# AWS 正式事务外置备份构建记录

任务状态：`blocked_at_authorization_marker`  
正式执行备份就绪：`ready_for_formal_execution_backup=false`

外置备份的数据部分已经完成：25 项备份内容齐全，manifest 逐项复算通过。授权 marker 的写入被自动审批拒绝，因此该目录目前不能触发正式事务。本任务没有运行正式合并，也没有改动正式 32 张表、资料卡、网页快照、冻结事务准备包、独立复核包或根目录文档。

## 正式基线预检

正式 32 表 aggregate 重新计算为 `d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`，32 个逐文件哈希 mismatch 为 0。20 张待写表与 3 张不同守卫表的当前哈希均与冻结清单相同；15 个新文件目标全部不存在。

正式数据校验器以 `subject_contract_mode=gate` 通过 97,920 项检查。冻结 preflight 通过 4,324 项检查，结果为 486 行签字、462 次 CSV 行写入、15 个文件 payload、9 个不写守卫，合计 477 次授权写入；这次只运行预检，没有执行事务。

冻结绑定复核如下：

| 项目 | SHA-256 或结果 |
|---|---|
| AWS 486 行签字 | `b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3` |
| 事务独立复核签字 | `491df0eb2bc2f7af0e771b966faae482bab235e9cf0fdbfcbbb9b60f8b7813c3` |
| 冻结事务 manifest | `23766423301f258187139cd451fc58b54f76bb3545dbea2833635e5f8651bc5a` |
| 冻结事务 package aggregate | `115319f5d187598f18525a05b0d27f8822283278daca29681ac8820858454f0c` |
| 冻结 manifest 内容复算 | 21 行，逐项 mismatch 为 0；其中 20 行进入 aggregate |
| 待写表清单 | `196e177d6f9206d6eb059a19442ec118bb33bb04389f75cae4d52c38a6ad0533` |
| 守卫清单 | `77c886d688411a51ad1421326e19fc133576b77ae1e7641d85b7973479639042` |
| 新文件目标清单 | `26d5ad2db57df1ac51b18a7a8f1d3dbb7332b8a7272a7be96004f033712e48e7` |
| 候选 20 表 posthash 清单 | `4188a42de1eafc383a592814330790ebb939d2613756781a3c941611e11857a7` |

## 外置备份内容

备份根为 `C:\Users\Huashuo\AppData\Local\Temp\AWS-FORMAL-BACKUP-M2-W2-20260813`。任务开始时该路径不存在。目录中已经按正式相对路径逐字节复制 20 张待写表和 3 张守卫表；23 份副本与正式源文件的哈希和字节数 mismatch 均为 0。

`new-file-targets.csv` 原样复制为 `AWS-NEW-FILE-TARGETS-ABSENT.csv`，SHA-256 为 `26d5ad2db57df1ac51b18a7a8f1d3dbb7332b8a7272a7be96004f033712e48e7`。`expected-candidate-20-table-posthashes.csv` 原样复制为 `AWS-CANDIDATE-20-TABLE-POSTHASHES.csv`，SHA-256 为 `4188a42de1eafc383a592814330790ebb939d2613756781a3c941611e11857a7`。

`AWS-FORMAL-BACKUP-MANIFEST.csv` 恰有 25 个唯一数据行，列顺序为 `relative_path,sha256,bytes`，UTF-8 无 BOM、CRLF 换行。逐行重算哈希和字节数 mismatch 为 0；manifest 自身 SHA-256 为 `dd94cfbe618272a46242cfa842b936512ecb6f5ccd6c66e710829c538f7a4f8f`，字节数为 2,809。

辅助说明 `README.md` 不在 25 项 manifest 内，SHA-256 为 `545d7371b890e037d162717e6396ca4180c0356c3817bc3daf30f48a6530c8c0`。当前目录共 27 个文件，即 25 项备份内容、1 份备份 manifest 和 1 份说明。`transaction-results` 不存在。

## 未完成的授权步骤

首次创建外置目录时，workspace 沙箱拒绝写入指定的 Windows 临时路径；这是沙箱权限限制。随后提出受限写入申请并获准，目录和数据备份才得以创建。

创建 `AWS-FORMAL-TRANSACTION-AUTHORIZATION.txt` 时，审批系统以“该 marker 会使后续正式事务具备执行授权，而用户尚未明确批准该副作用”为由拒绝。这是自动审批拒绝，不是用户拒绝，也不是模型能力、数据内容或事务脚本错误。按照审批要求，本任务没有重试，也没有采用间接方式生成 marker。

因此，25 项数据备份虽然完整且通过校验，整个 BackupRoot 仍不具备正式执行条件。只有用户明确批准正式合并及授权 marker 的副作用，并且后续审批允许写入后，才能补建 marker。补建前还需再次确认正式 aggregate 未变、15 个目标仍不存在、两份签字和两个 manifest 哈希未漂移。

## 写入边界与项目文档

本任务只写了外置 BackupRoot 和本交接文件。正式事务未运行，正式 32 表 aggregate 在备份完成后复核仍为 `d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`。

根目录 `README.md` 和 `AGENTS.md` 已检查但无需修改：外置备份未取得授权 marker，正式库状态和项目范围都没有变化。检查时两者 SHA-256 分别为 `418e0a7e2b58bfe08e2c63761be004ad4f1ba90c57587ffc7f3c0d674f90f064` 与 `8650a35b6314bb791db2214d53ae82dec691f47b329ec23e521385e5f365d0b6`。
