# 1 Claude Code 常见操作

这篇文档合并了原来的“常见操作”和“日常使用”，目标是给出一份更完整、少重复的 Claude Code 实用手册。

## 1.1 首次启动

在项目目录下执行 `claude` 即可启动交互会话。常用启动方式如下：

```sh
# 直接启动
claude

# 指定项目目录
claude /path/my-project

# 跳过权限确认
claude --dangerously-skip-permissions

# 输出更详细的执行过程
claude --verbose

# 指定模型启动
claude --model <name>

# 继续最近一次会话
claude --continue

# 恢复指定会话
claude --resume <id>
```

## 1.2 输入前缀快捷操作

Claude Code 支持几种高频输入前缀：

- `@`：文件路径自动补全，例如 `@internal/tpms`
- `!`：直接执行 shell 命令，例如 `!ls`
- `#`：向 Claude 写入单次系统提示，例如 `#请用中文回答`

## 1.3 会话与上下文

### 1.3.1 常用上下文命令

| 命令 | 作用 |
| --- | --- |
| `/clear` | 清空当前对话历史，开始新会话 |
| `/compact` | 将对话压缩成摘要，释放上下文空间 |
| `/compact <指令>` | 压缩时指定重点保留内容 |
| `/context` | 可视化查看上下文使用情况 |
| `/cost` | 查看当前会话 token 成本 |
| `/usage` | 查看更详细的用量统计 |
| `/model` | 切换模型 |
| `/effort` | 调整思考深度，常见有 `low`、`medium`、`high`、`max` |
| `/status` | 查看当前会话状态和上下文信息 |

### 1.3.2 什么时候用 `/clear`

适合场景：

- 当前任务已经完成
- 准备切换到完全不同的新任务
- 旧对话历史已经明显干扰当前问题

不适合场景：

- 同一个任务还在继续，只是上下文变长

### 1.3.3 什么时候用 `/compact`

适合场景：

- token 接近上限
- 回答开始变慢
- 还需要继续当前任务，但不想完全新开会话

示例：

```sh
/compact 保留已完成接口列表和当前待修复 bug
```

## 1.4 自动记忆与配置

### 1.4.1 常用记忆与配置命令

| 命令 | 作用 |
| --- | --- |
| `/memory` | 查看和编辑所有记忆内容（`CLAUDE.md` + 自动记忆） |
| `/doctor` | 检查 Claude Code 配置健康状态 |
| `/permissions` | 查看和修改 Claude 的权限设置 |
| `/init` | 初始化项目，创建 `CLAUDE.md` |

### 1.4.2 自动记忆怎么用

Claude Code 会自动记录对未来还有复用价值的信息，例如：

- 常用测试命令
- 你的修复偏好
- 项目本地运行依赖
- 常见调试经验

也可以主动告诉 Claude：

```text
记住：我们的 API 测试需要本地运行 Redis
```

如果是项目规则而不是个人偏好，更适合这样说：

```text
把这条规则写进 CLAUDE.md：所有错误响应统一使用 { code, message } 结构
```

### 1.4.3 自动记忆的存储目录

如果没有单独指定路径，通常会按项目记录在：

```text
~/.claude/projects/<项目完整路径>/memory/
```

也可以在 `~/.claude/settings.json` 中指定：

```json
{
  "autoMemoryDirectory": "~/.claude/memory/"
}
```

## 1.5 回退、恢复与导出

Claude Code 的 `Checkpoint` 很像游戏存档，`Rewind` 类似读档回退。

### 1.5.1 回退

可以通过双击 `Escape` 选择 checkpoint，也可以使用 `/rewind`。

典型界面提示类似：

```text
Rewind to...
Select a message to restore code and fork the conversation from that point.
```

常见回退模式：

- **仅恢复对话**：保留代码修改，重置上下文
- **仅恢复代码**：保留上下文，代码修改回退
- **同时恢复**：代码和上下文都回退

### 1.5.2 会话管理

| 命令 | 作用 |
| --- | --- |
| `/resume` | 恢复之前的会话 |
| `/export` | 导出当前对话为文本文件 |
| `/rename` | 重命名会话 |
| `/exit` | 退出当前 Claude 会话 |

## 1.6 MCP、插件与 Hooks

| 命令 | 作用 |
| --- | --- |
| `/mcp` | 查看和管理 MCP 服务器连接 |
| `/plugin` | 打开插件管理界面 |
| `/plugin install <url>` | 从 GitHub 或市场安装插件 |
| `/plugin list` | 列出已安装插件 |
| `/reload-plugins` | 热更新插件，无需重启会话 |
| `/hooks` | 管理事件触发的自动化脚本 |
| `/agents` | 查看和管理子代理 |

如果要优先补充安全护栏类能力，推荐先安装 `security-guidance` 之类的安全插件。

## 1.7 内置 Skills

常见内置命令包括：

| 命令 | 作用 |
| --- | --- |
| `/simplify` | 审查代码，找重用、质量和效率问题并修复 |
| `/debug` | 调试错误，分析根因并给出修复方案 |
| `/batch` | 批量处理多个任务 |
| `/loop` | 循环执行直到满足条件 |
| `/run` | 启动并驱动应用，验证改动是否生效 |
| `/verify` | 构建并运行项目，确认改动按预期工作 |
| `/run-skill-generator` | 教 `/run` 和 `/verify` 如何构建和启动项目 |

## 1.8 其他常用命令

| 命令 | 作用 |
| --- | --- |
| `/help` | 查看可用命令和已加载 Skills |
| `/terminal-setup` | 配置终端快捷键行为 |
| `/statusline` | 配置状态栏显示 |
| `/security-review` | 分析当前未提交改动，查安全问题 |
| `/stats` | 查看使用习惯统计 |
| `/config` | 统一设置入口 |

## 1.9 日常工作流

### 1.9.1 开始新任务

```sh
# 新任务开始前清空上下文
/clear

# 如果还要继续之前的任务，但想释放空间
/compact 保留已完成功能列表和当前待处理 bug
```

### 1.9.2 代码审查

```sh
# 用内置 skill 直接触发
/simplify

# 或用自然语言描述
请审查我最近的代码修改，重点关注安全性和性能问题
```

### 1.9.3 调试问题

```sh
/debug
```

或者直接说：

```text
测试失败了，帮我找出根本原因并修复
```

### 1.9.4 跨会话记住重要信息

```text
记住：我们的 API 测试需要本地运行 Redis
把这条规则写进 CLAUDE.md：所有错误响应统一使用 { code, message } 结构
```

### 1.9.5 处理大型任务

```text
用独立的子代理分别分析认证模块、数据库模块和 API 模块，只返回关键发现
```

然后可以用：

```sh
/agents
```

查看子代理执行状态。耗时任务也可以放到后台，例如使用 `Ctrl+B`。

# 2 开发命令选择

## 2.1 代码 Review

### 2.1.1 `/dev:code-review`

- 来源：Claude Command Suite 等社区命令集
- 定位：通用代码质量审查
- 场景：适合看整个项目，而不只是一次 diff

### 2.1.2 `/review`

- 来源：Claude Code 平台内置
- 定位：针对当前分支 / PR diff 的审查
- 场景：适合提交前检查本次改动

### 2.1.3 `pr-review-toolkit:review-pr`

- 来源：Anthropic 官方插件
- 定位：本地 diff 的多维专项审查
- 场景：PR 提交前最后一道质量门槛

### 2.1.4 `/grill-me`

- 来源：常见社区 Skill
- 定位：更偏对抗式 review
- 场景：提交前故意“挑刺”

## 2.2 安全审查

### 2.2.1 `security-guidance`

- 来源：Anthropic 官方插件
- 定位：开发过程中的自动安全护栏
- 特点：安装并 `/reload-plugins` 后自动运行

### 2.2.2 `/security-review`

- 来源：Claude Code 安全审查 Skill
- 定位：针对当前改动或当前任务的安全 review

### 2.2.3 `/security:security-audit`

- 来源：社区命令集
- 定位：周期性的全仓库安全检查

## 2.3 测试

### 2.3.1 `/test:write-tests`

- 来源：社区命令集
- 定位：围绕目标代码补测试
- 适合场景：
  - 新增业务逻辑后补测试
  - 修 bug 后先写复现测试
  - 安全审计后补边界用例
  - 接手旧代码时批量补测

# 3 模型选择

下面是常见模型别名的实用理解：

| Alias | 常见定位 |
| --- | --- |
| `sonnet` | 日常编码主力 |
| `opus` | 复杂推理、架构设计、复杂调试 |
| `haiku` | 快速小任务、搜索与轻量编辑 |

按任务复杂度选择通常更划算：

| 任务类型 | 推荐模型 | 原因 |
| :--- | :--- | :--- |
| 文件搜索、代码探索 | `haiku` | 速度快、成本低 |
| 简单单文件修改 | `haiku` | 指令明确时足够胜任 |
| 多文件日常实现 | `sonnet` | 综合平衡最好 |
| 复杂架构设计 | `opus` | 更适合长链路推理 |
| PR 审查 | `sonnet` | 质量和成本较平衡 |
| 安全审计 | `opus` | 更适合高要求分析 |
| 写文档 | `haiku` | 结构化输出通常够用 |
| 复杂调试 | `opus` | 适合同时持有更多系统状态 |

# 4 参考

- `https://code.claude.com/docs/zh-CN/cli-reference`
