# AgentMemory：安装、使用与记忆管理
## 1 介绍

[AgentMemory](https://github.com/rohitg00/agentmemory) 是一个面向 Agent 记忆管理的开源项目。它让 Claude Code、Cursor、Codex CLI、Gemini CLI、OpenClaw 等代理在跨会话、跨工具协作时能够"记住"之前做过的事情，避免每次都重新解释项目架构、技术选型、历史 bug 和个人偏好。

### 1.2 核心定位

| 维度         | 说明                          |
| ------------ | ----------------------------- |
| **类型**     | Memory engine + MCP server    |
| **部署方式** | 本地自托管，零外部依赖        |
| **底层引擎** | iii engine（v0.11.2）         |
| **存储**     | 本地磁盘，SQLite + iii-engine |


### 1.3 核心功能
#### 1.3.1 自动记忆捕获
通过 12 个生命周期 hook 自动采集代理行为，无需手动调用 `add()`：

- Session 创建 / 空闲 / 状态变更 / 压缩
- 消息更新（用户 + 助手）
- 工具调用前后
- 文件编辑 / patch / 推理
- 任务跟踪
- 命令执行
- 配置 / 模型追踪

#### 1.3.2 混合检索

采用多路召回 + 融合排序：

| 检索方式         | 适用场景                           |
| ---------------- | ---------------------------------- |
| **BM25 关键词**  | 文件名、函数名、错误码、精确术语   |
| **向量语义检索** | "数据库性能优化" → "N+1 query fix" |
| **图谱遍历**     | 实体关系、多跳推理                 |
| **RRF 融合**     | 综合排序，兼顾精度和召回           |

#### 1.3.3 四层记忆整合

| 层级                  | 说明                 | 示例                       |
| --------------------- | -------------------- | -------------------------- |
| **Working Memory**    | 近期可直接用的上下文 | 当前 session 的修改        |
| **Episodic Memory**   | 具体发生的事件       | "昨天修了 auth 模块的 bug" |
| **Semantic Memory**   | 抽象出的事实知识     | "项目用 jose 做 JWT"       |
| **Procedural Memory** | 可复用的做法和流程   | "部署前要先跑 lint"        |

#### 1.3.4 记忆生命周期管理

- **衰减（Decay）**：基于 Ebbinghaus 遗忘曲线
- **去重**：Jaccard-based 版本/覆盖关系
- **自动遗忘**：过时信息自动淘汰
- **隐私过滤**：入库前自动剥离 secrets（API key、token 等）

#### 1.3.5 跨代理共享

一个 memory server，所有 agent 共享同一份记忆：

| Agent                                           | 接入方式                       |
| ----------------------------------------------- | ------------------------------ |
| Claude Code                                     | native plugin + 12 hooks + MCP |
| Codex CLI                                       | native plugin + 6 hooks + MCP  |
| GitHub Copilot CLI                              | MCP + plugin hooks/skills      |
| Cursor                                          | MCP server                     |
| Gemini CLI                                      | MCP server                     |
| OpenClaw                                        | native plugin + MCP            |
| OpenCode                                        | 22 hooks + MCP + plugin        |
| Cline / Goose / Kilo Code / Windsurf / Roo Code | MCP server                     |
| Aider                                           | REST API                       |

### 1.4 实时可视化

- **Viewer**：`http://localhost:3113`，实时查看记忆的采集、整理、检索过程
- **iii Console**：引擎级别的调试和管理

---

## 2 安装&使用
### 2.1 前置条件

- Node.js >= 20 和 npm
- macOS 或 Linux（Windows 需使用 WSL2）
- 端口 3111（REST）、3112（streams）、3113（viewer）、49134（engine）可用

> 注意：依赖iii软件，启动时需要下载（https://github.com/iii-hq/iii/releases）
### 2.2 全局安装
**npm安装**
```bash
npm install -g @agentmemory/agentmemory

agentmemory --version
```
**docker安装**
```bash
docker run -d \
  --name agentmemory \
  --restart unless-stopped \
  -p 3111:3111 \
  -p 3112:3112 \
  -p 3113:3113 \
  -v ~/.agentmemory:/root/.agentmemory \
  node:22 \
  bash -c "npm install -g @agentmemory/agentmemory && agentmemory"

```

### 2.3 基本使用
#### 2.3.1 启动服务

```bash
agentmemory
```

服务启动后：

- REST API：`http://localhost:3111`
- Viewer：`http://localhost:3113`

验证服务是否就绪：

```bash
curl -fsS http://localhost:3111/agentmemory/livez
# 期望：200
```

#### 2.3.2 快速演示

```bash
agentmemory demo --serve
```

一条命令完成：启动服务 → 注入 3 个示例 session → 语义搜索验证 → 关闭服务。


#### 2.3.3 接入 Agent

```bash
agentmemory connect claude-code
agentmemory connect cursor        # Cursor
agentmemory connect codex         # Codex CLI
agentmemory connect copilot-cli   # GitHub Copilot CLI
agentmemory connect gemini-cli    # Gemini CLI
agentmemory connect openclaw      # OpenClaw
agentmemory connect opencode      # OpenCode
```

#### 2.3.4 安装原生技能

```bash
npx skills add rohitg00/agentmemory -y
```

安装 15 个原生技能（8 个可调用 + 7 个参考），让 agent 知道**何时**使用记忆工具。

#### 2.3.5 自定义数据目录

```bash
agentmemory --data-dir ~/.agentmemory-projects/main

# 或通过环境变量
AGENTMEMORY_DATA_DIR=~/.agentmemory-projects/main agentmemory
```

### 2.4 高级配置

在 `~/.agentmemory/.env` 中配置（不需要 `export` 前缀），然后重启服务：

```env
# 自动注入历史记忆到 agent 上下文（消耗 token）
AGENTMEMORY_INJECT_CONTEXT=true

# 使用 LLM 生成更丰富的摘要（消耗 API token）
AGENTMEMORY_AUTO_COMPRESS=true

# LLM Provider Key（三选一）
ANTHROPIC_API_KEY=sk-xxx
OPENAI_API_KEY=sk-xxx
GEMINI_API_KEY=xxx
```

> 不配置 Provider Key 时，agentmemory 使用零 LLM 模式，通过 BM25 + 本地 embedding 完成索引和召回。

### 2.5 工具集选择

```bash
agentmemory --tools all     # 默认 53 个工具
agentmemory --tools core    # 精简 8 个核心工具
```

核心 8 个工具覆盖：save、recall、consolidate、smart search、sessions、diagnose、lesson save、reflect。

### 2.6 安全配置

如果设置了 `AGENTMEMORY_SECRET`，REST API 需要 Bearer Token：

```bash
curl -H "Authorization: Bearer $AGENTMEMORY_SECRET" \
  http://localhost:3111/agentmemory/health
```

默认不设置，localhost 开放访问。

---

### 2.7 生命周期管理命令

| 命令                              | 说明                               |
| --------------------------------- | ---------------------------------- |
| `agentmemory status`              | 查看服务和引擎状态                 |
| `agentmemory doctor`              | 运行诊断，报告配置问题             |
| `agentmemory stop`                | 停止引擎                           |
| `agentmemory stop --force`        | 强制停止（绕过 Docker 保护）       |
| `agentmemory upgrade`             | 升级 agentmemory 和 iii 运行时     |
| `agentmemory --reset`             | 重置偏好，重新运行配置向导         |
| `agentmemory import-jsonl <file>` | 导入 Claude Code 历史 session 日志 |

---

## 3 REST API 快速参考

### 健康检查

```bash
curl http://localhost:3111/agentmemory/livez
curl http://localhost:3111/agentmemory/health
```

### 保存记忆

```bash
curl -X POST http://localhost:3111/agentmemory/remember \
  -H "Content-Type: application/json" \
  -d '{"content":"项目使用 jose 做 JWT 认证","concepts":["auth","jwt","jose"]}'
```
响应
```json
{"memory":{"concepts":["auth","jwt","jose"],"content":"项目使用 jose 做 JWT 认证","createdAt":"2026-07-29T12:28:30.519Z","files":[],"id":"mem_ms629eig_34a8c4cc7123","isLatest":true,"parentId":"mem_ms5jypth_f0e3ba4b1365","sessionIds":[],"sourceObservationIds":[],"strength":7,"supersedes":["mem_ms5jypth_f0e3ba4b1365"],"title":"项目使用 jose 做 JWT 认证","type":"fact","updatedAt":"2026-07-29T12:28:30.519Z","version":2},"success":true}
```

### 语义搜索

```bash
curl -X POST http://localhost:3111/agentmemory/smart-search \
  -H "Content-Type: application/json" \
  -d '{"query":"认证方案选型","limit":5}'
```

响应
```json
{"lessons":[],"mode":"compact","results":[{"obsId":"mem_ms5jypth_f0e3ba4b1365","score":0.01639344262295082,"sessionId":"memory","timestamp":"2026-07-29T03:56:18.868Z","title":"项目使用 jose 做 JWT 认证","type":"decision"},{"obsId":"mem_ms629eig_34a8c4cc7123","score":0.016129032258064516,"sessionId":"memory","timestamp":"2026-07-29T12:28:30.519Z","title":"项目使用 jose 做 JWT 认证","type":"decision"}]}
```

## 4 接口
### 4.1 保存长期记忆：`POST /agentmemory/remember`

 **请求体字段**

| 字段                 | 类型     | 必填 | 说明                                                   |
| -------------------- | -------- | ---- | ------------------------------------------------------ |
| content              | string   | 是   | 记忆正文，不能为空字符串。前 80 个字符自动生成 title   |
| type                 | string   | 否   | 记忆类型，枚举值见下方，非法值回退为 "fact"            |
| concepts             | string[] | 否   | 概念标签数组，必须是数组                               |
| files                | string[] | 否   | 关联文件路径数组，必须是数组                           |
| ttlDays              | number   | 否   | 自动过期天数，正数，到期后自动删除（设置 forgetAfter） |
| sourceObservationIds | string[] | 否   | 来源观察 ID 数组，必须是 string 数组，过滤掉非字符串项 |
| project              | string   | 否   | 项目作用域，非空字符串，用于隔离不同项目的记忆         |

**type枚举值**

| 值           | 含义          |
| ------------ | ------------- |
| fact         | 事实          |
| pattern      | 代码/行为模式 |
| preference   | 用户/团队偏好 |
| architecture | 架构决策      |
| bug          | 缺陷记录      |
| workflow     | 工作流程      |

  保存时会扫描全部 isLatest=true 的记忆，用 Jaccard 相似度（词级别集合交并比）比较 content：

  - 词长 ≤ 2 的词被过滤掉，只对长词做集合比较
  - 相似度 > 0.7 时，新记忆替代旧记忆（旧记忆标记 isLatest=false，并触发 cascade-update）
  - 若有 project，只和同 project 的记忆比较

**响应字段**

| 字段        | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| id          | 格式 mem_<时间戳base36>_<uuid前12位>                         |
| title       | content 的前 80 个字符，自动截取                             |
| strength    | 初始强度固定为 7（经 consolidation 衰减后变化）              |
| version     | 若替代了旧记忆，则为 旧版本 + 1，否则为 1                    |
| parentId    | 被替代的旧记忆 ID，无替代时为 null                           |
| supersedes  | 被替代的旧记忆 ID 列表，无替代时为 []                        |
| isLatest    | 始终为 true（旧版本被标记为 false）                          |
| sessionIds  | 保存时为空数组 []，后续 consolidation 可能填入               |
| agentId     | 取自请求中的 agentId，或环境变量 AGENTMEMORY_AGENT_ID，最长 128 字符 |
| forgetAfter | 仅在传了 ttlDays 时出现，ISO 时间字符串                      |
| project     | 仅在传了 project 时出现                                      |

```json
// 请求报文
{
    "content": "string (必填)",
    "type": "fact | pattern | preference | architecture | bug | workflow (可选，默认 fact)",
    "concepts": ["string", "..."] ,
    "files": ["path/to/file"],
    "ttlDays": 30,
    "sourceObservationIds": ["obs-id-1"],
    "project": "my-project"
  }

// 响应报文
  {
    "success": true,
    "memory": {
      "id": "mem-xxx",
      "type": "fact",
      "title": "...",
      "content": "...",
      "concepts": [],
      "files": [],
      "sessionIds": [],
      "strength": 1.0,
      "version": 1,
      "parentId": null,
      "supersedes": [],
      "sourceObservationIds": [],
      "isLatest": true,
      "agentId": "...",
      "project": "...",
      "createdAt": "2026-01-01T00:00:00Z",
      "updatedAt": "2026-01-01T00:00:00Z"
    }
  }

```

### 4.2 搜索记忆 /agentmemory/search

**请求体字段**

| 字段         | 类型    | 必填 | 校验规则                                              | 说明                          |
| ------------ | ------- | ---- | ----------------------------------------------------- | ----------------------------- |
| query        | string  | 必填 | 非空字符串，自动 trim                                 | 检索词，检索前自动去首尾空白  |
| limit        | integer | 可选 | 正整数，上限强制截为 100，默认 20                     | 返回结果数量                  |
| format       | string  | 可选 | `"full"` / `"compact"` / `"narrative"`，默认 `"full"` | 响应格式，见下方说明          |
| project      | string  | 可选 | 非空字符串                                            | 仅返回属于该 project 的结果   |
| cwd          | string  | 可选 | 非空字符串                                            | 仅返回 session.cwd 匹配的结果 |
| token_budget | integer | 可选 | 正整数                                                | token 预算，超出后截断结果集  |
| agentId      | string  | 可选 | 非空字符串，`"*"` 表示不过滤                          | 过滤归属 agent，* 读全部      |

**响应字段：**

| 字段          | 类型               | 所有 format 均有 | 说明                                              |
| ------------- | ------------------ | ---------------- | ------------------------------------------------- |
| format        | string             | ✓                | 实际使用的格式                                    |
| results       | array              | ✓                | 结果数组                                          |
| tokens_used   | integer            | ✓                | 本次响应估算 token 数（JSON 字节数 ÷ 3）          |
| tokens_budget | integer\|undefined | ✓                | 传入的 token_budget，未传则不存在                 |
| truncated     | boolean            | ✓                | 因 token_budget 截断时为 true                     |
| text          | string             | 仅 narrative     | 所有结果拼成的纯文本，格式：`N. title\nnarrative` |

请求示例：

```json
  {
    "query": "string (必填)",
    "limit": 20,
    "project": "...",
    "cwd": "/path",
    "format": "full | compact | narrative",
    "token_budget": 4000,
    "agentId": "..."
  }
// 响应
{
    "format": "compact",
    "results": [
      {
        "obsId": "obs_lzf3abc_def456",
        "sessionId": "sess_xxx",
        "title": "Implemented JWT refresh rotation",
        "type": "tool_call",
        "score": 2.34,
        "timestamp": "2026-07-29T06:00:00.000Z"
      }
    ],
    "tokens_used": 180,
    "tokens_budget": 4000,
    "truncated": false
  }
```

### 4.3 遗忘记忆 POST /agentmemory/forget

**请求字段**

| 字段           | 类型     | 说明                                               |
| -------------- | -------- | -------------------------------------------------- |
| memoryId       | string   | 按 ID 删除单条长期记忆                             |
| sessionId      | string   | 删除整个 session 或其中的指定观察                  |
| observationIds | string[] | 配合 sessionId 使用，精确删除 session 内的某些观察 |

> sessionId 和 memoryId 至少传一个，否则返回 400。

**响应字段**

| 字段      | 类型     | 必填 | 说明                                           |
| --------- | -------- | ---- | ---------------------------------------------- |
| memoryIds | string[] | 必填 | 要删除的记忆 ID 列表，非空数组                 |
| reason    | string   | 可选 | 删除原因，写入审计日志，默认 "manual deletion" |

### 4.4 其它
| Method | Path                        | 说明                                 |
|--------|-----------------------------|--------------------------------------|
| POST   | /agentmemory/remember       | 保存记忆/洞察                         |
| POST   | /agentmemory/smart-search   | 混合语义+关键词搜索（主要检索入口）   |
| POST   | /agentmemory/search         | 基础搜索                             |
| GET    | /agentmemory/memories       | 列出记忆                             |
| GET    | /agentmemory/memories/:id   | 获取单条记忆                         |
| POST   | /agentmemory/forget         | 删除记忆                             |
| POST   | /agentmemory/observe        | 记录观察                             |
| GET    | /agentmemory/observations   | 列出观察                             |
