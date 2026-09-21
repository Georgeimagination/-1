# GA100 v2 可复用性清点

## 清点结论

`r1_ga100_14_atomic_staging_v2/` 维持 reject，不可进入正式区。v2 中的来源快照、真实实体、直接事实、断言 locator、数值路径键和若干对象边界判断仍可作为 v3 输入。旧 141-field 汇总、假 capability/topology、批量 search 文本、七源选择结果和无 preimage 保护的 operation ledger 不可原样沿用。

本报告只做 salvage 分类，没有修改 v2、正式 32 表、来源池、范围注册表、资料卡或合同文件。四类标记的含义固定如下：

| 标记 | v3 可执行含义 |
|---|---|
| `retain_as_is` | PK 与行内语义可作为 v3 种子保留。仍需走 v3 review 和事务门，不继承 v2 的 draft 签字或 operation。 |
| `retain_after_contract_rebase` | 保留目标、证据或集合语义；先绑定新的 140-field、scope、policy、manifest 和 closure。旧发布状态、旧 run 或旧 requirement ID 不自动生效。 |
| `revise` | 只保留研究问题、来源线索或部分字段。v3 必须重读、重算或改写该行。 |
| `delete` | 该 PK 不进入 v3 正式候选。必要的负面判断转写到 factor requirement、card-scope policy 或审计说明，不保留假实体。 |

`retain_as_is` 只判断行内容是否值得复用，不表示旧事务安全。v2 的 76 个 update、3 个 delete 以及所有 insert 都要由新 manifest 重新绑定。下面保留的 fact、assertion、component、link、condition 和 source row 均不以 141-field 汇总为证据，也没有 target 到 11 个 `CAP-R1-GA100-GAP-*` 或 `TOPO-R1-GA100-NVLINK-GAP`。机器清点未发现 fact、assertion 或 requirement-evidence 指向这 12 个假实体。

## 逐表 PK 分类

下表覆盖 v2 的 30 个 CSV。用状态或“除某 PK 外全部”定义的集合都是精确 PK 集，不是抽样。

| CSV | PK | `retain_as_is` | `retain_after_contract_rebase` | `revise` | `delete` | 复用依据 |
|---|---|---:|---:|---:|---:|---|
| `objects.csv` | `object_id` | 0 | 1 | 0 | 0 | `OBJ-NVIDIA-GA100-DIE` 的 label、type 和裸片边界可靠；缺的是 scope allocation/mapping 与 registry row，和旧 141-field 无关。 |
| `object-relations.csv` | `object_relation_id` | 0 | 1 | 0 | 0 | `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 方向正确；待 projection manifest 和独立批准后再用于 GA100 card reachability。 |
| `components.csv` | `component_id` | 11 | 0 | 0 | 0 | 11 个 component 均来自 GA100 白皮书的真实结构或固定功能模块，没有为 coverage 造实体。 |
| `links.csv` | `link_id` | 2 | 0 | 0 | 0 | PCIe 4.0 x16 与 GA100 NVLink interface class 均有直接设计图依据；两行不依赖假 topology，也没有预设 NVLink 数量。 |
| `topologies.csv` | `topology_id` | 0 | 0 | 0 | 1 | 删除 `TOPO-R1-GA100-NVLINK-GAP`。notes 已承认没有真实 topology instance。 |
| `precision-paths.csv` | `precision_path_id` | 5 | 0 | 0 | 0 | 五行 path identity 由 Table 3 或 GA100 per-SM 实现事实支持。它们是数值路径实体，不由 141-field summary 生成。 |
| `special-capabilities.csv` | `capability_id` | 4 | 0 | 0 | 11 | 保留 sparse、warp reduce、OFA、video decode 四个真实 capability；删除全部 `CAP-R1-GA100-GAP-*`。 |
| `memory-levels.csv` | `memory_level_id` | 3 | 0 | 0 | 0 | register file、combined L1/shared、L2 都有真实 component identity；没有带入 A100 容量或带宽。 |
| `condition-sets.csv` | `condition_set_id` | 14 | 0 | 0 | 0 | 14 组条件用于真实 fact，保留 datatype、稀疏 pattern、LR-PHY、full-die、per-SM 与 RAS 外部依赖，不指向假实体。 |
| `facts.csv` | `fact_id` | 87 | 0 | 2 | 0 | 除 GA100 name/family 外，87 行都在真实 target 上并有可定位断言；两条 identity fact 需移除 MIG qualifier 后降为 `single_source`。 |
| `field-requirements.csv` | `requirement_id` | 0 | 102 | 149 | 21 | 90 条 `value_available` 有同 target fact；12 条结构性 N/A 可在新 policy 下复核。101 条真实 target 的 `not_found`、47 条剩余 pending 和 vendor TOPS 要重做。20 条假实体 requirement 与 data-cutoff requirement 删除。 |
| `card-completeness.csv` | `card_completeness_id` | 0 | 0 | 13 | 0 | 13 个 domain 的结论依赖旧 coverage、七源 run 和未批准数据；待 v3 manifest closure 后全部重算。 |
| `source-families.csv` | `source_family_id` | 8 | 0 | 0 | 0 | family/version 归并是来源身份数据，不依赖 GA100 coverage。本项含 MIG guide family，保留作 lead。 |
| `sources.csv` | `source_id` | 9 | 0 | 1 | 0 | 10 个内容版本及 fingerprint 可复用；`SRC-NVIDIA-A100-ISSCC-2021` 的 notes 要删去“依赖 MIG identity chain”表述。MIG 610 source 保留为 lead。 |
| `source-endpoints.csv` | `endpoint_id` | 28 | 0 | 0 | 0 | endpoint URL、local target、hash、bytes 与 source version 绑定已经核过；是否进入 v3 minimum set 由新 selection 决定。 |
| `fact-assertions.csv` | `assertion_id` | 107 | 0 | 0 | 2 | 107 条原始值与 locator 可复用；删除两条 MIG identity qualifier。没有 assertion 指向假 capability/topology。 |
| `requirement-evidence.csv` | `requirement_evidence_id` | 6 | 0 | 0 | 1 | 六条 bare-die 结构性 N/A 证据可保留；删除 vendor TOPS 的 `supports_not_applicable`。 |
| `search-log.csv` | `search_id` | 0 | 0 | 115 | 17 | 132 行全部是模板文本。17 行随假实体链删除；其余 115 行只保留 requirement/source lead，重写 query、endpoint 与 locator。 |
| `search-results.csv` | `search_result_id` | 0 | 0 | 216 | 34 | 250 行 note 全是模板。34 行随假实体 search 删除；其余 216 行重读来源后重建 checked scope 和字段特定排除理由。 |
| `source-screening.csv` | `screening_id` | 4 | 5 | 1 | 0 | 四个既有 lead 决策不依赖旧 closure；五个仍有独有职责的 selected source 待六源 run rebase；MIG 610 改为 `lead_only`。 |
| `source-selected-roles.csv` | `source_selected_role_id` | 0 | 7 | 0 | 1 | 六个保留来源对应七个角色可作为 rerun 输入；删除 MIG identity role。 |
| `source-coverage.csv` | `coverage_id` | 2 | 0 | 0 | 0 | IEEE Micro 被 whitepaper 覆盖、R595 被固定 RAS PDF 覆盖，都是 claim-scoped 来源裁决，不依赖假实体。 |
| `selection-runs.csv` | `selection_run_id` | 0 | 0 | 1 | 0 | `SELRUN-GA100-DIE-20260821-V2` 缺 scope row 且错误保留 MIG；用六源、新 scope、cutoff 和 closure 重跑。 |
| `selection-members.csv` | `selection_member_id` | 0 | 6 | 0 | 1 | 六个非 MIG member 的不可替代职责可复用，需绑定新 run；删除 `SELMEM-R1-GA100-V2-MIG610`。 |
| `payload_copies.csv` | `payload_id` | 0 | 19 | 0 | 0 | 19 组 source path、stable target、hash、bytes 已独立核对；复制动作需纳入 v3 input manifest，不能沿用旧 operation。 |
| `capability_coverage.csv` | `mechanism` | 0 | 3 | 0 | 11 | reduction、sparse skip、media/OFA 三行在真实 capability 上，可转入新 factor closure；其余 11 行因假 capability 删除，机制名称和负面边界另作 policy 输入。 |
| `field_coverage_summary.csv` | `field_id` | 0 | 0 | 140 | 1 | 删除 `FIELD-ID-DATA-CUTOFF` 行；其他 140 行从新 candidate/policy/requirement closure 重算，旧 disposition 和 record ID 不继承。 |
| `path_by_field_closure.csv` | `(precision_path_id, field_id)` | 0 | 108 | 0 | 0 | 只保留 108 个 key、path identity、field identity 与适用性判断。旧 requirement ID 和 draft closure 状态不作为 v3 结论。 |
| `claim_dispositions.csv` | `claim` | 13 | 1 | 0 | 0 | 13 条产品值排除、单位冲突或对象边界判断可直接复用；data-cutoff claim 转入 card metadata 合同。 |
| `operations.csv` | `(target_table, primary_key)` | 0 | 0 | 1021 | 0 | 整本 ledger 缺 preimage、input binding 和 postimage hash。目标行的 salvage 由本表其他行决定，operation 本身全部重建。 |

`field-requirements.csv` 中可 rebase 的 12 条结构性 N/A 是：`REQ-R1-GA100-PATH-M2NA-AMPERE-TENSOR-INT8-SUBNORMAL`、`REQ-R1-GA100-PATH-R1-GA100-AMPERE-TENSOR-BINARY-SUBNORMAL`、`REQ-R1-GA100-PATH-R1-GA100-AMPERE-TENSOR-INT4-SUBNORMAL`、`REQ-R1-GA100-PHY-COOLING`、`REQ-R1-GA100-PHY-FORM-FACTOR`、`REQ-R1-GA100-PHY-HBM-STACKS`、`REQ-R1-GA100-PHY-INTERPOSER`、`REQ-R1-GA100-PHY-PACKAGE`、`REQ-R1-GA100-REL-QUANTITY`、`REQ-R1-GA100-V2-ID-DEPLOYMENT-CONSTRAINT`、`REQ-R1-GA100-V2-ID-REGION`、`REQ-R1-GA100-V2-ID-SKU`。这些行依赖对象类型、relation 类型或 integer/binary path 语义，不依赖旧 141-field 行数或假实体。

## 假 capability 与 topology 删除链

以下 12 个 entity PK 及其 20 条 requirement 必须从 v3 正式候选移除。对 `not_found` requirement，search 和两个 result 一并删除；pending 或结构性 N/A 行没有 search 子链。

| 待删 entity | 待删 requirement | 待删 search | 待删 result |
|---|---|---|---|
| `CAP-R1-GA100-GAP-ATTENTION-MOVE` | `REQ-R1-GA100-CAP-GAP-ATTENTION-MOVE` | `SEARCH-R1-GA100-CAP-GAP-ATTENTION-MOVE` | `SRESULT-R1-GA100-CAP-GAP-ATTENTION-MOVE-1`；`SRESULT-R1-GA100-CAP-GAP-ATTENTION-MOVE-2` |
| `CAP-R1-GA100-GAP-COLLECTIVE` | `REQ-R1-GA100-CAP-GAP-COLLECTIVE` | `SEARCH-R1-GA100-CAP-GAP-COLLECTIVE` | `SRESULT-R1-GA100-CAP-GAP-COLLECTIVE-1`；`SRESULT-R1-GA100-CAP-GAP-COLLECTIVE-2` |
| `CAP-R1-GA100-GAP-COMPRESSION` | `REQ-R1-GA100-CAP-GAP-COMPRESSION` | 无，当前为 pending | 无 |
| `CAP-R1-GA100-GAP-DEQUANTIZE` | `REQ-R1-GA100-CAP-GAP-DEQUANTIZE` | `SEARCH-R1-GA100-CAP-GAP-DEQUANTIZE` | `SRESULT-R1-GA100-CAP-GAP-DEQUANTIZE-1`；`SRESULT-R1-GA100-CAP-GAP-DEQUANTIZE-2` |
| `CAP-R1-GA100-GAP-KV-CACHE` | `REQ-R1-GA100-CAP-GAP-KV-CACHE` | `SEARCH-R1-GA100-CAP-GAP-KV-CACHE` | `SRESULT-R1-GA100-CAP-GAP-KV-CACHE-1`；`SRESULT-R1-GA100-CAP-GAP-KV-CACHE-2` |
| `CAP-R1-GA100-GAP-MOE-DISPATCH` | `REQ-R1-GA100-CAP-GAP-MOE-DISPATCH` | `SEARCH-R1-GA100-CAP-GAP-MOE-DISPATCH` | `SRESULT-R1-GA100-CAP-GAP-MOE-DISPATCH-1`；`SRESULT-R1-GA100-CAP-GAP-MOE-DISPATCH-2` |
| `CAP-R1-GA100-GAP-MOE-ROUTE` | `REQ-R1-GA100-CAP-GAP-MOE-ROUTE` | `SEARCH-R1-GA100-CAP-GAP-MOE-ROUTE` | `SRESULT-R1-GA100-CAP-GAP-MOE-ROUTE-1`；`SRESULT-R1-GA100-CAP-GAP-MOE-ROUTE-2` |
| `CAP-R1-GA100-GAP-QUANTIZE` | `REQ-R1-GA100-CAP-GAP-QUANTIZE` | `SEARCH-R1-GA100-CAP-GAP-QUANTIZE` | `SRESULT-R1-GA100-CAP-GAP-QUANTIZE-1`；`SRESULT-R1-GA100-CAP-GAP-QUANTIZE-2` |
| `CAP-R1-GA100-GAP-SOFTMAX` | `REQ-R1-GA100-CAP-GAP-SOFTMAX` | `SEARCH-R1-GA100-CAP-GAP-SOFTMAX` | `SRESULT-R1-GA100-CAP-GAP-SOFTMAX-1`；`SRESULT-R1-GA100-CAP-GAP-SOFTMAX-2` |
| `CAP-R1-GA100-GAP-TOPK` | `REQ-R1-GA100-CAP-GAP-TOPK` | `SEARCH-R1-GA100-CAP-GAP-TOPK` | `SRESULT-R1-GA100-CAP-GAP-TOPK-1`；`SRESULT-R1-GA100-CAP-GAP-TOPK-2` |
| `CAP-R1-GA100-GAP-TRANSPOSE` | `REQ-R1-GA100-CAP-GAP-TRANSPOSE` | `SEARCH-R1-GA100-CAP-GAP-TRANSPOSE` | `SRESULT-R1-GA100-CAP-GAP-TRANSPOSE-1`；`SRESULT-R1-GA100-CAP-GAP-TRANSPOSE-2` |
| `TOPO-R1-GA100-NVLINK-GAP` | `REQ-R1-GA100-V2-INT-BISECTION-BW` | `SEARCH-R1-GA100-V2-V2-INT-BISECTION-BW` | `SRESULT-R1-GA100-V2-V2-INT-BISECTION-BW-1`；`SRESULT-R1-GA100-V2-V2-INT-BISECTION-BW-2` |
| 同上 | `REQ-R1-GA100-V2-INT-DEGREE` | `SEARCH-R1-GA100-V2-V2-INT-DEGREE` | `SRESULT-R1-GA100-V2-V2-INT-DEGREE-1`；`SRESULT-R1-GA100-V2-V2-INT-DEGREE-2` |
| 同上 | `REQ-R1-GA100-V2-INT-HOPS` | `SEARCH-R1-GA100-V2-V2-INT-HOPS` | `SRESULT-R1-GA100-V2-V2-INT-HOPS-1`；`SRESULT-R1-GA100-V2-V2-INT-HOPS-2` |
| 同上 | `REQ-R1-GA100-V2-INT-MAX-SCALE` | 无，当前为 N/A | 无 |
| 同上 | `REQ-R1-GA100-V2-INT-OVERSUBSCRIPTION` | 无，当前为 N/A | 无 |
| 同上 | `REQ-R1-GA100-V2-INT-TOPOLOGY` | `SEARCH-R1-GA100-V2-V2-INT-TOPOLOGY` | `SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-1`；`SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-2` |
| 同上 | `REQ-R1-GA100-V2-INT-TOPOLOGY-DIMENSIONS` | `SEARCH-R1-GA100-V2-V2-INT-TOPOLOGY-DIMENSIONS` | `SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-DIMENSIONS-1`；`SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-DIMENSIONS-2` |
| 同上 | `REQ-R1-GA100-V2-INT-TOPOLOGY-NODE-COUNT` | `SEARCH-R1-GA100-V2-V2-INT-TOPOLOGY-NODE-COUNT` | `SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-NODE-COUNT-1`；`SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-NODE-COUNT-2` |
| 同上 | `REQ-R1-GA100-V2-INT-TOPOLOGY-ROUTING` | `SEARCH-R1-GA100-V2-V2-INT-TOPOLOGY-ROUTING` | `SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-ROUTING-1`；`SRESULT-R1-GA100-V2-V2-INT-TOPOLOGY-ROUTING-2` |

这条删除链还要清理 11 行 `capability_coverage.csv`，并重算 `field_coverage_summary.csv` 中 `FIELD-CAP-IMPLEMENTATION-DETAIL` 和九个 topology field。`FIELD-CAP-IMPLEMENTATION-DETAIL` 本身仍由 sparse、warp reduce、OFA、video decode 的真实 fact 覆盖，不能随假 capability 一起删除。11 种机制名称及“未发现 dedicated entity”的判断转入新 factor policy；九个 topology field 表达为当前 card 没有 reachable real topology target。真实的 `LINK-R1-GA100-NVLINK-INTERFACE`、`LINK-M2NA-AMPERE-NVLINK3` 及其 link-local fact 保留。

另有一条合同删除链：`REQ-R1-GA100-ID-DATA-CUTOFF` 与 `field_coverage_summary.csv` 的 `FIELD-ID-DATA-CUTOFF` 行删除；`claim_dispositions.csv` 中对应 claim rebase 为 card metadata/cutoff 输入。它不再作为厂商 fact 或 field requirement 检索。

## 49 条 pending 的处置队列

49 条 `pending_verification` 都不能进入 provisional/formal。下列 PK 只保留问题定义；`REQ-R1-GA100-CAP-GAP-COMPRESSION` 走上节假实体删除链，`REQ-R1-GA100-ID-DATA-CUTOFF` 迁移到 card metadata，其余 47 条需实际检索后改为 value、not_found、not_public 或 not_applicable。

| 域 | 数量 | requirement PK |
|---|---:|---|
| benchmark | 2 | `REQ-R1-GA100-V2-BENCH-LATENCY`；`REQ-R1-GA100-V2-BENCH-THROUGHPUT` |
| compute | 4 | `REQ-R1-GA100-V2-COMP-CONCURRENCY`；`REQ-R1-GA100-V2-COMP-DATAFLOW-RESIDENCY`；`REQ-R1-GA100-V2-COMP-INSTRUCTION-TILE`；`REQ-R1-GA100-V2-COMP-UTILIZATION-LIMIT` |
| derived | 5 | `REQ-R1-GA100-V2-DER-CAPACITY-COMPUTE`；`REQ-R1-GA100-V2-DER-COMPUTE-BW-SPEC`；`REQ-R1-GA100-V2-DER-COMPUTE-BW-SUSTAINED`；`REQ-R1-GA100-V2-DER-INTERCONNECT-COMPUTE`；`REQ-R1-GA100-V2-DER-MOVE-MATRIX` |
| identity | 9 | `REQ-R1-GA100-ID-AVAIL`；`REQ-R1-GA100-ID-DATA-CUTOFF`；`REQ-R1-GA100-ID-STATUS`；`REQ-R1-GA100-V2-ID-DEPLOYMENT`；`REQ-R1-GA100-V2-ID-DESIGN-OBJECTIVE`；`REQ-R1-GA100-V2-ID-MARKET-ACCESS-CONSTRAINT`；`REQ-R1-GA100-V2-ID-RELEASE-DATE`；`REQ-R1-GA100-V2-ID-TARGET-USE-POSITIONING`；`REQ-R1-GA100-V2-ID-VENDOR-POSITIONING` |
| interconnect | 6 | `REQ-R1-GA100-V2-INT-AGGREGATE-BW`；`REQ-R1-GA100-V2-INT-INJECTION-BW`；`REQ-R1-GA100-V2-INT-LANE-COUNT`；`REQ-R1-GA100-V2-INT-LINK-COUNT`；`REQ-R1-GA100-V2-INT-PER-LINK-RATE`；`REQ-R1-GA100-V2-INT-PHYSICAL-LINK-COUNT` |
| memory | 8 | `REQ-R1-GA100-V2-MEM-COMPRESSION`；`REQ-R1-GA100-V2-MEM-CONSISTENCY`；`REQ-R1-GA100-V2-MEM-GRANULARITY`；`REQ-R1-GA100-V2-MEM-LATENCY`；`REQ-R1-GA100-V2-MEM-POOLING-MODE`；`REQ-R1-GA100-V2-MEM-READ-TRANSFER-PER-CYCLE`；`REQ-R1-GA100-V2-MEM-USABLE-CAPACITY`；`REQ-R1-GA100-V2-MEM-VIRTUAL-MEMORY` |
| physical | 2 | `REQ-R1-GA100-PHY-DIE-COUNT`；`REQ-R1-GA100-PHY-HBM-INTERFACE` |
| reliability | 3 | `REQ-R1-GA100-RAS-CKPT`；`REQ-R1-GA100-V2-RAS-ECC`；`REQ-R1-GA100-V2-RAS-PROTECTION-SCOPE` |
| software | 6 | `REQ-R1-GA100-V2-SW-CHIP-BOUND-SCHEDULING`；`REQ-R1-GA100-V2-SW-COMMUNICATION-LIBRARY`；`REQ-R1-GA100-V2-SW-COMPILER`；`REQ-R1-GA100-V2-SW-FRAMEWORK`；`REQ-R1-GA100-V2-SW-OPERATOR-LIBRARY`；`REQ-R1-GA100-V2-SW-RUNTIME` |
| special capabilities | 1 | `REQ-R1-GA100-CAP-GAP-COMPRESSION` |
| virtualization | 3 | `REQ-R1-GA100-V2-VIRT-MULTI-TENANCY`；`REQ-R1-GA100-V2-VIRT-PARTITIONING`；`REQ-R1-GA100-V2-VIRT-PREEMPTION-QOS` |

`pending` 数量减少不能靠批量改状态。每条最终缺失结论都要有 endpoint、实际章节或全文范围、source type 与字段特定排除理由。derived 项若输入不全，需由新 policy 决定 not_found、not_public 或暂不发布，不能继续用 pending 补齐行数。

## 132 条 search 与 250 条 result

132 个 `search_id` 和 250 个 `search_result_id` 都不能作为发布证据复用。v2 已让 query 中的 source ID 与 result 集合相等，但每个 query、log note 和 result note 都来自统一模板，没有实际 query string、页码、章节、表格、网页小标题或全文搜索范围。

删除链占 17 个 log 和 34 个 result；剩余 115 个 log 与 216 个 result 全部标为 `revise`。v3 可以复用 `requirement_id → candidate source_id` 的工作队列，不能复用 `no_reliable_result` 结论。新合同落地后，每条 result 还要写实际 `endpoint_id` 与 `checked_locator_or_scope`，`source_types_checked` 从 result 的 source type 派生。

优先重读的旧 PK 如下：

| 问题族 | 旧 requirement / search | v3 实查来源 |
|---|---|---|
| benchmark | `REQ-R1-GA100-BENCH-ENERGY`、`REQ-R1-GA100-BENCH-POWER`、`REQ-R1-GA100-BENCH-TPJ`、`REQ-R1-GA100-BENCH-UTIL`；对应 `SEARCH-R1-GA100-BENCH-ENERGY`、`SEARCH-R1-GA100-BENCH-POWER`、`SEARCH-R1-GA100-BENCH-TPJ`、`SEARCH-R1-GA100-BENCH-UTIL` | HPEC、random-access、Ampere microbenchmark、厂商固定资料；先补产品对象或明确 die card 不可归一化的边界。 |
| benchmark pending | `REQ-R1-GA100-V2-BENCH-LATENCY`、`REQ-R1-GA100-V2-BENCH-THROUGHPUT` | 同上；cycle 值不能写入 seconds 字段，产品测量不能下放 GA100。 |
| physical clock/power | `REQ-R1-GA100-PHY-CLOCK`、`REQ-R1-GA100-PHY-POWER` | whitepaper 与 ISSCC 的 full-design/product 边界，记录具体页码；A100 clock/power 仍不转为 GA100 fact。 |
| RAS BIST/SDE | `REQ-R1-GA100-RAS-BIST`、`REQ-R1-GA100-RAS-SDE` | 固定 `GPU Memory Error Management` PDF 优先，必要时再查 R595；保留 external HBM、driver、reset 条件。 |
| vendor TOPS | `REQ-R1-GA100-COMP-VENDOR-TOPS` | 改为 not_found 或 not_public 搜索。full-GA100 peak 在概念上适用，缺 frequency/precision/sparsity 条件时不能写 N/A。 |
| standalone price | `REQ-R1-GA100-ECON-PRICE` | 保留 v2 notes 中 price/pricing/MSRP/list price/cost/USD/dollar 的原始检索词，重新落 endpoint 和 locator；A100 产品价格继续排除。 |

## 9×12 路径的可复用边界

`path_by_field_closure.csv` 的 108 个 `(precision_path_id, field_id)` key 值得保留。九条 path、十二个 field、FP16→FP16 变体、TF32 conversion/output 分离以及 integer/binary subnormal N/A 的语义判断均可作为 v3 expected-pair seed。

108 行当前分为 34 value、71 not_found、3 not_applicable。v3 的复用范围如下：

- 34 个 value 单元回到对应 fact 和 fact-assertion；事实值与原始 locator 可以复用。
- 71 个 not_found 单元只保留待查问题、path/field 精确 target 和候选来源。旧 requirement ID、模板 search ID、`not_found` 状态与 `formal_record_id` 不自动推广到 v3。
- 3 个 integer/binary subnormal N/A 单元可在新 policy 下复核并 rebase，其结构 predicate 清楚。

v3 manifest 应独立生成 108 个 mandatory include key，再把 fact 或新 requirement 与每个 key 逐一绑定。不能从 v2 的 `formal_record_id` 列反推发布闭合，也不能因 108 行齐全而跳过 71 个单元的实际检索。

## MIG 610 只留在 lead 层

MIG 610 的 source family、source record、九个 endpoint 和九个 payload hash 可以保留，作用限于产品到 die 的辅助映射与对象边界复核。它不进入 v3 六源 minimum set，也不为 GA100 identity fact 增加 evidence count。

需要执行的 PK 变更是：

| 表 | PK | 动作 |
|---|---|---|
| `facts.csv` | `FACT-R1-GA100-ID-FAMILY` | `revise`，value 保留为 GA100，`evidence_state` 从 corroborated 降为 single_source。 |
| `facts.csv` | `FACT-R1-GA100-ID-NAME` | `revise`，value 保留为 NVIDIA GA100，`evidence_state` 从 corroborated 降为 single_source。 |
| `fact-assertions.csv` | `ASSERT-R1-GA100-ID-FAMILY-01-MIG` | `delete`。 |
| `fact-assertions.csv` | `ASSERT-R1-GA100-ID-NAME-01-MIG` | `delete`。 |
| `source-screening.csv` | `SCREEN-R1-GA100-NVIDIA-MIG-USER-GUIDE-610` | `revise`，selected 改为 lead_only，理由写辅助产品映射不承担不可替代 GA100 fact。 |
| `source-selected-roles.csv` | `SROLE-R1-GA100-NVIDIA-MIG-USER-GUIDE-610-IDENTITY` | `delete`。 |
| `selection-members.csv` | `SELMEM-R1-GA100-V2-MIG610` | `delete`。 |
| `selection-runs.csv` | `SELRUN-GA100-DIE-20260821-V2` | `revise`，重跑六源并绑定新 scope/manifest；建议使用新的 v3 run PK。 |
| `sources.csv` | `SRC-NVIDIA-A100-ISSCC-2021` | `revise` notes，删除“需要 MIG identity chain”措辞；ISSCC 的 LR-PHY、area qualifier 与 CUDA 8.0 conflict 职责不变。 |

六源职责保留 whitepaper、ISSCC、固定 RAS PDF、CUDA 11.0、PTX 7.0、PTX 7.2。PTX 两版本仍属同一 family，职责不同，不互算独立 corroboration。

## operation 的事务保护

`operations.csv` 的 1021 行全部重建。923 个正式 insert 要绑定 expected-absent；19 个 payload insert 要绑定 source hash、bytes、stable target expected-absent；76 个 update 和 3 个 delete 还要绑定 canonical preimage row hash。manifest 同时记录正式输入表 hash、scope/policy/cutoff、payload 集合、预期 postimage 表 hash和 closure hash。

76 个 update 的 PK 分组如下，v3 不能只检查“PK 仍存在”：

| target table | 数量 | PK |
|---|---:|---|
| `数据/condition-sets.csv` | 1 | `COND-M2NA-AMPERE-2OF4` |
| `数据/facts.csv` | 8 | `FACT-M2NA-AMPERE-ASYNC-EXEC`；`FACT-M2NA-AMPERE-CUDA-EXEC`；`FACT-M2NA-AMPERE-INT-A`；`FACT-M2NA-AMPERE-SM-EXEC`；`FACT-M2NA-AMPERE-SPARSE-DETAIL`；`FACT-M2NA-AMPERE-SPARSE-LEVEL`；`FACT-M2NA-AMPERE-SW`；`FACT-M2NA-AMPERE-TF32-A` |
| `数据/field-requirements.csv` | 22 | `REQ-M2NA-AVAIL-0001`；`REQ-M2NA-AVAIL-0004`；`REQ-M2NA-AVAIL-0005`；`REQ-M2NA-AVAIL-0013`；`REQ-M2NA-AVAIL-0016`；`REQ-M2NA-AVAIL-0017`；`REQ-M2NA-AVAIL-0018`；`REQ-M2NA-AVAIL-0021`；`REQ-M2NA-GAP-0006`；`REQ-M2NA-GAP-0059`；`REQ-M2NA-GAP-0060`；`REQ-M2NA-GAP-0061`；`REQ-M2NA-GAP-0062`；`REQ-M2NA-GAP-0063`；`REQ-M2NA-GAP-0109`；`REQ-M2NA-GAP-0110`；`REQ-M2NA-GAP-0111`；`REQ-M2NA-GAP-0112`；`REQ-M2NA-GAP-0113`；`REQ-M2NA-GAP-0114`；`REQ-M2NA-GAP-0163`；`REQ-M2NA-GAP-0164` |
| `数据/precision-paths.csv` | 1 | `PPATH-M2NA-AMPERE-TENSOR-INT8` |
| `数据/special-capabilities.csv` | 1 | `CAP-M2NA-AMPERE-SPARSE` |
| `最小参考资料库/fact-assertions.csv` | 15 | `ASSERT-M2NA-0001`；`ASSERT-M2NA-0004`；`ASSERT-M2NA-0005`；`ASSERT-M2NA-0008`；`ASSERT-M2NA-0009`；`ASSERT-M2NA-0010`；`ASSERT-M2NA-0011`；`ASSERT-M2NA-0012`；`ASSERT-M2NA-0013`；`ASSERT-M2NA-0014`；`ASSERT-M2NA-0015`；`ASSERT-M2NA-0016`；`ASSERT-M2NA-0017`；`ASSERT-M2NA-0018`；`ASSERT-M2NA-0021` |
| `最小参考资料库/search-log.csv` | 14 | `SEARCH-M2NA-0002`；`SEARCH-M2NA-0019`；`SEARCH-M2NA-0020`；`SEARCH-M2NA-0021`；`SEARCH-M2NA-0022`；`SEARCH-M2NA-0023`；`SEARCH-M2NA-0064`；`SEARCH-M2NA-0065`；`SEARCH-M2NA-0066`；`SEARCH-M2NA-0067`；`SEARCH-M2NA-0068`；`SEARCH-M2NA-0069`；`SEARCH-M2NA-0106`；`SEARCH-M2NA-0107` |
| `最小参考资料库/search-results.csv` | 14 | `SRESULT-M2NA-0002`；`SRESULT-M2NA-0033`；`SRESULT-M2NA-0034`；`SRESULT-M2NA-0035`；`SRESULT-M2NA-0036`；`SRESULT-M2NA-0037`；`SRESULT-M2NA-0123`；`SRESULT-M2NA-0124`；`SRESULT-M2NA-0125`；`SRESULT-M2NA-0126`；`SRESULT-M2NA-0127`；`SRESULT-M2NA-0128`；`SRESULT-M2NA-0211`；`SRESULT-M2NA-0212` |

三条 delete 的语义继续保留，但执行前必须绑定 preimage：`FACT-M2NA-AMPERE-TENSOR-FORMATS`、`REQ-M2NA-AVAIL-0003`、`ASSERT-M2NA-0003`。它们删除 aggregate format list，改由 path-specific fact 取代；旧 ledger 没有足够保护，不能直接重放。

## scope 与 manifest 的缺口

旧 scope gate 已经确定缺两行：`Test-ChipScope.ps1` 读入的 object-scope registry 没有 `OBJ-NVIDIA-GA100-DIE`，形成 79 objects 对 78 scope rows；selection-run-scope registry 没有 `SELRUN-GA100-DIE-20260821-V2`，形成 12 runs 对 11 run-scope rows。v3 先建立 `FREEZE-NV-001 → SCOPE-0001 → OBJ-NVIDIA-GA100-DIE` 的受控映射，再生成绑定该 scope 的新 selection run。

新合同还缺以下输入，v2 没有可直接 salvage 的 row：140-field baseline、card lifecycle/cutoff、scope allocation 与 approved mapping、coverage policy、真实 target candidates、reachable-target binding、factor requirement、factor-target binding、coverage-fields 派生结果、canonical input manifest、closure canonical-set hash、row/table preimage 与 postimage hash、独立 approval。11 种无真实 target 的机制和 topology 存在性由 factor requirement 承载，不再创建 capability/topology placeholder。

这些缺项是 v3 生成前置条件。本报告不等待合同实施，也不替合同预造列或 ID。

## v3 重建的最小输入

为避免重复提取，v3 从以下已可靠材料起步：

1. 复用 8 个 source family、10 个 source version、28 个 endpoint 和 19 个 payload 的现有 fingerprint/hash/bytes。MIG 610 保留为 lead，不进入 minimum set。
2. 复用 11 个真实 component、2 个真实 link、3 个 memory level、5 个 staged precision path、4 个真实 capability、14 个 condition。GA100 object 与 implements-Ampere relation 在新 scope/projection manifest 下 rebase。
3. 导入 87 条无需改值的 fact 与 107 条非 MIG assertion，直接复用 raw value、unit、condition 和 locator。只改两条 identity fact 的 evidence state，并删除两条 MIG qualifier。
4. 把 108 个 path×field key 作为 expected-pair seed；34 个 value 单元回链已验事实，71 个缺失单元重做搜索，3 个 N/A 单元按 policy 复核。旧 requirement/search ID 不作为必选输入。
5. 把 90 条 value-available requirement 和 12 条结构性 N/A 作为 rebase 候选；删除 21 条指定 requirement，重做其余 149 条。优先关闭 benchmark、clock/power、RAS、vendor TOPS 与 47 条真实 pending。
6. 六源 reverse-removal 的职责表从 whitepaper、ISSCC、固定 RAS PDF、CUDA 11.0、PTX 7.0、PTX 7.2 起步。事实、search 与 factor closure 固定后重新运行，不复用 v2 run 状态。
7. 新建 scope/policy/manifest/approval 输入，绑定 140-field、cutoff、真实 target reachability、factor obligations、payload、selection 和 closure hash。
8. 重新生成全量 operation ledger。每个 update/delete 带 canonical preimage，每个 insert 带 expected-absent，全包带 input/postimage hash。

GA100 Markdown 资料卡继续留到 v3 数据和 manifest 独立批准之后生成。v2 的 README、validation PASS 和 141-field summary 只能作为失败历史与问题索引。

## 文本自检

`report-humanizer final scan: PASS; no machine-detectable AI tells found`

人工逆向复读：PASS。按 v3 最小输入、scope/manifest、事务保护、MIG、9×12、search、pending、删除链、逐表分类和开头结论逆序检查，再单独核对标题、每节首段、表格导语与结尾。30 张 CSV 的分类总数、11 个假 capability、1 个假 topology、20 条绑定 requirement、17 个 search、34 个 result、49 条 pending、132/250 模板链、108 个 path key、76 个 update、3 个 delete、79/78 与 12/11 scope 差异前后一致。未发现剩余模板腔；剩余风险来自 v3 合同和检索尚未实施。
