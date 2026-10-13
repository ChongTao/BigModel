# Claude Code Plugins（插件）

## 1 Plugin vs 独立配置

Claude Code 支持两种方式扩展功能：

| 维度 | 独立配置（`.claude/` 目录） | Plugin（插件包） |
| --- | --- | --- |
| Skill 名称 | `/hello` | `/plugin-name:hello` |
| 适用场景 | 个人工作流、单项目定制、快速实验 | 与团队共享、社区分发、跨项目复用 |
| 安装方式 | 手动复制文件 | `/plugin install` 一键安装 |
| 版本管理 | 无 | 支持版本号 / git commit SHA |
| 命名冲突 | 可能冲突 | 命名空间隔离，不冲突 |

> **推荐工作流**：先在 `.claude/` 中快速迭代，准备好共享时再转换为 Plugin。

### Plugin 与 Skill 的关系

**Skill** 是单个能力定义（一个 `SKILL.md` 文件）；**Plugin** 是完整的扩展包，可包含多个 Skills + Agents + Hooks + MCP 配置。Plugin 是 Skill 的超集。

## 2 Plugin 目录结构

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # 插件清单（必需）
├── skills/                # Skills 目录
│   └── <skill-name>/
│       └── SKILL.md
├── commands/              # 旧版命令目录（平面 Markdown 文件）
├── agents/                # 自定义子代理定义
├── hooks/
│   └── hooks.json         # 事件处理程序
├── .mcp.json              # MCP 服务器配置
├── .lsp.json              # LSP 服务器配置
├── monitors/
│   └── monitors.json      # 后台监视器配置
├── bin/                   # 添加到 Bash PATH 的可执行文件
└── settings.json          # 启用时的默认设置
```

> ⚠️ **常见错误**：不要将 `commands/`、`agents/`、`skills/`、`hooks/` 放在 `.claude-plugin/` 目录内。只有 `plugin.json` 应在 `.claude-plugin/` 内，其余目录在插件根级别。

## 3 快速创建 Plugin

### 3.1 创建插件目录和清单

```sh
mkdir -p my-first-plugin/.claude-plugin
```

编写 `my-first-plugin/.claude-plugin/plugin.json`：

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

清单字段说明：

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `name` | ✅ | 唯一标识符，也是 Skill 命名空间前缀（如 `/my-first-plugin:hello`） |
| `description` | ✅ | 在插件管理器中显示的描述 |
| `version` | ❌ | 版本号，设置后用户仅在更新此字段时收到更新；省略则用 git commit SHA |
| `author` | ❌ | 作者信息，用于归属 |

### 3.2 添加 Skill

```sh
mkdir -p my-first-plugin/skills/hello
```

编写 `my-first-plugin/skills/hello/SKILL.md`：

```markdown
---
description: Greet the user with a personalized message
---

Greet the user named "$ARGUMENTS" warmly and ask how you can help them today.
```

### 3.3 本地测试

```sh
# 使用 --plugin-dir 标志加载插件（开发测试专用，无需安装）
claude --plugin-dir ./my-first-plugin

# 加载多个插件
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two

# 加载 zip 包（需要 Claude Code v2.1.128+）
claude --plugin-dir ./my-plugin.zip

# 加载远程 zip（通过 URL）
claude --plugin-url https://example.com/my-plugin.zip
```

加载后测试：

```sh
# 调用 Skill（带命名空间前缀）
/my-first-plugin:hello Alex

# 查看已加载的 Skills
/help

# 修改文件后热更新（无需重启）
/reload-plugins
```

## 4 Plugin 各组件详解

### 4.1 Skills

在 `skills/<name>/SKILL.md` 中定义，格式与独立 Skill 完全相同，调用时带命名空间：

```sh
/plugin-name:skill-name
```

详细配置见 [6 Claude Code Skill.md]。

### 4.2 Agents（子代理）

在 `agents/` 目录中定义，格式与独立子代理完全相同（YAML frontmatter + Markdown 系统提示）：

```
agents/
└── code-reviewer.md
```

调用时可直接引用代理名称，无需命名空间。详细配置见 [5 Claude Code Agent.md]。

### 4.3 Hooks（钩子）

在 `hooks/hooks.json` 中定义：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix"
          }
        ]
      }
    ]
  }
}
```

### 4.4 MCP 服务器（.mcp.json）

在插件根目录放置 `.mcp.json`，格式与项目级 MCP 配置相同：

```json
{
  "mcpServers": {
    "my-tool": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "my-mcp-package"]
    }
  }
}
```

### 4.5 LSP 服务器（.lsp.json）

为 Claude 提供实时代码智能，适合支持未覆盖语言：

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

> 注意：安装插件的用户需在自己机器上安装对应语言服务器二进制文件。

### 4.6 后台监视器（monitors/monitors.json）

插件激活时自动在后台监视日志或文件，事件到达时通知 Claude：

```json
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log"
  }
]
```

### 4.7 默认设置（settings.json）

插件启用时自动应用的设置（目前支持 `agent` 和 `subagentStatusLine`）：

```json
{
  "agent": "security-reviewer"
}
```

## 5 安装和管理 Plugin

```sh
# 通过 /plugin 命令管理插件
/plugin

# 安装插件（从市场或 git 仓库）
/plugin install <marketplace-name> or <github-url>

# 列出已安装插件
/plugin list

# 删除插件
/plugin remove <plugin-name>

# 验证插件结构
claude plugin validate
```

## 6 将现有配置迁移为 Plugin

```sh
# 1. 创建插件结构
mkdir -p my-plugin/.claude-plugin
# 编写 plugin.json

# 2. 复制现有配置
cp -r .claude/commands my-plugin/
cp -r .claude/agents my-plugin/
cp -r .claude/skills my-plugin/

# 3. 迁移 hooks（从 settings.json 提取 hooks 对象）
mkdir my-plugin/hooks
# 编写 hooks/hooks.json

# 4. 测试
claude --plugin-dir ./my-plugin
```

迁移前后的对比：

| 独立配置（`.claude/`） | Plugin |
| --- | --- |
| `.claude/commands/` | `plugin-name/commands/` |
| `.claude/skills/` | `plugin-name/skills/` |
| `.claude/agents/` | `plugin-name/agents/` |
| `settings.json` 中的 hooks | `hooks/hooks.json` |
| 手动复制共享 | `/plugin install` 一键安装 |

## 7 发布和共享 Plugin

### 7.1 准备发布

1. 添加 `README.md`，包含安装和使用说明
2. 确定版本策略：显式 `version` 字段 or 依赖 git commit SHA
3. 运行 `claude plugin validate` 验证结构

### 7.2 分发方式

| 方式 | 适用场景 |
| --- | --- |
| 私有 Git 仓库 | 团队内部共享 |
| GitHub 公开仓库 | 开源社区分发 |
| 提交到社区市场 | 面向所有 Claude Code 用户 |

### 7.3 提交到社区市场

提交链接：
- Claude.ai：`claude.ai/settings/plugins/submit`
- Console：`platform.claude.com/plugins/submit`

提交前本地验证：

```sh
claude plugin validate
```

审核通过后发布至 [`anthropics/claude-plugins-community`](https://github.com/anthropics/claude-plugins-community)。

> 添加插件市场: /plugin marketplace add anthropics/claude-plugins-official

## 8 参考

- https://docs.anthropic.com/zh-CN/docs/claude-code/plugins
- https://docs.anthropic.com/zh-CN/docs/claude-code/discover-plugins
- https://waytoagi.feishu.cn/wiki/ZNURw257lix59ekldGbczPDpnfd
- https://github.com/LangGPT/awesome-claude-code/blob/main/README-CN.md
