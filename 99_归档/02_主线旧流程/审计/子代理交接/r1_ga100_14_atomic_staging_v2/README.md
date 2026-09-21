# GA100 原子事实 staging overlay v2

## 状态与使用边界

本目录是 `NVIDIA GA100 die` 的第二版审计交接稿，日期为 2026-08-21。它只提供可重放的候选行、删除动作、固定文件复制计划和验证记录，没有写入正式 32 表、正式来源快照、资料卡、进度或清单，也没有改动 `r1_ga100_08_atomic_staging/`。本轮按总控要求不生成最终 GA100 Markdown 资料卡；资料卡应在 v2 数据验收后另行重生。

正式对象仍是 `OBJ-NVIDIA-GA100-DIE`，canonical label 固定为 `NVIDIA GA100 die`，语义范围是 full GA100 physical die design。Ampere 通用机制通过 `REL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 复用；A100 SXM/PCIe 产品配置、HBM 容量与堆叠、板卡功耗、产品峰值、MIG profile、随机访存与微基准结果均不无条件下放。batch、序列长度、KV Cache 规模、MoE 通信量等负载变量也没有写成芯片固有事实。

v2 目录现有 30 个 CSV 和本文及 `validation_report.md` 两个 Markdown 文件。24 个正式表 fragment 共 999 行，6 个审计辅助 CSV 共 296 行，`operations.csv` 共 1021 行；所有 CSV 合计 2316 行。`operations.csv` 明列 942 个 insert、76 个 update 和 3 个 delete。旧行只要语义、条件、证据链或字段发生改写，均回到 `draft` 或 `needs_resolution`，没有沿用旧的 reviewed 签字。

## 主要裁决

两项证据计数问题已经关闭。`FACT-R1-GA100-AMPERE-SW-MATURITY` 降为 `single_source`，只计 CUDA C++ Programming Guide 11.0 的语义相符断言；PTX 文档不再用于凑来源数。`FACT-M2NA-AMPERE-SPARSE-LEVEL` 新增 PTX ISA 7.2 对 `mma.sp` dedicated instruction 的直接断言，因而保留 `corroborated`。PTX 7.0 与 7.2 仍属于同一 source family，不能互相充当独立家族复核。

v1 的 75 个 `coverage_only` 已全部移除。两个 memory 字段改指向既有正式 fact/requirement，其余 73 个字段在合法、真实的目标上建立 fact 或 targeted requirement。`field_coverage_summary.csv` 的 141 行均使用 formal+staging 联集中的真实 fact/requirement ID，分布为 value 38、conditional 7、pending 49、not_found 35、not_applicable 12；没有空 ID，也没有辅助状态冒充正式记录。所有 staged `not_found` requirement 都能追到字段和目标明确的 search log。132 条 search log 只声明其 250 条 search-result 实际列出的来源，不再用“查过整包”文字扩大检索范围。

新增 `LINK-R1-GA100-NVLINK-INTERFACE`，表示 GA100 自有的 third-generation NVLink interface class，但不预设接口数量。logical/physical link count、lane count、per-link rate、injection/aggregate bandwidth 和 absolute latency 分别落到该 link 的 requirement。拓扑字段因合同只允许 topology target，使用 `TOPO-R1-GA100-NVLINK-GAP` 作为结构性缺口目标；它不是已公开的 GA100 系统拓扑实体。NVLink3 的 error detection/recovery、remote-memory 语义以及 ISSCC LR-PHY 的 NRZ、no-FEC、BER、CTLE、PRML、Viterbi 细节仍留在 Ampere architecture link，不扩写成全芯片 RAS 或物理 link count。

Tensor Core 数值路径增加 `PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16`，单独表达 FP16 输入和程序员可见 FP16 累加。`path_by_field_closure.csv` 对 9 条 Tensor path 的 12 个数值字段逐格闭合，共 108 个唯一单元；A、B、product、程序员可见累加、物理累加、output、rounding、scaling mode、scaling granularity、saturation、subnormal 和 sparsity 每格都有同 path、同 field 的 fact 或 requirement。TF32 output 的 FP32 事实与 conversion 分开；其他路径没有从 accumulator 反推 output。

价格改为 `not_found`。本轮实际对固定 NVIDIA whitepaper 与 ISSCC PDF 执行了 price、pricing、MSRP、list price、cost、USD 和 dollar 文本检索，只发现定性成本措辞，没有 standalone GA100 bare-die 公开价格；A100 卡或模块价格不进入本对象。economics completeness 因此为 `missing_public_data`。`FACT-R1-GA100-PHY-PROCESS` 改为 `source_with_caveat`：whitepaper 支持完整的 `TSMC 7 nm N7`，ISSCC 的 `7nm` 只作粒度较粗的 qualifier。54.2B 与 ISSCC 54B 同样保留取整差异，不把后者当作对精确值的普通 supports。

ISSCC 已改为 selected，并登记 `independent_validation` 与 `conflict_evidence` 两个角色。七源 draft selection run 包含 NVIDIA whitepaper、ISSCC、固定 RAS 文档、CUDA 11.0、PTX 7.0、PTX 7.2 和 MIG 610。ISSCC 的不可替代内容是 LR-PHY 电路细节与 CUDA 8.0 冲突断言；MIG 只用于 A100 产品到 GA100 die 的身份限定，不带入 profile。每个 member 的 mandatory reason 说明移除该来源会丢失的独有事实族，并明确 PTX 两版本同家族。

memory completeness 保持 `partial`。已覆盖每 SM 262144-byte register file、4 个 register-file group、196608-byte combined L1/shared memory、L2 名称，以及通过 Ampere 关系投影的部分 management/locality 机制。L2 与 usable capacity、读写或双向带宽、per-cycle transfer、seconds latency、bank、port、granularity、read/write model、consistency、pooling、virtual memory、compression 和 full-die aggregate 仍是明确缺口。

## 仍未解决的问题

`FIELD-ID-STATUS` 继续 pending；冻结名单的“历史锚点”不是厂商产品状态。`FIELD-ID-DATA-CUTOFF` 也继续 pending，因为它是卡片行政元数据，而当前 32 表要求 fact 具备外部证据链。v2 不用伪造 source、derived fact 或错误 evidence state 填补这两项。`FIELD-PHY-DIE-COUNT` 没有从 object type 推导为 1；HBM stack、package、interposer、form factor 和 cooling 按裸片边界保持 not_applicable 或 pending，A100 产品值不转写。

full GA100 NVLink 数量、lane/rate 规范化、injection/aggregate bandwidth、绝对链路延迟和系统拓扑仍未闭合。ISSCC 的 50 Gbps differential-interface PHY 只保留在条件与说明中，没有冒充 logical-link rate。A100 random-access 的 1400/1600 GB/s、64 GB cliff、14 groups，以及 microbenchmark cycle latency 只保留为被拒绝或待建产品对象的线索；`FIELD-MEM-LATENCY` 的正式单位仍是秒。

本机没有 `pwsh`、`powershell` 或 `powershell.exe`，所以没有运行也没有宣称通过 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1` 三道 Windows 硬门。这属于 tool/runtime failure。正式资料池另有既存的 113/111 PDF 基线差异，需由总控先裁决；它不是本 overlay 引入的问题，但会影响后续 SourcePool gate。

## 文件与不变表

正式 fragment 的行数如下：objects 1、object-relations 1、components 11、links 2、topologies 1、precision-paths 5、special-capabilities 15、memory-levels 3、condition-sets 14、facts 89、field-requirements 272、card-completeness 13、source-families 8、sources 10、source-endpoints 28、fact-assertions 109、requirement-evidence 7、search-log 132、search-results 250、source-screening 10、source-selected-roles 8、source-coverage 2、selection-runs 1、selection-members 7。

本轮不生成空 fragment。以下 8 张正式表不变：`数据/derived-inputs.csv`、`数据/derived-metrics.csv`、`数据/enums.csv`、`数据/fields.csv`、`数据/schema-columns.csv`、`数据/vendors.csv`、`最小参考资料库/conflict-groups.csv`、`最小参考资料库/conflict-members.csv`。审计辅助文件为 `payload_copies.csv` 19 行、`capability_coverage.csv` 14 行、`claim_dispositions.csv` 14 行、`field_coverage_summary.csv` 141 行和 `path_by_field_closure.csv` 108 行；它们不冒充第 33 张正式表，也没有自行引入 coverage manifest 或 card-completeness 新列。

19 个新固定 endpoint 的 candidate local path 均指向 `最小参考资料库/快照/NVIDIA/GA100/...` 的稳定目标。`payload_copies.csv` 把每个目标绑定到现有 staging download、SHA-256、byte count 和 endpoint ID；本目录没有执行复制或移动。已有 `论文/` 文件继续复用原路径。

## 正式合并顺序

正式合并必须在完整临时副本中按 `dependency_group` 重放，不能直接把 fragment 追加到正式 CSV：

1. 核对正式 32 表基线和 operations 命中，确认待 update/delete 的主键仍与本次制作时一致。
2. 按 `01_payload` 复制 19 个固定文件到 stable target，逐个核验 bytes 与 SHA-256；payload 未到位前不插入对应 endpoint。
3. 依次应用 source family、source、endpoint 和实体类记录，再应用 condition。
4. 先执行 `07_delete` 的 3 个显式删除，再应用 fact、requirement、assertion、requirement evidence 及 search log/result。每一组完成后重跑表头、PK/FK、枚举、七目标 XOR、数值列、单位、target contract 和 evidence count。
5. 数据事实集合固定后，再更新 screening、roles、coverage 和七源 selection run/member，重跑 reverse removal。
6. 最后更新 13 个 completeness 域；GA100 Markdown 资料卡在数据 v2 独立验收后另行重生，不属于本目录事务。
7. 在同一临时根运行 recovery/hash 检查，并到 Windows runner 执行三道 PowerShell gate。只有基线差异已裁决、三道 gate 退出 0 且独立复核签字后，才能把同一 ledger 原子应用到正式根。

任一步失败都应回滚同一临时事务，不得只合并已经通过的部分。

## 文本自检

`report-humanizer final scan: PASS; no machine-detectable AI tells found`

人工逆向复读：PASS。按合并顺序、未解决项、关键裁决和状态边界逆序检查，再核对 32 个文件、999 个 fragment 行、1021 个 operation、141 个 field、108 个 path cell、19 个 payload、7 个 selection member 和 113/111 基线差异。对象主体、数字、限定词、证据强度与“未运行 Windows gate”的结论前后一致。
