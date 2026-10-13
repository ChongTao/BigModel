# Hermes 安装部署

**Hermes Agent** 是 Nous Research 开源的自进化 AI Agent，核心特点是长期运行、跨会话记忆、自生成 Skill、工具密集和多入口接入。

- 官网：https://hermes-agent.nousresearch.com/docs/
- GitHub：https://github.com/NousResearch/hermes-agent
- 参考项目介绍：https://github.com/NousResearch/hermes-agent/blob/main/README.zh-CN.md

## 1 安装

### Linux / macOS / WSL2 CLI

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

安装后重新加载 shell：

```bash
source ~/.bashrc
# 或
source ~/.zshrc
```

## 2 首次初始化

Hermes 的最快可用路径通常是：

```bash
hermes setup --portal
```

这条路径会一次性处理：

1. 提供商接入
2. 模型配置
3. Tool Gateway 接入
4. 基础运行环境初始化

## 3 关键目录与配置文件

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

## 4 常用命令

### 4.1 基础命令

```bash
hermes
hermes setup
hermes model
hermes tools
hermes doctor
hermes update
```

### 4.2 Gateway

```bash
hermes gateway
```

Gateway 是 Hermes 的长生命周期入口，适合接 Telegram、Discord、Slack、WhatsApp、Signal 等平台。要把它长期挂成后台服务，可以继续使用：

```bash
hermes gateway install
```

### 4.3 Sessions

```bash
hermes sessions
```

会话是 Hermes 长期运行的重要基础。Hermes 会把对话、压缩、跨平台来源和历史检索能力都落到 session 体系中。

### 4.4 Skills 与 Plugins

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

## 5 参考

- https://hermes-agent.nousresearch.com/docs/getting-started/installation/
- https://hermes-agent.nousresearch.com/docs/getting-started/quickstart/
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- https://hermes-agent.nousresearch.com/docs/user-guide/windows-wsl-quickstart
- https://hermes-agent.nousresearch.com/docs/user-guide/configuration/
- https://github.com/NousResearch/hermes-agent/blob/main/README.zh-CN.md
- https://www.runoob.com/hermes-agent/hermes-agent-tutorial.html
