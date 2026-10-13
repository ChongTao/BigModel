# 16 Codex 配置与认证

Codex 的稳定性，除了模型本身，很大一部分来自：

- 登录方式
- `config.toml`
- 项目级 `.codex/config.toml`
- profile 配置

## 16.1 常见登录方式

常见有两种：

- ChatGPT 账号登录
- OpenAI API Key 登录

如果是 CLI 或 IDE，本地都可以使用这两类方式；如果是 Codex Cloud，则通常依赖 ChatGPT 登录。

## 16.2 关键配置文件

用户级主配置：

```text
~/.codex/config.toml
```

项目级覆盖：

```text
.codex/config.toml
```

profile 文件：

```text
~/.codex/<profile>.config.toml
```

## 16.3 config.toml 一般管什么

常见会放这些内容：

- 默认模型
- 沙箱和审批策略
- MCP 配置
- profile 行为差异
- agent 相关设置

可以把它理解成 Codex 的“行为总开关”。

## 16.4 配置优先级

粗略理解优先级：

1. CLI 临时参数
2. 项目级 `.codex/config.toml`
3. profile 配置
4. 用户级 `~/.codex/config.toml`

也就是说，越接近当前运行环境的配置，优先级越高。

## 16.5 实用建议

- 稳定个人偏好放用户级
- 仓库专属要求放项目级
- 不同工作模式用 profile 切换
- 一次性实验尽量用 CLI 参数覆盖，不要马上改全局配置
