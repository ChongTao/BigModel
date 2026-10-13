# 5 Codex AGENTS

`AGENTS.md` 是写给 Codex 的长期规则文件。

它解决的问题不是“这次怎么提示”，而是：

> 让 Codex 每次进入这个项目时，默认就知道团队规则、工程约束和输出习惯。



## AGENTS.md

AGENTS.md 是项目级的 Agent 指令文件，定义 Codex 在该项目中的行为规范。

### 文件发现顺序

1. 读取全局 `~/.codex/AGENTS.md`
2. 从项目根目录向下搜索每个目录
3. 更近目录的规则覆盖更远的

```markdown
# 项目开发规范

## 技术栈
- 前端：React + TypeScript
- 后端：Python FastAPI
- 数据库：PostgreSQL

## 代码规范
- 使用 4 空格缩进
- 每行最多 100 字符
- 所有函数必须有类型注解

## 测试要求
- 新功能必须包含测试
- 使用 pytest 运行测试

## Git 提交
- 使用 Conventional Commits 格式
- 提交信息描述"为什么"

## Review guidelines
- Don't log PII
- Verify authentication middleware
- Check for SQL injection
```





## 5.1 AGENTS.md 的作用

典型用途包括：

- 规定代码风格
- 规定 review 关注点
- 规定测试与验证要求
- 规定哪些文件能改、哪些不能动
- 规定提交和输出格式

## 5.2 常见层次

Codex 会把规则分层读取。可以把它理解成：

- 用户级 `~/.codex/AGENTS.md`
- 临时覆盖 `~/.codex/AGENTS.override.md`
- 仓库级 `AGENTS.md`
- 子目录内更细粒度的 `AGENTS.md`

越靠近当前工作目录的规则，通常越具体。

## 5.3 适合写什么

适合写入 `AGENTS.md` 的内容：

- 长期稳定规则
- 工程约束
- 目录分工
- 测试要求
- 提交规范
- 特定仓库的工作方式

不适合写进去的内容：

- 一次性任务说明
- 临时实验内容
- 个人短期偏好

## 5.4 一个实用模板

```md
# 项目规则

- 修改前先阅读相关模块
- 优先做最小改动
- 变更后必须运行最小验证
- 不要改无关文件
- 输出先给结论，再给细节
```

## 5.5 使用建议

- 把高频纠正沉淀进 `AGENTS.md`
- 把目录级差异写到更近的子目录
- 规则尽量短、稳、可执行
- 不要把它写成大而空的宣言
