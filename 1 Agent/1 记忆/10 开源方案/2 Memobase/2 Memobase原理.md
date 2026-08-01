# Memobase 原理

## 一、介绍

[Memobase](https://docs.memobase.io/introduction) 是一类面向 **用户画像和长期用户记忆** 的 Memory 系统。  
它的核心思路不是单纯保存聊天记录，而是以“**用户为中心**”沉淀长期记忆，为每个用户维护独立的记忆档案（memory profile）。

它特别适合“要持续记住某个用户是谁、发生过什么、偏好如何变化”的场景。

![memobase](https://mintcdn.com/memobase/YiZ2SowwPcUyIWD4/images/starter.png?w=1100&fit=max&auto=format&n=YiZ2SowwPcUyIWD4&q=85&s=14f1f1ee29c88ec31baef3a4500c904a)

## 1.1 Memobase 在 Agent 架构中的定位

如果把 Agent 记忆拆成短期记忆、长期记忆、工作记忆、语义记忆等几个层次，Memobase 主要覆盖的是：

- **长期记忆**
- **语义记忆**
- **情节记忆**

它不太像 MemGPT 那样强调“上下文分页 / 内外存切换”，也不像通用向量库那样只提供原始检索能力。  
Memobase 更强调把聊天交互沉淀为：

- 用户画像（profile）
- 重要事件（event）
- 用户关系或日程等扩展记忆

所以它更适合作为 **Agent 的长期用户记忆后端**，而不是完整的 Agent runtime。

## 1.2 核心价值

Memobase 的核心价值在于：**把分散在聊天里的用户信息，转成结构化、可检索、可演化的长期记忆**。

这类能力主要解决三类问题：

1. **个性化问题**
   让 AI 知道用户是谁、偏好什么、过去做过什么。
2. **连续性问题**
   让多轮对话和跨会话交互保持连续，而不是每次“重新认识用户”。
3. **记忆沉淀问题**
   让系统从历史对话中自动提炼稳定信息，而不是只堆聊天记录。

## 1.3 主要记忆类型

目前 Memobase 主要围绕来自聊天交互的用户记忆展开：

- **用户画像记忆（Profile Memory）**：记录用户是谁，例如姓名、位置、偏好、背景信息
- **事件记忆（Event Memory）**：跟踪用户生活中发生过的事件以及关键交互
- **日程记忆（Schedule Memory）**：面向时间安排与待办事项的记忆能力
- **社交记忆（Social Memory）**：围绕人物关系、联系网络的记忆能力

从记忆分类角度看：

- 用户画像记忆更偏 **语义记忆**
- 事件记忆更偏 **情节记忆**
- 日程与社交记忆更接近在特定业务域上的结构化长期记忆

# 二 核心机制

## 2.1 以用户为中心的记忆组织

Memobase 不是围绕“单次会话”组织全部信息，而是围绕“**用户对象**”组织长期记忆。

这意味着：

- 每个用户有独立的记忆空间
- 聊天记录不是最终形态，而是记忆提取的输入
- 系统更关注“这个用户长期有哪些稳定信息”

这和很多“只把会话做 embedding 然后检索”的实现方式不同。  
Memobase 更像是在维护一个可持续更新的 **用户数字档案**。

## 2.2 从聊天到记忆

Memobase 的典型流程可以概括为：

1. 用户与 Agent 发生聊天交互
2. 聊天内容被写入系统
3. 系统从对话中提取候选记忆
4. 将候选记忆整理成 profile 更新或 event 记录
5. 后续交互时再按当前上下文检索相关记忆

也就是说，它不是“原样保存聊天”，而是做了一层 **记忆提取与结构化整理**。

## 2.2.1 记忆是如何存储的

如果只看“存储形态”，Memobase 的记忆大致分成四层：

1. **原始输入层：Blob**
   用户交互不会直接变成 profile。系统先把输入存成 `blob`，官方目前明确支持 `ChatBlob` 和 `SummaryBlob`，其他如 `DocBlob`、`ImageBlob`、`CodeBlob` 仍在扩展中。

2. **缓冲层：Buffer**
   新写入的 blob 不一定立刻进入长期记忆，而是先进入用户级 buffer。  
   这样做的目的，是把多条短消息合并处理，降低抽取成本，并减少过于频繁的 profile 更新。

3. **长期记忆层：Profile + Event**
   buffer flush 后，系统会把可沉淀的信息整理成两类长期记忆：
   - `profile`：稳定用户事实和偏好
   - `event`：按时间组织的重要事件记录

4. **回填层：Context**
   当 Agent 需要使用记忆时，Memobase 再把 profile 和近期/相关 event 组装成上下文，返回给应用或直接生成 prompt。

可以把它理解成：

> 聊天原文先作为 blob 暂存，再经 buffer 批处理后，被提炼成 profile / event 这两类更稳定的长期记忆。

## 2.2.2 存储对象长什么样

从官方 API 形态看，Memobase 的主要存储对象不是“整段聊天历史”，而是几类可单独管理的数据对象：

- **Blob 对象**：保存原始输入内容及其元数据，可以单条读取、分页列出、删除。
- **Profile 对象**：长期用户画像条目，通常包含 `content` 和 `attributes`。其中 `attributes` 常用来描述 `topic`、`sub_topic` 一类槽位信息。
- **Event 对象**：时间序列事件，通常包含事件摘要、事件标签、`profile_delta` 和创建时间。

这意味着 Memobase 的“长期记忆”并不是一整个大 JSON，也不是单纯的向量切片集合，而更像是：

- 一组结构化 profile 条目
- 一组时间序列 event 条目
- 外加底层原始 blob 作为输入留痕

## 2.2.3 更新路径

Memobase 的记忆更新链路可以概括为：

1. 插入聊天或摘要 blob
2. blob 进入 buffer
3. buffer 达到阈值、空闲超时，或被手动 `flush`
4. 系统抽取并更新 profile
5. 同时生成或更新 event 记录

这里一个关键点是：**profile 是“汇总后的长期状态”，event 是“变化发生时的时间化记录”**。  
前者回答“这个用户通常是什么样”，后者回答“最近发生了什么、哪些槽位在何时被改动过”。

## 2.2.4 检索时是怎么取回的

Memobase 取回记忆通常不是直接把所有 blob 再塞回 prompt，而是走两条更高层的读取路径：

- **Profile API**：返回结构化 profile JSON，适合应用自己决定怎么拼 prompt。
- **Context API**：返回已经组装好的上下文字符串，通常包含用户 profile 和最近/相关 event。

如果提供最近聊天内容，Memobase 还会做上下文感知检索，优先返回和当前问题更相关的历史信息，而不是机械地按时间顺序回放所有过去内容。

## 2.2.5 关于底层数据库，需要怎么理解

当前官方文档对外讲得最清楚的是**逻辑存储模型**，而不是非常细的物理实现细节。  
也就是说，文档明确了它有：

- blob 存储
- buffer 处理
- profile / event 长期记忆
- 可配置的 profile schema

但并没有在面向用户的主文档里重点展开“底层具体是哪个数据库引擎、每张表怎么建、索引怎么设计”。  
所以更稳妥的理解方式是：

- **概念层**：Memobase 是“用户中心的长期记忆后端”
- **对象层**：它存的是 blob、profile、event 这些对象
- **流程层**：它通过 buffer + flush 把输入加工成长期记忆

而不是把它简单理解成“又一个向量库”。

## 2.3 系统架构与数据流

从应用集成视角看，Memobase 位于 Agent、业务系统与长期用户记忆之间。它接收原始交互，异步或按批次将其沉淀为可管理的记忆对象；Agent 在生成回复前再读取与当前任务相关的上下文。

```text
用户 / 业务事件
      │
      ▼
Agent 或应用 ── 写入 ChatBlob / SummaryBlob ──► 用户级 Buffer
      ▲                                             │
      │                                             ▼
      │                                    提取、归纳与结构化
      │                                             │
      │                              ┌──────────────┴──────────────┐
      │                              ▼                             ▼
      │                       Profile（稳定画像）          Event（时序事件）
      │                              │                             │
      └────── context(chats=...) ◄── 相关性检索与上下文组装 ◄───────┘
```

这个架构有两个工程含义：

- **写入路径和读取路径分离**：写入的是原始交互，读取的通常是整理后的 profile、event 或 context，而非完整聊天回放。
- **隔离边界应由应用定义**：应用需要把 Memobase 的用户对象映射到自己的租户、账号与授权模型；不能把“用户 ID”当作天然的权限控制。

## 2.4 记忆生命周期

Memobase 的关键不只是“存”和“搜”，而是让记忆经历一条可控的生命周期：

| 阶段 | 输入 / 输出 | 需要关注的问题 |
| --- | --- | --- |
| 采集 | 聊天、摘要等 Blob | 是否只写入对个性化有价值的信息；是否获得用户授权 |
| 缓冲 | 用户级 Buffer | 合并粒度、刷新时机和处理延迟 |
| 沉淀 | Profile 与 Event | 临时表述不能直接固化为长期事实；冲突信息要可追溯 |
| 取回 | Profile JSON 或 Context 文本 | 相关性、时效性和 token 预算 |
| 纠正 / 删除 | 更新或移除记忆 | 用户能否查看、纠正和删除其长期记忆 |

### 2.4.1 Profile 与 Event 的分工

| 维度 | Profile | Event |
| --- | --- | --- |
| 表达内容 | 较稳定的身份、偏好、背景和长期目标 | 某个时间发生的互动、状态变化或关键经历 |
| 时间属性 | 当前汇总状态 | 有明确时间顺序 |
| 典型提问 | “用户通常偏好什么？” | “用户最近在关注什么？” |
| 更新策略 | 用新证据修正或补充 | 追加新事件，必要时关联画像变化 |

因此，不宜把“这周想吃川菜”直接写成永久偏好，也不应仅用一条 profile 覆盖“上周已完成课程”之类的时序事实。前者应结合更多证据再沉淀，后者更适合作为 event 保留。

### 2.4.2 刷新与最终一致性

Blob 写入和长期记忆可见之间存在缓冲与处理过程。实际集成时应把它视为**最终一致**：刚写入的事实未必会立刻出现在 profile 或 context 中。

- 对必须立刻生效的短期状态（当前表单、交易结果、会话槽位），仍应由应用自己的数据库或会话状态管理。
- 对跨会话偏好、背景与事件摘要，交给 Memobase 进行沉淀和检索。
- 在测试中分别验证“写入成功”和“经过 flush / 处理后能被取回”，不要将两者混为一个断言。

## 2.5 检索上下文提示

Memobase 提供了从用户历史中生成上下文提示（context prompt）的能力。  
系统会自动从用户交互中提取和整理各种类型的记忆，包括：

- **用户个人资料**：描述用户的键值属性，例如姓名、位置、偏好
- **用户事件**：用户历史中的重要事件与关键交互

基本用法：

- 获取用户上下文的最简单方法是调用用户对象上的 `context()` 方法

```python
from memobase import MemoBaseClient, ChatBlob

# Initialize client and get/create a user
client = MemoBaseClient(api_key="your_api_key")
user = client.get_user(client.add_user(profile={"name": "Gus"}))

# Insert data to generate memories
user.insert(
    ChatBlob(
        messages=[
            {"role": "user", "content": "I live in California."},
            {"role": "assistant", "content": "Nice, I've heard it's sunny there!"}
        ]
    )
)

# Retrieve the default context prompt
user_context = user.context()
print(user_context)
```

### 上下文感知检索

为了使检索到的上下文与当前对话更相关，可以提供最近的聊天记录。  
Memobase 会执行语义搜索，优先返回和当前问题最相关的历史信息，而不是简单返回最近发生的事件。

```python
# Continuing from the previous example...
recent_chats = [
    {"role": "user", "content": "What is my name?"}
]

# Get context relevant to the recent chat
relevant_context = user.context(chats=recent_chats)
print(relevant_context)
```

## 2.6 用户画像（Profile）

Memobase 为 LLM 应用提供用户 profile 后端，使其能够跟踪和更新特定用户属性随时间的变化。

![memobase_profile](https://mintcdn.com/memobase/YiZ2SowwPcUyIWD4/images/profile_demo.png?w=840&fit=max&auto=format&n=YiZ2SowwPcUyIWD4&q=85&s=1ff336c08ecc4d6cf62683c1ea868442)

Memobase 带有默认的 profile 槽位结构，例如：

```yaml
- basic_info
    - name
    - gender
- education
    - school
    - major
```

这种方式的好处是：

- 比纯自然语言记忆更稳定
- 比原始聊天记录更容易更新
- 更适合做个性化推荐、助手设定、长期用户建模

## 2.7 用户事件（Event）

Memobase 会自动跟踪用户交互中的关键事件和记忆，从而形成按时间组织的事件记录。

```python
from memobase import MemoBaseClient, ChatBlob

# Initialize the client
client = MemoBaseClient(api_key="your_api_key")

# Create a user and insert a chat message
user = client.get_user(client.add_user())
user.insert(
    ChatBlob(
        messages=[{"role": "user", "content": "My name is Gus"}]
    )
)

# Retrieve the user's events
print(user.event())
```

每个事件对象通常包含：

- **事件摘要**：对近期交互的简要概述
- **事件标签**：对事件进行语义分类，例如 `emotion::happy`、`goal::buy_a_house`
- **profile 增量**：本次事件导致的 profile 变化
- **创建时间**：事件时间戳

事件记忆适合回答这类问题：

- 最近发生过什么？
- 用户最近在关注什么？
- 某项偏好是何时形成的？

## 2.8 工程接入与记忆治理

### 2.8.1 最小接入闭环

Python SDK 的最小闭环是：为业务用户创建或获取 Memobase 用户对象，写入 `ChatBlob`，在回复前调用 `context()`，并把返回结果作为 Agent 的补充上下文。官方 SDK 的 API Key 应从环境变量或密钥管理服务读取，不要硬编码进代码库。

```python
import os
from memobase import ChatBlob, MemoBaseClient

client = MemoBaseClient(api_key=os.environ["MEMOBASE_API_KEY"])
user = client.get_user(client.add_user(profile={"app_user_id": "user_123"}))

user.insert(
    ChatBlob(
        messages=[
            {"role": "user", "content": "我更喜欢简洁的中文技术说明。"},
            {"role": "assistant", "content": "好的，后续我会优先使用简洁的中文说明。"},
        ]
    )
)

memory_context = user.context(
    chats=[{"role": "user", "content": "解释一下 RAG 的检索步骤"}]
)
# 将 memory_context 与当前消息、系统提示词一起交给模型。
```

这里的 `app_user_id` 只是业务映射示例，不是认证信息。生产环境还应在应用侧校验“当前调用者是否有权读取该 Memobase 用户”的关系。

### 2.8.2 上下文注入策略

不要无条件把全部记忆塞进 system prompt。更稳妥的顺序是：

1. 将当前用户问题和最近少量对话传给 `context(chats=...)`，获取相关记忆。
2. 为记忆设置独立 token 预算，并优先保留与当前任务直接相关的内容。
3. 将“来自历史记忆”的内容作为可被模型引用、但仍可能需要确认的上下文；对价格、账户状态、医疗建议等高风险事实，以业务系统的实时数据为准。
4. 在需要结构化展示或业务规则判断时读取 profile / event，而不是依赖自然语言 context 的格式。

### 2.8.3 数据治理清单

长期用户记忆比普通会话日志更容易形成敏感画像。上线前至少应明确：

- **采集范围**：哪些字段允许被写入，哪些类别（凭据、支付信息、身份号码、私密健康信息等）必须在进入 Blob 前过滤。
- **用户权利**：提供查看、导出、更正、删除长期记忆的产品入口，并明确删除的传播范围与生效时间。
- **租户隔离**：以业务租户和用户身份做服务端鉴权，不允许客户端任意指定其他用户的记忆标识。
- **保留策略**：区分短期任务状态、长期偏好和审计记录，分别设置保留期与清理流程。
- **可观测性**：记录写入、读取、删除和失败处理的审计事件；日志中避免记录原始敏感对话。

# 三 适合场景

Memobase 特别适合以下场景：

## 3.1 长期个性化助手

例如 AI 私人助理、生活助理、学习助理、健康顾问等。  
这些场景需要持续记住用户偏好、近期事件和长期背景。

## 3.2 面向用户的 AI 产品

例如：

- AI 陪伴 / 社交产品
- 客服或成功经理助手
- 教育与成长教练
- 电商导购和个性化推荐系统

这类产品最需要的不是“通用文档知识”，而是“对这个用户的持续了解”。

## 3.3 CRM / 用户运营相关系统

如果系统需要长期追踪：

- 用户偏好
- 重要事件
- 关系变化
- 长期生命周期状态

那么 Memobase 这种以用户为中心的记忆组织方式会比纯 RAG 更贴合业务。