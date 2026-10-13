# LangGraph

LangGraph 是由 LangChain 团队推出的**有状态、持久运行、多智能体**应用的编排框架。核心将Agent建模成一个**图（Graph）**：每个节点是计算步骤（LLM 调用、工具函数、任意 Python 代码等），边控制流转（含条件与循环），并最终实现既定目标。并且在今年6月提供了**预构建模式**，对常见的多智能体场景提供了抽象封装，开发者只需定义少量参数（如参与的子智能体、主体提示词等）即可快速生成完整的多 Agent 协作系统。



**LangGraph** 是 LangChain 推出的 **多 Agent 协作与任务编排框架**，定位是：把多个 LLM Agent、工具、RAG、Memory 等模块，以图结构组织起来，实现复杂任务的分布式推理和自动化执行。

1. **图结构组织 Agent**
   - 节点（Node）代表 Agent 或工具
   - 边（Edge）代表信息流或任务依赖
   - 可以动态调整任务顺序和数据流
2. **多 Agent 协作**
   - 支持 ReAct、Planner + Executor 等 Agent
   - 可实现团队型智能体协作（如 Researcher + Writer + Analyst）
3. **任务可视化与调度**
   - 任务执行路径可视化
   - 可以调度任务优先级和依赖关系
4. **融合 Memory + Tools + LLM**
   - 各节点可调用工具、存储结果到 Memory
   - 支持 RAG 查询、数据库访问、API 调用



| 模块                     | 功能                   | 备注                                       |
| ------------------------ | ---------------------- | ------------------------------------------ |
| **Graph Planner**        | Goal → Graph Node      | 自动拆解任务，构建依赖关系                 |
| **Node**                 | LLM Agent / Tool / API | 可以是 ReAct Agent、RAG Agent 或自定义函数 |
| **Executor / Scheduler** | 调度执行               | 支持顺序、并行、失败重试                   |
| **Memory / RAG**         | 任务上下文和知识库     | 支持短期、长期记忆，可跨节点共享           |
| **Visualizer**           | Graph 可视化           | 显示执行流程、依赖关系、状态               |

![](https://mmbiz.qpic.cn/sz_mmbiz_png/j3gficicyOvauNZyziaHia56WajsqXbwHetmLJB9ibxhH3sv1v13JicVPwldlCbJEfBdHsIA5NhH9iauZsgeJmGFzJzPQ/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=9)



**主要特点：**支持图式编排、可人工干预、可中断/续跑。LangGraph可形成可控的分支/循环流程，可在每个节点中加入人工干预环节，适合需要人工审批/修订的业务场景，并且基于持久化状态可方便中断、续跑、回溯。

**典型应用场景：**可明确拆解任务步骤的场景，如RAG类、文章生成、日程助手等。





按照 LangGraph Memory分类，可以分为 Short-term memory与 Long-term memory，其中 Long-term memory又分为： semantic memory、 episodic memory、procedural memory。