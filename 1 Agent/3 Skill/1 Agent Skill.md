# 1 Agent Skill介绍

Agent Skill是 Anthropic为其旗下 Claude 系列模型推出的模块化能力扩展机制，核心是将完成特定任务所需的指令、脚本、资源等打包成含 SKILL.md 文件的目录，供智能体动态发现和加载，以此让通用模型获得专业领域能力，且具备可复用、可组合的特性，更多详细见：[Skill](https://claude.com/blog/skills)。

# 2 Agent Skill的结构

Claude 官方的 PDF 操作 Skill，具体构成如下：

| 文件或文件夹                          | 作用                                                         | 示例内容                                                     |
| ------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| SKILL.md                              | 核心文件，包含元数据和详细指令，元数据（技能名称、描述）启动时加载，正文触发后加载 | 以 YAML 格式开头标注技能名称和用途，正文写明 PDF 文本提取的操作步骤 |
| 辅助文档（如 FORMS.md、REFERENCE.md） | 补充特定场景说明和参考资料                                   | FORMS.md 记录 PDF 表单填写规范，REFERENCE.md 详述相关工具的 API 用法 |
| scripts 文件夹                        | 存放可执行脚本，多为 Python 或 Bash 脚本，供智能体在本地沙箱执行 | check_fillable_fields.py 用于检测 PDF 可填写字段，fill_pdf_form_with_annotations.py 用于填充 PDF 表单 |
| 其他附属文件                          | 如 LICENSE.txt 记录许可证信息，examples 文件夹存放任务案例模板等 | 标注技能的使用权限，提供 PDF 合并的示例模板                  |

SKILL.md的文件示例如下：

```yaml
# PDF表单处理技能 (PDF Form Processing Skill)
---
## 技能元数据 (Skill Metadata)
```yaml
name: pdf-form-processing
version: 1.0.0
description: 实现PDF表单的可填写字段检测、数据填充、表单验证及填充结果导出，支持常见PDF表单格式（AcroForm、XFA）
author: Anthropic Labs
compatibility: claude-3-opus, claude-3-sonnet, claude-3-haiku
dependencies:
  - PyPDF2>=3.0.0
  - pdfrw>=0.4
  - python-dotenv>=1.0.0
trigger_conditions:
  - 用户提及"PDF表单填充"
  - 用户上传PDF文件并要求"填写字段"
  - 用户询问"PDF可填写字段有哪些"
```



# 3 Agent Skill如何工作

在执行任务时，Claude扫描可用的skills去找到相关匹配项，当一但匹配到，它只会加载所需的最少信息和文件，包括：

- **可组合**: 技能可以叠加使用。Claude 会自动识别所需技能并协调其使用

- **可移植性**：只需构建一次，Skill可以在所有的地方使用

- **高效**：加载所需要的内容

- **强大**：Skill包括可执行的代码

# 4 Skill与MCP关系

MCP 负责连接外部世界，Skills 负责提供专业知识。开发者已经开始用 Skills 编排多个 MCP 工具的复杂工作流了。

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/0*9pl_KADfXHgPuA9y)
