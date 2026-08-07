# Superlinked SIE

[Superlinked SIE](https://github.com/superlinked/sie) 是 Superlinked 开源的 SIE（Superlinked Inference Engine）项目，面向 AI 应用中的向量检索与语义相似度计算场景。它可作为搜索、推荐和 RAG 等系统的数据检索层候选方案，把 Agent 所需的全部模型（嵌入、检索、文档解析、结构化输出、内容安全、Agent 循环本身）统一到一个集群、一个 API 中运行，替代"每个任务各起一个模型服务"的拼凑架构。

## 1. 核心能力
| 任务 | 做什么 | 代表模型 |
|---|---|---|
| 搜索 & 检索 | Embedding → 匹配 → 重排，获取精准上下文 | bge-m3, splade-v3, colbertv2, qwen3-reranker |
| 文档转 Markdown | PDF / Office / 扫描件 → 干净的 Markdown | lightningocr, glm-ocr, mineru, paddleocr-vl, docling |
| 结构化输出 | 生成 Schema 合规的 JSON，支持抽取和生成 | gliner2, numen-zero, qwen3.6-27b |
| 内容安全 | 安全判定 + 可配置概率阈值 | granite-guardian-2b |
| Agent 循环 | 规划步骤、调用工具、支持流式输出 | qwen3.6-27b |

![](https://substackcdn.com/image/fetch/$s_!lr4l!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd3baae5a-b05a-40f1-9a78-c143b21c3bcf_2950x1440.png)

## 2. 技术亮点

- OpenAI 兼容 API — 提供 /v1/embeddings、/v1/chat/completions、/v1/completions、/v1/responses，可无缝迁移现有 OpenAI 客户端代码。
- 多模型同时服务 — **按需加载模型权重**，LRU 策略自动驱逐，一个集群跑 100+ 模型。

  ![](https://substackcdn.com/image/fetch/$s_!lkC5!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F7b6c56ca-0fcf-4b17-b9a4-0cf3f6b02d5f_1199x575.jpeg)
- 预配置模型目录 — Stella、SPLADE、Qwen3、GLiNER、SigLIP 等，嵌入和检索模型在 MTEB 上有基准评测。
- 完整生产栈 — 自带负载均衡网关、KEDA 自动扩缩容、Grafana 监控面板、Terraform 部署模板（支持 GKE / EKS / AKS）。
- 生态集成 — LangChain、LlamaIndex、Haystack、DSPy、CrewAI、Chroma、Qdrant、Weaviate、LanceDB 等主流框架开箱即用。



## 3. 快速上手
1. 安装（Python 本地）：
```sh

pip install "sie-server[local]" && sie-server serve
```

2. Docker（NVIDIA GPU）：
```sh
docker run --gpus all -p 8080:8080 \
  -v sie-hf-cache:/app/.cache/huggingface \
  ghcr.io/superlinked/sie-server:latest-cuda12-default
```

3. Docker（纯 CPU）：
```sh
docker run -p 8080:8080 \
  -v sie-hf-cache:/app/.cache/huggingface \
  ghcr.io/superlinked/sie-server:latest-cpu-default
```

4. SDK 安装：
```sh
pip install sie-sdk          # Python
npm install @superlinked/sie-sdk  # TypeScript
```

使用示例（Python）：
```python
from sie_sdk import SIEClient
from sie_sdk.types import Item

client = SIEClient("http://localhost:8080")

# 生成嵌入
result = client.encode("sentence-transformers/all-MiniLM-L6-v2", Item(text="Hello world"))

# 重排搜索结果
scores = client.score(
    "cross-encoder/ms-marco-MiniLM-L-6-v2",
    Item(text="What is machine learning?"),
    [Item(text="ML learns from data."), Item(text="The weather is sunny.")],
)

# 实体抽取
result = client.extract(
    "urchade/gliner_multi-v2.1",
    Item(text="Tim Cook is the CEO of Apple."),
    labels=["person", "organization"],
)
```

## 4. 适用场景
- Agent 基础设施统一化 — 不再为 RAG 嵌入、文档解析、LLM 推理、安全过滤各搭一套服务
- 私有化部署 — 数据不出云，模型全部自托管
- 成本优化 — 多模型共享 GPU 资源，按需加载避免闲置
- 从 OpenAI 迁移 — API 兼容，改动最小

## 5.参考
- https://blog.dailydoseofds.com/p/hands-on-how-to-serve-5-models-on?utm_source=post-email-title&publication_id=1119889&post_id=208720252&utm_campaign=email-post-title&isFreemail=true&r=8lo7xg&triedRedirect=true&utm_medium=email