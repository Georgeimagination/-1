# 字段主体合同正式迁移备份

本目录保存字段主体合同迁移前的正式数据与项目文档。字段主体合同用于区分“事实可以挂在哪类对象上”和“资料卡缺口可以在哪类对象上登记”，迁移后两套约束由不同列管理。

## 备份范围

`backup-manifest.csv` 记录 10 个文件的原路径、备份路径、字节数和 SHA-256。其中 4 个 `formal_premerge_backup` 文件是正式迁移的可回滚对象；6 个 `project_doc_preupdate_backup` 文件用于保留本次状态文档更新前的版本。清单中的 `verified=true` 表示复制后已逐文件核对大小和哈希。

迁移授权来自两组冻结材料：

- 修正版：`审计/子代理交接/field_subject_contract_remediation/`
- 独立复核：`审计/子代理交接/field_subject_contract_remediation_independent_review/`

独立复核裁决为 `accept`，并把 166 个允许变化的单元格写入 `formal-migration-accept-signoff.csv`。迁移前技术预检通过 22,536 项检查。

## 回滚边界

如果正式迁移后的校验失败，只恢复以下 4 个文件：

1. `数据/schema-columns.csv`
2. `数据/fields.csv`
3. `数据/field-requirements.csv`
4. `scripts/validation/Validate-ResearchData.ps1`

恢复后必须重新运行正式校验器，并核对 `数据/facts.csv`、`数据/enums.csv` 以及预检清单中的其余禁止写入文件没有变化。项目文档备份不参与自动回滚；是否恢复，应根据正式数据最终处于迁移前还是迁移后状态决定。

## 验证说明

本目录不是新的正式数据源，也不参与资料卡或最小参考资料库的统计。正式迁移结果、实际哈希和校验结果记录在 `审计/字段主体合同正式迁移验收.md`。
