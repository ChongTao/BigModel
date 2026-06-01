Codex有三种形态使用，客户端，命令行，插件。

Windows安装Codex 

```sh
# 安装命令：
npm install -g @openai/codex
# 如果因网络问题无法安装，输入以下指令：
npm install -g @openai/codex --registry=https://registry.npmmirror.com
```

VSCode安装 codex





 ~/.codex/ 全局配置这里通常放个人默认配置、认证相关文件、全局规则或运行状态。它影响的是当前用户使用 Codex 的默认行为

项目级别配置



codex核心配置文件：

- config.toml: 主配置文件，包括模型、权限、沙箱、全局参数等

- auth.json: 认证信息，登录凭证、API秘钥、身份验证凭据
- instructions.md: 全局指令，**每次对话自动加载 / 行为规则 / 系统提示词模板**
- .env: 环境变量



config.toml可以理解成 Codex 的行为说明书。

它会影响 Codex 使用哪个模型、默认采用什么行为、是否接入 MCP、如何处理权限、项目里哪些规则文件会被读取等。



/init 初始化项目生成AGENT.md

AGENTS.md 是写给 Codex 的规则

