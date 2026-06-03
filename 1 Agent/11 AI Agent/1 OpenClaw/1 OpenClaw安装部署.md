# OpenClaw 安装部署

**OpenClaw** 是一个开源、自托管的 AI Agent 框架，核心定位是让 Agent 在本地或自管环境里调用模型、技能与渠道，完成真实任务。

- 官网：https://openclaw.ai
- 官方文档：https://docs.openclaw.ai
- GitHub：https://github.com/openclaw/openclaw
- 许可：MIT

## 系统要求

安装前至少确认以下条件：

- **Node.js**：推荐 `v24`，兼容 `v22+`
- **操作系统**：macOS、Linux、Windows
- **Windows 说明**：能原生安装，但**开发和日常运行更推荐 WSL2**
- **网络**：首次安装需要联网拉取 CLI 与依赖
- **模型凭证**：至少准备一个可用模型提供商的 API Key，或提前规划本地模型接入方式

## 推荐安装方式

### macOS / Linux / WSL2

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

如果你只想安装 CLI，不想立刻进入初始化流程：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

### Windows PowerShell

```powershell
iwr https://openclaw.ai/install.ps1 -useb | iex
```

如果要跳过首次引导：

```powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

### 无 root / 无全局 npm 权限

如果机器上不方便做全局安装，可以使用本地前缀安装方式：

```bash
curl -fsSL https://openclaw.ai/install-cli.sh | bash
```

## 首次初始化

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

## 安装后先做的 4 个验证

### 1. 查看 Gateway 状态

```bash
openclaw gateway status
```

### 2. 打开 Dashboard

```bash
openclaw dashboard
```

默认会打开本地 Dashboard，便于检查模型、渠道、技能和运行状态。

### 3. 看一次整体状态

```bash
openclaw status --deep
```

### 4. 跑一次诊断

```bash
openclaw doctor
```

## 关键目录与配置文件

OpenClaw 安装后的常见目录如下：

| 路径 | 说明 |
| :--- | :--- |
| `~/.openclaw/openclaw.json` | 主配置文件 |
| `~/.openclaw/workspace/` | 认知文件系统与长期工作区 |
| `~/.openclaw/agents/<agentId>/sessions/` | Agent 会话目录 |
| `~/.openclaw/logs/` | 运行日志 |

其中最重要的是：

- `openclaw.json`：模型、Gateway、渠道等主配置
- `workspace/`：记忆、行为说明、任务上下文

## 常用命令

下面只保留安装部署阶段最常用、且值得长期记住的命令。

### Gateway

```bash
# 启动默认 Gateway
openclaw gateway

# 将 Gateway 安装为后台服务
openclaw gateway install

# 启动 / 停止 / 重启后台 Gateway
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# 查看状态
openclaw gateway status
```

### 渠道管理

```bash
# 查看所有渠道（含未启用）
openclaw channels list --all

# 探测渠道状态
openclaw channels status --probe

# 新增渠道
openclaw channels add telegram

# 移除渠道
openclaw channels remove telegram

# 查看渠道日志
openclaw channels logs --channel all
```

### 技能管理

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

# 检查技能完整性
openclaw skills check
```

### 配置管理

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

### Memory 与状态排查

```bash
# 查看记忆系统状态
openclaw memory status

# 强制重建索引
openclaw memory index --force

# 搜索记忆
openclaw memory search "deployment"

# 将当前上下文提升为长期记忆
openclaw memory promote --apply

# 快速健康检查
openclaw health --verbose

# 安全审计
openclaw security audit
```

## 部署建议

### 个人机器

个人使用优先选择：

1. 官方安装脚本
2. `openclaw onboard --install-daemon`
3. 本地 Dashboard 验证

这条路径最适合长期常驻的自托管 Agent。

### Windows

Windows 可以直接安装，但有两点要注意：

1. 如果要做插件开发、脚本编排或依赖更多 Unix 工具，优先使用 **WSL2**
2. 如果是原生 Windows 运行，优先用 PowerShell 安装脚本，不要混用多套 Node/npm 环境

### 云服务器

如果要部署到云上，建议选择一台干净的 Linux 主机，按以下顺序执行：

1. 安装 Node.js
2. 运行官方安装脚本
3. 执行 `openclaw onboard --install-daemon`
4. 用反向代理统一暴露入口
5. 上线前执行 `openclaw doctor` 与 `openclaw security audit`

不建议直接采用来源不明的“一键镜像”或第三方打包脚本。

默认情况下优先保持 Gateway 仅监听本机地址；如果必须暴露到局域网、Tailscale 或公网，至少同步配置认证令牌、反向代理和最小化访问面。

### Docker

如果你的目标是：

- 和宿主机环境隔离
- 便于迁移
- 在服务器中统一纳管

可以再评估 Docker 方案；但对个人机器来说，官方安装脚本通常比容器方式更直接。

## 一个最小可用流程

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

## 参考

- https://docs.openclaw.ai/start/getting-started
- https://docs.openclaw.ai/zh-CN/platforms/windows
- https://docs.openclaw.ai/cli/reference
- https://github.com/openclaw/openclaw
