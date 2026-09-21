# M2-W2 AWS package facts 修正版验证报告

验证日期：2026-08-13。结论：`ready_for_independent_review`。

## 结构化闭合

本包有 57 条事实、69 条逐来源断言和 71 条字段要求。57 条事实各有唯一字段要求映射和唯一资料卡覆盖；四张卡仍各有九域记录。五组冲突及 10 个成员保持未决，没有 preferred fact。A06 的 2,517 MXFP8/MXFP4 TFLOPS 与 A08 的 2.52 PFLOPS generic FP8 使用不同 precision path、事实和断言，没有静默合并。

69 个 `quoted_context` 均在各自首选固定 HTML 的规范化全文中逐字匹配。A01 与 A07 的两组 endpoint 正文等价继续按一个 source_id 计数；其他七个 source update 都明确写为单一固定快照。20 条缺失检索的 source types 与实际登记的冻结来源一致。

字段主体检查以正式 `数据/fields.csv` 为基准，只对 `FIELD-PHY-CLOCK` 叠加本包的 `object;component` 候选。这个候选可由正式 Trainium2 的四条 reviewed 组件时钟事实和字段要求复现；正式和 staged `fields.csv` 均未修改。

## 包内校验

相对路径调用如下：

`& powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED\scripts\Test-Staging.ps1 -RootPath .`

绝对路径调用使用项目根目录的完整路径作为 `RootPath`。两次结果均为 PASS，各执行 9,289 项检查。除 32 表表头、枚举、外键、主键碰撞、七目标 XOR、事实/断言证据数、冲突、来源哈希、backlog、九域和卡片覆盖外，修正版还检查了字段主体、69 条逐字引文、B01/B06/B07/B08 的精确语义、八源反向移除和 457 行 lifecycle manifest 候选。输出分别保存在 `audit/staging-validation-relative.txt` 和 `audit/staging-validation-absolute.txt`。

## 正式基线与隔离合并

当前静止正式基线为 75 个对象、24 条关系、621 条事实、611 条断言和 792 条字段要求。官方 `Validate-ResearchData.ps1` 在正式根目录通过 93,179 项检查，输出见 `audit/formal-baseline-validation.txt`。

按这份基线重建的隔离临时正式库通过 101,048 项检查。脚本随后删除临时目录；`audit/formal-hash-integrity.csv` 记录的 32 张正式表前后 SHA-256 全部相同。临时合并输出见 `audit/temporary-formal-merge-validation.txt`。

DEC-025 候选共有 457 行，覆盖所有非空 structured 行和三份 overlay 的实际主键。407 行拟升 `reviewed`；49 行 `needs_resolution` 保持不变，`SCREEN-M2-GA-A01` 保持 `reviewed`。manifest SHA-256 为 `f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880`。独立 `package_review`、signoff 和冻结绑定尚未签发，修正者没有把自己的修改升为独立复核结论。

## 冻结与文档终检

中文 Markdown 已先按 report-humanizer 做机器扫描，再按 shuorenhua 的受保护区规则人工检查标题、首段、表格引导、转场和结尾。术语、数字、ID、路径、原文引文和责任归属未因润色改变；机器扫描结果保存在 `audit/report-humanizer-scan.csv`。

`audit/freeze-manifest.csv` 在所有数据、报告和验证输出稳定后最后重建。为避免自引用，它不包含自身；aggregate 和 manifest SHA-256 由交接消息单独报告。原冻结包、正式库、正式资料卡和全局文档均未修改。

## 工具事件

本轮没有用户拒绝、auto-review 拒绝、审批连接失败、沙箱拒绝或远端服务错误。一次临时合并命令因修正者设置的超时过短而提前结束，留下 staging 内临时目录；这是命令参数失误，不是正式库写入。后续运行先核对安全路径，再删除遗留目录并通过完整验证。卡片转换和校验脚本在编写过程中还出现过模板字符串、字符串重载、重复运行保护、PowerShell 变量解析和 statement-form 管道构造错误；这些都属于修正者的命令或脚本构造失误，修正后已由逐字引文检查、卡片双向覆盖和完整 validator 复验。一次进程命令行只读查询被本机权限拒绝，不影响验证，也没有改动项目文件。