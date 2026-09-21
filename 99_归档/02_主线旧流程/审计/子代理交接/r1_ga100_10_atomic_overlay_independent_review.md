# GA100 atomic staging overlay 独立最终复核

> 复核日期：2026-08-21  
> 对象：`OBJ-NVIDIA-GA100-DIE`（full GA100 physical die design）  
> 待复核 overlay：`r1_ga100_08_atomic_staging/`  
> 复核者：`ga100_overlay_independent_review`  
> 结论：REJECT，不得按当前 v1 合并。

## 一、验收结论

这个 overlay 已经把 GA100 裸片与 A100 产品大体分开，核心物理数字、PCIe link、RAS 条件链、Ampere precision/sparse 修复和 14 类特殊机制的主体方向基本正确。但它还不是可写入的原子事务。当前存在两条确定会让 `Validate-ResearchData.ps1` 失败的证据计数错误；141 字段总结中 75 行以 `coverage_only` 代替正式记录，严格按 GA100 资料卡主体复算后，其中 73 行没有能闭合该卡的 fact 或 targeted requirement；precision path 又存在字段级总结无法显示的路径级缺口。此外，ISSCC 既承担正式 assertion 和 CUDA 8.0 矛盾证据，却被标成 `lead_only` 并从 minimum set 删除；这与保留独立验证、限定和冲突的反向移除规则直接冲突。

本次独立复制并按 `operations.csv` 顺序应用了 567 个动作：516 insert、48 update、3 delete，以及 19 个 payload copy。机械数据合同中，32 表表头、PK 唯一性、FK、列枚举、七目标 XOR、subject/requirement target 合同、fact 数值/文本 XOR 和旧行回退 `draft/needs_resolution` 均没有发现 overlay 新增违规。这些通过项不能抵消下文的 blocker。

## 二、blocker 分类

### 2.1 硬校验 blocker

`FACT-R1-GA100-AMPERE-SW-MATURITY` 标为 `evidence_state=corroborated`，但联集中只有 `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0` 一个 distinct source。`Validate-ResearchData.ps1` 第 195 至 207 行明确规定 `corroborated` 至少两个 source，所以这是确定的 Windows 硬门失败。v2 有两种合法修法：保守方案是改为 `single_source` 并删掉 confidence reason 中未落 assertion 的 PTX 复数支持表述；若 PTX 7.0 相关段落确实直接证明同一个 `documented_supported` 成熟度语义，可以新建精确定位的 PTX assertion 后保留 `corroborated`，不得只为凑数复用一条内容不匹配的 assertion。

`FACT-M2NA-AMPERE-SPARSE-LEVEL` 同样标为 `corroborated`，当前只有白皮书一条 assertion。该 fact 的 confidence reason 写了“Whitepaper hardware mechanism plus PTX sparse MMA interface”，但 PTX assertion 只落在 sparse detail 和 datatype-specific path facts，没有落到该 level fact。这也会确定触发同一道硬门。由于 PTX 7.2 的 `mma.sp` 确实可以支持 `dedicated_instruction` 层级，v2 优先补一条内容相符的 PTX 7.2 assertion；若不补，就必须降为 `single_source`。

当前机器没有 `pwsh`、`powershell` 或 `powershell.exe`，分类为 tool/runtime failure，不是模型能力限制，也不能把静态检查写成三道正式硬门已通过。而且当前正式资料池是 113 份 PDF / 315363681 bytes，`Test-SourcePool.ps1` 冻结基线仍是 111 份 / 313921821 bytes。即使换到 Windows，这个既有 baseline difference 也会先挡住 SourcePool 门；它不是 GA100 overlay 造成的，但在总控裁决前仍是 formal acceptance blocker。

### 2.2 32 表合同 blocker：`coverage_only` 不是正式缺失状态

`field_coverage_summary.csv` 的 141 行确实一字段一行，但其中 75 行的 `formal_record_ids=coverage_only`，分布为 24 `not_found`、20 `conditional`、16 `pending`、8 `value`、5 `not_applicable` 和 2 `excluded`。研究计划 5.3 明确要求由 `field-requirements.csv` 定义应查字段，缺失是 requirement status；资料卡模板也明确要求芯片侧候选字段没有公开值时进入卡片或 `field-requirements.csv`。审计辅助 CSV 不是 32 张正式表，不能替代这一合同。

本复核的明确裁决是：75 行中没有任何一行可以继续用 `coverage_only` 单独结案。其中 `FIELD-MEM-LOCALITY-SCOPE` 和 `FIELD-MEM-MANAGEMENT` 已有可通过 Ampere 关系投影的正式 fact/requirement，v2 只需把辅助总结改为真实 ID。其余 73 行需要新增或映射到能闭合 GA100 卡的正式 fact/targeted requirement。`REQ-M2NA-GAP-0005` 只是 Ampere architecture 的派生比值缺口，`REQ-M2NA-GAP-0151` 只是 architecture-level NVLink link 的 aggregate-bandwidth 不适用记录；它们不能替代 full-GA100 对象或 GA100-owned link 的目标 requirement，所以仍算在 73 行内。

以“派生字段”或“产品线索”为理由保留 `coverage_only` 也不成立。派生指标可以不建 fact，但仍应在 GA100 object 上登记 `pending_verification` 或已有检索支持的 `not_found`，说明为何不能组合输入。A100/MIG/HPEC/random-access 等产品或实测线索可以留在资料卡说明或 `claim_dispositions.csv`，但这只能说明“该线索不转为 GA100 fact”，不能消除 GA100 字段本身的缺失 requirement。

最小可执行的 v2 口径如下：

| 当前 disposition | 行数 | v2 最低操作 |
|---|---:|---|
| `value` | 8 | 两个 memory 字段回填已有正式 ID；其余 6 个只能在有合格主体和直接证据时建 fact，否则改为 targeted pending/not_found requirement，不得继续写 `value + coverage_only` |
| `conditional` | 20 | 有合法产品/实测主体与完整 `condition_set_id` 才建条件 fact；当前没有上层主体的，建 GA100 缺口 requirement，线索另留说明 |
| `pending` | 16 | 在字段允许的真实目标上建 `pending_verification`；不得因为还没完成字段级检索而提前改成 `not_found` |
| `not_found` | 24 | 每个 targeted requirement 都必须有 field-specific `search-log.csv` 关联；数值路径字段还要按 precision path 拆分，不得用一条全局搜索代替 |
| `not_applicable` | 5 | 建 targeted requirement 并写结构性不适用理由；不得把“没找到”写成“不适用” |
| `excluded` | 2 | “排除 A100 值”不等于“GA100 字段关闭”。为 GA100-owned link 建 pending/not_found requirement；若最终证明 bare die 上结构性无意义，再改 `not_applicable` |

73 个待正式化字段按当前裁决分组如下。两个已能关系投影的 memory 字段不在清单中。

- `value`（6）：`FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-COMP-INSTRUCTION-TILE`、`FIELD-INT-LANE-COUNT`、`FIELD-INT-PER-LINK-RATE`、`FIELD-INT-REMOTE-MEMORY`、`FIELD-MEM-NAME`。

- `conditional`（20）：`FIELD-BENCH-LATENCY`、`FIELD-BENCH-THROUGHPUT`、`FIELD-COMP-CONCURRENCY`、`FIELD-COMP-UTILIZATION-LIMIT`、`FIELD-MEM-COMPRESSION`、`FIELD-MEM-CONSISTENCY`、`FIELD-MEM-GRANULARITY`、`FIELD-MEM-LATENCY`、`FIELD-MEM-POOLING-MODE`、`FIELD-MEM-READ-TRANSFER-PER-CYCLE`、`FIELD-MEM-USABLE-CAPACITY`、`FIELD-MEM-VIRTUAL-MEMORY`、`FIELD-RAS-ECC`、`FIELD-RAS-PROTECTION-SCOPE`、`FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-SW-COMPILER`、`FIELD-SW-RUNTIME`、`FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-PREEMPTION-QOS`。

- `pending`（16）：`FIELD-DER-CAPACITY-COMPUTE`、`FIELD-DER-COMPUTE-BW-SPEC`、`FIELD-DER-COMPUTE-BW-SUSTAINED`、`FIELD-DER-INTERCONNECT-COMPUTE`、`FIELD-DER-MOVE-MATRIX`、`FIELD-ID-DEPLOYMENT`、`FIELD-ID-DESIGN-OBJECTIVE`、`FIELD-ID-MARKET-ACCESS-CONSTRAINT`、`FIELD-ID-RELEASE-DATE`、`FIELD-ID-TARGET-USE-POSITIONING`、`FIELD-ID-VENDOR-POSITIONING`、`FIELD-INT-LINK-COUNT`、`FIELD-INT-PHYSICAL-LINK-COUNT`、`FIELD-SW-COMMUNICATION-LIBRARY`、`FIELD-SW-FRAMEWORK`、`FIELD-SW-OPERATOR-LIBRARY`。

- `not_found`（24）：`FIELD-COMP-ARRAY-SHAPE`、`FIELD-INT-BISECTION-BW`、`FIELD-INT-COLLECTIVE`、`FIELD-INT-DEGREE`、`FIELD-INT-HOPS`、`FIELD-INT-LATENCY`、`FIELD-INT-TOPOLOGY`、`FIELD-INT-TOPOLOGY-DIMENSIONS`、`FIELD-INT-TOPOLOGY-NODE-COUNT`、`FIELD-INT-TOPOLOGY-ROUTING`、`FIELD-MEM-BANKS`、`FIELD-MEM-BIDIR-BW`、`FIELD-MEM-PORTS`、`FIELD-MEM-READ-WRITE-MODEL`、`FIELD-MEM-WRITE-TRANSFER-PER-CYCLE`、`FIELD-NUM-PRODUCT`、`FIELD-NUM-ROUNDING`、`FIELD-NUM-SATURATION`、`FIELD-NUM-SCALING-GRANULARITY`、`FIELD-NUM-SCALING-MODE`、`FIELD-NUM-SUBNORMAL`、`FIELD-SW-CUSTOM-OPERATOR`、`FIELD-SW-DYNAMIC-SHAPE`、`FIELD-SW-QUANTIZATION-TOOL`。

- `not_applicable`（5）：`FIELD-ID-DEPLOYMENT-CONSTRAINT`、`FIELD-ID-REGION`、`FIELD-ID-SKU`、`FIELD-INT-MAX-SCALE`、`FIELD-INT-OVERSUBSCRIPTION`。

- `excluded`（2）：`FIELD-INT-AGGREGATE-BW`、`FIELD-INT-INJECTION-BW`。

NVLink 的实例化缺口是上述问题中最明显的一个。`FACT-R1-GA100-AMPERE-NVLINK-FAULT` 正确地留在 architecture link，且没有冒充 physical-link count；但 `FIELD-INT-PHYSICAL-LINK-COUNT` 在正式表里没有 `pending_verification` requirement。该字段只允许 link target，不能为了方便挂到 object。v2 应建一个不预设数量的 GA100-owned NVLink interface link，再把 physical/logical link count、lane/rate、injection/aggregate bandwidth 等缺口分别挂到这个 link。Figure 6 中可数的 12 个 interface 可以继续保留为 diagram candidate，但在证据裁决前不得装成已接收 fact。

### 2.3 precision path 合同 blocker

141 字段“每个 field 出现过一次”不能证明 precision path 完整。本次按路径复算得到：

| 路径 | A/B/程序可见累加 | output | physical accumulation | 裁决 |
|---|---|---|---|---|
| Ampere FP16 → FP32 | 有 | 无 fact/requirement | 有 `REQ-M2NA-GAP-0059` | 补 output gap |
| Ampere BF16 → FP32 | 有 | 无 fact/requirement | 有 `REQ-M2NA-GAP-0060` | 补 output gap |
| Ampere TF32 → FP32 | 有 | 有 `FIELD-NUM-OUTPUT=FP32` | 有 `REQ-M2NA-GAP-0061` | 这一路的三项合同闭合 |
| Ampere IEEE FP64 → FP64 | 有 | 无 fact/requirement | 有 `REQ-M2NA-GAP-0062` | 补 output gap |
| Ampere INT8 → INT32 | 有 | 无 fact/requirement | 有 `REQ-M2NA-GAP-0063` | 补 output gap |
| Ampere INT4 → INT32 | 有 | 无 fact/requirement | 无 | 补 output 与 physical-accum gap |
| Ampere Binary → INT32 | 有 | 无 fact/requirement | 无 | 补 output 与 physical-accum gap |
| GA100 dense FP16 → FP32 per-SM | 有 | 无 fact/requirement | 无 | 补 output 与 physical-accum gap |
| FP16 input → FP16 accumulation 变体 | 整条 path 不存在 | 不存在 | 不存在 | 白皮书 p.27 Table 3 已直接列出，必须建独立 path，补 A/B/acc fact 与 output/physical-accum gap |

因此，v2 至少需要新建 FP16→FP16 path 及其 A/B/acc 事实，为除 TF32 外的现有路径和新变体登记 path-specific output gap，并为 INT4、Binary、GA100 dense FP16 和新 FP16→FP16 变体登记 physical-accum gap。`FIELD-NUM-PRODUCT`、rounding、saturation、scaling 和 subnormal 也不能只有一行 field-global `coverage_only`：应在适用的 precision path 上分别建 pending/not_found/not_applicable requirement，并保留各自检索或不适用理由。

这些是 32 表路径合同 blocker，不是“资料卡可以以后再补”的排版问题。当前 `numerics=partial` 这个完整度结论本身是对的，但它不能替代逐路径缺口记录。

### 2.4 语义与证据 blocker

`REQ-R1-GA100-ECON-PRICE` 不应保留 `not_applicable`。当前证据只能证明 full GA100 design 与 A100 implementation 的对象边界，没有直接证明“该 die 不作为独立交易对象”。价格对裸片并非结构上无意义；本轮只是没找到公开独立定价。因此应改为 `not_found`，并把已执行的价格检索补成 field-specific search log；如果无法补出真实检索过程，则暂时只能写 `pending_verification`。对应的 economics completeness 应从 `not_applicable` 改成 `missing_public_data`。

`FACT-R1-GA100-PHY-PROCESS` 的 normalized value 是 `TSMC 7 nm N7`。白皮书直接支持完整字符串，ISSCC 只写 `7nm`，既没确认 foundry，也没确认 `N7` label。虽然 Windows validator 会把两个 source_id 计成 `corroborated`，但这不是对完整 normalized value 的独立复核。该 fact 应比照 54.2B/54B transistor 的处理改为 `source_with_caveat`，保留 ISSCC `qualifies` assertion，并把 notes/confidence reason 改成“第二来源只确认 7nm 节点粒度”。另有 `FIELD-PHY-FOUNDRY=TSMC` 的单源 fact 已经分开存在，不应让 ISSCC 的 `7nm` 为 foundry 增加伪独立性。

ISSCC 的 screening/selection 也必须改。它当前支持 826 mm² area 的精确 qualifier、限定 process 与 54B transistor，还在 `FACT-M2NA-AMPERE-SW` 上承担 `CUDA 8.0` 的 `contradicts` assertion，却被 screening 写成“No accepted full-GA100 atomic fact ... depends on it”并标为 `lead_only`。这句 rationale 与实际断言链不符。既然用户要求保留 CUDA 8.0 冲突，且 area 仍要保留 independent corroboration，v2 应把 ISSCC 改为 `selected`，在 source roles 中登记 `conflict_evidence`（可再登记 `independent_validation`），加入重跑后的 selection run。另一条可行路线是删掉 ISSCC 的所有正式 assertion、降级相关 evidence state 并不再保留 CUDA 8.0 冲突，但这不符合本次验收要求，因此不推荐。

当前六源 selection run 只能作为 provisional draft，不能写成已闭合 minimum set。PTX 7.0 与 7.2 同属 `SFAM-NVIDIA-PTX-ISA`，不得互相计为独立 corroboration；但当前 7.0 承担当期 sm_80/SIMT/async-copy 边界，7.2 承担 datatype-specific `mma.sp` 语义，两个版本的内容职责不同，可以在同家族前提下同时入选。待上述 fact/requirement/assertion 全部修复后，必须重跑 reverse removal，不得只修改旧 member rationale。

### 2.5 仅资料卡模板 blocker

staging 没有提供 `NVIDIA GA100 die` 的 Markdown 资料卡或可审计 patch，19 个 payload 也全是来源快照，不包含卡片。README 中的“最后更新人类资料卡”只是未执行步骤，`card-completeness.csv` 和 `field_coverage_summary.csv` 也都不是人类资料卡。因此当前不能验证模板的 15 个主节、缺失表、冲突表、最小来源和 fact/requirement 回链是否完整，这是交付层 blocker。

`memory=partial` 的完整度结论应保留，不能升成 complete。当前确实只闭合了 per-SM register file 262144 byte、4 组 RF、combined L1/shared 196608 byte、L2 实体以及部分 Ampere management/locality 机制。但 16 个 memory `coverage_only` 行中只有两个可直接映射旧 Ampere 记录，其余 bank、port、read/write model、write transfer、latency、granularity、compression、consistency、pooling、usable capacity、virtual memory 等都需在卡中显示缺失状态并回链正式 requirement。现有 completeness note 只列出 L2 capacity、read/write bandwidth、latency 和 full-die aggregate，范围太窄，v2 应同步扩充。

economics 的 completeness 需要随价格 requirement 改为 `missing_public_data`。其他 11 个 `partial` 和 benchmark 的 `missing_public_data` 未发现应当升级的依据。

## 三、通过的语义检查与 non-blocker

full GA100 直接实现事实没有混入 A100 enabled product 值。组件计数经独立查表为 8 GPC、64 TPC、128 SM、8192 FP32 CUDA Core、512 third-generation Tensor Core 和 12 个 512-bit memory controller。未建 6144-bit HBM interface 派生值，也未把 108 SM、6912 FP32、432 Tensor Core、40/80 GB HBM、1410 MHz、板卡功耗、A100 峰值或 MIG profile 下放到 GA100。

per-SM register file 是 262144 byte，combined L1/shared 是 196608 byte，issue width 是 32，dense FP16/FP32 是来源原口径的 1024 FMA per SM per clock，没有静默乘二改写成 FLOP。PCIe 4.0 x16 使用 GA100-owned `host_device` link，没有带入卡形态或链路吞吐。NVLink fault 保持在 architecture link，没有扩展成全芯片 RAS、FEC、BER 或 physical-link count。

OFA、GA100 video decode format、warp-wide reduction、TF32 conversion/output 和 datatype-specific sparse pattern 的主体边界可接受。OFA 没有虚构数量或吞吐；video 没有带入 A100 的 5 NVDEC 或 1410 MHz 条件值；warp reduction 只包含 ADD/MIN/MAX 和 AND/OR/XOR，没有写成 Softmax 或 collective engine。Sparse FP16/BF16 2:4、TF32 1:2、INT8 2:4 和 INT4 pair-wise 4:8 均留在 precision-path condition，没有写成 runtime pruning。

14 类特殊机制在 `capability_coverage.csv` 中一类一行，并都有真实 capability target 及 fact 或 requirement；这部分的结构覆盖成立。其中 sparse-level 的 evidence count 仍需按 2.1 修复，不影响“14 个机制均有 target”这一结构结论。

RAS 五类 fact 均使用 GA100 object 主体，条件和 notes 保留了 driver、external HBM spare row、InfoROM、application termination、reset/service window，没有被压成无条件的“GA100 全面 RAS”。MIG 只用来限定 GA100/A100 身份映射，HPEC 与 random-access 观测没有下放成 GA100 fact。`FIELD-ID-STATUS` 与 `FIELD-ID-DATA-CUTOFF` 没有行政性伪 fact，两个 requirement 仍为 pending。batch、context length、MoE 通信量和 KV Cache 迁移量没有出现在新 fact 的 normalized value 中，负载变量只能继续作条件。

23 个 formal fragment 的表头与正式表逐列一致，operation 应用后未发现新 PK/FK/列 enum/target XOR/value XOR 错误。所有被修改的旧 fact、requirement、condition、precision path、capability 和 assertion 均回到 `draft` 或 `needs_resolution`，没有静默继承旧 reviewed 签字。

来源筛选唯一性方面，新增 10 个 source 均恰好有一条 screening。联集仍有 9 个既有 source_id 各重复两行：`SRC-AWS-TRN2-S06`、`S07`、`S09`、`S10`、`S15`、`SRC-M2NA-AMD-CDNA4-WP`、`SRC-M2NA-AMD-CDNA4-ISA`、`SRC-M2NA-AMD-CDNA5-WP` 和 `SRC-M2W2-AMD-MI400-LANDING-20260813`。这九个与 formal baseline 完全一致，overlay 没有新增第十个重复。它们是正式库旧 warning，不应被误报成本次新错误，也不应被写成“全库一源一行已关闭”。

19 个 payload 在临时联集中按计划路径复制，byte count 和 SHA-256 全部一致。加上 4 个复用的既有本地 PDF endpoint 和 formal baseline 的 79 个本地 endpoint，独立联集共解析并核对 102 个本地 endpoint hash。正式根的 `verify_recovery_paths.py` 另行实跑通过：32 formal tables、153 endpoint rows、79 local paths、79 hashes、11 selection runs、106 selection members。

## 四、v2 的正式事务顺序

当前 v1 不应边合并边修。先在 staging 生成 v2 全量 operation ledger，把上述硬门、coverage、precision、price/process、ISSCC selection 和 Markdown 资料卡修复都纳入同一个可回滚事务，再执行以下顺序：

1. 从当前正式根创建完整临时副本，核对 32 表表头、基线 PK 与 v2 operations 的命中数，确认正式库在 v2 制作期间没有漂移。
2. 按 `payload_copies.csv` 复制 19 个固定文件到 stable target，逐个核对 byte count 和 SHA-256；文件没有到位前不得插入指向 stable path 的 endpoint。
3. 依次应用 source family/source 和 endpoint，然后是 object relation、component、memory level、GA100 PCIe/NVLink link、precision path、capability 和 condition set。这一阶段必须先建合法 target，再写 fact/requirement。
4. 先执行 fact/requirement/assertion 的 delete，再按 update、insert 应用 fact 修复、全部 targeted field requirement、fact assertion、requirement evidence、search log/result。每组完成后重跑表头、PK/FK、enum、七目标 XOR、numeric XOR、subject/requirement contract、available-requirement same-target fact 与 evidence-count 检查。
5. 在最终 fact/requirement/assertion 集合固定后，再更新 source screening/roles/coverage，将 ISSCC 的筛选与角色改正，重跑 reverse removal 并生成新 selection run/member。PTX 7.0/7.2 继续共用 source family，不得为了 corroboration 计数拆家族。
6. 最后更新 13 个 card-completeness 域和 GA100 Markdown 资料卡。卡片必须显示 141 字段的 fact/缺失落点、全部 precision path、14 类机制、CUDA 8.0 冲突、最小来源和未闭合问题，且所有标识能回链联集数据。
7. 对这个完整临时根执行 cross-platform recovery/hash 检查，再在 Windows runner 上运行三道硬门。只有三道全部退出 0，且独立复核签字后，才可以把同一 v2 ledger 原子应用到正式根；任意一步失败都回滚 payload、32 表和卡片的整个 GA100 事务。

## 五、Windows 三道硬门的强制要求

Windows 验收必须使用“完整 formal baseline + v2 operations + 19 stable payload + GA100 Markdown 资料卡”的同一个临时根，不能只对 fragments 或未复制 payload 的半联集运行。顺序和门槛为：

1. `Test-SourcePool.ps1`：退出 0。总控需先裁决 113/111 份 PDF 基线差异；未裁决前不得忽略失败或修改 expected count 伪造通过。
2. `Test-ChipScope.ps1`：退出 0。需要确认冻结名单的 `NVIDIA GA100 die` 与正式 object/relationship/card 一致，没有 A100 产品对象值混入裸片范围。
3. `Validate-ResearchData.ps1`：退出 0。v1 当前会因上述两条 `corroborated` 事实的 distinct-source 数不足而失败；v2 还必须同时通过表头、PK/FK、enum、XOR、subject/requirement 合同、same-target fact、review lifecycle、endpoint 和派生输入检查。

Python `verify_recovery_paths.py` 仍应在同一完整临时根另行执行，但它不替代上述三道 PowerShell 硬门。

## 六、工具、runtime 与操作错误记录

本次没有 sandbox denial、approval failure、approval-review connection failure、remote service error、user interruption 或 destructive action。

PowerShell 可执行文件缺失已分类为 tool/runtime failure，它直接导致三道 Windows 硬门未执行，因此降低了当前可验收层级。

最终边界核对时，`git status` 因当前 workspace 没有可见 `.git` 元数据而退出，分类为 tool/runtime failure 中的 non-Git workspace boundary，不是 sandbox denial。写入边界改用 apply-patch 记录、允许路径和最终文件清单核对。

复核中出现了四类 model/operator mistake，均为只读或 `/private/tmp` 内操作，没有修改正式库或 staging：

1. 首次统计 `field_coverage_summary.csv` 时误用了不存在的 `coverage_state` 列，引发 Python `KeyError`；查看表头后改用 `disposition` 重跑。
2. 首次在临时联集上跑 `verify_recovery_paths.py` 时，临时根只复制了 32 表和 19 个新 payload，没有复制 83 个 baseline 本地证据文件，因此得到 83 条伪缺失。后续改用“临时联集优先、正式根 baseline fallback”逐 endpoint 核 hash，并在完整正式根单独运行 recovery check，结果通过。
3. 首版独立 checker 的 GPC/TPC/SM 名称子串、`Optical Flow` 连字符号、`FIELD-ID-ARCH` relation projection 和旧 AWS enum-value 实现过严，产生 9 条假阳性。核对正式 validator 的 relation 特例与直接查表后，这 9 条均未计为 GA100 overlay 错误；其余三条为两个 evidence-count 硬错和 NVLink physical-count requirement 缺失。
4. 一次文件检索猜测了不存在的 `r1_ga100_07_runtime_audit.md`，实际文件名为 `r1_ga100_07_validation_runtime_audit.md`；通过目录列表更正。另一次 endpoint 统计误用 `endpoint_kind` 而正式列名为 `endpoint_type`，查表头后重跑。

## 七、报告自检

本报告仅写入 `r1_ga100_10_atomic_overlay_independent_review.md`，没有修改正式 32 表、来源快照、资料卡或进度。完稿后对这一个 Markdown 文件单独运行 `report-humanizer` 扫描，再按标题、首段、过渡句、结尾和数字/限定词逆向人工复读，不使用目录扫描代替单文件检查。第一次扫描报出 7 个 hard hit，其中 6 个是机械加粗，1 个是中文段落中的范围连接号；全部属于排版和句式问题，没有改变技术裁决、数字、限定词或证据归属。修正后再次扫描，最终结果见下行。

`report-humanizer final scan: PASS; no machine-detectable AI tells found`

人工逆向复读结果：PASS。按第七节向第一节逆序核对了结尾、事务门槛、non-blocker 与四类 blocker，再单独复读各标题后首段和转折句。REJECT 结论、两条硬门错误、75/73 字段裁决、precision-path 缺口、ISSCC 选源、price/process 证据强度、113/111 基线差异和 102 个 endpoint hash 口径前后一致；未发现数字、主体、因果、限定词或不确定性被自然化修改。
