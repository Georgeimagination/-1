# MI455X 新基线重签交接

> 状态：`complete / accept`  
> 日期：2026-08-13  
> 对象：`M2-W3-AMD-MI455X-MODULE`  
> 写入边界：仅本目录；正式库、原暂存包和项目级文档只读

本目录记录 AWS（Amazon Web Services）四代物理对象事实包正式合并后，MI455X 模组包在新正式基线上的只读重签。新签字包含 242 个结构化主键和 3 个文件动作，SHA-256 为 `196863031761221d825309387c563553187b0ee23630002aeaeed57bbbd6084c`。当前基线临时合并在 `gate` 硬门模式通过 111,040 项检查，正式 32 表运行前后均保持 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`。本任务没有执行正式合并。

主要产物：

- `formal-32-current-baseline.csv` 和 `.json`：当前正式 32 表逐文件哈希与基线摘要；
- `formal-change-scope.csv`：旧基线到当前基线的逐文件变化；
- `pk-conflict-audit.csv`：242 个结构化主键的冲突检查；
- `target-file-guard-audit.csv`：3 个目标文件的存在性和来源哈希检查；
- `temporary-merge-fresh-pass.json` 与 `temporary-validator-output.txt`：新鲜临时合并结果；
- `temporary-merge-attempt-history.csv` 与 `operator-error-log.csv`：失败分类和修正记录；
- `m2_mi455x_rebase_signoff.csv`：新基线精确签字；
- `old-to-rebase-signoff-cell-audit.csv` 和 `old-to-rebase-signoff-cell-diff.csv`：6,125 个单元格审计及 1,225 个变化；
- `rebase-signoff-validation.json`：签字结构、交集、文件门和单元格差异总体验证；
- `rebase-freeze-manifest.csv`：61 行重签冻结清单；
- `report.md`：裁决、证据、故障分类和正式合并边界。

冻结清单不包含 `report.md` 和本 README，避免报告引用清单哈希时形成自引用。报告与 README 通过独立哈希交付。