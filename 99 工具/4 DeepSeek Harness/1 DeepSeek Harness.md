# 1 DeepSeek Harness

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 是 DeepSeek 开源的编码 Agent 运行环境。它把模型、工作目录、命令执行、规则和扩展能力组织成一个可持续工作的开发工具，而不是只提供一次性的代码补全或对话。

项目的核心理念是 **“Everything is a Plugin”**：尽量把模型接入、工具、工作流和界面能力都做成可替换的插件。这样同一个基础运行时可以按团队需要组合能力，而不必把所有集成都固化在核心代码中。

## 1.1 适合什么场景

- 希望把 DeepSeek 模型用于多步骤编码、调试和验证任务
- 希望按项目接入不同工具、规则或工作流，而不是使用固定的 Agent 形态
- 需要将开发环境能力逐步封装为插件，便于团队复用
- 希望在本地工作区中保留可控的命令执行、文件修改和权限边界

它不是模型本身，也不是通用的 Agent 框架；更准确地说，它是面向编码任务的 **Agent Harness**：负责把模型放进真实的软件工程环境中工作。

> 项目目前处于开发者预览阶段，官方明确提示可能出现不兼容变更。安装、插件接口和配置应以当前官方文档为准。

## 1.2 安装与启动

### 1.2.1 通过 npm 快速启动

先安装 [Node.js](https://nodejs.org/)，然后在希望作为默认文件系统位置的目录运行：

```sh
npx @deepseek-ai/dsh web
```

该命令会启动 Web UI；本地运行时默认监听 `http://127.0.0.1:3080`，并打开默认浏览器。若只启动服务而不自动打开浏览器，可加 `--no-open`：

```sh
npx @deepseek-ai/dsh web --no-open
```

### 1.2.2 从源码运行

需要查看或修改 Harness 源码时，可使用 pnpm：

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

`pnpm run build` 会准备运行所需的构建产物；之后 `pnpm dsh web` 会直接使用这些产物，不会每次自动重新构建。

## 1.3 首次使用

启动 Web UI 后，按以下顺序完成最小可用配置：

1. 打开 **Settings → Models**，填入 DeepSeek API Key 并保存；模型路由会立即可用，无需重启服务。
2. 点击 **Choose workspace**，添加并选中启动 `dsh` 时所在的项目目录。未选择工作区前，无法在会话输入框发起任务。
3. 从低风险任务开始，例如“阅读此项目并说明启动命令”或“运行测试并解释失败原因”。确认模型、工作区与工具输出都正常后，再允许修改文件。
4. 需要使用其他模型提供方或自定义 OpenAI 兼容端点时，按官方的模型配置指南添加对应 Provider；不要将 API Key 写入仓库或提交到 Git。

通过 SSH 或远程开发环境启动时，`dsh` 会打印访问地址；浏览器端口转发应由 SSH 客户端或 IDE 配置。`dsh` 以调用命令所在目录作为默认文件系统位置，但仍需在 Web UI 中显式选择工作区。

## 1.4 核心组成

| 组成 | 作用 |
| --- | --- |
| 模型适配 | 将推理模型接入运行时，为任务规划、代码生成与工具调用提供能力。 |
| 工作区 | 向 Agent 提供项目文件、目录结构和项目规则等上下文。 |
| 工具执行 | 让 Agent 能读写文件、运行命令、检查输出并继续处理反馈。 |
| 插件 | 将模型提供方、工具、交互界面或特定工作流做成可安装、可替换的能力单元。 |
| 规则与权限 | 限制可执行操作，并将测试、检查和人工确认保留在适当的环节。 |

这一结构与 Harness 的通用闭环一致：**读取上下文 → 制定步骤 → 调用工具 → 验证结果 → 根据反馈继续执行**。

## 1.5 插件优先的含义

“Everything is a Plugin” 不等于为所有事情无差别安装插件，而是将变化频繁、项目差异大的能力从核心中分离出来。

- **模型插件**：适配不同模型或服务端，避免运行时绑定单一模型。
- **工具插件**：将浏览器、代码审查、部署或内部系统等能力按需接入。
- **工作流插件**：将重复任务沉淀为可复用的步骤和约束。
- **界面/入口插件**：允许不同的终端、桌面端或其他交互入口共享同一套运行能力。

实践上，应先启用最少插件并验证其权限范围，再逐个增加。插件能扩大 Agent 的执行面，也会扩大供应链、数据访问和外部副作用的边界。

## 1.6 与 Codex、Claude Code 的关系

DeepSeek Harness、Codex 和 Claude Code 都服务于“让模型在代码仓库中完成任务”，但重点不同：

| 工具 | 重点 |
| --- | --- |
| DeepSeek Harness | 以插件化方式组装编码 Agent 的运行环境，强调可替换的能力模块。 |
| Codex | OpenAI 提供的代码代理产品，覆盖 CLI、IDE、App 和 Cloud 等入口。 |
| Claude Code | Anthropic 提供的终端优先编码 Agent，围绕项目规则、权限、MCP、Skills 和子代理扩展。 |

三者都需要项目规则、上下文管理、工具权限和验证流程。选择时不应只比较模型能力，还要比较模型接入方式、插件生态、权限控制、团队已有工作流和可观测性是否匹配。

技术上，DeepSeek Harness 基于具有时空可组合性的 Cordis 插件系统构建。Cordis 作为元框架，只负责插件的加载与卸载以及依赖关系，Agent Harness 的所有具体组件都是不同的 Cordis 插件。插件通过服务与事件彼此协作，并可以在配置层自由组合。开发者无需改动 DeepSeek Harness 的源码本身，就能以插件的方式独立选择、替换或扩展其中的任一能力

## 1.7 使用建议

1. 先在隔离或非生产工作区验证模型接入与最小工具集。
2. 先让 Agent 具备只读、测试和格式化能力，再逐步开放文件修改与有副作用的外部工具。
3. 将构建、测试、提交规范写成项目规则或工作流插件；不要只依赖聊天中的临时指令。
4. 对删除、部署、发布、数据库写入等不可逆操作保留确认、审计和回滚路径。
5. 插件安装前检查来源、维护状态和所需权限；对外部服务插件尤其要避免授予超出任务所需的凭证和访问范围。

## 1.8 参考

- GitHub：<https://github.com/deepseek-ai/deepseek-harness>
- 官网：<https://deepseek.com/harness>
- [官方 Web UI 指南](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/index.md)
- [官方模型配置指南](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.md)
- [Harness 概述](../../4%20Harness/1%20Harness%E6%A6%82%E8%BF%B0.md)
