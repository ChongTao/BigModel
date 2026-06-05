# BigModel

`BigModel` 是一个围绕大模型应用与工程实践整理的知识库项目。内容不是按单一技术栈堆砌，而是按主题拆分，覆盖 Agent、RAG、NLP、LLM、开源框架、开源软件与 AI 工具等方向，适合做概念梳理、资料归档和实践入门。

项目当前更偏“持续沉淀型文档仓库”，目标不是做教程网站，而是把常见概念、核心模块、框架介绍和一些实践认知放到统一目录里，便于后续持续补充。

## 项目定位

这个仓库主要解决三类问题：

- 把大模型相关知识按主题整理，降低资料分散带来的查找成本
- 把常见框架、工具、协议和工程概念做成中文化摘要，便于快速建立知识地图
- 为后续继续扩展文档、补充实践案例和对比分析提供统一结构

## 知识地图

### 0. LLM

目录：`0 LLM/`

这一部分是当前仓库的核心基础模块之一，覆盖：

- 提示工程
- 上下文工程
- 大模型基础原理

推荐阅读：

- [0 LLM/1 提示工程/1 prompt engineering.md](0%20LLM/1%20%E6%8F%90%E7%A4%BA%E5%B7%A5%E7%A8%8B/1%20prompt%20engineering.md)
- [0 LLM/2 上下文工程/1 context Engineering.md](0%20LLM/2%20%E4%B8%8A%E4%B8%8B%E6%96%87%E5%B7%A5%E7%A8%8B/1%20context%20Engineering.md)
- [0 LLM/10 大模型原理/1 Transformer.md](0%20LLM/10%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%8E%9F%E7%90%86/1%20Transformer.md)

### 1. Agent

目录：`1 Agent/`

这一部分聚焦智能体相关概念，包括：

- Agent 基础认知
- 记忆机制
- Skill 能力封装
- 工具调用与接入
- Agent 框架与协议

推荐阅读：

- [1 Agent/1 Agent 概述.md](1%20Agent/1%20Agent%20%E6%A6%82%E8%BF%B0.md)
- [1 Agent/1 记忆/1 记忆概述.md](1%20Agent/1%20%E8%AE%B0%E5%BF%86/1%20%E8%AE%B0%E5%BF%86%E6%A6%82%E8%BF%B0.md)
- [1 Agent/2 Skill/1 Skill概述.md](1%20Agent/2%20Skill/1%20Skill%E6%A6%82%E8%BF%B0.md)
- [1 Agent/10 Agent框架与协议/3 工具调用与接入/1 Function Calling.md](1%20Agent/10%20Agent%E6%A1%86%E6%9E%B6%E4%B8%8E%E5%8D%8F%E8%AE%AE/3%20%E5%B7%A5%E5%85%B7%E8%B0%83%E7%94%A8%E4%B8%8E%E6%8E%A5%E5%85%A5/1%20Function%20Calling.md)
- [1 Agent/10 Agent框架与协议/1 Agent互操作协议/1 A2A协议.md](1%20Agent/10%20Agent%E6%A1%86%E6%9E%B6%E4%B8%8E%E5%8D%8F%E8%AE%AE/1%20Agent%E4%BA%92%E6%93%8D%E4%BD%9C%E5%8D%8F%E8%AE%AE/1%20A2A%E5%8D%8F%E8%AE%AE.md)
- [1 Agent/10 Agent框架与协议/1 Agent互操作协议/3 MCP协议.md](1%20Agent/10%20Agent%E6%A1%86%E6%9E%B6%E4%B8%8E%E5%8D%8F%E8%AE%AE/1%20Agent%E4%BA%92%E6%93%8D%E4%BD%9C%E5%8D%8F%E8%AE%AE/3%20MCP%E5%8D%8F%E8%AE%AE.md)

### 2. RAG

目录：`2 RAG/`

这一部分围绕检索增强生成展开，内容包括：

- RAG 基础概念
- RAG 架构设计
- 向量检索
- Agentic RAG
- 开源方案与竞品

推荐阅读：

- [2 RAG/1 RAG概述.md](2%20RAG/1%20RAG%E6%A6%82%E8%BF%B0.md)
- [2 RAG/2 RAG架构.md](2%20RAG/2%20RAG%E6%9E%B6%E6%9E%84.md)
- [2 RAG/3 向量检索.md](2%20RAG/3%20%E5%90%91%E9%87%8F%E6%A3%80%E7%B4%A2.md)
- [2 RAG/2 RAG架构.md](2%20RAG/2%20RAG%E6%9E%B6%E6%9E%84.md)

### 3. NLP

目录：`3 NLP/`

这一部分偏基础能力层，主要包括：

- NLP 简介
- Query 处理相关概念
- 召回算法

推荐阅读：

- [3 NLP/1 NLP简介.md](3%20NLP/1%20NLP%E7%AE%80%E4%BB%8B.md)
- [3 NLP/2 query处理相关概念.md](3%20NLP/2%20query%E5%A4%84%E7%90%86%E7%9B%B8%E5%85%B3%E6%A6%82%E5%BF%B5.md)

### 4. Harness

目录：`4 Harness/`

这一部分聚焦围绕模型运行的控制与执行层，包括：

- 上下文装配
- 工具执行与权限控制
- 长任务状态管理
- 验证、护栏与恢复机制

`Harness` 不属于 LLM 本体能力，也不等于 Agent 本身。更准确地说，它是围绕模型与 Agent 运行的一整套工程化环境。

推荐阅读：

- [4 Harness/1 Harness概述.md](4%20Harness/1%20Harness%E6%A6%82%E8%BF%B0.md)
- [3 NLP/3 召回算法.md](3%20NLP/3%20%E5%8F%AC%E5%9B%9E%E7%AE%97%E6%B3%95.md)

### 5. 开源生态

目录：`5 开源生态/`

这一部分汇总当前已整理的 AI 开源框架、平台型项目与开源软件，包括：

- Dify
- LangChain
- LangGraph
- OpenClaw
- Hermes
- nndeploy
- GPT-Load
- Ollama
- OneAPI
- 推理框架

推荐阅读：

- [5 开源生态/1 Dify/1 dify.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/1%20Dify/1%20dify.md)
- [5 开源生态/2 LangChain/1 LangChain.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/2%20LangChain/1%20LangChain.md)
- [5 开源生态/2 LangChain/1 LangGraph/1 LangGraph介绍.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/2%20LangChain/1%20LangGraph/1%20LangGraph%E4%BB%8B%E7%BB%8D.md)
- [5 开源生态/3 OpenClaw/2 项目介绍与架构概览.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/3%20OpenClaw/2%20%E9%A1%B9%E7%9B%AE%E4%BB%8B%E7%BB%8D%E4%B8%8E%E6%9E%B6%E6%9E%84%E6%A6%82%E8%A7%88.md)
- [5 开源生态/4 Hermes/2 项目介绍与原理概览.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/4%20Hermes/2%20%E9%A1%B9%E7%9B%AE%E4%BB%8B%E7%BB%8D%E4%B8%8E%E5%8E%9F%E7%90%86%E6%A6%82%E8%A7%88.md)
- [5 开源生态/5 nndeploy/1 nndeploy.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/5%20nndeploy/1%20nndeploy.md)
- [5 开源生态/7 Ollama/1 Ollama总结.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/7%20Ollama/1%20Ollama%E6%80%BB%E7%BB%93.md)
- [5 开源生态/8 OneAPI/1 OneApi.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/8%20OneAPI/1%20OneApi.md)
- [5 开源生态/9 推理框架/1 推理框架介绍.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/9%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6/1%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6%E4%BB%8B%E7%BB%8D.md)
- [5 开源生态/9 推理框架/2 vLLM.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/9%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6/2%20vLLM.md)
- [5 开源生态/9 推理框架/3 TGI.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/9%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6/3%20TGI.md)
- [5 开源生态/9 推理框架/4 TensorRT-LLM.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/9%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6/4%20TensorRT-LLM.md)
- [5 开源生态/9 推理框架/5 llama.cpp.md](5%20%E5%BC%80%E6%BA%90%E7%94%9F%E6%80%81/9%20%E6%8E%A8%E7%90%86%E6%A1%86%E6%9E%B6/5%20llama.cpp.md)

### 9. 论文与博客

目录：`9 论文&博客/`

这一部分用于收录值得沉淀的论文、综述和博客文章。

推荐阅读：

- [9 论文&博客/1 Memory in the Age of AI Agents A Survey.md](9%20%E8%AE%BA%E6%96%87%26%E5%8D%9A%E5%AE%A2/1%20Memory%20in%20the%20Age%20of%20AI%20Agents%20A%20Survey.md)
- [9 论文&博客/2 12 RAG Pain Points and Proposed Solutions.md](9%20%E8%AE%BA%E6%96%87%26%E5%8D%9A%E5%AE%A2/2%2012%20RAG%20Pain%20Points%20and%20Proposed%20Solutions.md)

### 99. 工具

目录：`99 工具/`

这一部分主要记录常见 AI 开发工具的使用说明与经验，包括：

- Cursor
- Claude Code
- Codex

推荐阅读：

- [99 工具/1 Cursor/1 Cursor.md](99%20%E5%B7%A5%E5%85%B7/1%20Cursor/1%20Cursor.md)
- [99 工具/2 Claude Code/1 Claude Code安装.md](99%20%E5%B7%A5%E5%85%B7/2%20Claude%20Code/1%20Claude%20Code%E5%AE%89%E8%A3%85.md)
- [99 工具/2 Claude Code/4 Claude Code MCP.md](99%20%E5%B7%A5%E5%85%B7/2%20Claude%20Code/4%20Claude%20Code%20MCP.md)
- [99 工具/3 Codex/1 Codex.md](99%20%E5%B7%A5%E5%85%B7/3%20Codex/1%20Codex.md)

## 当前文档特点

目前仓库内容有几个明显特点：

- 以中文资料为主，适合快速理解概念和框架
- 强调知识归档与工程化视角，而不是单纯复制官方文档
- 部分模块仍在持续扩充中，深度和完整度会逐步提升
- 一些目录已经形成专题化结构，例如 Agent、RAG、LLM、Claude Code

## 适合谁使用

这个仓库更适合以下场景：

- 想快速建立大模型应用知识地图的人
- 想梳理 Agent、RAG、Prompt、Context、Harness 等概念关系的人
- 想查找某个框架、协议或工具的中文整理资料的人
- 想持续维护个人或团队 AI 知识库结构的人

## 后续可继续补充的方向

后续可以继续完善的方向包括：

- 增加更多模块之间的关联说明
- 为重点主题补充对比型文档
- 为开源框架加入实践案例和优缺点分析
- 为工具模块补充更系统的工作流总结
- 为 README 增加按“入门路径”组织的阅读顺序

## 参考资料

- NLP教程：https://www.runoob.com/nlp/nlp-tutorial.html
- Foundations-of-LLMs：https://github.com/ZJU-LLMs/Foundations-of-LLMs
