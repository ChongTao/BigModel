# RAG分块策略

## 1 固定大小分块

按照固定字符数或 token 数切分文本，例如 `chunk_size=300`。

![](https://substackcdn.com/image/fetch/$s_!RG5y!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F98c422a0-f0e2-457c-a256-4476a56a601f_943x232.png)

- 优点：实现简单、处理快、适合结构弱的文本。
- 缺点：容易切断语义边界，导致上下文丢失。
- 适用：FAQ、短文档、格式不稳定的原始文本。

## 2 基于句子的分块

先做句子切分，再把一个或多个句子组合成 chunk。

- 优点：语义边界通常比固定长度更自然。
- 缺点：句子长度不均匀；中英文混排、表格、代码等内容切分效果不稳定。
- 适用：新闻、说明文、结构较清晰的自然语言文本。

## 3 递归字符分块

递归字符分块是 LangChain 中常见的实现方式。其核心思想是：优先按段落、句子等高层级分隔符切分，仍然过长时再递归使用更细粒度的分隔符。

![](https://substackcdn.com/image/fetch/$s_!WRuN!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ff4009caa-34fc-48d6-8102-3d0f6f2c1386_1066x316.gif)

- 优点：兼顾实现成本与语义完整性，通用性强。
- 缺点：效果依赖分隔符优先级和参数设置。
- 适用：大多数通用 RAG 系统的默认策略。

## 4 基于文档结构的分块

按照标题、章节、列表、表格、代码块等结构边界切分文档。

![](https://substackcdn.com/image/fetch/$s_!NtgT!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fe8febecd-ee68-42ff-ab06-41a0a3a43cd3_1102x306.gif)

- 优点：更符合原始文档的逻辑层次，利于保留上下文。
- 缺点：依赖格式解析能力，预处理复杂。
- 适用：Markdown、HTML、PDF 转结构化文本后的文档。

## 5 混合分块

先按文档结构粗切，再对大块内容用递归字符或句子级方式细切。

- 优点：同时兼顾结构信息和块大小控制。
- 缺点：策略设计复杂，参数更多。
- 适用：企业知识库、产品文档、手册类场景。

## 6 语义分块

根据句向量相似度、主题变化或语义边界进行切分，使每个 chunk 尽量表示一个完整语义单元。

![](https://substackcdn.com/image/fetch/$s_!tmOD!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa6ad83a6-2879-4c77-9e49-393f16577aef_1066x288.gif)

- 优点：chunk 内部语义聚合度高。
- 缺点：计算成本高，效果依赖模型质量。
- 适用：高精度问答、复杂专业文档。

## 7 分层分块

同时构建大块、中块、小块多个层级，并在不同层级上建立索引。

- 优点：可以在不同粒度上灵活检索和补充上下文。
- 缺点：索引和存储成本上升，实现更复杂。
- 适用：书籍、论文、长篇报告等层次清晰的长文档。

## 8 Parent Document / Small-to-Big

先用小块提高召回精度，再映射回父文档或更大块内容供生成阶段使用。

- 优点：兼顾“小块易召回”和“大块上下文完整”。
- 缺点：需要维护子块和父块映射关系。
- 适用：长文档问答、手册检索、章节级阅读理解。

## 9 命题分块

命题分块（Propositional Chunking）把文本切分为“完整事实”或“独立陈述”，例如一个主谓宾结构的事实单元。

- 优点：适合精确事实检索和知识抽取。
- 缺点：高度依赖 LLM 或 NLP 抽取质量。
- 适用：知识图谱构建、事实问答、结构化知识沉淀。

## 10 Agentic / LLM-based Chunking

使用大模型根据文档内容动态判断切分边界，而不是固定依赖长度或规则。

![](https://substackcdn.com/image/fetch/$s_!jVmL!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F4d1b6d60-8956-4030-8525-d899ee61a9d5_1140x198.gif)

- 优点：理论上最贴近语义和任务目标。
- 缺点：成本高、稳定性和可重复性较差，实现复杂。
- 适用：高价值、低吞吐的精细化知识处理流程。

> Chunking 没有绝对最优解。设计重点通常不是“块越大越好”或“越小越好”，而是要和检索方式、问题类型、上下文长度、重排能力一起设计。