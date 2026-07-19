# 一 LangMem 介绍

[LangMem](https://github.com/langchain-ai/langmem) 是 LangChain 团队开源的 **memory toolkit / memory primitives**，目标是给 Agent 提供一套更轻量、可组合的长期记忆能力。

如果从 Agent Memory 的视角看，LangMem 更像：

- **memory primitives**
- **memory tools + background manager**
- **围绕 LangGraph store 的长期记忆工具层**

它不是一个完整托管平台，也不是独立的 memory runtime。  
它更强调：**给现有 agent 加上“记”和“查”的能力**。

## 1.1 核心价值

LangMem 的核心价值在于：**把长期记忆拆成一组可组合工具，而不是要求你接入一整套固定系统**。

这类设计主要解决几个问题：

1. **很多 Agent 只缺记忆原语**
   并不一定需要一个完整 memory service。
2. **需要和现有 Agent 框架集成**
   尤其是在 LangGraph / LangChain 生态里。
3. **需要热路径和后台路径结合**
   有些记忆需要在当前对话里即时处理，有些适合后台慢慢整理。

## 1.2 主要特点

- **核心 memory API**：可接任意存储系统
- **memory tools**：支持 agent 在 hot path 中主动记录和搜索记忆
- **background manager**：后台自动抽取、整合和更新知识
- **原生集成 LangGraph store**：可直接使用 LangGraph 的长期存储
- **支持自定义 store**：不强绑单一数据库

# 二 核心机制

## 2.1 两条路径：Hot Path 与 Background

LangMem 一个很值得补充的点，是它把记忆处理拆成了两条路径：

1. **Hot Path**
   当前 Agent 在对话进行中，直接调用 memory tools 读写记忆。
2. **Background Path**
   后台 memory manager 异步抽取、整合、更新更稳定的长期知识。

这意味着 LangMem 不是只支持“边聊边记”，也支持“聊完之后再慢慢整理”。

## 2.2 Memory Tools

LangMem 提供的核心能力之一，是让 Agent 可以显式使用工具来管理记忆，例如：

- `create_manage_memory_tool`
- `create_search_memory_tool`

这类设计的意义在于：

- Agent 可以自主判断何时写记忆
- Agent 可以自主判断何时搜索旧记忆
- 记忆能力可以像普通工具一样挂到现有 Agent 上

## 2.3 存储模型

LangMem 自身不是数据库。  
它更像“记忆逻辑层”，而底层持久化通常依赖：

- LangGraph store
- 自定义 BaseStore
- 进程内存存储（开发环境）
- 数据库后端（生产环境）

官方 README 明确提到：

- `InMemoryStore` 适合开发测试
- 生产环境建议使用 DB-backed store，例如 `AsyncPostgresStore`

所以 LangMem 的重点不是“发明新存储”，而是**给存储之上加一层 memory workflow**。

## 2.4 记忆类型

从文档结构也能看出，LangMem 不只讲一个 memory 类型，而是覆盖了几类常见模式：

- episodic memories
- semantic memories
- user profile 管理
- summarization
- compound system optimization

所以它更像一个**memory patterns 库**，而不是单一记忆产品。

# 三 适合场景

## 3.1 已经在用 LangGraph / LangChain

这是 LangMem 最自然的场景。  
如果系统已经在 LangGraph 上构建，LangMem 会比单独引入一个外部 memory 平台更顺。

## 3.2 需要轻量加记忆能力

如果你不想接入一个完整 memory backend，而只是想让 agent：

- 能记住用户偏好
- 能搜索过去交互
- 能在后台整理长期知识

那么 LangMem 很合适。

## 3.3 想自己控制存储层

如果你更希望自己选数据库、自己定义 namespace、自己治理 memory schema，LangMem 的自由度也比较高。

# 四 与其他记忆方案的关系

LangMem 的横向定位可以概括为：

- 它不是完整 memory platform
- 它更偏“memory toolkit / primitives”
- 它强调和 LangGraph store 的原生集成

如果要看它和 Memobase、Mem0、MemGPT、Graphiti、Neo4j Agent Memory 的系统对比，统一放在：[10 记忆方案对比.md](./10%20记忆方案对比.md)

# 五 局限与注意点

## 5.1 更像工具箱，不是完整平台

LangMem 的优点是灵活，但代价是很多工程决策仍然要你自己做。

## 5.2 对 LangGraph 生态更友好

虽然它并不绝对绑定 LangGraph，但最自然的使用方式还是在 LangGraph / LangChain 生态里。

## 5.3 需要自己设计治理策略

LangMem 给了你原语和工具，但“哪些记忆该保留、如何更新、如何隔离多租户”这类治理问题，仍然要自己设计。

# 六 总结

可以把 LangMem 理解为：

> 一套给 Agent 增加长期记忆能力的轻量工具箱，而不是一个重型记忆平台。

它最重要的价值不在“统一托管所有 memory”，而在于：

- 让记忆能力可以像工具一样接入 agent
- 把 hot path 和记忆后台整理拆开
- 让 LangGraph / 自定义 store 更容易获得长期记忆能力
