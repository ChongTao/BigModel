# 1 Codex

`Codex` 是 OpenAI 的代码代理产品，当前主要有三种本地使用形态：

- CLI：在终端里直接运行
- IDE 扩展：在 VS Code 兼容编辑器里侧边协作
- App：桌面端集中管理线程、项目和自动化

如果只看定位，Codex 更接近“可读代码、可改文件、可执行命令、可调用外部工具的工程代理”，而不是普通聊天工具。

## 1.1 适合什么场景

Codex 比较适合：

- 阅读和理解现有代码库
- 批量修改文件
- 执行命令并验证结果
- 根据仓库规则持续协作
- 通过 AGENTS、Skills、Plugins、MCP、Subagents 扩展能力

## 1.2 安装与入口

### 1.2.1 CLI

Windows 下常见安装方式：

```sh
npm install -g @openai/codex
```

如果网络较慢，可以使用镜像：

```sh
npm install -g @openai/codex --registry=https://registry.npmmirror.com
```

安装后直接运行：

```sh
codex
```

首次启动通常会要求登录。常见方式有两种：

- 用 ChatGPT 账号登录
- 用 OpenAI API Key 登录

### 1.2.2 IDE 扩展

Codex 有 IDE 扩展，适合在 VS Code 兼容编辑器里直接协作。它和 CLI 共享同一套本地配置与代理能力。

### 1.2.3 App

Codex App 更像桌面工作台，适合：

- 并行管理多个线程
- 跟踪任务计划、变更和产物
- 配合本地项目、worktree 和自动化使用

## 1.3 常见本地目录

Codex 的本地状态目录通常在：

```text
~/.codex/
```

常见内容包括：

- `config.toml`：主配置文件
- `auth.json`：认证信息或本地凭证状态
- `AGENTS.md`：全局规则
- `agents/`：自定义子代理
- `memories/`：记忆相关状态
- `plugins/`：插件相关内容
- `skills/`：本地技能

项目内也可能出现：

```text
.codex/config.toml
AGENTS.md
```

## 1.4 理解 Codex 的最短路径

如果要快速上手，可以按这个顺序理解：

1. 先看安装和常见操作
2. 再看 `AGENTS.md`
3. 再看 `Skills / Plugins / MCP`
4. 需要复杂任务时再看 `Subagents`

## 1.5 延伸阅读

- [2 Codex常见操作.md](./2%20Codex%E5%B8%B8%E8%A7%81%E6%93%8D%E4%BD%9C.md)
- [4 Codex MCP.md](./4%20Codex%20MCP.md)
- [5 Codex AGENTS.md](./5%20Codex%20AGENTS.md)
- [6 Codex Skill.md](./6%20Codex%20Skill.md)
- [7 Codex Plugin.md](./7%20Codex%20Plugin.md)
- [8 Codex Subagents.md](./8%20Codex%20Subagents.md)
- [11 Codex项目结构.md](./11%20Codex%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84.md)
- [12 Codex 上下文管理.md](./12%20Codex%20%E4%B8%8A%E4%B8%8B%E6%96%87%E7%AE%A1%E7%90%86.md)
- [13 Codex 工作原理.md](./13%20Codex%20%E5%B7%A5%E4%BD%9C%E5%8E%9F%E7%90%86.md)
- [14 Codex IDE与App.md](./14%20Codex%20IDE%E4%B8%8EApp.md)
- [15 Codex 日常使用.md](./15%20Codex%20%E6%97%A5%E5%B8%B8%E4%BD%BF%E7%94%A8.md)
- [16 Codex 配置与认证.md](./16%20Codex%20%E9%85%8D%E7%BD%AE%E4%B8%8E%E8%AE%A4%E8%AF%81.md)
