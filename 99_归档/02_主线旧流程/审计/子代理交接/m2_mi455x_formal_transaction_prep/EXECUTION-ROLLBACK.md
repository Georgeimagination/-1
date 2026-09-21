# 执行与回滚合同

## 适用范围

本合同只适用于冻结的 MI455X 245 行签字包。执行器的正常入口是 `scripts/Invoke-MI455XFormalTransaction.ps1`。不带正式授权参数时，目标若等于当前正式根，脚本会在创建结果、候选、备份或目标文件之前拒绝执行。

## 正式执行前置条件

独立复核者先复算冻结包，再在正式根之外建立专用 BackupRoot。该目录不能是正式根、正式根子目录或正式根父目录。结果目录也必须位于 BackupRoot 内。备份按 `formal-backup-manifest-template.csv` 落盘并生成 `MI455X-FORMAL-BACKUP-MANIFEST.csv`：19 张待改表保存 premerge 原件，guard 涉及的 `数据/objects.csv` 与 `数据/object-relations.csv` 也保存原件；另复制 `new-file-targets.csv` 为 `MI455X-NEW-FILE-TARGETS-ABSENT.csv`，复制 `expected-candidate-19-table-posthashes.csv` 为 `MI455X-CANDIDATE-19-TABLE-POSTHASHES.csv`。23 个唯一条目的路径、SHA-256 和字节数都必须与 manifest 一致。

独立签字必须只有一行，字段顺序与模板完全相同。reviewer 必须为 `m2_mi455x_formal_transaction_independent_review`，verdict 为 `accept`，ready 为 `true`，并绑定执行器、preflight、rehearsal、包 manifest、包 aggregate、MI455X 上游签字、rebase freeze manifest、正式基线和授权令牌。准备者不得充当该复核者。

BackupRoot 还须有 `MI455X-FORMAL-TRANSACTION-AUTHORIZATION.txt`，内容精确为以下六项用竖线连接，不加说明文字：授权令牌、独立签字文件 SHA-256、MI455X 上游签字 SHA-256、正式基线 aggregate、包 manifest SHA-256、备份 manifest SHA-256。执行器会在事务开始和提交前重复核验。

## 提交边界

执行器先核正式 aggregate、两份上游签字、冻结清单、19 张表逐表哈希、3 个 guard、3 个新文件不存在状态、包与备份合同。随后在 BackupRoot 的唯一临时目录构造候选副本，重放 242 行受控写集，复制 3 个 payload，并运行完整校验器。候选必须通过 111,040 项检查，19 张待改表逐表后哈希必须与冻结清单一致，32 表 aggregate 必须为 `0d94c60e136fab58941ad8d1f6b5b55a4d2013a370c9a1dc938bd8005fa57bca`。

提交阶段只允许替换 `formal-csv-backup-candidates.csv` 的 19 张表并新建 `new-file-targets.csv` 的 3 个目标。每次移动或复制前先写 journal 注册，完成后再写 complete。正式结果写入 BackupRoot 内；锁位于 BackupRoot 的父目录，事务结束后清理。

## 回滚顺序

任何异常都会先逆序处理已经注册的 payload，再逆序处理已经注册的表。payload 只有在当前哈希仍等于本事务写入哈希时才删除；表从已核验的 premerge 备份恢复。随后必须重新得到正式 aggregate `f152…`，3 个新文件目标全部不存在，3 个 guard 仍与签字哈希一致，正式根中 `.mi455x-txn-*` 临时文件为零。若这些检查任一失败，结果为 `FAIL_ROLLBACK_FAILED`，不能宣称已恢复，必须保留 BackupRoot、journal 和现场交由人工处理。

## 明确禁止

不得编辑冻结包后再沿用旧签字，不得把 BackupRoot 放进正式根，不得预先创建 3 个目标，不得用准备者身份签 `accept`，不得绕过默认拒绝直接手工改表。故障注入环境变量只用于隔离镜像演练，正式执行环境必须为空。
