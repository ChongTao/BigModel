# Repository Guidelines

## Project Structure & Module Organization

This repository is a knowledge base organized by topic, not an application codebase. Topic content is mainly Markdown under these directories:

- `01 大模型基础`, `02 检索与RAG`, `03 Agent与Harness`
- `04 推理与部署`, `05 生产工程`, `06 AI开发工具`, `07 论文与阅读笔记`

Root files:

- `README.md`: project overview, learning paths, and topic map.
- `CLAUDE.md`: repository-specific review rules, especially sensitive-information checks.
- `.claude/mcp/context7/.mcp.json`: local assistant tooling config.

Each topic directory has a `README.md` index. Put new content in the closest topic directory. Use two-digit prefixes for ordered topics and learning sequences; leave prefixes off standalone reference notes.

## 使用 AGENTS.md

`AGENTS.md` 是仓库内 Agent 协作时应优先遵守的权威约束文件。它的价值不在于解释系统架构，而在于提供可直接执行的工作策略：明确如何构建、测试、提交，以及处理本仓库内容时必须遵守的限制。

- 保持简短、具体、可操作；优先写清命令、版本限制、文件约定和完成条件。
- 仅记录 Agent 无法可靠地从仓库本身推断出的信息；不要重复目录中已有的说明、代码或文档内容。
- 避免写成面向读者的架构概览或泛化建议；模糊的“尽可能”“全面覆盖”等表述不如明确的验收条件有效。
- 由熟悉仓库的人维护，并随工作流和约束变化更新；不要让 LLM 自动生成整份文件，以免引入重复、过期或不准确的规则。

## Build, Test, and Development Commands

There is no build system or runtime app in this repo. Use lightweight content-validation commands:

- `rg --files` to list documentation files quickly.
- `rg -n "sk-|Bearer |token:|auth_token|password:|passwd:|pwd:|BEGIN PRIVATE KEY|mysql://|mongodb://"` to scan for potential secrets.
- `git log --oneline -n 20` to review recent change patterns.
- `git status` before committing to verify only intended files changed.

## Coding Style & Naming Conventions

Use clear, concise Markdown with consistent heading levels (`#`, `##`, `###`). Keep sections focused and actionable.

- Preserve the existing language context; many files use Chinese, and English is acceptable when appropriate.
- Use descriptive file names with topic-first naming. Keep project names in their official spelling and place implementation notes under the matching knowledge domain.
- Use two-digit prefixes only when they express a deliberate reading order.
- Prefer UTF-8 encoding.

## Testing Guidelines

No automated test framework is configured. Quality checks are manual:

- Preview Markdown to verify heading structure and readability.
- Verify links and examples in edited documents.
- Run the sensitive-information scan above for every document edit, per `CLAUDE.md`.

## Commit & Pull Request Guidelines

Agents never commit or push on their own initiative:

- Do not run `git commit`, `git push`, `git tag`, or create/switch/delete branches unless the user explicitly asks in the current conversation.
- Do not rewrite history (`git reset`, `git rebase`, `git commit --amend`, `git cherry-pick`) unless fixing a commit the agent just created, and state the reason first.
- When asked to commit, stage only the files the user named. Run `git status` before `git add` so unrelated staged changes are not swept in, and verify `git show --stat HEAD` afterwards.
- A request to commit is not a request to push; `git push` needs separate approval.
- Read-only commands (`git status`, `git log`, `git diff`, `git show`, `git blame`) are always allowed.
- When a commit seems warranted, propose the scope and message in the reply instead of executing it.

Recent commits are short, topic-based messages (for example: `RAG架构`, `skills更新`, `大模型汇总`). Match that style:

- Keep commit subjects brief and specific to one topic.
- One logical change per commit when possible.

For pull requests, include:

- What changed and why.
- Exact paths/modules touched (for example `02 检索与RAG/` or `06 AI开发工具/Claude Code/`).
- Screenshots only when visual rendering is relevant.
