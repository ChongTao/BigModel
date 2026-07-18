# 1 Codex

`Codex` 是 OpenAI 的代码代理产品，可以在本地项目里读取文件、修改代码、执行命令，并按项目规则持续协作。

当前常见使用入口有四类：

- CLI：在终端里直接运行
- IDE 扩展：在编辑器里对接本地或云端工作流
- App：桌面端集中管理项目、线程和自动化
- Cloud：在浏览器里使用 Codex

它的重点不是“补全一行代码”，而是把一个开发任务拆开并执行完，包括阅读仓库、实现改动、运行验证、整理结果。

## 1.1 适合什么场景

Codex 比较适合：

- 阅读和理解现有代码库
- 批量修改文件
- 执行命令并验证结果
- 按仓库规则持续协作
- 通过 `AGENTS.md`、Skills、Plugins、MCP、Subagents 扩展能力

## 1.2 常见入口

### 1.2.1 CLI

Windows 下常见安装方式：

```sh
npm install -g @openai/codex
```

安装后直接运行：

```sh
codex
```

首次启动通常需要登录。常见方式有：

- 使用 ChatGPT 账号
- 使用 OpenAI API Key

### 1.2.2 IDE 扩展

IDE 扩展适合在 VS Code 兼容编辑器里直接协作。它和 CLI 共享同一套本地配置层。

### 1.2.3 App

Codex App 更像桌面工作台，适合：

- 并行管理多个线程
- 跟踪任务计划、变更和产物
- 配合本地项目、worktree 和自动化使用

### 1.2.4 Cloud

Cloud 更适合：

- 不依赖本地终端先快速体验
- 管理浏览器里的任务线程
- 做偏云端的协作与跟踪

## 1.3 常见本地目录

Codex 的本地状态目录默认在：

```text
~/.codex/
```

如果设置了 `CODEX_HOME`，则会改用自定义目录。

常见内容包括：

- `config.toml`：用户级主配置
- `AGENTS.md`：全局规则
- `AGENTS.override.md`：全局临时覆写规则
- `skills/`：本地技能
- `plugins/`：本地插件
- `agents/`：自定义子代理相关内容

项目内常见内容包括：

```text
.codex/config.toml
AGENTS.md
AGENTS.override.md
```

配置文件config.toml

```tom
model_provider = "xxx"
model = "xxxx"

# 永不询问
approval_policy = "never"
sandbox_mode = "danger-full-access"

# 跳过登录页面
hasCompletedOnboarding = true

# 禁用需要 OpenAI 官方服务器的内置功能（自定义代理不支持）
[features]
apps = false
plugins = false
image_generation = false

[model_providers.azure]
name = "Azure"
base_url = "xxxx"
wire_api = "responses"

# 多模型 profile：用 codex -p <名字> 切换；不指定 -p 则用顶层 azure/gpt-5.4
# profile 复用顶层 azure provider（统一平台入口 + responses 协议），仅覆盖 model 名
[profiles.qwen-max]
model = "alibaba/qwen3.7"

[profiles.qwen-plus]
model = "alibaba/qwen3.7"
```

codex -p qwen-max 进行切换

上述是老版本，新版本新增qwen-max.config.toml和qwen-plus.config.toml文件

```tom

```



配置原则

  - 用 ~/.codex/config.toml 放基础配置，再用单独的 ~/.codex/<profile-name>.config.toml 放各模型差异项；--profile profile-name 会先加载基础配置，再叠加对应 profile 文件。Profile
    名只允许字母、数字、- 和 _。 (developers.openai.com (https://developers.openai.com/codex/config-advanced.md))

  - 在当前版本里，不要再在 config.toml 里写 [profiles.profile-name]，也不要写顶层 profile = "profile-name"，这两种旧写法在 0.134.0+ 已不再使用。 (developers.openai.com
    (https://developers.openai.com/codex/config-advanced.md))

  - 单次临时覆盖时，优先用专用参数，比如 --model；需要改任意键时再用 --config。 (developers.openai.com (https://developers.openai.com/codex/config-advanced.md))

  推荐结构

  - 基础文件：/data0/chongtao/.codex/config.toml
  - GPT-5.4 profile：/data0/chongtao/.codex/gpt54.config.toml
  - GPT-5.4-mini profile：/data0/chongtao/.codex/gpt54-mini.config.toml

  示例

  # gpt54.config.toml
  model = "azure/gpt-5.4"
  model_provider = "custom"
  model_reasoning_effort = "high"
  model_context_window = 131072

  # gpt54-mini.config.toml
  model = "azure/gpt-5.4-mini"
  model_provider = "custom"
  model_reasoning_effort = "high"
  model_context_window = 131072

  切换方式

  - codex --profile gpt54 使用 GPT-5.4。 (developers.openai.com (https://developers.openai.com/codex/config-advanced.md))
  - codex --profile gpt54-mini 使用 GPT-5.4-mini。 (developers.openai.com (https://developers.openai.com/codex/config-advanced.md))
  - 临时改模型可直接：codex --model gpt-5.4。 (developers.openai.com (https://developers.openai.com/codex/config-advanced.md))





## 1.4 理解 Codex 的最短路径

如果要快速上手，可以按这个顺序理解：

1. 先看安装和常见操作
2. 再看 `AGENTS.md`
3. 再看 `config.toml`
4. 需要扩展能力时再看 Skills、Plugins、MCP、Subagents

## 1.5 参考

- https://developers.openai.com/codex/quickstart
- https://developers.openai.com/codex/cli
- https://developers.openai.com/codex/cli/agents-md
- https://developers.openai.com/codex/cli/slash-commands
