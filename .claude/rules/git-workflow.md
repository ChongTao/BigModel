# Git 提交规则

## 提交前必须通过敏感信息检查

本仓库的 Git 提交前检查由 `.githooks/pre-commit` 执行，实际校验脚本为 `scripts/check-sensitive-info.ps1`。

提交前必须满足：

- `git config core.hooksPath .githooks` 已在当前仓库生效
- 暂存区内容通过 `powershell -File scripts/check-sensitive-info.ps1 -Staged`
- 如发现真实 API Key、Bearer Token、密码、私钥块、带凭证的数据库连接串，必须先脱敏再提交

## 规则边界

自动拦截主要覆盖高风险凭证模式，目的是在保证可用性的前提下减少误报：

- 真实形态的 `sk-...` Key
- 真实形态的 `Bearer ...` Token
- `password=`、`token=`、`secret=` 一类显式赋值
- `mysql://user:pass@host`、`mongodb://...` 一类带凭证连接串
- 独立出现的私钥头

以下内容仍需人工复核：

- 内网 IP、专有域名
- 手机号、邮箱、身份证号等个人信息
- 文档中的上下文描述、截图、外链内容

## 手动执行

可在提交前手动运行：

```powershell
powershell -File scripts/check-sensitive-info.ps1 -Staged
```
