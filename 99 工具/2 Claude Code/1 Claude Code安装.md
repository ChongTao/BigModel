# 1 Claude Code

Claude Code 是 Anthropic 推出的、面向开发者的 **AI 编程助手形态**，核心目标是让 Claude 直接参与软件开发流程，而不仅仅是回答代码问题。Claude Code 的核心理念：协作，而不是替代。

它可以读取你的代码库、编辑文件、运行命令，并与你的开发工具集成。可在终端、IDE、桌面应用和浏览器中使用。

# 2 安装Claude Code

## 2.1 npm方式安装

1. 安装Node.js(>=18)

   访问 [nodejs.org](https://nodejs.org/) 下载 LTS 版本；已安装请跳过。

2. 通过npm安装Claude Code

   ```sh
   npm install -g @anthropic-ai/claude-code
   
   // 更新
   npm update -g @anthropic-ai/claude-code
   ```

3. 写入配置文件

   需要写入两份配置文件。Windows 对应路径为 `%USERPROFILE%\.claude\settings.json` 和 `%USERPROFILE%\.claude.json`。

   - `~/.claude/settings.json` — 令牌与模型配置

     ```json
     {
       "env": {
         "ANTHROPIC_DEFAULT_HAIKU_MODEL": "anthropic/claude-haiku-4-5-20251001",
         "ANTHROPIC_DEFAULT_OPUS_MODEL": "anthropic/claude-opus-4-6",
         "ANTHROPIC_AUTH_TOKEN": "sk-xxxx",
         "ANTHROPIC_BASE_URL": "https://your-api-proxy-url",
         "ANTHROPIC_MODEL": "anthropic/claude-sonnet-4-6",
         "ANTHROPIC_DEFAULT_SONNET_MODEL": "anthropic/claude-sonnet-4-6",
         "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1,
         "API_TIMEOUT_MS": "3000000"
       },
       "includeCoAuthoredBy": false
     }
     ```

   - `~/.claude.json` — 跳过首次引导

     ```json
     {
       "hasCompletedOnboarding": true
     }
     ```

   > 上述的配置文件 `~/.claude/settings.json` 配置账号信息和登录效果一样

4. 启动Claude Code

   在终端执行 `claude` 即可启动。首次启动会读取上面写入的 settings.json。

5. 安装 Claude Code IDE 插件

   安装 Anthropic 官方 Claude Code IDE 插件后，可直接在编辑器内唤起 Claude Code，自动复用上面写入的 `~/.claude/settings.json` 配置，无需再单独填写 Key。

   VSCode中执行命令`code --install-extension anthropic.claude-code`

   完成以上步骤后，在 IDE 终端或 Claude Code 插件中即可直接唤起 Claude Code，使用平台令牌与模型进行对话与编码协作：

## 2.2 脚本安装

```sh
# Windows CMD 安装命令：
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd

# Windows PowerShell:
irm https://claude.ai/install.ps1 | iex

# Linux 安装命令
curl -fsSL https://claude.ai/install.sh | bash
```

安装成功后执行命令`claude --version`，查看版本号（Windows安装需要手动配置环境变量）。

## 2.3 插件方式安装 

打开 VS Code，进入扩展市场，搜索 **Claude Code** 安装，安装完成后，点击右上角 Claude Code 图标，即可进入 Claude Code 页面：

![](https://www.runoob.com/wp-content/uploads/2026/01/5c78e2a4-f9f4-4e38-91fa-d09ae892b9a4.png)

**超实用小技巧**：

- **选中代码时**：直接在编辑器里选中一段代码，Claude 会自动看到你选中的部分。提示框下方会显示"已选中 XX 行"。
- **快速插入**：按 **Option + K**（Mac）或 **Alt + K**（Windows/Linux），就能插入带文件路径和行号的 @ 提及，例如 `@app.ts#5-10`。
- **隐藏选中内容**：点击提示框底部的"选择指示器"（眼睛图标），斜杠眼睛表示 Claude 看不到你选中的文本。
- **拖拽附件**：把文件拖到提示框时按住 **Shift**，可以作为附件添加。
  想删除附件？点击附件右上角的 × 即可。

# 3 Claude Code 配置文件

## 3.1 重要配置

- **CLAUDE.md**：每次对话加载的持久上下文，约定成俗的规则。
- **Skill**：可以使用的说明、知识和工作流，如可重用内容、参考文档、可重复的任务。
- **Subagent**：返回摘要结果的隔离执行上下文，如需要上下文隔离、并行任务执行时。
- **MCP**：连接到外部服务，对外部数据进行操作，如查询数据库等。
- **Hook**：由事件触发的脚本、HTTP 请求、提示或 subagent。
- **Plugins**：将 skills、hooks、subagents 和 MCP servers 捆绑到单个可安装单元中。

### 3.1.1 Skill vs Subagent

**Skills** 和 **subagents** 解决不同的问题：

- **Skills** 是可重用的内容，将其加载到任何上下文中。
- **Subagents** 是与主对话分开运行的隔离工作者。

| 方面           | Skill                      | Subagent                                   |
| :------------- | :------------------------- | :----------------------------------------- |
| **它是什么**   | 可重用的说明、知识或工作流 | 具有自己上下文的隔离工作者                 |
| **关键优势**   | 在上下文之间共享内容       | 上下文隔离。工作单独进行，仅返回摘要       |
| **上下文窗口** | 添加到您的主窗口           | 使用具有自己输入和输出令牌的单独窗口       |
| **最适合**     | 参考材料、可调用的工作流   | 读取许多文件的任务、并行工作、专门的工作者 |

### 3.1.2 CLAUDE.md vs Skill

| 方面               | CLAUDE.md             | Skill                    |
| :----------------- | :-------------------- | :----------------------- |
| **加载**           | 每个会话，自动        | 按需                     |
| **可以包含文件**   | 是，使用 `@path` 导入 | 是，使用 `@path` 导入    |
| **可以触发工作流** | 否                    | 是，使用 `/<name>`       |
| **最适合**         | ”始终执行 X” 规则     | 参考材料、可调用的工作流 |

**如果 Claude 应该始终知道它，请将其放在 CLAUDE.md 中**：编码约定、构建命令、项目结构、“永远不要执行 X” 规则。

**如果它是 Claude 有时需要的参考材料（API 文档、风格指南）或您使用 `/<name>` 触发的工作流（部署、审查、发布），请将其放在 skill 中**。

### 3.1.3 CLAUDE.md vs Rules VS Skills

| 方面       | CLAUDE.md          | `.claude/rules/`               | Skill                    |
| :--------- | :----------------- | :----------------------------- | :----------------------- |
| **加载**   | 每个会话           | 每个会话，或当打开匹配的文件时 | 按需，当调用或相关时     |
| **范围**   | 整个项目           | 可以限定到文件路径             | 特定于任务               |
| **最适合** | 核心约定和构建命令 | 特定于语言或目录的指南         | 参考材料、可重复的工作流 |

**对于每个会话需要的说明，使用 CLAUDE.md**：构建命令、测试约定、项目架构。

**使用 rules 来保持 CLAUDE.md 专注。** 带有 [`paths` frontmatter](https://code.claude.com/docs/zh-CN/memory#path-specific-rules) 的 rules 仅在 Claude 处理匹配文件时加载，节省上下文。

**对于 Claude 有时只需要的内容，使用 skills**，如 API 文档或您使用 `/<name>` 触发的部署清单。

### 3.1.4 Subagent vs Agent team

- **Subagents** 在您的会话内运行并将结果报告回您的主上下文。
- **Agent teams** 是相互通信的独立 Claude Code 会话。

| 方面         | Subagent                           | Agent team                             |
| :----------- | :--------------------------------- | :------------------------------------- |
| **上下文**   | 自己的上下文窗口；结果返回给调用者 | 自己的上下文窗口；完全独立             |
| **通信**     | 仅向主代理报告结果                 | 队友直接相互发送消息                   |
| **协调**     | 主代理管理所有工作                 | 具有自我协调的共享任务列表             |
| **最适合**   | 仅结果重要的专注任务               | 需要讨论和协作的复杂工作               |
| **令牌成本** | 较低：结果摘要返回到主上下文       | 较高：每个队友是一个单独的 Claude 实例 |

**当您需要一个快速、专注的工作者时，使用 subagent**：研究一个问题、验证一个声明、审查一个文件。Subagent 完成工作并返回摘要。您的主对话保持清洁。

**当队友需要共享发现、相互质疑和独立协调时，使用 agent team**。Agent teams 最适合具有竞争假设的研究、并行代码审查以及每个队友拥有单独部分的新功能开发。

### 3.1.5 MCP vs Skill

| 方面         | MCP                                | Skill                                  |
| :----------- | :--------------------------------- | :------------------------------------- |
| **它是什么** | 连接到外部服务的协议               | 知识、工作流和参考材料                 |
| **提供**     | 工具和数据访问                     | 知识、工作流、参考材料                 |
| **示例**     | Slack 集成、数据库查询、浏览器控制 | 代码审查清单、部署工作流、API 风格指南 |

**MCP** 给予 Claude 与外部系统交互的能力。没有 MCP，Claude 无法查询您的数据库或发布到 Slack。

**Skills** 给予 Claude 关于如何有效使用这些工具的知识，以及您可以使用 `/<name>` 触发的工作流。Skill 可能包括您团队的数据库架构和查询模式，或带有您团队消息格式规则的 `/post-to-slack` 工作流。

### 3.1.6 Hook vs Skill

Hook 在生命周期事件上触发；skill 被加载到上下文中供 Claude 应用。

| 方面           | Hook                                                         | Skill                                              |
| :------------- | :----------------------------------------------------------- | :------------------------------------------------- |
| **运行**       | Shell 命令、HTTP 请求、LLM 提示或 subagent                   | Claude 读取和遵循的说明                            |
| **由以下触发** | [生命周期事件](https://code.claude.com/docs/zh-CN/hooks#hook-events)，如 `PostToolUse` 或 `SessionStart` | 您输入 `/<name>`，或 Claude 将描述与您的任务相匹配 |
| **确定性**     | 总是在其事件上触发；触发器是有保证的                         | Claude 解释说明；结果可能会有所不同                |
| **上下文成本** | 零，除非 hook 返回输出                                       | 描述在每个会话加载；使用时加载完整内容             |
| **最适合**     | 每次都以相同方式运行且不需要 Claude 思考的操作               | 需要推理的工作流、参考材料、多步骤任务             |

**当操作必须每次都以相同方式发生且不需要 Claude 思考时，使用 hook**。例如：保存时格式化、拒绝 `rm -rf /`、在会话结束时发布 Slack 消息。

**当 Claude 应该决定如何应用步骤或内容是知识而不是脚本时，使用 skill**。例如：`/release` 清单、您的 API 风格指南、调试剧本。

## 3.2 配置加载

- **CLAUDE.md**：会话开始时将CLAUDE.md 文件的完整内容加载到上下文。
- **SKills**：取决于 skill 的配置。默认情况下，描述在会话开始时加载，完整内容在使用时加载。 对于模型可调用的 skills，Claude 在每个请求中看到名称和描述。当您使用 `/<name>` 调用 skill 或 Claude 自动加载它时，完整内容加载到您的对话中。
- **MCP 服务器**：会话开始时加载。
- **Hooks**：Hooks 在特定的生命周期事件上触发，如工具执行、会话边界、提示提交、权限请求和压缩。

# 4 参考资料

- https://code.claude.com/docs/zh-CN/features-overview#skill-vs-subagent
