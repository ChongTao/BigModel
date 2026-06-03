# Hermes 安装部署

**Hermes Agent** 是 Nous Research 开源的自进化 AI Agent，核心特点是长期运行、跨会话记忆、自生成 Skill、工具密集和多入口接入。

- 官网：https://hermes-agent.nousresearch.com/docs/
- GitHub：https://github.com/NousResearch/hermes-agent
- 参考项目介绍：https://github.com/NousResearch/hermes-agent/blob/main/README.zh-CN.md

## 1 系统要求

安装前建议先确认：

- **Python**：推荐使用项目当前安装脚本默认路径，避免手动混装多套 Python 环境
- **操作系统**：Linux、macOS、Windows
- **安装入口**：macOS / Windows / Linux 可以优先考虑 Desktop；Linux / macOS / WSL2 也可以直接走 CLI 安装脚本
- **Windows 说明**：当前同时支持原生 Windows 和 WSL2；如果你更依赖类 Unix 工具链、嵌入式终端或开发调试，优先选 WSL2
- **网络**：首次安装需要联网拉取依赖、模型或工具网关配置
- **模型凭证**：至少准备一个可用模型提供商，或直接走 `hermes setup --portal`

## 2 推荐安装方式

### 2.1 Desktop（macOS / Windows / Linux）

如果你的目标是最快上手，优先使用 Hermes Desktop。它适合：

1. 希望少碰环境依赖和 shell 初始化
2. 希望直接获得图形化入口
3. 需要在桌面端统一管理配置、会话和工具状态

### 2.2 Linux / macOS / WSL2 CLI

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

安装后重新加载 shell：

```bash
source ~/.bashrc
# 或
source ~/.zshrc
```

### 2.3 Windows PowerShell（原生）

Hermes 官方当前已经提供原生 Windows 路径。如果你不打算依赖 WSL2，也可以走 Windows Native Guide 对应的 PowerShell 安装路径。

更适合原生 Windows 的场景：

1. 你主要使用桌面端或 PowerShell
2. 你不依赖类 Unix 的 shell 工具链
3. 你不需要 Dashboard 的 POSIX PTY 终端体验

### 2.4 从源码运行

如果你要参与开发、排查问题或阅读实现：

```bash
git clone https://github.com/NousResearch/hermes-agent.git
cd hermes-agent
./setup-hermes.sh
```

源码方式更适合：

- 阅读 `run_agent.py`、`gateway/`、`tools/`、`skills/`
- 调试技能、插件、provider 或 gateway
- 跟踪主干更新

## 3 首次初始化

Hermes 的最快可用路径通常是：

```bash
hermes setup --portal
```

这条路径会一次性处理：

1. 提供商接入
2. 模型配置
3. Tool Gateway 接入
4. 基础运行环境初始化

如果你不走 Portal，也可以拆开执行：

```bash
hermes setup
hermes model
hermes tools
```

推荐理解为：

- `hermes setup`：第一次完整设置
- `hermes model`：挑选或切换模型
- `hermes tools`：启用或管理工具

## 4 安装后先做的 5 个验证

### 4.1 检查 CLI

```bash
hermes --help
```

### 4.2 启动一次对话

```bash
hermes
```

### 4.3 选择模型

```bash
hermes model
```

### 4.4 查看工具状态

```bash
hermes tools
```

### 4.5 跑一次诊断

```bash
hermes doctor
```

## 5 关键目录与配置文件

Hermes 当前最重要的本地目录主要集中在 `~/.hermes/`：

| 路径 | 说明 |
| :--- | :--- |
| `~/.hermes/config.yaml` | 主配置文件，保存非敏感配置 |
| `~/.hermes/.env` | 环境变量与敏感信息 |
| `~/.hermes/state.db` | SQLite 状态库，保存 session 元数据、消息历史和模型配置 |
| `~/.hermes/MEMORY.md` | 内置持久记忆文件，保存长期可复用的个人/项目记忆 |
| `~/.hermes/USER.md` | 用户画像与偏好信息的内置记忆文件 |
| `~/.hermes/skills/` | Skill 主目录，也是 Skill 的主要来源目录 |
| `~/.hermes/plugins/` | 用户插件目录 |

如果你使用 **profiles**，每个 profile 都会有自己独立的一套目录、配置、`.env`、`SOUL.md`、sessions、skills、cron jobs 和 state database。

## 6 常用命令

### 6.1 基础命令

```bash
hermes
hermes setup
hermes model
hermes tools
hermes doctor
hermes update
```

### 6.2 Gateway

```bash
hermes gateway
```

Gateway 是 Hermes 的长生命周期入口，适合接 Telegram、Discord、Slack、WhatsApp、Signal 等平台。要把它长期挂成后台服务，可以继续使用：

```bash
hermes gateway install
```

### 6.3 Sessions

```bash
hermes sessions
```

会话是 Hermes 长期运行的重要基础。Hermes 会把对话、压缩、跨平台来源和历史检索能力都落到 session 体系中。

### 6.4 Skills 与 Plugins

```bash
hermes skills
hermes plugins
```

这里建议区分：

- **Skills**：按需加载的知识文档 / 工作流能力
- **Plugins**：扩展工具、hook、CLI 命令、provider、gateway 平台等底层能力

如果要启用某个已发现但默认未启用的插件，可以直接使用：

```bash
hermes plugins enable <plugin-name>
```

## 7 部署建议

### 7.1 个人机器

个人使用优先建议：

1. 官方安装脚本
2. `hermes setup --portal`
3. `hermes`
4. `hermes model`
5. `hermes tools`

这条路径最适合快速体验 Hermes 的“会话 + 技能 + 工具 + 学习闭环”。

### 7.2 Windows

Windows 有两个主要选择：

1. **原生 Windows**：适合偏桌面使用和 PowerShell 用户
2. **WSL2**：适合插件开发、类 Unix 工具链、终端体验和 Dashboard 的嵌入终端

如果你的目标更偏工程开发，优先 WSL2。

### 7.3 服务器 / VPS

Hermes 很适合长期运行在 VPS 上，尤其适合：

- 挂载 Gateway 做多平台入口
- 通过 cron 做自动化
- 让 agent 持续沉淀 skills、sessions 和 memory

上线前建议至少确认：

1. 模型与 API 可用
2. `hermes doctor` 无关键错误
3. 所有对外平台只开放必要入口
4. secrets 只放在 `.env` 或安全注入链路中

### 7.4 Docker

如果你的诉求是：

- 环境隔离
- 便于迁移
- 统一纳管

可以再评估 Docker 方案；但对第一次上手来说，官方安装脚本通常更直接。

## 8 一个最小可用流程

```bash
# 1. 安装
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# 2. 初始化
hermes setup --portal

# 3. 启动对话
hermes

# 4. 检查模型
hermes model

# 5. 检查工具
hermes tools

# 6. 跑一次诊断
hermes doctor
```

## 9 参考

- https://hermes-agent.nousresearch.com/docs/getting-started/installation/
- https://hermes-agent.nousresearch.com/docs/getting-started/quickstart/
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration/
- https://github.com/NousResearch/hermes-agent/blob/main/README.zh-CN.md
