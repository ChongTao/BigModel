# 一 常见的 Skill 使用

这一篇不再展开讲 Skill 的概念本身，而是从“怎么用”出发，介绍常见 Skill 的使用方式，以及一个具有代表性的 Skill 示例。

如果还没有看 Skill 的基本定义，建议先读：[1 Agent/2 Skill/1 Skill概述.md](./1%20Skill%E6%A6%82%E8%BF%B0.md)

如果后续有新的常见 Skill，建议优先补充到独立目录中，再在本篇增加索引：

- [1 Agent/2 Skill/10 常见Skill/1 grill-me.md](./10%20%E5%B8%B8%E8%A7%81Skill/1%20grill-me.md)

# 二 Skill 的常见使用方式

实际使用 Skill 时，通常不是“安装完就自动变强”，而是围绕下面几个环节展开：

## 2.1 安装 / 放置 Skill

在 Claude Skills 这类实现里，常见做法是把 Skill 放到本地的 skills 目录中，例如：

- `~/.claude/skills/<skill-name>/`

目录里最重要的文件通常是：

- `SKILL.md`

如果这个 Skill 还包含脚本、模板、参考资料，那么还会有：

- `scripts/`
- `examples/`
- `REFERENCE.md`

## 2.2 通过任务触发 Skill

Skill 一般不会靠用户手动“点按钮启动”，而是通过任务语义去触发。  
也就是说，Agent 会根据：

- 用户当前在做什么任务
- 任务描述里出现的关键词
- 上下文中暴露出的目标和边界条件

来判断是否应该加载某个 Skill。

因此，一个 Skill 是否好用，很大程度上取决于：

- 描述是否清晰
- 触发条件是否准确
- 任务边界是否明确

## 2.3 与工具配合使用

很多 Skill 本身并不直接完成任务，而是：

- 告诉 Agent 应该先做什么
- 提示应该调用哪些工具
- 约束输出格式和检查步骤

所以 Skill 常见的真实工作方式是：

> Skill 提供任务级处理套路，Tool 提供原子执行能力。

## 2.4 多个 Skill 组合使用

一个复杂任务里，往往不只会命中一个 Skill。  
例如：

- 先用“需求澄清 Skill”把目标问清楚
- 再用“代码生成 Skill”完成实现
- 最后用“代码评审 Skill”检查风险

这种组合方式比写死成完整 workflow 更灵活。

# 三 常见 Skill 索引

## 3.1 `grill-me`

设计审问类 Skill，适合在开始编码前先把需求、边界条件和隐含假设问透。  
详细见：[1 Agent/2 Skill/10 常见Skill/1 grill-me.md](./10%20%E5%B8%B8%E8%A7%81Skill/1%20grill-me.md)

# 四 其他常见 Skill 方向

除了 `grill-me` 这种“需求澄清 / 设计审问”类 Skill，实际工作中常见的 Skill 方向还包括：

## 4.1 代码理解类 Skill

例如：

- 仓库结构分析
- 调用链梳理
- 模块职责识别
- 依赖关系追踪

这类 Skill 通常会结合代码搜索、AST、代码图等工具一起工作。

例如可以进一步关注：

- `https://github.com/colbymchenry/codegraph`

## 4.2 代码评审类 Skill

这类 Skill 更关注：

- 先找 bug 和风险
- 再给修改建议
- 最后补充测试和回归影响

它通常适合在代码生成或代码修改之后使用。

## 4.3 文档处理类 Skill

例如：

- PDF 表单处理
- 文档摘要
- 结构化信息抽取
- Markdown 规范化整理

这类 Skill 很适合沉淀成“脚本 + 说明 + 模板”组合包。

## 4.4 调研分析类 Skill

例如：

- 竞品分析
- 技术选型对比
- 需求梳理
- 问题排查

这类 Skill 往往会结合搜索、检索、结构化输出模板一起使用。

# 五 使用建议

## 5.1 先装高频 Skill，不要一开始装太多

如果一开始堆太多 Skill，容易出现：

- 触发冲突
- 职责重叠
- 维护困难

更好的方式是先装最常用、最有价值的 2 到 5 个。

## 5.2 让 Skill 描述尽量任务导向

比起写“这是一个很强大的 Skill”，更应该写清楚：

- 它解决哪类任务
- 什么时候触发
- 不适合处理什么问题

## 5.3 把 Skill 当作经验资产维护

一个好 Skill 本质上是团队经验的沉淀。  
所以需要定期维护：

- 更新脚本
- 更新参考资料
- 修正文档
- 收敛触发边界

# 六 相关资源

- Claude Code Skills 文档：`https://docs.claude.com/en/docs/claude-code/skills`
- `grill-me` 页面：`https://www.skills.sh/mattpocock/skills/grill-me`
- 代码图工具参考：`https://github.com/colbymchenry/codegraph`
