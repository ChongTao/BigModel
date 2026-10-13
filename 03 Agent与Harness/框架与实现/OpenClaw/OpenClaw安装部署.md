# OpenClaw 安装部署

**OpenClaw** 是一个开源、自托管的 AI Agent 框架，核心定位是让 Agent 在本地或自管环境里调用模型、技能与渠道，完成真实任务。

- 官网：https://openclaw.ai
- 官方文档：https://docs.openclaw.ai
- GitHub：https://github.com/openclaw/openclaw
- 许可：MIT

## 1 系统要求

安装前至少确认以下条件：

- **Node.js**：推荐 `v24`，兼容 `v22.19+`
- **操作系统**：macOS、Linux、Windows
- **Windows 说明**：能原生安装，但**开发和日常运行更推荐 WSL2**
- **网络**：首次安装需要联网拉取 CLI 与依赖
- **模型凭证**：至少准备一个可用模型提供商的 API Key，或提前规划本地模型接入方式

## 2 推荐安装方式

### 2.1 官方安装脚本：macOS / Linux / WSL2

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

如果你只想安装 CLI，不想立刻进入初始化流程：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

### 2.2 官方安装脚本：Windows PowerShell

```powershell
iwr https://openclaw.ai/install.ps1 -useb | iex
```

如果要跳过首次引导：

```powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

### 2.3 包管理器安装

如果你已经自己管理 Node 环境，也可以直接使用包管理器：

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

```bash
pnpm add -g openclaw@latest
pnpm approve-builds -g
openclaw onboard --install-daemon
```

```bash
bun add -g openclaw@latest
openclaw onboard --install-daemon
```

### 2.4 从源码运行

如果你要参与开发，或需要从本地源码启动：

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build
pnpm ui:build
pnpm link --global
openclaw onboard --install-daemon
```

## 3 首次初始化

安装 CLI 后，建议立刻执行一次引导：

```bash
openclaw onboard --install-daemon
```

这个流程通常会完成以下动作：

1. 检查 Node.js、网络和本机运行条件
2. 初始化 `~/.openclaw/`
3. 创建默认 workspace
4. 配置模型提供商凭证
5. 安装并注册 Gateway 后台服务

如果你已经安装过，只是想重新调整配置：

```bash
openclaw configure
```

如果只需要重建本地基础目录：

```bash
openclaw setup
```

## 4 安装后先做的 5 个验证

### 4.1 检查 CLI 是否可用

```bash
openclaw --version
```

### 4.2 查看 Gateway 状态

```bash
openclaw gateway status
```

### 4.3 打开 Dashboard

```bash
openclaw dashboard
```

默认会打开本地 Dashboard，便于检查模型、渠道、技能和运行状态。

### 4.4 看一次整体状态

```bash
openclaw status --deep
```

### 4.5 跑一次诊断

```bash
openclaw doctor
```

## 5 关键目录与配置文件

OpenClaw 安装后的常见目录如下：

| 路径 | 说明 |
| :--- | :--- |
| `~/.openclaw/openclaw.json` | 主配置文件 |
| `~/.openclaw/workspace/` | 认知文件系统与长期工作区 |
| `~/.openclaw/logs/` | 运行日志 |

其中最重要的是：

- `openclaw.json`：模型、Gateway、渠道、agents 等主配置
- `workspace/`：记忆、行为说明、任务上下文

> 说明：
> 当前官方配置文档以 `~/.openclaw/openclaw.json` 为主配置文件；如果你在本仓库其它文档里看到更抽象的 `config.yml` 表述，应优先以官方当前配置文件口径为准。

## 6 常用命令

下面只保留安装部署阶段最常用、且值得长期记住的命令。

### 6.1 Gateway

```bash
# 启动默认 Gateway
openclaw gateway run

# 将 Gateway 安装为后台服务
openclaw gateway install

# 启动 / 停止 / 重启后台 Gateway
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# 查看状态
openclaw gateway status

# 升级openclaw
openclaw update
```

### 6.2 渠道管理

```bash
# 查看所有渠道（含未启用）
openclaw channels list --all

# 探测渠道状态
openclaw channels status --probe

# 新增渠道
openclaw channels add telegram

# 移除渠道
openclaw channels remove telegram

# 实时探测渠道状态
openclaw channels status --probe
```

### 6.3 技能管理

```bash
# 搜索技能
openclaw skills search github

# 安装技能
openclaw skills install github

# 列出已安装技能
openclaw skills list

# 查看技能详情
openclaw skills info github

# 更新技能
openclaw skills update

# 检查技能安装状态
openclaw skills check
```

### 6.4 配置管理

```bash
# 查看配置文件位置
openclaw config file

# 校验配置
openclaw config validate

# 读取单个配置项
openclaw config get gateway.port

# 修改单个配置项
openclaw config set gateway.port 18789
```

## 7 一个最小可用流程

```bash
# 1. 安装
curl -fsSL https://openclaw.ai/install.sh | bash

# 2. 初始化并注册后台服务
openclaw onboard --install-daemon

# 3. 检查 Gateway
openclaw gateway status

# 4. 打开 Dashboard
openclaw dashboard

# 5. 跑一次诊断
openclaw doctor
```

## 8 参考

- https://docs.openclaw.ai/start/getting-started
- https://docs.openclaw.ai/zh-CN/platforms/windows
- https://docs.openclaw.ai/cli/reference
- https://github.com/openclaw/openclaw
