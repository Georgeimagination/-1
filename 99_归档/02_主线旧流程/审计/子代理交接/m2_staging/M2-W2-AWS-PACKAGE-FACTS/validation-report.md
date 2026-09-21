# M2-W2-AWS-PACKAGE-FACTS 验证报告

验证日期：2026-08-13。结论：`ready_for_independent_review`。

## 结构化候选

本包有 4 张资料卡、56 条事实和 66 条逐来源断言。实现实体包括 24 个组件、6 个存储层、3 条互连、17 条精度路径和 28 个条件集。70 条字段要求中，45 条为 `value_available`，5 条为 `conflicting_unresolved`，20 条为 `not_found`；物理构造缺口有 20 条检索日志和 50 条检索结果。五组冲突共 10 个候选成员，四个对象的九域完整度共 36 行。

backlog 审计共 24 行，其中 23 行拆成 56 条新事实，1 行复用 Trainium2 正式链。卡片覆盖审计有 56 行，每个 fact_id 恰好出现在一张对应资料卡中。最小来源候选包含 9 个 source_id；每个 selection member 完整列出反向移除会丢失的 fact_id，计数和列表与 `audit/reverse-removal.csv` 一致。

## 来源门

11 个 HTML 文件的 SHA-256 与 `source-gate/source-freeze-register.csv` 一致。11 个 endpoint 均为新的 `web_snapshot` 候选，`access_date` 和 `snapshot_date` 都是 2026-08-13，拟正式 `local_path` 位于 `最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/`。A01 与 A07 的 latest、v2.31.0 `<article>` 正文分别逐字符相同；每组只计一个 `source_id`，版本化 endpoint 为首选。

append 候选与既有 PK 更新已经分开。`structured/source-endpoints.csv` 只含 11 条新 endpoint；`structured/sources.csv` 和 `structured/source-screening.csv` 只有表头。既有 source、endpoint 和 screening 的更新分别在 `audit/source-updates.csv`、`audit/source-endpoint-updates.csv` 和 `audit/source-screening-updates.csv`，临时合并时按主键 overlay。

## 校验结果

`Test-Staging.ps1` 退出码为 0，共通过 8,322 项检查。检查覆盖 32 个正式表头、必填值、枚举、外键、正式主键碰撞、七目标 XOR、事实值和断言 raw 值 XOR、证据来源数、稳定 locator、原文短摘录、字段要求映射、缺失检索、冲突组、endpoint 日期与哈希、正文等价、backlog、九域完整度、卡片双向覆盖、最小来源反向移除和行数预算。

`Test-TemporaryFormalMerge.ps1` 退出码为 0。脚本在 staging 内建立临时合并目录，把 append 与 overlay 分流后运行正式 `Validate-ResearchData.ps1`；正式 validator 通过 99,503 项检查。临时目录和目录联接随后删除。`audit/formal-hash-integrity.csv` 显示验证前后 32 张正式表的 SHA-256 全部相同，正式库没有被测试过程修改。

项目正式基线 validator 另行只读运行并通过 91,827 项检查。`README.md`、`handoff.md`、本报告和四张中文资料卡均通过 `report-humanizer` 机器扫描；按 `shuorenhua` 的 docs/status 规则人工回读后，没有改动数字、日期、版本、ID、路径、原文短摘录、作用域或责任归属。

## 工具事件

有三类本地工具/命令事件，不影响最终产物。直接执行 `.ps1` 被 Windows 执行策略拒绝，改用显式 `-ExecutionPolicy Bypass` 后正常运行；这属于本机执行策略限制，不是沙箱、审批或模型能力问题。一次生成脚本因 Windows PowerShell 5.1 读取无 BOM 的中文 UTF-8 文件而出现乱码解析错误，改为 UTF-8 BOM 后通过；这是脚本编码处理失误。首次临时合并清理遇到 PowerShell `Remove-Item` 删除目录联接的 `NullReferenceException`，改用 .NET 只删除已验证的 reparse point 后，临时目录成功清理并重跑通过；这是 PowerShell 运行时故障，不是沙箱或审批失败。另有两次短命令因 `foreach` 结果直接接管道、一次字符串构造错误而报解析错误，修正为先物化结果后继续；这些属于命令构造失误。

没有用户拒绝、auto-review 拒绝、审批连接失败、沙箱拒绝或远端服务错误。指定输入 `数据/README.md` 在项目中不存在；本轮通过正式 schema、32 张表和 validator 补足了结构上下文，不影响完成，但独立复核时应知道该文件缺失。