# OpenClaude

OpenClaude 是一个开源 coding agent CLI。你可以把它理解为一种“Claude Code 风格”的终端工作流，但后端模型不局限于 Anthropic 官方服务，还可以接 OpenAI 兼容接口、Gemini、GitHub Models、Ollama 等 Provider。

它适合下面两类场景：

- 想保留类似 Claude Code 的交互方式，但希望自由切换模型提供商。
- 已经有 OpenAI 兼容网关或本地 Ollama，希望直接复用现有模型基础设施。

## 1 安装

OpenClaude 官方 Windows Quick Start 要求 **Node.js 22 LTS 或更高版本**。

```sh
npm install -g @gitlawb/openclaude@latest
```

安装完成后检查版本：

```sh
openclaude --version
```

## 2 最简单的使用方式

进入项目目录后直接启动：

```sh
openclaude
```

首次进入后，推荐先执行：

```text
/provider
```

它会引导你选择并保存 Provider 配置，比如 OpenAI、OpenRouter、Gemini、Ollama 等。对于第一次使用者，这种方式通常比手动维护环境变量更直观。

## 3 手动配置 Provider

如果你不想走 `/provider` 向导，也可以直接用环境变量启动。

### 3.1 OpenAI 兼容接口

```powershell
$env:CLAUDE_CODE_USE_OPENAI="1"
$env:OPENAI_API_KEY="sk-your-key-here"
$env:OPENAI_MODEL="gpt-4o"
openclaude
```

### 3.2 本地 Ollama

```powershell
$env:CLAUDE_CODE_USE_OPENAI="1"
$env:OPENAI_BASE_URL="http://localhost:11434/v1"
$env:OPENAI_MODEL="llama3.1:8b"
openclaude
```

使用 Ollama 本地模型时通常不需要 API Key，但需要先安装并启动 Ollama，并提前拉取对应模型。

## 4 一个实用注意点

OpenClaude **不会自动读取项目里的 `.env`**。如果你希望从指定 env 文件加载 Provider 变量，可以显式传入：

```sh
openclaude --provider-env-file .env
```

如果只是第一次上手，建议优先使用 `/provider`，这样不容易把凭证散落到项目目录里。
