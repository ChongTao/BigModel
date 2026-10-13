# 一 MCP 介绍

MCP（Model Context Protocol，模型上下文协议）是一种用于连接大模型与外部工具、资源、提示模板的开放协议。

它要解决的核心问题不是“模型会不会调用函数”，而是：

- 工具如何被标准化暴露出来
- 不同客户端如何用统一方式发现和调用能力
- 工具、资源、提示如何被组织成可复用接口

如果说 Function Calling 更偏“模型输出一个结构化调用请求”，那么 MCP 更偏“外部能力如何以统一协议接给模型系统”。

## 1.1 为什么需要 MCP

如果每个工具都用自己的一套接入方式，就会出现这些问题：

- 接入方式不统一
- 工具发现成本高
- 不同模型和运行时难以复用
- 工具、资源、提示缺少统一抽象

MCP 的目标就是把这些能力接入标准化，让模型系统面对外部能力时不必每次重新造一套协议。

## 1.2 MCP 和 Function Calling 的区别

这两者经常同时出现，但它们不是一回事：

| 对比维度 | Function Calling | MCP |
| :--- | :--- | :--- |
| 所处层级 | 模型接口层 | 工具接入协议层 |
| 核心问题 | 模型怎么表达调用 | 工具怎么标准接入 |
| 关注对象 | 函数名、参数、结构化调用 | 工具、资源、提示的发现与访问 |
| 适合场景 | 单模型、单应用、直接调用 | 多工具、多客户端、多运行时复用 |
| 类比 | 函数调用语法 | 统一设备接口规范 |

可以简单记成：

- Function Calling 是“模型怎么用工具”
- MCP 是“工具怎么给模型系统用”

## 1.3 MCP 暴露哪些能力

MCP 通常把能力分成三类：

- Tools：可执行能力，例如搜索、数据库查询、API 调用
- Resources：可读取资源，例如文件、文档、数据表
- Prompts：可复用的提示模板或上下文模板

![](https://www.dailydoseofds.com/content/images/2025/05/a2avsmcp-ezgif.com-crop.gif)

这意味着 MCP 不只是“工具协议”，它本质上是在统一模型系统可访问的外部能力面。

# 二 MCP 的基本工作方式

MCP 的典型流程通常是：

1. 客户端与 MCP Server 建立连接
2. 客户端发现可用 tools、resources、prompts
3. 客户端根据当前任务选择能力
4. 客户端发起调用或读取请求
5. 服务端返回结构化结果

这里的关键是：客户端不必提前把每个工具的实现写死，而是可以通过协议动态发现和使用能力。

## 2.1 一个重要特点：发现优于硬编码

传统做法里，工具往往是写死在应用里的：

- 工具名固定
- 调用方式固定
- 参数结构固定

而 MCP 更像是：

- 先发现有哪些能力
- 再决定怎么用这些能力

这让工具生态更容易扩展，也更适合 Agent 系统。

# 三 MCP 常见协议能力

MCP 常见地基于结构化消息机制工作，常见操作包括：

| 方法 | 作用 |
| :--- | :--- |
| `initialize` | 建立连接与初始化 |
| `tools/list` | 获取工具列表 |
| `tools/call` | 调用工具 |
| `resources/list` | 发现资源 |
| `resources/read` | 读取资源 |
| `prompts/list` | 发现提示模板 |
| `prompts/get` | 获取提示模板 |

## 3.1 获取工具列表

```json
{
  "method": "tools/list"
}
```

可能返回：

```json
{
  "tools": [
    {
      "name": "translate",
      "inputSchema": {
        "text": "string",
        "target_lang": "string"
      }
    }
  ]
}
```

## 3.2 调用工具

```json
{
  "method": "tools/call",
  "params": {
    "name": "translate",
    "arguments": {
      "text": "hello",
      "target_lang": "zh"
    }
  }
}
```

可能返回：

```json
{
  "content": [
    {
      "type": "text",
      "text": "你好"
    }
  ]
}
```

![](https://www.dailydoseofds.com/content/images/2025/06/mcp-only--1-.gif)

# 四 MCP 的价值

MCP 的工程价值主要体现在：

- 标准化：统一工具与资源接入方式
- 可移植：不同客户端和运行时更容易复用同一套能力
- 可发现：无需把所有能力写死在业务逻辑里
- 可扩展：新增能力时更容易接入与管理

在多工具、跨系统、跨模型的场景下，这种价值会更明显。

# 五 MCP 的边界

MCP 并不解决所有问题，它主要不负责：

- 模型到底是否应该调用某个工具
- 多步任务如何推理和规划
- 任务执行后的验证与恢复
- 整个 Agent 工作流的运行控制

这些问题通常分别落在：

- Function Calling / Tool Use
- ReAct / Plan-and-Execute 等推理范式
- Harness / Agent Runtime

所以，MCP 是连接层，不是完整 Agent 系统本身。

# 六 与 Harness 的关系

Harness 往往会把 MCP 作为外部能力接入的一部分来使用。

可以理解为：

- MCP 负责把工具和资源标准化暴露出来
- Harness 负责把这些能力组织进真实任务流

也就是说，MCP 提供的是“接口生态”，Harness 提供的是“执行环境”。

