# 1 《Memory in the Age of AI Agents: A Survey》

## 1.1 引用

[Memory in the Age of AI Agents: A Survey](https://arxiv.org/pdf/2512.13564)对现有技术罗列，其提出一个**统一的记忆分类学（Taxonomy**，试图从**形式（Forms）、功能（Functions）和动态（Dynamics）**三个维度，彻底厘清AI记忆的本质。它标志着AI研究正从单纯追求模型参数规模，转向追求像人类一样具有连续认知能力的“具身智能”。

## 1.2 核心定义

为了科学地讨论记忆，论文首先用数学语言对智能体记忆系统进行了形式化定义。

1. 数字形式化：**记忆的生命周期**

   智能体的决策过程不仅仅依赖当前的观察，更依赖于一个不断演变的**记忆状态** (Memory State)。一个完整的记忆生命周期包含三个核心算子（Operators）：

   - **记忆形成**：通过函数**选择性地**将当前的经历转化为潜在的记忆候选者。
   - **记忆演化**：这是记忆“沉淀”的过程。新形成的记忆需要与老记忆融合、去重、甚至解决冲突。
   - **记忆检索**：当需要记忆时，它不会把整个记忆库抽取出来，而是通过函数R检索出最相关的一小段记忆。

2. 介绍Agent Memory不是什么？

   作者通过一张韦恩图来区分几个容易混淆的术语：

   ![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHSlyZLTmYlxwibqfpqqtzh5f0icdpMPRO5ug1icdW5icta5vdgrM4kYuh3aQ/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=1)

- **Agent Memory vs RAG**

  RAG是通常是静态的，而Agent Memory是动态的，它更像人的**大脑**，会随着交互不断改写、遗忘、总结。

- **Agent Memory vs. Context Engineering** 

  上下文工程关注的是“**如何把东西塞进有限的窗口里**”，而Agent Memory关注的是“**我是谁，我经历了什么**”。

- **Agent Memory vs. LLM Memory**

  LLM Memory通常指模型训练好后参数里隐含的知识，而Agent Memory通常指模型外部的、可读写的存储系统。

## 1.3 记忆存储

论文将记忆存储分为三类。

![](https://mmbiz.qpic.cn/mmbiz_jpg/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHS6eiaGYfP6u21OqQO9sIbq18VIiaxHfpFkEHUsKicuUI5NBDaJzVSWg8Vg/640?wx_fmt=jpeg&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=2)

1. 符号记忆

   记忆以自然语言（文本）或离散符号的形式存储在外边数据库中。这部分记忆特点是透明、可读、可编辑。其结构分类：

   - **扁平 (Flat)**: 像流水账日记，按时间顺序记录。适合简单对话。

   - **平面 (Planar/2D)**: 像思维导图或知识图谱，记忆之间有链接（图结构）。适合需要联想的任务。

   - **层级 (Hierarchical/3D)**: 像金字塔，底层是原始对话，上层是高度抽象的总结。适合长期记忆管理（如MemGPT）。

     ![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHSrpUQFdmJH4Wz06r4Qdy1roIlRaIzK2kIk1HgibcO7x3IzliaFKCiaXaPg/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=3)

2. 参数化记忆

   记忆被“内化”到了模型的神经元权重里。就好像人类学会了骑自行车，这种记忆变成了本能，你无法用语言精确描述每块肌肉怎么动，但你就是会。

   通过微调（Fine-tuning）或模型编辑（Model Editing），将新知识直接“烧录”进模型参数。其特点是调用速度极快（不需要检索），但更新成本高（需要重新训练），且容易发生“灾难性遗忘”（学了新知识忘了旧知识）。

3. 潜在记忆

   介于上述两者之间。记忆以**高维向量（Embedding）**或**KV Cache（键值缓存）**的形式存在。其特点是人类看不懂，但机器读得快。它比纯文本更浓缩，比参数更新更灵活。在多模态任务中，一张图片的记忆可能直接就是一个向量，而不是一段文字描述。

## 1.4 记忆用来做什么

作者跳出了简单的“长期/短期记忆”分类，而是从**解决什么问题**的角度，提出了新的功能分类。

![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHSwOV1u4bLsJA5KnPGLib8YKxqPndTicsIuwXibVPRNiaQtBG1NzlZWFFlicw/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=4)

1. **事实记忆 (Factual Memory)：解决“我知道什么”**

   这是为了保持**一致性**。

   - **用户事实**：记住用户的名字、喜好、过敏源。
   - **世界事实**：记住当前环境的状态（如“门是锁着的”）。
   - **作用**：防止AI产生幻觉，确保聊天的连贯性。

2. **经验记忆 (Experiential Memory)：解决“我如何变强”**

   这是为了**进化**。它是智能体从过去的成功或失败中提取的智慧。

   - **案例库 (Case-based)**: “上次遇到这个问题，我是这么解决的，成功了。”（直接抄作业）。
   - **策略库 (Strategy-based)**: “我发现这类问题通常需要先分析再行动。”（提炼出的SOP或方法论）。
   - **技能库 (Skill-based)**: 将经验转化为可执行的代码或工具调用（API）。
   - **核心价值**：这是通向**自主智能体（Self-evolving Agents）**的关键。没有它，AI永远在同一个坑里跌倒。

   ![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHS3uSrlkfVvjWoBwoWibwwzTGEP9URKyggs9VPnU1RWEqE7ZcflEcuayA/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=5)

3. **工作记忆 (Working Memory)：解决“我正在想什么”**

   这是为了**当下任务的推理**。

   - 它是一个有限的“缓存区”，用于处理当前的复杂任务。
   - **动态管理**：它不仅仅是堆砌上下文，而是涉及**输入压缩**（把长文变短）、**状态折叠**（把已经做完的步骤打包成一个总结，腾出空间给新步骤）。

## 1.5 记忆的“动态机制” (Dynamics)：记忆如何运作？

记忆不是静态的存储，而是一个动态的循环过程。

![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHSfoZpAGmARHKLicMqGdy5wRt86m6Chlw8BpZAXsLXssZC2etWH3L0icpA/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=6)

1. 记忆形成
   - **语义摘要**：把一万字的聊天记录压缩成一百字的大意。
   - **知识蒸馏**：从对话中提取出“用户喜欢吃苹果”这一条规则。
   - **结构化构建**：把散乱的信息整理成知识图谱。

2. **记忆演化 (Evolution)**
   - **整合 (Consolidation)**: 将碎片化的短期记忆合并成长期记忆。
   - **更新 (Update)**: 修正错误的记忆（如通过RAG的冲突解决）。
   - **遗忘 (Forgetting)**: 这非常关键！
     - **基于时间的遗忘**：像人一样，太久远的事变淡。
     - **基于价值的遗忘**：不重要的废话直接删掉。
     - **基于频率的遗忘**：很久不用的知识会被归档。

3. **记忆检索**
   - **检索时机**：是每说一句话都查记忆，还是只有由于不决时才查？（现在趋势是让AI自主决定何时检索）。
   - **检索策略**：不仅仅是关键词匹配，现在更多使用**混合检索**（关键词+向量语义+图关系）。

![](https://mmbiz.qpic.cn/mmbiz_png/gKaxjIx6bagbuwJNTvs5ltQbMVflkXHSKog9A0R4bMqyGz5VKsqZ0EmTp1PIfySbT1iaH2GCOf5gjibDtxCDN4yg/640?wx_fmt=png&from=appmsg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=7)