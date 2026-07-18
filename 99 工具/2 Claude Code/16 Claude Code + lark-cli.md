# 1 lark-cli

`lark-cli`指的是用于和飞书/Lark开放平台相关能力交互的命令行工具。它的主要作用通常是帮助开发者通过终端更方便地完成一些操作。

- 创建或管理飞书应用
- 拉取或更新应用配置
- 本地调试
- 调用开放平台接口
- 辅助机器人、卡片、事件订阅等开发流程
- 提高脚手架初始化和部署效率

# 2 安装

## 2.1 通过npm安装

```sh
# 安装cli
npm install -g @larksuite/cli

# 安装cli skill
npx skills add https://github.com/larksuite/cli.git -y -g
```

## 2.2 首次配置 

1. 配置应用凭证

   ```sh
   lark-cli config init
   ```

   交互式引导，输出一个授权链接，在浏览器上完成配置，配置完成后验证登录状态即可。

   ```sh
   lark-cli auth status
   ```

   



# 3 常见命令-文档操作

- 创建

  ```shell
  # 基本创建（文档默认在"我的空间"根目录）
  lark-cli docs +create --title "文档标题" --markdown "## 正文内容\n\n- 要点一\n- 要点二"
  
  # 从本地 Markdown 文件创建
  lark-cli docs +create --title "技术评审" --markdown @./path/to/file.md
  
  # 创建到指定文件夹（folder-token 从飞书文件夹 URL 中获取）
  lark-cli docs +create --title "会议纪要" --folder-token fldcnXXXX --markdown @./notes.md
  
  # 创建到个人知识库
  lark-cli docs +create --title "学习笔记" --wiki-space my_library --markdown "## 笔记内容"
  
  # 创建到知识库某节点下
  lark-cli docs +create --title "API文档" --wiki-node wikcnXXXX --markdown "## 接口说明"
  
  # 创建到知识空间根目录
  lark-cli docs +create --title "概览" --wiki-space 7000000000000000000 --markdown "## 项目概览"
  ```

- 更新文档

  ```sh
  # 追加内容到文档末尾
  lark-cli docs +update --doc "文档URL或doc_id" --mode append --markdown "## 新增章节\n\n追加的内容"
  
  # 覆盖整个文档内容
  lark-cli docs +update --doc "CHkFduVLcopInbxvl0QcqKXQnRh" --mode overwrite --markdown "## 全新内容"
  
  # 替换指定标题下的内容
  lark-cli docs +update --doc "文档URL" --mode replace_range --selection-by-title "## 某章节" --markdown "替换后的内容"
  
  # 用省略号定位替换
  lark-cli docs +update --doc "文档URL" --mode replace_range --selection-with-ellipsis "开头文字...结尾文字" --markdown "新内容"
  
  # 在指定标题前插入
  lark-cli docs +update --doc "文档URL" --mode insert_before --selection-by-title "## 某章节" --markdown "插入的内容"
  
  # 在指定标题后插入
  lark-cli docs +update --doc "文档URL" --mode insert_after --selection-by-title "## 某章节" --markdown "插入的内容"
  
  # 删除指定范围
  lark-cli docs +update --doc "文档URL" --mode delete_range --selection-by-title "## 要删除的章节"
  
  # 同时更新标题
  lark-cli docs +update --doc "文档URL" --mode append --markdown "新内容" --new-title "新标题"
  
  # 从文件追加
  lark-cli docs +update --doc "文档URL" --mode append --markdown @./additional_content.md
  ```

- 读取文档

  ```sh
  # 获取文档内容（返回 Markdown）
  lark-cli docs +fetch --doc "文档URL或doc_id"
  
  # 人性化格式输出
  lark-cli docs +fetch --doc "CHkFduVLcopInbxvl0QcqKXQnRh" --format pretty
  
  # 分页获取长文档
  lark-cli docs +fetch --doc "文档URL" --offset 0 --limit 50
  ```

- 搜索文档

  ```sh
  # 按关键词搜索
  lark-cli docs +search --query "技术评审"
  
  # 表格格式输出
  lark-cli docs +search --query "周报" --format table
  
  # 带过滤条件
  lark-cli docs +search --query "项目" --filter '{"doc_types":["docx"]}'
  ```


# 4 即时通讯（IM）

## 4.1 发送消息

```Bash
# 发送文本消息到群聊（chat-id 从群聊 URL 或 API 获取）
lark-cli im +messages-send --chat-id "oc_xxx" --text "Hello, 这是一条测试消息"

# 发送 Markdown 消息
lark-cli im +messages-send --chat-id "oc_xxx" --markdown "**重要通知**\n\n- 今天下午3点开会"

# 发送消息给指定用户
lark-cli im +messages-send --user-id "ou_xxx" --text "你好"

# 发送图片
lark-cli im +messages-send --chat-id "oc_xxx" --image ./screenshot.png

# 发送文件
lark-cli im +messages-send --chat-id "oc_xxx" --file ./report.pdf
```

## 4.2 搜索消息

```Bash
lark-cli im +messages-search --query "关键词"
```

## 4.3 群聊操作

```Bash
# 创建群聊
lark-cli im +chat-create --name "项目讨论群"

# 搜索群聊
lark-cli im +chat-search --query "项目"

# 查看群聊消息
lark-cli im +chat-messages --chat-id "oc_xxx"
```

# 5 日历

```Bash
# 查看今日日程
lark-cli calendar +agenda

# 查看指定日期日程
lark-cli calendar +agenda --start "2026-04-22" --end "2026-04-23"

# 创建日程
lark-cli calendar +create --summary "项目评审会" --start "2026-04-25T14:00" --end "2026-04-25T15:00"

# 查询忙闲状态
lark-cli calendar +freebusy --start "2026-04-25" --end "2026-04-26"

# 时间建议
lark-cli calendar +suggestion --attendees "ou_xxx,ou_yyy" --duration 60
```

# 6 云空间 / 文件管理（Drive）

```Bash
# 上传文件
lark-cli drive +upload --file ./report.pdf

# 上传到指定文件夹
lark-cli drive +upload --file ./data.xlsx --folder-token fldcnXXXX

# 下载文件
lark-cli drive +download --file-token "文件token" --output ./local_file.pdf

# 创建文件夹
lark-cli drive +create-folder --name "项目资料" --folder-token fldcnXXXX

# 导出文档为 PDF/DOCX
lark-cli drive +export --file-token "文档token" --type pdf

# 删除文件（需确认）
lark-cli drive +delete --file-token "文件token" --yes
```

# 7 电子表格（Sheets）

```Bash
# 创建电子表格
lark-cli sheets +create --title "数据统计"

# 读取表格数据
lark-cli sheets +read --spreadsheet "表格URL或token"

# 写入数据
lark-cli sheets +write --spreadsheet "token" --range "A1:C3" --values '[["姓名","部门","分数"],["张三","研发",95],["李四","产品",88]]'

# 追加数据
lark-cli sheets +append --spreadsheet "token" --values '[["王五","设计",92]]'

# 查找数据
lark-cli sheets +find --spreadsheet "token" --query "张三"

# 导出表格
lark-cli sheets +export --spreadsheet "token" --type xlsx
```

# 8 任务管理（Task）

```Bash
# 创建任务
lark-cli task +create --summary "完成技术方案" --due "2026-04-30"

# 查看我的任务
lark-cli task +my-tasks

# 搜索任务
lark-cli task +search --query "技术方案"

# 完成任务
lark-cli task +complete --task-id "任务ID"

# 添加评论
lark-cli task +comment --task-id "任务ID" --content "已完成初稿"
```

# 9 知识库（Wiki）

```Bash
# 创建知识库节点（文档）
lark-cli wiki +node-create --space-id "空间ID" --title "新文档" --markdown "## 内容"

# 移动文档到知识库
lark-cli wiki +move --source "文档URL" --target-space "空间ID"
```

# 10 通讯录（Contact）

```Bash
# 搜索用户
lark-cli contact +search-user --query "张三"
```

# 11 实用技巧

## 11.1 输出格式

所有命令都支持 `--format` 参数：

```Bash
--format json      # 完整 JSON（默认）
--format pretty    # 人性化格式
--format table     # 表格
--format csv       # CSV
--format ndjson    # 换行分隔 JSON（适合管道）
```

## 11.2 Dry Run 预览

对写操作先预览，不实际执行：

```Bash
lark-cli docs +create --title "测试" --markdown "内容" --dry-run
```

## 11.3 身份切换

```Bash
# 以用户身份执行（默认）
lark-cli docs +create --as user --title "文档" --markdown "内容"

# 以机器人身份执行
lark-cli im +messages-send --as bot --chat-id "oc_xxx" --text "来自机器人的消息"
```

## 11.4 查看帮助

```Bash
# 查看所有服务
lark-cli --help

# 查看某个服务的所有命令
lark-cli docs --help
lark-cli im --help
lark-cli calendar --help

# 查看具体命令的参数
lark-cli docs +create --help

# 查看 API Schema
lark-cli schema                              # 列出所有 API
lark-cli schema calendar.events.instance_view  # 查看具体 API 的参数结构
```

## 11.5 认证管理

```Bash
lark-cli auth status    # 查看登录状态
lark-cli auth login     # 重新登录
lark-cli auth logout    # 登出
lark-cli auth scopes    # 查看所有可用权限
lark-cli auth check     # 校验指定权限
lark-cli auth list      # 列出所有已认证用户
```

# 12 Claude Code + lark-cli 使用建议

## 12.1 推荐协作流程

1. 先让 Claude Code 生成或整理本地 Markdown（如 `./output/weekly.md`）。
2. 用 `lark-cli docs +create` 或 `docs +update` 发布到飞书文档。
3. 用 `lark-cli im +messages-send` 把文档链接通知到群聊。
4. 需要跟踪时，再用 `task`/`calendar` 补齐后续动作。

这样可以把“内容生成”和“平台写入”解耦：Claude Code 专注内容质量，`lark-cli` 专注稳定落库与分发。

## 12.2 高价值实践建议

- 写操作默认先加 `--dry-run`，确认目标对象、范围和参数无误后再执行。
- 更新文档优先使用 `append`、`insert_before/after`、`replace_range`，减少 `overwrite` 带来的整文覆盖风险。
- 在执行覆盖更新前，先 `docs +fetch` 备份当前版本到本地文件。
- 优先使用 `--selection-by-title` 做局部更新，章节标题保持稳定可显著提升自动化成功率。
- 认证建议区分身份：人工操作用 `--as user`，自动通知/定时任务用 `--as bot`。
- 权限按最小化原则申请，定期用 `lark-cli auth scopes` 和 `auth check` 做权限审计。
- 避免在命令中硬编码 token、chat-id、space-id，统一放在环境变量或配置文件中管理。
- 在流水线中固定 `--format json`，便于后续程序解析和错误重试。

## 12.3 建议的目录与命名

```text
project/
  reports/
    2026-05-26-weekly.md
  scripts/
    publish-weekly.ps1
```

- 文档文件名建议带日期，便于回溯。
- 脚本名体现动作（如 `publish-*`），方便团队复用。

## 12.4 自动发布示例（PowerShell）

```powershell
# 1) 由 Claude Code 生成 reports/2026-05-26-weekly.md
# 2) 发布到飞书并发送通知

$doc = lark-cli docs +create `
  --title "研发周报 2026-05-26" `
  --folder-token $env:LARK_FOLDER_TOKEN `
  --markdown @./reports/2026-05-26-weekly.md `
  --format json

# 这里建议解析 $doc 中返回的 URL 或 token，再拼接通知消息
lark-cli im +messages-send `
  --as bot `
  --chat-id $env:LARK_CHAT_ID `
  --markdown "**周报已发布**`n请查看最新版本。"
```

## 12.5 适合交给 Claude Code 的任务

- 将会议纪要整理成统一模板并输出为 Markdown。
- 基于任务进展自动生成周报/日报草稿。
- 按固定章节（进展、风险、计划）重写已有文档。
- 生成可直接执行的 `lark-cli` 命令草案，并附参数解释。

# 13 Feishu-Claude-Code-Bridge（飞书集成）

## 13.1 项目简介

**Lark-Channel-Bridge** 是一个轻量级集成工具，直接将飞书消息与本地 Claude Code CLI 连接，让用户无需离开飞书即可与Claude进行实时交互。

项目地址：https://github.com/zarazhangrui/feishu-claude-code-bridge

## 13.2 核心功能

| 功能 | 说明 |
|------|------|
| **飞书对话** | 在飞书内直接与Claude聊天，无需切换应用 |
| **实时展示** | Claude的文本回复和工具调用结果实时出现在同一张卡片上 |
| **文件处理** | 支持直接上传图片和文件供Claude分析处理 |
| **会话隔离** | 每个聊天保持独立session，互不影响 |
| **智能调度** | 新消息可中断旧任务；快速连发消息自动合并处理 |
| **多工作空间** | 支持在不同团队/工作空间间切换 |

## 13.3 技术要求

- **Node.js 20+**
- **Claude CLI** 已登录
- **飞书PersonalAgent应用** 已配置

## 13.4 部署方式

### 前台运行
```bash
lark-channel-bridge run
```

> 长期后台运行 tmux attach -t lark-bridge，退出用 Ctrl+B D

### 后台守护进程

支持 macOS、Linux 和 Windows，自动恢复崩溃：
```bash
# 启动守护进程
lark-channel-bridge daemon start

# 停止守护进程
lark-channel-bridge daemon stop

# 查看状态
lark-channel-bridge daemon status
```

## 13.5 访问控制

支持可选的权限管理，满足个人到团队协作的不同场景：

- **用户白名单**：限制只有指定用户可使用
- **群白名单**：限制只有指定群聊可使用
- **管理员限制**：只允许管理员执行特定操作

配置示例：
```bash
lark-channel-bridge run --user-whitelist "user_id1,user_id2"
lark-channel-bridge run --chat-whitelist "chat_id1,chat_id2"
```

## 13.6 应用场景

| 场景 | 优势 |
|------|------|
| **团队代码讨论** | 在群里实时与Claude讨论代码，分享截图或文件 |
| **文档快速处理** | 上传文件让Claude分析、整理、翻译或总结 |
| **问题即时解答** | 无需切应用，在飞书里即时提问获得AI辅助 |
| **工作流集成** | 结合`lark-cli`实现文档生成→发布→通知的自动化流程 |

## 13.7 与 lark-cli 的配合

**推荐流程**：
1. 在飞书群里与Claude讨论并生成草案
2. Claude 在本地生成或整理 Markdown 文件
3. 使用 `lark-cli docs +create` 发布到飞书文档
4. 使用 `lark-cli im +messages-send` 在群里分享链接
5. 必要时用 `task`/`calendar` 跟踪后续动作

这样可以将"**实时交互**"（飞书Bridge）和"**结构化发布**"（lark-cli）分离，各司其职。
