# LangMem：安装、使用与记忆管理

[LangMem](https://github.com/langchain-ai/langmem) 是 LangChain 团队提供的记忆工具箱。它通过 memory tools 和后台 manager，为已有 Agent 增加可组合的记忆读写、检索、摘要与整理能力；最自然的集成场景是 LangGraph 的 Store 与 Agent 工作流。

## 1 核心定位

| 维度 | 说明 |
| --- | --- |
| 类型 | Memory toolkit / primitives |
| 主要能力 | 记忆工具、后台记忆管理、profile、摘要与优化模式 |
| 存储方式 | LangGraph Store 或兼容的自定义 Store |
| 适合场景 | 已使用 LangGraph、希望自行控制存储与记忆策略的 Agent |

LangMem 不负责替你托管完整记忆服务。模型、向量索引、数据库、隔离、保留期限和审计策略都需要由应用侧明确选择并实现。

## 2 安装与 Store 配置

### 2.1 安装

```bash
pip install -U langmem langgraph
```

开发测试可使用进程内的 `InMemoryStore`；进程重启后数据会丢失。生产环境应使用持久化、可备份、可访问控制的 Store，例如官方支持的数据库后端，并根据所用版本的 [LangMem 文档](https://langchain-ai.github.io/langmem/) 配置索引与 embedding。

### 2.2 开发环境中的 Store

```python
from langgraph.store.memory import InMemoryStore

store = InMemoryStore()
```

将 Store 作为依赖传入 Agent 或 LangGraph 执行图；不要在每次请求中重新创建 Store，否则记忆不会持续。

### 2.3 生产环境要点

- 使用持久化数据库与受控的迁移、备份流程；
- 为语义检索配置 embedding 模型与索引字段；
- 将模型和数据库凭据交给密钥管理服务，而不是提交到代码库；
- 为每个用户、Agent、项目或租户定义独立 namespace；
- 限制网络访问、设置认证，并记录关键记忆的变更审计。

## 3 基本使用

### 3.1 直接读写 Store

LangGraph Store 使用 namespace 将不同作用域的记忆隔离。以下示例保存与搜索用户偏好：

```python
namespace = ("memories", "user_123")

store.put(
    namespace,
    "seat_preference",
    {"content": "用户偏好靠窗座位", "source": "confirmed_by_user"},
)

results = store.search(namespace, query="座位偏好")
```

真实项目中，namespace 应由服务端的认证身份生成，不能直接相信客户端传入的用户 ID 或租户 ID。

### 3.2 将记忆工具交给 Agent

LangMem 可以创建供 Agent 在 hot path 自主调用的管理和搜索工具：

```python
from langmem import create_manage_memory_tool, create_search_memory_tool

# 具体参数随 LangMem 版本而变化，请以对应版本文档为准。
manage_memory = create_manage_memory_tool(...)
search_memory = create_search_memory_tool(...)

agent_tools = [manage_memory, search_memory]
```

建议只赋予 Agent 必要的工具权限：普通对话 Agent 通常只需要当前用户 namespace 的读取和受限写入；跨租户搜索、批量删除和全局维护应交由受控后台任务或管理员流程。

### 3.3 热路径与后台路径

```text
当前对话 → search memory tool → 回填少量相关记忆 → Agent 回复/执行
     ↓
稳定的新事实 → manage memory tool 或后台 manager → Store
```

- **Hot path**：当下需要时检索、确认或记录少量关键事实。
- **Background path**：异步做摘要、去重、用户画像更新、经验整合等较慢任务。

不要把全部对话无差别写入长期记忆。写入前应判断信息是否稳定、可复用、已确认且符合数据保留规则。

## 4 记忆治理

### 4.1 Schema 与元数据

建议为记忆记录保留 `content` 之外的来源、时间、置信度、业务对象和保留期限等元数据。区分用户明确陈述、模型推断和外部系统同步的信息，能降低错误记忆长期影响决策的风险。

### 4.2 更新与删除

使用稳定的 Store key 管理可变事实；事实变化时更新原记录或标记旧记录失效，而不是无限追加相互矛盾的偏好。产品应提供按用户、任务或 namespace 查询、纠正和删除记忆的能力，并保留适当审计。

### 4.3 注入控制

检索结果进入模型前应限制数量、长度与作用域：

- 只注入与当前问题相关的 Top-K 结果；
- 设置 token 预算，避免记忆吞噬有效上下文；
- 对高风险或易变化事实回到权威数据源验证；
- 对敏感信息默认禁止写入或在写入前脱敏。


## 5 相关文档
- [LangMem 官方文档](https://langchain-ai.github.io/langmem/) 与 [GitHub 仓库](https://github.com/langchain-ai/langmem)：以当前 API 与后端支持情况为准。
