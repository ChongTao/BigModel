# Mem0：安装、使用与记忆管理

[Mem0](https://github.com/mem0ai/mem0) 是面向 AI 应用与 Agent 的记忆层：它从对话中提取可复用的事实、偏好和决策，按作用域保存，并在后续请求中检索相关记忆。它保存的重点不是完整聊天记录，而是可维护的 memory item。

## 1 核心定位

| 维度 | 说明 |
| --- | --- |
| 类型 | Agent / LLM 应用的长期记忆层 |
| 主要能力 | 记忆提取、存储、检索、显式更新与删除 |
| 接入方式 | 自托管 Open Source SDK 或托管 Mem0 Platform |
| 常用作用域 | `user_id`、`agent_id`、`app_id`、`run_id` |
| 适合场景 | 个性化助手、跨会话 Agent、长期任务与团队知识沉淀 |

使用时应把 Mem0 放在 Agent 的上下文编排链路中：写入发生在有价值的新信息出现后，检索发生在生成回答或执行任务前；不要把它当作原始对话日志的替代品。

## 2 安装与初始化

### 2.1 前置条件

- Python 3.9 或更高版本
- 自托管模式需要可用的 LLM 与 embedding 配置
- 托管模式需要在 Mem0 Platform 创建项目并获取 API Key

### 2.2 安装开源 SDK

```bash
pip install mem0ai
```

安装后，Python 导入名是 `mem0`：

```python
from mem0 import Memory

memory = Memory()
```

> `mem0ai` 是发行包名，`mem0` 是 Python 模块名。生产环境应通过 `Memory.from_config()` 显式配置模型与存储后端，避免依赖隐式默认值。

### 2.3 初始化托管 Platform 客户端

将 API Key 放在部署环境的密钥管理系统或环境变量中，不要写入代码、示例输出或仓库文档。

```python
import os
from mem0 import MemoryClient

client = MemoryClient(api_key=os.environ["MEM0_API_KEY"])
```

Platform 与 OSS 的调用模型相近；差别主要在于基础设施由谁运维，以及可配置后端的范围。对数据驻留、模型供应商或检索后端有明确要求时，优先评估 OSS；希望尽快接入时，优先评估 Platform。

## 3 基本使用

### 3.1 写入对话并提取记忆

`add()` 的输入通常是一条或多条消息。Mem0 从消息中提取值得长期保留的信息并返回写入结果。

```python
from mem0 import Memory

memory = Memory()

messages = [
    {"role": "user", "content": "我偏好靠窗的座位，通常早上跑步。"},
]

result = memory.add(
    messages,
    user_id="user_123",
    metadata={"source": "profile_chat"},
)

print(result)
```

写入内容应是稳定事实、偏好、长期计划、已确认决策或可复用经验；不要把每一次闲聊、未确认猜测、一次性验证码或敏感凭据都写入记忆。

### 3.2 检索并回填 Agent 上下文

在模型生成前，用当前问题检索相关记忆，只将少量高相关结果组织进 prompt。

```python
results = memory.search(
    query="用户对座位有什么偏好？",
    user_id="user_123",
    limit=3,
)

for item in results.get("results", []):
    print(item["memory"])
```

一个常见的 Agent 调用顺序是：

```text
当前用户问题 → memory.search() → 选择 Top-K 记忆 → 构造 prompt → LLM / 工具调用
                                                   ↓
                                         新的稳定信息 → memory.add()
```

检索结果只是辅助上下文，不是不可质疑的事实。涉及权限、金额、地址、时间等高风险或易变化的信息，仍应向权威数据源或用户本人确认。

### 3.3 查看已有记忆

```python
memories = memory.get_all(user_id="user_123", limit=20)

for item in memories.get("results", []):
    print(item["id"], item["memory"])
```

在提供用户可见的“记忆管理”页面时，建议同时展示记忆内容、创建/更新时间、作用域和来源元数据，并提供删除或纠正入口。

## 4 作用域与隔离

Mem0 的检索与写入应始终带上明确的边界字段。最常用的是：

| 字段 | 用途 | 示例 |
| --- | --- | --- |
| `user_id` | 用户私有的长期偏好和事实 | `user_123` |
| `agent_id` | 区分不同 Agent 或工作角色 | `support_agent` |
| `app_id` | 区分产品、租户或业务入口 | `customer_portal` |
| `run_id` | 标识一个短期执行、会话或工单 | `ticket_456` |

例如，同一用户在两个产品中使用不同助手时，可将 `user_id` 与 `app_id` 一起传入：

```python
scope = {
    "user_id": "user_123",
    "agent_id": "travel_assistant",
    "app_id": "trip_planner",
}

memory.add(messages, **scope)
results = memory.search("推荐靠窗座位", **scope, limit=5)
```

作用域是隔离策略的一部分，不是可选装饰。多租户场景应在服务端从已认证身份派生这些字段，不能直接信任客户端随意传入的租户或用户 ID。

## 5 记忆治理

### 5.1 更新已存在的记忆

默认写入更接近“新增并提取”，纠正错误或补充已有事实时应使用显式更新，避免新旧冲突长期同时存在。

```python
memory.update(
    memory_id="memory_id_from_get_all",
    data="用户目前常住上海，偏好靠窗座位。",
)
```

具体参数名称会随 SDK 版本变化；升级时以所用版本的官方 API 参考为准，并为更新流程保留集成测试。

### 5.2 删除、重置与遗忘请求

删除单条不正确、过期或用户要求移除的记忆：

```python
memory.delete(memory_id="memory_id_from_get_all")
```

删除某个用户全部记忆前，应先要求明确确认，并记录可审计的操作者、时间和删除范围：

```python
# 谨慎使用：会清除该用户在当前作用域下的全部记忆
memory.delete_all(user_id="user_123")
```

产品层至少应具备：用户查看、纠正、删除、导出/清除请求处理，以及按保留期限清理过期记忆的能力。

### 5.3 元数据、来源与质量控制

写入时用 `metadata` 保存来源、业务对象或置信度等可审计信息，例如 `source`、`ticket_id`、`confirmed_by_user`。不要把敏感原文放入元数据。

建议建立以下规则：

- 仅写入与后续任务确有复用价值的信息；
- 对可能变化的事实记录时间与来源；
- 对模型推断与用户明确陈述使用不同的置信度标签；
- 定期抽样检查错误记忆、重复记忆和跨作用域泄漏；
- 对敏感字段先脱敏或直接禁止写入。
