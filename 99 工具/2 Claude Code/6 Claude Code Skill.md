# 1 Claude Code Skills（技能）

## 1 为什么需要 Skills

**Skills** 是 Claude Code 的能力扩展包，解决以下痛点：

| 痛点 | Skills 解决方案 |
| --- | --- |
| 团队规范每次需要手动提醒 | 一次创建，Claude 自动触发加载 |
| 复杂流程 AI 不了解最佳实践 | 将知识和步骤封装成 Skill |
| 长提示词占满上下文窗口 | 渐进式披露，只在需要时加载 |
| 工作流无法跨项目复用 | 支持用户级、项目级、插件级分发 |

> **与 CLAUDE.md 的区别**：CLAUDE.md 内容每次会话都加载，Skill 的正文**仅在使用时加载**，长参考资料几乎不消耗上下文成本。
>
> **与 Agent 的区别**：Skills 提供可重用的提示/工作流，在主对话上下文内运行；Agents 是独立的子代理，有自己的上下文窗口。

## 2 捆绑 Skills（内置）

Claude Code 内置了一组开箱即用的 Skills，输入 `/` 后跟 Skill 名称即可调用：

| Skill | 用途 |
| --- | --- |
| `/simplify` | 审查代码，找重用、质量和效率问题并修复 |
| `/debug` | 调试错误，分析根因并提供修复方案 |
| `/batch` | 批量处理多个任务 |
| `/loop` | 循环执行任务直到满足条件 |
| `/claude-api` | Claude API 使用相关的指导 |
| `/run` | 启动并驱动应用，验证更改是否生效 |
| `/verify` | 构建并运行应用，确认代码更改按预期工作 |
| `/run-skill-generator` | 教 `/run` 和 `/verify` 如何构建和启动项目 |

## 3 Skills 存储位置

| 位置 | 路径 | 适用范围 |
| --- | --- | --- |
| 企业级 | 托管设置目录 | 组织内所有用户 |
| 用户级 | `~/.claude/skills/<name>/SKILL.md` | 你的所有项目 |
| 项目级 | `.claude/skills/<name>/SKILL.md` | 仅此项目 |
| 插件级 | `<plugin>/skills/<name>/SKILL.md` | 启用插件的位置 |

**优先级**：企业 > 用户 > 项目。插件 Skills 使用 `plugin-name:skill-name` 命名空间，不与其他级别冲突。

> **实时变更检测**：`~/.claude/skills/` 和 `.claude/skills/` 中的文件变更会在当前会话中立即生效，无需重启。

## 4 创建 Skills

### 4.1 目录结构

每个 Skill 是一个以 `SKILL.md` 为入口点的目录：

```
my-skill/
├── SKILL.md           # 主要说明（必需）
├── reference.md       # 详细参考文档（按需加载）
├── examples.md        # 示例输出（按需加载）
└── scripts/
    └── validate.sh    # Claude 可执行的脚本
```

### 4.2 SKILL.md 文件格式

```markdown
---
name: my-skill
description: 技能描述，Claude 根据此判断何时自动调用
disable-model-invocation: true
---

## 说明内容（系统提示）

1. 步骤一
2. 步骤二
```

### 4.3 快速创建示例

```sh
# 创建用户级 Skill 目录
mkdir -p ~/.claude/skills/summarize-changes
```

编写 `~/.claude/skills/summarize-changes/SKILL.md`：

```markdown
---
description: Summarizes uncommitted changes and flags anything risky. Use when the user asks what changed, wants a commit message, or asks to review their diff.
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes in 2-3 bullet points, then list any risks such as missing error handling or tests that need updating.
```

调用方式：直接说"What did I change?"（Claude 自动触发），或输入 `/summarize-changes`。

## 5 Frontmatter 配置项

所有字段均为可选，建议至少填写 `description`：

| 字段 | 说明 |
| --- | --- |
| `name` | Skill 显示名称，省略则用目录名。仅小写字母、数字和连字符（最多 64 字符） |
| `description` | 功能描述及触发场景，Claude 根据此决定何时自动加载 |
| `when_to_use` | 额外的触发上下文（如触发短语、示例请求），附加到 `description` |
| `argument-hint` | 自动补全时显示的参数提示，如 `[issue-number]` |
| `arguments` | 命名位置参数，用于 `$name` 替换，接受空格分隔字符串或 YAML 列表 |
| `disable-model-invocation` | `true` 则 Claude 不会自动调用，只能用户手动 `/name` 触发 |
| `user-invocable` | `false` 则从 `/` 菜单隐藏，仅 Claude 自动调用 |
| `allowed-tools` | Skill 激活时无需权限确认可直接使用的工具列表 |
| `model` | 覆盖当前轮次使用的模型，仅当前轮有效 |
| `effort` | 思考深度：`low`、`medium`、`high`、`xhigh`、`max` |
| `context` | 设为 `fork` 则在独立子代理上下文中运行 |
| `agent` | 配合 `context: fork` 使用，指定子代理类型 |
| `hooks` | 限定于此 Skill 生命周期的 hooks |
| `paths` | Glob 模式，限定在哪些文件路径下自动激活此 Skill |
| `shell` | 内联命令使用的 shell：`bash`（默认）或 `powershell` |

### 5.1 调用控制对比

| Frontmatter 配置 | 用户可调用 | Claude 可调用 | 上下文加载方式 |
| --- | --- | --- | --- |
| （默认） | ✅ | ✅ | 描述始终在上下文，完整内容调用时加载 |
| `disable-model-invocation: true` | ✅ | ❌ | 描述不在上下文，用户调用时加载 |
| `user-invocable: false` | ❌ | ✅ | 描述始终在上下文，完整内容调用时加载 |

### 5.2 字符串替换变量

在 Skill 内容中可使用以下变量：

| 变量 | 描述 |
| --- | --- |
| `$ARGUMENTS` | 调用时传入的全部参数 |
| `$ARGUMENTS[N]` 或 `$N` | 按索引获取第 N 个参数（0 起始） |
| `$name` | frontmatter `arguments` 中声明的命名参数 |
| `${CLAUDE_SESSION_ID}` | 当前会话 ID |
| `${CLAUDE_EFFORT}` | 当前思考深度级别 |
| `${CLAUDE_SKILL_DIR}` | 当前 SKILL.md 所在目录的绝对路径 |

**参数示例**：

```markdown
---
name: fix-issue
description: Fix a GitHub issue by number
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.
```

运行 `/fix-issue 123` → Claude 收到 "Fix GitHub issue 123 following our coding standards."

## 6 调用 Skills

```sh
# 直接调用（用户触发）
/skill-name

# 带参数调用
/fix-issue 123

# 带多词参数（用引号包裹）
/my-skill "hello world" second

# 让 Claude 自动触发（无需特殊语法，直接自然语言提问）
# 只要请求内容匹配 description，Claude 会自动加载
```

## 7 高级功能

### 7.1 动态上下文注入（Shell 命令）

在 Skill 内容发送给 Claude 之前执行 Shell 命令，并将输出内联到提示中：

```markdown
---
name: pr-summary
description: Summarize pull request changes
context: fork
agent: Explore
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

**注意**：
- `!` 必须在行首或紧跟空白之后才会被识别为命令
- 多行命令使用 `` ```! `` 围栏代码块
- 命令在 Claude 看到内容前执行一次，输出替换占位符

### 7.2 在子代理中运行 Skill

设置 `context: fork` 让 Skill 在独立的子代理上下文中运行（不访问对话历史）：

```markdown
---
name: deep-research
description: Research a topic thoroughly in isolation
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

`agent` 可选值：`Explore`（只读）、`Plan`（只读规划）、`general-purpose`（全功能），或任意自定义子代理名称。

### 7.3 预批准工具权限

`allowed-tools` 字段让 Claude 在 Skill 激活时无需每次确认即可使用指定工具：

```markdown
---
name: commit
description: Stage and commit the current changes
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---
```

### 7.4 添加支持文件

将大型参考文档放到单独文件中，从 `SKILL.md` 引用，Claude 按需加载：

```markdown
## Additional resources

- For complete API details, see [reference.md](reference.md)
- For usage examples, see [examples.md](examples.md)
```

> 建议将 `SKILL.md` 控制在 500 行以内，详细资料放到单独文件。

## 8 从设置覆盖 Skill 可见性

在 `.claude/settings.local.json` 中通过 `skillOverrides` 控制显示方式：

```json
{
  "skillOverrides": {
    "legacy-context": "name-only",
    "deploy": "off"
  }
}
```

| 值 | 对 Claude 可见 | `/` 菜单可见 |
| --- | --- | --- |
| `on` | 名称 + 描述 | ✅ |
| `name-only` | 仅名称 | ✅ |
| `user-invocable-only` | 隐藏 | ✅ |
| `off` | 隐藏 | ❌ |

## 9 故障排除

| 问题 | 排查方向 |
| --- | --- |
| Skill 未自动触发 | 检查 `description` 是否包含用户会自然说的关键词；尝试 `/skill-name` 直接调用 |
| Skill 触发过于频繁 | 使描述更具体；或添加 `disable-model-invocation: true` |
| Skill 描述被截断 | 运行 `/doctor` 检查预算；在 `skillOverrides` 中将低优先级 Skill 设为 `name-only` |
| 修改文件后未生效 | `~/.claude/skills/` 和 `.claude/skills/` 支持热更新；若是首次创建顶层目录则需重启 |

## 10 参考

- https://code.claude.com/docs/zh-CN/skills
- andrej-karpathy-skills：受 Karpathy 启发的 Claude Code 指南，封装为技能包 https://github.com/multica-ai/andrej-karpathy-skills
