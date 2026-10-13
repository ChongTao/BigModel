# 一 Agent Runtime 概述

Agent Runtime 是 Agent 真正运行的地方。  
如果说：

- `LLM = CPU`
- `Prompt = 程序`
- `MCP / Tools = 外设接口`
- `Agent Runtime = 操作系统`

那么 Runtime 负责把模型、工具、记忆、状态和工作流组织成一个可持续执行的系统。

## 1.1 为什么需要 Agent Runtime

早期很多 Agent 更像下面这种单轮链路：

`User -> Prompt -> LLM -> Tool`

这种模式能完成简单问答或轻量工具调用，但很难支撑真实业务任务，因为它通常存在几个明显问题：

- 没有统一状态管理，任务执行到一半容易丢失上下文
- 失败后无法从中间步骤恢复，只能整段重跑
- 缺少暂停、继续、人工介入等运行控制能力
- Tool 调用分散，参数、权限和重试难以统一治理
- Memory、Prompt、Tool Output 往往各自为政
- 多 Agent 协作缺少统一调度和消息机制

例如一个企业级编码 Agent 需要连续完成：

1. 查询 Jira
2. 查询 GitLab
3. 修改代码
4. 提交 MR
5. 通知飞书

如果第 3 步失败，而系统没有状态管理和 checkpoint，那么整个 Agent 往往只能直接退出，之前的步骤也很难复用。

企业真正需要的不是“一次性跑完”，而是下面这种可控执行过程：

`Task -> Step1 -> Step2 -> Step3 -> 暂停 -> 人工修正 -> 继续 Step4 -> 完成`

这正是 Runtime 要解决的问题。

## 1.2 Runtime 是什么

Runtime 的本质是：

**负责运行 Agent 的执行引擎。**

它并不是单一组件，而是一整套围绕 Agent 执行过程建立的运行时系统，负责统一管理：

- LLM 调用
- Context 装配
- Memory 读写
- Tool 调度
- Workflow 编排
- Task 状态
- Checkpoint 与恢复
- 权限与审批
- 事件、日志与追踪

从工程角度看，Runtime 更像 Agent 的执行层和控制层。  
Agent 是否“能稳定做事”，很大程度上不是由模型本身决定，而是由 Runtime 决定。

## 1.3 Runtime 的核心组成

一个典型的 Agent Runtime 通常至少包含下面几个模块。

### 1.3.1 Execution Engine

Execution Engine 是 Runtime 的核心，负责驱动 Agent 持续执行。

最常见的模式是一个循环：

```python
while not done:
    think()
    act()
    observe()
```

这就是经典的 ReAct Loop。  
Execution Engine 负责把“思考、行动、观察、更新”串成一个可持续推进的任务闭环。

### 1.3.2 State Manager

State Manager 用来保存 Agent 当前的执行状态，例如：

- 当前步骤
- 重试次数
- 中间变量
- 已生成的工件
- 当前上下文窗口
- 是否等待人工审批

例如可以抽象成：

```text
State:
step=4
retry=2
branch=feature/login
mr=1234
status=waiting_review
```

没有状态管理，Agent 很难支撑长链路任务和中断恢复。

### 1.3.3 Context Manager

Context Manager 是现在 Runtime 最关键的模块之一。  
它负责把下面这些内容按需组装为模型当前回合真正可消费的上下文：

- System Prompt
- 用户目标与约束
- Conversation History
- Memory
- Search Result
- Code / Workspace
- Tool Output
- 用户偏好与项目规则

本质上它要解决的问题是：

**模型这一轮到底应该看到什么。**

上下文装配做得不好，Agent 很容易出现遗忘、跑偏、重复执行和无效调用。

### 1.3.4 Tool Runtime

Tool Runtime 负责工具的统一注册、描述、执行与治理。常见职责包括：

- Tool Schema 定义
- 参数校验
- 权限控制
- 执行与结果封装
- 超时与重试
- 错误分类
- 审批与审计

对 Runtime 来说，工具底层是：

- 本地函数
- Python / Shell
- REST API
- MCP Server
- SSH / Docker

这些实现细节都可以被统一抽象为同一种 `invoke()` 接口。

### 1.3.5 Memory Runtime

Memory Runtime 负责管理不同层级的记忆，例如：

- Short-term Memory：当前任务的工作记忆
- Long-term Memory：跨任务长期记忆
- Semantic Memory：事实、知识、偏好
- Episodic Memory：任务过程与历史经验
- Workspace Memory：与当前项目、代码库、文件相关的状态

例如：

- “用户偏好 Go”适合进入长期记忆
- “本次任务已经创建了 `feature/login` 分支”更适合会话级或工作区记忆

### 1.3.6 Workflow Runtime

很多现代 Runtime 已经不只是“工具循环”，而是内置了工作流执行能力。  
它们通常支持：

- 顺序流程
- DAG
- Graph
- FSM
- 多 Agent 编排
- Human-in-the-Loop 节点

这使 Runtime 不只是一个循环执行器，而是逐步演进成可编排的智能体执行平台。

### 1.3.7 Event Bus

Runtime 中的几乎所有动作都可以抽象成事件，例如：

- `ToolStarted`
- `ToolFinished`
- `LLMStarted`
- `LLMFinished`
- `MemoryUpdated`
- `CheckpointSaved`
- `ApprovalRequested`

事件总线的价值在于把执行过程开放给：

- UI
- Trace
- Debug
- Metrics
- 审计系统

用户在终端里看到的流式执行反馈，本质上通常也是事件流的外显。

### 1.3.8 Checkpoint

Checkpoint 是企业级 Runtime 的关键能力。  
它允许系统在关键节点保存执行快照，并在失败后从中间状态恢复，而不是整段重跑。

典型场景包括：

- 工具失败后回退到上一个稳定点
- 等待人工审批后从暂停点继续
- 长时间任务跨进程、跨会话恢复
- 审计或复盘时回放任务轨迹

## 1.4 Runtime 生命周期

一个完整的 Runtime，通常会经历下面这条执行链路：

`Receive Task -> Planning -> Execute -> Observe -> Update State -> Checkpoint -> Continue / Done`

如果展开成更完整的生命周期，大致可以描述为：

1. 接收任务
2. 读取上下文和历史状态
3. 规划当前步骤
4. 调用模型生成下一步动作
5. 执行工具或子工作流
6. 观察执行结果
7. 更新状态、记忆和上下文
8. 记录事件与日志
9. 保存 checkpoint
10. 判断继续、暂停、人工介入还是结束

因此，Runtime 不是一次性调用，而是一个持续循环、持续记录、持续纠偏的执行系统。

## 1.5 Runtime 与 Agent、Workflow、Harness 的关系

这几个概念经常被混用，但侧重点并不相同：

- **Agent**：强调目标驱动、自主决策和多步执行
- **Workflow**：强调流程编排、确定性步骤和稳定执行
- **Runtime**：强调如何把模型、工具、状态和工作流组织成可运行系统
- **Harness**：强调围绕模型运行构建的整体工程环境

可以用一个简化关系来理解：

```text
Harness
  └─ Agent Runtime
       ├─ Agent Loop
       ├─ Tool Runtime
       ├─ State / Context / Memory
       └─ Workflow / Event / Checkpoint
```

很多真实系统也不是“纯 Agent”或“纯 Workflow”，而是二者混合：

- 主流程由 Workflow 固定下来
- 不确定节点交给 Agent 决策
- Runtime 负责把两者统一在同一个执行环境中

## 1.6 主流 Agent Runtime 方向

近一两年的主流 Runtime，大致可以分成几类：

| Runtime / 框架 | 典型特点 | 更适合的场景 |
| --- | --- | --- |
| LangGraph | 图执行、持久化、checkpoint、状态图 | 企业级工作流与长任务 |
| CrewAI | 多 Agent 协作、Crew + Flow 模式 | 团队协作型 Agent |
| AutoGen | 对话式 / 事件驱动多智能体 | 多 Agent 研究与实验 |
| Mastra | TypeScript Runtime、Workflow、Memory、Observability | Web / TS 生态 Agent |
| OpenAI Agents SDK | 官方 Agent 运行抽象，支持 tools、handoffs、sessions、guardrails | OpenAI 生态集成 |
| Claude Code / OpenClaw | 面向编码任务的专用 Runtime | Coding Agent |

这些 Runtime 的差异，不主要体现在“是否能调用 LLM”，而在于：

- 状态是否持久化
- 是否支持 checkpoint / 恢复
- 多 Agent 如何协作
- 工具与权限是否统一治理
- 是否具备完整事件流和可观测性

## 1.7 企业级 Agent Runtime 架构

一个典型的企业级 Runtime，通常可以抽象成下面这套结构：

```text
User
  └─ API / UI Layer
       └─ Agent Runtime
            ├─ Scheduler
            ├─ Execution Engine
            ├─ Context Manager
            ├─ State Manager
            ├─ Memory Manager
            ├─ Workflow Engine
            ├─ Tool Runtime
            ├─ Permission Manager
            ├─ Checkpoint Manager
            ├─ Event Bus
            └─ Logging / Tracing

LLM API / MCP Tools / Memory Store
```

这种架构背后的核心思想是职责分离：

- 推理由模型负责
- 执行由 Runtime 驱动
- 状态由 State Manager 管理
- 上下文由 Context Manager 控制
- 工具由 Tool Runtime 统一接入
- 记忆由 Memory Runtime 负责持久化
- 观测由 Event、Log、Trace 体系承接

这样做的好处是更容易扩展、更容易治理，也更适合企业环境中的权限、审计和恢复需求。

## 1.8 发展趋势

当前 Agent Runtime 正从简单执行循环演进为完整智能体平台，几个明显趋势包括：

### 1.8.1 原生持久化与恢复

长时间运行、断点续跑、失败恢复和人工介入，正从“高级特性”变成基础能力。

### 1.8.2 统一上下文管理

Conversation、Memory、Tool Output、Code、External Knowledge 正在被统一纳入上下文管理层，由 Runtime 自动控制装配与压缩。

### 1.8.3 多 Agent 编排

越来越多复杂任务不再由单个 Agent 完成，而是通过图结构、工作流、消息总线或 handoff 机制进行协作。

### 1.8.4 工具生态标准化

Tool 调用正在逐步从“各家私有接口”走向更标准的协议化接入，例如 MCP 一类工具协议带来的解耦方式。

### 1.8.5 可观测性增强

事件流、Tracing、日志、指标和任务回放正变成 Runtime 的标配，因为没有可观测性就很难真正运营和优化 Agent。

### 1.8.6 安全与治理前置

权限、审批、沙箱、审计日志、合规控制不再是外围补丁，而是 Runtime 设计的一部分。

## 1.9 设计 Runtime 时的核心权衡

设计 Runtime 时，常见的矛盾并不是“功能够不够多”，而是下面几组平衡。

### 1.9.1 自主性 vs 可控性

Agent 越自主，能力边界通常越大，但失控风险也越高。  
治理越严格，系统越安全，但灵活性通常会下降。

### 1.9.2 通用性 vs 专用性

通用 Runtime 便于复用和抽象，但会引入更重的系统复杂度；专用 Runtime 更贴近具体任务，但迁移成本更高。

### 1.9.3 长链路能力 vs 稳定性

支持更长的任务链意味着更高上限，但状态漂移、上下文腐烂和工具误调用的概率也会同步上升。

### 1.9.4 效果 vs 成本

更多思考、更细粒度校验、更强观测能力通常能提升质量，但也会带来更高 token、延迟和维护成本。

### 1.9.5 自动化 vs 人工介入

自动化能提高吞吐，但在高风险场景中，人类审批和纠错往往是降低系统性风险的必要手段。

## 1.10 总结

可以把 Agent Runtime 看成 AI Agent 的“操作系统”：

| 能力 | Runtime 的作用 |
| --- | --- |
| 推理执行 | 驱动 ReAct 或其他执行循环 |
| 状态管理 | 保存任务、变量和执行状态 |
| 上下文管理 | 聚合 Prompt、记忆、工具结果和外部知识 |
| 工具调用 | 统一管理本地工具、API 和 MCP 服务 |
| 工作流 | 编排复杂任务和多步骤执行 |
| 持久化 | 支持 checkpoint、恢复和长时间运行 |
| 可观测性 | 提供日志、事件、Tracing 和调试能力 |
| 安全治理 | 提供权限、审批、隔离和审计能力 |

随着 Agent 从一次性对话演进到可持续运行的数字员工，Runtime 已经成为和模型本身同等重要的基础设施。  
一个优秀的 Runtime，不只决定 Agent 能不能完成任务，也决定它是否可靠、可恢复、可扩展，以及是否能进入企业级生产环境。