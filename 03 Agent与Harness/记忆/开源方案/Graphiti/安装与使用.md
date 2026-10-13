# Graphiti：安装、使用与记忆管理

[Graphiti](https://github.com/getzep/graphiti) 是 Zep 开源的时序上下文图框架。它将新观察写成 episode，持续抽取实体、关系和时间变化，并从图中组合可供 Agent 使用的上下文。它适合“事实会变化且关系本身很重要”的记忆场景。

## 1 核心定位

| 维度 | 说明 |
| --- | --- |
| 类型 | 时序图记忆 / temporal context graph |
| 写入单位 | Episode（交互、文档或外部观察） |
| 主要能力 | 实体与关系抽取、时序更新、图搜索、混合检索与 rerank |
| 常用后端 | Neo4j、FalkorDB、Amazon Neptune 等图数据库 |
| 适合场景 | 动态用户状态、企业关系网络、长期运行的世界模型 Agent |

Graphiti 不是通用文档 RAG 的直接替代品。只有当实体关系、来源追溯或状态随时间变化会影响推理时，图记忆带来的复杂度才通常值得承担。

## 2 安装与初始化

### 2.1 前置条件

- Python 3.10 或更高版本；
- 可访问的图数据库实例；
- 用于实体/关系抽取与 embedding 的模型配置；
- 生产环境中的网络隔离、凭据管理、备份与监控方案。

### 2.2 安装 Python SDK

```bash
pip install graphiti-core
```

Graphiti 对不同图后端有对应的安装与连接配置。以当前 [官方 Quickstart](https://help.getzep.com/graphiti/getting-started/quickstart) 和所选后端文档为准，不要将数据库密码或模型密钥写入脚本、示例输出或仓库。

### 2.3 连接图数据库

以下以 Neo4j 为概念示例。连接 URI、认证信息与模型配置应从部署环境的密钥管理服务读取：

```python
import os
from graphiti_core import Graphiti

graphiti = Graphiti(
    os.environ["NEO4J_URI"],
    os.environ["NEO4J_USER"],
    os.environ["NEO4J_PASSWORD"],
)

await graphiti.build_indices_and_constraints()
```

首次初始化时，创建索引和约束有助于后续写入和检索保持性能与数据一致性。生产系统应将该初始化作为受控的部署步骤，而非每次请求都执行。

## 3 写入与检索

### 3.1 写入 episode

新信息应以带来源与参考时间的 episode 写入。Graphiti 据此识别实体、关系及其有效时间。

```python
from datetime import datetime, timezone
from graphiti_core.nodes import EpisodeType

await graphiti.add_episode(
    name="用户座位偏好更新",
    episode_body="用户目前偏好靠窗座位，并在上午出行。",
    source=EpisodeType.message,
    source_description="用户已确认的偏好",
    reference_time=datetime.now(timezone.utc),
)
```

`reference_time` 应表示事件或事实真正发生的时间，而不是盲目使用写入时间。对会变化的状态，正确的时间语义决定了系统能否回答“现在是什么”与“过去是什么”。

### 3.2 搜索图上下文

```python
results = await graphiti.search(
    "用户目前有什么座位偏好？"
)

for result in results:
    print(result.fact)
```

典型 Agent 流程如下：

```text
当前问题 → Graphiti 搜索 → 选择相关事实、关系和来源 → 组织为 Agent 上下文
新观察   → 写入 episode → 增量更新时序图
```

检索结果是辅助上下文。涉及权限、财务、医疗或实时状态时，仍应向权威业务系统验证，不能只凭历史图记忆作最终决策。

### 3.3 关闭连接

长连接服务应在应用生命周期结束时正常释放资源：

```python
await graphiti.close()
```

## 4 图记忆治理

### 4.1 先定义实体、关系与时间边界

接入前应明确：

- 需要追踪哪些实体，例如用户、账户、产品、工单或地点；
- 哪些关系可随时间变化，例如“偏好”“归属”“负责”；
- episode 的可信来源与允许写入者；
- 当前事实与历史事实的查询和展示规则。

不清楚这些边界时，图会很快积累同义实体、冲突关系与不可解释的历史记录。

### 4.2 作用域与多租户隔离

Graphiti 图中的节点与 episode 应携带租户、项目、用户或 Agent 作用域，并在写入与检索两端强制过滤。多租户系统不能直接信任客户端提供的作用域；应由服务端根据认证身份派生并验证。

### 4.3 更正、删除与审计

图记忆不能只追加。应建立以下能力：

1. 错误 episode 或关系的纠正与删除流程；
2. 对来源、写入时间、操作者和影响范围的审计；
3. 对过期关系的生命周期与保留期限；
4. 用户查看、导出与遗忘请求处理；
5. 对敏感字段的写入前脱敏或禁止规则。