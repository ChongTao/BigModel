# Hermes 原理

Hermes 走的是“**工具密度 + 长期运行 + 自我改进**”路线。和单纯把大模型包一层 chat UI 的方案不同，Hermes 强调的是：让 Agent 长时间存在、持续积累经验、自动生成 Skill、跨平台接入，并把复杂任务拆给子 Agent 并行处理。

![](https://www.runoob.com/wp-content/uploads/2026/06/runoob_1782524875795.png)

## 1 整体架构

![](https://www.runoob.com/wp-content/uploads/2026/04/425bde75-892c-4560-8d76-89d15c7e7555.webp)

| 模块                            | 作用                   | 示例                   |
| :------------------------------ | :--------------------- | :--------------------- |
| 接入层（Clients）               | 接收用户请求           | Web、App、API、飞书    |
| 输入层（Input）                 | 处理各种输入数据       | 文本、图片、PDF、Excel |
| 调度器（Agent Orchestrator）    | 理解任务并拆分执行流程 | 分析需求 → 制定计划    |
| 能力层（Capabilities）          | 提供执行能力           | 对话、检索、代码执行   |
| 记忆层（Memory）                | 保存上下文和历史信息   | 会话记忆、长期记忆     |
| 知识层（Knowledge）             | 提供知识检索能力       | RAG、向量数据库        |
| 模型层（Model Layer）           | 提供推理能力           | GPT、Claude、本地模型  |
| 工具层（Tools）                 | 调用外部工具完成任务   | 搜索、数据库、API      |
| 外部服务层（External Services） | 对接业务系统           | ERP、CRM、云服务       |
| 基础设施层（Infrastructure）    | 支撑系统运行           | 权限、日志、监控       |

## 2 核心

### 2.1 Memory

Hermes 采用三层记忆架构：高频重要信息常驻上下文，低频历史信息按需召回，深层模式由 AI 自动推理——在记忆能力与 Token 成本之间取得平衡。

| 记忆层级        | 存储位置                               | 容量                 | 加载方式                      | 用途                   |
| :-------------- | :------------------------------------- | :------------------- | :---------------------------- | :--------------------- |
| 持久记忆        | ~/.hermes/memories/ 下的 Markdown 文件 | ~1,300 tokens 总量   | 会话启动时自动注入系统提示词  | 关键事实，始终可见     |
| 情节日志        | SQLite 数据库 + JSONL 转录文件         | 无限（所有历史对话） | Agent 按需搜索，FTS5 全文检索 | 查找特定历史讨论       |
| Honcho 用户建模 | Honcho 服务端 API                      | 按 Agent 隔离        | 每轮/每 N 轮后台推理注入      | 自动推导深层偏好与目标 |

#### 持久记忆文件

持久记忆是 Hermes 记忆系统的第一层，也是最基础的一层。

它由两个存放在 `~/.hermes/memories/` 下的 Markdown 文件组成，每次会话启动时自动注入系统提示词。

| 文件      | 用途                                                   | 字符上限   | 约等于      |
| :-------- | :----------------------------------------------------- | :--------- | :---------- |
| MEMORY.md | Agent 的个人笔记——环境事实、项目规范、工作中学到的东西 | 2,200 字符 | ~800 tokens |
| USER.md   | 用户画像——你的偏好、沟通风格、工作习惯、技能水平       | 1,375 字符 | ~500 tokens |

每次会话启动时，两个文件的内容以固定格式注入系统提示词，注意事项：

- 系统提示词中的记忆内容在会话开始时捕获一次，中途不会更新，目的是保持前缀缓存，降低token成本。
- 每条记忆之间用 § 分隔，条目本身可以是多行文字。

```markdown
══════════════════════════════════════════════
MEMORY（Agent 个人笔记）[67% — 1,474/2,200 字符]
══════════════════════════════════════════════
用户的项目是位于 ~/code/myapi 的 Rust Web 服务，使用 Axum + SQLx
§
本机运行 Ubuntu 22.04，已安装 Docker 和 Podman
§
用户偏好简洁回复，不喜欢冗长解释
```

##### 记忆处理

| 操作    | 说明                         | 参数                           |
| :------ | :--------------------------- | :----------------------------- |
| add     | 新增一条记忆条目             | target（memory/user）、content |
| replace | 替换已有条目（子串匹配定位） | target、old_text、content      |
| remove  | 删除已有条目（子串匹配定位） | target、old_text               |

Agent 会自动判断并保存有价值的信息，例如以下类型的信息触发 Agent 写入 MEMORY.md：

| 类型     | 示例                                                         |
| :------- | :----------------------------------------------------------- |
| 环境事实 | 本机运行 Debian 12，PostgreSQL 16，Docker 用 Podman 替代     |
| 项目规范 | ~/code/api 使用 Go 1.22，sqlc 查询，chi 路由；测试用 make test |
| 工具经验 | staging 服务器 SSH 端口是 2222，不是 22，密钥在 ~/.ssh/staging_ed25519 |
| 纠正记录 | 不要用 sudo 运行 Docker 命令，用户已在 docker 用户组         |
| 完成工作 | 2026-01-15 完成数据库从 MySQL 迁移到 PostgreSQL              |

以下类型的信息触发 Agent 写入 USER.md：

| 类型     | 示例                                   |
| :------- | :------------------------------------- |
| 身份信息 | 姓名、职位、时区                       |
| 沟通偏好 | 偏好简洁回复，不需要解释显而易见的步骤 |
| 厌恶项   | 不要在代码里加过多注释                 |
| 工作习惯 | 每天下午 3 点前不看消息                |
| 技能水平 | 熟悉 Rust 和 Python，Go 是新学的       |

##### 记忆容量管理

记忆文件有严格的字符上限，Agent 需要在接近上限时主动整理。当新条目会导致超出字符上限时，工具返回错误而非静默截断，然后读取所有条目，找出可以删除或合并的条目，用 `replace` 将几条相关条目合并为一条更精炼的版本，然后重试。

##### 记忆自我压缩

每轮对话结束后，Hermes 会在后台运行一次自我改进回顾（background review），分析这轮对话并提炼值得保留的记忆或技能。

#### 情景记忆

第二层记忆——情节日志（Session History）——存储所有历史对话的完整记录，支持全文检索和按需召回。所有记忆都会自动保存，保存两个地方：

| 存储位置            | 格式                          | 内容                                                         |
| :------------------ | :---------------------------- | :----------------------------------------------------------- |
| ~/.hermes/state.db  | SQLite 数据库 + FTS5 全文索引 | 结构化元数据、完整消息历史（含工具调用和结果）、Token 用量、时间戳 |
| ~/.hermes/sessions/ | JSONL 转录文件                | 原始对话转录，包含工具调用记录                               |

##### Session 在 SQLite 中如何组织

`state.db` 是 Session 的**结构化索引与运行状态存储**：它让 Hermes 不必每次从 JSONL 文件顺序扫描全部历史，就可以按会话、时间、来源或关键词快速定位需要的记录。JSONL 更接近可追加的原始转录；SQLite 则承担查询、关联、排序和恢复运行状态的职责。二者保存的是同一段会话历史的不同视图，不能只把 SQLite 理解为一个“聊天记录文件”。

从逻辑数据模型看，可将数据库中的内容理解为以下几类记录（表名和字段会随 Hermes 版本演进，不应依赖具体表名编写业务集成）：

| 记录类型 | 关键字段 | 保存内容 | 用途 |
| :--- | :--- | :--- | :--- |
| Session 元数据 | `session_id`、来源渠道、创建/更新时间、状态、父 Session | 一段连续对话或任务运行的边界 | 恢复会话、跨平台关联、追踪 lineage |
| 消息记录 | `message_id`、`session_id`、角色、顺序、时间戳、内容 | 用户消息、助手回复、系统消息及附件引用 | 重建对话上下文与审计 |
| 工具调用记录 | 所属消息、工具名、调用参数摘要、结果、状态、耗时 | 模型发起的工具调用及返回结果 | 重放、排障和识别失败步骤 |
| 压缩与摘要记录 | 覆盖的消息范围、摘要内容、生成时间、版本 | 被上下文压缩替代的历史片段 | 控制上下文长度，同时保留可追溯关系 |
| 用量与运行状态 | 模型、Token 用量、错误、重试、检查点 | 一次或多次 Agent loop 的执行信息 | 成本统计、恢复与诊断 |

典型写入过程如下：

```text
收到平台消息
  → 定位或创建 session_id
  → 追加原始 JSONL 转录
  → 在 SQLite 写入 Session 元数据与消息记录
  → 模型调用及工具执行后，追加结果、用量和状态
  → 需要压缩时，写入摘要及其覆盖的消息范围
  → 为可检索文本更新 FTS5 索引
```

恢复一个 Session 时，Hermes 先按 `session_id` 读取元数据和最近的消息/摘要，再根据上下文窗口选择保留原文、载入压缩摘要，或通过全文检索补回较早的相关片段。这样既避免把无限历史全部塞回 Prompt，也保证旧记录仍可被精确追溯。

SQLite 的事务能力使“消息内容、工具结果、状态更新”能够以一致的顺序落盘；如果进程在中途退出，恢复逻辑可根据最后成功写入的记录、任务状态与原始 JSONL 转录判断应继续、重试还是重新执行。对于有副作用的工具调用，还应依赖幂等标识或外部执行状态确认，不能仅凭重新读取 Session 就重复调用。

##### session_search 工具

Agent 内置 `session_search` 工具，可以在所有历史对话中执行全文检索。

整个过程无需 LLM 参与搜索阶段，直接由 SQLite FTS5 引擎完成：

工作流程：

1. FTS5 按相关性排序检索匹配消息
2. 按会话分组，取最相关的若干会话（默认 3 个）
3. 加载各会话对话，截取匹配点附近约 10 万字符
4. 用轻量摘要模型生成聚焦摘要
5. 返回各会话的摘要与上下文给 Agent

#### Honcho 用户建模

Honcho 是由 Plastic Labs 开发的 AI 原生记忆后端，以插件形式集成到 Hermes 中。

它不替换 MEMORY.md 和 USER.md，而是在它们之上增加辩证推理层——通过分析你的对话模式，自动推导你未曾明确表达的偏好、目标和习惯。



https://github.com/plastic-labs/honcho 可以详细了解下，了解其功能

### 2.2 Skills

Hermes 的 Skills 更接近**按需加载的知识文档 / workflow 文档**，并且和 `agentskills.io` 口径兼容。

它们的特点：

- 存放在 `~/.hermes/skills/`
- 采用渐进加载，尽量减少 token 浪费
- 可以来自内置 skills、Hub 安装 skills、agent 自生成 skills、插件附带 skills

这也是 Hermes 与很多 Agent 项目差异最大的一点：Skill 不只是手工编写资产，还会进入“从经验生成并持续改进”的闭环。

### 2.3 Tools

Tools 是 Hermes 的原子能力层，覆盖：

- 终端与代码执行
- 文件系统
- 浏览器 / Web
- 会话搜索
- Memory
- 任务委派
- MCP 工具接入

Hermes 的很多优势来自“工具足够多、足够实用、而且可组合”。

### 2.4 Gateway

Gateway 是 Hermes 的长运行消息接入层。

作用主要有：

- 统一接 Telegram、Discord、Slack、WhatsApp、Signal 等平台
- 保持跨平台会话连续性
- 给 cron、通知、异步执行提供长期运行通道

如果说 CLI 是“本地驾驶舱”，那 Gateway 更像“长期在线的多平台总入口”。

### 2.5 Plugins 与 MCP

Hermes 允许通过插件和 MCP 扩展能力：

- **Plugins**：扩展 tools、hooks、CLI 命令、provider、gateway 平台等
- **MCP**：把外部工具能力接入到 Hermes 的工具体系中

官方当前也强调：插件默认不会自动启用，发现到的插件需要显式加入 `plugins.enabled` 或通过 CLI 显式启用后才真正加载。

## 3关键原理

### 3.1 自我改进闭环

Hermes 最有代表性的特征不是“会用工具”，而是“会从经验中生成与改进 Skill”。

可以粗略理解为：

```text
任务执行
  ↓
识别可复用模式
  ↓
生成或改写 Skill
  ↓
后续任务按需加载该 Skill
  ↓
继续在使用中修正
```

这使 Hermes 更像一个**会不断积累工作方法的 Agent**。

### 3.2 长上下文控制

Hermes 为了避免长对话越来越贵，采用了两类机制：

1. **Context Compression**：把中间轮次总结压缩
2. **Prompt Caching**：在支持的模型路径上做前缀缓存

这套设计的目标不是“绝不丢信息”，而是在**可用性、记忆延续和成本**之间做平衡。

### 3.3 委派与并行

Hermes 提供任务委派能力，可以把复杂任务拆给隔离子 Agent。

子 Agent 通常具备：

- 新会话
- 自己的 task_id
- 受限工具集
- 聚焦后的系统提示

这样做的价值在于：

- 降低单线程上下文污染
- 让复杂任务并行
- 把主 Agent 保持在更高层的调度位置

### 3.4 Session 为中心的数据组织

Hermes 很多能力都建立在 Session 之上：

- 消息历史
- 工具调用历史
- 平台来源标记
- 压缩分裂后的 lineage
- FTS5 检索

这也是为什么 Hermes 的数据组织更像“以 session 为中心的 Agent runtime”，而不是“只保存一份聊天记录”。

这使 Hermes 的“跨会话记忆”并不是抽象口号，而是和底层 session storage 深度绑定。

## 4 与 OpenClaw 的对比理解

如果参考你前面整理的 OpenClaw 方式，可以这样理解：

| 维度 | OpenClaw | Hermes |
| :--- | :--- | :--- |
| 核心气质 | 多渠道 Agent 运行时 + 结构化认知文件系统 | 长驻自进化 Agent + 工具密度 + Skill 学习闭环 |
| Skill 定义 | 当前仓库文档中存在“业务能力抽象”和官网 `SKILL.md` 口径差异 | 官方当前更明确是 `~/.hermes/skills/` 下的按需知识文档，并兼容 `agentskills.io` 口径 |
| 长对话处理 | 记忆分层 + 混合检索 | Session + 压缩 + Prompt Cache |
| 并行能力 | 可通过协议/框架扩展 | 内置委派子 Agent 思路更突出 |
| 扩展体系 | Plugin / Tool / Channel / Provider | Plugins + MCP + Tools + Gateway 平台 |

简化一句话：

- **OpenClaw** 更像“可扩展的多渠道 Agent 平台”
- **Hermes** 更像“长期在线、会成长、会沉淀工作方法的个人 Agent”

## 7 参考

- https://hermes-agent.nousresearch.com/docs/
- https://hermes-agent.nousresearch.com/docs/developer-guide/architecture/
- https://hermes-agent.nousresearch.com/docs/developer-guide/agent-loop/
- https://hermes-agent.nousresearch.com/docs/developer-guide/context-compression-and-caching/
- https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/
- https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins/
- https://hermes-agent.nousresearch.com/docs/user-guide/features/honcho/
- https://hermes-agent.nousresearch.com/docs/developer-guide/session-storage/
- https://github.com/NousResearch/hermes-agent/blob/main/README.zh-CN.md
- https://www.runoob.com/hermes-agent/hermes-agent-memory.html
