# Git 提交规则

## 提交前必须通过敏感信息检查

本仓库的 Git 提交前检查由 `.githooks/pre-commit` 执行，实际校验脚本为 `scripts/check-sensitive-info.ps1`。

提交前必须满足：

- `git config core.hooksPath .githooks` 已在当前仓库生效
- 暂存区内容通过 `powershell -File scripts/check-sensitive-info.ps1 -Staged`
- 如发现真实敏感信息，必须先脱敏再提交

敏感信息的定义、人工复核范围和占位符例外规则，以 [document-security.md](./document-security.md) 为准。

## 自动检查边界

Git hook 的自动拦截主要覆盖高风险凭证模式，目的是在保证可用性的前提下减少误报：

- 真实形态的 `sk-...` Key
- 真实形态的 `Bearer ...` Token
- `password=`、`token=`、`secret=` 一类显式赋值
- `mysql://user:pass@host`、`mongodb://...` 一类带凭证连接串
- 独立出现的私钥头

以下内容仍需人工复核，提交前不能只依赖 hook：

- 内网 IP、专有域名
- 手机号、邮箱、身份证号等个人信息
- 文档中的上下文描述、截图、外链内容

## 手动执行

可在提交前手动运行：

```powershell
powershell -File scripts/check-sensitive-info.ps1 -Staged
```

## 规则边界

- `document-security.md` 负责定义“什么是敏感信息，以及文档处理时如何检查”
- 本文件负责定义“提交前必须经过什么 Git 检查流程”
