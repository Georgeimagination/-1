# M2-W3 AMD MI455X 模组包定点修复验证记录

> 验证日期：2026-08-13  
> 验证对象：`M2-W3-AMD-MI455X-MODULE` 暂存包  
> 正式库处理：只读，未合并

本文所用缩写：HBM 指高带宽内存，OCP 指 Open Compute Project；TFLOP/s 与 TOP/s 分别表示每秒万亿次浮点运算和每秒万亿次运算。

## 结论

定点修复后的暂存包通过包内复算和官方正式验证器。正式基线在 `gate` 模式通过 32 张表、97,920 项检查；把 24 份暂存表叠加到正式库只读副本后，临时镜像通过 102,752 项检查。字段主体合同与字段要求目标合同都作为硬门执行。

临时镜像删除后，正式数据区和最小参考资料库的 32 份 CSV 与包内基线逐文件匹配，变化数为 0。按 `relative_path|sha256|bytes` 排序并用换行连接后计算的 SHA-256 仍为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`。正式 `论文/` 仍有 111 份 PDF；包内 `tmp/` 和临时镜像都不存在。

| 检查项 | 修复后结果 |
|---|---:|
| structured CSV | 24 份，表头匹配 24/24 |
| facts | 39 行；直接 39，派生 0 |
| fact assertions | 53 行；覆盖 39/39 条直接事实 |
| field requirements | 44 行；`value_available` 36，`not_found` 8 |
| components / memory levels / links | 5 / 2 / 3 |
| precision paths / special capabilities / topologies | 12 / 0 / 0 |
| condition sets | 9 |
| derived metrics / inputs | 0 / 0 |
| no-result search logs / results | 8 / 32；每项恰查 4 个来源 |
| 新 sources / endpoints | 2 / 4；本地 endpoint 哈希错误 0 |
| selection run / members | 1 / 4；状态保持 `draft` |
| card completeness | 恰 9 行、9 个域 |
| card mapping | 39/39 facts，8/8 非 value-available requirements，关系已引用 |
| Helios facts | 0 行 |
| 正式 32 CSV 哈希变化 | 0 |

## 独立复核问题的关闭情况

状态链已经恢复。`FACT-M2W3-AMD-MI455X-STATUS` 的规范值是 `announced`，`REQ-M2W3-AMD-MI455X-STATUS` 为 `value_available`，产品页断言使用 `qualifies`，并明确公开宣布不等于出货、量产爬坡或一般可用。与状态冲突的一条无结果日志和四条检索结果已经删除；实际可用日期仍单独保持 `not_found`。

四条不满足字段前置条件的存算比已经整链删除。结构化表和资料卡中没有残留相应的 fact、requirement、condition、derived metric 或 derived input 主键；`derived-metrics.csv` 与 `derived-inputs.csv` 只有表头。三个 precision-path 备注使用独立复核要求的文本，9 个条件指纹均不含 dense 外推。

七条 HTML locator 均与固定产品页标签逐字一致，Process 的 raw text 也已改为 `TSMC 2nm | 3nm FinFET`。独立复核点名的 15 条 `confidence_reason` 已逐条核对，只引用该事实已有断言的来源；没有仅凭说明文字把 `single_source` 提升为 `corroborated`。

资料卡第 3.2 节使用“厂商性能格式标签”，第 4 节明确没有 MI455X 产品级 A/B 操作数、乘积、程序员可见累加、物理累加或输出编码证据。资料卡引用全部 39 条直接事实和 8 条非 `value_available` 要求，不引用已删除派生链。

## 证据、合同和来源集复算

39 条直接事实都有 `source_checked` 断言，断言 raw text / raw number 二选一错误为 0，locator 缺失为 0。按不同 `source_id` 复算，证据状态为 `single_source` 23 条、`corroborated` 14 条、`source_with_caveat` 2 条，错误为 0。

事实主体合同通过 39/39，字段要求目标合同通过 44/44。包内主键重复、与正式库 ID 碰撞、endpoint 本地文件缺失或哈希不符、preferred endpoint 数量异常均为 0。九域完整度包含 identity、physical、compute、numerics、memory、interconnect、special_engines、software 和 evidence，恰好各 1 行。

事实集合变化后，`SELRUN-M2W3-AMD-MI455X-20260813` 已按 39 条直接事实重跑。产品页、brochure、MI400 固定页和 CDNA 5 白皮书仍各有不可替代贡献，四个成员继续保留；选择运行与成员均保持 `draft`，不由本包作者签字。

## 验证方法与故障分类

临时镜像完整复制正式 `数据/`、`最小参考资料库/` 和 `论文/`，再追加 24 份暂存表及两份固定候选。官方验证器成功后，先确认镜像路径位于包内 `validation/`，再用 PowerShell 精确删除；没有使用 junction，也没有触碰正式文件。

定点修复阶段有两次脚本构造错误。第一次卡片插入按 CRLF 寻找，但原文件使用 LF；第二次正式哈希命令把 JSON 数组误当成单个对象。另一次临时本地检查脚本缺少 UTF-8 BOM，Windows PowerShell 误解了中文路径。这些都属于执行代理的操作错误，已修正并由成功结果完整覆盖。修复阶段没有发生沙箱拒绝、审批拒绝或远端服务错误。

机器可读结果见 `local-check-results.json`，逐卡片实体映射见 `card-evidence-map.csv`，正式 32 表基线见 `formal-32-csv-baseline.json`。本报告不构成独立复核签字；包状态只到 `ready_for_final_independent_review`。