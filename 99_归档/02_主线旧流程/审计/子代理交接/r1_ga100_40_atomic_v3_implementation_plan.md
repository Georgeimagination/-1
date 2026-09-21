# GA100 atomic v3 实施蓝图：在合同 postimage 与 release-date migration 之后

状态：`blocked_preimplementation`。本文只定义将来可执行的原子实施边界，不创建 staging，不写入正式 CSV、合同、来源快照、资料卡或进度文件，也不把任何候选事实当作已发布事实。

## 结论与实施时序

GA100 不能从 v2 的 30 张 staging CSV 直接“修补”为正式包。正确起点是已批准的 contract v7 postimage，再叠加一个已经完成、独立审查并正式批准的全库 release-date migration。只有这两个 postimage 都成为不可变 preimage，GA100 才能以 `OBJ-NVIDIA-GA100-DIE` 的真实对象边界、scope mapping 的 seq2 转移和完整来源闭环进入一次 chip transaction。

R15 的结论需要精确表述。`r1_contract_15_design_v7_independent_review.md` 已接受 v7 设计；这不等于合同迁移已经实施。contract v7 implementation/transaction 的独立审查尚未发生，不能从 R15 的设计 accept 推出实施授权。release-date migration 的设计当前也仍在独立审查流程中；在其裁决为 accept、迁移实际完成并通过独立复核前，状态应写为 `pending`（或若审查退回则 `rejected`），而不是假定它已可执行。

顺序不能交换。先完成 source-pool-113 的正式推广及其独立前置复核，再实施并独立复核 v7 contract transaction；随后以该合同 postimage 为 base 执行全库 release-date migration，并完成其 transaction/coverage 审查；最后才冻结 GA100 的 H0 preimage 并执行本蓝图。GA100 transaction 不产生、也不裁决 release-date migration 的全库语义；它只能消费已批准的迁移输出。特别是，不能把 2020-05-14 的 Technical Blog 日期在旧语义下自行写成 GA100 release value，也不能用 A100 的 shipping、availability 或产品发布日期替代它。

| 前置门 | 最低可验收结果 | 当前状态及其含义 |
|---|---|---|
| source-pool-113 | 依 R38 的 00 至 11 顺序正式推广；前置 manifest/approval 完整，`Test-SourcePool` 三个 Windows runtime transcript 均 PASS | `blocked`；当前 live pool 仍是 pre-promotion，不能把候选 payload 当作正式 source pool 记录。 |
| contract v7 | 45/58/12 bootstrap membership、92 个唯一 identity、96 个 contract file input、11/24/35 transaction，以及 34 表/376 列/141 fields/77 enum groups/564 enum rows的 mirror 均通过 | `blocked`；R15 只接受设计，contract v7 implementation/transaction 的独立审查和实际迁移尚未发生。 |
| release-date migration | 按已裁决的“首次公开日期”语义完成全库 atomic migration、覆盖/来源闭合、approval 与 postimage 审查 | `pending_design_review`；不能预填 GA100 release date，更不能把该迁移揉入 v3。 |
| GA100 source ingestion | 所有将被使用的 family、version、endpoint、payload、screening 和 endpoint-level result 在正式 source schema 中注册，并与不可变字节一致 | `not_ingested`；r29、r37/r39 是来源裁决输入或孤立 staging，不是正式 source rows。 |
| GA100 package 与 Windows 发布门 | 本文 H0 至 H24 的每层 set-equal、独立 approval，以及 `Test-ChipScope`、`Validate-ResearchData` 和相应 runtime fixture 的三 Windows PASS | `not_run`；本机没有 PowerShell runtime，不能把未运行写为 PASS 或 FAIL。 |

这五个门中任一未满足时，唯一允许的工作是只读复核或修订实施设计；不得生成“临时正式化”的 v3 staging，更不得对现有 v2 或正式库做增量写入。

## 冻结 preimage、对象身份与 38-input scope 分支

### H0 的不可变输入

H0 不是当前 32 表的 live 目录，也不是 r14 的 staging。它是以下已批准工件的只读组合：

1. source-pool-113 成功推广后的 source-pool postimage、固定 payload hash/byte manifest、其 approval 和三 runtime PASS transcript；
2. v7 contract transaction 的完整 postimage、注册表、factor policy、表 image、rollback/transaction manifest 与 approval。该状态的结构计数必须仍为 34 张表、376 列、141 fields、77 个 enum group、564 个 enum row；
3. 完成且独立批准的 release-date migration postimage，以及它的 coverage/transaction approval。它是 GA100 `首次公开日期` 语义的唯一来源；
4. 冻结的芯片 scope input，尤其是 `FREEZE-NV-001 -> SCOPE-0001` 的 raw-only freeze、当前 49 行 `scope-object-mapping.csv` base snapshot 和 seq1 的原字节；
5. 已固定但尚未自动成为正式记录的内容字节：GA100 whitepaper/ISSCC/CUDA/RAS 固定资料、official-web v2 成功 snapshot、r37 的 Matrix/MLCommons/SEC asset manifest，以及它们的 family map、HTTP header、hash、byte count 与 capture qualification；
6. 批准合同、字段字典、模板、reachable-target policy、forced benchmark policy、factor policy、source-family dedup policy 和预分配 transaction ID。

第 5 项只是 builder 的候选原材料。任何 `END-PROP-*`、`SRCVER-GA100R37-*` 或 r14 PK 在 H0 都不能因“文件存在”而被视为正式 source/fact/requirement。

### GA100 的对象与关系

原子包唯一的新芯片对象是 `OBJ-NVIDIA-GA100-DIE`：NVIDIA 的 full physical GA100 design，object type 为 `die`。它表示公开的完整 128-SM 物理设计，不等于启用 108 SM 的 A100 SKU，不等于 A100 PCIe/SXM module、80 GB HBM2e 产品、DGX host/system，也不等于 A100/H100 integrated circuit 的监管对象。所有 facts、condition、source assertion 和 benchmark result 都必须先判断这一主体边界。

对象 identity、scope allocation、mapping 和 card identity 必须在同一 chip transaction 内出现。对象与 Ampere 的唯一实现关系为：

```text
OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE
  subject: OBJ-NVIDIA-GA100-DIE
  predicate: implements
  object: OBJ-NVIDIA-AMPERE-ARCH
```

该关系不是通用的事实复制许可。它只允许合同明定的 `FIELD-ID-ARCH` relation projection；architecture 主语的 design objective、target-use positioning、vendor positioning、CUDA/PTX 软件接口和 Tensor Core ISA 仍需保留 architecture target、条件与来源主语。不能借 `implements` 把 A100 产品数字、system benchmark 或 Ampere 宣传语无条件写给 full GA100 die。

### 固定选择 mapping override，而不是 37-input 分支

R38 固定的合同 postimage 中，`SCOPE-0001` 的 EffectiveTip 是：

```text
(FREEZE-NV-001, SCOPE-0001, 1, empty,
 OBJ-NVIDIA-GA100-DIE, pending_formal_object_create, needs_resolution)
```

因此 GA100 必须走 mapping-override 分支，不能走“已 mapping 的同对象”37-input 分支。其精确 file-input 集合是：

```text
ChipRequired38 =
  CommonChipBase34
  union {mapping base snapshot, mapping post snapshot}
  union AuthorizationTwo
```

也就是 34 个 common input、两张 mapping snapshot 与两个 authorization input，合计 38。这个数是 chip package 的 file-input contract，不是 operation 数量，更不能被误写成“38 条操作”。H1/H10/H18 都必须保持 seq1 行原样，并只 append：

```text
mapping_event_id = MAPEV-SCOPE-0001-0002
mapping_event_seq = 2
card_object_id = OBJ-NVIDIA-GA100-DIE
mapping_status = mapped
approval_status = approved
mapping_basis = chip_identity_mapping_approved_v1
```

post mapping snapshot 必须是原 49 行逐字未改加这一行，恰为 50 行。mapping row 的 reviewer/date 由独立 authorization 填入，绝不能由对象名称或资料日期猜测。H3、H10、H18 与 apply 后的 live gate 都要同时验证：对象存在、identity/card identity 与 `SCOPE-0001` 一致、seq2 是最高的 non-rejected event、而且 six forced benchmark pair 解析到该对象。只创建对象不 append seq2，或只 append seq2 不创建对象/identity，均为阻断错误。

## v3 builder 的精确输入与输出集合

builder 的输入是一组经 hash 绑定并带角色的集合，输出是由 complete delta 导出的 operation ledger。实现前必须定义以下输入和输出，并在每层以 PK 集、row hash、payload hash 和目标表集合作双向 set-equal。

| 角色化输入集合 | 必须包含的内容 | 生成的候选输出集合 |
|---|---|---|
| `I-contract` | v7 postimage 的全部 34 表、schema/enum/field/factor/coverage policy、stable artifact、contract approval | 合法字段、enum、table path、target-kind、status、factor、coverage 和 authorization 约束。 |
| `I-release` | 已成功的 release-date migration postimage 与独立 approval | GA100 release-date pair 的 immutable terminal input；v3 不生成新的 release-date 语义或替代值。 |
| `I-scope` | raw freeze、scope registry、49-row mapping base、allocation policy、`ChipRequired38` role set | `OBJ-NVIDIA-GA100-DIE`、identity/card identity、`OREL-*`、seq2 mapping post snapshot 与 mapping-bound coverage manifest item。 |
| `I-source-bytes` | 每个候选 source/version/endpoint 的本地 byte path、body/header hash、byte count、capture status、family map、fixed locator | family/version/endpoint/payload-copy、screening、assertion、search/result 和 requirement-evidence 候选；失败/duplicate bytes 不得伪作 content evidence。 |
| `I-semantic-seed` | r16/r20/r21/r22/r23/r24/r37 已接受的内容边界、r18 salvage 分类、r39 acceptance boundary | real entity/fact/assertion/condition/path、exact search scope、wrong-subject/duplicate result、candidate requirement terminal status。 |
| `I-reachability` | 对象、relation、component、link、memory、capability、precision path、condition set 与 projection policy | H4 的 reachable inventory、H5 的 expected field-pair 和 factor obligation 全集；不以人工 15 行或旧 108 行代替。 |
| `I-selection` | source screening rule、family dedup rule、selected-role contract、reverse-removal rule | selection run/member/role、逐 family 反向移除结果及其不可替代职责。 |

任何 source、target、pair 或 requirement 只有在相应输入集合与 H0 hash 对齐时才可进入 H1。builder 的输出最低包含：对象/关系与实体表候选、facts/assertions、source family/version/endpoint/screening、search log/result、requirement/factor/evidence/binding、selection/reverse-removal、coverage field/manifest、完整 planned post、exact delta、authorization item、operation/payload inventory、isolated mirror、image、rollback、transaction manifest 和 journal event。operation 与 payload item 必须由批准的 complete delta 生成；operation 总数只在 H17 materialize 后计算。

## 真实实体、可接受事实与边界条件

### 可进入 v3 的真实结构

下列 v2 内容可作为语义 seed，但每一行仍须按 H1 的正式 PK、source version、endpoint、condition 与 postimage 重新绑定。它们不是“复制 r14 的行”。

| 实体类别 | 可语义复用的真实集合 | v3 实施要求 |
|---|---|---|
| object/relation | `OBJ-NVIDIA-GA100-DIE` 与 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | 保留 label、die scope 与 relation direction 的语义；以 38-input mapping、identity/card policy、relation projection manifest 重新创建。 |
| components（11） | `COMP-R1-GA100-{GPC,TPC,SM,FP32,TENSOR,MEMCTRL,L1SMEM,L2,REG,OFA,VIDEO-DECODE}` | 仅记录 GA100 full-design 的真实结构/固定功能模块；SM、per-SM memory、Tensor path 都带 full-die 或 per-SM 条件。A100 108 SM、module HBM 容量、product peak 不得混入。 |
| links（2） | `LINK-R1-GA100-NVLINK-INTERFACE`、`LINK-R1-GA100-PCIE4-X16` | 真实 interface class，不先验断言 topology、degree、hops、logical/physical link count、aggregate bandwidth 或 card host endpoint。可接受的 full-GA100 NVLink physical/lane/directivity事实须由直接来源另行精确 target/condition。 |
| memory levels（3） | `COMP-R1-GA100-REG`、`COMP-R1-GA100-L1SMEM`、`COMP-R1-GA100-L2` | register file、combined L1/shared、L2；192 KB combined L1/shared 和 256 KB register file 必须是 per-SM physical capacity，不能相加，也不能乘成未公开 aggregate。 |
| capabilities（4） | `CAP-M2NA-AMPERE-SPARSE`、`CAP-R1-GA100-AMPERE-WARP-REDUCE`、`CAP-R1-GA100-OFA`、`CAP-R1-GA100-VIDEO-DECODE` | sparse 是 datatype-specific `mma.sp`/metadata-directed ISA 能力，不代表 runtime discovery；warp reduction 不是 collective/Softmax；OFA/video decode 不补 count 或 throughput。architecture capability 的 source/condition 不能伪降成 die-local engine。 |
| conditions（14 seed） | `COND-M2NA-AMPERE-2OF4`、`COND-R1-GA100-AMPERE-BF16-SP24`、`COND-R1-GA100-AMPERE-CUDA110-SM80`、`COND-R1-GA100-AMPERE-INT4-PAIR48`、`COND-R1-GA100-AMPERE-INT8-SP24`、`COND-R1-GA100-AMPERE-NVLINK-LR-PHY`、`COND-R1-GA100-AMPERE-TF32-SP12`、`COND-R1-GA100-FULL-DIE`、`COND-R1-GA100-PER-SM-MEMORY`、`COND-R1-GA100-RAS-CONTAINMENT`、`COND-R1-GA100-RAS-DPO`、`COND-R1-GA100-RAS-ROW-REMAP`、`COND-R1-GA100-SM-FP16-DENSE`、`COND-R1-GA100-SM-PROCESSING-BLOCK` | 重建时保留 datatype、sparsity pattern、software version、direction、aggregation scope、measurement scope、full-die/per-SM/RAS external dependency。必要时可新增精确 condition，但不可用无条件 facts 替代。 |

GA100 physical-design 的可接受 facts 以 direct source assertion 或批准公式为限：128 SM、8192 FP32 CUDA cores、512 Tensor cores、12 个 512-bit memory controller、N7/area/transistor 等直接公开设计事实；可由同一已批准公式得出的 HBM interface 为 `12 × 512 = 6144 bit`，且公式输入、constant、unit、arity 和 output descriptor 必须在 H2 通过 v7 formula contract。NVLink 只在 full-GA100 source 直接给出 physical links、per-direction lanes/rate、logical-link rate或全部启用条件时，才能记录 12 physical NVLink、每方向 4 lane、50 Gbit/s/lane、25 GB/s/方向、200 Gbit/s/logical link、12 links enabled 时 300 GB/s/方向和 600 GB/s bidirectional aggregate；不能从 A100 的 5120-bit HBM bus 或 product datasheet 转写。

L2 compression/coherence/pooling、on-die ECC 的 scope、PCIe、sparse Tensor Core 和 per-SM datapath 必须保留各自的 condition/source target。on-die ECC 只能对应公开支持的 L2/L1/register-file scope；external HBM、NVLink 和 MIG 的 protection 另立 scoped facts，绝不可概括成“GA100 全芯片 ECC”。

### terminal requirement 状态：value、not_found、N/A 与 pending

H7 中每个 required pair 必须具有一个且仅一个 terminal adjudication。`value_available` 需要 direct assertion 或批准公式；`not_found` 需要实际 endpoint-aware search 和 `no_reliable_result` plus per-endpoint `checked_no_support`/`duplicate`；`not_applicable` 需要合同中的目标/字段 predicate 及 evidence；`not_public` 必须有明确的官方“不公开”表述，不能由沉默推断。`pending_verification` 只能存在于 H1 至 H7 的未闭合工作队列，不能进入 H10/H13/H24 的发布性 coverage 或 card。

以下边界是 v3 的强制要求，而不是可选措辞：

| 类别 | 必须执行的裁决 |
|---|---|
| 可接受 value | 上表真实实体对应的直接设计事实；approved formula 的 6144-bit interface；受条件约束的 NVLink、memory/RAS 和 CUDA/PTX semantics；Ampere architecture 的三个 identity pair；Matrix Guide 支持的 Tensor/GEMM utilization-limit。 |
| 必须重搜后终结为 `not_found` 或 direct value | die clock、die power、vendor TOPS、bare-die price、physical array/accumulator、instruction tile、raw memory transfer/latency、checkpoint/migration mechanics、GA100 die 的 design/target/vendor positioning、market access，以及全部 contract-generated 未闭合 pair。没有可靠正证时必须建实际 search closure，而不是保留旧 pending。 |
| 仅在 predicate 成立时的 `not_applicable` | INT8、INT4、Binary 三条 numeric path 的 rounding/subnormal 共 6 个必需 N/A；全 physical die 的 cooling/form factor/HBM stacks/interposer/package 等对象类型 N/A；relation quantity/region/SKU 等 relation/type N/A；`FIELD-PHY-DIE-COUNT` 仅在 release migration 后批准 policy 允许时作为正常 structural N/A。不得把 vendor TOPS、缺失 benchmark 或假 capability 填 N/A。 |
| 当前 pending 的处理 | release-date pair 在 release migration 前不得由 v3 处理；migration 完成后其输出是 H0 输入。RAS checkpoint、MIG raw checkpoint/Live Migration、unresolved performance/physical fields若仍没有 terminal evidence，则 H7 必须形成有范围的 `not_found`；若尚未完成搜索，阻断 H10/H13/card，而不是发布 pending。 |

旧的 49 条 `pending_verification` 不能继承。按 r18，其中一个 `REQ-R1-GA100-CAP-GAP-COMPRESSION` 随假 entity 删除，一个 data-cutoff requirement 迁移为 card metadata/contract input，剩余项逐 pair 重新搜索、重判为 value/not_found/not_applicable/not_public，或阻断实施。release-date 是唯一不能在 v3 内重判的例外，因为它已移交到前置的全库 migration。

### CUDA、MIG 与 RAS 的对象边界

CUDA/PTX 内容的主语是 `OBJ-NVIDIA-AMPERE-ARCH`，不是“GA100 已公开 RTL”。`nvcc`/`cudart` Toolkit 11.0.3、`sm_80`、PTX virtual ISA、`cp.async`、`mbarrier`、`redux.sync`、CUDA Graph、WMMA、NCCL/框架/动态 shape/量化工具的 documented support 都应在 software/architecture target 和精确 software version 条件下建立。PTX 只表达 programmer-visible ISA semantics，不能推出 SASS、physical accumulator、array layout、RTL 或 actual runnable test。CUDA 8.0 与 CUDA 11.x 的文献差异作为 source/assertion conflict 保存，不能私下改写成“文档笔误”。

MIG 的真实 virtualization evidence 可以在其产品/driver/software条件下服务 VIRT requirements；它不得再充当 GA100 name/family identity source。旧 MIG610 identity assertion/selected role/member 必须删除；MIG guide 默认 `lead_only`，只有某个 VIRT fact 在 source selection 中证明它是不可替代时，才能以 virtualization role 被选中。GI/CI 的 isolation、shared memory/engine、dedicated SM、driver/profile/lifecycle条件必须拆开；不得把 CI 写成独立 address space，不得把 product vGPU Live Migration/Suspend/Resume/time-slice 说成 raw GA100 die 原生 lifecycle，也不得称为 SR-IOV 等价物。

RAS 只写可定位的 scope。BIST 可作为 telemetry/Field Diagnostics 的 `value_available`，但没有公开 BIST structure 时对应 factor 是 `not_found`；SDE 要在白皮书、RAS PDF、R595 等已计划端点实际搜索后再终结。DPO/row remap/contained UCE 都须标记 external HBM、driver、InfoROM、reset/service window 或 rare uncontained exception 等条件。没有这些条件的“GA100 可靠性”总括事实不可进入 H1。

## 9×12 precision-path closure

H5 的 expected-pair builder 必须产生九条 precision path 乘十二个 numeric fields 的全集，恰为 108 个 `(precision_path_id, field_id)` key。它不能以旧的 108 条 closure status、r37 的 15 行增量或人工计数替代。九条 path 为：

```text
PPATH-M2NA-AMPERE-TENSOR-FP16
PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16
PPATH-M2NA-AMPERE-TENSOR-BF16
PPATH-M2NA-AMPERE-TENSOR-TF32
PPATH-M2NA-AMPERE-TENSOR-FP64
PPATH-M2NA-AMPERE-TENSOR-INT8
PPATH-R1-GA100-AMPERE-TENSOR-INT4
PPATH-R1-GA100-AMPERE-TENSOR-BINARY
PPATH-R1-GA100-TENSOR-FP16-DENSE
```

十二个 field 是 operand A、operand B、product、programmer-visible accumulation、physical accumulation、output、rounding、scaling mode、scaling granularity、saturation、subnormal、sparsity。operand A/B 与 programmer-visible accumulation 的既有 direct value 可作为 evidence seed；其余仍要依 exact path/condition 重建 requirement、assertion、search 和 evidence。H7 的最终状态目标是 53 个 `value_available`、49 个 `not_found`、6 个 `not_applicable`，但这只是 pair-status closure 的验收计数，不是 fact 数、search 数或 operation 数。

| 路径组 | 必须保留的精确语义 |
|---|---|
| FP16、BF16、TF32 | FP32-output 或 FP16-ACC16 output 仅按 exact `dtype` path。rounding 和 subnormal 的 `not_specified` 是 PTX 直接 value，不是 not_found。product encoding、physical accumulator、scaling mode/granularity若无直接公开规范则为 not_found。稀疏 pattern 仅对 matrix A、`sm_80`、PTX 7.1+的 datatype-specific condition 成立。 |
| FP64 | output FP64；默认 `rne`，并保留 `.rz/.rm/.rp` 的原始 modifier/condition。若 enum 未承载全部 option，先走合同扩展，不能静默丢弃。matrix-MMA subnormal 未获直接承接时保持 not_found。 |
| INT8、INT4 | output INT32；rounding/subnormal 为 N/A。`.satfinite` 存在时 saturate、缺省 modifier 时 wrap，必须是两个 instruction-condition facts，不能把其中一种写成无条件路径属性。INT4 sparsity 是 pair-wise 4:8，不得改写为普通 element-wise 4:8。 |
| Binary | output INT32；rounding/subnormal 为 N/A；saturation 和 sparsity没有该 instruction syntax 的直接支持时为 not_found。XOR+POPC 描述不能凭空给 product encoding。 |
| GA100 specific dense FP16 | `PPATH-R1-GA100-TENSOR-FP16-DENSE` 只承接 GA100 per-SM、per-clock 的 published dense FP16/FP32 FMA 条件。不得从 Ampere PTX 的 D type、rounding、subnormal 或 sparsity自动填值；此处没有 `FIELD-ID-ARCH` 例外。 |

每一个 `not_found` 都要有真实 endpoint/locator 的 target-specific search result，明确所查 syntax/section和排除理由。每一个 N/A 都要带 integer/logical path predicate，不用“缺资料”冒充适用性判断。H10 前必须做 `(expected keys == terminal keys)` 双向相等以及 `{value=53, not_found=49, N/A=6}` 复算。

## 强制 benchmark、Ampere 三对 identity 与 r37 来源裁决

### 六个 benchmark pair 必须 include

下列 exact pair 均是 v7 forced rule，H5 不得以 bare-die、no-reachable 或 informal exclusion 跳过：

```text
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-POWER
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-ENERGY-PER-TOKEN
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-TOKENS-PER-JOULE
OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-UTILIZATION
```

每条都由 H1 创建正式 search candidate、H7 生成一个 `no_reliable_result` terminal result，并为每个实际 endpoint 创建 `checked_no_support` 或 `duplicate` result。预期结论是 six `include/not_found`，但只有完整 source range、端点结果、requirement evidence 和 selection/reverse-removal 已写入 H10 后才算闭合。不能从 A100 TDP 推 workload power，不能从 samples/s 和 TDP 推 J/token，不能对缺失量取倒数，也不能用 HPEC cycle、GB/s、RAND、Matrix microbenchmark 或 product datasheet 冒充完整 full-GA100 workload benchmark。

`SRCVER-GA100R37-MLCOMMONS-COMMIT-36D324B5` 的完整 commit 是 `36d324b502175621063a478fcbf6d2cb9421ca34`。它的 system JSON、Offline summary、SingleStream summary、两个 scenario directory 和 commit identity endpoint 可以关闭这些 search 的错误主体：对象是 `NVIDIA DGX A100 (1x A100-SXM-80GB, TensorRT)` system-under-test，而不是 full GA100 die。`3560.73 samples/s` 和 `0.001551870 s` 只能留在 `checked_no_support: wrong_subject_system_under_test` 结果中，不能成为 GA100 fact；commit HTML 是 identity duplicate，不能算第二独立来源。所选 directory 未列 power child 只说明该 directory，不能外推为整个仓库不存在 power/MaxQ。

### Matrix utilization-limit 的正确正证

`SRCVER-GA100R37-NVIDIA-MATRIX-GUIDE-CAPTURE-20260821` 与 `END-PROP-GA100R37-MATRIX-LOCAL` 可支持：`COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT` 在 A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4、datatype、matrix dimension/tile 的 carrier condition 下，具有 alignment requirement、small-GEMM tile efficiency/parallelism trade-off 和 tile quantization 三类限制。H1 应将它们拆成三条 assertion，不要合成无条件“GA100 utilization”数值。

Matrix Guide §3.2 的 108-SM wave/tail-wave、117-tile例子属于 A100 enabled configuration。H1 必须生成该 locator 的 `checked_no_support` 或 rejected assertion，理由为 `wrong_enabled_scale_108sm_not_full_ga100_128sm`；严禁把 108 机械替换成 128，或把该 component/GEMM 条件值改成 six benchmark 中的模型级 utilization。

### Ampere architecture 需要三个正值，GA100 die 需要各自的负证据

H5 必须同时生成以下 Ampere architecture exact pairs，并在 H7 以 whitepaper p.38/p.11 的 direct assertion 终结为 `value_available`：

```text
OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE
OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-TARGET-USE-POSITIONING
OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-VENDOR-POSITIONING
```

其语义分别是：面向 existing DNN 的 strong scaling、对该 workload 的保守 target-use positioning，以及 NVIDIA 对 Ampere 可编程性/latency/software complexity/performance-per-watt 的厂商定位。它们不通过 `implements` 下放给 die。相同三 field 对 `OBJ-NVIDIA-GA100-DIE` 也必须由 builder 生成，并用 `SEARCH-PROP-GA100-DESIGN-R37`、`SEARCH-PROP-GA100-TARGET-R37`、`SEARCH-PROP-GA100-VENDOR-R37` 和实际 endpoint result 终结为 `not_found`，而不是让 pair 消失。

### SEC 是 wrong-subject 负证据，不是 GA100 market fact

`SRCVER-GA100R37-NVIDIA-20220731-10Q` 的 canonical endpoint `END-PROP-GA100R37-SEC-10Q-LOCAL` 对 A100/H100 integrated circuits及相关 DGX/system export license requirement 有正面内容；对 `OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` 则只是 `checked_no_support: wrong_subject_a100_ic_and_system_not_full_ga100_design`。H7 因此应让 `SEARCH-PROP-GA100-MARKET-R37` 收敛为 GA100 exact pair 的 `not_found`，不把 SEC 内容降写为 GA100 die market-access value。SEC gzip retry 是 transport duplicate；403 响应是 remote access-policy失败，不具证据资格。

## source、screening、search、evidence、selection 与 reverse-removal

### 从 fixed bytes 到正式 source rows

r29 已接受 official-web v2 的隔离 staging 质量，而非正式入库：29 manifest entries 中 27 个成功 snapshot、2 个无 payload 的拒绝项；22 HTML 和 5 PDF 的 bytes 必须继续用本地 fixed snapshot，不允许以在线 URL 重抓替代。r37/r39 也只接受来源内容裁决：r37 的 11 assets 共有 8 canonical、2 duplicate、1 failed attempt，r39 明确它们尚未形成 formal source/endpoint/search/result/selection closure。H1 必须先将每个可用 source family、version、actual endpoint 与 payload-copy 作为正式候选注册，再允许其承载 fact/assertion/search evidence。

family 去重必须遵循已审映射：Newsroom HTML/PDF 为一个 family；40 GB/80 GB Product Brief 是一个 family 的版本；MIG latest/supported GPUs/r580/r610 是一个 MIG User Guide family；PTX 7.0/7.2 是一个 revision family；cuSPARSELt Guide 与 Release Notes 是两个 work family；TensorRT Release Notes、Support Matrix、Developer Guide 是三个 family。MLCommons 的 commit API/HTML 是同一 commit identity view，SEC canonical/gzip/403 是同一 filing version 的不同 capture，不得把 endpoint 数量冒充独立来源数量。

对每个 accepted payload，H1 的 source chain 至少要有：family identity、source version（含日期/版本/commit）、endpoint URL 和 local immutable path、body/header fingerprint、capture qualification、screening verdict、actual locator、fact assertion 或 search result。`duplicate` endpoint 可以留为查重证据，但不能产生第二个 content assertion；failed endpoint 只保存失败分类，不可支持 `not_found` 结论。历史 403 是 remote service access-policy response，历史 Matrix DNS问题是 sandbox network/DNS denial；它们不是“资料不存在”的证据。

### endpoint-level search 和 requirement evidence

每个 `not_found` requirement 在 H7 至少拥有一个显式 search range，range 内各 canonical/duplicate endpoint 均有结果行。搜索行必须保存关键词、实际 section/page/JSON path、target/field、version、范围边界和 source-specific排除理由；不得继续使用 `searching for evidence`、`no evidence found in planned sources` 一类模板句。六 benchmark、GA100 market access、GA100 三个 die identity pair、未公开 physical/performance fields、MIG/RAS/CUDA边界都按此标准完成。

`requirement-evidence` 只在 status/predicate 与 evidence role 对应时生成：direct assertion 支持 value，formula input/descriptor 支持 derived value，policy plus object/type predicate 支持 N/A，actual search/result chain 支持 not_found，官方明确拒绝披露 statement 才支持 not_public。对同一 pair 的 source conflict、wrong subject和duplicate均留在 assertion/search-result，而不把它们压扁成一句 coverage notes。

### source selection 与 reverse-removal

H8 从 H7 的完整 terminal closure 构造新的 GA100 object-scope selection run。它不复用 `SELRUN-GA100-DIE-20260821-V2`，也不继承旧 member/role 的结论。每个 selected family 必须有不可替代职责：identity/core specification、architecture mechanism、independent validation、conflict evidence、status/version evidence 或 v7 的 coverage-obligation evidence；同一 publisher 的修订链只能按职责计数，不能借多 endpoint 增加 corroboration。

reverse-removal 对每个 selected family 逐一运行：假设移除该 family，重新计算 value support、formula input、endpoint result、not_found search range、source coverage、role obligation 和 six benchmark closure。仍有不可替代职责则保留；可由同 family revision 或其他正式 endpoint 完全覆盖时移除。MLCommons 和 SEC 即使不提供 GA100 positive fact，也在相应 wrong-subject `not_found` 链未被其他可靠 endpoint覆盖前具有不可替代的 negative-search职责。MIG610 绝不能作为 identity member；只有实际 VIRT evidence 保留它的不可替代性时，才可作为 virtualization member。每次移除和保留都输出 reason、affected requirement IDs、before/after closure hash；这就是 H8 的 reverse-removal result，而不是一段说明文字。

## v2 salvage、删除与重建边界

v2 的有效内容要与它的 transaction 和模板化链彻底分离。以下分类逐项继承 r15 reject、r18 salvage、r20/r21/r22/r23/r24/r28/r32/r35/r37/r39 的裁决；“可语义复用”永远不等于可以复制旧 PK、旧 source ID、旧 selection、旧 operation 或旧 coverage 行。

| v2 项 | 可语义复用的部分 | v3 必须删除或重建的部分 |
|---|---|---|
| object/implements relation | `OBJ-NVIDIA-GA100-DIE` 的 die 边界、`OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 的方向 | 重新绑定正式 scope allocation、seq2 mapping、identity/card policy、projection manifest、row hash 和 authorization。 |
| 实体 rows | 11 component、2 link、3 memory level、4 real capability、14 condition 的实体语义；旧 5 条 precision-path identity | 以 9 条完整 path 和 v7 schema重建。旧 review status、payload hash、operation 不继承；任何 A100 product前提重新筛掉。 |
| facts/assertions | 87 个不改值 fact、107 个非 MIG assertion 的 raw value/unit/condition/locator可作 source-reading seed | 两个 identity fact须移除 MIG qualifier并改为 single-source；两条 MIG identity assertion删除。所有 fact/assertion 都要在正式 source endpoint与新 contract field上重新落 row/hash。 |
| requirements/evidence | 102 条候选 requirement（90 direct value、12 structural N/A）及 6 条 bare-die N/A evidence可作 policy/input seed | 149 条 revise，全部 terminal status、factor binding、evidence、coverage重新生成；旧 49 pending 不能保留；vendor TOPS N/A 删除；data-cutoff requirement/coverage row移为 metadata/contract input。 |
| numeric closure | 108 path×field key、path identity、field identity与适用性判断可作 expected-pair seed | 旧 requirement ID、draft status和旧 34 value/71 NF/3 N/A 分布全部丢弃；由新版 9×12 builder得到 53/49/6 terminal closure。 |
| source chain | 8 family、10 source version、28 endpoint、19 payload 的 fingerprint/bytes/path以及 9 source content + 1 note revision可辅助重读 | 正式 family/version/endpoint/payload-copy、screening、role、source coverage 和 actual endpoint资格重新注册；ISSCC notes去除“MIG identity chain”描述；MIG610 保持 lead，默认不入 minimum set。 |
| selection | 六个非-MIG member可能仍有不可替代职责 | 删除 MIG identity role 和 `SELMEM-R1-GA100-V2-MIG610`；不使用旧 selection run，按 H8 全量重跑并保存逐 family reverse removal。 |
| operations/coverage/card | 无 | 全部 1021 v2 operations、140 field coverage行和 13 domain completeness结论重建。旧 ledger 缺 preimage/input/postimage binding，不能作 transaction evidence。 |

以下 12 个假 entity 在 H1 之前就应从 v3 candidate universe 排除：11 个 `CAP-R1-GA100-GAP-*`（attention move、collective、compression、dequantize、KV cache、MoE dispatch、MoE route、quantize、Softmax、Top-k、transpose）和 `TOPO-R1-GA100-NVLINK-GAP`。它们对应的 20 条 requirement、17 条 template search、34 条 template result、11 条 capability coverage 均不应复活。机制缺口只可表达为 card-scope factor requirement/search；不能为了让 field 有 reachable target而制造 capability或topology实体。真实 `LINK-R1-GA100-NVLINK-INTERFACE` 仍然保留，但绝不伪造成 topology instance。

其余 115 条 search 和 216 条 result虽不随假 entity删除，也全是 v2 模板行：需要使用 actual endpoint、关键词、locator、checked scope、subject边界和字段专属排除理由重建。132 条旧 search、250 条旧 result一个都不能“语义复用为正式负证据”。r15 指出的 v2 B1 到 B10 因而全部得到对应处理：假 entity、old cutoff、pending、template search/result、source relevance、TOPS N/A、MIG selection、缺 preimage、scope registry mismatch和缺 policy/manifest均不被带进 H10。

## H0 至 H24 的强制 DAG 与 transaction 产物

以下层次直接采用 R38 的依赖方向。任何实现若让同层候选相互决定、让 approval 回填较低层 hash，或让 live 状态重选 37/38 分支，都应失败并保留现场。H0 至 H24 定义了构造授权与恢复时必须遵守的 DAG。

| 层 | 产物和不可跳过的约束 |
|---|---|
| H0 | 已应用的合同/迁移 inputs、使用时不可变 mapping base、source/candidate raw bytes、预分配 transaction ID。 |
| H1 | 所有 direct、non-derived row/payload candidate：object/identity/relation/mapping seq2、实体、fact/assertion、source/screening/search/result/evidence。 |
| H2 | 只由 H1 计算的 formula-derived post row candidate。 |
| H3 | H1/H2 与 immutable base 组合的 preliminary semantic post。 |
| H4 | 从 H3 得到 reachable inventory 和 formula-use verification。 |
| H5 | 从 H4 得到 expected field-pair 与 factor-obligation builder output。 |
| H6 | 从 H5 得到 coverage target、reachable binding、factor-binding rows。 |
| H7 | 从 H1/H6 得到 terminal requirement/factor adjudication，包括 endpoint-aware terminal evidence closure。 |
| H8 | 从 H7 得到 selection 与 reverse-removal result。 |
| H9 | 从 H7/H8 得到 coverage-field rows。 |
| H10 | H1/H2/H6 至 H9 加 immutable base 的 complete planned post。它必须同时含 object、identity、seq2 mapping和所有 coverage。 |
| H11 | `ExactDiff(H0 base, H10 post)` 的 complete planned delta；不可由旧 1021 operations 填充。 |
| H12 | 从 H4 至 H11 得到 transaction coverage closure set。 |
| H13 | 绑定 H10 object/mapping和 H12 closure 的 coverage manifest。 |
| H14 | coverage approval。 |
| H15 | 由完整 H11 delta 构建 chip operation/payload authorization。 |
| H16 | authorization approval。 |
| H17 | materialize 实际 operation、payload 和 file-input inventory；此层才有可数的 operation total。 |
| H18 | 将 H17 应用于 H0 immutable base 所得 isolated full post mirror，必须与 H10 exact set-equal。 |
| H19 | 从 H17/H18 派生 table images。 |
| H20 | 从 H17/H19 派生 rollback rows。 |
| H21 | rollback manifest。 |
| H22 | transaction manifest。 |
| H23 | transaction approval。 |
| H24 | journal events；apply/replay/rollback均以 H0/H17/H22 的不可变输入恢复，不能从后写 live 目录重新推断。 |

H15 之前不能 materialize operations；H18 之前不能产生正式 table image；H23 之前不能 apply；H24 之前不能把 card 或 coverage 说成发布。card candidate 已在 H10 作为受管 payload 被规划，但同样要到 H24 的成功 journal 与 post-apply byte-equality verification 后才可称为已发布。对于 GA100，H13 仍只按冻结的 58-key coverage manifest schema 绑定 `MAPEV-SCOPE-0001-0002` 的 row hash、`OBJ-NVIDIA-GA100-DIE` row hash、six forced benchmark closure、9×12 closure、Ampere three-pair closure、factor obligations、source selection/reverse-removal和 13-domain coverage closure；不得擅自新增 card payload hash key。card payload 的绑定由 H10/H11、H15/H17、H18 和 apply 后的重渲染 byte-equality 完成。

## card 生成、coverage 闭合与最终门

资料卡不从 H1 草稿或 r14 staging生成，也不在 apply 后另起一次未授权写入。H9 的 field coverage、selection 与 factor closure完成后，renderer 以 planned formal rows 为唯一输入确定性生成 card candidate；该 candidate 作为受管 payload 进入 H10 complete planned post，随后进入 H11 delta、H15 authorization、H17 file/payload inventory 和 H18 isolated full post mirror。v7 的 DAG不单列 card 层，因此这是 H9 到 H10 的 semantic edge，不引入同层依赖。apply 后只允许从 live post 重新渲染并验证其 bytes 与 H10/H18 的批准 payload 相等；任何差异都阻断，不能补写或改写资料卡。

card candidate 必须只引用 planned formal fact/assertion/relation/condition/source IDs，明确 full GA100 die、Ampere architecture、A100 product、DGX system四种主体差别，并保存每条 condition 的 software、SKU/carrier、measurement或scope限定。只有 H18 与 H10 exact set-equal、H19 至 H24 完备、正式 apply 后 data validation 通过并经独立 reviewer认可时，该受管 card payload 才可随事务发布。

coverage 闭合的最低条件是：

1. H5 expected pair 与 H7 terminal pair 严格双向相等，九路径×十二字段和 six benchmark 不存在缺项或额外手工行；
2. 9×12 的 status 分布为 53 value、49 not_found、6 N/A，并已验证 N/A predicate；
3. Ampere 的三个 architecture value、GA100 die 的三个同名 not_found、Matrix condition/value及108-SM拒绝行均在正式 assertion/search链中；
4. MLCommons、SEC、official-web duplicate、failed capture 的主体/资格判断均已落 endpoint-level result，未被误写为 positive fact；
5. source screening、selection、reverse-removal和 requirement evidence 已从 H7/H8 重算，所有 selected family具有不可替代职责；
6. v7 factor binding、13 个 card completeness domain、field coverage、mapping seq2和 object identity均由 H10 的同一 postimage驱动；
7. `Test-SourcePool.ps1`、`Test-ChipScope.ps1`、`Validate-ResearchData.ps1` 及 v7 fixtures在 PowerShell 5.1、PowerShell 7、Python 3 的规定矩阵中取得 PASS，并由独立 reviewer复验。

当前 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`，故第 7 项为 tool/runtime limitation，状态是 `not_run`，不是 sandbox denial、approval failure或验证失败。本报告也没有尝试在替代 runtime 声称 Windows gate 通过。

## 本次交接的实施边界

本文已把 v2 salvage/reject、r16/r20/r21/r22、r23、r24、r25/r28/r32/r35 的边界、r37/r39 的来源裁决、official-web v2/r29 的固定快照边界、contract v7/r38 的 postimage与scope规则、正式 32 表/模板/字段字典的结构要求统一为 v3 builder blueprint。r25 与 r32 只可作历史内容线索，不是当前合同或 closure authority；r35、r38、r39 的后续约束优先。

本文件不授权下一步写入。实际实施必须在 source-pool、contract v7、release-date migration、正式 source ingestion 和 Windows gates均解除阻断后，从 H0 重新冻结输入；任何试图跳过这些门、沿用 v2 operation、把 r37 的 15 行当完整 builder、或将 A100/DGX/SEC/MLCommons证据直接写成 GA100 die value 的操作都应被拒绝。

## 本文复核记录

本报告只新增本文件。文本完成后须按 `report-humanizer` 单文件脚本扫描，并从文末向前人工逆序复读，重点核对：R15设计 accept与实施未发生的区别、release migration未裁决、38-input mapping branch、无固定 operation 总数、9×12/6 benchmark/3 Ampere pair、Matrix 108/128边界、MLCommons/SEC错误主体、MIG/RAS/CUDA边界、v2删除链和 Windows `not_run` 分类。最终 SHA-256 与行数在本次交付回报中给出，避免把自引用 hash 写回正文后改变文件。
