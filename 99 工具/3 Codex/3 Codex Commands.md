# 1 Codex Commands

Codex 有两类常见命令入口：

- CLI 命令：如 `codex`、`codex exec`
- 会话内命令：如 `/...`

## 3.1 常见 CLI 用法

### 交互式会话

```sh
codex
```

适合持续协作、边看边改、逐步验证。

### 一次性执行

```sh
codex exec "review this repository and summarize the risks"
```

适合自动化脚本、CI、单次任务。

### 登录

```sh
codex login
```

### 指定配置

```sh
codex --profile review
codex --model gpt-5.5
```

## 3.2 会话内 Slash Commands

Codex 在交互会话里支持 `/` 开头的命令，适合快速控制当前会话，例如：

- 切换模型
- 调整权限
- 总结会话
- 管理 agent 线程

具体可用命令会随着环境不同而不同，最稳妥的方式是直接在会话里输入 `/` 查看候选列表。

## 3.3 什么时候用 `exec`

`exec` 更适合：

- 批处理脚本
- 非交互自动化
- 固定流程任务
- CI 场景中的代码检查、摘要、迁移说明生成

## 3.4 什么时候用交互模式

交互模式更适合：

- 需求还在变化
- 需要逐步确认
- 需要反复查看文件和运行命令
- 需要人工审批改动

## 3.5 实用建议

- 要稳定可复用，优先把长流程沉淀进 `AGENTS.md` 或 Skill
- 要自动化，优先考虑 `codex exec`
- 要快速控制当前会话，优先用 slash commands
