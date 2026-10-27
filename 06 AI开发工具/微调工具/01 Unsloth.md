# Unsloth Core

[Unsloth](https://github.com/unslothai/unsloth) 项目目前包含 Desktop、Studio 和 Core 等使用入口，覆盖模型运行、训练与导出；各入口支持的硬件后端和功能并不完全相同。本文只介绍代码版 **Unsloth Core** 的训练流程，不展开桌面推理或 Studio 功能。

Core 与 Hugging Face Transformers、TRL、PEFT 等训练生态配合，为受支持的模型和硬件提供优化实现，可用于 SFT、LoRA / QLoRA、继续预训练及部分偏好优化或强化学习流程。优化效果取决于模型、硬件、精度和训练配置，不应理解为固定的速度或显存收益，也不限于单张 GPU。训练数据、模板、评估集和版本管理仍需自行设计。

## 适合什么场景

- 在官方当前支持的硬件与后端上，对开源模型进行 LoRA / QLoRA 微调
- 希望降低显存占用，快速验证领域数据、指令模板或超参数
- 使用 Hugging Face Datasets、Transformers 和 TRL 训练链路
- 训练后需要保留 LoRA Adapter，或导出合并模型、GGUF 等部署格式

使用前应核对目标模型、训练算法、操作系统和硬件是否在当前支持范围内；项目支持多 GPU 不代表任意多机并行配置都适用。知识可以通过微调注入，但如果事实经常变化或需要引用来源，RAG 通常更容易更新和审计。

## 安装

项目提供 Core、Desktop 和 Studio 等不同入口，安装命令不能互换。本文的 Python 训练示例使用 Core；其安装方式与操作系统、硬件后端、PyTorch 及 CUDA 等版本有关，应先查看[官方安装说明](https://unsloth.ai/docs/get-started/install)的当前组合矩阵。通常应在独立虚拟环境中安装：

```sh
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
# source .venv/bin/activate

# 以下命令仅适用于官方 Core 安装矩阵支持的环境
pip install --upgrade pip
pip install unsloth
```

安装后先用实际模型运行加载和极短训练，确认所选后端与驱动匹配；使用 bitsandbytes 量化时，再核对它与 PyTorch、硬件后端的兼容组合。若官方安装页要求指定 wheel 或额外安装命令，应按其步骤执行，不要混用其他教程中的版本组合。

## 最小 LoRA 微调流程

一个可复用的流程是：选择基础模型 → 准备训练集 → 加载 4-bit 模型 → 注入 LoRA → 用 TRL 训练 → 验证与导出。

下面示例只展示关键结构；模型名、数据集和训练参数应按任务调整：

```python
from datasets import load_dataset
from unsloth import FastLanguageModel
from trl import SFTConfig, SFTTrainer

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
    processing_class=tokenizer,
    train_dataset=dataset,
    args=SFTConfig(
        output_dir="outputs",
        dataset_text_field="text",
        max_length=2048,
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

示例模型只用于演示代码结构，应换成当前 Unsloth 支持且符合授权要求的模型。示例采用较新的 TRL `SFTConfig` 和 `processing_class` 接口；TRL 与 Unsloth 的 API 会变化，复现实验时应固定依赖版本，并对照[TRL SFTTrainer 文档](https://huggingface.co/docs/trl/main/en/sft_trainer)和匹配版本的官方示例。

## 数据与训练要点

- **先统一模板**：将训练集转换为模型对应的 chat template 或单一 `text` 字段，训练和推理必须使用同一套格式。
- **先做小样本冒烟测试**：用几十到几百条样本跑通加载、loss、保存和推理，再扩大数据量与训练步数。
- **控制有效 batch size**：数据并行时，`per_device_train_batch_size × gradient_accumulation_steps × 数据并行副本数` 才是有效 batch size；张量或流水线并行中的 GPU 数不应直接当作数据副本数。显存不足时可降低单设备 batch size，并相应调整梯度累积。
- **区分 Adapter 与完整模型**：LoRA 训练默认产出 Adapter，体积小、便于回滚；部署端若不支持 Adapter，再执行合并或格式转换。
- **用评估集判断效果**：保留未参与训练的任务样本，比较基础模型与微调模型的正确率、格式遵循、幻觉和安全性；不要只观察训练 loss。

## 导出与部署

常见产物选择：

| 产物 | 适合场景 |
| --- | --- |
| LoRA Adapter | 继续训练、实验管理，或由支持 PEFT 的推理服务加载。 |
| 合并后的 Hugging Face 模型 | Transformers、vLLM 等加载完整权重的服务。 |
| GGUF | llama.cpp、Ollama 等本地量化推理工具。 |

导出会涉及基础模型版本、tokenizer、量化方案和目标运行时。应在目标推理环境中以固定评测集验证导出后的模型，避免只验证“文件能加载”。具体导出命令请按[官方保存与部署指南](https://unsloth.ai/docs/basics/running-and-saving-models)执行。

## 常见问题

| 现象 | 优先检查 |
| --- | --- |
| CUDA out of memory | 降低 `max_seq_length`、单卡 batch size 或 LoRA rank；确认是否启用了 4-bit 加载。 |
| 训练后回答格式异常 | 检查训练集与推理时的 chat template、EOS token 和 prompt 格式是否一致。 |
| loss 下降但实际任务无提升 | 检查数据质量、重复样本和评估集；增加针对目标任务的样例，而非盲目延长训练。 |
| 导出模型无法使用 | 核对基础模型版本、tokenizer、Adapter 是否已合并，以及目标运行时支持的格式与量化。 |

## 参考

- GitHub：<https://github.com/unslothai/unsloth>
- 官方文档：<https://unsloth.ai/docs>
- Core 安装说明：<https://unsloth.ai/docs/get-started/install>
- 训练 notebooks：<https://unsloth.ai/docs/get-started/unsloth-notebooks>
- TRL SFTTrainer：<https://huggingface.co/docs/trl/main/en/sft_trainer>
