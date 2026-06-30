# Claude Code日常使用

# 1 常用命令

## 1.1 会话管理

| 命令 | 作用 |
| --- | --- |
| `/clear` | 清空当前对话历史，开始全新会话 |
| `/compact` | 将对话历史压缩为摘要，释放上下文空间，保留当前任务 |
| `/compact <指令>` | 压缩时附加提示，告知 Claude 重点保留哪些内容 |

## 1.2 记忆与配置

| 命令 | 作用 |
| --- | --- |
| `/memory` | 查看和编辑所有记忆内容（CLAUDE.md + 自动记忆） |
| `/doctor` | 检查 Claude Code 配置健康状态，排查常见问题 |
| `/status` | 查看当前会话状态、上下文用量等信息 |

## 1.3 代理与工具

| 命令 | 作用 |
| --- | --- |
| `/agents` | 打开子代理管理界面（Running / Library 两个选项卡） |
| `/plugin` | 打开插件管理界面，安装/删除/列出插件 |
| `/plugin install <url>` | 从 GitHub 或市场安装插件 |
| `/plugin list` | 列出已安装的插件 |
| `/reload-plugins` | 热更新插件，无需重启会话 |

安全护栏类插件推荐优先安装 `security-guidance`，详见 `5.2`。

## 1.4 内置 Skills

| 命令 | 作用 |
| --- | --- |
| `/simplify` | 审查代码，找重用、质量和效率问题并修复 |
| `/debug` | 调试错误，分析根因并提供修复方案 |
| `/batch` | 批量处理多个任务 |
| `/loop` | 循环执行任务直到满足条件 |
| `/run` | 启动并驱动应用，验证更改是否生效 |
| `/verify` | 构建并运行应用，确认代码更改按预期工作 |
| `/run-skill-generator` | 教 `/run` 和 `/verify` 如何构建和启动项目 |

## 1.5 其他实用命令

| 命令 | 作用 |
| --- | --- |
| `/help` | 查看所有可用命令和已加载的 Skills |
| `/init` | 在当前项目初始化 CLAUDE.md 文件 |
| `/cost` | 查看当前会话的 token 消耗和费用估算 |
| `/terminal-setup` | 配置终端 shift-enter 换行等快捷键 |
| `/statusline` | 配置终端状态行显示 |

---

# 2 常用工作流

## 2.1 开始新任务前

```sh
# 新任务开始时清空上下文
/clear

# 如果是接续之前任务，先用 compact 释放空间
/compact 保留已完成的功能列表和当前待处理的 bug 描述
```

## 2.2 代码审查

```sh
# 使用内置 Skill 直接触发
/simplify

# 或者自然语言描述
请审查我最近的代码修改，关注安全性和性能问题
```

## 2.3 调试问题

```sh
# 使用调试 Skill
/debug

# 或让 Claude 自动分析
测试失败了，帮我找出根本原因并修复
```

## 2.4 跨会话记住重要信息

```sh
# 让 Claude 写入自动记忆
记住：我们的 API 测试需要本地运行 Redis

# 升级为正式规范写入 CLAUDE.md
把这条规则写进 CLAUDE.md：所有错误响应统一使用 { code, message } 结构
```

## 2.5 处理大型任务

```sh
# 让子代理并行处理，避免主上下文被淹没
用独立的子代理分别分析认证模块、数据库模块和 API 模块，只返回关键发现

# 查看子代理运行状态
/agents

# 将耗时任务放到后台（快捷键）
Ctrl+B
```



# 5 开发命令选择

## 5.1 代码review

### 5.1.1 /dev:code-review

- **来源：** https://github.com/qdhenry/Claude-Command-Suite/blob/main/.claude/commands/dev/
- **定位：** 通用代码质量审查，适合所有语言和项目，审查**整个项目**。
- **触发方式**： `/dev:code-review`
- **审查维度：**仓库分析、代码质量、安全、性能、架构设计、测试覆盖、文档等。

### 5.1.2 /review

- **来源：** Claude Code 平台内置，描述为 "Review a pull request"。
- **定位：** 针对 PR/分支 diff 的审查，聚焦在变更集。
- **触发方式：** /review（自动读取当前分支 vs 主分支的 diff）。
- **行为：**  自动拉取变更，审查本次PR引入的变更。

### 5.1.3 pr-review-toolkit:review-pr （重要）

- **来源：** Anthropic官网插件。
- **定位：** 本地 diff 的多维专项审查工具，PR 提交前的最后一道质量门控。
- **触发方式：**/pr-review-toolkit:review-pr [aspects] 
- **本质：** 一个 orchestrator 命令 + 6 个独立专项 agent 的组合体，每个 agent 各司其职。
- **审查维度：** 通用代码质量、静默错误猎手、测试覆盖分析、注释准确性、类型设计质量、代码简化

### 5.1.4 /grill-me

- **来源：** 社区 Skill，常见来源为 `mattpocock/skills` 中的 `grill-me`。
- **定位：** 面向当前改动或当前方案的对抗式 review，适合在提交前进一步挑问题。
- **触发方式：** `/grill-me`
- **使用方式：** 直接执行 `/grill-me`

## 5.2 安全审查

### 5.2.1 security-guidance（自动）

- **来源：** Anthropic 官方插件。
- **定位：** 开发过程中的自动安全护栏，用于持续检查当前改动中的常见安全问题。
- **触发方式：** 安装并执行 `/reload-plugins` 后自动运行，无需手动触发命令。
- **使用方式：** `/plugin install security-guidance@claude-plugins-official`；如市场未配置，先执行 `/plugin marketplace add anthropics/claude-plugins-official`。

### 5.2.2 /security-review

- **来源：** Claude Code 安全审查 Skill。
- **定位：** 面向当前改动或当前任务的安全 review，适合功能完成后或提交前使用。
- **触发方式：** `/security-review`
- **使用方式：** 直接执行 `/security-review`

### 5.2.3 /security:security-audit 

- **来源：** https://github.com/qdhenry/Claude-Command-Suite/blob/main/.claude/commands/security/security-audit.md
- **定位：** 周期性全仓库安全体检，适合累计若干次功能合并后的定期巡检。
- **触发方式：** /security:security-audit
- **使用方式：** 直接执行 `/security:security-audit`

## 5.3 测试

### 5.3.1 test:write-tests 

- **来源**: https://github.com/qdhenry/Claude-Command-Suite/blob/main/.claude/commands/test/write-tests.md

- **调用方式：** /test:write-tests [目标代码/文件]

- **核心功能：** 

  | 阶段 | 步骤  | 说明                           |
  | ---- | ----- | ------------------------------ |
  | 准备 | 1-3   | 检测框架、分析代码、制定策略   |
  | 实现 | 4-9   | 单测、集成测试、Mock、错误路径 |
  | 扩展 | 10-13 | 性能、安全、跨平台、异步       |
  | 维护 | 14-18 | 工具类、快照、文档、维护规范   |

- **使用时机：**                                                                                                                                                                                                              
      1. 新增业务逻辑后，为新增xxx.go等补充测试。
          2. 修复 bug 后——先写复现测试，再修复（与 TDD 工作流配合）。
          3. 安全审计发现缺陷后——校验缺失补充边界用例。
          4. 接手存量代码——对覆盖率低的模块批量补测。
