# Claude Code 日常使用

# 1 常用斜杠命令

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

## 1.4 内置 Skills

| 命令 | 作用 |
| --- | --- |
| `/simplify` | 审查代码，找重用、质量和效率问题并修复。详见 [代码检查工具](./14%20Claude%20Code%20代码检查工具.md) |
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

---

# 3 快捷键

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+C` | 中断当前操作 |
| `Ctrl+B` | 将当前任务放到后台运行 |
| `Shift+Enter` | 换行输入（需先通过 `/terminal-setup` 配置） |
| `↑ / ↓` | 浏览历史输入 |

---

# 4 启动参数

```sh
# 使用指定模型启动
claude --model claude-opus-4-6

# 以指定子代理身份启动整个会话
claude --agent code-reviewer

# 加载插件（开发测试）
claude --plugin-dir ./my-plugin

# 禁用自动记忆（临时）
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude

# 在指定目录启动
claude /path/to/project
```

---

# 5 上下文管理技巧

| 场景 | 建议操作 |
| --- | --- |
| 对话已很长，Claude 开始重复或遗忘 | 立即 `/compact`，不要继续在同一会话中纠正 |
| 任务已完成，准备切换新任务 | `/clear` 彻底清空 |
| 读取大文件或长日志 | 要求只输出关键部分，如"只显示 ERROR 级别的日志" |
| 反复用到同一提示词 | 保存为 `.claude/commands/` 自定义命令 |
| Claude 两次记错同一规范 | 让 Claude 写入 CLAUDE.md 固化 |
