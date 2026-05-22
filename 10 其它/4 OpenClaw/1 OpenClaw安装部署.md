# OpenClaw

**OpenClaw** 是一个开源的、自托管的 AI Agent 框架，基于 Node.js v22 构建。

它能通过自然语言指挥电脑完成真实任务，从"对话 AI"进化为"执行 AI"。

- **官网**：https://openclaw.ai
- **中国社区**：https://open-claw.org.cn（推荐中国用户）
- **GitHub**：https://github.com/openclaw/openclaw
- **Gitee**（中国镜像）：https://gitee.com/openclaw/openclaw
- **许可**：MIT

## 核心特性

### 国产大脑原生支持
- 源码级内置 DeepSeek-V3 / Qwen 支持，开箱即用
- 无需兼容层，性能更优

### 高效开发
- 预配置 npmmirror 镜像，依赖安装速度提升 10 倍
- 基于 Node.js v22 沙箱机制确保文件操作权限可控

### 数据安全
- 本地运行，数据完全自主
- 无需上传至第三方服务

### 办公集成
- 正在开发飞书与企业微信连接器
- ClawHub 技能市场供插件下载



## 传统 AI vs OpenClaw

| 维度 | 传统 AI | OpenClaw |
| :--- | :--- | :--- |
| 能力边界 | 只能对话和提供建议 | 能操作文件、浏览器、执行脚本 |
| 数据安全 | 依赖云端，数据上传第三方 | 本地运行，数据完全自主 |
| 推理引擎 | 云端受限 | 国产大脑原生支持（DeepSeek-V3 / Qwen） |
| 执行方式 | 人工根据建议手动操作 | 自动规划并执行多步骤任务 |



## 系统要求

- **Node.js**：v22 或更高版本
- **操作系统**：Linux、macOS、Windows
- **内存**：建议 2GB 以上
- **网络**：互联网连接

## 安装

### 一键安装（推荐）

**中国用户**（自动配置npmmirror加速，依赖安装快 10 倍）：
```sh
curl -fsSL https://open-claw.org.cn/install-cn.sh | bash
```

**国际用户**：
```sh
curl -fsSL https://openclaw.ai/install.sh | bash
```

### 初始化配置

安装完成后进行配置向导：

```sh
# 交互式配置向导（推荐首次使用）
openclaw onboard

# 快速启动模式（跳过详细配置）
openclaw onboard --flow quickstart
```

## 云平台一键部署

中国用户可在以下平台实现一键部署：
- 阿里云
- 腾讯云
- 百度云
- 火山云

## 常用命令

### Gateway 管理

```sh
# 启动 Gateway 服务
openclaw gateway start

# 停止 Gateway 服务
openclaw gateway stop

# 重启 Gateway 服务
openclaw gateway restart

# 查看 Gateway 状态
openclaw gateway status

# 查看 Gateway 日志（实时）
openclaw gateway logs -f

# 查看特定行数的日志
openclaw gateway logs -n 100
```

### 技能（Skills）管理

```sh
# 列出所有可用的技能
openclaw skills list

# 搜索特定技能
openclaw skills search <关键词>

# 安装技能
openclaw skills install <技能名>

# 卸载技能
openclaw skills uninstall <技能名>

# 升级所有技能到最新版本
openclaw skills upgrade

# 查看技能详情
openclaw skills info <技能名>
```

### 配置管理

```sh
# 查看当前配置
openclaw config view

# 编辑配置文件
openclaw config edit

# 验证配置文件合法性
openclaw config validate

# 重置为默认配置
openclaw config reset
```

### 认知文件管理

```sh
# 查看工作区路径
openclaw workspace path

# 打开工作区目录
openclaw workspace open

# 查看内存统计
openclaw memory stats

# 重建内存索引（当嵌入发生变化时）
openclaw memory rebuild

# 导出记忆文件
openclaw memory export

# 导入记忆文件
openclaw memory import <文件路径>

# 清理过期的工作记忆
openclaw memory clean
```

### 渠道管理

```sh
# 列出所有已安装的渠道
openclaw channels list

# 查看渠道状态
openclaw channels status

# 启用特定渠道
openclaw channels enable <渠道名>

# 禁用特定渠道
openclaw channels disable <渠道名>

# 重新授权渠道（刷新凭证）
openclaw channels reauth <渠道名>

# 测试渠道连接
openclaw channels test <渠道名>
```

### Agent 和任务

```sh
# 启动 Agent 服务
openclaw agent start

# 停止 Agent 服务
openclaw agent stop

# 查看活跃的 Agent 进程
openclaw agent list

# 查看 Agent 日志
openclaw agent logs

# 手动触发 HEARTBEAT（定时任务）
openclaw heartbeat run

# 查看待执行的定时任务
openclaw heartbeat list
```

### 调试和诊断

```sh
# 查看 OpenClaw 版本
openclaw version

# 查看系统信息
openclaw system info

# 运行健康检查
openclaw health check

# 启用调试模式（详细日志）
openclaw --debug start

# 导出诊断报告（用于问题排查）
openclaw diagnose

# 验证所有依赖和插件
openclaw doctor
```

### 开发者命令

```sh
# 本地开发模式启动（支持热重载）
openclaw dev

# 构建项目
openclaw build

# 运行测试
openclaw test

# 创建新插件模板
openclaw plugin create <插件名>

# 在本地测试插件
openclaw plugin test <插件路径>

# 发布插件到 ClawHub
openclaw plugin publish
```

### 账户和认证

```sh
# 查看已链接的账户
openclaw accounts list

# 链接新账户（某个渠道）
openclaw accounts link <渠道名>

# 取消链接账户
openclaw accounts unlink <账户ID>

# 管理 API Key
openclaw keys add <提供商> <API_KEY>

openclaw keys list

openclaw keys delete <提供商>
```

---

## 常见使用场景

### 场景 1：首次安装和配置

```sh
# 1. 一键安装
curl -fsSL https://open-claw.org.cn/install-cn.sh | bash

# 2. 初始化配置（交互式）
openclaw onboard

# 3. 验证安装
openclaw health check

# 4. 查看 Gateway 是否正常运行
openclaw gateway status
```

### 场景 2：添加新渠道（以 Telegram 为例）

```sh
# 1. 获取 Telegram Bot Token（从 @BotFather 处获取）
# 2. 配置渠道
openclaw channels enable telegram

# 3. 设置认证信息
openclaw config edit  # 在 config.yml 中填入 TELEGRAM_BOT_TOKEN

# 4. 重启 Gateway
openclaw gateway restart

# 5. 测试连接
openclaw channels test telegram
```

### 场景 3：安装和使用技能

```sh
# 1. 搜索想要的技能
openclaw skills search github

# 2. 安装技能
openclaw skills install github

# 3. 查看技能详情
openclaw skills info github

# 4. 在 Agent 中自动识别新能力（已安装后自动）
openclaw gateway restart
```

### 场景 4：查看和管理记忆

```sh
# 1. 查看记忆统计
openclaw memory stats

# 2. 打开工作区编辑记忆文件
openclaw workspace open

# 3. 如果修改了嵌入模型，重建索引
openclaw memory rebuild

# 4. 导出记忆备份
openclaw memory export
```

### 场景 5：问题排查

```sh
# 1. 运行健康检查
openclaw health check

# 2. 查看完整日志
openclaw gateway logs -n 500

# 3. 导出诊断报告
openclaw diagnose

# 4. 启用调试模式重现问题
openclaw --debug gateway start

# 5. 查看系统信息
openclaw system info
```

---

## 环境变量速查

常用的环境变量配置：

```bash
# AI 模型提供商
export ANTHROPIC_API_KEY=sk-xxxx
export DEEPSEEK_API_KEY=sk-xxxx
export OPENAI_API_KEY=sk-xxxx
export QWEN_API_KEY=sk-xxxx

# 消息渠道
export TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
export SLACK_BOT_TOKEN=xoxb-xxxx
export DISCORD_TOKEN=xxxx

# OpenClaw 运行配置
export OPENCLAW_PORT=3000
export OPENCLAW_LOG_LEVEL=info  # debug / info / warn / error
export OPENCLAW_WORKSPACE_DIR=~/.openclaw/workspace
```

---

## 更多资源

- **官方文档**：https://docs.openclaw.ai
- **API 参考**：https://docs.openclaw.ai/api
- **插件开发指南**：https://docs.openclaw.ai/plugins/development
- **社区论坛**：https://open-claw.org.cn/community
- **GitHub Issues**：https://github.com/openclaw/openclaw/issues
