# MemGPT / Letta：安装、使用与记忆管理

MemGPT 是以“上下文像内存一样被动态调度”为核心的记忆运行时思路；当前持续演进的开源产品主线是 [Letta](https://github.com/letta-ai/letta)。新项目应优先以 Letta 的当前文档和 SDK 为准，旧版 MemGPT / Letta V1 的 API 仅适合作为理解经典 memory hierarchy 的参考。

## 1 核心定位

| 维度 | 说明 |
| --- | --- |
| 类型 | 记忆感知的 Agent runtime |
| 核心能力 | 持久 Agent 状态、memory blocks、archival memory、长上下文调度 |
| 适合场景 | 长任务、跨会话 Agent、长期运行的数字助理或 coding agent |
| 不擅长的场景 | 仅需短对话或简单 FAQ 的轻量应用 |

Letta 的基本对象是持久化的 **Agent**，而不是一次性的聊天会话。一个 Agent 可拥有多个 conversation，并持续保留其 memory blocks、归档记忆和配置。

## 2 安装与启动

### 2.1 前置条件

- Python 3.10 或更高版本
- 可访问的模型提供商，或已部署的本地模型服务
- 用于生产环境的持久化数据库与凭据管理方案

### 2.2 安装 SDK 与 CLI

```bash
pip install letta
```

检查安装：

```bash
letta --help
```

Letta 的 CLI、Server 和 SDK 在版本间演进较快。执行安装、升级或部署前，应以 [Letta 官方文档](https://docs.letta.com/) 中与目标版本对应的命令为准。

### 2.3 本地开发与服务端模式

本地探索通常可以直接通过 Python SDK 或 CLI 创建 Agent；需要让 Web 应用、多个客户端或多个 Agent 共用持久状态时，再部署 Letta Server。

部署时应明确：

- Agent 状态与记忆的持久化位置；
- 模型、embedding 与工具服务的网络边界；
- 服务端的认证、用户隔离和审计策略；
- 备份、升级与数据迁移策略。

不要将模型供应商密钥写入脚本或 Markdown。应通过部署环境的变量或密钥管理服务注入，并按提供商最小权限原则配置。

## 3 创建与运行 Agent

### 3.1 先区分 SDK 版本

Letta 的 API 正在演进，创建 Agent 的具体类名、方法和模型配置字段可能随版本不同。接入时先固定版本，再根据该版本的官方 SDK 示例创建 Agent；不要混用旧版 V1 与新 Letta Agent SDK 的代码。

无论使用哪个版本，基本流程保持一致：

```text
配置模型与存储 → 创建持久 Agent → 设置核心 memory blocks
→ 向 Agent 发送消息 → Agent 按需查询 archival memory / 调用工具
→ 检查并维护记忆与会话状态
```

### 3.2 最小概念示例

以下示例表达的是通用工作流，具体导入路径和字段请按所安装的 Letta SDK 版本调整：

```python
# 伪代码：以当前 Letta SDK 的官方示例为准
client = create_letta_client()

agent = client.agents.create(
    name="research_assistant",
    model="your-model",
    memory_blocks=[
        {
            "label": "persona",
            "value": "你是一名严谨的研究助理。",
        },
        {
            "label": "user_profile",
            "value": "用户偏好简洁、可核验的结论。",
        },
    ],
)

response = client.agents.messages.create(
    agent_id=agent.id,
    messages=[{"role": "user", "content": "整理本周调研结论"}],
)
```

核心原则是：将身份、稳定偏好、长期工作约束放入少量 memory blocks；将规模大、按需使用的资料放入 archival memory；不要把全部历史消息固定塞进每次 prompt。

## 4 记忆管理

### 4.1 Memory blocks：始终在上下文中的核心记忆

Memory blocks 适合保存高价值、短小、稳定且每轮都应可见的信息，例如：

- Agent 的角色、行为边界和工作规范；
- 已确认的用户偏好；
- 当前长期任务的关键约束；
- 团队共享的少量稳定规则。

应为每个 block 设定清晰的 label、用途和长度上限。block 越多、越长，越会挤占模型的有效上下文；因此应定期合并重复内容并移除失效规则。

### 4.2 Archival memory：按需检索的长期记忆

Archival memory 用于保存不需要每轮可见、但未来可能召回的资料，例如：

- 长任务的阶段性结论和决策依据；
- 已处理文档的摘要、实体和引用；
- 历史任务的经验与故障记录；
- 需要语义检索的项目知识。

写入时建议附带来源、时间、任务或租户等元数据；检索时使用 Agent、用户、项目或会话边界过滤。检索结果应是辅助上下文，涉及实时或高风险事实时仍需回到权威数据源验证。

### 4.3 Conversation、Agent 与共享记忆

| 对象 | 职责 | 保留策略 |
| --- | --- | --- |
| Agent | 持久身份、模型配置与长期状态 | 长期保存，明确所有者与权限 |
| Conversation | 某条消息线程 | 按业务留存期保存或删除 |
| Memory block | 当前上下文中的核心记忆 | 少量、稳定、可人工审核 |
| Archival memory | 可检索的外部长期资料 | 分作用域保存，支持纠正与遗忘 |

多个 conversation 可以服务同一个 Agent；是否共享 memory block 或 archival memory 是产品权限设计，而不是默认行为。多用户或多租户环境必须在服务端强制隔离 Agent 与记忆作用域。

### 4.4 纠错、删除与保留期限

建立可审计的治理流程：

1. 用户或管理员可以查看 Agent 保存的关键记忆。
2. 错误或过期的 memory block 应显式更新，而不是继续追加矛盾内容。
3. 无需保留的 archival memory 应支持按条、按任务或按用户清除。
4. 为 conversation 和归档资料设置保留期限、删除请求和备份恢复策略。
5. 对模型推断出的结论标注来源与置信度，避免与用户明确陈述混淆。
