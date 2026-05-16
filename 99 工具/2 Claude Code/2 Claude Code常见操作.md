# 1 Claude Code常见操作

## 1.1 首次启动 Claude Code

在项目目录下执行`claude`命令，然后和`claude`进行交互，退出时输入`/exit`命令。启动时可通过以下参数指定行为：

```sh
# 直接启动
claude

# 指定项目目录，不需要切换到对应目录下
claude /path/my-project

# 跳过权限认证，进入时需要重新确认
claude --dangerously-skip-permissions

# 显示详细的思考、执行过程，包括读取的文件内容
claude --verbose

# 指定模型启动，也可以在执行过程中切换模型， 简写: -m
claude --model <name> 

# 恢复最近会话，继续之前的工作 简写: -c
claude --continue

# 恢复指定会话 简写: -r
claude --resume <id>
```

## 1.2 输入前缀快捷操作

Claude Code支持以下特殊输入前缀：

- `@`：文件路径自动补全，如`@internal/tpms`
- `!`：直接执行 bash 命令，如`!ls`
- `#`：向 Claude 写入单次系统提示注记，如`#请用中文回复`

## 1.3 对话技巧

- 使用`/clear`清空对话，适用场景：当一个任务完成，开始新的任务时。注意解决同一个任务时不需使用该命令。

- 使用`/compact`压缩对话，使用场景：

  - Token接近上限（使用`/context`查看使用）。
  - 响应变慢，还需要上下文。


## 1.4 上下文管理

- `/context` - 可视化上下文使用，显示展示Token使用情况，包括Token使用情况等。

- `/cost`：显示当前会话的 Token 总成本。
- `/usage`：显示详细使用统计。

- `/model`： 切换AI模型。

- `/effort` ：调整Claude的思考深度，有low、medium、high、xhigh和max选项。

- 自动记忆：Claude Code自动记录会话重要信息，自动写入到memory文件中.

  - 如果没有指定路径，每个project项目在`~/.claude/projects/<项目完整路径（经过编码）>/memory/`目录下记录该项目的记忆；

  - 在 `~/.claude/settings.json` 中指定记忆存储目录：

    ```json
    {
      "autoMemoryDirectory": "~/.claude/memory/"
    }
    ```

## 1.5 回退

Claude有个Checkpoint（检查点）就像游戏存档，Rewind（回退）就是读档。

- 双击Escape键，选择要回退的checkpoint。

  ```sh
  Rewind to…
  
  Select a message to restore code and fork the conversation from that point.
  ```

- `/rewind`命令

有三种选项可供选择：

- **仅恢复对话**：保留代码修改，重置上下文。
- **仅恢复代码**：保留上下文，代码修改回退。
- **同时恢复**：代码和上下文都回退。

## 1.6 会话管理

- `/resume`：恢复之前的对话会话，例如重启电脑，恢复昨天的工作。
- `/export`: 把当前对话导出为纯文本文件。
- `/rename` ： 重命名会话。
- `/exit`：退出当前 Claude 会话。

## 1.7 项目配置

- `/init`：初始化项目配置，创建CLAUDE.md文件。
- `/memory`：编辑记忆文件，可选择哪层的记忆文件。
- `/permissions` ： 查看和修改Claude的权限设置。

## 1.8 MCP 配置

- `/mcp`：查看和管理MCP服务器连接。
- `/plugin` ：管理 Claude Code 插件。
- `/hooks`： 管理配置在特定事件触发的自动化脚本。

## 1.9 其它

- `/security-review`：分析当前尚未提交的改动，找安全问题（需对应 MCP 插件支持，或在终端使用自然语言指令触发）。
- `/agents`：管理和查看Claude的子代理。
- `/doctor` ：检查Claude Code安装的健康状态。
- `/status` ：完整状态信息。
- `/stats`： 统计使用习惯。
- `/config`： 统一设置入口

# 2 Claude Code 模型选择

当前官方主要模型（截至 2026-05）：

| Alias    | 实际模型 ID                          | 实际用途          | 推荐度 |
| -------- | ------------------------------------ | ----------------- | ------ |
| `sonnet` | `claude-sonnet-4-6`                  | 日常编码主力      | ⭐⭐⭐⭐⭐  |
| `opus`   | `claude-opus-4-7`                    | 复杂推理/架构设计 | ⭐⭐⭐⭐   |
| `haiku`  | `claude-haiku-4-5-20251001`          | 快速小任务        | ⭐⭐⭐    |

黑客松冠军仓库（参考：[Anthropic Hackathon Winners](https://github.com/anthropics/anthropic-hackathon)）的一个核心实践是**按任务复杂度路由到不同模型**。他们的经验总结：

| 任务类型             | 推荐模型   | 原因                                 |
| :------------------- | :--------- | :----------------------------------- |
| 文件搜索、代码探索   | **Haiku**  | 速度快、成本低、搜索类任务准确率够用 |
| 简单编辑、单文件修改 | **Haiku**  | 指令明确时 Haiku 完全能胜任          |
| 多文件实现、日常编码 | **Sonnet** | 90% 场景的最佳平衡点                 |
| 复杂架构设计         | **Opus**   | 需要在脑中同时持有整个系统           |
| PR 审查              | **Sonnet** | 理解上下文够用，能抓到细微问题       |
| 安全审计             | **Opus**   | 安全漏洞不能漏，值得花更多 token     |
| 写文档               | **Haiku**  | 结构简单，不需要深度推理             |
| 复杂调试             | **Opus**   | 需要在脑中持有整个系统状态           |



