# BigModel
大模型知识汇总



参考资料：

NLP教程：https://www.runoob.com/nlp/nlp-tutorial.html

**CoT/ReAct 解决了 Agent 的“行动闭环”，而 Memory 解决了 Agent 的“经验积累”。**

**Naive RAG / Conversational Memory：** 解决**“记住了什么”**的问题。

**Agentic RAG：** 解决**“记什么、怎么记、怎么用”**的问题。这是从“被动接收”到“主动学习”的关键一步。

“LLM 是文本生成器，RAG 是一种外部知识检索的技术手段。但 **Memory System** 才是把 Agent 推向 **长期智能、个性化和状态管理** 的关键一步。

**企业需要的不是一个只会查文档的系统，而是能积累经验、记住用户、能自我更新知识的 Agent。**

所以，Memory 是工程级 Agent 体系中，与 ReAct 框架同等重要的底层范式。”



常常面临以下挑战：

- **事实幻觉：**模型可能生成看似合理但不准确的信息；
- **缺乏实时信息：**模型训练数据截止后的新信息无法获取；
- **规划能力不足：**面对复杂任务时难以分解和制定有效策略；
- **错误传播：**单个错误推理可能导致整个任务失败；



语义检索的本质就是向量计算



![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_lossy/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F0681d04f-0cd6-45a7-b1f1-a37f9269d01d_1116x1126.gif)

LLaMA 4 并不完全依赖于经典的 Transformer 架构。相反，它采用了一种混合专家（MoE）方法，每个令牌仅激活一小部分专家子网络。



大型语言模型（LLM）的规模已经大幅增长，参数数量达到数百亿甚至数千亿。为了提高这些模型的效率，最近出现了一种创新方法，即专家混合模型（MoE）架构。

与模型的每个部分对每个输入都处于激活状态不同，MoE 网络仅针对每个标记激活“专家”子网络的子集。

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_lossy/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F89aa177b-ab94-48f1-873f-787dd42d5f69_1080x846.gif)



这意味着每次前向传播只使用模型的一小部分参数，从而在保持性能的同时降低计算成本。

换句话说，MoE 使我们能够扩展模型容量，而无需按比例增加计算需求。

举例来说，Meta 的 LLaMA 4（LLaMA 系列 LLM 的最新版本）采用了 MoE 架构。

例如，LLaMA 4 Maverick 使用了 128 位专家，但每个 token 只激活几个专家，以大约一半的推理成本实现了 GPT-4 水平的性能。

MoE 是 LLaMA 4 能够如此庞大而高效的一个重要原因——这表明这一理念在当前的 AI 研究中有多么重要（https://www.dailydoseofds.com/building-llama-4-from-scratch-with-python/）。





![](https://www.dailydoseofds.com/content/images/2025/05/a2avsmcp-ezgif.com-crop.gif)



- 截断和滑动窗口：对于多轮对话（例如聊天机器人），一种常见的做法是尽可能多地将最近的对话/聊天记录包含在窗口中，同时移除较早的消息或对其进行摘要。虽然这可以确保模型看到最新的用户查询和一些历史记录，但可能会丢失重要的早期上下文信息。

![](https://www.dailydoseofds.com/content/images/2025/05/sliding.svg)

- 摘要：另一种策略是将冗长的文档或对话记录概括成模型可以处理的简短形式。然后，将摘要作为上下文提供给模型。虽然这种方法可以捕捉关键信息，但也引入了额外的出错风险。例如，糟糕的摘要可能会遗漏关键细节，甚至引入不准确之处。此外，为每种潜在上下文即时生成高质量的摘要也相当耗时。

​           ![](https://www.dailydoseofds.com/content/images/2025/05/summarizer.svg)   	

向量数据库FAISS、Milvus
