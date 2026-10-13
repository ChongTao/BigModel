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
