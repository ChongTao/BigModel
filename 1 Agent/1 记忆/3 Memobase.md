# 一 Memobase介绍

[memobase](https://docs.memobase.io/introduction)是一款基于用户画像的长期记忆系统，可为AI应用提供长期用户记忆功能，它以用户为中心， 记住用户信息以及用大模型提取的用户画像，为每个用户建立独立的记忆档案。

![memobase](https://mintcdn.com/memobase/YiZ2SowwPcUyIWD4/images/starter.png?w=1100&fit=max&auto=format&n=YiZ2SowwPcUyIWD4&q=85&s=14f1f1ee29c88ec31baef3a4500c904a)

目前支持以下几种来自聊天交互的用户记忆类型：

-  用户画像记忆: 了解用户是谁。
-  事件记忆-：跟踪用户生活中发生的事情。
-  日程记忆：管理用户的日历（即将推出）。
-  社交记忆 ：绘制用户关系图（即将推出）。

# 二 特征

## 2.1 检索内存提示

Memobase 可自动从用户交互中提取和整理各种类型的记忆，包括：

- **用户个人资料**：描述用户的键值属性（例如，姓名、位置、偏好）。
- **用户事件**：用户历史记录中的重要事件和交互。

基本用法：

- 获取用户上下文的最简单方法是调用`context()`用户对象上的方法。

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

- 上下文感知检索:

为了使检索到的上下文与当前对话更加相关，您可以提供最近的聊天记录。Memobase 将执行语义搜索，优先返回最相关的历史事件，而不是仅仅返回最新的事件。

```python
# Continuing from the previous example...
recent_chats = [
    {"role": "user", "content": "What is my name?"}
]

# Get context relevant to the recent chat
relevant_context = user.context(chats=recent_chats)
print(relevant_context)
```

## 2.2 用户个人资料

Memobase 为 LLM 应用程序提供用户配置文件后端，使其能够跟踪和更新特定用户属性随时间的变化。

![memobase_profile](https://mintcdn.com/memobase/YiZ2SowwPcUyIWD4/images/profile_demo.png?w=840&fit=max&auto=format&n=YiZ2SowwPcUyIWD4&q=85&s=1ff336c08ecc4d6cf62683c1ea868442)

Memobase 带有默认的配置文件槽位架构，例如：

```yaml
- basic_info
    - name
    - gender
- education
    - school
    - major
```

## 2.3 用户活动

Memobase 会自动跟踪用户交互中的关键事件和记忆，从而创建用户体验的时间顺序记录。

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

每个事件对象包含以下信息：

- **事件摘要**（可选）：用户近期交互的简要概述。对于每个事件，会生成一份简洁的近期用户交互摘要。该摘要是后续提取个人资料更新和事件标签的主要输入，因此其质量对记忆系统的整体有效性至关重要。
- **事件标签**（可选）：用于对事件进行分类的语义标签（例如，事件、`emotion::happy`活动`goal::buy_a_house`等）。
- **配置文件增量**（必填）：在此事件期间创建或更新的特定配置文件槽位。
- **创建时间**（必填）：事件发生的时间戳。