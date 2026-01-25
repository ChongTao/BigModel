# 1  Ollama介绍

Ollama 是一款开源跨平台本地大模型运行框架，能让用户在 Windows、macOS、Linux 设备上一键部署 Llama 3、Mistral、Phi-3、LLaVA 等主流开源大模型，实现数据本地化与离线可用，无需复杂环境配置，还提供 CLI、兼容 OpenAI 的 REST API 及 Modelfile 自定义能力。

## 1.1 特点

- **多种预训练语言模型支持**：提供了多种开箱即用的预训练模型，如GPT、BERT等大型语言模型。
- **易于集成和使用**：提供了命令行工具（CLI）和 Python SDK，简化了与其他项目和服务的集成。
- **本地部署与离线使用**：允许开发者在本地计算环境中运行模型。
- **支持模型微调与自定义**：用户不仅可以使用 Ollama 提供的预训练模型，还可以在此基础上进行模型微调。
- **性能优化**：提供了高效的推理机制，支持批量处理，能够有效管理内存和计算资源。

## 1.2 安装

Ollama 官方下载地址：https://ollama.com/download。

安装完后，执行命令`ollama --version`判断是否安装成功。

> 注意：可以指定安装目录OllamaSetup.exe /DIR="d:\some\location"

## 1.3 命令

1. 基础命令

| 命令                            | 功能说明                                     | 示例                                                         |
| :------------------------------ | :------------------------------------------- | :----------------------------------------------------------- |
| `ollama run <模型名>`           | 下载并交互式运行指定模型（首次运行自动下载） | `ollama run llama3`（运行 Llama 3 模型）`ollama run qwen:7b`（运行通义千问 7B 版本） |
| `ollama pull <模型名>`          | 手动下载模型（仅下载不运行）                 | `ollama pull mistral:7b`（下载 Mistral 7B 模型）             |
| `ollama push <模型名>`          | 将本地模型推送到 Ollama 库（需先登录）       | `ollama push my-custom-model`                                |
| `ollama pull <用户名>/<模型名>` | 下载第三方分享的模型                         | `ollama pull username/chat-model:latest`                     |

2. 模型管理（查看 / 删除 / 复制）

| 命令                              | 功能说明                             | 示例                                                         |
| --------------------------------- | :----------------------------------- | :----------------------------------------------------------- |
| `ollama list`                     | 列出本地已下载的所有模型             | `ollama list`（输出包含模型名、ID、大小、修改时间）          |
| `ollama rm <模型名>`              | 删除本地指定模型                     | `ollama rm llama3`（删除 Llama 3 模型）`ollama rm --all`（删除所有本地模型） |
| `ollama cp <原模型名> <新模型名>` | 复制模型（重命名）                   | `ollama cp llama3 my-llama3`                                 |
| `ollama show <模型名>`            | 查看模型详情（参数、模板、许可证等） | `ollama show llama3`（基础信息）`ollama show llama3 --parameters`（仅查看参数）`ollama show llama3 --template`（仅查看提示词模板） |

3. 服务与配置

| 命令                   | 功能说明                                               | 示例                                                         |
| :--------------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| `ollama serve`         | 启动 Ollama 后台服务（默认自动启动，手动启动用于调试） | `ollama serve`                                               |
| `ollama ps`            | 查看正在运行的 Ollama 进程                             | `ollama ps`                                                  |
| `ollama stop <模型名>` | 停止指定模型的运行                                     | `ollama stop llama3`                                         |
| `ollama config`        | 查看 / 修改 Ollama 配置（如模型存储路径）              | `ollama config set modelsdir /data/ollama/models`（修改模型存储目录） |

4. 自定义模型（Modelfile）

| 命令                                              | 功能说明                                | 示例                                        |
| :------------------------------------------------ | :-------------------------------------- | :------------------------------------------ |
| `ollama create <自定义模型名> -f <Modelfile路径>` | 通过 Modelfile 创建自定义模型           | `ollama create my-rag-model -f ./Modelfile` |
| `ollama inspect <模型名>`                         | 查看模型的详细配置（含 Modelfile 内容） | `ollama inspect my-rag-model`               |

5. 其他实用命令

| 命令             | 功能说明                                                    |
| :--------------- | :---------------------------------------------------------- |
| `ollama version` | 查看 Ollama 版本号                                          |
| `ollama help`    | 查看所有命令的帮助信息（可加具体命令，如`ollama help run`） |
| `ollama logs`    | 查看 Ollama 运行日志（调试排错用）                          |



















