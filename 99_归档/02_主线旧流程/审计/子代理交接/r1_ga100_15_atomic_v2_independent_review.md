# GA100 atomic staging v2 独立复核

## 裁决

结论是 reject。`r1_ga100_14_atomic_staging_v2/` 不能进入正式区，也不能据此把 GA100 卡标为 provisional 或 formal。

这版候选在旧 32 表合同下已经做到“可以机械重放”：999 行正式 fragment 与 1021 条 operation 一一对应，19 个 payload 的来源文件、字节数和 SHA-256 全部相符；合并到临时镜像后，旧 schema 的 PK、FK、枚举、必填值、分号约束、七目标 XOR、subject/target contract、fact/assertion 数值 XOR、证据计数和同目标 value requirement 均未报错。`path_by_field_closure.csv` 也确有 9×12=108 个不重复单元。

但这只是旧合同的结构通过，不是本体语义、卡级 coverage 或正式发布通过。候选仍把不存在的 topology 和 11 个不存在的 capability 写成正式实体；以 49 条 `pending_verification` 冒充发布闭合；132 条 search log 和 250 条 result 全部由两种模板句生成，多处没有检查该字段最相关且已经入池的来源；七源 reverse-removal 又保留了可移除的 MIG 610。事务清单对 76 次 update 和 3 次 delete 没有 preimage hash，且新增 object、selection run 没有同步当前 scope registry。新 card-scope 合同所需的 140-field 基线、policy、manifest、binding、closure hash、scope/cutoff 和独立批准也完全没有落地。这些都是正式接收前的 blocker，不是文案问题。

## 独立重放结果

本次只读正式区，在 `/private/tmp/r1_ga100_v2_independent_mirror` 建立临时镜像并按 `operations.csv` 重放。正式区和候选目录均未改动。

| 检查层 | 独立结果 | 边界 |
|---|---|---|
| fragment/operation 绑定 | 923 个正式 insert、76 个 update、3 个 delete 全部命中；另有 19 个 payload insert；无 fragment 孤行、operation 孤行、insert PK 碰撞或 update/delete 空命中 | 只证明当前基线上的主键级重放可行；没有证明基线未漂移 |
| payload | 19/19 staging source 存在，byte count 与 SHA-256 全匹配；19 个 stable target 当前均不存在 | 复制只发生在临时镜像，没有写正式快照 |
| 旧 32 表静态合同 | 32 tables、346 schema columns、557 enum values，独立 Python 静态复算为 0 error | 这是对现有 PowerShell 规则的 macOS 侧复算，不是三道 Windows gate |
| recovery/hash | 临时镜像在复制 19 个 payload 后，`verify_recovery_paths.py` 通过：`formal_tables=32; endpoint_rows=181; local_paths=102; hashes_checked=102; selection_runs=12; selection_members=113` | 该脚本不检查新 coverage contract，也不替代 Windows gate |
| 141-field summary | 141 个唯一 field；38 value、7 conditional、49 pending、35 not_found、12 not_applicable | 集合等于旧 `fields.csv`，但不是新合同要求的 field×真实 target 闭包 |
| 9×12 precision path | 108 个唯一 path×field 单元；34 value、71 not_found、3 not_applicable | 结构集合通过；71 个 not_found 仍是 draft search closure，未达到发布要求 |
| card-completeness | 13 个 domain 均有一行，全部为 draft | 没有 GA100 Markdown 卡；evidence 行也明言 payload、正式应用、Windows gate 和独立签字未完成 |

## 正式接收 blocker

下表各项都足以单独阻止正式接收。行号均指候选目录内文件，除非另有说明。

| 编号 | 精确位置 | 问题与最小修复 |
|---|---|---|
| B1 | `topologies.csv:2`；`special-capabilities.csv:4-14`；`field-requirements.csv:59-69,229,231-244` | `TOPO-R1-GA100-NVLINK-GAP` 和 11 个 `CAP-R1-GA100-GAP-*` 明言自己不是公开实体，却被写入正式 entity 表，并承接 20 条正式 requirement。这是伪造本体，不是合法的 gap 表达。删除 12 个实体及其 20 条 requirement/search/result；无真实 target 的机制和拓扑缺口改由已批准的 card-scope policy 与无 target mechanism requirement 承载。 |
| B2 | `README.md:15-17,39`；`field_coverage_summary.csv:35`；合同设计 `r1_ga100_13_contract_repair_design.md:59-70,199-214` | 候选仍基于旧 141-field 合同，并保留 `FIELD-ID-DATA-CUTOFF`。已审设计要求先迁移到 140-field 基线，再生成 GA100 v2；也明确禁止假 capability/topology。必须先独立完成并批准合同迁移，再从新基线生成 v3；补几行 CSV 无法修复这项问题。 |
| B3 | `field-requirements.csv:61,96,97,100,183,186,194,207,208,210-219,221,222,224,226-228,233,234,236,239,240,247-251,253,255,256,258-262,265,266,268-271` 的 49 条 `pending_verification`；`field_coverage_summary.csv` 共 49 个 pending | `pending_verification` 只允许 draft，不能进入 provisional/formal。候选把“存在一个真实 requirement ID”称作闭合，但它只闭合了结构引用，没有闭合证据。逐项完成实际检索并改成 value/not_found/not_public/not_applicable；不能把 pending 保留到发布 manifest。 |
| B4 | `search-log.csv:2-133`；`search-results.csv:2-251` | 132/132 个 `query_or_path` 都是 “Field-specific review … explicitly checked sources” 模板，132/132 个 log note 和 250/250 个 result note 也都是同一通用句式。source ID 集合及 `source_types_checked` 与 result 的 source type 在语法上相符，但没有实际 query、章节、页码、命中词或排除理由，不能证明搜索真的发生。按实际读过的来源重写 `query_or_path` 和 result note，保留可复查 locator 与字段特定排除理由。 |
| B5 | `field-requirements.csv:55-58,181,190,193,200`；`search-log.csv:30-33,45-48`；`search-results.csv:44-51,74-81` | 搜索相关性失配。四个 benchmark gap 只列 whitepaper+CUDA Guide；其中 `REQ-R1-GA100-BENCH-POWER` 还声称“Reviewed microbenchmarks”，却没有 HPEC 或 random-access source。PHY clock/power 没查更相关且已选的 ISSCC；RAS BIST/SDE 没查已选的 GPU Memory Error Management。补入实际读过的相关来源，或把 requirement reason 改窄；不能只换 source ID，必须重读并记录具体结果。 |
| B6 | `field-requirements.csv:87`；`requirement-evidence.csv:2` | `REQ-R1-GA100-COMP-VENDOR-TOPS` 被判 `not_applicable`，理由只是公开峰值属于 A100 产品。full-GA100 die 在给定频率、精度、稀疏条件下的峰值在概念上仍适用；当前只是没有条件完整的公开值。改为 `not_found` 或 `not_public`，补相应搜索或证据，不能用 N/A 隐去潜在训练/推理差异因素。 |
| B7 | `selection-members.csv:4`；`source-selected-roles.csv:5`；`source-screening.csv:9`；`fact-assertions.csv:79-82`；`facts.csv:64-65` | MIG 610 只对 `FACT-R1-GA100-ID-FAMILY/NAME` 提供 `qualifies`，而 whitepaper 已直接 `supports` 这两个事实。它没有 assertion 或 requirement evidence 支撑 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`，A100-SXM4/PCIe→GA100 映射也不是本 GA100 die 卡不可替代的原子事实。删除两条 MIG qualifier assertion，把两个 identity fact 降为 `single_source`，screening 改 `lead_only`，删除 selected role/member，并把 selection run 重跑为六源，而不是接受自报 mandatory reason。 |
| B8 | `operations.csv:1`；更新样例 `operations.csv:85,90,106,123-130`；删除 `operations.csv:120-122`；`README.md:47` | operation 只有 table、动作和 PK，没有 `expected_preimage_sha256`、基线表 hash、正式事务 input binding 或 postimage hash。当前只检查“PK 仍存在”，基线内容漂移后仍会静默覆盖或删除。为 76 个 update 和 3 个 delete 绑定 canonical preimage hash，为 insert 绑定 expected-absent，并给全部正式输入、scope registry、payload 和预期 postimage 建原子事务 manifest；任一 hash 不同即拒绝执行。 |
| B9 | 候选 `objects.csv:2`、`selection-runs.csv:2`；正式 `主线对象范围.csv` 与 `主线选择运行范围.csv` 均无相应 ID | 临时镜像有 79 objects 对 78 scope rows、12 selection runs 对 11 run-scope rows；`OBJ-NVIDIA-GA100-DIE` 和 `SELRUN-GA100-DIE-20260821-V2` 缺登记，当前 `Test-ChipScope.ps1` 必然失败。若仍按旧门重放，必须把两个 registry 更新纳入同一事务；正式路线则应先按新合同登记 `FREEZE-NV-001 → SCOPE-0001 → OBJ-NVIDIA-GA100-DIE`，再生成绑定该 scope 的 run。两张表的正式全名可从 `Test-ChipScope.ps1:16-17,50` 直接解析。 |
| B10 | `selection-runs.csv:2`、`object-relations.csv:2`、全部 staged review rows；候选目录没有 coverage manifest、binding、approval 或 GA100 Markdown card | run 和 projection relation 都是 draft。新合同还要求 policy hash、expected-pair set、reachable inventory、closure hash、cutoff、scope、独立 approval 和 approved relation；候选全部缺失。合同事务通过后重新生成并独立签字，最后才生成资料卡。 |

## capability 与 topology 本体裁决

`special-capabilities.csv` 的 15 行不能作为同一种实体接受。四行有公开能力或机制，十一行只是 coverage placeholder。

| 行 | capability ID | 裁决 | 依据与边界 |
|---:|---|---|---|
| 2 | `CAP-M2NA-AMPERE-SPARSE` | 真实机制，可保留 | whitepaper 和 PTX 7.2 支持 metadata-directed `mma.sp`；datatype pattern 由 precision path condition 分开表达，不推断 runtime pruning 或 RTL。 |
| 3 | `CAP-R1-GA100-AMPERE-WARP-REDUCE` | 真实机制，可保留 | 公开 warp-wide reduction instruction；只到 warp scope，不是 Softmax unit 或网络 collective offload。 |
| 4 | `CAP-R1-GA100-GAP-ATTENTION-MOVE` | placeholder，删除 | notes 明言不主张公开 module、instruction 或 engine。 |
| 5 | `CAP-R1-GA100-GAP-COLLECTIVE` | placeholder，删除 | NVLink protocol 不等于 collective-offload engine。 |
| 6 | `CAP-R1-GA100-GAP-COMPRESSION` | placeholder，删除 | 当前只有 A100 L2 compression 的产品条件线索，且 requirement 仍 pending。 |
| 7 | `CAP-R1-GA100-GAP-DEQUANTIZE` | placeholder，删除 | 没有被接受的真实 entity assertion。 |
| 8 | `CAP-R1-GA100-GAP-KV-CACHE` | placeholder，删除 | 没有 GA100-bound KV-cache manager 证据。 |
| 9 | `CAP-R1-GA100-GAP-MOE-DISPATCH` | placeholder，删除 | 没有被接受的真实 entity assertion。 |
| 10 | `CAP-R1-GA100-GAP-MOE-ROUTE` | placeholder，删除 | 没有被接受的真实 entity assertion。 |
| 11 | `CAP-R1-GA100-GAP-QUANTIZE` | placeholder，删除 | format conversion 不能反推 dedicated quantizer。 |
| 12 | `CAP-R1-GA100-GAP-SOFTMAX` | placeholder，删除 | warp reduction 不能反推 Softmax unit。 |
| 13 | `CAP-R1-GA100-GAP-TOPK` | placeholder，删除 | 没有被接受的真实 entity assertion。 |
| 14 | `CAP-R1-GA100-GAP-TRANSPOSE` | placeholder，删除 | 没有被接受的真实 entity assertion。 |
| 15 | `CAP-R1-GA100-OFA` | 真实能力，可保留 | whitepaper 支持 optical-flow/stereo-disparity hardware；候选没有导入 A100 unit count 或 throughput。 |
| 16 | `CAP-R1-GA100-VIDEO-DECODE` | 真实能力，可保留 | whitepaper支持 hardware decode formats；候选没有导入 A100 NVDEC 数量、频率或吞吐。 |

`TOPO-R1-GA100-NVLINK-GAP` 的结论更直接：它是伪造实体，必须删除。候选 `topologies.csv:2` 和 `README.md:17` 都承认没有公开 topology instance 或 system configuration，只因旧字段合同要求 topology target 才创建该行。主键、外键和 target XOR 通过不能把“没有 topology”变成一个 topology。其九条 field requirement 应在新 coverage policy 下表现为“没有可达真实 topology target”或 card-scope mechanism gap，不得继续正式入库。

## 高风险事实抽查

对象边界方面，这版比 v1 有明显改进。`COND-R1-GA100-FULL-DIE` 明确排除 enabled A100、package、HBM stack、module、card 和 system；128 SM、512 Tensor Core、8192 FP32、12 memory controllers 等值均标为 full physical design，没有混入 108 SM、40/80 GB HBM、250/400 W、1400/1600 GB/s、64 GB cliff 或 14 groups。GA100 dense FP16 路径只保留 1024 FMA/SM/clock，没有乘二成 FLOP，也没有在缺频率时推导 full-chip TOPS。HPEC microbenchmark 与 random-access 两篇论文均停在 lead，不曾写成 GA100 fact。这些边界可以保留。

Ampere 投影方向也正确：`OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 从 GA100 die 指向 Ampere architecture；通用 SM、sparse、barrier、warp reduce 和 NVLink3 机制落在 architecture component/link，GA100 数量与 per-SM implementation 落在 GA100 entity。不过 relation 仍为 draft，且候选没有新合同要求的显式 projection manifest 和 relation approval，因此只能算方向正确，不能算发布闭合。

process、price 和 ISSCC 角色的处理基本合理。`FACT-R1-GA100-PHY-PROCESS` 由 whitepaper 精确支持 `TSMC 7 nm N7`，ISSCC 的 `7nm` 只作 qualifier；54B 对 54.2B 也只作取整 qualifier。裸片 price 被判 `not_found`，search 使用 whitepaper+ISSCC，且 requirement note 留下 price/pricing/MSRP/list price/cost/USD/dollar 关键词，没有把 A100 卡或模块价格写进 GA100。ISSCC 同时保留独立 LR-PHY 细节和 CUDA 8.0 冲突职责，进入 minimum set 是必要的；这与 MIG 610 的冗余身份 qualifier 不同。

NVLink 的真实 link 与伪 topology 必须分开。`LINK-R1-GA100-NVLINK-INTERFACE` 只表示 GA100 自有 interface class，不预设数量；LR-PHY 的 50 Gbps 被留在 condition，未当作 logical-link rate，NRZ/no-FEC/BER/CTLE/PRML/Viterbi 也限定在 architecture LR-PHY。这个 link 处理可保留。需要删除的是为了接 topology fields 而创建的假 topology，而不是删除真实的 NVLink interface 或 architecture link。

RAS 事实保留了 driver、external HBM/DRAM、InfoROM、application termination、service/reset 和 rare uncontained UCE 条件，没有把 DPO、row remap 或 containment 写成无条件全芯片能力；CUDA 11.0/PTX 7.0 也只表达 documented sm_80 interface，不声称已运行或已 benchmark。这里的事实边界可以保留。问题出在 RAS gap 的搜索证据：BIST/SDE 没有把已经入选的 RAS 文档列入结果，因此 `not_found` 状态尚未闭合。

## search、requirement 与 9×12 路径

候选确实消除了 v1 那种“query 声称查过很多 source，result 只列两份”的集合不等问题：独立比对没有发现 `source_types_checked` 与 actual result source type 不一致。但是这只解决了语法，没解决检索语义。所有 log/result 都是批量模板，没有 source locator；其中 33 组以 whitepaper+CUDA Guide 作为通用组合，混入 benchmark、clock、power、RAS 和 11 个假 capability gap。这个模式不能作为 `no_reliable_result` 的可审计证据。

9×12 precision path 的目标绑定是当前候选里最扎实的部分。九条 path、十二个数值 field、108 个键均唯一，FP16→FP16 accumulation path 已补上，TF32 output 与 conversion 分离，其他 path 没有从 accumulator 反推 output。结构上可以复用这份矩阵。不过 71 个 `not_found` 单元的搜索仍为 draft 模板记录；新合同要求 reviewed、completed、可定位的 no-reliable-result closure。修复时应保留 108 键集合，逐单元把真实 PTX/whitepaper locator 和排除理由写回，而不是重新机械生成另一套 108 行。

49 条 pending 可按域定位如下，便于 v3 逐项关闭：benchmark 在 `field-requirements.csv:207,208`；compute 在 `210-213`；derived 在 `214-218`；identity 在 `96,97,100,219,221,222,224,226,227`；interconnect 在 `228,233,234,236,239,240`；memory 在 `247-251,253,255,256`；physical 在 `183,186`；RAS 在 `194,258,259`；software 在 `260-262,265,266,268`；virtualization 在 `269-271`；假 compression capability 在 `61`。这些行目前都没有 search log。`FIELD-ID-DATA-CUTOFF` 不应继续检索为厂商事实，而应由先行合同迁移移到卡级管理元数据；其余项目必须经过实际检索后才能确定最终状态。

## reverse-removal 独立结论

ISSCC、whitepaper、固定 RAS PDF、CUDA 11.0、PTX 7.0 和 PTX 7.2 都有不可替代职责。ISSCC 独有 LR-PHY 电路细节及冲突证据；RAS PDF 独有固定版 GA100 DPO/row-remap/containment 流程；CUDA 11.0 与 PTX 7.0 分别承担 API maturity 和当期 machine-interface 边界；PTX 7.2 承担 datatype-specific `mma.sp`，虽与 7.0 同 family，也不是同内容职责。

MIG 610 不满足同一标准。候选给它的唯一正式作用，是给 whitepaper 已经直接支持的 `GA100` family/name 再加两条 `qualifies`。删除 MIG 后不会失去 GA100 die 的 identity fact，也不会失去 implements-Ampere relation；只会失去一条产品→裸片的辅助映射和“corroborated”标签。最小来源选择不能为了维持更高 evidence-state 名称而保留内容冗余来源。正确做法是移除 MIG qualifier、把两个 identity fact 降为 single source，并将 MIG 留在 lead 层供对象边界复核。随后应在修正全部事实、requirement 和 search closure 后重跑六源 reverse-removal；不能只把 member 数从七改成六。

## macOS 静态检查与未运行的 Windows 硬门

本机没有 `pwsh`、`powershell` 或 `powershell.exe`。因此 `Validate-ResearchData.ps1`、`Test-ChipScope.ps1`、`Test-SourcePool.ps1` 三道 Windows 硬门均未运行。这是 tool/runtime limitation，不是 sandbox denial、approval failure、remote service error，也不能被候选或本报告写成 PASS。

macOS 侧做了三类只读复算。第一，按当前 schema 和 validator 规则重写了独立静态检查，旧 32 表 union 为 0 error。第二，payload 复制到临时镜像后，正式 Python recovery/hash 脚本通过。第三，直接按 `Test-ChipScope.ps1` 和 `Test-SourcePool.ps1` 的确定性条件复算，已经看到两个硬失败：object/scope 为 79/78、run/scope 为 12/11；论文 manifest 为 111 行，但 `论文/` 实际有 113 份 PDF、315363681 bytes，另有两份未登记文件：

- `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI350P_PCIe_Card_Brochure.pdf`
- `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI455X_GPU_Brochure.pdf`

这两份 PDF 是正式 baseline 的既有差异，不是 GA100 v2 新增；但在总控裁决、修正 manifest 或恢复冻结基线以前，Windows SourcePool gate 仍不可能通过。范围注册表差异则由本候选新增 object/run 直接造成，必须由 v3 事务修复。

## 最小修复顺序

修复必须按依赖顺序推进。先完成并独立批准 `r1_ga100_13_contract_repair_design.md` 所定义的合同事务，包括 140-field、card lifecycle/cutoff、不可复用 scope、coverage policy、无 target mechanism gap、canonical manifest/binding/hash 和三运行时 fixtures。然后从该基线重新生成 GA100 v3，删除 12 个假实体及 20 条绑定 requirement，保留四个真实 capability、真实 NVLink link 和已核对的 108 个 precision path 单元。

接着逐项完成 49 条 pending 与全部 not_found 的实际来源检索，先修 benchmark、PHY clock/power、RAS BIST/SDE 和 vendor TOPS；每条 search 都写真实 query/path、locator、source type 和字段特定排除理由。事实集合稳定后，移除 MIG 610 的正式 qualifier 职责并重跑六源 reverse-removal。最后为 update/delete 和全包输入增加 preimage/input/postimage hash，把 scope registry 和 selection-run registry 纳入同一原子事务。合同 fixtures 先在 Windows PowerShell 5.1、PowerShell 7 和 Python 三端复算，再在包含 19 个 payload 的完整临时根上运行项目三道 Windows hard gate。三道项目门退出 0、合同 manifest 独立批准、GA100 Markdown 卡按最终闭包生成并反向校验后，才可重新申请 accept。

## 最终状态

`r1_ga100_14_atomic_staging_v2/` 的旧 schema 机械重放和部分高风险事实可以作为 v3 的输入，但整体裁决保持 reject。不得把本报告中的“旧 32 表静态 0 error”“recovery pass”或“108 个 path key 完整”解释为正式写入许可。

本文件已完成 `report-humanizer` 单文件扫描，未检出机器可识别的模板化表达。人工逆向复读从最终裁决、修复顺序、运行时边界、reverse-removal、search、对象边界和 blocker 表回到开头，重新核对了 1021 个 operation、19 个 payload、49 条 pending、12 个假实体、20 条假实体 requirement、141/140 field 边界、108 个 path 单元、79/78 与 12/11 scope 差异以及 113/111 PDF 差异；未发现数字、主体、证据强度或运行状态前后冲突。
