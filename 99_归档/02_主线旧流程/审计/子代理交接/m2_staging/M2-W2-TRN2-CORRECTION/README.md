# M2-W2 Trainium2 正式数据修复与三实例包重做

状态：`ready_for_independent_review`

本目录只保存待独立复核的修复包，不直接修改正式 32 表、正式资料卡或全局状态文档。修复范围包括 Trainium2（AWS 第二代训练加速器）M1 历史事实污染、Elastic Fabric Adapter（EFA，弹性网络适配器）字段归类、S07 来源复核记录，以及 `trn2.3xlarge`、`trn2.48xlarge`、`trn2u.48xlarge` 三张实例资料卡。

## 输入与冻结边界

输入为 `审计/子代理交接/m2_review_trn2_instance.md`、被拒包 `M2-W2-TRN2-INSTANCE`、当前正式 32 表和 M1 Trainium2 试填卡。被拒包保持原样。本目录通过同表头 overlay、显式主键清单、卡片替换候选、固定快照复制候选和验证记录表达全部拟议变更。只有独立复核通过后，主代理才能正式合并。

基线是 Helios 合并后的静止正式库：75 个对象、24 条关系、632 条事实、622 条逐来源断言、803 条字段要求；官方校验通过 93,799 项检查。`baseline-hashes.csv` 固定全部 32 张表，验证结束时 32 张表哈希全部不变。

## 包的组成

`operation-manifest.csv` 有 196 行：188 行同表头 delete、update 或 append，另有 8 个文件 create/replace。`lifecycle-manifest.csv` 单列 17 行需要独立签字的状态动作。`file-copy-plan.csv` 记录 S07 固定网页、五张卡片和两张映射表的正式目标与哈希。

三张实例卡映射 41 条事实，按对象为 4/20/17，按来源为 S06=32、S07=5、S09=1、S10=1、S15=2。正向最小来源集以 39 条可采纳事实为分母；S15 两条声明留作未裁决冲突和来源质量审计，不进入最小集。

## 修复要点

S10 只保留芯片 FP8 与 `trn2.48xlarge` FP8 两条历史事实，删除其余十条无直接支持的扩写及对应冲突链。芯片 BF16、FP16、TF32 当前事实仍属于 `CG-AWS-TRN2-007-*` 的范围冲突；`trn2.48xlarge` 的 FP8 历史冲突继续保留。

`trn2.3xlarge` 芯片数改由 S07 Product details 表支持。三条实例 EFA 事实使用每实例注入带宽，UltraServer 12.8 Tbps 使用系统聚合带宽。原 UltraServer 3.2 Tbps 事实整条删除，因为 S06 的 3,200 Gbps 实际属于两个 48xlarge 实例列，不是可换字段保留的系统事实。

S07 保留原 source ID、版本标签和内容指纹，只更新 2026-08-13 复核日期与 nonce 归一化等价说明；新固定入口指向拟正式路径，不依赖 staging。

## 验证与下一步

包内表头、主键、数量和语义检查均通过。完整 correction 在隔离副本应用后，官方校验通过 93,131 项检查；隔离副本最终清理。验证记录见 `validation/validation-report.md`，备份与回滚方案见 `backup-plan/rollback-plan.md`，独立复核交接见 `handoff.md`。

下一步由未参与编写者复核本包，并对 `lifecycle-manifest.csv` 单独签字。复核通过前不得把 overlay、卡片或 S07 快照写入正式路径。