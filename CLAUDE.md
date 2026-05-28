# BigModel 项目规范

## 规则管理

本项目规则采用 **按需加载** 模式，详见 [.claude/rules/README.md](.claude/rules/README.md)

### 文档安全检查规则

📋 详见 [.claude/rules/document-security.md](.claude/rules/document-security.md)

**要点**：阅读或修改任何项目文档时，必须扫描以下敏感信息类型：

- **API Key / Token** - `sk-`、`Bearer ` 等开头的真实字符串
- **密码** - 后跟非占位符的真实值
- **私钥 / 证书** - `-----BEGIN PRIVATE KEY-----` 等
- **内网 IP / 专有域名** - `192.168.x.x`、`10.x.x.x` 等
- **个人信息** - 手机号、邮箱、身份证号
- **数据库连接串** - 含真实凭证的连接字符串

⚠️ **占位符不属于敏感信息**（如 `sk-xxxx`、`your-token-here`），无需告警。
