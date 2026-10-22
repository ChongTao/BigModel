# Embedding

## 1. Embedding 是什么

Embedding（嵌入或向量表示）是把对象映射为向量或向量序列的表示方法。大模型中的对象可以是 Token、文本、图像、音频或代码。

Embedding 通常用于表示、检索、匹配或分类，不负责直接生成答案。模型的训练目标决定了哪些对象会在表示空间中靠近。只有经过联合训练或对齐的表示，才适合跨模态比较；不同模型输出的向量通常不能直接互比。

例如，在与模型训练任务匹配时：

- 语义接近或任务相关的句子，可能在向量空间中更接近。
- 同一个 Token ID 的初始查表向量相同，经过上下文编码后得到的表示则可能不同。

Embedding 是很多能力的基础组件，例如：

- 语义搜索与向量检索
- 聚类与分类
- 推荐系统
- 文本相似度计算
- RAG 中的语义召回

但要注意：**Embedding 是一个宽泛概念，既可以指模型输入侧的 Token 查表向量，也可以指面向任务的句子、文档或其他对象表示。**这些表示的形状、训练目标和可比较范围可能不同。

## 2. 从文本到表示

以常见的文本编码模型为例，文本表示通常经历以下步骤；具体模型可能使用不同的编码器和输出方式：

1. 分词：把文本切成 Token。
2. 编号：把 Token 映射到词表中的 ID。
3. 查表：把每个 Token ID 映射为初始向量。
4. 编码：经过序列模型处理，得到上下文化表示。
5. 生成任务表示：按模型设计使用特殊 Token、池化或任务头得到单向量；也可能保留多个 Token 向量或输出稀疏词项权重。

```mermaid
flowchart LR
  A["Token 或模态输入表示"] --> B["上下文化编码"]
  B --> C["任务表示：稠密、稀疏或多向量"]
  C --> D["检索与匹配"]
  D --> E["重排与上下文组织"]
  E --> F["生成回答"]
```

图中前三个节点是 Embedding 模型自身的职责，后三个发生在 RAG 链路里；两者的边界见文末说明。

### 2.1 Token Embedding

这是最狭义的 embedding，表示：

`token id -> 向量`

例如，词表中的某个 Token ID 查表后得到一个固定维度的向量。这一步是把离散符号映射到可计算空间。

### 2.2 上下文化表示

同一个 Token 进入序列模型（常见为 Transformer）后，会结合上下文更新表示。

因此：

- 初始 `token embedding` 是查表得到的参数向量。
- 经过模型层后的表示会受到上下文影响。

所以，同一个词在不同句子中的上下文化表示可能不同。

### 2.3 Text Embedding

很多检索模型会把整句话或整段文本编码成一个单向量；也有模型保留多个 Token 向量，或输出稀疏词项权重。

单向量通常就是 RAG、向量数据库和语义检索里所说的 `embedding`。

因此在工程语境里，口头所说的“做 embedding”很多时候是： **把一段文本编码成可用于匹配的句向量、文档向量或其他检索表示。**

## 3. 常见表示形式

### 3.1 稀疏向量

稀疏向量（Sparse Vector）是指大多数维度为 0、只有少量维度非零的表示。词项稀疏表示的维度通常对应词表或扩展词表中的词项，因此可以达到数万甚至十几万维，而单条文本往往只有几十个非零位置。

常见的稀疏表示分两类：

- 统计型：One-hot、词袋、TF-IDF。权重由词频和语料统计得出，不需要训练。
- 学习型：SPLADE 等模型用神经网络为词项生成权重，还可能扩展出原文没有出现的词项，从而在保留词面匹配的同时获得部分语义泛化能力。

需要区分的是，BM25 这类传统词项检索基于倒排索引和词项统计打分，**它是排序函数，不是学习型 Embedding 模型**；工程上仍常把它和稀疏向量检索放在一起比较，因为二者都擅长精确词面匹配。

由于大多数维度为 0，稀疏向量通常只存储非零值及其位置，而不完整保存所有维度。常见形式包括坐标列表、压缩稀疏行和索引到数值的映射。

例如，一个 6 维向量 `[0, 0, 1, 0, 0, 2]` 只有 2 个非零位置，可以表示为索引 `[2, 5]` 对应数值 `[1, 2]`，或写成 `{ "2": 1, "5": 2 }`。实际索引从 0 还是 1 开始取决于具体实现。真实词项向量的维度远大于 6，稀疏程度也更高。

### 3.2 稠密向量

稠密向量（Dense Vector）是指大多数维度都为非零值的向量表示。现代神经网络生成的文本表示常采用这种形式。

稠密向量通常有以下特点：

- 多个维度共同表达特征，单个维度未必有稳定、直观的含义。
- 输出维度和是否归一化由模型或接口规定；不同模型的向量通常不可直接混用。
- 常用于稠密向量检索、聚类、推荐和语义匹配。

稠密向量的质量依赖模型和训练任务。

### 3.3 多向量表示

有些检索模型会保留文本中多个 Token 的上下文化向量，而不是把整段文本压成一个向量。例如 ColBERT 使用 late interaction，在查询与文档的 Token 向量之间计算匹配。这种表示能保留细粒度匹配信息，但通常需要存储和比较更多向量。

因此，“Embedding”不一定意味着“每段文本对应一个固定长度的稠密向量”。

## 4. 维度、长度与存储

### 4.1 常见维度档位

稠密向量的维度由模型决定，常见档位如下：

| 维度 | 典型来源 | 特点 |
| --- | --- | --- |
| 384 | `all-MiniLM-L6-v2` 等轻量模型 | 存储与计算最省，精度上限较低 |
| 768 | BERT-base 一类的 base 档模型 | 常见的默认选择 |
| 1024 | large 档模型、`bge-m3`、Qwen3-Embedding-0.6B | 精度与成本的折中点 |
| 1536 | `text-embedding-3-small`、`text-embedding-ada-002` | API 模型的常见档位 |
| 2560 / 3072 / 4096 | Qwen3-Embedding-4B/8B、`text-embedding-3-large` | 精度更高，存储与检索成本同步上升 |

维度更高不必然更好：它直接放大存储、ANN 检索耗时和网络带宽，而收益必须用自己的数据验证。

### 4.2 存储开销怎么估

一条 FP32 向量占 `维度 × 4` 字节。以 1024 维为例，单条约 4 KB，1000 万条约 40 GB，这还没算索引结构的额外开销和原始文本。几个推论：

- 半精度（FP16/BF16）减半，INT8 量化降到四分之一，但都需要实测召回率损失。
- 向量条数通常等于 Chunk 数而不是文档数；分块越细，向量越多。
- 多向量表示还要再乘上每段文本保留的 Token 向量数，存储放大最明显。

### 4.3 截断维度：MRL

Matryoshka Representation Learning（MRL，套娃表示学习）在训练时就让向量的前 k 维单独可用。支持 MRL 的模型（如 Qwen3-Embedding、`text-embedding-3` 系列）允许直接截取前 256 或 512 维，用少量精度损失换取数倍的存储与检索成本下降。

需要注意：截断后通常要重新做归一化；不支持 MRL 的模型直接截断会明显掉点，因为它的信息分散在所有维度上。

### 4.4 最大输入长度与截断

Embedding 模型有最大输入 Token 数：早期 BERT 系多为 512，`bge-m3`、`text-embedding-3` 等新一代模型普遍到 8K 左右，Qwen3-Embedding 可到 32K。

超限后的行为分两种：有的实现按 `truncation=True` 静默丢弃尾部，有的直接报错。静默截断更危险——长文档只有开头被编码，向量照常生成、接口不报错、日志无异常，但检索质量系统性变差。因此：

- 入库前先确认模型的最大输入长度，并让分块长度留出余量。
- 对超长输入显式分块，不要依赖模型截断。
- 查询侧一般很短，真正容易踩坑的是文档侧。

## 参考资料

- [Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks](https://arxiv.org/abs/1908.10084)
- [SPLADE: Sparse Lexical and Expansion Model for First Stage Ranking](https://arxiv.org/abs/2107.05720)
- [ColBERT: Efficient and Effective Passage Search via Contextualized Late Interaction over BERT](https://arxiv.org/abs/2004.12832)
- [MTEB: Massive Text Embedding Benchmark](https://arxiv.org/abs/2210.07316)
- [MMTEB: Massive Multilingual Text Embedding Benchmark](https://arxiv.org/abs/2502.13595)
- [Text Embeddings by Weakly-Supervised Contrastive Pre-training (E5)](https://arxiv.org/abs/2212.03533)
- [Improving Text Embeddings with Large Language Models (E5-mistral)](https://arxiv.org/abs/2401.00368)
- [C-Pack: Packed Resources For General Chinese Embeddings (BGE / C-MTEB)](https://arxiv.org/abs/2309.07597)
- [BGE M3-Embedding: Multi-Lingual, Multi-Functionality, Multi-Granularity](https://arxiv.org/abs/2402.03216)
- [Towards General Text Embeddings with Multi-stage Contrastive Learning (GTE)](https://arxiv.org/abs/2308.03281)
- [Qwen3 Embedding: Advancing Text Embedding and Reranking Through Foundation Models](https://arxiv.org/abs/2506.05176)
- [Approximate Nearest Neighbor Negative Contrastive Learning for Dense Text Retrieval (ANCE)](https://arxiv.org/abs/2007.00808)
- [Matryoshka Representation Learning](https://arxiv.org/abs/2205.13147)
- [Learning Transferable Visual Models From Natural Language Supervision (CLIP)](https://arxiv.org/abs/2103.00020)
- [Sigmoid Loss for Language Image Pre-Training (SigLIP)](https://arxiv.org/abs/2303.15343)
