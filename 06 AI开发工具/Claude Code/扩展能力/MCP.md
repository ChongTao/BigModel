# 1 Claude Code MCP

## 1.1 基本使用

Claude Code 内置了完整的 MCP 管理能力，核心命令只有一个：

```sh
claude mcp
```

常用子命令:

| 命令                       | 作用                             |
| :------------------------- | :------------------------------- |
| `claude mcp add`           | 添加一个 MCP 服务器              |
| `claude mcp list`          | 查看所有已配置服务器             |
| `claude mcp get <name>`    | 查看某个服务器详情               |
| `claude mcp remove <name>` | 删除服务器                       |
| `/mcp`                     | 在 Claude Code 中查看状态 / 认证 |

## 1.2 安装 MCP 服务器

MCP 服务器支持 HTTP/SSE/stdio 三种接入方式，推荐优先使用 HTTP（SSE transport 已弃用）。

1. 远程 HTTP 服务器（推荐）

   ```sh
   # 基础语法
   claude mcp add --transport http <服务器名称> <服务器URL>
   
   # 示例1：连接Notion
   claude mcp add --transport http notion https://mcp.notion.com/mcp
   
   # 示例2：带身份验证的HTTP服务器
   claude mcp add --transport http secure-api https://api.example.com/mcp \
     --header "Authorization: Bearer 你的令牌"
   ```

2. 本地 stdio 服务器

   适用于需要本地系统访问的工具（如本地数据库、自定义脚本）：

   ```sh
   # 基础语法（注意：--前是Claude参数，--后是服务器命令）
   claude mcp add --transport stdio [--env 环境变量] <服务器名称> -- <启动命令>
   
   # 示例：连接Airtable（需替换自己的API密钥）
   claude mcp add --transport stdio --env AIRTABLE_API_KEY=你的密钥 airtable \
     -- npx -y airtable-mcp-server
   ```

   > 关键注意：`--transport`/`--env` 等参数必须放在 `--` 分隔符**前面**，`--` 用于分隔 Claude 参数和服务器命令，避免参数冲突。

## 1.3 管理 MCP 服务器

配置完成后，你可以通过以下命令管理服务器：

```sh
# 列出所有已配置的服务器
claude mcp list

# 查看指定服务器详情（如github）
claude mcp get github

# 删除指定服务器
claude mcp remove github

# 在Claude Code中检查服务器状态
/mcp
```

## 1.4 配置范围（控制服务器可见性）

你可以指定 MCP 服务器的生效范围，适配个人/团队使用场景：

| 范围          | 用途                                      | 配置命令示例                         |
| :------------ | :---------------------------------------- | :----------------------------------- |
| local（默认） | 仅当前项目可用，私密配置（如敏感密钥）    | `claude mcp add --scope local ...`   |
| project       | 团队共享（存储在.mcp.json，可提交版本库） | `claude mcp add --scope project ...` |
| user          | 所有项目可用（个人全局配置）              | `claude mcp add --scope user ...`    |



## 1.5 开源MCP服务器

- Brave Search：网页搜索，支持联网检索实时信息。
- Context7：技术文档查询，可获取最新库的 API 文档和示例代码。
