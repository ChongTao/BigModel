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
   ```

3. 写入配置文件

   需要写入两份配置文件。Windows 对应路径为 `%USERPROFILE%\.claude\settings.json` 和 `%USERPROFILE%\.claude.json`。

   - `~/.claude/settings.json` — 令牌与模型配置

     ```json
     {
       "env": {
         "ANTHROPIC_DEFAULT_HAIKU_MODEL": "anthropic/claude-haiku-4-5-20251001",
         "ANTHROPIC_DEFAULT_OPUS_MODEL": "anthropic/claude-opus-4-7",
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
