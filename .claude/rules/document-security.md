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
