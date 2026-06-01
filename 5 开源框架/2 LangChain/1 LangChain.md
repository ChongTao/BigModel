![](https://mmbiz.qpic.cn/mmbiz_png/QmaZGtn6624AfAOSdbrGsmb1EQquZeh3aDYhcAwwghwz6Hscw3hHsKZPFx4NRkmCgtuY0spYm05rwibKibEAffZg/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=1)

**业务架构层** - LangChain 能构建哪些 AI 应用？答案是：AI 对话系统、知识库问答、智能客服、代码助手等。关键是它降低了门槛——以前需要 AI 团队才能做的事，现在几十行代码就能实现。 

**应用架构层** - 核心组件包括 Models(模型抽象)、Chains(链式调用)、Agents(智能体)、Toolkits(工具集)。这一层的设计哲学是**可组合性**：你可以像搭乐高一样组合这些组件，而不是从零开始写代码。

 **数据架构层** - 包含 Memory(记忆管理)、Vector Stores(向量数据库)、Document Loaders(文档加载器)、Text Splitters(文本切割器)。重点是**数据的流转和转换**：原始文档如何变成 AI 能理解的向量？对话历史如何高效存储和检索？ 

**技术架构层** - 底层涉及 API Integration(多模型兼容)、Prompt Engineering(提示词工程)、Embeddings(向量化)、LLM Provider(模型提供商集成)。这一层解决的是**如何让不同技术栈无缝协作**。



### 核心设计：State、Node、Edge

从 LangGraph(LangChain 的进阶版)可以看出架构设计的精髓：

- State

  (状态) - 就像一个"货箱"，在各个处理节点间传递数据。它不是简单的变量，而是**结构化的数据容器**，清晰定义了"这一步需要什么数据，输出什么数据"。

- Node

  (节点) - 每个节点是一个独立的处理单元，比如"分类器"、"数学专家"、"编辑审核"。**节点的职责单一，边界清晰**，这样才能组合出复杂的流程而不失控。

- Edge

  (边) - 定义数据流向。普通边是固定路径，条件边可以根据状态动态决定下一步去哪里(就像交通路口的红绿灯)。





https://mp.weixin.qq.com/s/_ilk2MiKHGqwORP7eyzhDQ

https://www.langchain.com.cn/docs/introduction/