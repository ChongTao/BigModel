# 1 Understand-Anything

Understand-Anything 是一个面向 AI 编码工具的项目理解插件，可以把代码库、知识库或文档转换成可搜索、可探索、可对话的交互式知识图谱。它支持 Claude Code、Codex、Cursor、Copilot、Gemini CLI 等多平台，核心目标不是单纯“画图”，而是帮助你更快理解系统结构、业务流程和变更影响（**不建议使用，太耗Token**）。 

## 1.1 核心能力

- 将代码库解析成知识图谱，节点可对应文件、函数、类及其依赖关系
- 提供交互式 Dashboard，用图形化方式查看系统结构
- 支持自然语言提问，直接围绕代码库做问答
- 支持差异影响分析，帮助判断当前改动会波及哪些模块
- 支持生成 onboarding 学习路径，方便新人理解项目
- 支持分析 Karpathy 风格的 Wiki / 知识库

## 1.2 适用场景

- 接手陌生项目时快速建立全局认知
- 梳理复杂系统中的依赖关系和业务域
- 在提交改动前评估影响范围
- 为团队成员生成项目导览和学习路径
- 将知识库整理成可导航的知识图谱

# 2 安装

## 2.1 在 Claude Code 中安装

Claude Code 的原生安装方式是：

```bash
/plugin marketplace add Lum1104/Understand-Anything
/plugin install understand-anything
```

安装完成后，插件就可以在当前环境中直接使用。 

## 2.2 其他平台安装

Understand-Anything 也支持 Codex、OpenCode、OpenClaw、Gemini CLI、Copilot、Cline 等平台。上游项目提供了一键安装脚本：

macOS / Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash
```

如果想直接指定平台（例如 Codex）：

```bash
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash -s codex
```

Windows PowerShell：

```powershell
iwr -useb https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.ps1 | iex
```

根据上游说明，安装脚本会把仓库克隆到 `~/.understand-anything/repo`，并为所选平台建立对应链接。安装后通常需要重启 CLI 或 IDE。 

# 3 使用

## 3.1 首次分析代码库

最核心的命令是：

```bash
/understand
```

执行后，插件会通过多智能体流程扫描项目、提取函数 / 类 / 依赖关系，并生成知识图谱文件：

```text
.understand-anything/knowledge-graph.json
```

如果希望输出中文描述，可以加语言参数：

```bash
/understand --language zh
```

上游文档说明，`--language` 会影响知识图谱中的节点摘要、Dashboard UI 文案以及导览路线说明。支持的语言包括 `en`、`zh`、`zh-TW`、`ja`、`ko`、`ru`。 

## 3.2 打开交互式 Dashboard

```bash
/understand-dashboard
```

这个命令会打开交互式网页数据看板，你可以通过搜索、点击节点和颜色分层来查看代码结构、关系和解释。 

## 3.3 常用命令

```bash
# 询问整个代码库
/understand-chat How does the payment flow work?

# 分析当前改动的影响范围
/understand-diff

# 深入解释某个文件
/understand-explain src/auth/login.ts

# 生成项目 onboarding 指南
/understand-onboard

# 提取业务领域、流程和步骤
/understand-domain

# 分析 Karpathy 风格的知识库 / Wiki
/understand-knowledge ~/path/to/wiki
```

## 3.4 推荐使用流程

一个比较实用的流程是：

1. 先执行 `/understand` 建立代码库知识图谱。
2. 再用 `/understand-dashboard` 从全局查看结构和依赖。
3. 针对具体问题使用 `/understand-chat` 提问。
4. 针对重点文件使用 `/understand-explain` 深挖实现。
5. 提交前用 `/understand-diff` 看改动影响范围。

这样更适合先建立全局认知，再逐步下钻到局部模块。 

# 4 补充说明

- 如果项目较大，首次分析可能会比普通命令更耗时
- 该类插件更适合中大型项目、遗留系统和知识库整理场景
- 使用前最好确认当前 CLI / 插件平台已经正确安装并重启

# 5 参考资料

- 上游中文文档：`Lum1104/Understand-Anything` 的 `READMEs/README.zh-CN.md`
