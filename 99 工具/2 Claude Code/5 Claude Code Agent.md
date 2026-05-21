# 1 Claude Code 子代理（Sub-agents）

## 1 为什么使用子代理

子代理的核心价值在于**隔离 + 专业化**：

| 优势 | 说明 |
| --- | --- |
| **保留主对话上下文** | 把探索、日志分析等"重任务"放到子代理中，主对话只接收结论摘要，不被大量中间输出淹没 |
| **强制执行约束** | 通过工具白名单或黑名单限制子代理的能力，例如只读分析、禁止执行危险命令 |
| **行为专业化** | 为特定领域（代码审查、调试、数据分析）设计专用 AI，在系统提示中明确指出能力边界 |
| **控制成本** | 将简单任务交给 Haiku，将复杂分析交给 Sonnet，避免不必要的高成本调用 |
| **跨项目复用** | 用户级子代理一次配置，所有项目可用 |

> 研究表明，并行运行三个子代理分析 5 万行项目约需 45 秒，而串行执行需要 3 分钟。

## 2 内置子代理

Claude Code 已内置多种子代理，通常会自动使用，无需手动配置。每个内置代理继承父对话的权限并附加工具限制。

### 2.1 Explore（探索代理）

用于**只读搜索与分析**代码库。

- **模型**：Haiku（速度快、延迟低）
- **工具**：只读工具（拒绝访问 Write / Edit）
- **触发时机**：Claude 需要查看代码但不修改代码时自动使用
- **探索深度**：支持 `quick`、`medium`、`very thorough` 三档

### 2.2 Plan（规划代理）

在**计划模式**下收集代码库信息，为后续方案制定积累上下文。

- **模型**：从主对话继承
- **工具**：只读工具（拒绝访问 Write / Edit）
- **触发时机**：处于 plan mode 且 Claude 需要理解代码库时
- **注意**：Plan 代理不会产生嵌套代理，安全地收集规划所需信息

### 2.3 General-purpose（通用代理）

用于**复杂、多步骤**任务，开放全部工具，继承主对话的模型。

- **模型**：从主对话继承
- **工具**：所有工具
- **触发时机**：任务需要探索和修改、多步骤操作或复杂推理时

### 2.4 其它内置代理

| 代理名称 | 模型 | 触发时机 |
| --- | --- | --- |
| `statusline-setup` | Sonnet | 运行 `/statusline` 配置状态行时 |
| `claude-code-guide` | Haiku | 提出关于 Claude Code 功能的问题时 |

> **注意**：Explore 和 Plan 会跳过 CLAUDE.md 文件和父会话的 git 状态，以保持研究快速且成本低廉。其他内置和自定义子代理都会加载两者。

## 3 子代理管理（/agents）

使用 `/agents` 命令打开管理界面：

```sh
/agents
```

界面分两个选项卡：

- **Running**：显示实时运行的子代理，可打开或停止
- **Library**：查看所有可用子代理（内置、用户、项目、插件），创建、编辑或删除自定义子代理

## 4 创建自定义子代理

### 4.1 子代理存储位置与优先级

| 位置 | 作用范围 | 优先级 | 创建方式 |
| --- | --- | --- | --- |
| 托管设置 | 组织范围 | 1（最高） | 通过 managed settings 部署 |
| `--agents` CLI 标志 | 当前会话 | 2 | 启动时传递 JSON |
| `.claude/agents/` | 当前项目 | 3 | 交互式或手动创建 |
| `~/.claude/agents/` | 所有项目 | 4 | 交互式或手动创建 |
| Plugin 的 `agents/` 目录 | 启用插件的位置 | 5（最低） | 与插件一起安装 |

**推荐**：项目级子代理（`.claude/agents/`）适合放入版本控制，与团队共享；用户级子代理（`~/.claude/agents/`）适合个人跨项目复用。

### 4.2 通过 /agents 创建（推荐）

1. 运行 `/agents`，切换到 **Library** 选项卡
2. 选择 **Create new agent**，选择存储位置（Personal / Project）
3. 选择 **Generate with Claude** 输入描述，或手动填写
4. 配置工具、模型、颜色和内存范围
5. 保存后立即生效（无需重启）

### 4.3 手动创建子代理文件

子代理是带有 YAML frontmatter 的 Markdown 文件，正文作为系统提示：

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after code changes.
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

> **注意**：通过 `/agents` 界面创建的子代理立即生效；直接编辑磁盘上的文件需要重启会话才能加载。

### 4.4 通过 CLI 标志定义（临时会话）

仅在当前会话有效，不保存到磁盘，适合快速测试：

```sh
# macOS / Linux / WSL
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

## 5 子代理文件配置项

以下是 YAML frontmatter 支持的所有字段，仅 `name` 和 `description` 为必填项：

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `name` | ✅ | 唯一标识符，使用小写字母和连字符 |
| `description` | ✅ | 描述何时应委托给此子代理，Claude 用此判断触发时机 |
| `tools` | ❌ | 允许使用的工具白名单，省略则继承全部工具 |
| `disallowedTools` | ❌ | 禁止使用的工具黑名单 |
| `model` | ❌ | 模型：`sonnet`、`opus`、`haiku`、完整模型 ID 或 `inherit`（默认） |
| `permissionMode` | ❌ | 权限模式：`default`、`acceptEdits`、`auto`、`dontAsk`、`bypassPermissions`、`plan` |
| `maxTurns` | ❌ | 子代理停止前的最大代理轮数 |
| `skills` | ❌ | 启动时预加载到子代理上下文的技能列表 |
| `mcpServers` | ❌ | 仅此子代理可用的 MCP 服务器 |
| `hooks` | ❌ | 限定于此子代理的生命周期钩子 |
| `memory` | ❌ | 持久内存范围：`user`、`project`、`local` |
| `background` | ❌ | 设为 `true` 则始终作为后台任务运行（默认 `false`） |
| `effort` | ❌ | 思考深度：`low`、`medium`、`high`、`xhigh`、`max` |
| `isolation` | ❌ | 设为 `worktree` 在临时 git worktree 中运行，获得隔离的仓库副本 |
| `color` | ❌ | 显示颜色：`red`、`blue`、`green`、`yellow`、`purple`、`orange`、`pink`、`cyan` |
| `initialPrompt` | ❌ | 作为主会话运行时自动提交的第一条用户消息 |

### 5.1 工具配置示例

```markdown
# 只允许指定工具（白名单）
---
tools: Read, Grep, Glob, Bash
---

# 继承所有工具，排除指定工具（黑名单）
---
disallowedTools: Write, Edit
---

# 限制可生成的子代理类型
---
tools: Agent(worker, researcher), Read, Bash
---
```

### 5.2 模型选择策略

`model` 字段的解析优先级（从高到低）：

1. `CLAUDE_CODE_SUBAGENT_MODEL` 环境变量
2. 每次调用时传递的 `model` 参数
3. 子代理定义中的 `model` frontmatter
4. 主对话的当前模型

推荐按任务复杂度选择模型：

| 任务类型 | 推荐模型 | 原因 |
| --- | --- | --- |
| 文件搜索、代码探索 | **Haiku** | 速度快、成本低 |
| 代码审查 | **Sonnet** | 理解上下文够用，能抓到细微问题 |
| 复杂架构分析、调试 | **Opus** | 需要在脑中持有整个系统状态 |

### 5.3 权限模式说明

| 模式 | 行为 |
| --- | --- |
| `default` | 标准权限检查，有提示 |
| `acceptEdits` | 自动接受工作目录内的文件编辑 |
| `auto` | 后台分类器审查命令，受保护目录的写入仍提示 |
| `dontAsk` | 自动拒绝权限提示（显式允许的工具仍然工作） |
| `bypassPermissions` | 跳过全部权限提示（谨慎使用） |
| `plan` | 只读探索模式 |

> ⚠️ `bypassPermissions` 会跳过所有权限提示，仅在受信任环境中使用。

### 5.4 持久内存（memory）

启用后，子代理拥有跨会话幸存的持久目录，可积累代码库模式、调试见解等知识：

| 范围 | 存储路径 | 适用场景 |
| --- | --- | --- |
| `user` | `~/.claude/agent-memory/<name>/` | 知识在所有项目中通用 |
| `project` | `.claude/agent-memory/<name>/` | 知识特定于项目，可纳入版本控制 |
| `local` | `.claude/agent-memory-local/<name>/` | 知识特定于项目，不纳入版本控制 |

## 6 调用子代理

### 6.1 自然语言（Claude 自动决定）

```markdown
Use the test-runner subagent to fix failing tests
Have the code-reviewer subagent look at my recent changes
```

### 6.2 @-mention（确保特定子代理运行）

输入 `@` 从补全列表中选择子代理，保证该子代理被调用：

```markdown
@"code-reviewer (agent)" look at the auth changes
```

### 6.3 --agent 标志（整个会话使用子代理）

整个会话采用该子代理的系统提示、工具限制和模型：

```sh
claude --agent code-reviewer
```

### 6.4 设置文件（项目默认子代理）

在 `.claude/settings.json` 中配置，使其成为项目中每个会话的默认值：

```json
{
  "agent": "code-reviewer"
}
```

### 6.5 禁用特定子代理

在 `settings.json` 的 `deny` 数组中添加：

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

或通过 CLI 标志：

```sh
claude --disallowedTools "Agent(Explore)"
```

## 7 前台与后台运行

| 模式 | 行为 |
| --- | --- |
| **前台** | 阻塞主对话直到完成，权限提示实时传递给用户 |
| **后台** | 与主对话并发运行，使用已授予的权限，无法提示时自动拒绝 |

- 可对 Claude 说 "run this in the background" 指定后台运行
- 按 `Ctrl+B` 将正在运行的任务放到后台
- 设置环境变量 `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` 禁用所有后台任务

## 8 常见使用模式

### 8.1 隔离高容量操作

将产生大量输出的操作（运行测试、获取文档、处理日志）委托给子代理，只接收摘要：

```
Use a subagent to run the test suite and report only the failing tests with their error messages
```

### 8.2 并行研究

对独立的调查，同时启动多个子代理：

```
Research the authentication, database, and API modules in parallel using separate subagents
```

### 8.3 链式调用

多步骤工作流中按顺序使用子代理：

```
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

### 8.4 何时选择子代理 vs 主对话

| 使用**主对话** | 使用**子代理** |
| --- | --- |
| 需要频繁来回或迭代细化 | 任务产生不需要在主上下文中的详细输出 |
| 多阶段共享重要上下文 | 需要强制执行特定工具限制或权限 |
| 快速、有针对性的更改 | 工作是自包含的，可以返回摘要 |
| 对延迟敏感 | 可并行处理的独立任务 |

## 9 示例子代理

### 代码审查者（只读）

```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Good test coverage

Provide feedback organized by: Critical issues → Warnings → Suggestions
```

### 调试器（可修改代码）

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

Process: Capture error → Identify reproduction steps → Isolate failure → Implement minimal fix → Verify solution.

For each issue, provide: root cause explanation, evidence, code fix, and prevention recommendations.
```

### 只读数据库查询（使用 hooks 限制）

```markdown
---
name: db-reader
description: Execute read-only database queries. Use when analyzing data or generating reports.
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You are a database analyst with read-only access. Execute SELECT queries only.
```

## 10 参考

- https://docs.anthropic.com/zh-CN/docs/claude-code/sub-agents
- https://www.runoob.com/claude-code/claude-code-subagent.html
- 子Agent不需要填写，参考不同来源的Agent使用 https://waytoagi.feishu.cn/wiki/Gx3ywoTZIihfiWkD1hlcLq5Vnqb
