# Claude Code 项目结构

```html
your-project/
├── CLAUDE.md                    ← 团队共享指令，提交到 git
├── CLAUDE.local.md              ← 个人覆盖，被 git 忽略（加入 .gitignore）
└── .claude/
    ├── settings.json            ← 权限 + 配置，提交到 git
    ├── settings.local.json      ← 个人权限，被 git 忽略
    ├── memory/                  ← 自动记忆存储（Claude 自动维护）
    │   └── MEMORY.md
    ├── commands/                ← 自定义斜杠命令
    │   ├── review.md            →  /project:review
    │   ├── fix-issue.md         →  /project:fix-issue
    │   └── deploy.md            →  /project:deploy
    ├── rules/                   ← 模块化指令文件（全局生效）
    │   ├── code-style.md
    │   ├── testing.md
    │   └── api-conventions.md
    ├── skills/                  ← 自动调用的工作流
    │   ├── security-review/
    │   │   └── SKILL.md
    │   └── deploy/
    │       └── SKILL.md
    └── agents/                  ← 子代理角色定义
        ├── code-reviewer.md
        └── security-auditor.md
```

![](https://www.runoob.com/wp-content/uploads/2026/03/claude-code-project-runoob-1.svg)

## 1.1 CLAUDE.md

`CLAUDE.md`是 Claude 系统提示词的一部分，使每次对话都能预先加载项目上下文，不再需要重复解释基本信息。一份好的 CLAUDE.md 应该覆盖三个维度：

- WHAT（是什么）：技术栈、项目结构，为 Claude 提供代码库的全局地图
- WHY（为什么）：项目的目的，各模块的功能与定位
- HOW（怎么做）：开发方式，例如使用 bun 而非 node，以及 Claude 如何验证改动是否正确

`CLAUDE.md`放置在项目根目录，所有团队成员共享，它告诉 Claude：这个项目是什么、如何运行、有什么约定。

Claude Code 会从多个位置加载 `CLAUDE.md`，不同位置的文件作用范围不同：

| 范围         | 位置                                                         | 目的                                  | 用例示例                         | 共享对象                 |
| :----------- | :----------------------------------------------------------- | :------------------------------------ | :------------------------------- | :----------------------- |
| **托管策略** | • macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md` • Linux 和 WSL: `/etc/claude-code/CLAUDE.md` • Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | 由 IT/DevOps 管理的组织范围指令       | 公司编码标准、安全策略、合规要求 | 组织中的所有用户         |
| **用户指令** | `~/.claude/CLAUDE.md`                                        | 所有项目的个人偏好                    | 代码样式偏好、个人工具快捷方式   | 仅你（所有项目）         |
| **项目指令** | `./CLAUDE.md` 或 `./.claude/CLAUDE.md`                       | 项目的团队共享指令                    | 项目架构、编码标准、常见工作流   | 通过源代码控制的团队成员 |
| **本地指令** | `./CLAUDE.local.md`                                          | 个人项目特定偏好；添加到 `.gitignore` | 你的沙箱 URL、首选测试数据       | 仅你（当前项目）         |

### 1.1.1 用 @ 语法引用外部文件

当项目已经有了规范文档（如 API 设计规范、数据库设计文档等），不需要将内容复制到 `CLAUDE.md` 中，直接用 `@文件路径` 引用即可。

Claude 读取 `CLAUDE.md` 时会自动加载引用的文件内容：

```html
## 规范文档

详细的 API 设计规范请参考：
@docs/api-design-guide.md

数据库设计约定：
@docs/database-conventions.md

组件库使用说明：
@docs/component-guidelines.md
```

> 引用的文件路径是相对于 `CLAUDE.md` 所在目录的相对路径。引用的文件内容会占用上下文窗口，避免引用过大的文件（建议单个引用文件不超过 500 行）。

### 1.1.2 CLAUDE.md 的维护建议

- **保持精简**：`CLAUDE.md` 的内容会在每次会话中占用上下文窗口，内容过多会压缩 Claude 实际可用的上下文空间，降低效率。
- **持续更新**：当更换了包管理器或构建工具、添加或移除了重要的依赖库、制定了新的编码约定等更新。

- **用命令式语言**：指令越明确，Claude 遵守的概率越高。

- **规则太多**：拆分到 `.claude/rules/`目录下按需加载。

### 1.1.3 CLAUDE.local.md -- 个人本地指令

`CLAUDE.local.md` 是 `CLAUDE.md` 的个人覆盖文件，优先级高于 `CLAUDE.md`，用于存放不适合提交到 git 的个人偏好设置。

**使用场景：**

- 本地沙箱 URL、测试数据库连接
- 个人调试命令、临时实验性规则
- 本地环境特有的路径或工具配置

**配置步骤：**

1. 在项目根目录创建 `CLAUDE.local.md`
2. 将其加入 `.gitignore`，避免提交到版本库
```
# .gitignore
CLAUDE.local.md
```

### 1.1.4 CLAUDE.md 与自动记忆

Claude Code 有两个互补的记忆系统。两者都在每次对话开始时加载。Claude 将它们视为上下文，而不是强制配置。

|              | CLAUDE.md 文件             | 自动记忆                              |
| :----------- | :------------------------- | :------------------------------------ |
| **谁编写**   | 你                         | Claude                                |
| **包含内容** | 指令和规则                 | 学习和模式                            |
| **范围**     | 项目、用户或组织           | 每个工作树                            |
| **加载到**   | 每个会话                   | 每个会话（前 200 行或 25KB）          |
| **用于**     | 编码标准、工作流、项目架构 | 构建命令、调试见解、Claude 发现的偏好 |

自动记忆存储在 `.claude/memory/MEMORY.md`，由 Claude 在对话过程中自动维护，无需人工干预。

## 1.2 .claude/settings.json -- 权限与配置中心

团队共享的配置文件，控制 Claude **允许或禁止**执行哪些操作，作为团队安全基线。

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(pytest:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl * | bash)"
    ]
  }
}
```

### 1.2.1 settings.local.json -- 个人本地权限

个人本地权限覆盖，临时放开或收紧某些权限，不影响团队其他成员。

```json
{
  "permissions": {
    "allow": [
      "Bash(rm ./tmp/*)"
    ]
  }
}
```

### 1.2.2 Hooks -- 工具调用钩子

Hooks 允许在 Claude 调用工具的前后自动执行 shell 命令，适合做日志记录、格式化检查、安全拦截等自动化操作。

| 事件           | 触发时机                   | 常见用途               |
| :------------- | :------------------------- | :--------------------- |
| `PreToolUse`   | Claude 执行工具调用**之前** | 安全检查、权限拦截     |
| `PostToolUse`  | Claude 执行工具调用**之后** | 日志记录、自动格式化   |
| `Notification` | Claude 发送通知时           | 消息转发、告警集成     |

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[LOG] Bash executed' >> .claude/bash.log"
          }
        ]
      }
    ]
  }
}
```

> Hooks 配置在 `settings.json`（团队共享）或 `settings.local.json`（个人本地）中均可设置。

## 1.3 .claude/commands/ -- 自定义斜杠命令

目录下每个 `.md` 文件自动映射为一条 `/project:文件名` 命令。`.claude/commands/` 是团队将重复性任务**标准化**的核心机制。

| 文件名         | 对应命令             |
| :------------- | :------------------- |
| `review.md`    | `/project:review`    |
| `fix-issue.md` | `/project:fix-issue` |
| `deploy.md`    | `/project:deploy`    |

**传递参数：** 命令文件中使用 `$ARGUMENTS` 占位符接收调用时传入的参数。例如 `/project:fix-issue 123` 中的 `123` 会替换文件内所有 `$ARGUMENTS`。

- `commands/review.md`

```md
# Code Review
请对当前修改执行完整的代码审查：

1. 检查是否有安全漏洞（SQL 注入、XSS 等）
2. 验证错误处理是否完整
3. 确认测试覆盖率是否达标
4. 检查是否符合代码风格规范
5. 评估性能影响

用中文输出结构化审查报告，按严重程度排列问题。
```

- `commands/fix-issue.md`（带参数）

```
# Fix GitHub Issue

给定 Issue 编号 $ARGUMENTS，请：

1. 读取并理解 Issue 描述
2. 定位相关代码文件
3. 实现最小化修复方案
4. 编写对应的单元测试
5. 更新 CHANGELOG.md

调用方式：/project:fix-issue 123
```

## 1.4 .claude/rules/ -- 模块化行为规则

将 `CLAUDE.md`中的规则**拆分模块化**存放，Claude 在整个会话中始终遵守。适合存放长期稳定执行的行为约定，避免 `CLAUDE.md`过于臃肿。

- `rules/code-style.md`

```html
# Code Style Rules

- TypeScript 严格模式，禁用 any 类型
- 函数长度不超过 40 行，超出则拆分
- 优先使用 const，避免使用 let
- 导入顺序：标准库 → 三方包 → 本地模块
- 所有 export 的函数/类型需要 JSDoc 注释
- 禁止使用 console.log，使用项目 logger
```

- `rules/testing.md`

```
# Testing Rules

- 每个公开函数必须有对应的单元测试
- 测试文件与源文件同目录，命名为 `*.test.ts`
- 使用 describe / it 嵌套结构组织测试用例
- Mock 外部依赖，不允许测试直接访问数据库或网络
- 每次提交前必须通过 `npm run test` 全量测试
```

- `rules/api-conventions.md`

```
# API Conventions

- RESTful 风格，资源名使用复数形式
- 统一响应格式：{ data, error, meta }
- 错误码遵循 HTTP 标准语义
- 所有接口需要在 OpenAPI 文档中声明
- 分页参数统一使用 page / page_size
```

## 1.5 .claude/skills/ -- 自动调用的工作流

Skills 是更高级的**复合工作流**。每个 skill 是一个子目录，目录内包含 `SKILL.md`，其中定义触发条件和执行步骤。

**触发方式有两种：**

1. **自动触发**：Claude 判断当前任务符合某个 skill 的触发条件时，自动读取并执行
2. **手动触发**：通过 `Skill` 工具显式调用指定 skill

- skills/security-review/SKILL.md

```
# Security Review Skill

## 触发条件
当用户请求代码审查、代码涉及认证/授权/加密/用户输入处理时自动触发。

## 执行步骤
1. 扫描 SQL 注入风险（检查所有数据库查询）
2. 检查 XSS 防护（验证输出转义）
3. 审计权限边界（确认最小权限原则）
4. 检查敏感数据处理（日志、错误信息中是否泄露）
5. 输出 OWASP Top 10 对照检查表

## 输出格式
按 CVSS 评分排列，高危问题优先展示。
```

## 1.6 .claude/agents/ -- 子代理角色

定义可被主 Claude 实例**派遣的专业子代理**。在复杂任务中，主代理将子任务委派给对应专家角色，实现**多代理协作**。子代理在隔离上下文中运行，拥有独立的权限范围。

- agents/code-reviewer.md

```html
---
name: code-reviewer
description: 资深代码审查员，专注代码质量与可维护性
---

# 代码审查员

## 角色定位
你是一名拥有 10 年经验的资深工程师，专注于代码可读性、性能优化和最佳实践。

## 审查重点
- 命名是否清晰表达意图
- 函数/类的单一职责原则
- 边界条件和错误处理
- 性能瓶颈（N+1 查询、不必要的循环等）

## 权限
只读访问，不直接修改文件。

## 输出格式
使用 Markdown 表格输出，包含：问题位置、严重程度、建议方案。
```

- agents/security-auditor.md

```
---
name: security-auditor
description: 安全审计专家，专注漏洞扫描与合规审计
---

# 安全审计员

## 角色定位
你是一名安全工程师，熟悉 OWASP、CVE 数据库和常见攻击向量。

## 审计范围
- 认证与授权逻辑
- 输入验证与输出转义
- 依赖包已知漏洞（结合 npm audit / pip audit）
- 敏感信息泄露风险

## 权限
只读访问 + 可运行安全扫描工具。

## 输出格式
按 CVSS 3.1 评分排列，包含：漏洞描述、影响范围、修复建议、参考链接。
```

# 2 最佳实践建议

**从最小可行配置开始：**

```html
your-project/
├── CLAUDE.md        
└── .claude/
    └── settings.json
```

随着项目发展，再逐步引入：

1. `commands/` — 当你发现自己重复输入相同的指令时
2. `rules/` — 当 CLAUDE.md 超过 100 行时，拆分模块
3. `skills/` — 当有复杂的多步骤工作流需要标准化时
4. `agents/` — 当任务复杂到需要多个专业视角并行时

# 3 参考

- https://docs.anthropic.com/zh-CN/docs/claude-code/memory

- https://docs.anthropic.com/zh-CN/docs/claude-code/settings

- https://x.com/vincemask/status/2052368318825402507
