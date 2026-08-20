# CrewAI

[CrewAI](https://github.com/crewAIInc/crewAI) 是用于构建多智能体（Multi-Agent）工作流的开源 Python 框架。它将协作单元组织为 **Crew**，让具有不同角色、目标和工具的 Agent 协同完成任务；同时通过 **Flow** 编排带状态、分支和人工参与的业务流程。

## 1. 核心概念

| 概念 | 作用 |
| --- | --- |
| Agent | 配置角色、目标、背景、可用工具和所使用的 LLM，是执行具体工作的智能体。 |
| Task | 描述输入、预期结果、负责 Agent 与上下游依赖，是可验证的工作单元。 |
| Crew | 将多个 Agent 和 Task 组成协作团队，支持顺序或分层等协作过程。 |
| Flow | 用于控制应用级流程和状态，例如条件分支、事件触发、持久化与人工审核。 |
| Tool | Agent 调用的外部能力，如检索、文件处理、数据库访问或业务 API。 |

## 2. 适用场景

- **研究与内容生产**：研究、资料整理、撰写和审校等职责可分配给不同 Agent。
- **客户支持与业务自动化**：由 Flow 管理请求分类、工具调用、审批和异常处理。
- **数据分析**：将数据获取、分析、可视化和报告生成拆分为可追踪的任务。
- **多步骤 Agent 应用**：需要明确角色边界、任务交接和最终交付物的场景。

## 3. 快速开始

安装 Python 包：

```python
from crewai import Agent, Task, Crew

# 定义智能体
researcher = Agent(
    role="资深研究员",
    goal="发现 AI 领域的最新突破",
    backstory="你是一位在顶级期刊发表论文无数的 AI 研究员",
    verbose=True
)

writer = Agent(
    role="技术撰稿人",
    goal="用通俗语言解释复杂技术",
    backstory="你是一位擅长将技术转化为易懂内容的资深编辑"
)

# 定义任务
research_task = Task(
    description="研究 2025 年 AI 领域的三大突破性进展",
    expected_output="一份包含三大突破的简要报告",
    agent=researcher
)

writing_task = Task(
    description="基于研究报告，撰写一篇面向非技术读者的博客文章",
    expected_output="一篇 1000 字的博客文章",
    agent=writer
)

# 组建团队并执行
crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    verbose=True
)

result = crew.kickoff()
```

一个 Crew 通常包含以下步骤：

1. 定义 Agent 的职责、可用模型和工具权限。
2. 定义 Task 的输入、输出要求及负责人，并声明任务依赖。
3. 将 Agent 和 Task 组装为 Crew，选择合适的执行过程。
4. 需要稳定业务控制时，用 Flow 明确状态、分支、重试和人工审核点。
5. 为工具调用、模型输出和最终结果加入日志、评测及安全边界。

> 以项目 README 和官方文档中的当前 API、CLI 和模型配置为准；框架版本升级时应重新验证示例。


## 4. 参考

- GitHub：<https://github.com/crewAIInc/crewAI>
- 官方文档：<https://docs.crewai.com/>
