# Claude Code Commands

在 [Anthropic](https://www.anthropic.com?utm_source=chatgpt.com) 的 [Claude Code](https://docs.anthropic.com/en/docs/claude-code?utm_source=chatgpt.com) 中，Commands（命令）是一套“可复用 Prompt + 自动化工作流”的机制。Claude Code的命令通常分为两类：

| 类型            | 作用                      |
| --------------- | ------------------------- |
| 内置 Commands   | Claude Code 自带，如/help |
| 自定义 Commands | 用户自己定义              |

其本质是：命令名称 + Prompt模板 + 上下文规则 + 可选参数

## 1 自定义命令开发

### 1.1 命令文件结构

一个完整的Command Prompt命令如下：

```markdown
Review the Go code.

Requirements:
- Check goroutine leaks
- Check context propagation
- Check error handling
- Check panic safety

Target:
$ARGUMENTS
```

### 1.2 命令位置及作用域

| 作用域     | 存放位置              | 生效范围 | 适用场景           |
| :--------- | :-------------------- | :------- | :----------------- |
| **项目级** | `.claude/commands/`   | 当前项目 | 团队共享、项目特定 |
| **用户级** | `~/.claude/commands/` | 所有项目 | 个人工具、通用模板 |

> 相同命令优先级是：项目级（.claude/commands/）> 用户级（ ~/.claude/commands/） > 内置命令。

### 1.3 示例

```sh
.claude/commands/golang-review.md
```

内容：

```markdown
Review the Go code following these rules:

- Check goroutine leaks
- Check context propagation
- Check error wrapping
- Check interface abstraction
- Follow Uber Go Style Guide

Target file:
$ARGUMENTS
```

然后执行 `/project:golang-review user_service.go`，Claude 会自动加载命令模板，将 `$ARGUMENTS` 替换为 `user_service.go`，读取目标文件并执行分析。

## 2 Claude Command 资源

- Claude Command Suite： https://github.com/qdhenry/Claude-Command-Suite
- Awesome Claude Code：https://github.com/hesreallyhim/awesome-claude-code