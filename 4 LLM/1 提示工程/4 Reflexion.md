# 1 Reflexion

Reflexion是一个强化学习框架，由Shinn等人提出，它通过生成语言反馈帮助智能体从错误中学习，而非传统标量奖励。Reflexion模仿人类反思过程，让模型在尝试后获得具体改进建议，如"上次搜索范围太宽，下次更具体"。Reflexion解决以下问题：

- ReAct/COT：只能在当前上下文内推理，并且一旦失败后需要从头开始



## 1.1 Reflexion的三大组件

Reflexion构建在ReAct基础上，添加评估和反思机制，形成闭环：

- **参与者（Actor）：**基于ReAct或CoT生成行动轨迹。
- **评估者（Evaluator）：**对轨迹打分，判断成功或失败。
- **自我反思（Self-Reflection）：**核心组件，生成语言反馈并存入长期记忆，指导下次行动。

工作流程：行动 → 评估 → 反思 → 迭代。通过滑动窗口记忆，Reflexion保留反思内容，实现持续优化。

![](https://mmbiz.qpic.cn/mmbiz_png/Z6bicxIx5naKyOLK50D5X8j93cRAicEC2xfjxfrhGoaURLHkngAdMe8SwEe0YacNkQXickDopQjWdeN13CDZyZIsw/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=1)

## 1.2 适用场景与局限性

Reflexion适合需要试错学习的任务，如决策、推理和编程。它计算效率高，无需模型微调，提供详细反馈和高可解释性。但局限包括依赖评估准确性、简单记忆机制，以及在非确定性编程任务中的挑战。
