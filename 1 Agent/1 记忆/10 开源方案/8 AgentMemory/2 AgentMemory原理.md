# AgentMemory 原理

[AgentMemory](https://github.com/rohitg00/agentmemory) 的价值不在于“保存聊天记录”，而在于将可复用信息以独立于当前上下文窗口的形式保存，并在 Agent 决策时按需取回。本页用 Agent Memory 的通用实现框架解释应关注的内部机制。

## 1 系统架构

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Agent Layer                            │
│  Claude Code  │  Cursor  │  Codex CLI  │  OpenClaw  │  ...  │
└─────────────────────────────────────────────────────────────┘
         │              │              │              │
         │   hooks      │   MCP        │   REST       │
         └──────────────┴──────────────┴──────────────┘
                           │
                    ┌──────▼──────┐
                    │  Memory     │
                    │  Server     │
                    │  (:3111)    │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
        │ Capture   │ │ Store │ │ Retrieve  │
        │ Engine    │ │ Layer │ │ Engine    │
        └─────┬─────┘ └───┬───┘ └─────┬─────┘
              │            │            │
              └────────────┼────────────┘
                           │
                    ┌──────▼──────┐
                    │  iii Engine │
                    │  (:49134)   │
                    └──────┬──────┘
                           │
                    ┌──────▼──────────┐
                    │  Local Disk     │
                    │  ~/.agentmemory │
                    └─────────────────┘
```

### 1.2 核心组件

####  Capture Engine（捕获引擎）

**职责**：监听 agent 生命周期事件，提取 observation。

**实现方式**：

- Claude Code：12 个 hook（session create/idle/status/compaction, message.updated, tool use, file edited, etc.）
- OpenCode：22 个 hook（覆盖 Claude Code 的 12 类 hook 类型）
- 其他 agent：MCP 协议或 REST API

**数据流**：

```
Agent Event → Hook/MCP → Observation Payload → Capture Engine
```

**Observation 结构**（推测）：

```json
{
  "timestamp": "2026-07-29T01:45:00Z",
  "agent": "claude-code",
  "session_id": "sess_abc",
  "event_type": "tool_use",
  "tool_name": "edit_file",
  "content": "修改了 src/auth.ts，将 jose 替换为 jsonwebtoken",
  "context": {
    "file": "src/auth.ts",
    "project": "my-app"
  },
  "metadata": {
    "confidence": 0.95,
    "importance": "high"
  }
}
```

---

#### Store Layer（存储层）

**职责**：将 observation 压缩、结构化、分层存储。

**四层记忆模型**：

| 层级                  | 说明                 | 存储形式        | 生命周期             |
| --------------------- | -------------------- | --------------- | -------------------- |
| **Working Memory**    | 近期可直接用的上下文 | 内存 + 临时索引 | 当前 session         |
| **Episodic Memory**   | 具体发生的事件       | 时间戳序列      | 衰减（Ebbinghaus）   |
| **Semantic Memory**   | 抽象出的事实知识     | 实体-关系图     | 稳定，可被新版本覆盖 |
| **Procedural Memory** | 可复用的做法和流程   | 模式/模板       | 长期保留             |

**压缩策略**：

- **去重**：Jaccard-based 版本/覆盖关系
- **摘要**：LLM 生成更丰富的摘要（可选，需 API Key）
- **分层**：根据重要性和时效性自动分配到不同层级

**存储引擎**：

- **iii Engine**：底层持久化引擎（v0.11.2）
- **SQLite**：结构化存储
- **本地 Embedding**：`all-MiniLM-L6-v2`（免费，无需 API Key）

---

####  Retrieve Engine（检索引擎）

**职责**：根据当前上下文，精准召回相关记忆。

**混合检索策略**：

```
Query → ┌─────────────┐
        │ BM25        │ → 关键词匹配（文件名、函数名、错误码）
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │ Vector      │ → 语义相似度（"数据库优化" → "N+1 query fix"）
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │ Graph       │ → 实体关系遍历（多跳推理）
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │ RRF Fusion  │ → 综合排序（Reciprocal Rank Fusion）
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │ Top-K       │ → 返回最相关的 K 条记忆
        └─────────────┘
```

**检索时机**：

1. **会话开始时**：注入与当前项目/任务相关的记忆摘要
2. **工具调用前**：注入与当前操作相关的历史经验
3. **用户提问时**：注入与问题相关的上下文

**检索精度优化**：

- **显式查询规划**：先理解用户意图，再构造检索查询
- **时间衰减**：近期记忆权重更高
- **置信度过滤**：低置信度记忆不参与检索
- **隐私过滤**：入库前剥离 secrets，避免泄露

---

#### Inject Layer（注入层）

**职责**：将检索结果注入 agent 上下文。

**注入方式**：

| 方式               | 说明                                   | 适用场景   |
| ------------------ | -------------------------------------- | ---------- |
| **System Context** | 注入到系统 prompt                      | 会话开始时 |
| **Tool Context**   | 注入到工具调用参数                     | 工具执行前 |
| **Enrichment**     | 通过 `system.transform` 动态修改上下文 | 实时注入   |

**注入策略**：

- **Token 预算**：控制注入的记忆量，避免超出上下文窗口
- **相关性排序**：优先注入最相关的记忆
- **去重**：避免重复注入相同信息

---

### 1.3 数据流全景

```
┌─────────────────────────────────────────────────────────────────┐
│                        完整数据流                                 │
└─────────────────────────────────────────────────────────────────┘

1. 捕获阶段
   Agent Event → Hook/MCP → Observation → Capture Engine

2. 存储阶段
   Observation → Compress → Deduplicate → Layer Assignment → Store

3. 检索阶段
   Query → BM25 + Vector + Graph → RRF Fusion → Top-K Results

4. 注入阶段
   Top-K Results → Token Budget → System/Tool Context → Agent

5. 维护阶段
   Decay → Forget → Consolidate → Update
```

---

## 2 关键技术细节

### 2.1 Hook 机制

#### Claude Code Hook 类型

| Hook                  | 触发时机   | 用途         |
| --------------------- | ---------- | ------------ |
| `session.create`      | 新会话开始 | 注入历史记忆 |
| `session.idle`        | 会话空闲   | 整理记忆     |
| `session.status`      | 状态变更   | 更新工作记忆 |
| `session.compact`     | 上下文压缩 | 提取关键信息 |
| `message.updated`     | 消息更新   | 捕获对话内容 |
| `tool.execute.before` | 工具执行前 | 注入相关记忆 |
| `tool.execute.after`  | 工具执行后 | 捕获执行结果 |
| `file.edited`         | 文件编辑   | 捕获代码变更 |
| `task.updated`        | 任务更新   | 捕获任务进展 |
| `command.executed`    | 命令执行   | 捕获命令输出 |
| `config.updated`      | 配置变更   | 捕获配置变化 |
| `error`               | 错误发生   | 捕获错误信息 |

#### Hook 数据流示例

```
用户输入："帮我修一下 auth 模块的 bug"
    ↓
[session.status] 触发
    ↓
Capture Engine 提取 observation：
{
  "event": "user_query",
  "content": "帮我修一下 auth 模块的 bug",
  "context": {"module": "auth"}
}
    ↓
Retrieve Engine 检索相关记忆：
- "昨天修了 auth 模块的 JWT 验证 bug"
- "项目用 jose 做 JWT，不用 jsonwebtoken"
- "auth.ts 在 src/middleware/auth.ts"
    ↓
Inject Layer 注入上下文：
{
  "system_context": "用户之前修过 auth 模块的 bug，项目用 jose 做 JWT...",
  "tool_context": "相关文件：src/middleware/auth.ts"
}
    ↓
Agent 看到注入的记忆，直接开始修复，无需用户重复解释
```

---

### 2.2 混合检索实现

#### BM25 关键词检索

**适用场景**：精确匹配文件名、函数名、错误码、技术术语。

**实现**：

```
Query: "src/auth.ts"
    ↓
BM25 Score = Σ (IDF(term) × TF(term, doc) × (k1 + 1) / (TF + k1 × (1 - b + b × doc_len / avg_len)))
    ↓
Top-K Documents
```

**优点**：精确匹配，速度快
**缺点**：无法处理语义相似但字面不同的查询

---

#### Vector 语义检索

**适用场景**：语义相似但字面不同的查询。

**实现**：

```
Query: "数据库性能优化"
    ↓
Embedding Model (all-MiniLM-L6-v2) → Query Vector [0.12, -0.34, ...]
    ↓
Cosine Similarity with Stored Vectors
    ↓
Top-K Documents (包括 "N+1 query fix")
```

**优点**：语义理解能力强
**缺点**：需要 embedding 模型，计算成本较高

---

#### Graph 图谱检索

**适用场景**：实体关系、多跳推理。

**实现**：

```
Query: "为什么选 jose 而不是 jsonwebtoken"
    ↓
Entity Extraction: ["jose", "jsonwebtoken", "JWT"]
    ↓
Graph Traversal (BFS/DFS):
- jose → Edge("used_for") → JWT
- jsonwebtoken → Edge("not_used_because") → "Edge compatibility"
    ↓
Multi-hop Reasoning: "选择 jose 是因为 Edge 兼容性"
```

**优点**：支持多跳推理，理解实体关系
**缺点**：需要构建知识图谱，复杂度高

---

#### RRF 融合排序

**Reciprocal Rank Fusion** 公式：

```
RRF_score(d) = Σ (1 / (k + rank_i(d)))
```

其中：

- `d` 是文档
- `k` 是常数（通常 60）
- `rank_i(d)` 是文档在第 i 个检索器中的排名

---

### 2.3 四层记忆模型

#### Working Memory（工作记忆）

**特点**：

- 短期、易变
- 当前 session 的上下文
- 高频访问，低延迟

**实现**：

- 内存缓存
- 临时索引
- Session 结束后清理或降级到 Episodic Memory

**示例**：

```
当前正在修改 src/auth.ts
Working Memory: {
  "file": "src/auth.ts",
  "recent_changes": ["line 42: 修改了 JWT 验证逻辑"],
  "context": "用户要求修复 auth 模块的 bug"
}
```

---

#### Episodic Memory（情景记忆）

**特点**：

- 时间戳序列
- 具体发生的事件
- 随时间衰减

**实现**：

- 时间戳索引
- Ebbinghaus 遗忘曲线：`Retention = e^(-t/S)`
  - `t` 是时间
  - `S` 是记忆强度

**示例**：

```
Episodic Memory: [
  {
    "timestamp": "2026-07-28T10:00:00Z",
    "event": "修复了 auth 模块的 JWT 验证 bug",
    "details": "将 jose 替换为 jsonwebtoken，因为 Edge 兼容性",
    "strength": 0.8
  },
  {
    "timestamp": "2026-07-27T15:00:00Z",
    "event": "重构了 user 模块",
    "details": "将 class 组件改为 function 组件",
    "strength": 0.6
  }
]
```

---

#### Semantic Memory（语义记忆）

**特点**：

- 抽象出的事实知识
- 稳定，可被新版本覆盖
- 实体-关系图

**实现**：

- 知识图谱（实体 + 关系 + 属性）
- Jaccard-based 版本控制
- 冲突解决（新版本覆盖旧版本）

**示例**：

```
Semantic Memory:
{
  "entities": [
    {"id": "jose", "type": "library", "purpose": "JWT"},
    {"id": "jsonwebtoken", "type": "library", "purpose": "JWT"},
    {"id": "edge_compatibility", "type": "reason"}
  ],
  "relations": [
    {"from": "project", "to": "jose", "type": "uses"},
    {"from": "project", "to": "jsonwebtoken", "type": "not_uses"},
    {"from": "jose", "to": "edge_compatibility", "type": "chosen_because"}
  ]
}
```

---

#### Procedural Memory（程序记忆）

**特点**：

- 可复用的做法和流程
- 长期保留
- 模式/模板

**实现**：

- 模式匹配
- 模板库
- 最佳实践库

**示例**：

```
Procedural Memory:
{
  "pattern": "部署前检查清单",
  "steps": [
    "1. 运行 lint: npm run lint",
    "2. 运行测试: npm test",
    "3. 构建: npm run build",
    "4. 检查环境变量",
    "5. 部署到 staging",
    "6. 验证功能",
    "7. 部署到 production"
  ],
  "confidence": 0.95,
  "usage_count": 12
}
```

---

### 2.4 生命周期管理

#### 衰减（Decay）

**Ebbinghaus 遗忘曲线**：

```
Retention(t) = e^(-t/S)
```

其中：

- `t` 是时间（自上次访问）
- `S` 是记忆强度（基于访问频率和重要性）

**实现**：

- 每次访问增加记忆强度 `S`
- 长时间不访问的记忆强度衰减
- 强度低于阈值的记忆被遗忘

---

#### 去重（Deduplication）

**Jaccard Similarity**：

```
J(A, B) = |A ∩ B| / |A ∪ B|
```

**实现**：

- 新记忆与已有记忆计算 Jaccard 相似度
- 相似度高于阈值（如 0.8）的记忆被合并
- 保留最新版本，旧版本标记为 superseded

---

#### 遗忘（Forgetting）

**触发条件**：

- 记忆强度低于阈值
- 记忆被新版本覆盖
- 用户显式调用 `mem::forget`

**实现**：

- 软删除（标记为 deleted，保留审计日志）
- 硬删除（物理删除，不可恢复）

---

#### 整合（Consolidation）

**触发条件**：

- 定期整合（如每天一次）
- 记忆数量超过阈值
- 用户显式调用 `consolidate`

**实现**：

- 将多条 Episodic Memory 整合为一条 Semantic Memory
- 提取共同模式，形成 Procedural Memory
- 压缩冗余信息，保留关键事实

**示例**：

```
Episodic Memories:
- "2026-07-25: 修复了 auth 模块的 bug"
- "2026-07-26: 修复了 auth 模块的另一个 bug"
- "2026-07-27: 重构了 auth 模块"
    ↓ Consolidation
Semantic Memory:
- "auth 模块在 2026-07-25 到 2026-07-27 期间进行了多次修复和重构"
- "auth 模块使用 jose 做 JWT 验证"
```

---

### 2.5 多代理协调

#### Leases（租约）

**用途**：防止多个 agent 同时修改同一条记忆。

**实现**：

```
Agent A 想要修改 Memory X
    ↓
请求租约：POST /agentmemory/lease
{
  "memory_id": "X",
  "agent_id": "A",
  "duration": 60  // 60 秒
}
    ↓
如果租约成功，Agent A 独占修改权
如果租约失败（已被其他 agent 占用），等待或重试
```

---

#### Signals（信号）

**用途**：agent 之间传递事件通知。

**实现**：

```
Agent A 修改了 Memory X
    ↓
发送信号：POST /agentmemory/signal
{
  "type": "memory_updated",
  "memory_id": "X",
  "agent_id": "A"
}
    ↓
其他 agent 收到信号，更新本地缓存
```

---

#### Mesh（网格）

**用途**：跨 agent 共享记忆。

**实现**：

```
Agent A (Claude Code) 和 Agent B (Cursor) 共享同一个 memory server
    ↓
Agent A 修改了 Memory X
    ↓
Agent B 通过 REST API 或 MCP 访问 Memory X
    ↓
两个 agent 看到相同的记忆状态
```

---

## 3 性能优化

### 3.1 检索延迟优化

| 优化策略           | 说明                                        |
| ------------------ | ------------------------------------------- |
| **本地 Embedding** | `all-MiniLM-L6-v2` 在本地运行，无需网络请求 |
| **索引缓存**       | 常用查询的检索结果缓存到内存                |
| **增量索引**       | 新记忆只索引增量部分，不全量重建            |
| **异步检索**       | 非关键检索异步执行，不阻塞主流程            |

### 3.2 Token 节省优化

| 优化策略       | 说明                                 |
| -------------- | ------------------------------------ |
| **Token 预算** | 控制注入的记忆量，避免超出上下文窗口 |
| **相关性过滤** | 只注入高相关性的记忆                 |
| **去重**       | 避免重复注入相同信息                 |
| **压缩**       | 将多条记忆压缩为一条摘要             |

### 3.3 存储优化

| 优化策略     | 说明                                         |
| ------------ | -------------------------------------------- |
| **分层存储** | 热数据（Working Memory）存内存，冷数据存磁盘 |
| **压缩存储** | 使用 SQLite 压缩存储                         |
| **定期清理** | 清理过期的临时索引和缓存                     |

---

## 4 安全与隐私

### 4.1 隐私过滤

**入库前过滤**：

- 自动检测并剥离 API Key、Token、Password 等敏感信息
- 正则匹配 + 启发式规则

**示例**：

```
原始内容："使用 API Key sk-xxxx 调用 OpenAI API"
    ↓ 隐私过滤
存储内容："使用 API Key [REDACTED] 调用 OpenAI API"
```

---

### 4.2 访问控制

**本地模式**：

- 默认 localhost 开放访问
- 可设置 `AGENTMEMORY_SECRET` 启用 Bearer Token 认证

**企业模式**（Roadmap Q4 2026）：

- SSO 网关（OIDC）
- RBAC（基于角色的访问控制）
- 审计日志导出

---

### 4.3 审计日志

**记录内容**：

- 所有记忆的创建、修改、删除操作
- 操作者（agent_id）
- 时间戳
- 操作详情

**用途**：

- 追溯记忆变更历史
- 合规审计
- 故障排查

---
