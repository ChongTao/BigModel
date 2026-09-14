# Superpowers

> Superpowers 是一套面向 Coding Agent 的软件开发工作流与 Skills 集合。
> 它的重点不是提供新的大模型，而是通过需求澄清、设计、计划、TDD、Debug、Code Review 和完成前验证等方法，约束 Agent 的开发过程，提高复杂任务的可控性和交付质量。

---

## 1. 项目概览

Superpowers 是一个开源的 Coding Agent 软件开发工作流项目，最初主要面向 Claude Code，当前也在逐步适配其他 Coding Agent。

官方仓库：

https://github.com/obra/superpowers

它可以理解为：

```text
普通 Coding Agent

用户需求
   ↓
Agent 理解
   ↓
修改代码
   ↓
测试
   ↓
完成
```

而 Superpowers 更强调：

```text
用户需求
   ↓
需求澄清 / Brainstorm
   ↓
设计
   ↓
Implementation Plan
   ↓
任务拆分
   ↓
TDD / 实现
   ↓
Code Review
   ↓
Verification
   ↓
完成 / 合并
```

核心思想是：

> 不只是让 Agent “写出代码”，而是让 Agent 按照软件工程流程完成任务。

---

# 2. Superpowers 解决什么问题

Coding Agent 在复杂项目中容易出现以下问题：

* 需求没有明确就开始修改代码；
* 忽略边界条件和非功能需求；
* 复杂任务一次性修改大量文件；
* 没有测试就认为功能完成；
* Debug 时不断尝试修改，而不是先定位根因；
* 长任务执行过程中逐渐偏离最初目标；
* 子 Agent 之间缺少明确的任务边界；
* Code Review 流程缺失；
* Agent 声称“已经完成”，但没有提供实际验证证据。

Superpowers 通过一系列 Skills 对这些问题进行流程化约束。

---

# 3. 核心理念

Superpowers 可以归纳为以下几个原则。

## 3.1 先理解，再实现

不要把：

```text
用户的一句话
```

直接转换成：

```text
代码修改
```

而是：

```text
需求
 ↓
澄清
 ↓
设计
 ↓
确认
 ↓
实现
```

---

## 3.2 Plan 优先

复杂任务应该先形成明确的实施计划：

```text
Requirement
    ↓
Design
    ↓
Implementation Plan
    ↓
Tasks
    ↓
Implementation
```

计划应该能够让其他开发者在缺少原始上下文的情况下继续执行，而不是只有：

```text
1. 修改代码
2. 增加测试
3. 完成
```

而应该明确到：

```text
1. 修改哪些文件
2. 为什么修改
3. 修改什么内容
4. 依赖哪些前置条件
5. 如何验证
```

---

## 3.3 测试优先

Superpowers 强调 TDD：

```text
RED
 ↓
GREEN
 ↓
REFACTOR
```

即：

1. 编写能够表达需求的失败测试；
2. 确认测试确实因为预期原因失败；
3. 编写最小实现；
4. 确认测试通过；
5. 在测试保护下进行重构；
6. 再次验证。

---

## 3.4 Evidence Before Completion

不要只说：

```text
功能已经完成。
```

而应该提供：

```text
执行了什么
 ↓
得到什么结果
 ↓
哪些测试通过
 ↓
哪些验证完成
```

例如：

```text
go test ./...
PASS

go vet ./...
PASS

git diff
确认只有预期文件发生变化
```

核心思想：

> 用证据证明完成，而不是用描述声称完成。

---

## 3.5 根因优先

Debug 时避免：

```text
失败
 ↓
猜一个原因
 ↓
修改
 ↓
失败
 ↓
再猜
```

而采用：

```text
问题复现
 ↓
收集证据
 ↓
定位 Root Cause
 ↓
验证 Root Cause
 ↓
实施修复
 ↓
回归测试
```

---

# 4. Superpowers 的整体架构

可以将 Superpowers 理解为：

```text
                    Superpowers
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ↓                ↓                ↓
    Requirement       Development       Verification
        │                │                │
        ↓                ↓                ↓
   Brainstorming      Planning          Testing
                         │                │
                         ↓                ↓
                    Implementation     Review
                         │                │
                         └───────┬────────┘
                                 ↓
                              Delivery
```

它并不是一个必须每次完整执行的固定 Pipeline。

更准确的理解是：

> **根据任务类型选择和组合不同 Skills。**

例如：

```text
简单 Bug
    ↓
systematic-debugging
    ↓
verification
```

而大型功能可能是：

```text
brainstorming
    ↓
writing-plans
    ↓
executing-plans
    ↓
TDD
    ↓
code-review
    ↓
verification
    ↓
finishing-development-branch
```

---

# 5. 核心 Skills

## 5.1 brainstorming

作用：

> 将模糊需求转化为明确的设计。

主要处理：

* 目标；
* 用户场景；
* 功能边界；
* 非目标；
* 技术约束；
* 数据模型；
* 接口；
* 异常情况；
* 兼容性；
* 验收条件。

典型流程：

```text
需求
 ↓
阅读代码 / 文档
 ↓
发现未知信息
 ↓
向用户确认
 ↓
提出方案
 ↓
确认设计
```

---

## 5.2 using-git-worktrees

作用：

> 为开发任务创建隔离的 Git Worktree。

适合：

* 大型功能；
* 并行开发；
* 子 Agent 开发；
* 不希望污染当前工作目录的任务。

结构类似：

```text
project/
├── main
├── worktree-feature-a
├── worktree-feature-b
└── worktree-fix
```

优点：

* 工作目录隔离；
* 降低多个任务相互污染的风险；
* 适合并行 Agent。

缺点：

* 增加分支和 Worktree 管理成本；
* 最终需要处理合并；
* 对简单任务没有必要。

---

## 5.3 writing-plans

作用：

> 将已经确认的设计转换为可执行的实施计划。

好的 Plan 应至少包含：

```text
Task
├── 文件
├── 修改内容
├── 实现细节
├── 依赖关系
└── 验证方式
```

例如：

```text
Task 1：增加 MemoryRepository

文件：
internal/memory/repository.go

修改：
增加 Save / Get / Delete 方法

验证：
go test ./internal/memory/...
```

---

## 5.4 executing-plans

作用：

> 按照实施计划执行任务。

适合：

* 已经有明确 Plan；
* 多步骤开发；
* 需要阶段性验证的任务。

重点不是简单地“执行 Markdown”，而是：

```text
Plan
 ↓
Task
 ↓
Implementation
 ↓
Test
 ↓
Review / Checkpoint
 ↓
Next Task
```

---

## 5.5 subagent-driven-development

作用：

> 使用独立上下文的 Sub Agent 执行具体工程任务。

典型流程：

```text
Main Agent
    │
    ├── Sub Agent A
    │      ↓
    │    Implement
    │      ↓
    │    Review
    │
    ├── Sub Agent B
    │      ↓
    │    Implement
    │      ↓
    │    Review
    │
    └── Main Agent
           ↓
         汇总
```

适合：

* 大型任务；
* 任务可以拆分；
* 希望减少单个上下文积累错误；
* 需要多个 Agent 协作。

---

## 5.6 dispatching-parallel-agents

作用：

> 将相互独立的任务并行交给多个 Agent。

适合：

```text
Task A ────────┐
Task B ────────┼──→ Merge
Task C ────────┘
```

不适合：

```text
Task A
 ↓
Task B
 ↓
Task C
```

这种强依赖任务。

特别需要注意：

> 多个 Agent 同时修改相同核心文件时，通常不适合并行执行。

---

## 5.7 test-driven-development

作用：

> 通过 TDD 降低实现偏差。

核心流程：

```text
RED
 ↓
确认失败原因
 ↓
GREEN
 ↓
REFACTOR
 ↓
验证
```

重点不是简单增加测试数量，而是：

> 让测试在实现之前约束设计和行为。

---

## 5.8 systematic-debugging

作用：

> 系统化定位 Bug 根因。

推荐流程：

```text
1. 复现
2. 收集证据
3. 缩小问题范围
4. 建立 Root Cause 假设
5. 验证假设
6. 修复
7. 回归测试
```

避免：

```text
修改 A
 ↓
测试
 ↓
修改 B
 ↓
测试
 ↓
修改 C
```

这种没有根因分析的试错式 Debug。

---

## 5.9 requesting-code-review

作用：

> 请求其他 Agent / Reviewer 审查当前实现。

重点关注：

### Specification Review

```text
是否完成需求？
是否遗漏 Plan？
是否满足验收条件？
```

### Code Quality Review

```text
代码是否合理？
是否引入不必要复杂度？
是否存在明显 Bug？
是否符合项目规范？
```

---

## 5.10 receiving-code-review

作用：

> 结构化处理 Code Review 意见。

不要：

```text
Reviewer 提意见
 ↓
全部照改
```

而应该：

```text
Review Comment
 ↓
判断正确性
 ↓
确认影响
 ↓
修改
 ↓
验证
```

---

## 5.11 verification-before-completion

作用：

> 在宣布任务完成之前进行最终验证。

例如 Go 项目：

```bash
go test ./...
go vet ./...
git diff
git status
```

根据项目实际情况增加：

```bash
go test -race ./...
golangci-lint run
make test
```

核心原则：

> 没有验证证据，不应该声称任务已经完成。

---

## 5.12 finishing-a-development-branch

作用：

> 完成开发后的分支收尾。

通常包括：

```text
确认测试
 ↓
确认 Diff
 ↓
选择后续动作
 ├── Merge
 ├── Pull Request
 ├── 保留分支
 └── 清理 Worktree
```

对于要求人工控制 Git 的项目，应特别注意：

> Superpowers 可以帮助完成开发流程，但不应该替代团队自己的 Git 提交和发布安全策略。

---

# 6. Skills 总览

| 分类     | Skill                            | 主要作用                   |
| ------ | -------------------------------- | ---------------------- |
| 需求     | `brainstorming`                  | 澄清需求、形成设计              |
| 环境     | `using-git-worktrees`            | 隔离开发环境                 |
| 计划     | `writing-plans`                  | 生成实施计划                 |
| 执行     | `executing-plans`                | 执行实施计划                 |
| 执行     | `subagent-driven-development`    | Sub Agent 驱动开发         |
| 协作     | `dispatching-parallel-agents`    | 并行执行独立任务               |
| 测试     | `test-driven-development`        | TDD                    |
| Debug  | `systematic-debugging`           | 系统化定位根因                |
| Review | `requesting-code-review`         | 发起代码审查                 |
| Review | `receiving-code-review`          | 处理代码审查意见               |
| 验证     | `verification-before-completion` | 完成前验证                  |
| 收尾     | `finishing-a-development-branch` | 分支 / Worktree 收尾       |
| 元能力    | `using-superpowers`              | Superpowers Skill 使用说明 |
| 元能力    | `writing-skills`                 | 创建和修改 Skill            |

---

# 7. Superpowers 与 Grill-me 的关系

Superpowers 与 Grill-me 有部分功能重叠，但定位不同。

## Grill-me

核心目标：

> 把需求问清楚。

```text
模糊需求
   ↓
持续提问
   ↓
用户做决策
   ↓
明确需求
```

它更像：

```text
产品经理
+
架构师
+
需求访谈
```

---

## Superpowers

核心目标：

> 把明确需求可靠地实现出来。

```text
需求
 ↓
设计
 ↓
Plan
 ↓
Implementation
 ↓
TDD
 ↓
Review
 ↓
Verification
 ↓
Delivery
```

更像：

```text
Tech Lead
+
Developer
+
Reviewer
```

---

## 两者组合

对于大型任务，可以采用：

```text
                 Grill-me
                    ↓
              明确业务需求
                    ↓
             Superpowers
                    ↓
              Technical Design
                    ↓
                  Plan
                    ↓
              Implementation
                    ↓
                  TDD
                    ↓
                 Review
                    ↓
               Verification
```

注意：

> 不建议让 Grill-me 和 Superpowers 的 `brainstorming` 对同一个任务重复进行完整需求访谈，否则会增加不必要的交互成本。

---

# 8. 实际使用策略

不是所有任务都需要完整使用 Superpowers。

## 8.1 简单任务

例如：

```text
修改一个配置
修改变量名
增加一个简单字段
查询代码
```

直接使用 Claude Code：

```text
Claude Code
```

不需要完整 Superpowers 流程。

---

## 8.2 中等任务

例如：

```text
增加一个 REST API
增加 Redis 缓存
增加一个 Go Service
修复一个复杂 Bug
```

推荐：

```text
需求澄清
 ↓
Plan
 ↓
Implementation
 ↓
Test
 ↓
Verification
```

必要时使用：

```text
brainstorming
systematic-debugging
verification-before-completion
```

---

## 8.3 大型任务

例如：

```text
重构核心模块
增加 Agent Memory
修改 RAG Pipeline
OpenSearch 检索架构调整
跨多个 Go Service 的功能
```

推荐完整流程：

```text
Grill-me（如果需求复杂且存在大量业务决策）
        ↓
Superpowers brainstorming
        ↓
Design
        ↓
writing-plans
        ↓
executing-plans
        ↓
TDD
        ↓
Subagent
        ↓
Code Review
        ↓
Verification
        ↓
Finishing Branch
```

---

# 9. Claude Code 中的安装

## 9.1 官方插件市场

在 Claude Code 中：

```text
/plugin install superpowers@claude-plugins-official
```

## 9.2 Superpowers Marketplace

```text
/plugin marketplace add obra/superpowers-marketplace

/plugin install superpowers@superpowers-marketplace
```

不同 Harness 的插件环境彼此独立。

例如：

```text
Claude Code
    ↓
安装 Superpowers

Codex
    ↓
需要单独配置

Cursor
    ↓
需要按照 Cursor 的方式配置
```

一个 Agent 中安装成功，并不意味着其他 Agent 自动获得该插件。

---

# 10. 安装后的验证

安装完成后，不建议只看：

```text
/plugin install
```

是否成功。

应该实际验证 Skill 是否能够加载。

可以检查：

```text
/help
```

以及：

```text
/superpowers:brainstorm
/superpowers:write-plan
/superpowers:execute-plan
```

然后使用一个小型测试项目进行验证。

例如：

```text
创建一个简单的 Go HTTP API。

要求：
1. 先进行需求澄清；
2. 形成设计；
3. 生成实施计划；
4. 使用 TDD 实现；
5. 最后执行测试并报告结果。
```

观察 Agent 是否按照预期进入对应工作流。

---

# 11. 与 CLAUDE.md 的关系

Superpowers 与 `CLAUDE.md` 不应该承担相同职责。

推荐：

```text
CLAUDE.md
    ↓
项目规则 / 项目事实 / 约束

Superpowers
    ↓
开发方法 / 工作流程

Custom Skills
    ↓
领域专业能力
```

例如 `CLAUDE.md`：

```text
技术栈：
Go 1.25
Gin
Redis
OpenSearch

代码规范：
...

测试：
go test ./...

Git：
禁止自动 commit
禁止自动 push
```

Superpowers：

```text
如何澄清需求
如何制定 Plan
如何 TDD
如何 Debug
如何 Review
如何 Verification
```

因此：

> CLAUDE.md 解决“这个项目应该遵守什么规则”，Superpowers 解决“Agent 应该如何完成复杂开发任务”。

---

# 12. 与 AGENTS.md 的关系

如果同时使用 Claude Code 和 Codex，可以考虑：

```text
CLAUDE.md
    ↓
Claude Code 专属配置

AGENTS.md
    ↓
跨 Coding Agent 的通用项目规则

Superpowers
    ↓
开发工作流
```

不要把 Superpowers 的完整工作流复制到：

```text
CLAUDE.md
AGENTS.md
```

否则容易形成重复规则。

推荐：

```text
                    Project
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
    CLAUDE.md       AGENTS.md     Superpowers
        │              │              │
   Claude规则       通用规则        工作流程
```

---

# 13. 与普通 Skill 的区别

| 对象          | 解决的问题                       |
| ----------- | --------------------------- |
| Skill       | 一个具体能力或工作步骤                 |
| Plugin      | Skills / Hooks / 配置等扩展能力的打包 |
| Superpowers | 一整套软件开发工作流                  |

例如：

```text
Go Skill
    ↓
Go 代码开发规范

OpenSearch Skill
    ↓
OpenSearch 专业知识

Superpowers
    ↓
如何把一个复杂 OpenSearch 功能从需求做到交付
```

因此 Superpowers 并不是“一个更大的 Skill”，而更接近：

> 一套可以组合多个 Skills 的工程工作流。

---

# 14. Git 与安全策略

Superpowers 可以使用：

* Git Branch；
* Git Worktree；
* Sub Agent；
* 测试命令；
* 代码修改；
* 分支收尾流程。

因此项目应该单独建立 Git 安全边界。

对于要求：

```text
Agent 可以修改代码
Agent 可以运行测试
Agent 不允许自动 commit
Agent 不允许自动 push
```

建议采用：

```text
CLAUDE.md
+
Git Hook
```

双保险。

不要只依赖 Superpowers 或 Agent 自己记住：

```text
禁止 git push
```

---

# 15. Token、时间和复杂度

Superpowers 并不是没有成本。

使用：

```text
Brainstorm
+
Plan
+
Subagent
+
Review
+
TDD
```

会增加：

* Token 消耗；
* Agent 执行时间；
* 上下文数量；
* Git Worktree 管理成本；
* 子 Agent 调度成本。

因此不应该：

> 所有任务都使用完整 Superpowers 流程。

推荐：

```text
任务复杂度
│
├── 小 ─────→ 直接 Claude Code
│
├── 中 ─────→ 部分 Skills
│
└── 大 ─────→ 完整 Superpowers
```

---

# 16. 推荐的实际工作模式

对于个人开发：

```text
简单任务
    ↓
Claude Code
```

```text
复杂需求
    ↓
Grill-me
    ↓
需求明确
    ↓
Superpowers
    ↓
Plan
    ↓
Implementation
    ↓
Verification
```

对于大型项目：

```text
用户需求
    ↓
需求澄清
    ↓
Design
    ↓
Implementation Plan
    ↓
Task 拆分
    ↓
Subagent
    ↓
TDD
    ↓
Code Review
    ↓
Verification
    ↓
人工 Git Review
    ↓
人工 Commit
    ↓
人工 Push
```

---

# 17. 一句话理解 Superpowers

可以把 Superpowers 理解成：

> **让 Coding Agent 从“帮我写代码”升级到“按照软件工程流程帮我完成开发任务”。**

而：

> **Grill-me 负责把“我要什么”问清楚，Superpowers 负责把“已经确定要做的东西”可靠地做出来。**

两者不是简单的替代关系，而是可以形成：

```text
Grill-me
需求澄清
    ↓
Superpowers
设计 → Plan → Code → Test → Review → Verify
    ↓
人工 Git / 发布
```

---

# 18. 推荐资料

官方仓库：

https://github.com/obra/superpowers

建议重点阅读：

```text
README
    ↓
Skills
    ↓
using-superpowers
    ↓
brainstorming
    ↓
writing-plans
    ↓
executing-plans
    ↓
subagent-driven-development
    ↓
test-driven-development
    ↓
systematic-debugging
    ↓
verification-before-completion
```

对于实际使用，优先掌握以下 6 个：

```text
1. brainstorming
2. writing-plans
3. executing-plans
4. test-driven-development
5. systematic-debugging
6. verification-before-completion
```

这 6 个基本覆盖了日常复杂 Coding Agent 任务的核心流程。
