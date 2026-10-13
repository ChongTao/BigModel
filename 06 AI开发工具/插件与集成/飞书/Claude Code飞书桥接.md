# 2 Feishu Claude Code Bridge

## 2.1 是什么

`lark-channel-bridge`（npm 包名，GitHub 仓库叫 `feishu-claude-code-bridge`）是一个把 **飞书消息** 和 **本地 Claude Code CLI** 连接起来的桥接工具。

它的核心价值很直接：

- 你不用切出飞书去单独打开终端
- 可以直接在飞书里和本地 Claude Code 交互
- 适合把“聊天入口”放在飞书，把“执行能力”留在本机

如果你已经在本地用 Claude Code 做开发，这个 bridge 的意义不是替代 Claude Code，而是给它补一个 **飞书入口**。

## 2.2 主要功能

从使用视角看，这个工具最重要的能力有下面几类。

### 2.2.1 飞书内直接对话

你可以在飞书群或会话里直接给 Claude 发消息，让它继续在本地工作，而不是来回切换窗口。

### 2.2.2 实时返回结果

Claude 的回复、执行状态和部分工具输出，可以持续回流到飞书，适合做“边问边看结果”的交互。

### 2.2.3 文件与图片输入

可以把文件、图片等内容从飞书侧交给 Claude 做分析、总结或处理。

### 2.2.4 会话隔离

不同聊天通常会对应不同 session，避免多个飞书对话互相串上下文。

### 2.2.5 消息调度

新消息可以打断旧任务；连续消息也可以被合并处理，减少重复执行。

### 2.2.6 权限控制

可以通过白名单限制允许使用的人或群，适合从个人使用逐步过渡到小团队协作。

## 2.3 适合什么场景

这个 bridge 特别适合下面几类场景：

- **团队代码讨论**：在群里直接贴代码、截图、日志，让 Claude 辅助分析
- **文档快速处理**：上传文档后，让 Claude 做总结、翻译、整理
- **问题即时解答**：不切应用，直接在飞书里问本地 Claude
- **轻量流程协作**：配合 `lark-cli` 做“讨论 -> 生成文档 -> 发布 -> 通知”的闭环

它最适合的不是重型平台化部署，而是“我已经在本地用 Claude Code，现在想把入口放到飞书里”。

## 2.4 前置条件

在实际使用前，通常至少要准备好下面几项：

- **Node.js 20+**
- **Claude CLI / Claude Code 已可在本地使用**
- **飞书 Personal Agent 或对应应用配置完成**

如果本地 Claude Code 本身还没跑通，不建议先折腾 bridge。  
更稳妥的顺序是：

1. 先确认本地 `claude` 可以正常工作
2. 再把飞书接入补上

## 2.5 基本使用

## 2.5.1 启动

最直接的方式是前台启动：

```bash
lark-channel-bridge run
```

如果你希望它长期驻留运行，可以使用 daemon 模式：

```bash
# 启动后台守护进程
lark-channel-bridge start

# 停止守护进程
lark-channel-bridge stop

# 查看状态
lark-channel-bridge status
```

多 profile：分别运行 Claude 和 Codex
默认情况下，bridge 使用当前激活的 profile；可以通过 profile use <name> 切换。每个 profile 会维护独立的应用凭据、会话、工作目录和日志。只有在需要同时连接多个 PersonalAgent 应用，或分别运行 Claude 和 Codex 时，才需要创建多个 profile：
```bash
lark-channel-bridge start --profile claude --agent claude
lark-channel-bridge start --profile codex --agent codex
例如只重启 Codex bot：

lark-channel-bridge restart --profile codex
lark-channel-bridge status --profile codex
```


## 2.5.2 飞书侧怎么用

基本交互方式可以理解为：

1. 在飞书里向 Claude 发送消息
2. bridge 把消息转给本地 Claude Code
3. Claude 在本机执行分析、读取文件、生成回复
4. 结果再回传到飞书

也就是说，飞书负责：

- 发起请求
- 展示回复
- 上传附件

本地 Claude Code 负责：

- 真正的推理与执行
- 读写本地文件
- 调用本地命令和工具

## 2.5.3 访问控制

如果不想让所有飞书用户都能调用本地 Claude，可以加白名单。

例如：

```bash
lark-channel-bridge run --user-whitelist "user_id1,user_id2"
lark-channel-bridge run --chat-whitelist "chat_id1,chat_id2"
```

常见做法是：

- **个人使用**：只放自己的 user whitelist
- **小团队试用**：限制在几个群里
- **团队协作**：再补管理员权限或更严格的访问控制

## 2.5.4 输出偏好：关闭思考过程，只看最终结果

0.7.x 的 `/config` 里有三个互相独立的展示开关：

| 开关 | 配置键 | 可选值 | 作用 |
|---|---|---|---|
| 消息回复方式 | `messageReply` | `markdown` 消息卡片（默认，流式）/ `text` 纯文本（run 结束后一次性发出） | 最终回复的载体 |
| 工具调用显示 | `showToolCalls` | `show`（默认）/ `hide` | 最终回复里是否保留工具块 |
| COT 过程消息 | `cotMessages` | `off` 关闭（默认）/ `brief` 简略 / `detailed` 详细 | 是否额外发一条过程消息 |

**只要最终结果**，就设成：COT 过程消息 = `关闭`、工具调用显示 = `隐藏`、消息回复方式 = `纯文本`。

COT 三档的差别：

- `off`：只发最终回复，一条消息
- `brief`：先发一条过程消息，展示 agent 的过程文本和工具摘要，再单独发最终答案
- `detailed`：在简略基础上再带上工具参数和截断后的输出

开启 COT 后，过程消息和最终答案是**两条独立消息**。最终答案会先过一道 `finalAnswerOnlyState`：清空 reasoning、丢掉工具块，只留 agent 的最终文本，所以思考内容不会混进最终回复。但 bridge 不对最终答案做启发式过滤——如果 agent 把最终答案也当普通流式文本输出，过程消息里可能出现重复片段。

手改配置时注意 0.7.x 已经是 profile 级配置，只改对应 profile 下的 `preferences`，别整段覆盖 root `config.json`：

```json
{
  "schemaVersion": 2,
  "profiles": {
    "claude": {
      "preferences": {
        "messageReply": "text",
        "messageReplyMigrated": true,
        "showToolCalls": false,
        "cotMessages": "off"
      }
    }
  }
}
```

`/config` 提交后下一条消息即生效；手改文件要重启 bridge，或在 admin 上下文里发 `/reconnect`。

> **0.1.x 旧版没有 COT 开关**，思考内容是否外露完全由 `messageReply` 决定：只有 `card`（交互卡片）会把 reasoning 渲染成「🧠 思考中 / 思考完成，点击查看」折叠面板（截断到 1500 字）；`markdown` 和 `text` 走纯文本渲染路径，reasoning 根本不进输出，最多剩一行 `🧠 正在思考…` 状态提示。所以旧版“关思考”的办法就是把回复方式从交互卡片换掉。另外旧版写 `messageReply: "text"` 时必须同时写 `messageReplyMigrated: true`，否则会被当成 0.1.27 之前的语义强制解释成 `markdown`——这条兼容逻辑 0.7.x 仍然保留。
## 2.6 和 `lark-cli` 的关系

这两个工具适合搭配，但定位不同：

- **bridge**：解决“在飞书里实时和 Claude 交互”
- **lark-cli**：解决“把结果发布到飞书文档、群消息、任务系统里”

一个很典型的组合流程是：

1. 在飞书里和 Claude 讨论需求或问题
2. Claude 在本地生成或整理 Markdown
3. 用 `lark-cli` 把内容发布到飞书文档
4. 再把文档链接发回群里

所以可以把它们理解为：

- bridge 偏 **实时对话入口**
- `lark-cli` 偏 **结构化发布与自动化操作**

## 2.7 使用建议

### 2.7.1 先跑通最小链路

先不要一上来就配全量自动化。  
推荐先验证最小链路：

1. 本地 Claude Code 正常工作
2. bridge 能成功启动
3. 飞书里能发消息并拿到回复

这三步跑通后，再继续加：

- 白名单
- daemon 守护
- 文件上传
- `lark-cli` 联动

### 2.7.2 把它当作“飞书入口”，不是“飞书版 IDE”

这个 bridge 最有价值的点，是把入口前移到飞书。  
但真正执行代码分析、文件处理和命令调用的，仍然是本地 Claude Code。

因此更合理的使用方式通常是：

- 在飞书里提问、看结果、贴附件
- 复杂修改和验证仍然以本地工作区为准

## 2.8 升级与版本迁移

npm 包名是 `lark-channel-bridge`（不是 `lark-coding-agent-bridge`，那个名字在 npm 上不存在），升级就是重新全局装一遍：

```bash
npm i -g lark-channel-bridge
# 或
pnpm add -g lark-channel-bridge

lark-channel-bridge --version
```

**服务层命令必须全局安装，不能用 npx**。`start` 注册的 launchd plist / systemd unit / Windows 计划任务里会硬编码 bridge CLI 的路径；npx 的路径落在 npm 临时缓存里，缓存被清掉后 daemon 就起不来了。`run` 用 npx 单次前台启动没问题。

### 2.8.1 升级步骤

1. 停干净在跑的 bridge：前台进程 `Ctrl-C`；后台服务 `lark-channel-bridge stop`；游离进程用 `ps` 查、`kill <id|#>` 停
2. `npm i -g lark-channel-bridge`
3. `lark-channel-bridge migrate`（`run` / `start` 启动时也会自动迁移，显式跑一遍输出更清楚）
4. `lark-channel-bridge start` 或 `run`，然后在飞书里发 `/status` 验证

第 1 步不能省。检测到活跃 bridge 进程时迁移会拒绝执行：TTY 下问 `[y/N]` 是否代为停止，非交互终端直接报 `检测到 bridge 正在运行；非交互模式无法确认停止，请先停止后重试迁移`。已经死掉但没清理的注册表条目不算活跃进程，不会挡住迁移。

### 2.8.2 v1 → v2 迁移做了什么

0.2 之后本地状态从“单份平铺”改成“root config + 多 profile”，`migrate` 会：

- 把旧 `~/.lark-channel/config.json` 备份成 `config.json.bak`
- root config 重写成 `schemaVersion: 2` + `activeProfile` + `profiles.<name>`
- 把 `sessions.json`、`workspaces.json`、`secrets.enc`、`.keystore.salt`、`media/`、`logs/` 搬进 `~/.lark-channel/profiles/<profile>/`
- 进程注册表搬到 `~/.lark-channel/registry/processes.json`
- 旧 `preferences`（含 `preferences.access`、`requireMentionInGroup`）原样带进新 profile；旧 `sandbox` 字段迁移成 `permissions`
- 中途出错自动回滚，不会留下半迁移状态

前置条件是旧 config 里有完整的 `accounts.app.{id, secret, tenant}`，否则报 `legacy config is missing accounts.app`。用加密 keystore（`secret` 是 `{ source: "exec", id: ... }` 这种引用）的配置同样能迁，`secrets.enc` 和 `.keystore.salt` 会一起搬进 profile 目录。

### 2.8.3 容易踩的坑

- **profile 名跟着本机 agent 走**：默认 profile 名是 `claude`，但没显式指定 `--profile` / `--agent` 时，bridge 会探测 PATH 上的 `claude` 和 `codex`（可用 `LARK_CHANNEL_CLAUDE_BIN` / `LARK_CHANNEL_CODEX_BIN` 覆盖）。只装了 `codex` 的机器会直接建出 `codex` profile，并沿用原来的飞书应用凭据。想固定就写全：`lark-channel-bridge migrate --profile claude --agent claude`
- **迁移后本机至少要有个能用的 agent CLI**：0.7.x 同时支持 Claude Code 和 Codex，但一个都没装会报 `no supported local agent found; install claude or codex first`
- **服务名带上了 profile 后缀**：Windows 计划任务从 `LarkChannelBridge.Bot` 变成 `LarkChannelBridge.Bot.<profile>`，macOS 从 `ai.lark-channel-bridge.bot` 变成 `ai.lark-channel-bridge.bot.<profile>`，Linux 从 `lark-channel-bridge.bot.service` 变成 `lark-channel-bridge.bot.<profile>.service`。升级前注册过旧服务的，先 `unregister` 清掉旧定义再 `start`，否则会留一个指向旧路径的僵尸服务
- **Node 版本**：要求从 `>= 20` 提到 `>= 20.12.0`
- **想整体搬数据目录**：`LARK_CHANNEL_HOME=/path/to/state`；日志保留天数用 `LARK_CHANNEL_LOG_DAYS`
- **agent 建错了类型**：先 `stop` 或 `unregister --profile <name>`，再 `profile remove <name>`，然后用正确的 `--agent` 重建

### 2.8.4 0.7.x 相比 0.1.x 新增的能力

- `--agent claude|codex`：同一台机器上跑两个 bot
- `profile create / list / use / remove / export`：多 profile 管理。`export` 默认脱敏 app secret，加 `--include-secrets --yes` 才导出敏感配置
- `ui` 和 `--web-ui`：本地 web 控制台（配置、profile、在线 bot）；`--web-ui` 是托管所有 profile 的 supervisor 模式
- `permissions.defaultAccess` / `maxAccess`：`full` / `workspace` / `read-only`，分别映射到 Claude 的 `bypassPermissions` / `acceptEdits` / `plan`，和 Codex 的 `danger-full-access` / `workspace-write` / `read-only`
- COT 过程消息开关（见 2.5.4）
- `lark-cli` 身份策略：每个 profile 独立的 `LARKSUITE_CLI_CONFIG_DIR`，默认 `bot-only`，授权过个人资源后可切 `user-default`
- 云文档评论不再需要单独绑定工作目录或维护文档白名单

## 2.9 一句话总结

`feishu-claude-code-bridge` 适合已经在本地使用 Claude Code 的人，把飞书变成一个更顺手的消息入口，让 Claude 的能力能直接嵌进日常沟通和协作里。
