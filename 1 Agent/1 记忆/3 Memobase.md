# 一 Memobase 介绍

[Memobase](https://docs.memobase.io/introduction) 是一类面向 **用户画像和长期用户记忆** 的 Memory 系统。  
它的核心思路不是单纯保存聊天记录，而是以“**用户为中心**”沉淀长期记忆，为每个用户维护独立的记忆档案（memory profile）。

从 Agent Memory 的视角看，Memobase 更偏向：

- **用户中心的长期记忆**
- **结构化 profile + 事件记忆**
- **面向个性化和长期交互**

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

## 2.3 检索上下文提示

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

## 2.4 用户画像（Profile）

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

## 2.5 用户事件（Event）

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

# 四 与其他记忆方案的关系

Memobase 的横向定位可以概括为：

- 它不是单纯的向量检索后端
- 它更偏“用户中心的长期记忆后端”
- 它特别强调 `profile / event` 这类长期用户档案

如果要看它和 Mem0、MemGPT、通用 RAG 的系统对比，统一放在：[10 记忆方案对比.md](./10%20记忆方案对比.md)

# 五 局限与注意点

## 5.1 更偏用户记忆，不是完整 Agent runtime

Memobase 很适合做长期用户记忆，但它本身不等于完整的 Agent 运行系统。  
实际落地时，通常仍需要外层 Harness 来负责：

- 工具调用
- 任务规划
- 状态流转
- 权限控制
- 终止条件

## 5.2 记忆抽取质量依赖模型

如果从聊天里抽取 profile 或 event 的模型质量不高，就可能出现：

- 抽取不完整
- 把短期信息误写成长期事实
- 错误更新用户画像

## 5.3 隐私与数据治理问题

用户画像、事件、关系网络本身就可能是敏感数据。  
在生产环境中，需要额外考虑：

- 数据最小化原则
- 用户可删除 / 可纠错
- 权限隔离
- 合规与保留策略

# 六 总结

可以把 Memobase 理解为：

> 一个围绕“用户是谁、经历过什么、偏好如何变化”来构建长期记忆的系统。

它最有价值的地方不在于“帮你存对话”，而在于：

- 帮你维护长期用户档案
- 把历史交互转成 profile 和 event
- 为 Agent 提供面向个性化的长期用户记忆
