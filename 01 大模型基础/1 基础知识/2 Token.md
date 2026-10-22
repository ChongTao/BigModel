# Token

Token 是模型读写文本的最小离散单位：输入文本先被切成 Token 并映射成整数编号，模型输出也是词表上的 Token 概率分布。

## 1. Token 是什么

Token 是由 Tokenizer 和词表共同定义的文本离散单位。它不完全等于“一个字”，也不完全等于“一个单词”，可能对应完整词、子词片段、单个字符、字节片段，也可能是不对应任何可见文字的特殊标记。

可以把 Token 理解为模型眼中的“文本积木”：积木的形状由词表事先决定，模型只能拼装词表里已有的积木。

### 1.1 与“字”“词”的关系

| 文本类型 | 常见切分结果 | 说明 |
| --- | --- | --- |
| 高频英文单词 | 1 个 Token | 常用词通常整词入表 |
| 低频英文词 | 多个子词 Token | 例如 `unbelievable` 可能切成 `un` + `believ` + `able` |
| 中文常用字词 | 1 个或多个 Token | 高频字词常整词入表，生僻字可能落到字节级 |
| 代码标识符 | 多个 Token | 驼峰、下划线命名常被拆开 |
| 长数字 | 多个 Token | 多位数字通常按固定位数切分 |
| Emoji 与生僻符号 | 多个 Token | 多字节 UTF-8 字符可能被拆成字节片段 |

表中只是常见情况。同一段文本在不同模型下的切分结果不同，必须用目标模型的 Tokenizer 实测确认。

### 1.2 Token 的三种形态

同一个 Token 在链路里会经历三种形态，讨论问题时要先明确指的是哪一种：

1. **文本片段**：切分出来的字符串，例如 `"模型"`、`"un"`、`"able"`
2. **整数编号**：`token id`，即该片段在词表中的下标
3. **向量表示**：`token id` 查 Embedding 表得到的浮点向量

```text
"模型" → 片段 "模型" → token id 18532 → [0.12, -0.84, 1.07, ..., 0.33]
```

编号与向量均为示例值，实际取决于具体模型。由此要区分三件事：

- Token 本身不是向量，向量是查表之后的结果。
- Token 本身不是概率，概率是模型在词表上输出的分布。
- Token 最初只是被切分出来的文本单位及其编号。

## 2. Token 的作用

### 2.1 模型的输入输出单位

神经网络只能处理数值，所以文本必须先离散化：`token id` 查表变成向量进入模型，模型最后一层输出词表大小的概率分布，再解码回文本。词表因此划定了模型能读写的全部符号，不在词表里的内容只能由若干已有 Token 组合表示。

### 2.2 容量、费用与性能的计量单位

| 维度 | 为什么以 Token 计量 | 深入内容 |
| --- | --- | --- |
| 上下文容量 | 上下文窗口是一次调用可用的 Token 预算，输入与输出共同占用 | [1 LLM基本概念](1%20LLM%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md) 的上下文窗口部分 |
| 费用 | 输入与输出分别按 Token 计价，输出单价通常更高 | [成本](../../05%20%E7%94%9F%E4%BA%A7%E5%B7%A5%E7%A8%8B/%E6%88%90%E6%9C%AC%E4%B8%8E%E5%BB%B6%E8%BF%9F/%E6%88%90%E6%9C%AC.md) |
| 延迟 | TTFT 衡量首 Token 延迟，TPOT 衡量每个输出 Token 的时间 | [延迟](../../05%20%E7%94%9F%E4%BA%A7%E5%B7%A5%E7%A8%8B/%E6%88%90%E6%9C%AC%E4%B8%8E%E5%BB%B6%E8%BF%9F/%E5%BB%B6%E8%BF%9F.md)、[04 推理性能指标与Benchmark](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/%E6%8E%A8%E7%90%86%E5%B7%A5%E7%A8%8B/04%20%E6%8E%A8%E7%90%86%E6%80%A7%E8%83%BD%E6%8C%87%E6%A0%87%E4%B8%8EBenchmark.md) |
| 吞吐与显存 | 序列越长，注意力计算量和 KV Cache 占用越大 | [02 KV Cache与PagedAttention](../../04%20%E6%8E%A8%E7%90%86%E4%B8%8E%E9%83%A8%E7%BD%B2/%E6%8E%A8%E7%90%86%E5%B7%A5%E7%A8%8B/02%20KV%20Cache%E4%B8%8EPagedAttention.md) |

### 2.3 结构与边界的标记

特殊 Token 不对应可见文字，却决定消息边界、角色归属和生成何时停止，例如序列起止标记、填充标记、对话模板中的角色分隔标记。

### 2.4 能力边界的一个来源

切分粒度会影响部分任务的表现。逐字符任务（数位数、拼写、回文、按字符对齐）在子词切分下并不容易，因为模型看到的是子词而不是字符；这类任务通常要把字符显式写进上下文，或交给代码处理。多语言与代码的切分效率差异也来自词表覆盖，见第 4 节。

## 3. Token 是怎么生成的

Token 由 Tokenizer 生成，典型流程分四步：

```text
原始文本 → 归一化 → 预切分 → 子词切分 → 词表映射 → token id 序列
```

### 3.1 归一化

先把文本统一到可比较的形式：Unicode 规范化（如 NFC、NFKC）、大小写处理、全角半角转换、空白与控制字符清理。归一化规则的差异会让“看起来一样”的文本产生不同 Token，例如全角空格与半角空格、组合字符与预组合字符。

### 3.2 预切分

把文本切成粗粒度片段，作为后续合并的边界：

- 以空格和标点为主要分隔，适合英文等有天然分隔符的语言。
- 字节级 BPE 先用正则把文本切成更细的单元，再在字节层面合并。
- SentencePiece 一类实现直接处理原始文本流，不依赖空格，对中文、日文这类不写空格的语言更稳定。

预切分规则决定合并不能跨越的边界，所以标点、换行和缩进都会影响最终 Token 数。

### 3.3 子词切分

主流方案都在“词表大小”和“序列长度”之间找平衡：

| 方案 | 训练阶段做什么 | 推理阶段怎么切 | 常见使用方 |
| --- | --- | --- | --- |
| BPE | 统计相邻单元共现频次，反复合并最高频组合，得到合并规则表 | 按合并规则的优先级依次应用 | GPT 系列等多数开放权重模型 |
| WordPiece | 选择让语料似然提升最多的合并，评分为 `p(AB) / (p(A)·p(B))` | 贪心地按最长匹配切分，续接片段带 `##` 标记 | BERT 系列 |
| Unigram LM | 从较大的候选子词集出发，按语料似然逐步裁剪 | 用 Viterbi 找概率最大的切分，也可采样多种切分 | SentencePiece 常用配置 |
| 字节级 BPE | 以 256 个字节为基础单元训练合并规则 | 文本转字节后再合并 | 需要覆盖任意 Unicode 的模型 |

BPE 的合并过程可以这样理解（示意，非真实词表）：

```text
语料: low lower lowest newest widest
初始: l o w | l o w e r | l o w e s t | n e w e s t | w i d e s t
合并: (l,o) → lo   (lo,w) → low   (e,s) → es   (es,t) → est
结果: low | low er | low est | new est | wid est
```

字节级 BPE 的好处是永远不会遇到未知字符：任何文本都能用字节表示；代价是词表覆盖不足的语言和生僻符号要付出更多 Token。

### 3.4 词表映射

切分出的每个片段在词表中查到一个整数下标，即 `token id`。词表大小同时决定 Embedding 层和输出层的维度，因此 Tokenizer 与模型权重是绑定关系：预训练结束后更换 Tokenizer，这两层参数就全部失效。

### 3.5 特殊 Token 从哪里来

特殊 Token 不是从文本切分得到的，而是由对话模板、推理框架或调用方注入：

- 序列开始与结束标记：界定一段完整输入，并作为生成终点。
- 角色分隔标记：把 system、user、assistant、tool 的内容分开。
- 填充标记：批处理时把不等长序列补齐。
- 停止序列：命中后结束生成。

这些 Token 同样占用上下文预算并计入费用，本地估算时最容易漏掉。

### 3.6 结果确定，但只对特定 Tokenizer 有效

同一段文本在同一个 Tokenizer 版本下的切分结果是确定、可复现的；换模型、换模型版本或换 Tokenizer 配置，结果都可能变化。因此：

- 跨模型比较上下文长度和费用时，不能直接套用同一数字。
- 中文与英文的 Token 比例取决于具体 Tokenizer 和文本内容，不存在固定换算系数。
- 上线前要用目标模型的 Tokenizer 复测，而不是沿用旧模型的估算。

## 4. 词表大小与压缩率

**词表大小是一组权衡**。词表越大，同一段文本切出的 Token 越少，序列更短、训练与推理更快，但 Embedding 层和输出层参数更多；词表越小则相反。

**压缩率决定账单**。压缩率指每个 Token 平均承载多少字符或信息量。同一段中文在不同模型下的 Token 数可能相差一倍以上，直接影响：

- 一次调用能装进上下文窗口的内容量
- 输入与输出的 Token 费用
- 生成同样内容所需的步数与延迟

**多语言需要均衡**。若词表对某些语言覆盖不足，这些语言的文本会付出成倍 Token 成本，同样的窗口能装的内容更少。这也是“支持某种语言”往往要从 Tokenizer 设计阶段就考虑的原因。

## 5. 怎么数 Token

原则是：用目标模型自己的 Tokenizer 实测，不要按字符数或词数换算。

Hugging Face Transformers 示例：

```python
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("<模型名或本地路径>")
text = "大模型基础知识"
ids = tokenizer(text)["input_ids"]

print(len(ids))
print(tokenizer.convert_ids_to_tokens(ids))
```

tiktoken 示例：

```python
import tiktoken

enc = tiktoken.get_encoding("cl100k_base")
ids = enc.encode("大模型基础知识")

print(len(ids), ids)
```

不同口径的结果可能有差异：

| 口径 | 适用场景 | 注意 |
| --- | --- | --- |
| 本地 Tokenizer 计数 | 预估上下文占用、裁剪长文本 | 不含服务端注入的模板与特殊 Token |
| 渲染对话模板后计数 | 估算真实请求长度 | 需要套用模型对应的 Chat Template |
| 接口返回的 usage | 对账与成本核算 | 计费依据，包含全部开销 |

批量场景可以先抽样实测出“每千字符 Token 数”的经验系数再放大估算，但要保留误差范围并定期复测。

## 6. 常见误区

- “1 个汉字 = 1 个 Token”：不成立，中文可能一个词一个 Token，也可能拆成多个字节级 Token。
- “Token 数 = 字数或词数”：不同 Tokenizer 之间没有固定换算关系。
- “Token 就是向量”：向量是 `token id` 查表后的结果。
- “换个模型 Token 数差不多”：词表和压缩率差异可能带来成倍差距。
- “只算可见文字就够了”：特殊 Token 和对话模板同样计入预算与费用。
- “上下文长度按字数算”：窗口限制的是 Token 总数，且输入与输出共享。

## 参考资料

- [Summary of the Tokenizers（Hugging Face）](https://huggingface.co/docs/transformers/tokenizer_summary)：BPE、WordPiece、Unigram 与字节级切分的对照说明。
- [Neural Machine Translation of Rare Words with Subword Units](https://arxiv.org/abs/1508.07909)：BPE 用于子词切分的代表工作。
- [Google's Neural Machine Translation System](https://arxiv.org/abs/1609.08144)：WordPiece 切分的公开实例。
- [Subword Regularization](https://arxiv.org/abs/1804.10959)：Unigram 语言模型切分与多切分采样。
- [SentencePiece](https://arxiv.org/abs/1808.06226)：不依赖空格预切分的语言无关分词实现。
- [tiktoken](https://github.com/openai/tiktoken)：BPE 计数的开源实现。
