# Claude Code 代码检查工具

## 概述

Claude Code 提供了 **4 种不同的代码审查机制**，各自定位不同，可以组合使用以实现全方位的代码质量保证。

| 工具 | 触发方式 | 触发时机 | 审查范围 | 关注点 | 费用 |
| --- | --- | --- | --- | --- | --- |
| **security-guidance** | 全自动 | 每次编辑后、回合结束、git 操作时 | 变更文件 | 安全漏洞（注入、越权、敏感信息泄露等） | 有额外调用费用 |
| **/security-review** | 手动 slash command | 开发者主动触发（通常 PR 前） | 当前分支相对 main 的所有变更 | 安全漏洞（完整上下文） | 有调用费用 |
| **/grill-me** | 手动 skill | 开发者主动触发（对抗性审查） | 当前分支或指定代码 | 安全、设计、边界情况、实现正确性 | 有调用费用 |
| **/golang-review** | 手动 slash command（本项目自定义） | 针对指定 Go 文件 | 指定文件 | Go 特定问题（goroutine 泄漏、context 传播、error wrapping 等） | 有调用费用 |

---

## 工具详解

### 1. security-guidance 插件（全自动）

#### 功能定位
- **自动守门员**：持续监控代码变更，无需主动操作
- **及时反馈**：错误发现后当场自动修复，session 内完成
- **降低人工成本**：减少进入手动审查阶段的问题量

#### 触发时机
- 每次文件编辑后（自动分析变更代码）
- Claude 执行每个回合结束（汇总审查）
- Claude 执行 git commit/push 时（提交前最后把关）

#### 审查内容
- **注入攻击**：SQL 注入、命令注入、XXS、模板注入
- **认证与授权**：硬编码密钥、权限检查缺失、token 处理不当
- **敏感信息泄露**：API Key、密码、内网 IP、个人信息等
- **数据验证**：缺少输入验证、类型混乱、边界检查不足
- **安全库使用**：使用了已知有安全漏洞的库、不安全的加密方式

#### 工作流程
```
代码编辑 → security-guidance 自动分析
         ↓
         发现问题?
         ├→ 是：自动修复 + 告知用户
         └→ 否：继续
```

#### 示例场景
```javascript
// ❌ security-guidance 会自动发现并修复
const query = `SELECT * FROM users WHERE id = ${req.query.id}`;

// ✅ 自动修改为
const query = `SELECT * FROM users WHERE id = ?`;
db.query(query, [req.query.id]);
```

#### 配置

检查 security-guidance 是否已安装：
```bash
/plugin list
```

如未安装，手动安装：
```bash
/plugin install anthropic/security-guidance
```

---

### 2. /security-review 命令

#### 功能定位
- **完整审计**：扫描当前分支相对 main 的所有变更
- **上下文完整**：一次性分析全部改动，能识别跨文件的安全问题
- **补充 security-guidance**：捕获 session 内遗漏的、需要跨文件理解的问题

#### 使用方法

**基础用法：**
```bash
/security-review
```

**用途：**
- PR 前的最后安全检查
- 完成一个功能模块后的全面审查
- 跨多个文件的重构完成后

#### 审查内容
与 security-guidance 类似，但由于上下文更完整，能发现：
- 跨模块的权限链路问题
- 多个认证点的一致性问题
- 信息流中的敏感数据泄露路径
- API 接口的统一安全标准缺失

#### 工作流程
```
执行 /security-review
        ↓
扫描：当前分支 vs main 的所有 git diff
        ↓
分析所有变更代码的安全风险
        ↓
输出：问题列表 + 修复建议
        ↓
用户决定：接受修复 / 讨论问题
```

#### 示例场景
```bash
# 新增了用户认证模块，想确保没有安全漏洞
/security-review

# 输出：
# ✅ 检查完成
# 发现问题 3 个：
# 1. tokens.go: Token 过期时间硬编码，建议配置化
# 2. auth_middleware.go: 缺少 CSRF 防护
# 3. db.go: 连接字符串含有密码，建议使用环境变量
```

---

### 3. /grill-me skill

#### 功能定位
- **对抗性审查**：Claude 主动向你提难题，直到你答对才放行
- **覆盖面更广**：不仅是安全，还包括设计、边界情况、实现正确性
- **推倒重写模式**：支持"我觉得设计有问题，帮我推倒重来"的场景

#### 使用方法

**基础用法：**
```bash
/grill-me
```

**交互模式：**
- Claude 提出问题，等待你的回答
- 你的回答不能令 Claude 满意 → 继续追问
- 直到你给出令人信服的答案，grill-me 才宣布通过

#### 审查内容
- **安全设计**：是否有明显的安全漏洞？防护措施够吗？
- **算法正确性**：边界情况处理是否完整？是否有潜在的逻辑漏洞？
- **并发安全**：涉及并发时，是否有竞态条件、死锁风险？
- **错误处理**：错误是否正确捕获和传播？是否有不可恢复的状态？
- **接口设计**：API 签名是否清晰？是否容易被错误使用？
- **性能**：有没有明显的性能问题或优化空间？

#### 工作流程
```
执行 /grill-me
      ↓
Claude 提出第 1 个质问
      ↓
你的回答 → Claude 评估
      ├→ 满意：下一题
      └→ 不满意：追问
      ↓
...（循环直到通过）
      ↓
✅ 通过审查
```

#### 示例场景
```
用户：/grill-me

Claude：问题 1: 你这个缓存实现，如果 Redis 宕机了会怎么样？

用户：我们有容错逻辑，缓存失败会降级到数据库查询。

Claude：听起来不错。那假设 Redis 恢复了，旧数据仍在缓存中。你怎么保证数据一致性？

用户：我们设置了 5 分钟的 TTL，并且在更新数据时清除对应的缓存键。

Claude：✅ 回答满意。下一题...
```

#### 适用场景
- **PR 前的质量把关**：确保代码经得起推敲
- **推倒重来**：发现设计有根本问题，需要重新思考
- **新特性复审**：重要功能上线前的最后挑战

---

### 4. /golang-review 命令（本项目自定义）

#### 功能定位
- **Go 特定问题**：专注于 Go 语言的常见陷阱和最佳实践
- **规范执行**：基于 Uber Go 风格指南和 Go 社区最佳实践
- **补充 security-guidance**：security-guidance 管安全，golang-review 管代码质量

#### 使用方法

**基础用法：**
```bash
/golang-review <文件路径>
```

**示例：**
```bash
# 审查单个文件
/golang-review internal/service/user.go

# 审查多个文件（可选）
/golang-review internal/service/
```

#### 审查内容

| 类别 | 检查项 | 示例 |
| --- | --- | --- |
| **Goroutine** | goroutine 泄漏 | 启动 goroutine 后没有正确 cancel context |
| | goroutine 生命周期管理 | 未确保 goroutine 在适当时机退出 |
| | 无缓冲 channel 死锁 | channel 操作导致的死锁 |
| **Context** | context 传播链 | 跨函数调用没有正确传递 context |
| | context timeout 处理 | 超时后没有正确清理资源 |
| | context 使用规范 | 在并发环数中正确使用 context.Background/TODO |
| **Error** | error wrapping | 使用 `%w` 保留原始错误链 |
| | error check | 检查每个可能返回 error 的函数调用 |
| | sentinel errors | 正确定义和使用 sentinel error 值 |
| **并发安全** | 竞态条件 | 共享变量的并发访问是否保护 |
| | 互斥量使用 | sync.Mutex 是否正确加锁和解锁 |
| **接口设计** | 接口粒度 | 接口定义是否过大或过小 |
| | 接口命名 | 单方法接口是否以 `er` 后缀命名 |
| **其他** | nil 检查 | 切片、map、interface 的 nil 检查 |
| | defer 顺序 | defer 的执行顺序是否符合预期 |
| | 资源释放 | 文件、网络连接等资源是否正确关闭 |

#### 工作流程
```
执行 /golang-review <file>
        ↓
分析 Go 代码特定问题
        ↓
输出：问题列表 + 修复建议
        ↓
用户决定：接受修复 / 讨论问题
```

#### 示例场景

**问题 1：Goroutine 泄漏**
```go
// ❌ golang-review 会发现
func (s *Service) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-time.Tick(1 * time.Second):
                s.process()
            }
        }
    }()
}

// ✅ 修复为
func (s *Service) Start(ctx context.Context) {
    go func() {
        ticker := time.NewTicker(1 * time.Second)
        defer ticker.Stop()

        for {
            select {
            case <-ctx.Done():
                return  // 正确退出
            case <-ticker.C:
                s.process()
            }
        }
    }()
}
```

**问题 2：Error 未正确 wrap**
```go
// ❌ golang-review 会发现
if err := db.Query(ctx, query); err != nil {
    return err  // 丢失了错误链上下文
}

// ✅ 修复为
if err := db.Query(ctx, query); err != nil {
    return fmt.Errorf("failed to query users: %w", err)
}
```

#### 配置

确保项目的 CLAUDE.md 中已定义该 skill（通常在项目初始化时完成）。

---

## 工具对比与选择

### 快速决策表

| 场景 | 推荐工具 | 原因 |
| --- | --- | --- |
| 日常开发，想要持续保护 | **security-guidance** | 全自动，无需额外操作 |
| 功能完成，想快速安全检查 | **/security-review** | 一键审查当前分支变更 |
| PR 前最后把关 | **/security-review** | 完整上下文扫描 |
| 想被"怼"到服气 | **/grill-me** | 对抗性审查，覆盖面广 |
| 写 Go 代码，关注质量 | **/golang-review** | Go 特定问题深度检查 |
| PR 前完整检查 | security-guidance + /security-review + /grill-me | 多层防护 |

### 工具间的协作关系

```
编码阶段
    ↓
    ├─→ security-guidance （自动）
    │   └─ 发现即时问题，当场修复
    ↓
代码完成
    ↓
    ├─→ /security-review （手动）
    │   └─ 全面扫描当前分支
    │
    ├─→ /golang-review <文件> （手动，若是 Go）
    │   └─ Go 特定质量检查
    │
    ├─→ /grill-me （手动，可选）
    │   └─ 对抗性审查，设计+实现
    ↓
PR 提交
```

---

## 实践建议

### 推荐工作流（通常场景）

```bash
# 1. 完成一个功能
# （security-guidance 自动保护）

# 2. 提交前全面检查
/security-review

# 3. 如果是 Go 代码，额外检查质量
/golang-review internal/service/user.go

# 4. 如果有设计疑虑或想要对抗性审查
/grill-me

# 5. 满意后提交 PR
git add .
git commit -m "Add user authentication module"
git push origin feature/auth
```

### 重要功能前的完整检查（推荐）

```bash
# PR 前对关键模块的 3 层检查
/security-review
/golang-review internal/auth/
/grill-me
```

### 快速单次检查（轻量）

```bash
# 仅做安全扫描，不做对抗性审查
/security-review
```

---

## 常见问题

### Q1: 所有工具都要用吗？

**A:** 不必。根据场景选择：
- 日常开发：只依赖 **security-guidance**（自动）
- 小功能：security-guidance + **/security-review**
- 关键功能或复杂设计：加上 **/grill-me** 和 **/golang-review**

### Q2: 这些工具会影响性能吗？

**A:**
- **security-guidance**：轻量，后台运行，基本无感知
- **/security-review** 和 **/grill-me**：需要调用 API，有一定延迟（通常 5-30 秒）
- **/golang-review**：取决于文件大小，通常 5-15 秒

### Q3: 修复建议和人工修复哪个优先？

**A:** 建议：
1. 理解工具的修复逻辑
2. 如果同意，接受修复
3. 如果有疑虑，讨论后再决定
4. 信任 security-guidance 的自动修复，因为它更保守

### Q4: 如果 /security-review 和 /grill-me 有冲突的建议怎么办？

**A:** 很少发生，但可能发生的情况：
- 优先信任 /security-review（安全 > 性能）
- 如有疑虑，在 CLAUDE.md 中记录决策理由

### Q5: 本地开发能用这些工具吗？

**A:** 是的。所有工具都适用于：
- 本地开发 session
- 远程会话（如果配置了 MCP）
- CI/CD 流程（需要集成脚本）

---

## 技术细节

### security-guidance 的架构

```
文件编辑事件
    ↓
    捕获 diff
    ↓
    调用独立 Claude 实例（与主会话隔离）
    ↓
    正则匹配 + LLM 分析（双重检查）
    ↓
    发现问题 → 自动修复 + 通知用户
    ↓
    无问题 → 继续
```

**隔离设计的好处：**
- 不干扰主会话的上下文
- 安全审查逻辑独立演进
- 可以持续升级而不影响用户工作流

### /security-review 的工作范围

```
git diff main..HEAD  # 当前分支相对 main 的所有改动
    ↓
逐文件分析
    ↓
跨文件关联分析（关键）
    ↓
输出：
  - 影响范围
  - 问题严重程度
  - 修复建议
  - 相关代码行号
```

### /grill-me 的交互逻辑

```
Claude 提问 → 等待用户输入 → 评估答案
        ↑                         ↓
        ←─────── 不满意 ───────────
                              ↓
                          满意 → 下一题
                              ↓
                        (循环 3-5 轮)
                              ↓
                            通过
```

---

## 更新日志

| 日期 | 工具 | 变更 |
| --- | --- | --- |
| 2026-05-28 | 全部 | 首次整理代码检查工具文档 |

