# 11 Codex项目结构

Codex 相关配置通常分成两层：

- 用户级目录：`~/.codex/`
- 项目级目录：`.codex/` 和仓库内 `AGENTS.md`

## 11.1 用户级目录

常见内容：

```text
~/.codex/
├── config.toml
├── auth.json
├── AGENTS.md
├── agents/
├── skills/
├── plugins/
└── memories/
```

作用：

- 保存默认模型和策略
- 保存登录态或认证信息
- 保存全局规则
- 保存个人 Skills、Plugins、Subagents

## 11.2 项目级目录

常见内容：

```text
repo/
├── AGENTS.md
└── .codex/
    ├── config.toml
    └── agents/
```

作用：

- 保存项目专属规则
- 保存项目专属覆盖配置
- 保存项目专属子代理

## 11.3 配置优先级

可以粗略理解为：

1. CLI 临时参数
2. 当前项目 `.codex/config.toml`
3. profile 配置
4. 用户级 `~/.codex/config.toml`

也就是说，越靠近当前运行环境的配置，优先级越高。

## 11.4 应该把什么放在哪

放到用户级：

- 个人习惯
- 通用默认模型
- 全局 AGENTS
- 个人 Skills

放到项目级：

- 仓库规则
- 项目内专属约束
- 仓库专属 agent 配置
- 项目级 MCP / 工作流配置
