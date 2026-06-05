# Repository Guidelines

## Project Structure & Module Organization
This repository is a knowledge base organized by topic, not an application codebase. Content is mainly Markdown files under numbered directories:

- `0 LLM`, `1 Agent`, `2 RAG`, `3 NLP`, `5 开源生态`
- `9 论文&博客`, `99 工具`

Root files:

- `README.md`: brief project overview and reference links.
- `CLAUDE.md`: repository-specific review rules (especially sensitive-information checks).
- `.claude/mcp/context7/.mcp.json`: local assistant tooling config.

Prefer keeping new content in the closest existing topic folder. Follow the existing numeric-prefix pattern for ordering.

## Build, Test, and Development Commands
There is no build system or runtime app in this repo. Use lightweight content-validation commands:

- `rg --files` to list tracked documentation files quickly.
- `rg -n "sk-|Bearer |token:|auth_token|password:|passwd:|pwd:|BEGIN PRIVATE KEY|mysql://|mongodb://"` to scan for potential secrets.
- `git log --oneline -n 20` to review recent change patterns.
- `git status` before committing to verify only intended files changed.

## Coding Style & Naming Conventions
Use clear, concise Markdown with consistent heading levels (`#`, `##`, `###`). Keep sections focused and actionable.

- Preserve existing language context (many files use Chinese; English is acceptable when appropriate).
- Use descriptive file names with topic-first naming; keep numeric prefixes where the folder already uses them.
- Prefer UTF-8 encoding.

## Testing Guidelines
No automated test framework is configured. Quality checks are manual:

- Preview Markdown to verify heading structure and readability.
- Verify links and examples in edited documents.
- Run the sensitive-information scan above for every document edit, per `CLAUDE.md`.

## Commit & Pull Request Guidelines
Recent commits are short, topic-based messages (for example: `RAG架构`, `skills更新`, `大模型汇总`). Match that style:

- Keep commit subjects brief and specific to one topic.
- One logical change per commit when possible.

For pull requests, include:

- What changed and why.
- Exact paths/modules touched (for example `2 RAG/` or `99 工具/2 Claude Code/`).
- Any screenshots only when visual rendering is relevant.
