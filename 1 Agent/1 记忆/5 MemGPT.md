# 一 MemGPT 介绍

MemGPT（Memory-GPT）是一类面向大语言模型上下文扩展与记忆管理的系统。  
它最核心的思路是：**把 LLM 当作“操作系统（OS）”中的控制核心来使用，让模型自己管理哪些信息应该留在主上下文中，哪些信息应该放到外部记忆中。**

## 1.1 当前项目形态

从今天的官方生态看，MemGPT 更适合理解为一种**记忆运行时思想**，而当前持续演化的产品主线已经是 **Letta**。

可以粗略理解为：

- **MemGPT**：最初的研究视角和项目名，强调 memory hierarchy 与内外存调度
- **Letta V1 SDK（legacy）**：把 MemGPT 思路做成可编程的 stateful agent 形态
- **Letta Agent SDK / Letta Agent**：当前更推荐的新形态，进一步加入了 MemFS、dreaming、subagents、skills 等能力

所以今天再讲 MemGPT，最好区分：

- **思想层**：MemGPT = memory-aware runtime
- **产品层**：当前主线生态 = Letta

如果从 Agent Memory 的视角看，MemGPT / Letta 这一脉最突出的特点不是“用户画像”或“通用记忆 CRUD”，而是：

- **上下文窗口管理**
- **内外存切换**
- **memory hierarchy**
- **runtime 驱动的记忆调度**

## 1.2 MemGPT 在 Agent 架构中的定位

如果说：

- **Memobase** 更偏“用户长期档案”
- **Mem0** 更偏“通用记忆管理层”

那么 **MemGPT** 更偏：

- **LLM memory runtime**
- **上下文调度系统**
- **让模型在有限上下文下持续工作的机制**

它重点解决的问题是：

> 当模型上下文窗口有限，但任务本身又很长、信息很多时，系统如何决定“什么应该放进当前上下文，什么应该暂时放到外部存储”。

这个定位和你在 Agent 概述里写的 `LLM + Harness` 很接近。  
MemGPT 不是单纯的 memory store，而更像是 memory-aware runtime。

# 二 核心机制与架构

## 2.1 记忆层级（Memory Hierarchy）

MemGPT 的核心设计是记忆分层，类似操作系统中的内存层级。

在早期 MemGPT / Letta V1 的表述里，最经典的是：

- **主上下文（main context）**：类似 RAM，当前 prompt 中可直接访问的内容
- **外部存储 / 归档记忆（archival memory / external storage）**：类似磁盘，存放暂时不在当前上下文中的内容
- **可召回记忆（recall memory）**：可按需要检索并重新载入到当前上下文中的记忆

这意味着，系统不会试图把所有内容都一直留在主上下文里，而是动态调度。

而在当前 Letta 文档里，这套结构又被写得更工程化一些：

- **Memory blocks / core memory**：始终在上下文中的持久块
- **Archival memory**：语义可搜索、按需查询的长期外部记忆
- **Messages / reasoning / tool history**：即使被压出窗口，状态依然持久保留

所以今天更准确的理解是：

- 早期 MemGPT 强调 `main context / recall / archival`
- 当前 Letta 更强调 `memory blocks + archival memory + persistent agent state`

![memGPT](https://miro.medium.com/v2/resize:fit:720/format:webp/0*V4z-l_8f3AHzh5a7.png)

## 2.1.1 Memory Blocks

这是当前 Letta 体系里最值得补充的点。

Memory blocks 是结构化、持久存在于上下文窗口里的 memory。  
它们通常带有：

- `label`
- `description`
- `value`
- `limit`

它们的特点是：

- **始终可见**：不需要检索，直接在 prompt 前部可用
- **可由 agent 自主读写**
- **可共享**：多个 agent 可以访问同一个 block
- **更像核心记忆**，而不是普通外部 RAG 结果

## 2.1.2 Archival Memory

Archival memory 更接近传统长期外部记忆：

- 可持续增长
- 可语义搜索
- 按需通过工具查询
- 默认不固定驻留在当前上下文窗口里

所以它和 memory blocks 的分工是：

- **memory blocks**：高价值、持续可见、上下文内
- **archival memory**：海量长期内容、按需召回、上下文外

## 2.2 内外存切换

MemGPT 的关键不是“有没有外部记忆”，而是“**什么时候把信息放进上下文，什么时候把信息移出上下文**”。

典型过程可以理解为：

1. 当前上下文承载当前最关键的信息
2. 当上下文快满或任务进入新阶段时，系统触发 memory pressure
3. 模型决定哪些内容保留在主上下文
4. 其余信息被摘要、迁出或写入外部记忆
5. 后续需要时，再通过检索把相关内容召回

这种模式更像“分页”或“内存换入换出”，而不是传统的一次性 prompt 拼接。

在当前 Letta 文档里，这种“换入换出”也不只发生在聊天历史上，还会作用于：

- memory blocks 的组织和裁剪
- archival memory 的查询时机
- 长对话中的消息 compaction
- 多会话并行时 agent 状态的持续维护

## 2.3 函数调用机制（Function Calls）

MemGPT 通常通过函数调用或工具调用机制来实现：

- 检索记忆
- 写入记忆
- 更新或删除记忆
- 将外部内容重新载入当前上下文

这意味着，LLM 不只是被动读取 prompt，而是能主动参与 memory management。

## 2.4 事件与控制流（Event + Interrupts）

MemGPT 设计里通常会有一类“系统事件”，例如：

- 用户输入到来
- 上下文过载
- 任务阶段切换
- 定时任务或外部触发

这些事件会驱动模型重新判断：

- 是否要检索旧记忆
- 是否要压缩当前上下文
- 是否要把某些信息写入长期存储

因此，MemGPT 更接近一个“**围绕事件运行的上下文调度系统**”。

## 2.5 为什么 MemGPT 的思路重要

很多记忆系统解决的是“怎么存”，而 MemGPT 解决的是：

> 在有限上下文窗口下，模型如何持续工作而不丢失长期任务能力。

所以它特别适合那些：

- 输入远超上下文窗口
- 任务持续时间很长
- 需要阶段性读取旧信息
- 不能把全部历史始终塞进 prompt

的场景。

## 2.6 Agent 与 Conversation 的区分

当前 Letta 体系里，一个很重要但本地文档还没写清的点是：

- **Agent**：持久主体，拥有名字、记忆、模型配置和长期状态
- **Conversation**：某个 agent 下的一条消息线程

也就是说，今天 Letta 不再只是“延续某个 session”，而是“**多个 conversation 挂在同一个持久 agent 上**”。

这个设计的意义是：

- 多个会话可以共享同一个长期记忆主体
- 记忆不再和单条 session 强绑定
- 更接近“数字员工 / 数字人格”而不是一次性聊天线程

# 三 工作流理解

可以把 MemGPT 的工作流简单理解为：

1. 用户输入任务
2. 当前主上下文装载最相关的信息
3. 模型开始推理与执行
4. 当上下文不足或需要历史信息时，触发外部检索
5. 检索结果被重新装入主上下文
6. 无关或过期信息被迁出、压缩或归档
7. 系统继续执行，直到任务结束

这个流程的核心不是“存下所有历史”，而是“让最重要的信息始终处于当前上下文附近”。

## 3.1 当前工程化落地：MemFS

如果是当前的 Letta Agent，而不是旧版 V1 SDK，那么 memory 的工程落地方式又更进一步：

- agent memory 进入 **MemFS**
- MemFS 是 **git-backed memory filesystem**
- memory blocks 会投影成可检查、可编辑、有版本历史的 markdown 文件

这说明 Letta 现在已经不只是“抽象上的 memory hierarchy”，而是给了一个更可操作的 memory filesystem 实现。

## 3.2 Dreaming / Sleep-time Compute

另一个值得补充的新能力是 **dreaming**。

Letta Agent 可以在对话之外启动 sleep-time subagents，回顾最近会话并把有价值的经验写回记忆。  
这让它不只是在交互时即时读写 memory，还开始具备“离线反思和整理记忆”的机制。

# 四 主要应用场景

## 4.1 大型文档分析

当待分析的文档远大于 LLM 上下文窗口时，MemGPT 可以通过分页检索和动态装载的方式逐步处理内容，而不是一次性把全部文档塞进 prompt。

适合场景例如：

- 法律材料
- 财报分析
- 长论文 / 长手册阅读
- 大型代码库分析

## 4.2 长任务 Agent

对于执行轮次很多、阶段很多的任务，MemGPT 有助于系统保留关键状态，同时避免上下文不断膨胀。

例如：

- 复杂调研任务
- 长链路代码修改
- 跨阶段自动化流程
- 多步骤问题排查

## 4.3 跨会话长期交互

在长期对话里，MemGPT 也可以支持用户偏好、历史交互、实体关系等内容的管理。  
不过它的核心优势仍然是“上下文调度”，而不是像 Memobase 那样专门围绕用户画像构建长期档案。

## 4.4 更像数字员工 / 长期运行 Agent

结合当前 Letta Agent 的形态，它还特别适合：

- 长期运行的 coding agent
- 持续演化的数字助理
- 多会话并行但共享长期人格/记忆的 agent
- 需要通过 memory blocks 协调行为的多 agent 场景

# 五 与其他记忆方案的关系

MemGPT 的横向定位可以概括为：

- 它不是简单的外部检索后端
- 它更偏“记忆感知的运行时”
- 它强调上下文窗口管理、内外存切换和 memory hierarchy

如果要看它和 Memobase、Mem0、通用 RAG 的系统对比，统一放在：[10 记忆方案对比.md](./10%20记忆方案对比.md)

# 六 局限与注意点

## 6.1 工程复杂度较高

MemGPT / Letta 这一路线的价值很高，但实现复杂度通常也更高，因为系统需要处理：

- 何时换入 / 换出
- 如何摘要和 compaction
- 如何避免丢失关键状态
- 如何协调主上下文、memory blocks 和 archival memory

## 6.2 对模型决策质量依赖强

如果模型本身不能稳定判断“什么重要、什么该迁出、什么该回填”，就容易出现：

- 关键状态被过早迁出
- 不重要内容长期占据上下文
- 检索和装载时机不合理

## 6.3 还要区分“旧版 V1”与“Letta Agent”

今天讨论 MemGPT 时，一个常见误区是把旧版 V1 SDK 和新 Letta Agent 混成一个东西。  
更准确地说：

- **V1 SDK**：更接近经典 MemGPT / Letta API 抽象
- **Letta Agent SDK / Letta Agent**：是新一代更高层的 harness

如果不区分这两层，就会把 “memory blocks / archival memory” 和 “MemFS / dreaming / subagents” 混成一套单一架构。

## 6.4 不一定适合简单产品

如果产品只是：

- FAQ
- 短对话助手
- 规则固定的 workflow

那么直接用 RAG、profile memory 或通用 memory layer 往往更简单，不一定需要 MemGPT 这类 runtime。

# 七 总结

可以把 MemGPT / Letta 这一路线理解为：

> 一套让 LLM 在有限上下文窗口下，像操作系统调度内存一样调度长期信息的 memory runtime。

它最重要的价值不在“多存一点记忆”，而在于：

- 让模型在长任务中持续工作
- 让重要信息优先留在当前上下文
- 把 memory hierarchy 落成可运行的 agent runtime
