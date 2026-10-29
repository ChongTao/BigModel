# Unsloth 实战微调

本文从环境准备、模型加载与推理，逐步演示 LoRA 指令微调和情感分类。Gemma 3 270M 部分用于验证模型与训练流程；后半部分使用 Qwen3 0.6B 和 ChnSentiCorp 演示分类微调。示例采用小样本和有限训练步数，重点是理解流程与指标，不代表正式训练效果。

## 1 安装依赖

以下命令创建独立虚拟环境并安装 Unsloth，避免和其他项目的 Python 包相互影响。

```sh
python -m venv .venv
# Linux / macOS: source .venv/bin/activate
# Windows PowerShell: .\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
python -m pip install unsloth
```

Unsloth、PyTorch、CUDA、Transformers 与 TRL 的兼容组合会随平台和版本变化。GPU 环境应按操作系统和显卡选择匹配的 PyTorch/CUDA 安装方式。示例中的 `__file__` 输出路径适用于保存为 `.py` 文件运行；在 Notebook 中请改为显式指定目录。

## 2 加载模型

使用 Gemma 3 270M Instruct 检查模型和分词器能否正常加载。`MAX_SEQ_LENGTH` 限制输入序列长度；设得更大通常会增加显存或内存占用。分词测试用于检查对话模板和文本还原，不用于衡量模型回答质量。

```python
import os
import time
import torch
from unsloth import FastLanguageModel
from unsloth.chat_templates import get_chat_template

MODEL_NAME = "unsloth/gemma-3-270m-it"
MAX_SEQ_LENGTH = 1024  # 输入序列最大长度；示例用较小值控制内存
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

load_start = time.time()
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=MODEL_NAME,
    max_seq_length=MAX_SEQ_LENGTH,
    load_in_4bit=False,   # 本示例不启用 4bit 量化
    dtype=torch.float32,  # 示例使用兼容性较好的 float32
)
load_time = time.time() - load_start
print(f"\n✅ 模型加载成功，耗时 {load_time:.1f}s")

# 模型信息
n_params = sum(p.numel() for p in model.parameters())
print(f"参数量: {n_params / 1e6:.1f}M")
print(f"模型类型: {model.config.model_type}")
print(f"隐藏层维度: {model.config.hidden_size} | 层数: {model.config.num_hidden_layers}")
print(f"词表大小: {model.config.vocab_size}")

# 设置 Gemma3 chat 模板
tokenizer = get_chat_template(tokenizer, chat_template="gemma-3")
print(f"\n✅ 分词器就绪，词表实际大小: {len(tokenizer)}")

# ---------- 分词测试 ----------
print("\n" + "=" * 60)
print("分词器测试")
print("=" * 60)
test_texts = [
    "你好，世界！",
    "Hello, Gemma3! Unsloth makes fine-tuning faster.",
    "人工智能正在改变世界。Artificial intelligence is changing the world.",
]
for text in test_texts:
    ids = tokenizer(text)["input_ids"]
    # transformers 5.x 单条文本返回扁平 list；旧版返回嵌套 list，做兼容处理
    if ids and isinstance(ids[0], list):
        ids = ids[0]
    decoded = tokenizer.decode(ids)
    print(f"\n原文   : {text}")
    print(f"token数: {len(ids)}")
    print(f"ids前10: {ids[:10]}")
    print(f"还原   : {decoded}")
    assert text in decoded or decoded.strip() == text, "分词还原校验失败"
print("\n✅ 分词测试全部通过")

# ---------- 保存分词器供后续步骤使用 ----------
out_dir = os.path.join(os.path.dirname(__file__), "..", "outputs")
tokenizer.save_pretrained(os.path.join(out_dir, "tokenizer"))
print(f"✅ 分词器已保存至 outputs/tokenizer")
```

## 3 推理

以下代码接续第 2 节，使用已加载的 `model`、`tokenizer` 和 `DEVICE` 进行生成。`apply_chat_template` 按模型的对话格式构造输入，`max_new_tokens` 限制新生成的 token 数；关闭采样便于在同一环境下比较输出。该步骤用于检查推理调用，不是模型效果评估。

```python
test_prompts = [
    "用一句话介绍你自己。",
    "What is 2 + 2? Answer briefly.",
    "写一句关于春天的短诗。",
]

results = []
for i, prompt in enumerate(test_prompts, 1):
    print(f"\n{'-' * 60}")
    print(f"[测试 {i}] 用户: {prompt}")
    messages = [{"role": "user", "content": prompt}]
    enc = tokenizer.apply_chat_template(
        messages, add_generation_prompt=True, return_tensors="pt", return_dict=True
    )
    # transformers 5.x 返回 BatchEncoding(继承 UserDict 而非 dict)，直接按键取张量
    input_ids = enc["input_ids"] if hasattr(enc, "keys") else enc
    input_ids = input_ids.to(DEVICE)

    t0 = time.time()
    with torch.inference_mode():
        outputs = model.generate(
            input_ids=input_ids,
            max_new_tokens=64,
            use_cache=True,
            do_sample=False,  # 贪心解码，结果可复现
            pad_token_id=tokenizer.eos_token_id,
        )
    elapsed = time.time() - t0

    new_tokens = outputs.shape[1] - input_ids.shape[1]
    response = tokenizer.decode(outputs[0][input_ids.shape[1]:], skip_special_tokens=True)
    speed = new_tokens / elapsed

    print(f"模型: {response.strip()}")
    print(f"⏱  生成 {new_tokens} tokens / {elapsed:.1f}s = {speed:.1f} tok/s")
    results.append({"prompt": prompt, "response": response.strip(),
                    "tokens": new_tokens, "seconds": round(elapsed, 1),
                    "tok_per_s": round(speed, 1)})
```

## 4 LoRA 微调

本节对内置的 16 条问答样例注入 LoRA 并训练 10 个优化步骤。LoRA 冻结基座模型权重，只训练适配器参数；`r` 控制适配器容量，`lora_alpha` 控制缩放。示例使用单设备、`per_device_train_batch_size=1` 和 `gradient_accumulation_steps=4`，有效批次大小为 4，适合验证数据格式、训练循环和保存流程。

```python
import os
import time
import torch
torch.set_num_threads(4)

from datasets import Dataset
from trl import SFTTrainer, SFTConfig
from unsloth import FastLanguageModel
from unsloth.chat_templates import get_chat_template

MODEL_NAME = "unsloth/gemma-3-270m-it"
MAX_SEQ_LENGTH = 512
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs")
LORA_DIR = os.path.join(OUTPUT_DIR, "gemma3-270m-lora")

print("=" * 60)
print("步骤3：LoRA 微调小规模验证（CPU）")
print("=" * 60)

# ---------- 1. 加载模型并注入 LoRA ----------
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=MODEL_NAME,
    max_seq_length=MAX_SEQ_LENGTH,
    load_in_4bit=False,
    dtype=torch.float32,
)
tokenizer = get_chat_template(tokenizer, chat_template="gemma-3")

model = FastLanguageModel.get_peft_model(
    model,
    r=8,        # 低秩分解的维度，决定新增参数量
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],  # 注意力和 MLP 全部线性层都注入 LoRA
    lora_alpha=16,     # 缩放系数
    lora_dropout=0.05,
    bias="none",
    use_gradient_checkpointing=False,  # CPU 模式下关闭，避免兼容问题；内存足够
    random_state=3407,
)

trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
total = sum(p.numel() for p in model.parameters())
print(f"✅ LoRA 注入完成: 可训练参数 {trainable/1e6:.2f}M / 总计 {total/1e6:.1f}M "
      f"({100*trainable/total:.2f}%)")

# ---------- 2. 内置小样本数据集 ----------
samples = [
    ("你好", "你好！有什么我可以帮你的吗？"),
    ("介绍一下北京", "北京是中国的首都，是一座历史悠久的文化名城。"),
    ("水的化学式是什么？", "水的化学式是 H2O。"),
    ("1加1等于几？", "1 加 1 等于 2。"),
    ("中国有多少个省级行政区？", "中国共有 34 个省级行政区。"),
    ("什么是机器学习？", "机器学习是人工智能的一个分支，让计算机从数据中学习规律。"),
    ("太阳从哪边升起？", "太阳从东边升起。"),
    ("一年有多少天？", "平年有 365 天，闰年有 366 天。"),
    ("熊猫吃什么？", "大熊猫主要以竹子为食。"),
    ("地球是什么形状？", "地球是一个两极稍扁的椭球体。"),
    ("HTTP 的默认端口是多少？", "HTTP 的默认端口是 80。"),
    ("什么是光合作用？", "光合作用是植物利用光能将二氧化碳和水转化为有机物的过程。"),
    ("Python 是谁创造的？", "Python 由 Guido van Rossum 于 1991 年创造。"),
    ("彩虹有几种颜色？", "彩虹通常有七种颜色：红橙黄绿蓝靛紫。"),
    ("世界上最高的山是什么？", "世界上最高的山是珠穆朗玛峰。"),
    ("什么是 GPU？", "GPU 是图形处理器，擅长并行计算，常用于深度学习训练。"),
]

def format_sample(instruction, output):
    text = tokenizer.apply_chat_template(
        [
            {"role": "user", "content": instruction},
            {"role": "assistant", "content": output},
        ],
        tokenize=False,
    )
    return {"text": text}

dataset = Dataset.from_list([format_sample(i, o) for i, o in samples])
print(f"✅ 数据集就绪: {len(dataset)} 条样本")

# ---------- 3. 训练 ----------
trainer = SFTTrainer(
    model=model,
    processing_class=tokenizer,
    train_dataset=dataset,
    args=SFTConfig(
        per_device_train_batch_size=1,
        gradient_accumulation_steps=4,
        max_steps=10,               # 仅验证流程，10 步即停
        learning_rate=2e-4,
        warmup_steps=2,
        logging_steps=1,
        fp16=False,                 # CPU 不支持 fp16 训练
        bf16=False,                 # float32 最稳
        optim="adamw_torch",
        output_dir=os.path.join(OUTPUT_DIR, "train_tmp"),
        seed=3407,
        max_length=MAX_SEQ_LENGTH,   # TRL 1.x 中 max_seq_length 已改名为 max_length
        report_to=[],               # 不上报 wandb 等
        save_strategy="no",
    ),
)

print("\n开始训练（10 步）...")
t0 = time.time()
stats = trainer.train()
train_time = time.time() - t0
print(f"\n✅ 训练完成: 耗时 {train_time:.1f}s, "
      f"平均 {train_time/10:.1f}s/步, 最终 loss = {stats.training_loss:.4f}")

# ---------- 4. 保存 LoRA ----------
model.save_pretrained(LORA_DIR)  # peft 标准 API（旧教程的 save_lora 已移除）
tokenizer.save_pretrained(LORA_DIR)
lora_size = sum(f.stat().st_size for f in
                __import__("pathlib").Path(LORA_DIR).rglob("*") if f.is_file()) / 1e6
print(f"✅ LoRA 权重已保存至 outputs/gemma3-270m-lora/（{lora_size:.1f} MB）")

# ---------- 5. 微调后推理验证 ----------
print("\n微调后推理验证:")
FastLanguageModel.for_inference(model)
for prompt in ["什么是机器学习？", "太阳从哪边升起？"]:
    enc = tokenizer.apply_chat_template(
        [{"role": "user", "content": prompt}],
        add_generation_prompt=True, return_tensors="pt", return_dict=True,
    )
    input_ids = enc["input_ids"] if hasattr(enc, "keys") else enc
    with torch.inference_mode():
        out = model.generate(input_ids=input_ids, max_new_tokens=32,
                             do_sample=False, pad_token_id=tokenizer.eos_token_id)
    resp = tokenizer.decode(out[0][input_ids.shape[1]:], skip_special_tokens=True)
    print(f"  Q: {prompt}\n  A: {resp.strip()}\n")

import json
with open(os.path.join(OUTPUT_DIR, "finetune_results.json"), "w", encoding="utf-8") as f:
    json.dump({
        "trainable_params_M": round(trainable / 1e6, 2),
        "trainable_ratio_pct": round(100 * trainable / total, 2),
        "dataset_size": len(dataset),
        "max_steps": 10,
        "train_seconds": round(train_time, 1),
        "seconds_per_step": round(train_time / 10, 1),
        "final_loss": round(stats.training_loss, 4),
        "lora_size_MB": round(lora_size, 1),
    }, f, ensure_ascii=False, indent=2)
print("✅ 步骤3 完成，指标已保存至 outputs/finetune_results.json")

```
下面是一次示例运行输出。耗时、loss 和适配器文件大小会随硬件、依赖版本及训练配置变化。

```text
开始训练（10 步）...
{'loss': '6.304', 'grad_norm': '30.57', 'learning_rate': '0', 'entropy': '1.599', 'mean_token_accuracy': '0.4327', 'num_tokens': '116', 'epoch': '0.25'}
{'loss': '6.048', 'grad_norm': '28.09', 'learning_rate': '0.0001', 'entropy': '1.291', 'mean_token_accuracy': '0.4629', 'num_tokens': '240', 'epoch': '0.5'}
{'loss': '5.885', 'grad_norm': '19.48', 'learning_rate': '0.0002', 'entropy': '1.739', 'mean_token_accuracy': '0.4278', 'num_tokens': '359', 'epoch': '0.75'}
{'loss': '5.392', 'grad_norm': '23.19', 'learning_rate': '0.000175', 'entropy': '1.636', 'mean_token_accuracy': '0.4007', 'num_tokens': '475', 'epoch': '1'}
{'loss': '4.469', 'grad_norm': '16.91', 'learning_rate': '0.00015', 'entropy': '1.629', 'mean_token_accuracy': '0.5224', 'num_tokens': '581', 'epoch': '1.25'}
{'loss': '4.07', 'grad_norm': '14.2', 'learning_rate': '0.000125', 'entropy': '1.9', 'mean_token_accuracy': '0.4907', 'num_tokens': '699', 'epoch': '1.5'}
{'loss': '3.441', 'grad_norm': '9.166', 'learning_rate': '0.0001', 'entropy': '1.741', 'mean_token_accuracy': '0.5522', 'num_tokens': '824', 'epoch': '1.75'}
{'loss': '3.092', 'grad_norm': '7.688', 'learning_rate': '7.5e-05', 'entropy': '1.769', 'mean_token_accuracy': '0.6169', 'num_tokens': '950', 'epoch': '2'}
{'loss': '3.546', 'grad_norm': '8.4', 'learning_rate': '5e-05', 'entropy': '2.081', 'mean_token_accuracy': '0.5561', 'num_tokens': '1064', 'epoch': '2.25'}
{'loss': '3.014', 'grad_norm': '7.751', 'learning_rate': '2.5e-05', 'entropy': '1.744', 'mean_token_accuracy': '0.6596', 'num_tokens': '1179', 'epoch': '2.5'}
{'train_runtime': '20.55', 'train_samples_per_second': '1.946', 'train_steps_per_second': '0.487', 'train_loss': '4.526', 'epoch': '2.5'}
100%|█████████████████████████████████████████████████████████████████████████████████████████| 10/10 [00:20<00:00,  2.06s/it]

✅ 训练完成: 耗时 20.8s, 平均 2.1s/步, 最终 loss = 4.5262
✅ LoRA 权重已保存至 outputs/gemma3-270m-lora/（41.0 MB）

```

- loss: 当前累积窗口内的交叉熵损失（预测下一个 token 的误差）
- grad_norm: 梯度全局 L2 范数，反映梯度规模；单看该数值不能判断训练是否稳定
- learning_rate: 当前学习率（含预热/衰减调度的实际值）
- entropy: 输出分布的熵，越高说明模型越“不确定”
- mean_token_accuracy: 预测 token 与标签一致的比例（greedy 意义下的 top-1 准确率）
- num_tokens: 日志记录的处理 token 数，具体统计口径可能随 Transformers/TRL 版本变化
- epoch: 已训练的 epoch 进度

本次配置用于验证模型加载、对话模板、LoRA 注入、数据格式、训练循环和适配器保存。16 条样例、有效批次大小 4、10 个优化步骤对应约 2.5 轮数据遍历；loss 下降只能说明训练过程产生了更新，不能据此判断模型已经收敛或具备泛化能力。要评估问答效果，应使用未参与训练的数据，并结合任务结果调整数据规模和训练步数。保存的 LoRA 是适配器权重，后续推理还需要匹配的基座模型。

## 5 Qwen3 LoRA 微调：情感分类

本节使用 ChnSentiCorp 演示中文情感二分类，并将分类转换成生成“正面”或“负面”标签的任务。示例从训练集抽取 500 条、从测试集抽取 100 条，训练 1 个 epoch；样本量用于快速展示数据处理、基线评估和微调后评估流程，结果不代表完整数据集上的性能。

代码会从 Hugging Face Hub 下载数据和模型。CPU 上的 `bfloat16` 支持取决于处理器与 PyTorch 构建；若不支持，可改用兼容的类型（如 `float32`）并重新评估内存。内存统计在 Linux/macOS 上读取 `resource` 并按平台单位换算；Windows 不提供该模块，代码会跳过峰值内存统计。

```python
import os
import json
import math
import sys
import time

try:
    import resource
except ImportError:
    resource = None

import torch
from huggingface_hub import hf_hub_download
from datasets import load_dataset
from trl import SFTTrainer, SFTConfig
from unsloth import FastLanguageModel
from unsloth.chat_templates import get_chat_template

MODEL_NAME = "unsloth/Qwen3-0.6B"
MAX_SEQ_LENGTH = 256           # 评论较短，256 足够且省内存/时间
MODEL_DTYPE = torch.bfloat16   # 需确认 CPU/PyTorch 支持 BF16；不支持时可改为 torch.float32
SEED = 3407
N_TRAIN, N_TEST = 500, 100
LABEL_MAP = {1: "正面", 0: "负面"}
INSTRUCTION = '请判断以下中文评论的情感倾向，只回答"正面"或"负面"。'

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs")
DATASET_DIR = os.path.join(OUTPUT_DIR, "dataset_cls")
LORA_DIR = os.path.join(OUTPUT_DIR, "qwen3-0.6b-lora-cls")
os.makedirs(DATASET_DIR, exist_ok=True)

print("=" * 60)
print("步骤6：Qwen3 0.6B 分类微调（ChnSentiCorp 情感二分类）")
print("=" * 60)

# ---------- 1. 下载并切分数据集（arrow 直载，兼容 datasets 4.x） ----------
print("\n[1/6] 下载 ChnSentiCorp 并切分训练/测试集...")
arrow_files = {
    split: hf_hub_download("seamew/ChnSentiCorp", f"chn_senti_corp-{split}.arrow", repo_type="dataset")
    for split in ["train", "test"]
}
full = load_dataset("arrow", data_files=arrow_files)

train_raw = full["train"].shuffle(seed=SEED).select(range(N_TRAIN))
test_raw = full["test"].shuffle(seed=SEED).select(range(N_TEST))
print(f"  训练集: {len(train_raw)} 条 | 测试集: {len(test_raw)} 条")
pos = sum(test_raw["label"])
print(f"  测试集标签分布: 正面 {pos} / 负面 {len(test_raw) - pos}")

train_raw.to_json(os.path.join(DATASET_DIR, "train.json"), force_ascii=False, orient="records")
test_raw.to_json(os.path.join(DATASET_DIR, "test.json"), force_ascii=False, orient="records")
print("  已保存至 outputs/dataset_cls/train.json / test.json")

# ---------- 2. 加载模型 + LoRA ----------
print("\n[2/6] 加载模型并注入 LoRA...")
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name=MODEL_NAME,
    max_seq_length=MAX_SEQ_LENGTH,
    load_in_4bit=False,
    dtype=MODEL_DTYPE,
)
tokenizer = get_chat_template(tokenizer, chat_template="qwen-3")

model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=32,
    lora_dropout=0.05,
    bias="none",
    use_gradient_checkpointing=False,
    random_state=SEED,
)
trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
total = sum(p.numel() for p in model.parameters())
print(f"  可训练参数: {trainable/1e6:.2f}M / {total/1e6:.1f}M ({100*trainable/total:.2f}%)")

# ---------- 3. 格式化为分类样本（关闭思考模式，直接输出标签） ----------
def to_text(ex):
    user_content = f'{INSTRUCTION}\n评论：{ex["text"]}\n答案：'
    text = tokenizer.apply_chat_template(
        [{"role": "user", "content": user_content},
         {"role": "assistant", "content": LABEL_MAP[ex["label"]]}],
        tokenize=False,
        enable_thinking=False,   # 分类任务无需思维链
    )
    return {"text": text}

train_ds = train_raw.map(to_text, remove_columns=train_raw.column_names)
test_ds = test_raw.map(to_text, remove_columns=test_raw.column_names)

# ---------- 4. Trainer + 基线评估 ----------
trainer = SFTTrainer(
    model=model,
    processing_class=tokenizer,
    train_dataset=train_ds,
    eval_dataset=test_ds,
    args=SFTConfig(
        per_device_train_batch_size=1,
        per_device_eval_batch_size=1,
        gradient_accumulation_steps=4,
        num_train_epochs=1,
        learning_rate=2e-4,
        lr_scheduler_type="cosine",
        warmup_ratio=0.05,
        logging_steps=10,
        eval_strategy="steps",
        eval_steps=25,
        fp16=False, bf16=False,   # CPU 训练
        optim="adamw_torch",
        output_dir=os.path.join(OUTPUT_DIR, "train_tmp6"),
        seed=SEED,
        max_length=MAX_SEQ_LENGTH,  # TRL 1.x 参数名
        report_to=[],
        save_strategy="steps",      # 定期存 checkpoint，被 OOM 杀掉可断点续训
        save_steps=50,
        save_total_limit=1,
        save_only_model=True,
    ),
)

def parse_pred(text):
    """从生成文本中解析分类标签：取最先出现的「正面/负面」。"""
    t = text.strip()
    i_pos, i_neg = t.find("正面"), t.find("负面")
    if i_pos == -1 and i_neg == -1:
        return None
    if i_pos == -1: return 0
    if i_neg == -1: return 1
    return 1 if i_pos < i_neg else 0

def generate_label(review):
    user_content = f'{INSTRUCTION}\n评论：{review}\n答案：'
    enc = tokenizer.apply_chat_template(
        [{"role": "user", "content": user_content}],
        add_generation_prompt=True, return_tensors="pt", return_dict=True,
        enable_thinking=False,
    )
    input_ids = enc["input_ids"] if hasattr(enc, "keys") else enc
    with torch.inference_mode():
        out = model.generate(input_ids=input_ids, max_new_tokens=6,
                             do_sample=False, pad_token_id=tokenizer.eos_token_id)
    return tokenizer.decode(out[0][input_ids.shape[1]:], skip_special_tokens=True).strip()

def eval_accuracy(tag):
    """在测试集上生成式评估分类准确率，返回 (acc, preds, invalid)。"""
    t0 = time.time()
    correct, invalid, preds = 0, 0, []
    for ex in test_raw:
        raw = generate_label(ex["text"])
        p = parse_pred(raw)
        preds.append(p)
        if p is None:
            invalid += 1
        elif p == ex["label"]:
            correct += 1
    acc = correct / len(test_raw)
    print(f"  [{tag}] 分类准确率 = {correct}/{len(test_raw)} = {acc*100:.1f}% "
          f"(无法解析 {invalid} 条) | 耗时 {time.time()-t0:.1f}s")
    return acc, preds, invalid

print("\n[3/6] 训练前基线评估（测试集 100 条）...")
t0 = time.time()
base_eval = trainer.evaluate()
base_loss = base_eval["eval_loss"]
base_ppl = math.exp(base_loss)
print(f"  基线 test loss = {base_loss:.4f} | 困惑度 = {base_ppl:.2f} | 耗时 {time.time()-t0:.1f}s")

print("\n[4/6] 基线生成式分类准确率（LoRA B 零初始化，等价于原始模型）...")
base_acc, base_preds, base_invalid = eval_accuracy("基线")
base_answers = [generate_label(ex["text"]) for ex in test_raw.select(range(5))]

# ---------- 5. 训练（支持从 checkpoint 断点续训） ----------
import glob
ckpt_dir = os.path.join(OUTPUT_DIR, "train_tmp6")
ckpts = sorted(glob.glob(os.path.join(ckpt_dir, "checkpoint-*")),
               key=lambda p: int(p.rsplit("-", 1)[-1]))
resume = ckpts[-1] if ckpts else None
if resume:
    print(f"\n[5/6] 发现 checkpoint，从 {os.path.basename(resume)} 断点续训...")
else:
    print("\n[5/6] 开始 LoRA 分类微调（1 epoch，约 125 步）...")
t0 = time.time()
stats = trainer.train(resume_from_checkpoint=resume)
train_time = time.time() - t0
print(f"  ✅ 训练完成: {train_time:.1f}s ({train_time/stats.global_step:.2f}s/步), "
      f"平均 train loss = {stats.training_loss:.4f}")

# ---------- 6. 训练后评估 ----------
print("\n[6/6] 训练后评估（测试集）...")
post_eval = trainer.evaluate()
post_loss = post_eval["eval_loss"]
post_ppl = math.exp(post_loss)
print(f"  微调后 test loss = {post_loss:.4f} | 困惑度 = {post_ppl:.2f}")
print(f"  📉 loss 变化: {base_loss:.4f} -> {post_loss:.4f} "
      f"({100*(base_loss-post_loss)/base_loss:+.1f}%)")

FastLanguageModel.for_inference(model)
post_acc, post_preds, post_invalid = eval_accuracy("微调后")

print("\n  样例对比（前 5 条测试评论）:")
qualitative = []
for i, ex in enumerate(test_raw.select(range(5))):
    after = generate_label(ex["text"])
    gold = LABEL_MAP[ex["label"]]
    qualitative.append({"review": ex["text"][:80], "gold": gold,
                        "before": base_answers[i], "after": after})
    print(f"  评论: {ex['text'][:50]}...")
    print(f"    标准: {gold} | 前: {base_answers[i][:20]} | 后: {after[:20]}")

# 保存 LoRA
model.save_pretrained(LORA_DIR)
tokenizer.save_pretrained(LORA_DIR)
print("\n  ✅ LoRA 已保存至 outputs/qwen3-0.6b-lora-cls/")

if resource is None:
    peak_mb = None
    print("  📈 当前平台不提供 resource 模块，跳过进程峰值内存统计")
else:
    peak_rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    peak_mb = peak_rss / (1024 * 1024 if sys.platform == "darwin" else 1024)
    print(f"  📈 进程峰值内存: {peak_mb:.0f} MB")

# ---------- 汇总指标 ----------
results = {
    "task": "ChnSentiCorp 中文情感二分类（生成式标签）",
    "model": MODEL_NAME, "dtype": str(MODEL_DTYPE).replace("torch.", ""),
    "train_size": len(train_ds), "test_size": len(test_ds),
    "lora_r": 16, "lora_alpha": 32,
    "trainable_params_M": round(trainable/1e6, 2),
    "epochs": 1, "global_step": stats.global_step,
    "train_seconds": round(train_time, 1),
    "seconds_per_step": round(train_time/stats.global_step, 2),
    "avg_train_loss": round(stats.training_loss, 4),
    "baseline_test_loss": round(base_loss, 4),
    "baseline_test_ppl": round(base_ppl, 2),
    "finetuned_test_loss": round(post_loss, 4),
    "finetuned_test_ppl": round(post_ppl, 2),
    "baseline_accuracy": round(base_acc, 4),
    "finetuned_accuracy": round(post_acc, 4),
    "baseline_invalid": base_invalid,
    "finetuned_invalid": post_invalid,
    "peak_memory_mb": round(peak_mb) if peak_mb is not None else None,
    "eval_history": [{k: v for k, v in log.items() if k in
                      ("loss", "eval_loss", "epoch", "step")}
                     for log in trainer.state.log_history],
    "qualitative": qualitative,
}
with open(os.path.join(OUTPUT_DIR, "finetune_cls_results.json"), "w",
          encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
print("\n✅ 步骤6 完成，指标已保存至 outputs/finetune_cls_results.json")

```

### 指标解读

- `eval_loss` 和困惑度反映格式化文本上的 token 级预测损失，不等同于分类准确率。
- 分类准确率来自生成文本解析；`无法解析` 统计没有生成可识别标签的样本。解析器按文本中最先出现的“正面”或“负面”作为预测标签。
- 基线和微调后指标使用同一测试集，便于对照；100 条测试样本较少，评估结论仍需更多数据和样例复核。
- 输出目录保存的是 LoRA 适配器和分词器；推理时仍需加载与训练时匹配的基座模型。
