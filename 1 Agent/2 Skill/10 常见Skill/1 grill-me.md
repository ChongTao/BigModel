# 一 grill-me

`grill-me` 是一个面向 Claude Code / Agent Skills 生态的“设计审问（design grilling）”类 Skill。  
它的核心目标是在真正开始编码前，通过高强度追问（interrogation）把需求、架构、边界条件和隐含假设尽可能挖出来。

这类 Skill 的价值很高，因为很多开发任务真正的问题不是“不会写”，而是：

- 目标没有说清楚
- 约束条件没有暴露出来
- 边界场景没有讨论
- 假设太多，导致后面返工

因此，`grill-me` 更像一个“开始干活前先把问题问透”的 Skill。

## 1.1 适合什么时候用

`grill-me` 特别适合以下情况：

- 任务目标还比较模糊
- 方案还没有定下来
- 需要先把风险点和边界条件问清楚
- 开始编码前希望先做一次设计审查

它不太适合已经完全明确、只差执行的简单任务。

## 1.2 安装示例

下面是一个常见安装方式：

```sh
mkdir -p ~/.claude/skills/grill-me
curl -L https://claudskills.com/skills/grill-me/SKILL.md \
  -o ~/.claude/skills/grill-me/SKILL.md
```

安装完成后，这个 Skill 就会作为本地可用 Skill 被运行时发现。

## 1.3 实际作用

这类 Skill 的典型作用不是直接输出代码，而是帮助 Agent 或用户先回答这些问题：

- 这个需求真正要解决什么问题？
- 成功标准是什么？
- 有哪些输入输出约束？
- 有没有历史方案或兼容性要求？
- 最容易忽略的边界条件是什么？

因此，它更适合作为“编码前置步骤”，而不是直接替代编码类 Skill。

## 1.4 相关链接

- `grill-me` 页面：`https://www.skills.sh/mattpocock/skills/grill-me`
- Claude Code Skills 文档：`https://docs.claude.com/en/docs/claude-code/skills`
