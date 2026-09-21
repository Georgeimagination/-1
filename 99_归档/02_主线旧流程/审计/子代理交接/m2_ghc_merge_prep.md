# M2-GHC-ARCH 正式合并准备

生成日期：2026-08-12  
范围：只读核对 `审计/子代理交接/m2_staging/M2-GHC-ARCH/` 与当前正式库。本文是总控机械合并清单，不表示已经合并。

## 当前判断

独立复核最终裁决为 `accept`。四个架构对象已经存在于正式 `数据/objects.csv`，本包没有 `objects.csv`，合并时不得重复导入对象。24 张 staging CSV 的主键与当前正式同表均无碰撞；35 条 staged facts 中没有寒武纪 MLUarch05 新事实，`FACT-CAMBRICON-MLUARCH05-OFFICIAL-NAME` 与 `FACT-CAMBRICON-MLU590-MLUOPS-BUILD-TARGET-67B3707F` 继续复用正式行，不得再次追加。

本报告尚在补齐正式资料路径、四项清单更新和依赖顺序；最终版会列明每个文件的源路径、目标路径、哈希和不可改字段。

## 24 张 CSV 映射

| staging 文件 | 正式路径 | 数据行数 | 当前正式行数 | 同表主键碰撞 |
|---|---|---:|---:|---:|
| `card-completeness.csv` | `数据/card-completeness.csv` | 36 | 27 | 0 |
| `components.csv` | `数据/components.csv` | 27 | 35 | 0 |
| `condition-sets.csv` | `数据/condition-sets.csv` | 0 | 115 | 0 |
| `conflict-groups.csv` | `最小参考资料库/conflict-groups.csv` | 0 | 26 | 0 |
| `conflict-members.csv` | `最小参考资料库/conflict-members.csv` | 0 | 53 | 0 |
| `derived-inputs.csv` | `数据/derived-inputs.csv` | 0 | 45 | 0 |
| `derived-metrics.csv` | `数据/derived-metrics.csv` | 0 | 23 | 0 |
| `fact-assertions.csv` | `最小参考资料库/fact-assertions.csv` | 35 | 239 | 0 |
| `facts.csv` | `数据/facts.csv` | 35 | 253 | 0 |
| `field-requirements.csv` | `数据/field-requirements.csv` | 80 | 265 | 0 |
| `links.csv` | `数据/links.csv` | 2 | 10 | 0 |
| `memory-levels.csv` | `数据/memory-levels.csv` | 8 | 11 | 0 |
| `precision-paths.csv` | `数据/precision-paths.csv` | 8 | 38 | 0 |
| `requirement-evidence.csv` | `最小参考资料库/requirement-evidence.csv` | 3 | 13 | 0 |
| `search-log.csv` | `最小参考资料库/search-log.csv` | 43 | 73 | 0 |
| `search-results.csv` | `最小参考资料库/search-results.csv` | 43 | 40 | 0 |
| `source-coverage.csv` | `最小参考资料库/source-coverage.csv` | 1 | 6 | 0 |
| `source-endpoints.csv` | `最小参考资料库/source-endpoints.csv` | 12 | 46 | 0 |
| `source-families.csv` | `最小参考资料库/source-families.csv` | 11 | 25 | 0 |
| `sources.csv` | `最小参考资料库/sources.csv` | 11 | 26 | 0 |
| `source-screening.csv` | `最小参考资料库/source-screening.csv` | 11 | 26 | 0 |
| `source-selected-roles.csv` | `最小参考资料库/source-selected-roles.csv` | 10 | 28 | 0 |
| `special-capabilities.csv` | `数据/special-capabilities.csv` | 10 | 24 | 0 |
| `topologies.csv` | `数据/topologies.csv` | 1 | 3 | 0 |

空表只保留表头，不执行追加。其余 19 张表共 379 个 staging 主键行。

## 待补核对

- 两份 Groq PDF 的正式 `论文/` 路径及四项清单、资料池基线更新。
- 五个 HTML 快照的正式路径和 endpoint `local_path` 替换。
- 四张卡去除 staging 状态文字后的正式路径，以及实现对象待办的长期追溯位置。
- `review_status` 的正式转换规则和全局最小来源选择重跑安排。
- 与其他 M2 staging 包的跨包 ID 碰撞复核。