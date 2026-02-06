# 一 MCP介绍

MCP（Model Context Protocol，模型上下文协议），是由 Anthropic 推出的一种开放标准，旨在统一大模型与外部数据源和工具之间的通信协议。MCP 的主要目的在于解决当前 AI 模型因数据孤岛限制而无法充分发挥潜力的难题，MCP 使得 AI 应用能够安全地访问和操作本地及远程数据，为 AI 应用提供了连接万物的接口。



## 1.1 MCP 与 Function Calling区别

这两种技术都在增强 AI 模型与外部数据的交互能力，MCP解决的是工具接入标准化的问题，两者之间差异如下：

| 对比维度       | Function Call    | MCP                        |
| :------------- | :--------------- | :------------------------- |
| 层级           | 模型能力         | 系统 / 协议                |
| 关注点         | 模型如何调用函数 | 工具如何被标准接入         |
| 是否标准       | 各家实现不同     | 协议级标准                 |
| 是否强依赖模型 | ✅ 是             | ❌ 否                       |
| 适合场景       | 单应用、单模型   | 多工具、多模型、Agent 系统 |
| 类比           | 函数调用语法     | 操作系统接口规范           |

- **Function Call 是“模型怎么用工具”**
- **MCP 是“工具怎么给模型用”**

## 1.2 核心概念

MCP将Agent能力拆分三类：

- Tool：可执行的工具，要求有明确输入schema、结构化输出等，如APIs、数据库
- Resource：可读取数据（文件、DB），主要用于提供上下文信息
- Prompt/Context：注入模型的上下文

![](https://www.dailydoseofds.com/content/images/2025/05/a2avsmcp-ezgif.com-crop.gif)

通过MCP协议，Agent不需要关注实现细节，只需要关注当前有哪些能力，该能力如何调用以及返回结构。

## 1.3 协议

MCP基于**JSON-RPC 2.0**的协议，提供常见方法：

| 方法             | 作用         |
| :--------------- | :----------- |
| `initialize`     | 建立连接     |
| `tools/list`     | 获取工具列表 |
| `tools/call`     | 调用工具     |
| `resources/list` | 资源发现     |
| `resources/read` | 读取资源     |
| `prompts/list`   | Prompt 发现  |
| `prompts/get`    | 获取 Prompt  |

- 发现能力

  ```json
  {
    "method": "tools/list"
  }
  
  // 返回结果
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

- 调用Tool

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
  
  // 返回
  {
    "content": [
      {
        "type": "text",
        "text": "你好"
      }
    ]
  }
  
  ```

  