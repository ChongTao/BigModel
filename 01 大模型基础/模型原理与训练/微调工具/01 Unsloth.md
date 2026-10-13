# 1 Unsloth

[Unsloth](https://github.com/unslothai/unsloth) 是面向大语言模型微调与推理优化的开源工具。它围绕 LoRA / QLoRA 等参数高效微调（PEFT）流程，提供经过优化的模型加载、训练和导出路径，目标是在单张 GPU 上以更少显存完成 SFT、继续预训练或偏好优化等任务。

它不是标注平台，也不替代训练框架；更适合把 Hugging Face、TRL、PEFT 等生态中的训练流程简化并加速。

## 1.1 适合什么场景

- 在消费级 NVIDIA GPU 上对开源模型进行 LoRA / QLoRA 微调
- 希望降低显存占用，快速验证领域数据、指令模板或超参数
- 使用 Hugging Face 数据集、Transformers 和 TRL 训练链路
- 训练后需要保留 LoRA Adapter，或导出合并模型、GGUF 等部署格式

不适合的情况包括：没有兼容 GPU 却需要本地大规模训练、需要多机大规模全参数训练，或训练目标本质上是检索/知识更新而非行为与风格调整。此类需求应分别考虑云端训练、分布式训练方案或 RAG。

## 1.2 安装

Unsloth 的安装与 GPU、CUDA、PyTorch 版本强相关，应先查看[官方安装页](https://docs.unsloth.ai/get-started/installing-+-updating)的当前组合矩阵。通常应在独立虚拟环境中安装：

```sh
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
# source .venv/bin/activate

pip install --upgrade pip
pip install unsloth
```

安装后先用实际模型运行一次加载和极短训练，验证 CUDA、PyTorch、bitsandbytes 与驱动版本是否匹配。若官方安装页要求指定 PyTorch / CUDA wheel，应按其命令安装，不要混用其他教程中的版本组合。

## 1.3 最小 LoRA 微调流程

一个可复用的流程是：选择基础模型 → 准备训练集 → 加载 4-bit 模型 → 注入 LoRA → 用 TRL 训练 → 验证与导出。

下面示例只展示关键结构；模型名、数据集和训练参数应按任务调整：

```python
from datasets import load_dataset
from unsloth import FastLanguageModel
from trl import SFTTrainer
from transformers import TrainingArguments

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Llama-3.2-3B-Instruct",
    max_seq_length=2048,
    load_in_4bit=True,
)

model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_alpha=16,
    lora_dropout=0,
)

dataset = load_dataset("json", data_files="train.jsonl", split="train")

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=2048,
    args=TrainingArguments(
        output_dir="outputs",
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        num_train_epochs=1,
        learning_rate=2e-4,
        logging_steps=1,
    ),
)
trainer.train()
model.save_pretrained("adapter")
tokenizer.save_pretrained("adapter")
```

不同版本的 TRL 与 Unsloth 参数可能变化，运行前应对照官方 notebook / 文档调整导入和 `SFTTrainer` 参数。

## 1.4 数据与训练要点

- **先统一模板**：将训练集转换为模型对应的 chat template 或单一 `text` 字段，训练和推理必须使用同一套格式。
- **先做小样本冒烟测试**：用几十到几百条样本跑通加载、loss、保存和推理，再扩大数据量与训练步数。
- **控制有效 batch size**：`per_device_train_batch_size × gradient_accumulation_steps × GPU 数` 才是有效 batch size；显存不足时优先降低前者、增加后者。
- **区分 Adapter 与完整模型**：LoRA 训练默认产出 Adapter，体积小、便于回滚；部署端若不支持 Adapter，再执行合并或格式转换。
- **用评估集判断效果**：保留未参与训练的任务样本，比较基础模型与微调模型的正确率、格式遵循、幻觉和安全性；不要只观察训练 loss。

## 1.5 导出与部署

常见产物选择：

| 产物 | 适合场景 |
| --- | --- |
| LoRA Adapter | 继续训练、实验管理，或由支持 PEFT 的推理服务加载。 |
| 合并后的 Hugging Face 模型 | Transformers、vLLM 等加载完整权重的服务。 |
| GGUF | llama.cpp、Ollama 等本地量化推理工具。 |

导出会涉及基础模型版本、tokenizer、量化方案和目标运行时。应在目标推理环境中以固定评测集验证导出后的模型，避免只验证“文件能加载”。具体导出命令请按[官方保存与部署指南](https://docs.unsloth.ai/basics/running-and-saving-models)执行。

## 1.6 常见问题

| 现象 | 优先检查 |
| --- | --- |
| CUDA out of memory | 降低 `max_seq_length`、单卡 batch size 或 LoRA rank；确认是否启用了 4-bit 加载。 |
| 训练后回答格式异常 | 检查训练集与推理时的 chat template、EOS token 和 prompt 格式是否一致。 |
| loss 下降但实际任务无提升 | 检查数据质量、重复样本和评估集；增加针对目标任务的样例，而非盲目延长训练。 |
| 导出模型无法使用 | 核对基础模型版本、tokenizer、Adapter 是否已合并，以及目标运行时支持的格式与量化。 |

## 1.7 参考

- GitHub：<https://github.com/unslothai/unsloth>
- 官方文档：<https://docs.unsloth.ai/>
- 安装与更新：<https://docs.unsloth.ai/get-started/installing-+-updating>
- 训练 notebooks：<https://docs.unsloth.ai/get-started/unsloth-notebooks>
