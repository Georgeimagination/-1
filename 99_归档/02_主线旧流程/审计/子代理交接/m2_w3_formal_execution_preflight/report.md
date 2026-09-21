# M2 第三波三包组合正式执行只读预检

## 裁决

状态为 `accept`，当前 `ready_for_formal_execution=true`。

用户已明确授权这次精确的正式写入及其副作用。外置备份目录中的 `M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt` 已创建；本轮复核确认其六段内容精确匹配，SHA-256 为 `50ab3f2715f76ae98bef6eb0ac57ec22d10761d11a627d54b2c4234d40c9d44b`。事务的数据、签字、脚本、正式基线、外置备份和授权标记全部通过只读检查，当前没有阻断项。

本轮只重验授权和写前状态，没有运行正式事务。正式库仍为合并前状态：32 表聚合哈希为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`，正式校验器通过 106,160 项检查，15 个新文件目标均不存在，正式写入次数为 0。

这里的 PK 是 primary key，即结构化表主键；SHA-256 是用于核对文件内容是否逐字节一致的摘要；`journal` 是执行器使用的事务日志字段名。

## 冻结事务边界

这次授权范围固定为 `formal_execution_of_exact_1057_rows_15_payloads_via_bundle_transaction_v1`，只包括 MI455X、MI350P 和 Ascend 950 三包在 f152 基线上的组合事务。它会写入 1,057 个唯一生命周期 PK，替换 20 张正式 CSV（逗号分隔值表），并新建 15 个资料卡、快照或 PDF 文件；另有 11 个保护项，只核对不写入。

组合准备包 `manifest.csv` 有 75 个成员，逐项哈希和字节数均匹配。清单 SHA-256 为 `efdb763a24c0e97fd483735bba5d68dd01f0768553f963988436efa933ebbaba`，成员聚合值为 `958e1b5106b6c42ae116fe643b3b8ec63a190cc20951654380d86c45a2ad332f`。执行器、严格预检和演练脚本的 SHA-256 分别为：

- `a0c44ca7a7c6bd5925083efc6e4230b5832f34dd7622ea69a8e4bb1ed312a5c5`；
- `f468031dd8660c423b9f5c118dcb9a6091f08d7e5325c154d017c2ec68608160`；
- `a4276f4b143a747c2f047107e6adf1700f0e9645548b53f00dc22156a3587058`。

三份脚本均通过 PowerShell 5.1 语法解析。独立复核签字只有一行、19 列，裁决为 `accept / true`，SHA-256 为 `2291a5c77c3b4fef6a94488a4f3b76cbf1df092230a279292a7246d03efa6e5c`。签字绑定的授权令牌摘要为 `7c2902c416f246f9f13e0462599d87f12805e6387de21810df20c140153a7a3a`，与执行器中的精确令牌一致。

本轮重新运行严格预检，通过 9,656 项检查：1,057 个写入主键、20 张写表、15 个新文件目标、11 个保护项和六份上游签字全部匹配，三包之间的写入主键、载荷路径和保护项主键交集均为 0。候选 20 表后哈希清单的 SHA-256 为 `78956df9394146d39ded5e6e0740157e4ccd9cc50e44699ec6f8b8eca0ea1394`；它重构出的 32 表候选聚合值为 `5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a`，候选预期通过 125,619 项检查。

## 外置备份和授权标记

外置备份目录是：

`D:\Workspace\2026projects\m2w3-bundle-formal-backup-20260813-f152`

该目录不等于正式项目根，也不位于正式项目根之内或包含正式项目根。`M2W3-BUNDLE-FORMAL-BACKUP-MANIFEST.csv` 有 24 个唯一条目：20 张待改表的合并前原件、2 张保护表、1 份 15 目标不存在清单和 1 份候选 20 表后哈希清单。24 项的哈希和字节数全部匹配，清单自身的 SHA-256 为 `cff6755cbdd5b24ee4cda2c025ee65ab8ccfd041f47cf5b4c1fb8ab079fd255e`。

目录中的 7 项授权输入已按用户的精确授权刷新并全部匹配，授权输入清单 SHA-256 为 `31e138af1b9058c07b54240f379582eb4f88d1b985e2b7851e2e90e0cf243541`。当前没有 `transaction-results`，没有事务锁，也没有 `.tmp-m2w3-bundle-formal-*` 临时目录；两个故障注入环境变量均为空。

执行器要求的授权标记现位于上述外置备份目录，文件名为 `M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt`。本轮读取到的内容精确为下面这一行，六段均与当前签字、上游绑定、f152 基线、准备包清单和 24 项备份清单匹配：

```text
M2W3-BUNDLE-FORMAL-MERGE-20260813-F1520907-5F62191B|2291a5c77c3b4fef6a94488a4f3b76cbf1df092230a279292a7246d03efa6e5c|ac52660a807e67da48479f14bf90e65d596c5727b8c9c49cdbce3baa4e819bdb|f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10|efdb763a24c0e97fd483735bba5d68dd01f0768553f963988436efa933ebbaba|cff6755cbdd5b24ee4cda2c025ee65ab8ccfd041f47cf5b4c1fb8ab079fd255e
```

## 正式命令

下面是本次冻结事务的精确执行命令。用户授权、授权标记和写前重验现在都已满足；本轮任务边界仍是只读重验，因此本代理没有运行该命令。正式执行应由总控在同一连续操作窗口内使用，不得修改参数。

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_w3_bundle_formal_transaction_prep\scripts\Invoke-BundleFormalTransaction.ps1' `
  -SourceRoot 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总' `
  -TargetRoot 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总' `
  -BackupRoot 'D:\Workspace\2026projects\m2w3-bundle-formal-backup-20260813-f152' `
  -AllowFormalRoot `
  -FormalAuthorizationToken 'M2W3-BUNDLE-FORMAL-MERGE-20260813-F1520907-5F62191B' `
  -AuthorizationSignoffSha256 '2291a5c77c3b4fef6a94488a4f3b76cbf1df092230a279292a7246d03efa6e5c' `
  -TransactionReviewSignoffPath 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_w3_bundle_formal_transaction_independent_review\formal-execution-signoff.csv' `
  -ResultRoot 'D:\Workspace\2026projects\m2w3-bundle-formal-backup-20260813-f152\transaction-results'
```

`ResultRoot` 必须位于外置备份目录内，并在执行前不存在或为空。执行器会把候选和提交前临时副本建在外置备份目录的 `.tmp-m2w3-bundle-formal-<GUID>` 中；不能把候选、临时副本或结果目录建在正式项目根。锁文件也位于外置备份目录，当前正式根对应的文件名为 `M2W3-BUNDLE-FORMAL-TRANSACTION-LOCK-d347d957e1fb163d.lock`。

## 写前验收

本轮刚完成以下五组写前检查，结果均通过。若正式命令不在同一连续操作窗口内执行，执行者必须重新检查；任一项不通过就停止，不创建候选，也不尝试修补后继续执行。

1. 正式校验器仍通过 106,160 项检查，32 表聚合仍为 f152；20 张写表的逐表哈希和字节数仍等于合并前清单。
2. 1,057 个目标 PK 在正式表中仍不存在；15 个新文件目标仍全部不存在；11 个保护项的主键、规范行哈希和两张保护表文件哈希仍匹配。
3. 准备包的 75 个成员、成员聚合值、三份核心脚本、六份上游签字、独立复核签字、20 表候选后哈希清单及其 5f6219 候选聚合均与本报告记录一致。
4. 外置备份清单仍恰好有 24 个唯一条目，24 项逐文件哈希和字节数都匹配；7 项授权输入仍匹配；授权标记六段内容与当时文件的实际哈希精确一致。
5. `M2W3_BUNDLE_TEST_FAIL_AFTER_REPLACEMENTS` 和 `M2W3_BUNDLE_TEST_FAIL_AFTER_PAYLOADS` 两个进程环境变量为空；`transaction-results` 不存在或为空；锁文件、替换临时文件、恢复临时文件和事务临时目录均不存在。

## 执行中和写后验收

执行器只取得一把排他锁，并把事件持续写入同一本 `commit-rollback-journal.csv`。它从 f152 复制 32 表到外置候选，重放 1,057 行并复制 15 个候选载荷；候选必须通过 125,619 项检查，32 表聚合必须等于 5f6219，20 张写表的逐表哈希也必须与冻结清单一致。通过这些门后，脚本才会依次替换 20 张正式表，再复制 15 个正式载荷。

成功状态必须同时满足：`transaction-outcome.json` 为 `PASS` 且 `rollback_used=false`；正式校验器通过 125,619 项；正式 32 表聚合为完整的 `5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a`；20 张写表逐表等于候选后哈希；15 个新文件存在且各自哈希匹配；11 个保护项没有变化；journal 包含完整的 20 次表提交和 15 次载荷提交；锁、事务临时目录、替换临时文件和恢复临时文件均为 0。`transaction-results`、外置备份、授权标记和 journal 要作为持久证据保留，不能在验收前清理。

如果脚本报告 `FAIL_ROLLED_BACK`，必须确认正式聚合恢复到 f152、15 个新文件目标重新全部不存在、20 张表恢复到合并前哈希、11 个保护项仍匹配、正式校验器恢复为 106,160 项，并保留结果目录和 journal 供独立复核。若报告 `FAIL_ROLLBACK_FAILED`，立即停止自动重试，不删除外置备份、锁旁证、结果目录或现场文件，转入人工恢复。

## 检查边界

本轮只在 `审计/子代理交接/m2_w3_formal_execution_preflight/` 写入预检证据。根 `README.md` 和 `AGENTS.md` 已只读检查；正式数据状态、项目范围、目录职责和运行约定均未改变，因此不修改这两份文档。

前一轮曾有一次跨 `D:\Workspace\2026projects` 的递归定位命令以退出码 1 结束且没有返回诊断，分类为工具或运行时失败；后续已改用准备包登记的外置路径完成检查。授权标记此前因缺少精确用户授权遭自动审批拒绝；用户现已明确授权，标记已成功创建并通过本轮复核。两项历史事件都没有影响正式库，本轮没有新的用户拒绝、审批失败、沙箱拒绝或远程服务错误。