# 执行与回滚合同

## 适用边界

本合同只适用于 SHA-256 为 `0f59aa2fd893473eb1002d44816e16ace6b204259ac94e802b5f00774ea0cbd5` 的 Ascend 950 553 行签字。执行入口是 `scripts/Invoke-Ascend950FormalTransaction.ps1`。不带正式授权参数时，只要 `TargetRoot` 等于当前正式根，脚本会在创建候选、备份、结果或目标文件之前拒绝执行。

## 正式执行前的外置备份

独立复核者须在正式根之外建立专用外置备份目录（`BackupRoot`）。该目录不能是正式根、正式根子目录或正式根父目录，结果目录必须位于 `BackupRoot` 内。备份按 `formal-backup-manifest-template.csv` 建立，共 24 个唯一条目：20 张待改表的合并前（premerge）原件、只读保护项（guard）涉及的 `数据/objects.csv` 和 `数据/object-relations.csv`、`ASCEND950-NEW-FILE-TARGETS-ABSENT.csv` 以及 `ASCEND950-CANDIDATE-20-TABLE-POSTHASHES.csv`。路径、字节数和 SHA-256 都要与模板一致。

独立签字必须只有一行，字段顺序与 `transaction-review-signoff-template.csv` 完全相同。复核者须为不同代理 `m2_ascend950_formal_transaction_independent_review`，裁决为 `accept`，`ready_for_formal_execution` 为 `true`，并绑定执行器、预检（preflight）、镜像演练（rehearsal）、事务包清单（manifest）、包聚合哈希、上游签字、暂存区清单（staging manifest）、f152 正式基线聚合哈希和授权令牌。准备者不能充当该复核者。

`BackupRoot` 还须包含 `ASCEND950-FORMAL-TRANSACTION-AUTHORIZATION.txt`。内容精确为六项用 `|` 连接：授权令牌、独立签字文件 SHA-256、上游签字 SHA-256、正式基线聚合哈希、事务包清单 SHA-256、备份清单 SHA-256。不得附加说明文字。执行器在开始和提交前会重复核验。

## 提交范围

执行器先核对 f152 聚合哈希、553 行签字、53 行 staging manifest、20 张表逐表合并前哈希、5 个只读保护项、8 个目标不存在状态、包冻结和外置备份。随后在唯一临时目录构造候选副本，重放 545 行结构化写入并复制 8 个文件。

候选必须在硬门（`gate`）模式通过 115,509 项检查；20 张待改表的后哈希必须与冻结清单一致；32 表聚合哈希必须为 `bcb16e932019c1625e9b5a5309a37f569c0bb230b7c921a589dd3f7175632b8c`。提交阶段只允许按 `formal-csv-backup-candidates.csv` 替换 20 张表，并按 `new-file-targets.csv` 新建 8 个目标。每次替换或复制前先写事务日志（journal）注册，完成后再写 `complete`。

## 回滚顺序

任何提交期异常都会先逆序处理已注册的新文件，再逆序处理已注册的表。新文件只有在当前哈希仍等于本事务写入哈希时才能删除；表从已核验的合并前备份恢复。回滚结束必须同时满足：32 表聚合哈希回到 f152；8 个新文件目标均不存在；5 个只读保护项保持原哈希；`.ascend950-formal-transaction-*` 临时文件和事务锁均为 0。

任一检查失败时，结果必须写成 `FAIL_ROLLBACK_FAILED`，不得宣称已恢复；须保留 `BackupRoot`、journal 和现场交由人工处理。不得编辑冻结包后沿用旧签字，不得把 `BackupRoot` 放入正式根，不得预先创建新文件目标，也不得绕过默认拒绝手工改表。故障注入环境变量只用于隔离镜像，正式执行环境必须为空。
