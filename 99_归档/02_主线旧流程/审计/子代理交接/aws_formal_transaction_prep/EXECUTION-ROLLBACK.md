# 执行与回滚说明

这份说明面向独立复核者和以后获得明确授权的正式执行者。当前状态只允许镜像复核，不允许本任务代理在正式根执行。

## 先完成独立复核

复核者应先核对 `manifest.csv` 和 `package-aggregate.txt`，再在受控镜像运行 `Test-AwsFormalTransactionRehearsal.ps1`。三种场景都要通过：完整正向提交、替换 3 张表后注入失败、替换全部 20 张表并复制 4 个 payload 后注入失败。正向结果应为 477 次授权写入、9 个守卫，候选与写后校验器均为 `106160` 项。

复核通过后，在冻结目录之外创建一行事务签字。表头必须与 `transaction-review-signoff-template.csv` 完全相同，不能多列或少列；`transaction_review_id`、`package_id`、复核者身份、日期、授权范围、三份脚本哈希、manifest 哈希、package aggregate、两份 AWS 签字、正式基线和 token 哈希都必须精确填写。`verdict` 必须为 `accept`，`ready_for_formal_execution` 必须为 `true`。模板本身写的是 `pending/false`，不能用作授权。

## 外部备份根

正式执行前要在正式根之外新建专用 `BackupRoot`。它不能等于正式根、位于正式根内，也不能把正式根包含在内。备份清单恰好包含 25 行：

1. 按原相对路径保存 `formal-csv-backup-candidates.csv` 列出的 20 张待写 CSV；
2. 按原相对路径保存 9 个守卫所涉及的 3 张不同 CSV；
3. 把 `new-file-targets.csv` 原样保存为 `AWS-NEW-FILE-TARGETS-ABSENT.csv`；
4. 把 `expected-candidate-20-table-posthashes.csv` 原样保存为 `AWS-CANDIDATE-20-TABLE-POSTHASHES.csv`。

`AWS-FORMAL-BACKUP-MANIFEST.csv` 对这 25 个文件记录相对路径、SHA-256 和字节数。正式执行脚本会逐项重算，并确认 20 张表和 3 张守卫表仍等于当前签字基线，15 个新文件在正式根仍不存在。

备份验证通过后，写入 `AWS-FORMAL-TRANSACTION-AUTHORIZATION.txt`。该文件只有一行，按下式用半角竖线连接，不加引号：

```text
精确token|事务独立复核签字实际SHA-256|AWS签字SHA-256|正式32表基线aggregate|冻结manifest的SHA-256|外部备份manifest的SHA-256
```

精确 token 为 `AWS-FORMAL-MERGE-20260813-5709DCCD-B9FA7487`。它是一次性授权绑定值，不是密码；缺少独立事务签字、完整外部备份或 marker 时，单独提供 token 仍会被拒绝。

## 正式命令合同

只有总控或用户另行明确授权后，正式执行者才能填写以下参数。`ResultRoot` 必须位于正式根之外；省略时脚本使用 `BackupRoot\transaction-results`，且该目录必须为空。

```powershell
& '<冻结目录>\Invoke-AwsFormalTransaction.ps1' `
  -SourceRoot '<正式资料汇总根>' `
  -TargetRoot '<同一个正式资料汇总根>' `
  -BackupRoot '<外部专用备份根>' `
  -ResultRoot '<外部空结果目录>' `
  -AllowFormalRoot `
  -FormalAuthorizationToken 'AWS-FORMAL-MERGE-20260813-5709DCCD-B9FA7487' `
  -TransactionReviewSignoffPath '<冻结包外的最终单行事务签字.csv>' `
  -AuthorizationSignoffSha256 '<该签字文件的实际SHA-256>'
```

脚本先完成全部授权和备份验证，再创建外部结果目录、外部事务临时目录和原子互斥锁。候选 20 表写后哈希必须与冻结清单完全一致。提交前还会重核完整 32 表 aggregate 和 9 个守卫。

## 自动回滚与人工恢复

事务在替换前先登记表路径，在复制新 payload 前也先登记路径。失败时先逆序处理 payload，再逆序恢复已经登记的表。payload 当前哈希一旦偏离签字预期，脚本不会删除它，而是报 `FAIL_ROLLBACK_FAILED`；这是严重恢复事件，不能把它误记为普通回滚成功。

正常回滚结束后，20 张表必须恢复到原哈希，15 个目标必须全部不存在，32 表 aggregate 必须回到 `d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`。3 张守卫表会与原哈希和外部防御备份双重核对。守卫不是本事务写集合，若它们漂移，脚本只报警，不自动覆盖；只有在独立事故核查确认恢复对象和责任后，才可使用外部备份人工恢复。

成功或失败都会把候选 posthash、journal、预检、replay、validator 和结果 JSON 留在外部结果目录。事务临时目录、锁以及 20 张表旁的 replacement/restore 临时文件应为 0。强制结束 PowerShell 进程可能绕过 `finally`，此时必须先确认没有活动执行者，再由人工删除确属本事务的外部锁和临时目录。回滚删除文件后可能留下空父目录；这些目录不含 payload，但复核记录应说明并按授权范围处理。