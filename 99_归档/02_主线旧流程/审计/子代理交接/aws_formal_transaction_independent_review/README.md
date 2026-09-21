# AWS 一次性正式事务独立复核

裁决：`accept`  
执行就绪：`ready_for_formal_execution=true`

这次复核只在外部短路径镜像中运行事务。没有修改正式 32 张表、15 个正式目标、资料卡、网页快照，也没有改动被复核的事务准备包。`accept` 说明冻结事务满足技术执行条件，不等于已经执行；正式合并仍须由总控或用户另行授权，并先按冻结合同建立完整外部备份。

## 签字绑定

最终单行签字是 `formal-execution-accept-signoff.csv`，SHA-256 为 `491df0eb2bc2f7af0e771b966faae482bab235e9cf0fdbfcbbb9b60f8b7813c3`。文件为 UTF-8 无 BOM、CRLF 换行，恰好 1 行、17 列。它绑定：

- transaction：`15664cdc8459ddb6bd34fb9fbecb7cfc00b114af3b4e16fdb6a5d16e9b1ee5a0`；
- preflight：`8efe68087758f9a405257d94bbc67bbaa9e0acdabce094bc7b2b7d345fbdebaa`；
- rehearsal：`88eeb37cf574c63aff3d15f9dd77beb306f3078b7750bcef2a12de869ff1eeb6`；
- 冻结 manifest：`23766423301f258187139cd451fc58b54f76bb3545dbea2833635e5f8651bc5a`；
- package aggregate：`115319f5d187598f18525a05b0d27f8822283278daca29681ac8820858454f0c`；
- 486 行 AWS 签字：`b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3`；
- 内容独立复核：`5709dccd10be494233dd8ced7a7206e151a2fc6d73e34687a8a7c65658b47797`；
- 正式 32 表基线 aggregate：`d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`；
- 授权 token 的 SHA-256：`72763eda2728d2fd687c9f1ddc841adee9c040297e73b2608a73c0f19d864bd6`。

冻结包有 22 个文件。`manifest.csv` 自身不入表，其余 21 个文件逐项哈希和字节数一致，其中 20 个文件进入 package aggregate。复核结束时再次检查，冻结文件 mismatch 为 0。

## 镜像结果

直接运行冻结副本中的 `Test-AwsFormalTransactionRehearsal.ps1`，共通过 352 项检查和 3 个场景。正向场景完成 477 项授权写入、9 个不写守卫和 15 个新文件；候选与写后校验均为 106,160 项。替换 3 张表后注入失败，以及替换 20 张表并复制 4 个 payload 后注入失败，都完成回滚；正式 32 表保持不变，正式 payload 仍为 0，演练临时根被清理。

10 个正式门控负向场景均在写入前拒绝：默认拒绝、错误 token、错误签字 SHA、旧的内容签字、错误正式基线 aggregate、错误 package aggregate、备份不完整、缺授权 marker、marker 不匹配、目标文件预先存在。每个场景都返回非零退出码并命中预期错误，短根内 transaction temp、lock、replacement 和 restore 均为 0。原始输出在 `evidence/`，汇总见 `evidence/independent-scenario-summary.csv`。

复核结束时，正式 32 表逐文件 mismatch 为 0，15 个正式目标仍全部不存在，正式数据校验器以 `subject_contract_mode=gate` 通过 97,920 项检查。被复核包中的 temp、lock、replacement 和 restore 也为 0。

## 正式执行前的必要条件

正式根只有同时满足以下条件才可触达：显式 `-AllowFormalRoot`、精确 token、上述独立签字及其实际 SHA、与签字和备份 manifest 精确对应的授权 marker、完整外部 `BackupRoot`。`BackupRoot` 必须在正式根之外，且清单恰好包含 20 张待写表、9 个守卫涉及的 3 张不同表、15 个目标不存在清单和候选 20 表 posthash 清单，共 25 项。结果目录须位于正式根之外并为空。

得到正式授权并建立备份后，执行命令为：

```powershell
& '<冻结目录>\Invoke-AwsFormalTransaction.ps1' `
  -SourceRoot '<正式资料汇总根>' `
  -TargetRoot '<同一个正式资料汇总根>' `
  -BackupRoot '<外部专用备份根>' `
  -ResultRoot '<外部空结果目录>' `
  -AllowFormalRoot `
  -FormalAuthorizationToken 'AWS-FORMAL-MERGE-20260813-5709DCCD-B9FA7487' `
  -TransactionReviewSignoffPath '<本目录>\formal-execution-accept-signoff.csv' `
  -AuthorizationSignoffSha256 '491df0eb2bc2f7af0e771b966faae482bab235e9cf0fdbfcbbb9b60f8b7813c3'
```

本复核没有运行这条正式命令，也没有创建可用于正式执行的 `BackupRoot` 或授权 marker。正式执行前应重新核对 signoff、冻结 manifest、25 项备份 manifest、正式 aggregate 和 15 个不存在目标；任何一项变化都应停止执行并重新复核。

## 复核过程中的异常

前期出现过几次复核编排错误：命令行过长、短盘符映射不能跨工具进程、PowerShell 参数名与自动变量冲突、手工镜像目录层级写错，以及一次外层 timeout 提前结束父事务。这些都属于复核者的命令构造或运行方式错误，不是沙箱、审批或冻结事务缺陷。相关受控临时目录和锁在确认无活动进程后清理；它们没有触碰正式库。最终裁决只采用从零复制、22 文件哈希一致的冻结包演练和随后完成的门控负向结果。

项目级 `README.md` 和 `AGENTS.md` 已检查，无需修改：本任务只产出子代理独立复核材料，不改变项目范围、正式状态或全局协作约定；正式执行后应由总控统一更新根文档和进度记录。