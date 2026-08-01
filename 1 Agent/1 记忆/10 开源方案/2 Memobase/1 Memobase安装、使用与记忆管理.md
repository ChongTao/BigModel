# Memobase：安装、使用与记忆管理

## 1 介绍

[Memobase](https://docs.memobase.io/introduction) 是面向长期用户记忆的服务。它将聊天等原始输入沉淀为用户画像（Profile）和时间化事件（Event），再向 Agent 返回与当前对话相关的记忆上下文。

与直接保存完整聊天记录相比，接入重点是建立稳定的业务用户映射、控制写入范围，并在生成回复前按需取回记忆。


## 2 安装与初始化

### 2.1 前置条件

- 已创建可用的 Memobase 服务账号与 API Key。
- Python 环境可安装并运行官方 SDK。
- 应用自身能够识别当前租户和业务用户；Memobase 的用户对象不替代应用鉴权。

### 2.2 安装 SDK

```bash
pip install memobase
```

将 API Key 放入部署环境的密钥管理服务或环境变量中。不要将真实密钥写入 Markdown、源码或版本控制文件。

```bash
# macOS / Linux
export MEMOBASE_API_KEY="your_api_key"

# PowerShell
$env:MEMOBASE_API_KEY="your_api_key"
```

### 2.3 创建或获取用户

每个业务用户应映射到一个独立的 Memobase 用户对象。下面以业务侧的 `app_user_id` 作为关联信息；生产环境应由服务端根据当前登录身份确定该值。

```python
import os
from memobase import MemoBaseClient

client = MemoBaseClient(api_key=os.environ["MEMOBASE_API_KEY"])
user = client.get_user(
    client.add_user(profile={"app_user_id": "user_123"})
)
```

## 3 基本使用

### 3.1 写入对话

将一段完整且有语义边界的用户—助手交互写入 `ChatBlob`。避免将每个字符或无意义的 UI 事件单独写入，这会降低提取质量并增加处理成本。

```python
from memobase import ChatBlob

user.insert(
    ChatBlob(
        messages=[
            {"role": "user", "content": "我更喜欢简洁的中文技术说明。"},
            {"role": "assistant", "content": "好的，后续我会优先使用简洁的中文说明。"},
        ]
    )
)
```

### 3.2 取回上下文

在调用模型前传入当前问题或最近对话，让 `context()` 选择相关的长期记忆。返回值应作为补充上下文，而不是覆盖系统指令或实时业务数据。

```python
recent_chats = [
    {"role": "user", "content": "解释一下 RAG 的检索步骤"}
]

memory_context = user.context(chats=recent_chats)
# 将 memory_context 与系统提示词、当前对话一起提供给模型。
```

### 3.3 读取结构化记忆

当业务逻辑需要查看稳定画像或近期事件时，使用对应的 Profile / Event 读取接口。与 `context()` 返回的自然语言上下文相比，结构化对象更适合展示、审核和规则判断。

```python
profile = user.profile()
events = user.event()
```

## 4 记忆管理

### 4.1 写入策略

- 写入可能影响未来交互的偏好、长期目标、关键事件和必要背景。
- 不写入密码、访问令牌、支付凭据、身份证件号码等敏感信息。
- 当前订单状态、表单草稿等必须即时一致的数据，应保留在应用自己的数据库或会话状态中。

### 4.2 取回策略

- 使用最近对话驱动相关性检索，不要将全部历史记忆无差别注入 prompt。
- 为记忆上下文预留独立 token 预算；内容过多时优先保留与当前任务最相关的记忆。
- 对价格、账户、医疗等高风险事实，以实时业务数据或人工确认结果为准。

### 4.3 删除、更正与治理

用户画像属于长期数据，应在产品层提供查看、更正和删除能力。删除流程需要明确其影响范围：原始输入、已提取的 Profile / Event、缓存以及日志保留策略。

同时应做到：

- 服务端按租户和业务用户校验读取、写入、删除权限。
- 记录必要的写入、读取和删除审计事件，审计日志避免保留原始敏感对话。
- 将“写入成功”和“记忆已完成处理、可被取回”分别监控；二者之间可能存在缓冲处理延迟。

## 5 最小接入流程

```text
识别当前业务用户
        │
        ▼
写入有价值的 ChatBlob ──► 等待记忆处理 ──► Profile / Event
        │                                           │
        └── 当前问题 + 最近对话 ─► context() ◄──────┘
                                           │
                                           ▼
                                作为补充上下文调用 Agent
```

在上线前分别验证用户隔离、写入后的取回效果、删除链路和敏感字段过滤。
