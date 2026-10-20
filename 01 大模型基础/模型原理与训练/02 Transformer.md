# Transformer

Transformer 是现代大语言模型最核心的底层架构之一。它由 Google 团队在 2017 年的论文 [Attention Is All You Need](https://arxiv.org/abs/1706.03762) 中提出。Transformer解决的是：**模型内部到底用什么结构完成这些计算。**

## Transformer 的核心思想

Transformer 的核心思想是：

**通过注意力机制直接计算序列中不同位置的信息关系，并支持并行计算多个位置的表示。**

这种并行性主要体现在训练和处理完整输入时；自回归模型生成时仍按 Token 逐步输出。

这带来三个关键收益：

- 更容易并行训练
- 更擅长建模长距离依赖
- 更容易扩展到超大参数规模

## Transformer 结构图

![](https://www.runoob.com/wp-content/uploads/2025/06/Transformer_full_architecture.png)

上图展示的是 **2017 原始论文中的经典 Encoder-Decoder Transformer**。从这个经典结构看，Transformer 主要包含：

1. 输入处理：把 token 转成向量，并加入位置信息
2. 编码器（Encoder）
3. 解码器（Decoder）
4. 输出层：把内部表示映射回词表概率

但要注意：**“Transformer”是一个架构家族，不等于必须同时有 Encoder 和 Decoder。**

## 编码器与解码器

### 编码器

编码器的作用是：对输入序列做上下文化理解。

常见组成包括：

- Multi-Head Self-Attention
- Feed-Forward Network
- Residual Connection
- LayerNorm

编码器适合理解任务，因此很多理解型模型会偏向 Encoder-Only 结构。

### 解码器

解码器的作用是：根据已有上下文一步步生成后续内容。

它和编码器的重要差异在于：

- 解码器会使用因果掩码（causal mask）
- 当前 token 只能看到自己之前的内容，不能看到未来

这保证了生成过程符合“从前到后逐步生成”的方式。

### 为什么 Decoder-Only 很适合 LLM

现代通用 LLM 大多采用 Decoder-Only 架构，原因包括：

- 训练目标天然统一：下一 token 预测
- 更适合统一对话、写作、代码、问答等生成任务
- 更容易规模化扩展

也就是说：

- 原始 Transformer：更像一个完整的 Encoder-Decoder 框架
- 现代通用 LLM：通常只保留 Decoder 这一侧，并在其上扩展规模
- BERT 这类理解模型：更接近 Encoder-Only

因此，今天大家说“Transformer 是 LLM 的基础”，更准确的意思是：**LLM 大多建立在 Transformer 的变体之上，而不是照搬最早那张完整结构图。**

## Self-Attention

Self-Attention 是 Transformer 的核心。它要解决的问题是：

**当前 Token 在更新自己表示时，应该重点参考上下文中的哪些 Token。**

例如在句子：

```text
苹果发布了新手机，它的芯片性能更强
```

模型在处理“它”时，应该更关注“苹果”或“新手机”，而不是平均看待所有词。

这就是注意力机制的意义：对上下文做有重点的加权读取。

### 相似度为什么要缩放

`Q` 与 `K` 的点积数值尺度会随向量维度 `d_k` 增大。除以 `√d_k` 可以稳定 softmax 的输入范围，减少权重过度集中和梯度变小的问题。

因此标准做法是先按维度缩放，再送入 softmax：

```text
Attention(Q, K, V) = softmax(QK^T / √d_k) · V
```

这个公式同时指出了注意力开销的来源：`QK^T` 需要算出序列中每一对位置之间的相似度，计算量随长度平方增长。

## Q、K、V 怎么理解

可以把 Q、K、V 理解成一次内部检索：

- `Q`：我现在想找什么信息
- `K`：我这里能提供什么信息
- `V`：如果你关注我，我真正提供给你的内容是什么

粗略过程可以理解为：

1. 当前 token 产生自己的 `Q`
2. 序列中所有 token 都提供 `K` 和 `V`
3. 用 `Q` 和所有 `K` 算点积相似度，并按 `√d_k` 缩放
4. Decoder 中先用因果掩码屏蔽未来位置，再做 softmax，得到注意力权重
5. 对所有 `V` 做加权求和
6. 得到当前 token 更新后的表示

对每个查询而言，softmax 会在未被掩码的位置上把权重归一化为 1，因此可以把注意力理解为有限权重在可见位置间的分配。不过，增加上下文长度不会必然降低某个特定 Token 的权重；权重取决于各位置的点积和掩码。长上下文的信息利用还与模型训练分布、位置处理、信息所在位置和提示设计等因素有关。

## Multi-Head Attention

Transformer 不只用一个注意力头，而是会同时使用多个头并行关注不同模式。

这样做的原因是：

- 各头通过独立的投影矩阵并行处理不同的表示子空间。
- 多个头的结果可以组合不同的关联信息。

各头算出的结果会先拼接，再经过一次输出投影（`W_O`）融合成本层的最终输出。没有 `W_O` 时，当前注意力层只会并列拼接各头表示，无法在该层通过线性投影混合不同头的通道；后续层仍可继续处理这些特征。

训练后，有些头可能对某些模式更敏感，但每个头与某种语义功能之间没有固定的一一对应关系，也可能存在冗余。例如：

- 某些头对语法依赖更敏感
- 某些头对指代关系更敏感
- 某些头对远距离信息更敏感

这也是 Transformer 表达能力强的重要原因之一。

## Transformer 的关键组件

可以按三个位置来区分：

- 输入侧：Token Embedding，把 Token ID 查表成向量
- 位置信息：可加到 Token 表示中，也可在注意力计算中注入
- 层内部：Attention 与 Feed Forward 两个子层，以及包裹在每个子层外的残差连接和归一化

Token Embedding 通常在输入侧查表得到；位置机制的作用位置取决于具体方案。绝对位置编码常加到 Token 表示中，RoPE 则在注意力计算中作用于 Q/K。“堆很多层”的是后面的 Transformer block。

一个标准 Transformer 层由两个子层堆成，每个子层都被残差连接和归一化包裹：

- Multi-Head Attention：有重点地读取上下文，负责在位置之间搬运信息
- Feed Forward Network：对每个位置独立做非线性变换，负责就地加工信息
- Residual Connection：把子层输入直接加回输出，保留原始信息，避免深层退化
- 归一化（LayerNorm / RMSNorm）：稳定数值分布，让深层网络可训练

可以把它理解成：每一层都让 Token “重新看一遍上下文”，然后把自己的表示更新得更准确。

### 残差流视角

把各层的残差连接串起来看，可以把整个模型理解为一条贯穿所有层的**残差流**：每层的注意力和 FFN 都从这条流上读取信息，再把计算结果加回去。

这个视角能解释两件事：

- 残差连接提供直接传递子层输入的路径，子层可以在已有表示上叠加更新
- 信息因此有机会跨层传播，但并不保证某个特征一定保留；后续层仍可能改变或削弱它

### 归一化放在哪里：Pre-LN 与 Post-LN

2017 年原论文把归一化放在子层输出之后（Post-LN）。许多现代 Decoder-only LLM 把归一化放在子层输入之前（Pre-LN），并使用 RMSNorm；具体结构仍随模型而异。

差别在于：

- Post-LN 在深层网络中可能更难稳定训练，训练时常需配合预热等策略
- Pre-LN 在子层前归一化，为残差流保留近似恒等的直通路径，有助于深层网络的梯度传播
- RMSNorm 去掉 LayerNorm 的均值中心化，只做尺度归一；它在许多模型中效果良好，但不代表对所有配置都等价

### Feed Forward 层承担什么

FFN 常被一句话带过成“非线性变换”，但它的分量远比这大：

- 参数占比高：在常见 Dense Transformer 配置中，FFN 约占单层参数量的三分之二；实际比例取决于注意力和 FFN 的维度设计
- 计算逐位置独立：每个 Token 各自经过同一组权重，不涉及跨位置交互
- 一种研究视角把 FFN 描述为键值记忆，以“模式匹配 → 写出对应内容”解释它如何存储和调用部分关联

键值记忆是解释 FFN 的一种研究视角，不代表事实知识只存储在 FFN。提示词可以通过上下文提供新事实；微调能改变参数及模型行为，但不保证模型准确记住事实。需要持续更新或引用来源的知识通常更适合结合 RAG。相关讨论见 [01 LLM基本概念](01%20LLM%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md) 中的幻觉与知识截止部分。

## 参数量都花在哪

把参数拆开看，有助于理解模型规模、词表和显存之间的关系：

| 部分 | 规模量级 | 说明 |
| --- | --- | --- |
| 输入 Embedding | 词表大小 × 隐藏维度 | 词表越大占用越多；中文和多语言模型的词表通常更大 |
| N 个 Transformer 层 | 每层约 12 × 隐藏维度的平方 | 注意力约占 4 倍、FFN 约占 8 倍；层数和隐藏维度是主要放大项 |
| 输出投影 | 隐藏维度 × 词表大小 | 部分模型与输入 Embedding 共享权重（weight tying），部分不共享 |

由此可以得到几个结论：

- 参数量主要由层数、隐藏维度和词表大小决定，与上下文长度无关。
- 上下文长度影响的是运行时的激活值和 KV Cache 显存，不是权重体积。
- 因此“同一个模型支持更长上下文”通常不需要更多权重显存，却需要更多运行时显存。

MoE 模型把 FFN 换成多组专家并按 Token 路由，参数总量的算法随之改变，见 [03 模型架构谱系](03%20%E6%A8%A1%E5%9E%8B%E6%9E%B6%E6%9E%84%E8%B0%B1%E7%B3%BB.md)。

## 隐藏表示如何变成输出

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

## 计算代价与 KV Cache

前面讲的是“模型怎么算”，这一节讲“算这些要付多少代价”。工程上关于长度的大多数取舍，根源都在这里。

### 注意力是平方复杂度

序列长度为 `n`、隐藏维度为 `d` 时，标准全注意力的主要计算量约为 `O(n²d)`，逐 Token 的 FFN 计算量随 `n` 线性增长：

- 显式构造完整注意力分数矩阵的实现，需要 `O(n²)` 的额外矩阵空间；FlashAttention 等内核可避免物化该矩阵，但不会消除全注意力的平方计算量

因此，常见模型的短序列计算可能主要花在 FFN 和投影上；序列变长后，注意力的平方项会快速增加。实际瓶颈还取决于模型维度、注意力内核和硬件。

### Prefill 与 Decode 是两个阶段

自回归生成的一次请求分成两个特性完全不同的阶段：

| 阶段 | 做什么 | 计算特性 |
| --- | --- | --- |
| Prefill | 并行处理输入 Token，计算各层的 K、V，并由最终 logits 选出首个生成 Token | 可并行，通常计算密集 |
| Decode | 每步处理一个新 Token，并复用此前缓存的 K、V 来生成后续 Token | 自回归串行，常受访存影响 |

这解释了为什么服务端会分别观察首 Token 延迟（TTFT）和每 Token 延迟（TPOT）：模型计算阶段不同，但端到端延迟也受排队、网络和服务调度影响。详见 [04 推理性能指标与Benchmark](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/%E6%8E%A8%E7%90%86%E5%B7%A5%E7%A8%8B/04%20%E6%8E%A8%E7%90%86%E6%80%A7%E8%83%BD%E6%8C%87%E6%A0%87%E4%B8%8EBenchmark.md)。

### KV Cache 从哪来

Decode 阶段每生成一个 Token，都要用新的 `Q` 和**此前可见位置**的 `K`、`V` 做注意力。如果每步都重算历史位置的 `K`、`V`，计算量会随长度反复膨胀。

因此推理引擎会把已算出的 `K`、`V` 缓存下来，这就是 KV Cache。其存储量大致随层数、Token 数、KV 头数、头维度、每个值的字节数和活动序列数线性增长；前缀共享等机制可以复用部分缓存。长上下文或高并发时，KV Cache 会占用显著显存，但是否超过模型权重取决于模型、并行方式和缓存精度。

Decode 每步都要读取相关 KV Cache，因此许多服务负载会受到显存带宽影响；实际瓶颈会随批量大小、硬件和内核变化。

围绕这个瓶颈的优化，正是后文《常见组件与工程实现》里 MQA、GQA、MLA 的出发点：减少需要缓存的 KV 头数，或压缩 KV 表示。分页管理、量化和前缀复用见 [02 KV Cache与PagedAttention](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/%E6%8E%A8%E7%90%86%E5%B7%A5%E7%A8%8B/02%20KV%20Cache%E4%B8%8EPagedAttention.md)，调度与批处理见 [03 Continuous Batching与调度](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/%E6%8E%A8%E7%90%86%E5%B7%A5%E7%A8%8B/03%20Continuous%20Batching%E4%B8%8E%E8%B0%83%E5%BA%A6.md)。

## 位置信息与上下文长度

注意力本身不区分顺序：打乱输入 Token，算出的注意力关系不会变。位置信息必须额外注入，否则模型无法理解语序。

### 位置编码的演进

| 方案 | 做法 | 特点 |
| --- | --- | --- |
| 正弦绝对位置编码 | 用不同频率的三角函数生成位置向量，加到 Token 表示上 | 原论文方案，无参数；外推到训练长度之外效果有限 |
| 可学习绝对位置编码 | 每个位置对应一个可训练向量 | 早期 BERT、GPT 采用；位置数固定，超出即无法处理 |
| 相对位置编码 | 直接建模两个位置之间的距离 | 对长度变化更鲁棒 |
| RoPE | 在注意力计算中对 Q、K 做与位置相关的旋转 | 当前主流；相对位置关系自然体现在点积结果里 |
| ALiBi | 按位置距离给注意力分数加线性惩罚 | 不改动权重，倾向于关注近距离内容 |

### 上下文长度上限从哪来

模型能处理多长的上下文，不由单一因素决定：

- 位置编码的表示范围，以及是否做过长度外推训练（位置插值、NTK 缩放、YaRN 等）
- 训练语料里长序列的覆盖程度
- 运行时的 KV Cache 显存和注意力计算开销
- 在目标长度上的实际检索与推理表现

前两条决定模型“能不能”，第三条决定服务“划不划算”，最后一条决定“好不好用”。这也是标称上下文长度不等于长文任务质量的原因，见 [01 LLM基本概念](01%20LLM%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md)。

## Transformer 解决了什么问题

和它取代的 RNN / LSTM 相比，关键差别在信息传递方式：

| 维度 | RNN / LSTM | Transformer |
| --- | --- | --- |
| 处理方式 | 按时间步串行，逐步更新隐状态 | 一次算出所有位置之间的关系 |
| 长距离依赖 | 信息需经多步传递，容易衰减 | 任意两个位置直接相连，路径长度为 1 |
| 并行度 | 受时间步限制，难以充分利用 GPU | 训练时可整序列并行 |
| 扩展性 | 加深加宽收益有限 | 参数、数据、计算同步扩展时收益明显 |

代价是失去了 RNN 那种固定大小的隐状态：Transformer 必须显式保存全部历史，这正是 KV Cache 的来源。

现代大语言模型、视觉 Transformer 和多模态模型，大多建立在 Transformer 或其变体之上。

## Transformer 的局限

优势的另一面就是约束，这些约束直接决定了推理系统的形态：

- **平方复杂度**：标准全注意力的计算开销随长度平方增长；超长序列的成本还取决于注意力内核和硬件。
- **状态随长度增长**：KV Cache 让显存占用与序列长度、并发数成正比，限制单卡能服务的请求数。
- **位置外推有限**：超出训练长度的位置区间后质量往往明显下降，需要专门的外推方法和长文评测验证。
- **Decode 阶段常受访存影响**：每步只生成一个 Token，KV Cache 读取可能成为瓶颈；具体表现取决于批量、硬件和实现。

这些局限催生了两类应对：一是在 Transformer 内部继续优化（GQA、MLA、FlashAttention、稀疏注意力、连续批处理），二是换用或混合其他序列建模骨干（SSM、循环式架构）。前者见 [推理与部署](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/README.md)，后者见 [03 模型架构谱系](03%20%E6%A8%A1%E5%9E%8B%E6%9E%B6%E6%9E%84%E8%B0%B1%E7%B3%BB.md)。

## 常见扩展方向

Transformer 并不是停留在 2017 年原始结构不变的。后续很多能力增强，都是在这个家族上继续扩展出来的。

常见方向包括：

- **稀疏注意力 / 局部注意力**：减少长序列计算量，具体效果取决于稀疏模式、训练方式和任务。
- **RoPE 等位置编码**：为序列位置提供信息；扩展上下文长度还需要相应训练和长文本评测。
- **MoE（混合专家）**：由路由器为不同 Token 选择部分专家，增加模型总容量时控制每 Token 计算；权重存储、通信和负载均衡仍有成本。
- **多模态融合**：把文本、图像、语音或视频转换成模型可处理的表示，再通过编码器、投影层、跨注意力或统一序列融合。

这些方向分别涉及序列计算、位置信息、参数路由和输入模态，不能简单看成同一类“Transformer 改进”。

### 常见组件与工程实现

- **MHA、MQA、GQA**：它们都属于注意力头组织方式。MQA 和 GQA 使用较少的 Key/Value 头，常用于降低自回归生成时 KV Cache 的容量和带宽需求。
- **MLA（Multi-head Latent Attention）**：将 Key/Value 信息压缩到低维潜在表示，以减少自回归推理时的 KV Cache 占用。DeepSeek-V2 的[技术报告](https://arxiv.org/abs/2405.04434)给出了代表性实现。MLA 与 MQA/GQA 都能降低缓存负担，具体机制不同。
- **RMSNorm、LayerNorm、SwiGLU**：属于 Transformer Block 中的归一化或前馈网络设计，影响训练稳定性和计算表现。
- **FlashAttention**：通过优化显存读写和计算调度实现精确注意力的高效计算，属于算法/内核实现，不是新的模型家族。
- **长上下文扩展**：除位置编码外，还取决于训练数据中长序列的覆盖、注意力实现、显存与吞吐，以及模型在长距离信息检索任务上的表现。

GQA、MLA、KV Cache 与注意力内核的服务端实现见 [推理与部署](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/README.md)。不同模型的架构组合见 [03 模型架构谱系](03%20%E6%A8%A1%E5%9E%8B%E6%9E%B6%E6%9E%84%E8%B0%B1%E7%B3%BB.md)。

如果需要从经典 NLP 任务（分类、NER、相似度、Seq2Seq）的视角入门注意力和 Transformer，见 [01 NLP简介](../../02%20%E6%A3%80%E7%B4%A2%E4%B8%8ERAG/NLP%E4%B8%8EQuery/01%20NLP%E7%AE%80%E4%BB%8B.md)；本文侧重面向 LLM 工程的结构与代价分析。

## 一句话总结

如果说：

- Token 解决“文本如何切成模型可处理的单位”
- 向量化解决“离散符号如何变成可计算对象”

那么：

- Attention 解决“当前 token 该重点参考谁”
- FFN 解决“每个位置的信息如何被加工和存储”
- Transformer 解决“如何把这些计算组织成可堆叠、可并行的深层网络”

工程侧还要记住：**注意力的平方计算量和随上下文增长的 KV Cache，是长上下文成本与延迟的重要来源；FFN、权重读取、通信和调度也会影响总开销。**

## 参考资料

- [Attention Is All You Need](https://arxiv.org/abs/1706.03762)：Transformer 原始论文。
- [RoFormer: Enhanced Transformer with Rotary Position Embedding](https://arxiv.org/abs/2104.09864)：RoPE 位置编码。
- [Train Short, Test Long: Attention with Linear Biases Enables Input Length Extrapolation](https://arxiv.org/abs/2108.12409)：ALiBi。
- [YaRN: Efficient Context Window Extension of Large Language Models](https://arxiv.org/abs/2309.00071)：长上下文外推方法。
- [Fast Transformer Decoding: One Write-Head is All You Need](https://arxiv.org/abs/1911.02150)：MQA。
- [GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints](https://arxiv.org/abs/2305.13245)：GQA。
- [DeepSeek-V2 Technical Report](https://arxiv.org/abs/2405.04434)：MLA 的代表性实现。
- [FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness](https://arxiv.org/abs/2205.14135)：IO 感知的精确注意力内核。
- [Root Mean Square Layer Normalization](https://arxiv.org/abs/1910.07467)：RMSNorm。
- [GLU Variants Improve Transformer](https://arxiv.org/abs/2002.05202)：SwiGLU 等前馈结构设计。
- [Transformer Feed-Forward Layers Are Key-Value Memories](https://arxiv.org/abs/2012.14913)：FFN 的知识存储视角。
- [A Mathematical Framework for Transformer Circuits](https://transformer-circuits.pub/2021/framework/index.html)：残差流与注意力头的分析框架。
