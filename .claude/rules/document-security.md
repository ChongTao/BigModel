# 文档安全检查规则

## 敏感信息检查（每次阅读/修改文档时必须执行）

每次检查本项目任意文档时，必须扫描以下敏感信息类型，发现后立即告知用户并建议脱敏处理：

| 类型 | 示例 / 特征 |
| --- | --- |
| API Key / Token | `sk-`、`Bearer `、`token:`、`auth_token` 等开头的真实字符串 |
| 密码 | `password:`、`passwd:`、`pwd:` 后跟非占位符的真实值 |
| 私钥 / 证书 | `-----BEGIN PRIVATE KEY-----`、`.pem` 内容 |
| 内网 IP / 专有域名 | 形如 `192.168.x.x`、`10.x.x.x` 或公司内网域名 |
| 个人信息 | 手机号、邮箱地址、身份证号 |
| 数据库连接串 | `mysql://user:pass@host`、`mongodb://...` 含真实凭证 |

**占位符（如 `sk-xxxx`、`your-token-here`）不属于敏感信息，无需告警。**

## 自动提交校验

提交前会通过 `.githooks/pre-commit` 调用 `scripts/check-sensitive-info.ps1 -Staged` 扫描暂存区。

- 未通过检查时，`git commit` 会被直接阻止
- 自动扫描重点覆盖真实凭证、高风险连接串和私钥块
- 内网 IP、专有域名、个人信息等仍需人工复核

## 检查记录

| 日期 | 文件 | 检查结果 |
| --- | --- | --- |
| 2026-05-16 | `99 工具/2 Claude Code/2 Claude Code常见操作.md` | ✅ 未发现敏感信息 |
| 2026-05-16 | `99 工具/2 Claude Code/1 Claude Code安装.md` | ✅ 未发现敏感信息（`sk-xxxx`、`https://your-api-proxy-url` 均为占位符） |
| 2026-05-16 | `99 工具/2 Claude Code/3 Claude Code项目结构.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/11 Claude Code项目结构.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/12 Claude Code 上下文管理.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/13 Claude Code 工作原理.md` | ✅ 未发现敏感信息 |
| 2026-05-28 | `99 工具/2 Claude Code/13 Claude Code 工作原理.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/3 Claude Code Commands.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/5 Claude Code Agent.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/6 Claude Code Skill.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/7 Claude Code Plugin.md` | ✅ 未发现敏感信息 |
| 2026-05-21 | `99 工具/2 Claude Code/15 Claude Code 日常使用.md` | ✅ 未发现敏感信息 |
| 2026-05-16 | `99 工具/2 Claude Code/4 Claude Code MCP.md` | ✅ 未发现敏感信息（Bearer/API Key 均为中文占位符） |
| 2026-05-25 | `10 其它/4 OpenClaw/3 插件开发指南.md` | ✅ 未发现敏感信息（所有 API Key 和 Token 均为占位符） |
| 2026-05-25 | `10 其它/4 OpenClaw/4 技能开发指南.md` | ✅ 未发现敏感信息（所有凭证均为占位符） |
| 2026-05-25 | `10 其它/4 OpenClaw/20 内置技能清单.md` | ✅ 未发现敏感信息（所有配置示例均为占位符） |
| 2026-06-01 | `全仓库（tracked files）` | ✅ 未发现真实敏感凭证；命中内容均为规则说明、占位符或示例文本 |
