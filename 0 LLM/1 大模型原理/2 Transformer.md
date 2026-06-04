# 一 Transformer

Transformer 是现代大语言模型最核心的底层架构之一。它由 Google 团队在 2017 年的论文 [Attention Is All You Need](https://arxiv.org/abs/1706.03762) 中提出。

如果前一篇 [1 LLM基本概念.md](./1%20LLM%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md) 解决的是“LLM 在处理什么、输出什么”，那么这一篇解决的是：**模型内部到底用什么结构完成这些计算。**

## 1.1 Transformer 的核心思想

Transformer 的核心思想是：

**不再依赖 RNN 那样按时间步逐个处理序列，而是通过注意力机制一次性建模整个序列中的关系。**

这带来三个关键收益：

- 更容易并行训练
- 更擅长建模长距离依赖
- 更容易扩展到超大参数规模

## 1.2 Transformer 结构图

![](https://www.runoob.com/wp-content/uploads/2025/06/Transformer_full_architecture.png)

上图展示的是 **2017 原始论文中的经典 Encoder-Decoder Transformer**。从这个经典结构看，Transformer 主要包含：

1. 输入处理：把 token 转成向量，并加入位置信息
2. 编码器（Encoder）
3. 解码器（Decoder）
4. 输出层：把内部表示映射回词表概率

但要注意：**“Transformer”是一个架构家族，不等于必须同时有 Encoder 和 Decoder。**

## 1.3 编码器与解码器

### 1.3.1 编码器

编码器的作用是：对输入序列做上下文化理解。

常见组成包括：

- Multi-Head Self-Attention
- Feed-Forward Network
- Residual Connection
- LayerNorm

编码器适合理解任务，因此很多理解型模型会偏向 Encoder-Only 结构。

### 1.3.2 解码器

解码器的作用是：根据已有上下文一步步生成后续内容。

它和编码器的重要差异在于：

- 解码器会使用因果掩码（causal mask）
- 当前 token 只能看到自己之前的内容，不能看到未来

这保证了生成过程符合“从前到后逐步生成”的方式。

### 1.3.3 为什么 Decoder-Only 很适合 LLM

现代通用 LLM 大多采用 Decoder-Only 架构，原因包括：

- 训练目标天然统一：下一 token 预测
- 更适合统一对话、写作、代码、问答等生成任务
- 更容易规模化扩展

也就是说：

- 原始 Transformer：更像一个完整的 Encoder-Decoder 框架
- 现代通用 LLM：通常只保留 Decoder 这一侧，并在其上扩展规模
- BERT 这类理解模型：更接近 Encoder-Only

因此，今天大家说“Transformer 是 LLM 的基础”，更准确的意思是：**LLM 大多建立在 Transformer 的变体之上，而不是照搬最早那张完整结构图。**

## 1.4 Self-Attention

Self-Attention 是 Transformer 的核心。它要解决的问题是：

**当前 Token 在更新自己表示时，应该重点参考上下文中的哪些 Token。**

例如在句子：

```text
苹果发布了新手机，它的芯片性能更强
```

模型在处理“它”时，应该更关注“苹果”或“新手机”，而不是平均看待所有词。

这就是注意力机制的意义：对上下文做有重点的加权读取。

## 1.5 Q、K、V 怎么理解

可以把 Q、K、V 理解成一次内部检索：

- `Q`：我现在想找什么信息
- `K`：我这里能提供什么信息
- `V`：如果你关注我，我真正提供给你的内容是什么

粗略过程可以理解为：

1. 当前 token 产生自己的 `Q`
2. 序列中所有 token 都提供 `K` 和 `V`
3. 用 `Q` 和所有 `K` 算相似度
4. 得到注意力权重
5. 对所有 `V` 做加权求和
6. 得到当前 token 更新后的表示

## 1.6 Multi-Head Attention

Transformer 不只用一个注意力头，而是会同时使用多个头并行关注不同模式。

这样做的原因是：

- 一个头往往只能学到一种关系
- 多个头可以从不同角度同时看上下文

例如：

- 某些头更关注语法依赖
- 某些头更关注指代关系
- 某些头更关注远距离信息

这也是 Transformer 表达能力强的重要原因之一。

## 1.7 Transformer 的关键组件

先区分两个层面：

- 模型输入侧组件：Token Embedding、Position 信息
- 单个 Transformer 层内部组件：Attention、Feed Forward、Residual、LayerNorm

也就是说，Embedding 和位置编码通常发生在输入阶段；而“堆很多层”的，是后面的 Transformer block。

一个标准 Transformer 层通常包括：

- Multi-Head Attention：有重点地读取上下文
- Feed Forward Network：做非线性特征变换
- Residual Connection：保留原始信息，避免深层退化
- LayerNorm：让训练更稳定

可以把它理解成：每一层都让 Token “重新看一遍上下文”，然后把自己的表示更新得更准确。

## 1.8 隐藏表示如何变成输出

Self-Attention 和 Transformer 层处理出来的，首先不是最终答案，而是一串更丰富的**隐藏表示（hidden states）**。

在生成任务里，后面通常还会接：

1. 线性映射：把隐藏表示投影到词表大小
2. softmax：得到“下一个 token 的概率分布”
3. 采样或贪心选择：真正选出要输出的 token

所以可以把链路理解成：

`token -> embedding -> transformer layers -> hidden states -> vocab logits -> 概率分布 -> 输出 token`

这也说明：

- Attention 更新的是表示，不是直接“选词”
- 真正变成输出 token，还要经过输出层和采样步骤

## 1.9 Transformer 解决了什么问题

相比早期的 RNN / LSTM，Transformer 的优势主要在于：

- 不必严格按时间步串行处理
- 更适合 GPU 并行训练
- 更容易建模长距离依赖
- 更容易扩展到超大模型规模

现代大语言模型、视觉 Transformer、多模态模型，很多都建立在 Transformer 或其变体之上。
