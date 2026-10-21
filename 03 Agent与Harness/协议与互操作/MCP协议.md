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
![](https://www.dailydoseofds.com/content/images/2025/06/mcp-only--1-.gif)
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

# 四 MCP 的价值

MCP 的工程价值主要体现在：

- 标准化：统一工具与资源接入方式
- 可移植：不同客户端和运行时更容易复用同一套能力
- 可发现：无需把所有能力写死在业务逻辑里
- 可扩展：新增能力时更容易接入与管理

在多工具、跨系统、跨模型的场景下，这种价值会更明显。

# 五 MCP 开发示例

下面以 Python 官方 SDK（`pip install mcp`，Python 3.10+）的 FastMCP 为例，把两个已有接口封装成一个 MCP 服务：日志查询接口和数据库查询接口。封装的核心只有三件事：声明服务、用 `@mcp.tool()` 把函数暴露为工具、选择传输方式启动；参数校验、只读限制和错误语义在服务端兜底。

## 5.1 封装思路

| 现有接口 | MCP 工具 | 封装时补的约束 |
| :--- | :--- | :--- |
| 日志查询 `search_logs(keyword, level, limit)` | `query_logs` | 级别枚举、返回条数上限 |
| 数据库查询 `run_sql(sql, params)` | `query_database` | 只读语句白名单、自动补 `LIMIT` |

函数的名字、类型注解和 docstring 会直接进入 `tools/list` 的返回，成为模型理解工具的唯一依据，因此描述要写清参数取值和返回结构。

## 5.2 核心实现

```python
"""把现有的日志查询与数据库查询接口封装为 MCP 服务。"""

import json
import re

from mcp.server.fastmcp import FastMCP
from mcp.server.fastmcp.exceptions import ToolError

mcp = FastMCP(
    "ops-query",
    instructions="只读运维查询服务：日志检索与数据库查询。",
)

# ---- 现有业务接口，替换为真实实现 ----

def _search_logs(keyword: str, level: str, limit: int) -> list[dict]:
    """现有日志查询接口：返回结构化日志列表。"""
    raise NotImplementedError


def _run_sql(sql: str, params: tuple = ()) -> list[dict]:
    """现有数据库查询接口：执行只读 SQL，返回行列表。"""
    raise NotImplementedError


# ---- MCP 工具封装 ----

@mcp.tool()
def query_logs(keyword: str, level: str = "INFO", limit: int = 100) -> str:
    """按关键字检索应用日志。

    Args:
        keyword: 日志关键字，如 trace_id 或错误信息片段。
        level: 日志级别，取值 DEBUG/INFO/WARN/ERROR。
        limit: 最多返回条数，1 到 500。
    """
    if not 1 <= limit <= 500:
        raise ToolError("limit 必须在 1 到 500 之间")
    rows = _search_logs(keyword, level.upper(), limit)
    return json.dumps({"count": len(rows), "logs": rows}, ensure_ascii=False)


_READ_ONLY = re.compile(r"^\s*(select|with|show|describe|explain)\b", re.I)


@mcp.tool()
def query_database(sql: str, params: list[str] | None = None) -> str:
    """执行只读 SQL 查询数据库，返回结果行。

    Args:
        sql: 只允许 SELECT/WITH/SHOW/DESCRIBE/EXPLAIN 开头的语句。
        params: 位置参数列表，按顺序绑定到 SQL 占位符。
    """
    if not _READ_ONLY.match(sql):
        raise ToolError("仅支持只读查询语句")
    if not re.search(r"\blimit\s+\d+\s*$", sql, re.I):
        sql = f"{sql.rstrip().rstrip(';')} LIMIT 200"
    rows = _run_sql(sql, tuple(params or ()))
    return json.dumps({"count": len(rows), "rows": rows}, ensure_ascii=False)


if __name__ == "__main__":
    mcp.run()  # 默认 stdio 传输，由本地客户端拉起进程
```

## 5.3 客户端接入

客户端配置只描述如何拉起服务，不写业务逻辑：

```json
{
  "mcpServers": {
    "ops-query": {
      "command": "python",
      "args": ["/opt/mcp/ops_query_server.py"]
    }
  }
}
```

## 5.4 实现要点

- 描述即提示词：工具名、参数说明和返回结构会进入 `tools/list`，写得不清楚模型就会猜错用法，呼应第 2.1 节的发现优于硬编码。
- 校验前置：取值范围、只读白名单和 `LIMIT` 在服务端强制，不依赖调用方自觉。
- 错误语义：抛 `ToolError` 会转换为 `isError: true` 的调用结果，模型可据此改参数重试；不要把异常吞成空结果。
- 返回结构化文本：JSON 字符串便于模型解析；结果集过大时先分页或摘要，避免撑爆上下文。
- 传输选择：本地客户端用 stdio；跨进程或跨主机改用 Streamable HTTP，并把鉴权放在 HTTP 层。
- 凭据管理：日志平台与数据库凭据经环境变量或密钥管理注入，客户端配置和代码中不出现明文。