# M2-W2-TRN2-CORRECTION 交接

状态：`ready_for_independent_review`

## 任务与边界

本包修复 Trainium2 M1 中十条无直接支持的 S10 历史事实、`trn2.3xlarge` 芯片数错挂来源、Elastic Fabric Adapter（EFA，弹性网络适配器）带宽字段语义，以及由这些问题造成的冲突、要求和资料卡漂移。被拒的 `M2-W2-TRN2-INSTANCE` 包未改动；正式 32 表、正式资料卡和全局项目文档也未改动。

## 主要结果

拟删除 11 条事实：十条 S10 污染和一条 UltraServer 3.2 Tbps 错主体事实。与其对应的 12 条断言、11 条要求、11 个条件集、11 个冲突组和 22 个冲突成员也显式删除。UltraServer 3.2 采用“删除事实”而不是“换字段”，因为 S06 的 3,200 Gbps 位于 `trn2.48xlarge` 与 `trn2u.48xlarge` 实例列，不能转写为 UltraServer 系统事实。

三张实例卡映射 41 条事实，分布 4/20/17。39 条可采纳事实的最小来源为 S06、S07、S09、S10；S15 两条容量声明继续留作未裁决冲突和质量审计链。M1 试填卡与 Trainium2 架构卡候选也同步修正。

## 交付入口

- `operation-manifest.csv`：196 行确定性操作清单；
- `overlay/`：与正式表同表头的 188 行 delete、update 和 append；
- `file-copy-plan.csv`：8 个固定文件的 create/replace、目标路径和哈希；
- `lifecycle-manifest.csv`：17 行状态动作，独立签字仍为 pending；
- `baseline-hashes.csv` 与 `baseline-card-hashes.csv`：正式合并前基线；
- `cards/`：三张实例卡、M1 试填卡和架构卡候选；
- `sources/`：41 行卡片映射、修复后的架构复用映射和来源选择说明；
- `fixed-candidates/`：S07 的 2026-08-13 固定网页；
- `scripts/Apply-Correction.ps1`：只应先用于隔离副本；
- `backup-plan/rollback-plan.md`：正式合并的备份与精确回滚方案；
- `validation/validation-report.md`：结构、语义、临时合并与正式库保护证据。

## 验证结论

当前正式库校验通过 93,799 项，隔离应用后校验通过 93,131 项。正式 32 表在验证前后哈希全部不变。包内语义检查通过，S10 只保留两条 FP8 历史事实，UltraServer 3.2 错主体链无残留，EFA 字段和值、S07 断言、41/39 计数和最小集成员均符合修复要求。

## 独立复核重点

复核者应先核对 `operation-manifest.csv` 与全部 overlay 主键，再抽查 S10 原文、S06/S07 表格主语、四条保留 EFA 事实和 S15 未裁决措辞。之后复跑隔离应用与官方校验器，并对 `lifecycle-manifest.csv` 的 17 行状态动作单独签字。只有这些步骤通过，主代理才能按备份方案正式合并。