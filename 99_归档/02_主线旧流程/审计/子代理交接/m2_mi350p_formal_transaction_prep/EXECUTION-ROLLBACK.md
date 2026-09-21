# 执行与回滚合同

## 适用范围

本合同只适用于已经冻结的 MI350P 274 行签字包。正常入口是 `scripts/Invoke-MI350PFormalTransaction.ps1`。执行器遇到当前正式根时默认拒绝，并且在创建结果目录、候选、备份或目标文件之前停止。

`BackupRoot` 指正式根之外的专用备份目录；`guard` 指事务不得改动、但必须在提交前后核验的保护对象；`payload` 指随结构化数据一并落盘的文件载荷。这里的 journal 是逐步登记提交与回滚动作的事务日志。

`manifest` 指逐文件清单，`aggregate` 指按约定汇总多条文件哈希得到的聚合哈希；SHA-256 用来确认文件内容未变化。

## 正式执行前置条件

独立复核者先复算冻结包，再于正式根之外建立 `BackupRoot`。该目录不能是正式根、正式根的子目录或父目录；正式结果目录必须放在 `BackupRoot` 内。

备份按 `formal-backup-manifest-template.csv` 落盘，并生成 `MI350P-FORMAL-BACKUP-MANIFEST.csv`。清单应有 23 个唯一条目：19 张待改表的合并前原件，guard 涉及的 `数据/objects.csv` 与 `数据/object-relations.csv`，以及 `MI350P-NEW-FILE-TARGETS-ABSENT.csv`、`MI350P-CANDIDATE-19-TABLE-POSTHASHES.csv` 两个冻结哨兵。每个条目的路径、SHA-256 和字节数都必须与清单一致。

独立签字只能有一行，字段顺序必须与 `transaction-review-signoff-template.csv` 完全相同。`reviewer` 必须为 `m2_mi350p_formal_transaction_independent_review`，`verdict` 必须为 `accept`，`ready_for_formal_execution` 必须为 `true`。签字还要绑定执行器、预检脚本、演练脚本、本包 manifest 与 aggregate、最终复核报告、274 行精确签字、staging（暂存区）冻结清单、正式基线、候选逐表后哈希、候选聚合、111,390 项候选校验计数和授权令牌。准备者不得充当该复核者。

`BackupRoot` 内还须有 `MI350P-FORMAL-TRANSACTION-AUTHORIZATION.txt`。文件内容由六项按顺序用竖线连接，不带解释文字：授权令牌、独立签字文件 SHA-256、274 行精确签字 SHA-256、正式基线 aggregate、本包 manifest SHA-256、备份 manifest SHA-256。执行器会在事务启动和正式提交前再次核验这些值。

## 提交边界

预检先核对正式 aggregate、最终复核报告、精确签字、冻结清单、19 张表的逐表哈希、3 个 guard、4 个目标不存在状态，以及本包和备份合同。随后，执行器只在 `BackupRoot` 下的唯一临时目录构造候选副本，重放 270 行受控写集并复制 4 个 payload，再运行完整校验器。

候选必须通过 111,390 项检查；19 张待改表的逐表后哈希必须与 `expected-candidate-19-table-posthashes.csv` 一致；32 表 aggregate 必须为 `28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e`。上游签字中的 111,343 项对应尚未提升生命周期状态的暂存合并，受控重放完成状态提升后新增 47 项检查。拆分见 [candidate-validator-count-analysis.md](candidate-validator-count-analysis.md)。

正式提交只允许替换 `formal-csv-backup-candidates.csv` 列出的 19 张表，并新建 `new-file-targets.csv` 列出的 4 个目标。每次移动或复制之前，journal 先登记 `registered`；动作完成后再登记 `complete`。正式结果写在 `BackupRoot` 内，事务锁写在该目录的父目录，结束时必须清理。

## 回滚顺序

出现异常后，执行器先按登记顺序的逆序处理 payload，再按逆序处理已经登记的表。payload 只有在当前哈希仍等于本事务写入哈希时才删除；表则从已经核验的合并前备份恢复。

回滚完成后，必须同时满足以下条件：正式 aggregate 恢复为 `f152...da10`；4 个新文件目标全部不存在；3 个 guard 仍与签字哈希一致；事务目录中的 `.mi350p-formal-transaction-*` 临时文件为零；事务锁和 `.tmp-mi350p-formal-*` 目录也为零。任一条件不满足时，结果只能标为 `FAIL_ROLLBACK_FAILED`。此时不得声称已经恢复，应保留 `BackupRoot`、journal 和现场，交由人工核查。

## 禁止事项

冻结后不得编辑本包再沿用旧签字；不得把 `BackupRoot` 放进正式根；不得提前创建 4 个正式目标；准备者不得自行签署 `accept`；不得绕过执行器手工改表。故障注入环境变量只用于隔离镜像演练，正式执行环境必须为空。
