# Trainium2 结构化暂存说明



> 总控验收状态：本批次已于 2026-08-12 合并到正式表；本目录保留为可复查的交接快照。

本目录最初是 `Trainium2_试填草稿.md` 的待合并数据。它只使用试填卡和原交接中已经列出的证据，没有新增检索，也没有改动全局 CSV。对象沿用全局库中的 7 个正式 ID，因此这里不重复提交 `objects.csv` 和 `object-relations.csv`。



## 文件与行数



| 文件 | 数据行 |

|---|---:|

| `components.csv` | 20 |

| `condition-sets.csv` | 81 |

| `conflict-groups.csv` | 22 |

| `conflict-members.csv` | 49 |

| `derived-inputs.csv` | 30 |

| `derived-metrics.csv` | 15 |

| `fact-assertions.csv` | 164 |

| `facts.csv` | 179 |

| `field-requirements.csv` | 196 |

| `links.csv` | 8 |

| `memory-levels.csv` | 7 |

| `precision-paths.csv` | 22 |

| `search-log.csv` | 14 |

| `source-endpoints.csv` | 30 |

| `source-families.csv` | 15 |

| `sources.csv` | 15 |

| `source-screening.csv` | 15 |

| `source-selected-roles.csv` | 21 |

| `special-capabilities.csv` | 15 |

| `topologies.csv` | 3 |



## 录入边界



已录入计算引擎、精度路径、片上与 HBM 存储、DMA、特殊能力、互联、拓扑、实例聚合规格、来源版本、访问入口、逐事实断言、筛选角色、字段要求和派生关系。15 个来源版本中，S1 至 S14 是最小来源候选；S15 是产生容量冲突的 EC2 通用规格表，只作 `rejected_unreliable` 的冲突与质量审计证据。总控已从 AWS 官方检索定位 S15，并在 2026-08-12 复核全部 15 个网页入口。每个来源都保存了原始 HTML 快照，位于 `最小参考资料库/快照/AWS/Trainium2/2026-08-12/`；`sources.csv` 使用对应文件的 SHA-256，30 个 endpoint 分为 15 个官方网页入口和 15 个本地快照。



未公开或未找到的数据没有补零。SBUF/PSUM 数值带宽、物理累加器和乘积位宽、NeuronLink 每接口速率与延迟、拓扑对分带宽、芯片工艺/面积/晶体管/功耗/封装，以及专用 sort、sampling 物理模块，都留在 `field-requirements.csv`；对应 `not_found` 行带有试填阶段的检索记录。



## 冲突处理



六类冲突均保留为候选事实和 `unreviewed` 冲突组，没有填写 preferred fact：芯片总值与 8 倍单核值、CC-Core 数量 16/20、当前与历史稀疏值、UltraServer 状态、UltraServer EFA 统计范围，以及 EC2 通用表的容量/器件错误。为保证不同精度路径可独立追溯，算力和稀疏冲突按精度与对象拆成多个冲突组；它们仍属于上述六类问题。



## 合并检查



合并时先检查 ID 是否与全局库新增内容碰撞，再确认 7 个正式对象及 staging 使用的 5 条对象关系仍存在。总控补齐网页快照、S15 入口、Trainium2 首次公布日期，并把“芯片直值与 8×每核派生值”的分组改为 `scope_disagreement`。在已合并 H100 数据的正式库临时副本中复测后，当时的验证结果为 `PASS`，共执行 35,089 项检查，退出码为 0；本批次据此合并。合并后又完成芯片/每核路径分层、冲突拆分和最小集复核，最新结果见根目录状态文件。



反向移除预检显示，S1 至 S14 各自至少支撑一条没有其他入选来源覆盖的事实；因此当前没有可以直接删除的入选来源。合并后仍需人工复核原文定位、GB/GiB 口径、动态页观察日期和 15 个派生指标。派生项的三项检查在 staging 中均写为 `passed`，只表示公式的范围、精度与方向校验已完成，不代表冲突已经裁决。