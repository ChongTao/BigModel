# 一 Mem0介绍

[mem0](https://docs.mem0.ai/cookbooks/overview)是一款专为大语言模型应用打造的 **记忆层／记忆管理系统**，旨在解决 AI 系统“忘记之前交互内容”这一典型痛点，特点如下：

- **长期记忆 + 短期记忆管理**：支持 “短期” 会话内上下文（conversation history）与 “长期” 跨会话保存的用户信息、偏好、经历等。
- **多类型记忆模型**：包括事实记忆（factual memory）、语义记忆（semantic memory）、情景记忆（episodic memory）等。
- **高效检索与管理**：使用向量存储（vector store）、图数据库（graph store）、键-值存储（key-value store）等混合架构，以便快速检索相关记忆。
- **节省成本与提高性能**：据其官方数据，Mem0 在某些基准测试上比传统「全部上下文＋RAG」（retrieval-augmented generation）方式在 token 使用量、延迟、准确率上有所优势。
- **易于集成／部署**：提供开源 SDK（如 Python、JavaScript），也有托管平台版本，支持多种后端向量数据库

- **提取 + 更新两阶段流程**：聊天发生后，系统会从最新交互与历史回顾中提取“候选记忆”，然后判断是否「新增／更新／删除／合并」已有记忆（[原理](https://zhuanlan.zhihu.com/p/1905724877035516887)）。
- **语义向量检索 + 图关系理解**：通过将记忆转为向量后进行相似度搜索，同时利用图数据库理解实体/关系，使记忆的检索更精准。
- **高效性能表现**：在某些测试中，Mem0 实现了比传统全上下文方法大幅度降低 token 使用（例如节省 90% 以上）和延迟（如 p95 延迟减少约 90%）的表现。



# 二 使用

以下为简单示例（基于其开源 SDK）：

```python
from mem0 import Memory
memory = Memory()
# 添加用户记忆
memory.add("我喜欢坐靠窗的座位", user_id="user123")
# 搜索相关记忆
results = memory.search(query="你的座位偏好是什么？", user_id="user123", limit=3)
```

或者使用托管平台版本：

```python
from mem0ai import MemoryClient
client = MemoryClient(api_key="YOUR_MEM0_API_KEY")
memory = client.for_user(user_id="user123")
memory.add("我喜欢在早上跑步")
```