# MI350P 正式事务准备包

状态：`ready_for_independent_review`

本目录为 AMD Instinct MI350P PCIe（Peripheral Component Interconnect Express，高速外设互联）卡准备受控正式事务。它只提供冻结合同、执行器、回滚证据和复核入口，不授权正式合并。本任务没有改动正式 32 表、正式资料卡、正式网页快照或正式 PDF（Portable Document Format，可移植文档格式）；全部写入都留在当前交接目录。

## 冻结输入

| 输入 | 冻结值 |
|---|---|
| 当前正式 32 表聚合 | `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10` |
| MI350P 最终独立复核报告 SHA-256 | `470d381d66e5cb7ccd7b3fc9aa88ede12ed1a995a6a1af6e03844630d9b43461` |
| 274 行精确签字 SHA-256 | `74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1` |
| 50 行 staging（暂存区）冻结清单 SHA-256 | `1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01` |
| staging 冻结内容聚合 | `152df43e8b64c2b78c54a41c6cf9bd7acfa4d3315fcf33d6128399b22f2f8825` |

SHA-256 是用于确认文件内容未变化的哈希值。274 行签字由 270 个结构化主键和 4 个文件载荷组成；270 个主键分布在 19 张正式表中。

## 准备结果

静态合同通过 8,811 项检查，冻结了 19 张写表、3 条无写保护、4 个当前不存在的正式目标，以及备份和逆序回滚清单。事务预检通过 11,290 项检查。当前正式校验器仍通过 106,160 项检查，正式 32 表聚合仍为 `f152...da10`。

执行器在正式模式下默认拒绝。默认拒绝、错误令牌、待签独立复核、错误镜像标记、预先存在目标和错误合并前哈希六个负向门均已通过，正式写入次数为 0。

隔离镜像完成三种演练：正向提交、替换 3 张表后中断、复制 2 个文件载荷后中断。正向候选通过 111,390 项检查，聚合为 `28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e`；两种中断场景都按事务日志（journal）逆序回滚到 `f152...da10`，事务临时文件和锁均清零。三场景期间，正式 32 表和四个正式目标均为零变化。

## 独立复核入口

复核者先读 [VALIDATION-RECORD.md](VALIDATION-RECORD.md) 和 [EXECUTION-ROLLBACK.md](EXECUTION-ROLLBACK.md)，再核对 `manifest.csv`、`freeze-validation.json` 与 `transaction-review-signoff-template.csv`。准备者没有签署 `accept`；模板仍为 `pending / false`。只有任务名为 `m2_mi350p_formal_transaction_independent_review` 的不同代理，对精确范围 `formal_execution_of_exact_274_row_signoff_via_transaction_v1` 独立签字后，正式执行器才允许最小重新绑定。
