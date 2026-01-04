# 1 A2A Project

**A2A Project** 是一个开源社区组织，专注于 **Agent-to-Agent (A2A) 协议** 的标准化和生态建设。其核心目标是：

1. **跨语言互操作**：让不同语言、不同框架开发的 Agent 能够互相发现、调用和协作（包括a2a、a2a-python等）
2. **统一协议标准**：提供一套标准化协议（支持 JSON-RPC、gRPC、HTTP Stream 等 transport）
3. **面向多 Agent 网络的可扩展性**：支持多 Agent 协作、工作流组合，能够处理复杂的分布式 agent 系统
4. **声明式能力调用**：Agent 可以声明自身的能力 (skills / tools / APIs)，其他 agent 可自动发现并调用这些能力
   - 避免强耦合，促进 agent 自治性和可组合性

## 1.1 核心概念

- **AgentCard**
  - JSON 文档，用于描述 agent 名称、版本、endpoint、支持的 transport、能力声明、认证方式等。

- **Transport**：A2A 是 transport-agnostic 的协议：JSON-RPC（HTTP POST）、gRPC、SSE / Streaming- 

- **Interaction 模型**

  - Action Request / Response：请求执行某个能力，返回结果

  - Streaming Task：长任务流式输出

  - Artifact / 文件传输

  - 多媒体消息（图像、音频等）

- **Capabilities**：描述 Agent 能执行的功能或提供的工具、输入输出用 JSON Schema 或 proto 定义

# 2 A2A

A2A (Agent-to-Agent Protocol) 是由 Google 发起的开源协议项目，旨在解决 AI 生态系统中的关键挑战：让不同框架、不同公司开发、运行在不同服务器上的 AI Agent 能够有效地相互通信和协作——作为 Agent 而非工具。

当前最重要的是[a2a.proto](https://github.com/a2aproject/A2A/blob/main/specification/grpc/a2a.proto)文件，其中定义数据模型、A2A操作以及协议。

## 2.1 操作

| 类别       | 操作                             | 说明                                   |
| :--------- | :------------------------------- | :------------------------------------- |
| 消息发送   | SendMessage                      | 发送消息给 Agent，返回 Task 或直接响应 |
|            | SendStreamingMessage             | 流式版本，实时返回更新                 |
| 任务管理   | GetTask                          | 获取任务当前状态                       |
|            | ListTasks                        | 列出任务（支持过滤和分页）             |
|            | CancelTask                       | 取消任务                               |
|            | SubscribeToTask                  | 订阅任务更新（流式）                   |
| 推送通知   | SetTaskPushNotificationConfig    | 设置 Webhook 通知                      |
|            | GetTaskPushNotificationConfig    | 获取通知配置                           |
|            | ListTaskPushNotificationConfig   | 列出所有通知配置                       |
|            | DeleteTaskPushNotificationConfig | 删除通知配置                           |
| Agent 发现 | GetExtendedAgentCard             | 获取扩展 Agent Card                    |

## 2.2 状态定义

```lua
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              Task 状态生命周期                                           │
└─────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌───────────────────┐
                                    │    SUBMITTED      │  任务已创建
                                    └─────────┬─────────┘
                                              │
                                              ▼
                                    ┌───────────────────┐
                         ┌─────────│     WORKING       │─────────┐
                         │         └─────────┬─────────┘         │
                         │                   │                   │
              ┌──────────▼───────────┐       │      ┌────────────▼────────────┐
              │   INPUT_REQUIRED     │       │      │    AUTH_REQUIRED        │
              │   需要额外输入        │       │      │    需要认证             │
              └──────────┬───────────┘       │      └────────────┬────────────┘
                         │                   │                   │
                         └─────────┬─────────┘───────────────────┘
                                   │
            ┌──────────────────────┼──────────────────────┐
            ▼                      ▼                      ▼
  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
  │   COMPLETED     │   │     FAILED      │   │   CANCELLED     │
  │   成功完成       │   │     失败        │   │    已取消       │
  └─────────────────┘   └─────────────────┘   └─────────────────┘
                                              
  ┌─────────────────┐
  │    REJECTED     │  Agent 拒绝执行
  └─────────────────┘
```

```protobuf
enum TaskState {
  TASK_STATE_UNSPECIFIED = 0;   // 未知状态
  TASK_STATE_SUBMITTED = 1;     // 已提交
  TASK_STATE_WORKING = 2;       // 处理中
  TASK_STATE_COMPLETED = 3;     // 已完成 (终态)
  TASK_STATE_FAILED = 4;        // 失败 (终态)
  TASK_STATE_CANCELLED = 5;     // 已取消 (终态)
  TASK_STATE_INPUT_REQUIRED = 6; // 需要输入 (中断态)
  TASK_STATE_REJECTED = 7;      // 被拒绝 (终态)
  TASK_STATE_AUTH_REQUIRED = 8; // 需要认证
}
```

## 2.3 数据类型

```protobuf
message Message {
  string message_id = 1;           // 消息唯一 ID
  string context_id = 2;           // 上下文 ID（可选）
  string task_id = 3;              // 任务 ID（可选）
  Role role = 4;                   // 发送者角色 (USER/AGENT)
  repeated Part parts = 5;         // 消息内容部分
  google.protobuf.Struct metadata = 6;  // 元数据
  repeated string extensions = 7;        // 扩展 URI
  repeated string reference_task_ids = 8; // 引用的任务 ID
}

enum Role {
  ROLE_UNSPECIFIED = 0;
  ROLE_USER = 1;    // 客户端发送
  ROLE_AGENT = 2;   // 服务端发送
}

message Part {
  oneof part {
    string text = 1;      // 文本内容
    FilePart file = 2;    // 文件内容
    DataPart data = 3;    // 结构化数据
  }
  google.protobuf.Struct metadata = 4;
}
```

## 2.4 Agent Card

Agent Card 是 Agent 自描述的元数据文档，用于能力发现：

```protobuf
message Artifact {
  string artifact_id = 1;      // 产物唯一 ID
  string name = 3;             // 名称
  string description = 4;      // 描述
  repeated Part parts = 5;     // 内容部分
  google.protobuf.Struct metadata = 6;
  repeated string extensions = 7;
}
```

Agent接口定义

```protobuf
message AgentCard {
  optional string protocol_version = 16;  // A2A 协议版本 (默认 "1.0")
  string name = 1;                        // Agent 名称
  string description = 2;                 // Agent 描述
  
  // 支持的接口（按优先级排序）
  repeated AgentInterface supported_interfaces = 19;
  
  AgentProvider provider = 4;             // 服务提供商
  string version = 5;                     // Agent 版本
  optional string documentation_url = 6;  // 文档 URL
  
  AgentCapabilities capabilities = 7;     // 能力声明
  map<string, SecurityScheme> security_schemes = 8;  // 安全方案
  repeated Security security = 9;                     // 安全要求
  
  // 输入/输出模态（MIME 类型）
  repeated string default_input_modes = 10;
  repeated string default_output_modes = 11;
  
  repeated AgentSkill skills = 12;        // 技能列表
  optional bool supports_authenticated_extended_card = 13;
  repeated AgentCardSignature signatures = 17;  // JWS 签名
  optional string icon_url = 18;               // 图标 URL
}
```

## 2.5 技能

```go
message AgentSkill {
  string id = 1;                    // 技能 ID
  string name = 2;                  // 技能名称
  string description = 3;           // 技能描述
  repeated string tags = 4;         // 标签
  repeated string examples = 5;     // 示例提示
  repeated string input_modes = 6;  // 覆盖输入模态
  repeated string output_modes = 7; // 覆盖输出模态
  repeated Security security = 8;   // 安全要求
}
```

## 2.6 响应

```protobuf
message StreamResponse {
  oneof payload {
    Task task = 1;                          // 任务对象
    Message msg = 2;                        // 消息对象
    TaskStatusUpdateEvent status_update = 3;    // 状态更新事件
    TaskArtifactUpdateEvent artifact_update = 4; // 产物更新事件
  }
}
```

## 2.7 协议对比

| 操作            | JSON-RPC Method | gRPC RPC             | HTTP/REST                          |
| :-------------- | :-------------- | :------------------- | :--------------------------------- |
| 发送消息        | message/send    | SendMessage          | POST /v1/message:send              |
| 流式发送        | message/stream  | SendStreamingMessage | POST /v1/message:stream (SSE)      |
| 获取任务        | tasks/get       | GetTask              | GET /v1/tasks/{id}                 |
| 列出任务        | tasks/list      | ListTasks            | GET /v1/tasks                      |
| 取消任务        | tasks/cancel    | CancelTask           | POST /v1/tasks/{id}:cancel         |
| 订阅任务        | tasks/subscribe | SubscribeToTask      | GET /v1/tasks/{id}:subscribe (SSE) |
| 获取 Agent Card | N/A             | GetExtendedAgentCard | GET /.well-known/agent-card.json   |

# 3 a2a-go

a2a-go 是由社区开发的 A2A 协议 Go 语言 SDK 实现，提供了一个简洁、灵活的框架来构建符合 A2A 协议的 Agent 服务器。

```go
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              a2a-go 项目架构                                             │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│   ┌────────────────────────────────────────────────────────────────────────────────┐   │
│   │                              A2A Server                                         │   │
│   │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│   │  │                         HTTP Handler (Mux)                              │   │   │
│   │  │  ┌────────────────────┐    ┌─────────────────────────────────────────┐  │   │   │
│   │  │  │ /.well-known/      │    │           RPC Endpoint (/)              │  │   │   │
│   │  │  │   agent.json       │    │  ┌────────────────────────────────────┐ │  │   │   │
│   │  │  │  (Agent Card)      │    │  │      JSON-RPC 2.0 Dispatcher       │ │  │   │   │
│   │  │  └────────────────────┘    │  │  • tasks/send                      │ │  │   │   │
│   │  │                            │  │  • tasks/get                       │ │  │   │   │
│   │  │                            │  │  • tasks/cancel                    │ │  │   │   │
│   │  │                            │  │  • tasks/sendSubscribe (SSE)       │ │  │   │   │
│   │  │                            │  │  • tasks/resubscribe (SSE)         │ │  │   │   │
│   │  │                            │  │  • tasks/pushNotification/*        │ │  │   │   │
│   │  │                            │  └────────────────────────────────────┘ │  │   │   │
│   │  │                            └─────────────────────────────────────────┘  │   │   │
│   │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│   │                                      │                                         │   │
│   │          ┌───────────────────────────┼───────────────────────────┐             │   │
│   │          │                           ▼                           │             │   │
│   │  ┌───────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐ │   │
│   │  │   HandlerFuncs    │     │    handlerAdapter   │     │    TaskStore        │ │   │
│   │  │  (User Defined)   │────►│   (内部适配器)       │────►│  (可插拔存储)        │ │   │
│   │  └───────────────────┘     └─────────────────────┘     │  • InMemoryStore    │ │   │
│   │                                                         │  • FileTaskStore    │ │   │
│   │                                                         └─────────────────────┘ │   │
│   └────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## 3.1 项目文件

```lua
a2a-go/
├── schema.go      # 核心数据模型定义（Task, Message, Part, AgentCard 等）
├── server.go      # Server 实现、HTTP 处理、SSE 流、RPC 调度
├── handler.go     # Handler 接口和 HandlerFuncs 定义
├── store.go       # TaskStore 接口及实现（InMemory、File）
├── core.go        # 类型整合（已合并到 schema.go）
├── agent.go       # Agent 相关（如有）
├── examples/
│   ├── helloworld/main.go  # 最简示例：Hello World
│   └── simple/main.go      # 简单回显示例
├── docs/          # 文档
├── go.mod         # Go 模块定义
└── README.md      # 项目说明
```

## 3.2 数据模型

```go
// 任务状态
type TaskState string

const (
    StateUnknown    TaskState = "unknown"
    StatePending    TaskState = "pending"     // 等待处理
    StateProcessing TaskState = "processing"  // 处理中
    StateCompleted  TaskState = "completed"   // 已完成
    StateFailed     TaskState = "failed"      // 失败
    StateCanceled   TaskState = "canceled"    // 已取消
)
```

## 3.3 handlerFuncs设计模式

a2a-go 采用函数式 Handler 配置，允许开发者只实现需要的方法：

```go
type HandlerFuncs struct {
    // 必须实现：返回 Agent Card
    GetAgentCardFunc func() (*AgentCard, error)

    // 可选：处理 tasks/send（非流式）
    SendTaskFunc func(ctx *TaskContext) (*Task, error)

    // 可选：处理 tasks/get
    GetTaskFunc func(params *TaskGetParams) (*Task, error)

    // 可选：处理 tasks/cancel
    CancelTaskFunc func(params *TaskCancelParams) (*Task, error)

    // 可选：处理 tasks/sendSubscribe（流式 SSE）
    SendTaskSubscribeFunc func(ctx *TaskContext) (*Task, error)

    // 可选：处理 tasks/resubscribe
    ResubscribeFunc func(params *TaskGetParams) error

    // 可选：推送通知配置
    SetTaskPushNotificationsFunc func(params *TaskPushNotificationSetParams) (*PushNotificationConfig, error)
    GetTaskPushNotificationsFunc func(params *TaskIdParams) (*PushNotificationConfig, error)
}
```

## 3.4 RPC方法映射

| JSON-RPC Method            | Handler 方法               | 说明                    |
| :------------------------- | :------------------------- | :---------------------- |
| tasks/send                 | SendTask()                 | 发送消息，同步返回 Task |
| tasks/get                  | GetTask()                  | 获取任务状态            |
| tasks/cancel               | CancelTask()               | 取消任务                |
| tasks/sendSubscribe        | SendTaskSubscribe()        | 发送消息，开启 SSE 流   |
| tasks/resubscribe          | Resubscribe()              | 重新订阅 SSE 流         |
| tasks/pushNotification/set | SetTaskPushNotifications() | 设置推送通知            |
| tasks/pushNotification/get | GetTaskPushNotifications() | 获取推送通知配置        |

## 3.5 与A2A协议

```lua
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         A2A 协议规范 → a2a-go 实现映射                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────┐        ┌─────────────────────────────────────────────┐ │
│  │      A2A Protocol Spec          │        │           a2a-go Implementation            │ │
│  ├─────────────────────────────────┤        ├─────────────────────────────────────────────┤ │
│  │                                 │        │                                             │ │
│  │  Transport Layer                │        │  Transport Layer                           │ │
│  │  ├── HTTP/HTTPS                 │───────►│  ├── net/http (标准库)                      │ │
│  │  ├── JSON-RPC 2.0               │───────►│  ├── RPCRequest/RPCResponse (schema.go)   │ │
│  │  └── SSE (Server-Sent Events)   │───────►│  └── initiateSSEStream() (server.go)     │ │
│  │                                 │        │                                             │ │
│  │  Discovery Layer                │        │  Discovery Layer                           │ │
│  │  └── /.well-known/agent.json    │───────►│  └── handleAgentCard() (server.go)        │ │
│  │                                 │        │                                             │ │
│  │  Data Model                     │        │  Data Model                                │ │
│  │  ├── Task                       │───────►│  ├── Task struct (schema.go)              │ │
│  │  ├── Message                    │───────►│  ├── Message struct (schema.go)           │ │
│  │  ├── Part (Text/File/Data)      │───────►│  ├── Part interface + 实现 (schema.go)    │ │
│  │  ├── Artifact                   │───────►│  ├── Artifact struct (schema.go)          │ │
│  │  └── AgentCard                  │───────►│  └── AgentCard struct (schema.go)         │ │
│  │                                 │        │                                             │ │
│  │  RPC Operations                 │        │  RPC Operations                            │ │
│  │  ├── tasks/send                 │───────►│  ├── handleSendTaskRPC() (server.go)      │ │
│  │  ├── tasks/get                  │───────►│  ├── handleGetTaskRPC() (server.go)       │ │
│  │  ├── tasks/cancel               │───────►│  ├── handleCancelTaskRPC() (server.go)    │ │
│  │  ├── tasks/sendSubscribe        │───────►│  ├── handleSendTaskSubscribeRPC()         │ │
│  │  ├── tasks/resubscribe          │───────►│  ├── handleResubscribeRPC()               │ │
│  │  └── tasks/pushNotification/*   │───────►│  └── handleSet/GetPushNotifyRPC()         │ │
│  │                                 │        │                                             │ │
│  │  Storage (非协议，实现扩展)       │        │  Storage                                   │ │
│  │  └── (自定义)                   │───────►│  └── TaskStore interface (store.go)       │ │
│  │                                 │        │                                             │ │
│  └─────────────────────────────────┘        └─────────────────────────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

