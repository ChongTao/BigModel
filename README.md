# BigModel

面向大模型应用与工程实践的中文知识库。仓库按主题沉淀 LLM、Agent、RAG、生产实践、开源生态与开发工具等内容，便于快速建立知识地图、查找资料和持续归档。

## 从这里开始

如果你刚接触大模型应用，建议按以下顺序阅读：

1. [LLM 基础与提示词](#llm)
2. [上下文工程与 RAG](#rag)
3. [Agent、记忆与工具调用](#agent)
4. [生产实践与开源框架](#生产实践与开源生态)

## 知识地图

### LLM

大模型基础、提示词、推理方法、上下文工程、推理工程及后训练与对齐。

- [大模型原理](0%20LLM/1%20大模型原理/1%20LLM基本概念.md)
- [Prompt Engineering](0%20LLM/2%20提示词Prompt/1%20prompt%20engineering.md)
- [上下文工程](0%20LLM/4%20上下文工程/1%20context%20Engineering.md)
- [推理工程](0%20LLM/5%20推理工程/1%20推理工程概述.md)
- [后训练与对齐](0%20LLM/6%20后训练与对齐/1%20后训练概述.md)

### Agent

智能体概述、运行时、记忆、Skill、工具调用，以及 Agent 框架与互操作协议。

- [Agent 概述](1%20Agent/1%20Agent%20概述.md)
- [记忆概述](1%20Agent/1%20记忆/1%20记忆概述.md)
- [Skill 概述](1%20Agent/2%20Skill/1%20Skill概述.md)
- [Agent Runtime 概述](1%20Agent/3%20运行时/1%20Agent%20Runtime概述.md)
- [Function Calling](1%20Agent/10%20Agent框架与协议/3%20工具调用与接入/1%20Function%20Calling.md)
- [MCP 协议](1%20Agent/10%20Agent框架与协议/1%20Agent互操作协议/3%20MCP协议.md)

### RAG

检索增强生成的架构、数据预处理、分块、检索、重排、评测及开源方案。

- [RAG 概述](2%20RAG/1%20RAG概述.md)
- [RAG 架构](2%20RAG/2%20RAG架构.md)
- [RAG 数据预处理](2%20RAG/3%20RAG数据预处理.md)
- [RAG 分块策略](2%20RAG/4%20RAG分块策略.md)
- [RAG 检索](2%20RAG/5%20RAG检索.md)
- [RAG 评测](2%20RAG/11%20RAG评测.md)

### NLP 与 Harness

NLP 基础、查询处理、召回算法，以及模型与 Agent 运行的工程化控制层。

- [NLP 简介](3%20NLP/1%20NLP简介.md)
- [Query 处理相关概念](3%20NLP/2%20query处理相关概念.md)
- [Harness 概述](4%20Harness/1%20Harness概述.md)

### 生产实践与开源生态

生产环境中的成本、延迟、安全、监控、韧性，以及常用 AI 开源项目和推理框架。

- [生产：成本](6%20生产/1%20成本.md)、[延迟](6%20生产/2%20延迟.md)、[安全和沙箱](6%20生产/3%20安全和沙箱.md)、[监控与 drift](6%20生产/4%20监控与drift.md)、[韧性](6%20生产/5%20韧性.md)
- [Dify](5%20开源生态/1%20Dify/1%20dify.md)
- [LangChain](5%20开源生态/2%20LangChain/1%20LangChain.md) / [LangGraph](5%20开源生态/2%20LangChain/1%20LangGraph/1%20LangGraph介绍.md)
- [OpenClaw](5%20开源生态/3%20OpenClaw/2%20OpenClaw介绍与架构概览.md)
- [Ollama](5%20开源生态/7%20Ollama/1%20Ollama总结.md)
- [推理框架](5%20开源生态/9%20推理框架/1%20推理框架介绍.md)

### 论文、博客与工具

收录值得长期参考的论文、博客，以及 AI 开发工具的安装、配置与实践。

- [Memory in the Age of AI Agents: A Survey](9%20论文%26博客/1%20Memory%20in%20the%20Age%20of%20AI%20Agents%20A%20Survey.md)
- [Claude Code](99%20工具/2%20Claude%20Code/1%20Claude%20Code安装.md)
- [Codex](99%20工具/3%20Codex/1%20Codex.md)
- [DeepSeek Harness](99%20工具/4%20DeepSeek%20Harness/1%20DeepSeek%20Harness.md)
- [Unsloth](99%20工具/5%20Unsloth/1%20Unsloth.md)

## 如何使用

- 将本仓库作为主题索引：从对应编号目录进入，按文件名逐步阅读。
- 通过 GitHub 的文件搜索，按概念、框架或工具名定位资料。
- 新增内容时，放入最接近的主题目录，并沿用该目录的编号与命名方式。

## 贡献说明

欢迎补充和修订内容。提交前请确认：

- 文档结构清晰、链接可用，且内容适合长期维护；
- 新文件位于正确主题目录，并遵循已有命名习惯；
- 不包含密钥、令牌、密码、私钥、个人信息或真实连接串。

## 参考资料

- [NLP 教程](https://www.runoob.com/nlp/nlp-tutorial.html)
- [Foundations of LLMs](https://github.com/ZJU-LLMs/Foundations-of-LLMs)
