# Prompt Engineering（提示词工程）

## 1. Prompt Engineering 是什么

Prompt Engineering（提示词工程）是在给定模型和应用接口的前提下，组织任务指令、上下文、示例和输出约束，以改善模型任务表现并便于评估的过程。它不改变模型参数，也不是只改写一段普通文本：实际请求可能包含带角色的消息、工具结果和多模态内容。

Prompt 设计可以减少歧义、改善指令遵循和格式一致性，但不能单独保证事实正确、消除幻觉或提供安全边界。最终效果还受模型能力、消息模板、上下文质量、生成参数、检索与工具、应用侧校验等因素影响。

### 1.1 Prompt Engineering 关注什么

常见目标包括：

- 让任务、成功标准和约束更清晰
- 提供模型完成任务所需的相关上下文与示例
- 提高输出格式和风格的一致性
- 通过评测发现失败类型，并迭代改进

### 1.2 Prompt Engineering 不是什么

- 它不是模型训练或微调本身
- 它不是 RAG；提示词可以承载检索结果，但检索与知识更新属于系统能力
- 它不是工具调用协议；模型提出工具调用意图后，还需要应用执行和返回结果
- 它也不等于完整的 Agent 或工作流

Prompt Engineering 是模型应用的一部分；Context Engineering 则更广泛地关注如何选择、组织、压缩和维护模型可用的全部上下文。

## 2. 核心原则

### 2.1 说清任务和成功标准

明确要求模型做什么、处理哪些对象，以及什么结果算完成。相比“分析一下”，可以说明要找出几项问题、使用哪些标准、如何排序，以及信息不足时如何处理。

### 2.2 说明角色、受众和语气

角色描述可以帮助限定视角、专业语气或受众，例如“面向初学者解释”。角色本身不会赋予模型真实资质或额外能力；关键事实和专业判断仍需依据可靠资料或人工审核。

### 2.3 提供必要上下文并标明来源

根据任务提供必要背景、限制、输入资料和相关历史。区分已知事实、用户假设和外部材料；避免把无关内容塞进上下文，也不要把未经核实的资料写成确定事实。

### 2.4 明确输出要求

说明语言、长度、字段、排序方式和格式。普通文本中的“请输出 JSON”只是指令，不能保证结果一定是合法 JSON；面向程序处理时，应结合结构化输出能力和应用侧校验，见第 5 节。

### 2.5 按需提供示例

Few-shot 示例可以展示期望的格式、风格和任务边界，但不会更新模型参数。示例应与指令一致，覆盖有代表性的输入；错误、矛盾或单一的示例可能使输出产生偏差。

### 2.6 说明信息不足时的处理方式

对依赖事实或决策的任务，明确模型应在何时提出澄清问题、标注假设、说明不确定性或拒绝猜测。提示词可以引导这种行为，但不能取代事实核查和风险控制。

## 3. 常见 Prompt 方法

### 3.1 Zero-Shot Prompting

零样本提示不提供任务示例，只给任务说明。适合模型熟悉、格式简单且边界清楚的任务；复杂约束和特殊格式下，结果可能不稳定。

### 3.2 Few-Shot Prompting

少样本提示在任务说明中加入少量示例，帮助模型在当前上下文中参照输入与输出模式。它适合格式或风格要求明确的任务，但会占用上下文；示例选择不当也会带偏结果。

### 3.3 Chain-of-Thought（CoT）

CoT 是通过提示或示例引导模型使用中间推导来处理任务的一类研究方法。在部分模型和数学、符号推理等任务上，它可能带来帮助，但效果取决于模型和任务，不能视为通用增益。

参考：[Chain-of-Thought Prompting 研究论文](https://arxiv.org/abs/2201.11903)；[推理模型实践指南](https://platform.openai.com/docs/guides/reasoning-best-practices)。

### 3.4 Self-Consistency

Self-Consistency 通过多次采样得到多条候选推导，再聚合或投票选择较一致的答案。它更适合有明确答案、且多次推导确实有价值的任务。

多次采样会增加 Token 消耗和响应时间；候选答案也可能共享同一错误，因此投票不等于事实验证。应在代表性数据上评估收益，再决定是否值得使用。

参考：[Self-Consistency 研究论文](https://arxiv.org/abs/2203.11171)。

### 3.5 Generate Knowledge

Generate Knowledge 是先让模型生成与问题相关的背景知识，再基于这些内容回答问题的研究方法。它可能帮助激活模型已有知识，但生成的背景本身也可能错误或过时，不能作为可靠来源。

适合将其用于构思或稳定知识领域的辅助推理；对最新事实、专业结论或需要出处的答案，应检索可信来源并核验。

参考：[Generated Knowledge Prompting 研究论文](https://arxiv.org/abs/2110.08387)。

### 3.6 Prompt Chaining

Prompt Chaining 把复杂任务拆成多个相互衔接的步骤，例如抽取信息、归类、再生成总结。实际落地通常包含工作流编排、步骤间的数据传递和中间结果处理，不只是写好几段提示词。

应验证关键中间结果，并考虑前序错误会传递到后续步骤；必要时加入规则、检索、工具或人工审核。

### 3.7 Active-Prompt

Active-Prompt 是一种基于不确定性选择样例的研究方法：识别模型较不确定的输入，优先为这些输入补充可信标注，再将其用于提示示例。它不等同于泛指的“自动搜索更好的提示词”。

自动生成候选提示词、打分和选择属于更广义的 Prompt Optimization，同样需要可靠的评测集验证，不能只根据少数案例判断改进。

参考：[Active-Prompt 研究论文](https://arxiv.org/abs/2302.12246)。

## 4. Prompt 的输入载体与可信边界

在聊天 API 中，Prompt 通常由带角色的消息和内容组成，并由目标模型对应的 Chat Template 转换为模型输入。角色是消息协议中的结构信息；在普通用户文本里写“system:”并不会自动获得系统消息的权限。不同模型和平台的消息格式可能不同，细节见[对话模板与上下文装配](02%20%E5%AF%B9%E8%AF%9D%E6%A8%A1%E6%9D%BF%E4%B8%8E%E4%B8%8A%E4%B8%8B%E6%96%87%E8%A3%85%E9%85%8D.md)。

现代模型输入还可能包含图像、音频、视频和工具结果，不只是纯文本。多模态格式和上下文预算应按目标模型/API 的要求处理，参见[Context Engineering](03%20Context%20Engineering.md)。

网页、检索片段、用户文档和工具结果都可能包含与应用指令冲突的内容。应标记来源，并把这些内容当作待分析数据；分隔符有助于表达边界，但不能单独阻止提示注入。工具权限、敏感操作和输出校验应由应用与工具层执行，详见[对话模板与上下文装配中的可信边界说明](02%20%E5%AF%B9%E8%AF%9D%E6%A8%A1%E6%9D%BF%E4%B8%8E%E4%B8%8A%E4%B8%8B%E6%96%87%E8%A3%85%E9%85%8D.md)。

## 5. 结构化输出与程序校验

当输出需要被程序消费时，仅在 Prompt 中写“请输出 JSON”并不能确保结果符合 JSON 语法或预期字段。若目标 API 支持 JSON Schema 或受约束输出，应优先使用相应机制；应用仍需处理拒答、截断、解析失败和业务规则校验。

不同模型/API 对结构化输出的支持和限制不同，参见[生成参数与结构化输出](../推理与生成/02%20%E7%94%9F%E6%88%90%E5%8F%82%E6%95%B0%E4%B8%8E%E7%BB%93%E6%9E%84%E5%8C%96%E8%BE%93%E5%87%BA.md)。

## 6. Prompt 评测与迭代

Prompt 的效果应通过代表性任务评估，而不是只凭一两个成功案例判断。可以按以下流程迭代：

1. 定义任务成功标准，并记录当前提示词和模型配置作为基线。
2. 准备覆盖常见输入、边界情况和已知失败类型的评测样例。
3. 每次修改后，用相同样例比较结果，并记录模型版本、提示词版本和生成参数。
4. 分析失败类型，检查事实正确性、格式遵循、安全性、延迟和成本。
5. 将有效变化纳入回归评测；若更换模型或参数，重新验证关键场景。

自动评测适合重复比较，重要或高风险任务还应结合人工审查。评测指标应与实际用途匹配。

## 7. Prompt 与其他能力的边界

### 7.1 RAG

RAG 通过检索引入外部知识。Prompt 可以说明如何使用检索结果，但不会自动完成检索、保证资料质量或验证引用。详见[01 RAG 概述](../../02%20%E6%A3%80%E7%B4%A2%E4%B8%8ERAG/RAG%E6%B5%81%E7%A8%8B/01%20RAG%E6%A6%82%E8%BF%B0.md)。

### 7.2 Tool Use / ReAct

Tool Use 和 ReAct 涉及模型提出行动、应用执行工具、再把结果交还模型的闭环。提示词只能描述行为要求，实际调用和权限控制由运行时系统实现。详见[ReAct](../../03%20Agent%E4%B8%8EHarness/Agent%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F/ReAct.md)。

### 7.3 Reflection / Reflexion

反思模式包含生成后的评估、修正或多轮迭代，通常需要额外的状态管理和工作流支持。提示词可以参与其中，但本身不等于完整机制。详见[Reflexion](../../03%20Agent%E4%B8%8EHarness/Agent%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F/Reflexion.md)。

### 7.4 Context Engineering

Prompt Engineering 主要关注任务指令、示例和输出要求；Context Engineering 还要管理对话历史、检索资料、工具结果、记忆和上下文预算。详见[Context Engineering](03%20Context%20Engineering.md)和[上下文压缩](04%20%E4%B8%8A%E4%B8%8B%E6%96%87%E5%8E%8B%E7%BC%A9.md)。

## 8. 一个实用的 Prompt 组织方式

与其记忆多个缩写，不如按任务需要组织以下内容：

1. **任务与成功标准**：要完成什么，如何判断完成。
2. **上下文与输入**：提供必要资料，并标出来源和边界。
3. **约束与不确定性处理**：说明限制、缺少信息时的处理方式，以及哪些内容不能猜测。
4. **输出要求**：指定语言、结构、字段、长度或格式。

例如：

> **任务：** 分析一款面向大学生的时间管理 App 留存率偏低的可能原因。
>
> **已知信息：** 目前只知道留存率偏低，尚未提供分群、时间趋势或用户反馈数据。
>
> **要求：** 将原因标为待验证假设，不要写成已证实事实；为每个假设列出需要补充的数据。若关键信息不足，请先提出澄清问题。
>
> **输出：** 用表格列出假设、依据、所需数据和验证方法。

ICIO、APE、CARE、TRACE 等缩写在不同资料中的展开方式和适用范围并不统一，不是标准协议或效果保证。研究文献中的 APE 还指 Automatic Prompt Engineer，需与 Action、Purpose、Expectation 之类的助记用法区分；参见 [Automatic Prompt Engineer 研究论文](https://arxiv.org/abs/2211.01910)。

## 9. 参考资料

### 官方文档

- [OpenAI：Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering)
- [OpenAI：Reasoning Best Practices](https://platform.openai.com/docs/guides/reasoning-best-practices)
- [OpenAI：Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
- [Anthropic：Prompt Engineering Overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [Google Gemini：Prompting Strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies)
- [Hugging Face：Chat Templates](https://huggingface.co/docs/transformers/chat_templating)

### 研究论文

- [Chain-of-Thought Prompting](https://arxiv.org/abs/2201.11903)
- [Self-Consistency](https://arxiv.org/abs/2203.11171)
- [Generated Knowledge Prompting](https://arxiv.org/abs/2110.08387)
- [Active-Prompt](https://arxiv.org/abs/2302.12246)
- [Automatic Prompt Engineer](https://arxiv.org/abs/2211.01910)

官方接口和模型能力会持续变化，具体行为、限制与参数应以目标模型/API 的文档为准。
