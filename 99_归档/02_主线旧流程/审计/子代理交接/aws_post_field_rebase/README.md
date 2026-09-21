# AWS 字段主体合同迁移后重签与演练

复核日期：2026-08-13  
裁决：`accept`  
正式执行：`forbidden_in_this_package`

## 裁决

AWS 四代物理对象事实包可以进入下一道独立复核，但本目录不授权写正式库。字段主体合同迁移改变了正式基线，也已经先行满足 AWS 包提出的 `FIELD-PHY-CLOCK` 合同变更。旧签字中的 `AWS-SIGN-0458` 因此撤销 `exact_cell_write`，改成当前 `数据/fields.csv` 的整行不写守卫。

新签字 `aws-signoff-post-field-rebase.csv` 仍有 486 行，组成是 477 个写授权和 9 个 `no_write_guard`；没有 `exact_cell_write`。SHA-256 为：

`b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3`

当前正式 32 表聚合 SHA-256 独立复算为：

`d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`

## FIELD-PHY-CLOCK 重叠项

字段主体合同迁移后，`数据/fields.csv` 有 13 列。`FIELD-PHY-CLOCK.allowed_subject_kinds` 已是 `object;component`，`allowed_requirement_target_kinds` 为 `object;component;precision_path`。AWS 冻结包里的 `structured/fields.csv` 仍是历史 12 列文件；它没有要求目标合同列。

继续执行旧写入会重复改一个已经满足的单元格，而且无法保护新增列。新签字把这项改成 `true_already_satisfied_full_row_guard`。严格合并器会核对当前 13 列表头、两个合同值以及完整行哈希；AWS 生命周期写集也不得包含 `数据/fields.csv`。因此，冻结 staging 的 12 列文件不会覆盖正式 13 列表。

重叠裁决的机器可读记录在 `field-contract-overlap-adjudication.csv`。Google 来源门合并后的旧重签版与本版的逐单元格差异在 `prior-to-new-cell-diff.csv`。除基线哈希、逐表预合并哈希、全部 notes 和 `AWS-SIGN-0458` 的五个裁决字段外，没有其他授权语义变化。

## 严格演练

`Invoke-AwsPackageMerge.ps1` 默认拒绝把 SourceRoot 当 TargetRoot；目标必须是带固定标记的隔离目录。它先检查签字 SHA、冻结包 76 条 manifest、457 条生命周期绑定、32 表基线聚合、逐表预合并哈希、39 个唯一来源文件、15 个缺失目标以及 9 条不写守卫，全部通过后才写隔离副本。CSV 保持 UTF-8 无 BOM、CRLF；11 个快照和 4 张资料卡逐字节复制，目标存在即停。

`Test-AwsPackageMergeRehearsal.ps1` 的三类结果如下：

| 场景 | 结果 | 写入边界 |
| --- | --- | --- |
| 字段迁移前的旧重签版用于当前基线 | 退出码 1，在签字 SHA 门拒绝 | 32 表零变化 |
| 预先放入一张授权资料卡 | 退出码 1，在文件目标预检拒绝 | 32 表零变化；哨兵文件未变；快照未复制 |
| 新签字用于隔离当前基线 | 退出码 0 | 477 个写授权执行，9 个守卫通过 |

演练器通过 372 项检查，合并器通过 25,467 项检查。隔离结果通过当前默认 `gate` 模式校验器，共执行 106,160 项检查；结果为 78 个对象、27 条对象关系、678 条事实、680 条断言、863 条字段要求、40 张资料卡、8 个来源选择运行和 96 个选择成员。

演练前后，正式 32 表哈希全部不变；临时目录数量为 0。正式库当前校验仍为 97,920 项，独立合并后的更高检查数来自 AWS 新增事实链和来源链。

## 输入与冻结关系

本轮完整读取任务指定的八组输入，共记录 150 个文件，见 `input-read-audit.csv`。AWS 原冻结包的三项绑定没有改变：

- 77 文件 aggregate：`46fd41d8b19a82dc22c24ddee5c1b4e3534cacfe56bc4258cd1c9756ed67b552`；
- freeze manifest SHA-256：`74fe487790a0d2fbcaf012c1d60b409fd065dad5480a769843c28dab070036c4`；
- 457 行生命周期候选 SHA-256：`f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880`。

字段迁移前后变化的三张正式表及行列计数记录在 `post-field-baseline-table-diff.csv` 和 `post-field-baseline-change-audit.csv`。新基线逐表哈希记录在 `formal-baseline-hashes.csv`；演练后实测哈希记录在 `formal-baseline-after-rehearsal.csv`，32 行逐一相同。

## 文件职责

- `Build-AwsPostFieldRebase.ps1`：重建新签字、输入读取审计和字段重叠裁决；已有签字时默认拒绝覆盖。
- `aws-signoff-post-field-rebase.csv`：绑定字段迁移后新基线的 486 行签字。
- `Invoke-AwsPackageMerge.ps1`：参数化隔离合并器；只能写带标记的独立目标根。
- `Test-AwsPackageMergeRehearsal.ps1`：执行旧签字拒绝、预置目标拒绝和正向演练，并清理临时根。
- `validation-summary.json`、三份运行输出和 `formal-hash-integrity.csv`：保存本轮执行证据。
- `rebase-binding.json`：保存旧签字、字段迁移、新基线和新签字的绑定。

## 后续门槛

本包由同一代理生成新签字并完成演练，尚未形成独立于作者的最终签字。下一步应由另一代理复核 486 行签字、字段整行守卫、三类运行输出、正式 32 表不变和目录 manifest。独立裁决为 `accept` 后，总控才能另建正式合并备份并决定是否执行。`README.md`、`AGENTS.md`、正式资料卡和正式 32 表均不在本子任务写入范围内。