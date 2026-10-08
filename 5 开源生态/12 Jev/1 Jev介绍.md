# Jev（TypeSafe AI）

Jev 是 TypeSafe AI 的 System One 模型，面向应用中的结构化判断，而不是聊天或自由文本生成。调用方传入待判断的 `state` 和一个或多个类型化问题，模型返回应用代码可直接处理的结果。

## 1 工作方式
Jev是一个语义决策引擎，需要提供如下：

- `state`：待判断的字符串、JSON 对象或文本数组，例如用户消息、工单上下文。
- `questions`：针对同一份 state 提出的类型化问题；多个问题可在一次请求中独立求值。

| 类型 | 用途 | 结果 |
| :--- | :--- | :--- |
| `Choice` | 分类、意图识别、路由 | 选项、各选项概率和置信度 |
| `Score` | 按量表评分 | 分数、概率和置信度 |
| `Noul` | 判断陈述是否成立 | “是”的概率（0–1） |

![](https://substackcdn.com/image/fetch/$s_!kVnj!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F20183228-e999-4dd4-91bd-d9e770e50e0d_2752x1536.jpeg)
通过 `POST /v1/systemone` 调用；输入限文本，不接收图像、音频或视频。典型流程是“业务状态 → 语义判断 → 应用代码按结果分支/复核”。

## 2 适用场景

- 工单分类、意图识别与队列路由
- 内容审核、风险判断、紧急程度或质量评分
- 判断是否满足语义条件，再决定是否调用工具或交由人工处理
- 在 Agent 或业务流程中加入结构化判断，让确定性控制流继续由应用代码负责

## 3 Python 快速调用

安装官方 SDK，并在运行环境中设置 `TYPESAFE_API_KEY`：

```sh
uv add typesafe-sdk
```

```python
from typesafe_sdk import Choice, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state={'message': 'I was charged twice.'},
        questions={
            'category': Choice(
                instructions='What is this ticket about?',
                criteria={'billing': None, 'technical': None, 'other': None},
            ),
        },
    )

print(response.choices['category'].choice)
```

## 4 开源生态

- [Python SDK](https://github.com/typesafe-ai/typesafe-sdk-python)：官方 Python 客户端，MIT 许可；[JavaScript / TypeScript SDK](https://github.com/typesafe-ai/typesafe-sdk-js)：官方 JS / TS 客户端。
- [Agent Skills](https://github.com/typesafe-ai/skills)：供编程 Agent 查询文档和生成集成，MIT 许可。
- [System One Adapter for Python](https://github.com/typesafe-ai/system-one-adapter-python)：用其他 LLM API 适配相同接口以便比较测试；不是 Jev 权重或本地 Jev 推理服务，MIT 许可。

## 5 使用边界

- Jev 适合分类、路由、审核、风险/质量评分和 Agent 工具调用前的语义判断；不负责生成回复、代码或解释，不替代通用聊天模型。
- 官方说明中文等 CJK 语言可输入，但准确率低于主要训练语言英语；上线前应使用目标数据评测。
- 概率和置信度不保证单条判断正确。通过离线评测设阈值，并为低置信度或高风险结果保留人工复核。
- 精确计算、计数、日期比较等交给代码；多步推理应拆成窄问题，再由应用组合结果。
- SDK 默认使用 `jev-latest`；对结果敏感时固定模型版本并回归测试。价格、版本和速率限制以官方文档为准。

## 6 参考

- [官方文档：Introduction](https://docs.typesafe.ai/introduction) / [System One](https://docs.typesafe.ai/concepts/system-one)
- [问题类型](https://docs.typesafe.ai/primitives) / [模型版本与限制](https://docs.typesafe.ai/models) / [API 参考](https://docs.typesafe.ai/api)
- [TypeSafe AI 官方 GitHub 组织](https://github.com/typesafe-ai)

资料核对日期：2026-10-08。
