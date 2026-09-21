# GA100 v3 来源综合与原子重建输入

> 状态：审计输入，不授权写入正式数据或任何 staging CSV  
> 唯一研究对象：`OBJ-NVIDIA-GA100-DIE`，即 full GA100 physical die design  
> 架构关系：`OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` → `OBJ-NVIDIA-AMPERE-ARCH`  
> 合同基线：采用冻结设计 `r1_ga100_19_contract_repair_design_v3.md`；该合同尚未迁移上线  
> 输入范围：指定的 identity、ISSCC、CUDA/PTX、MIG/RAS、microbenchmark、official-web、software-stack 报告及当前正式实体表、v2 staging 实体表

## 裁决摘要

这份报告把 GA100 v2 的来源阅读结论收束成 v3 原子重建输入，但不生成 fact、requirement、factor、source、endpoint 或 transaction ID。后续实现者必须从合同迁移后的正式 postimage 重新生成工作包，不能把 v2 staging 当作可直接合并的 rowset。

对象边界固定为 full GA100 裸片。A100 的 108 SM、5 个 HBM stack、40/80 GB、卡级时钟、板卡功耗、产品状态、vGPU profile 与 benchmark 都不是 `OBJ-NVIDIA-GA100-DIE` 的无条件事实。当前 reachability 只有 GA100 die、正向 `implements_architecture` 关系及其 Ampere 架构实体；因此 A100、vGPU、card、module、system、cloud 的正向信息只能作为条件、负向排除或卡外相关证据。只有 `FIELD-ID-ARCH` 可以沿该关系做特殊投影，其他字段不得借 architecture、A100 或软件产品关系复制到 GA100 die。

冻结 v3 合同将删除 `FIELD-ID-DATA-CUTOFF`，新增 `FIELD-COMP-INSTRUCTION-LATENCY`，并允许 `FIELD-MEM-LATENCY` 保留 `cycle` 或 `s`。合同事务尚未执行，所以指令周期与 memory cycle 虽已找到可接收来源，当前仍是合同/单位阻塞，不能提前写入现有 142-field 数据。`not_public` 也不能拿来代替检索失败：本轮没有一项得到“厂商明确声明不公开”的强证据，未命中项应按实际范围用 `not_found` 或 `pending`。

## 真实目标与合同核对

### 对象、组件、路径与关系

| 类别 | 可用真实 ID | v3 处理 |
|---|---|---|
| 对象 | `OBJ-NVIDIA-GA100-DIE`；`OBJ-NVIDIA-AMPERE-ARCH` | 前者是本卡唯一 card object；后者只能由批准的正向关系进入 reachable inventory。 |
| 对象关系 | `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | 只承担 `FIELD-ID-ARCH`；不得成为其他字段的通用投影通道。 |
| GA100 组件 | `COMP-R1-GA100-GPC`、`COMP-R1-GA100-TPC`、`COMP-R1-GA100-SM`、`COMP-R1-GA100-FP32`、`COMP-R1-GA100-TENSOR`、`COMP-R1-GA100-REG`、`COMP-R1-GA100-L1SMEM`、`COMP-R1-GA100-L2`、`COMP-R1-GA100-MEMCTRL`、`COMP-R1-GA100-OFA`、`COMP-R1-GA100-VIDEO-DECODE` | 11 个都是真实 implementation target。parent chain 必须保持 GPC→TPC→SM，以及 SM 下的 FP32/Tensor/REG/L1SMEM。 |
| Ampere 组件 | `COMP-M2NA-AMPERE-SM`、`COMP-M2NA-AMPERE-TENSOR`、`COMP-M2NA-AMPERE-CUDA`、`COMP-M2NA-AMPERE-SFU`、`COMP-M2NA-AMPERE-ASYNC-COPY`、`COMP-M2NA-AMPERE-REG`、`COMP-M2NA-AMPERE-L1SMEM`、`COMP-M2NA-AMPERE-L2` | 仅作为真实 architecture target；不能把其事实复制成 GA100 component fact。 |
| 9 个 mandatory precision path | `PPATH-M2NA-AMPERE-TENSOR-FP16`、`PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16`、`PPATH-M2NA-AMPERE-TENSOR-BF16`、`PPATH-M2NA-AMPERE-TENSOR-TF32`、`PPATH-M2NA-AMPERE-TENSOR-FP64`、`PPATH-M2NA-AMPERE-TENSOR-INT8`、`PPATH-R1-GA100-AMPERE-TENSOR-INT4`、`PPATH-R1-GA100-AMPERE-TENSOR-BINARY`、`PPATH-R1-GA100-TENSOR-FP16-DENSE` | 前 8 条归 Ampere Tensor component；最后一条归 GA100 Tensor component。108 个 numerics cell 全部 include，不能用 `not_applicable` 逃避。 |
| Memory level | `COMP-R1-GA100-REG`、`COMP-R1-GA100-L1SMEM`、`COMP-R1-GA100-L2`，以及对应三个 Ampere component | memory-level ID 与 component ID 相同。`COMP-R1-GA100-MEMCTRL` 当前不是 memory-level row，只能作为 component。 |

### capability、link、topology 与假实体

真实 capability 只有已有实体可参选：`CAP-M2NA-AMPERE-SPARSE`、`CAP-M2NA-AMPERE-ASYNC`、`CAP-R1-GA100-AMPERE-WARP-REDUCE`、`CAP-R1-GA100-OFA`、`CAP-R1-GA100-VIDEO-DECODE`。`CAP-M2NA-AMPERE-MOE` 与 `CAP-M2NA-AMPERE-TOPK` 是既有架构级缺口实体，不能拿来证明 GA100 有对应实现；v3 policy 应通过 subtype selector 与 factor closure 决定是否进入本卡，而不是把它们投影成 GA100 fact。

真实 link 是 `LINK-R1-GA100-NVLINK-INTERFACE`、`LINK-R1-GA100-PCIE4-X16` 和 reachable 的 `LINK-M2NA-AMPERE-NVLINK3`。当前没有 GA100 真实 topology row。下面 12 个 v2 placeholder 必须删除，不得复活：

`CAP-R1-GA100-GAP-ATTENTION-MOVE`、`CAP-R1-GA100-GAP-COLLECTIVE`、`CAP-R1-GA100-GAP-COMPRESSION`、`CAP-R1-GA100-GAP-DEQUANTIZE`、`CAP-R1-GA100-GAP-KV-CACHE`、`CAP-R1-GA100-GAP-MOE-DISPATCH`、`CAP-R1-GA100-GAP-MOE-ROUTE`、`CAP-R1-GA100-GAP-QUANTIZE`、`CAP-R1-GA100-GAP-SOFTMAX`、`CAP-R1-GA100-GAP-TOPK`、`CAP-R1-GA100-GAP-TRANSPOSE`、`TOPO-R1-GA100-NVLINK-GAP`。

这些名字可作为 factor 的自然语言检索标签，但本报告不创建 factor ID。尤其是 compression：假 capability 删除，真实 `COMP-R1-GA100-L2 / FIELD-MEM-COMPRESSION` 仍有正向 value。

### 字段与枚举门

冻结 postimage 的 field 总数仍为 141：删 `FIELD-ID-DATA-CUTOFF`，加 `FIELD-COMP-INSTRUCTION-LATENCY`。新字段的 subject/requirement target 仅 `component;precision_path`，规范单位是 `cycle`；`FIELD-MEM-LATENCY` 的规范单位改为空，并通过 unit policy 允许 `cycle;s`，不得在无频率时把 cycle 换成 second。当前正式枚举可直接使用 `requirement_status={value_available,not_public,not_found,not_applicable,pending_verification,inaccessible_evidence,conflicting_unresolved}`、`fact_kind={direct_statement,measured,derived}`、`search_result_relation={candidate,checked_no_support,supports_requirement,duplicate,inaccessible}`。合同迁移后 `selected_role` 还会增加 `coverage_obligation_evidence`。

Numerics 的既有枚举可接收 `rounding_mode=not_specified`、`saturation_mode=saturate|wrap`、`sparsity_mode=dense|structured_sparse`、`subnormal_mode=not_specified`。FP64 的 `.rm/.rp` 当前没有对应 rounding enum；原始 modifier 可以保留在 assertion/condition，但若要把完整选项结构化，仍需独立合同裁决，不能静默丢弃。

## 原子裁决矩阵

表中 `value` 对应未来 requirement 的 `value_available`。`actual endpoint` 指本轮实际读取或报告已核验的入口；r23/r24 的远程 HTML 还没有本地快照，故即使语义已命中，写入状态仍只能是 `pending / ingestion_pending`。

### 身份、physical 与 full-design resource

| exact target + field/factor | 建议与事实主体、条件 | source family/version；actual endpoint；locator | evidence / 派生输入 / 冲突 | search-result 语义与仍需来源 |
|---|---|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-NAME` | `value=NVIDIA GA100`；主体为 full die | `SFAM-M2NA-NVIDIA-AMPERE-WP-2020` v1.0；`END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`；PDF pp.9,14,19 | direct，single-source；MIG identity qualifier 冗余 | `supports_requirement`；可直接落盘。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-FAMILY` | `value=GA100` | 同上；pp.9,14,19 | direct；删除 MIG 610 的冗余 identity assertion 后重算 evidence state | `supports_requirement`；可直接落盘。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-VENDOR` | `value=NVIDIA` | 同上；封面、正文 GA100 | direct | `supports_requirement`。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-OBJECT-TYPE` | `value=die`；这是 curated object classification，不从 A100 card 继承 | 白皮书 pp.14,19,20 + ISSCC die photo | direct+curatorial classification | `supports_requirement`。 |
| `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE / FIELD-ID-ARCH` | `value` 由关系本身表达；GA100 implements `OBJ-NVIDIA-AMPERE-ARCH` | 白皮书 pp.9,14,19；MIG 610 Supported GPUs Table 1 仅 qualifier | direct relation；这是唯一允许的特殊投影 | `supports_requirement`；关系必须 approved 后才能进入 inventory。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` | `pending / ingestion_pending`；候选值 `2020-05-14 first official public naming`，不是产品发售日 | NVIDIA Technical Blog 2020-05-14；远程 HTML `https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/`；页首日期、Key features、A100 GPU hardware architecture | direct web statement；无本地 hash；与 A100 shipping 语义不同 | `candidate`，正式快照后可落。若字段坚持 standalone die sales release，则改 `not_found`。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-AVAILABILITY-DATE` | `not_found`；没有 standalone die 供货日期 | A100 Newsroom 2020-05-14 HTML/PDF、白皮书、Product Briefs | A100 production/shipping 是产品事实，不是 GA100 die value | 各来源 `checked_no_support` 于 die；A100 event 只作 negative/related evidence。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-STATUS` | `not_found`；不把网页仍在线或 A100 vGPU fully-supported 写成 die hardware lifecycle | vGPU lifecycle、AI Enterprise 8.2、A100 page；均为 r23 remote HTML | product/software subject mismatch | die status `checked_no_support`；A100 status 属“产品对象越界”。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-SKU` | `not_found`；full-design codename 不等于 Product Brief 中 `GA100-883/893...` product GPU SKU | 40/80 GB A100 PCIe Product Brief，document pp.1,3 | direct A100 card/SKU evidence，subject mismatch | `checked_no_support` 于 full design；需要产品对象才能接收 SKU。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-FOUNDRY` | `value=TSMC` | 白皮书 p.14/p.36；ISSCC PDF p.1 | direct，内部 corroboration | `supports_requirement`。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-PROCESS` | `value=TSMC N7 / 7 nm` | 同上 | direct；ISSCC 7 nm N7 与 whitepaper 一致 | `supports_requirement`。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-DIE-AREA` | `value=826 mm2` | 白皮书 p.14/p.36；ISSCC p.1 | direct，corroborated | `supports_requirement`。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-TRANSISTORS` | `value=54.2 billion` | 白皮书 p.14/p.36；ISSCC `54 billion` | direct；54B 是舍入，不建 conflict group | `supports_requirement`；raw assertion 各自保留。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-CLOCK` | `not_found` | 白皮书 Table 4 与 ISSCC 1.41 GHz 均为 A100 boost/product | subject mismatch | `checked_no_support` 于 full die；不能用频率推导 full-die peak。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-POWER` | `not_found` | 白皮书 p.37 400 W、Product Brief 250/300 W | A100 SXM4/PCIe board values | `checked_no_support` 于 die；产品对象越界。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-HBM-STACKS` | `not_applicable` 于裸片直接事实；stack 是外部封装/板级资源 | 白皮书 pp.19,35-37：6 physical / 5 active stack 语境 | structural subject mismatch；不得与 on-die controller 合并 | no fact；如产品对象进入别的工作包再建 requirement。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-HBM-INTERFACE` | `value=6144 bit`，条件 `full GA100 design` | 白皮书 p.19 的 12 个 512-bit memory controllers | `derived`；输入为 `12 count × 512 bit/controller`，必须各有 direct fact/assertion；formula/output unit 需登记 | `supports_requirement`；派生 DAG 与 formula evaluator 通过后可落。不是 5-stack A100 interface。 |
| `COMP-R1-GA100-GPC / FIELD-COMP-UNIT-COUNT` | `value=8`，full design | 白皮书 p.19 | direct | `supports_requirement`。 |
| `COMP-R1-GA100-TPC / FIELD-COMP-UNIT-COUNT` | `value=64`，即 full-design 8 TPC/GPC | 白皮书 p.19 | direct；不要由 8×8 重复制造第二独立事实 | `supports_requirement`。 |
| `COMP-R1-GA100-SM / FIELD-COMP-UNIT-COUNT` | `value=128`，full design | 白皮书 p.19、Technical Blog candidate | direct | `supports_requirement`；HPEC background 的 124 SM 明确 `rejected`。 |
| `COMP-R1-GA100-FP32 / FIELD-COMP-UNIT-COUNT` | `value=8192`，full design | 白皮书 p.19 | direct | `supports_requirement`；A100 6912 只作 enabled-product negative boundary。 |
| `COMP-R1-GA100-TENSOR / FIELD-COMP-UNIT-COUNT` | `value=512`，full design | 白皮书 p.19 | direct | `supports_requirement`；A100 432 不进入 same-target fact。 |
| `COMP-R1-GA100-MEMCTRL / FIELD-COMP-UNIT-COUNT` | `value=12`，每个 512-bit | 白皮书 p.19 | direct | `supports_requirement`；A100 10 active controller 是产品条件。 |
| `A100 enabled implementation / 108 SM, 6912 FP32, 432 TC, 10 controller` | 不创建 GA100 fact；仅 negative evidence / 卡外相关证据 | 白皮书 p.19；ISSCC p.1；Technical Blog remote HTML | direct A100 product evidence；与 128/8192/512/12 不构成 GA100 冲突 | search result 对 GA100 target 记 `checked_no_support` 或 `qualifies` 类语义，不建 reachable value。 |

### Memory、interconnect 与 compute component

| exact target + field/factor | 建议与事实主体、条件 | source family/version；actual endpoint；locator | evidence / 派生输入 / 冲突 | search-result 语义与仍需来源 |
|---|---|---|---|---|
| 11 个 GA100 component / `FIELD-COMP-UNIT-NAME` | `value`，沿用已核对 canonical label | 白皮书 pp.19-22,35,56；Table/Figure 直接命名 | direct；OFA/video decode 不带 count | 每个 exact component 一条 `supports_requirement`。 |
| `COMP-R1-GA100-L1SMEM / FIELD-MEM-CAPACITY` | `value=192 KiB per SM combined physical L1/shared`，规范化 `196608 byte` | 白皮书 Figure 7、Table 4 | direct；不能与 164 KB software-visible shared maximum相加 | `supports_requirement`。 |
| `COMP-R1-GA100-REG / FIELD-MEM-CAPACITY` | `value=256 KiB per SM register file`，规范化 `262144 byte` | 白皮书 Figure 7/Table 4 | direct | `supports_requirement`。 |
| `COMP-R1-GA100-REG / FIELD-MEM-INSTANCE-COUNT` | `value=4 processing-block register-file instances per SM` | 白皮书 SM diagram | diagram direct/count；condition=per SM organization | `supports_requirement`。 |
| `COMP-R1-GA100-L1SMEM / FIELD-MEM-USABLE-CAPACITY` | `pending`；164/160/163 KB 是 A100/CC8.0 与 CUDA revision 下的软件可见上限，不是 full-design physical value | 白皮书 pp.36-37,43；Programming Guide 11.0 p.371；Tuning Guide 11.2.1 §1.4.3 | source-revision + product/architecture condition conflict，不能投影 | 产品对象越界；需要合同确认 architecture target 或直接 GA100 implementation source。 |
| `COMP-R1-GA100-L2 / FIELD-MEM-COMPRESSION` | `value=Compute Data Compression for compressible data/unstructured zeros`，4×/2×均保留 `up to` | 白皮书 pp.35,41；ISSCC p.1 | direct vendor mechanism；不是 2:4 sparse MMA，也不派生基础 BW/capacity | `supports_requirement`；假 compression capability 删除。 |
| `COMP-R1-GA100-L2 / FIELD-MEM-CONSISTENCY` | `value=full-GPU hardware cache coherence sufficient for CUDA model`；condition=non-partitioned full GPU | 白皮书 p.35；ISSCC p.1 | direct；不含 protocol、atomic scope、跨 GI 语义 | `supports_requirement`。 |
| `COMP-R1-GA100-L2 / FIELD-MEM-POOLING-MODE` | `value=logically_shared_distributed`；condition=full GPU | 白皮书 p.35 | direct organization statement | `supports_requirement`；MIG 下另设产品条件。 |
| `COMP-R1-GA100-L1SMEM / FIELD-MEM-GRANULARITY` | `not_found`，当前计划来源已查不到 line/transaction/bank access granularity | 白皮书、ISSCC、CUDA PG11、PTX70/72、两份 microbenchmark | `cp.async` 4/8/16 byte 和 random workload 128 byte 都是 operation/request size，不是该字段 | 全部 `checked_no_support`；未来新硬件手册可重开。 |
| `COMP-R1-GA100-L1SMEM / FIELD-MEM-READ-TRANSFER-PER-CYCLE` 与 `...WRITE...` | `not_found` | 同上 | latency cycle、instruction width、A100 L2 5120 B/clk 均不可跨 component | `checked_no_support`；不做伪派生。 |
| `COMP-R1-GA100-L2 / FIELD-MEM-VIRTUAL-MEMORY` | `not_found` 于 L2 exact target | 白皮书 pp.34,52-54；CUDA PG11；PTX | 只证明 address spaces/peer fault，不证明 L2 的 VM responsibility、page size 或 migration | `checked_no_support`；若未来以 object/software target建模须另取 Unified Memory/Driver 文档。 |
| `LINK-R1-GA100-PCIE4-X16 / FIELD-INT-PROTOCOL` | `value=PCI Express 4.0 x16 host interface`，full-design interface | 白皮书 p.20 Figure 6 | figure direct | `supports_requirement`。 |
| `LINK-R1-GA100-NVLINK-INTERFACE / FIELD-INT-PHYSICAL-LINK-COUNT` | `value=12 physical NVLink interfaces`，full design | 白皮书 p.20 Figure 6 | figure direct/count | `supports_requirement`；不生成 topology。 |
| 同一 link / `FIELD-INT-LINK-COUNT` | `value=12 logical links/device`，condition=12 enabled | 白皮书 p.20,p.52；ISSCC pp.1-2 | direct，内部 corroboration | `supports_requirement`。 |
| 同一 link / `FIELD-INT-LANE-COUNT` | `value=4 lanes per direction per link` | 白皮书 p.52 | direct | `supports_requirement`。 |
| 同一 link / `FIELD-INT-PER-LINK-RATE` | `value=200 Gbit/s per direction per logical link` | 白皮书 p.52：4×50 Gbit/s signal pair；25 GB/s/link/direction cross-check | `derived`；输入 `4 lane × 50 Gbit/s/lane`；direction/raw-line-rate 条件必填 | `supports_requirement`；不能把 50 Gbit/s 填成完整 link rate。 |
| 同一 link / `FIELD-INT-INJECTION-BW` | `value=300 GB/s per direction per device`，12 links enabled | 白皮书 p.52；ISSCC p.1 | `derived` 或 direct ISSCC；输入 `12×25 GB/s` | `supports_requirement`。 |
| 同一 link / `FIELD-INT-AGGREGATE-BW` | `value=600 GB/s bidirectional aggregate`，12 links enabled | 白皮书 pp.20,52；ISSCC | `derived`；输入 `12×25×2`；不是 DGX total | `supports_requirement`。 |
| 同一 link / `FIELD-INT-LATENCY` | `not_found` | 白皮书仅 low-latency；ISSCC 的 tens-of-ns 是相对 FEC round-trip saving | no absolute latency | `checked_no_support`。 |
| `OBJ-NVIDIA-GA100-DIE + NVLink-topology factor` | `not_found`；没有 die topology target，不能创建 topology row | 白皮书 p.52；ISSCC Figure 3.2.6 | sources describe possible configurations / DGX A100 system | factor search `no_reliable_result`；bisection/degree/hops/max-scale/oversubscription/topology/dimensions/node-count/routing 走 zero-included factor closure。 |
| `COMP-R1-GA100-SM / FIELD-COMP-CONCURRENCY` | `value` 只到 FP32+INT32 simultaneous issue capability，不扩成 all-unit simultaneous peak | 白皮书 SM section；HPEC p.5 只作 qualifier | direct vendor + measured qualifier；HPEC 两 add/two mad 约4 cycles不证明峰值 | 白皮书 `supports_requirement`，HPEC `candidate/qualifier`。 |
| `COMP-R1-GA100-SM / FIELD-COMP-SHARED-RESOURCE` | `value`，每SM四个processing block，各自组合warp scheduler/dispatch、REG、FP32/INT32、Tensor、LD/ST、SFU资源 | 白皮书 Figure 7与SM正文 | direct organization statement；不推导端口、queue或simultaneous peak | `supports_requirement`。 |
| `COMP-M2NA-AMPERE-ASYNC-COPY / FIELD-MEM-DMA` | `value`，implementation level=thread instruction；global→shared non-blocking copy，绕过中间RF，4/8/16 byte | `SRC-NVIDIA-PTX-ISA-7-0`，`END-NVIDIA-PTX-ISA-7-0-LOCAL` pp.201-204；`SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`，`END-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0-LOCAL` pp.215,217 | direct ISA/API；不是独立DMA engine，无count/queue/latency/BW | `supports_requirement`。 |
| `COMP-M2NA-AMPERE-SM / FIELD-COMP-CONTROL-SCHEDULING` | `value`，四warp scheduler、static warp distribution，以及CTA/shared-memory `mbarrier`同步语义 | CUDA PG11 p.370；PTX70 pp.249-250 | direct software-visible organization；不证明scheduler RTL、dual issue或barrier state RAM | `supports_requirement`。 |
| `CAP-R1-GA100-AMPERE-WARP-REDUCE / FIELD-CAP-IMPLEMENTATION-DETAIL, FIELD-CAP-IMPLEMENTATION-LEVEL, FIELD-CAP-LIMITATION` | `value`，single-warp 32-bit add/min/max与and/or/xor；level=`dedicated_instruction`；其他datatype/op软件实现 | CUDA PG11 p.191；PTX70 pp.248-249 | direct；不是Softmax、Top-k、CTA reduction或network collective | 每个field分别`supports_requirement`。 |
| `CAP-M2NA-AMPERE-SPARSE / FIELD-CAP-IMPLEMENTATION-DETAIL, FIELD-CAP-IMPLEMENTATION-LEVEL` | `value`，metadata-directed sparse operand A selection/zero-skip；level=`dedicated_instruction` | PTX72 `END-NVIDIA-PTX-ISA-7-2-LOCAL` pp.330-332,348-350；whitepaper sparse Tensor sections | direct；pattern由precision path决定，不是runtime nonzero discovery | 每个field分别`supports_requirement`。 |
| `CAP-R1-GA100-OFA / FIELD-CAP-IMPLEMENTATION-DETAIL, FIELD-CAP-IMPLEMENTATION-LEVEL` | `value`，optical-flow/stereo-disparity acceleration；level=`dedicated_physical_module` | whitepaper p.56 | direct；count/throughput仍未公开 | detail/level `supports_requirement`；throughput `checked_no_support`。 |
| `CAP-R1-GA100-VIDEO-DECODE / FIELD-CAP-IMPLEMENTATION-DETAIL, FIELD-CAP-IMPLEMENTATION-LEVEL` | `value`，H.264/HEVC/VP9 documented decode format support；level=`dedicated_physical_module` | whitepaper Table 7 | direct；不带unit count或throughput | detail/level `supports_requirement`。 |
| `COMP-R1-GA100-TENSOR / FIELD-COMP-ARRAY-SHAPE` | `not_found` | 白皮书 Figure 14、PTX shapes、HPEC Tables III/V | 16×8×16 是 warp instruction tile；8×4×8 是二手引用 | `checked_no_support`；不得用 instruction shape 造 physical array。 |
| `PPATH-M2NA-AMPERE-TENSOR-FP16 / FIELD-COMP-INSTRUCTION-TILE` | `value`，按 dense/sparse opcode 条件保存 shape set | PTX70 pp.325-327；PTX72 pp.348-350；白皮书 p.39 | direct ISA；`.m16n8k16` 等不是 physical array | `supports_requirement`；PTX revisions 同一家族。 |
| `PPATH-R1-GA100-TENSOR-FP16-DENSE / FIELD-COMP-THROUGHPUT` | `value=1024 FP16/FP32 FMA per SM per clock`；count rule=`vendor_label`，不得乘2 | 白皮书 full GA100 SM table | direct vendor statement | `supports_requirement`；不能用 A100 clock聚合。 |
| `COMP-R1-GA100-OFA / FIELD-CAP-THROUGHPUT` | `not_found` | 白皮书 p.56 | 只给 tunable quality/performance，无 operation/frequency/throughput | `checked_no_support`。 |

### 9×12 numerics mandatory cells

9 个 path 的 operand A、operand B 和 programmer-visible accumulation 维持既有 direct value；下表给出全部 12 字段的实施裁决。缩写：`V`=`value`，`NF`=`not_found`。所有 architecture path 主要由 PTX70/72 与 CUDA PG11 支撑；`PPATH-R1-GA100-TENSOR-FP16-DENSE` 只能使用直接 GA100 implementation 来源。PTX 7.0、7.1 introduction record 与 7.2 是同一 `SFAM-NVIDIA-PTX-ISA` revision chain，不算独立 corroboration。

| precision path | operand A | operand B | accumulation | product | physical accum | output | rounding | scaling mode | scaling granularity | saturation | subnormal | sparsity |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `PPATH-M2NA-AMPERE-TENSOR-FP16` | V FP16 | V FP16 | V FP32 | NF | NF | V FP32 | V `not_specified` | NF | NF | NF；WMMA `satf`仅 lead | V `not_specified` | V A=2:4 |
| `PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16` | V FP16 | V FP16 | V FP16 | NF | NF | V FP16 | V `not_specified` | NF | NF | NF；WMMA `satf`仅 lead | V `not_specified` | V A=2:4 |
| `PPATH-M2NA-AMPERE-TENSOR-BF16` | V BF16 | V BF16 | V FP32 | NF | NF | V FP32 | V `not_specified` | NF | NF | NF；WMMA `satf`仅 lead | V `not_specified` | V A=2:4 |
| `PPATH-M2NA-AMPERE-TENSOR-TF32` | V TF32 | V TF32 | V FP32 | NF | NF | V FP32 | V `not_specified` | NF | NF | NF；WMMA `satf`仅 lead | V `not_specified` | V A=1:2 |
| `PPATH-M2NA-AMPERE-TENSOR-FP64` | V FP64 | V FP64 | V FP64 | NF | NF | V FP64 | V default `rne`；raw `.rz/.rm/.rp` | NF | NF | NF | NF | NF |
| `PPATH-M2NA-AMPERE-TENSOR-INT8` | V INT8 | V INT8 | V INT32 | NF | NF | V INT32/`.s32` | NF | NF | NF | V conditional：`satfinite`→saturate，absent→wrap | NF | V A=2:4 |
| `PPATH-R1-GA100-AMPERE-TENSOR-INT4` | V INT4 | V INT4 | V INT32 | NF | NF | V INT32/`.s32` | NF | NF | NF | V conditional：`satfinite`→saturate，absent→wrap | NF | V A pair-wise 4:8 |
| `PPATH-R1-GA100-AMPERE-TENSOR-BINARY` | V binary | V binary | V INT32 | NF | NF | V INT32/`.s32` | NF | NF | NF | NF | NF | NF |
| `PPATH-R1-GA100-TENSOR-FP16-DENSE` | V FP16 | V FP16 | V FP32 | NF | NF | NF | NF | NF | NF | NF | NF | V dense |

矩阵的 direct locator 为 PTX70 dense `wmma/mma` PDF pp.273-276、325-327，PTX72 sparse `mma.sp` pp.330-332、348-350，以及 whitepaper p.39/Table 3。所有 `NF` 都应由 exact path + exact field 的真实 search 关闭，不能只挂一个家族级模板 result。integer/logical rounding 与 subnormal 在语义上属于结构性不适用，但冻结合同禁止108个mandatory cell使用 requirement-level `not_applicable`，且现有 `rounding_mode`/`subnormal_mode` 也没有可据来源直接写入的N/A枚举，因此实施状态必须是 `not_found`，并在理由中保留“该整数/逻辑operation没有浮点rounding/subnormal stage”。floating `not_specified` 则是来源明确给出的 value，不是 `not_public`。最后一行没有 architecture projection，除 operand/accumulation与 dense throughput已有直接 GA100 source 外，其余保持 `not_found`。

| cell group | source family/version、actual endpoint与locator | evidence/search state |
|---|---|---|
| 8个Ampere path的operand/output/accumulation、rounding/subnormal与integer saturation | `SFAM-NVIDIA-PTX-ISA`；`SRC-NVIDIA-PTX-ISA-7-0`/`END-NVIDIA-PTX-ISA-7-0-LOCAL` pp.273-276,325-327；`SRC-NVIDIA-PTX-ISA-7-2`/`END-NVIDIA-PTX-ISA-7-2-LOCAL` pp.348-350 | exact opcode/path direct value；未给product/physical-accum/scaling的格逐一`checked_no_support`。 |
| 8个Ampere path的sparsity | PTX72同endpoint pp.330-332,348-350，PTX 7.1 introduction record | direct datatype-dependent value；7.1/7.2同族。 |
| FP16/BF16/TF32 accumulation rounding/subnormal=`not_specified` | PTX70 p.275,p.326；PTX72 p.349 | source explicitly unspecified，因此是direct value。 |
| FP64 rounding | PTX70 pp.274-275,325-326 | default `.rn`规范为`rne`；`.rz/.rm/.rp`保留raw condition，enum gap单独阻塞。 |
| `PPATH-R1-GA100-TENSOR-FP16-DENSE` | `SFAM-M2NA-NVIDIA-AMPERE-WP-2020` v1.0，`END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` p.20与SM/Tensor表 | operand/accumulation/dense/1024 FMA direct；其余exact implementation semantics `checked_no_support`，不能借PTX投影。 |

### Instruction 与 memory latency

| exact target + field | 建议与条件 | source/version；actual endpoint；locator | evidence / 冲突 | search-result 与阻塞 |
|---|---|---|---|---|
| `COMP-R1-GA100-SM / FIELD-COMP-INSTRUCTION-LATENCY` | `pending`；可拆 `add.f16 3/2`、`add.u32 4/2`、`add.f64 5/4`、`mul.lo.u32 3/2`、`mad.rn.f32 4/2` cycles，分别带 dependent/independent、initialization、SASS mapping | `SFAM-NVIDIA-AMPERE-MICROBENCH-2022`，`SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022`；`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`；PDF p.5 Table II、p.7 Table V | `measured`；A100 product family/SKU unresolved；compiler/driver/CUDA/clock unknown；不是 RTL 固定 latency | source=`candidate`；合同迁移前不可落。迁移后用 `INSTRUCTION-LATENCY-CONDITION-V1`，未知项写 `unknown`。 |
| 相关 precision path / `FIELD-COMP-INSTRUCTION-LATENCY` | `pending`；WMMA cycles：FP16/BF16/TF32/FP64=16，U8=8，U4=4，保留 PTX shape 与 SASS 展开 | 同一 arXiv v1，p.6 Table III | `measured`；单位只接收 cycle | 合同/单位阻塞；Table III 的 throughput 列不参与。 |
| `COMP-R1-GA100-L1SMEM / FIELD-MEM-LATENCY` | `pending`；候选 L1=33 cycles，shared load/store=23/19 cycles，保留 cache operator、pointer chase、dependency 与 unknown software/clock | 同一 arXiv v1，pp.4-6 Sections IV-B/V-B、Table IV | `measured`；A100-conditioned on-die component | 合同迁移后可直接落盘；当前 `FIELD-MEM-LATENCY` 仍只允许 s。 |
| `COMP-R1-GA100-L2 / FIELD-MEM-LATENCY` | `pending`；candidate=200 cycles，完整条件同上 | 同上 Table IV | `measured`；不能换算为 s | 合同/单位阻塞。 |
| global memory 290 cycles | 不写入 GA100 die/component fact；A100 product path only | 同上 Table IV | measured path crosses HBM/product configuration | 产品对象越界；只作 negative/related evidence。 |
| HPEC Table III `GB/s` throughput | `rejected_for_normalization` | 同一 arXiv v1，p.6 Table III | 原单位与理论 FLOPS/TOPS 数值重合，但论文不给 operation-count、clock、SM count 或 byte definition | 对 throughput/byte-per-cycle 均 `checked_no_support`；禁止改成 TFLOPS/TOPS。 |
| HPEC background `124 SM` | `rejected` | 同一 arXiv v1，p.2 Section II | 与 full 128 和 A100 enabled 108 均不符，无推导 | 不建任何事实或冲突组。 |

HPEC 本地副本是 `arXiv:2208.11174v1`。DOI/HPEC 发表关系可以留作书目元数据，但没有 IEEE publisher PDF 或逐页比对，不能声称它等同 IEEE final。

### Software 五字段

这五条的事实 target 固定为 `OBJ-NVIDIA-AMPERE-ARCH`。A100/GA100 只进入 product reachability 或 condition，不得把 software fact 改挂 `OBJ-NVIDIA-GA100-DIE`。r24 的所有 actual endpoint 都是远程 versioned HTML，尚未固定本地 payload、bytes 与 SHA-256，因此当前一律为 `pending / ingestion_pending`，不是 `value_available`；完成 ingestion 后才按下表转 `value`。

| exact target + field | 语义上建议 value 与条件 | source family/version；actual endpoint；locator | evidence maturity / 冲突 | ingestion 后的 search 语义 |
|---|---|---|---|---|
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-FRAMEWORK` | PyTorch container 20.06/20.07：PyTorch `1.6.0a0+9907a3e`、CUDA 11；TensorFlow 20.07：TF `1.15.3/2.2.0`、CUDA `11.0.194`；A100 reachability | NVIDIA PyTorch Container Release Notes 20.06/20.07：`rel_20-06.html`,`rel_20-07.html`；TensorFlow 同路径；locators=`Contents/GPU Requirements/Key Features/Known Issues` | `documented_supported`，未运行；同一 framework 的月版同族；PyTorch 20.07 Ampere omission不能当否定证据 | 各 family `supports_requirement`；CUDA family只作 reachability。 |
| 同 target / `FIELD-SW-COMMUNICATION-LIBRARY` | NCCL `2.7.6` + CUDA 11.0；保留 send/receive/GDR 限制和 topology matrix 未指定 | NCCL 2.7.6 archived release note `https://docs.nvidia.com/deeplearning/nccl/archives/nccl_276/release-notes/rel_2-7-6.html`；Compatibility/Known Issues；framework 20.07 component list | documented only；2.7.5 是同族 launch issue background | NCCL `supports_requirement`；containers qualifier；warp reduce/NVLink `checked_no_support` 于 library。 |
| 同 target / `FIELD-SW-OPERATOR-LIBRARY` | 分条：cuBLAS `11.1.0.229`、cuDNN `8.0.1`、TensorRT `7.1.3` CUDA11/A100 Preview、cuSPARSELt `0.0.1` | CUDA 11.0 GA Release Notes；cuDNN 8.x archive；TensorRT 8.6.1 cumulative release notes 中7.1.3条目；cuSPARSELt 0.0.1 Guide；各版本 locator见 r24 | documented only；TensorRT 7.1.3 lifecycle=`preview`；library existence≠全部 operator support | 每个不可替代 family `supports_requirement`；container清单只证明 packaging/binding。 |
| 同 target / `FIELD-SW-DYNAMIC-SHAPE` | TensorRT 8.6.1 runtime dimension `-1`、optimization profile、shape tensor及限制；7.1.3只作 launch Preview | TensorRT 8.6.1 Developer Guide `Working with Dynamic Shapes` §§8.1,8.6-8.10；Support Matrix CC8.0 row；Release Notes compatibility | documented only；不是任意 PyTorch/TensorFlow graph 支持 | 三条 work family 分担 semantics/reachability/lifecycle；均固定后 `supports_requirement`。 |
| 同 target / `FIELD-SW-QUANTIZATION-TOOL` | TensorRT 8.6.1 INT8 calibration与Q/DQ；dynamic shape需calibration optimization profile；7.1.3仅 symmetric per-tensor Preview | TensorRT Developer Guide `Working with INT8` §§7.1,7.4,8.10；Support Matrix INT8/CC8.0；Release Notes 7.1.3/8.6.1 | documented only；cuSPARSELt pruning、PTX INT8不是 quantization tool | TensorRT work families `supports_requirement`；PTX/cuSPARSELt 对本字段 `checked_no_support`。 |

### RAS、MIG 与 vGPU

| exact target + field/factor | 建议与事实主体、条件 | source/version；actual endpoint；locator | evidence / 冲突 | search-result 与仍需来源 |
|---|---|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-RAS-ECC` | `value`，拆 on-die L2/L1/RF SECDED 与 external HBM ECC；不写 whole-chip | whitepaper p.35；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` local PDF Overview/SRAM sections | direct；外部 HBM作用域单独条件 | `supports_requirement`。 |
| 同 target / `FIELD-RAS-PROTECTION-SCOPE` | `value`，拆 storage、NVLink detection/replay、GI isolation；compute datapath未覆盖 | whitepaper pp.35,45-48,52；RAS PDF；MIG610 | direct，分作用域 | `supports_requirement`；不得合成“全芯片保护”。 |
| 同 target / `FIELD-RAS-ERROR-DETECTION` | `value`，driver identifies framebuffer UCE location | RAS fixed PDF `END-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001-LOCAL`；PDF p.6/document p.4 DPO | direct process statement | `supports_requirement`。 |
| 同 target / `FIELD-RAS-FAULT-ISOLATION` | `value`，contained UCE isolation；保留 rare uncontained errors | 同 endpoint；PDF pp.4-5/document pp.2-3 | direct | `supports_requirement`。 |
| 同 target / `FIELD-RAS-CORRECTION-REPLAY` | `value`，row remapping after service/reset；NVLink replay另拆条件 | RAS PDF pp.7-8/document pp.5-6；whitepaper p.52 | direct | `supports_requirement`。 |
| 同 target / `FIELD-RAS-RECOVERY` | `value`，application termination、page offline、service/reset；不含 job-state restart | RAS PDF pp.8,10/document pp.6,8 | direct | `supports_requirement`；degraded compute/capacity mode仍 `not_found`。 |
| 同 target / `FIELD-RAS-TELEMETRY-BIST` | `value` 仅 telemetry + Field Diagnostics：XID/NVML/`nvidia-smi`/SMBPBI/InfoROM counters与RMA diagnostics | RAS PDF pp.11-12,14-15/document pp.9-10,12-13 | direct；软件/固件/带外条件 | `supports_requirement`；绝不把 Field Diagnostics改写成内建 BIST。 |
| `OBJ-NVIDIA-GA100-DIE + BIST structure factor` | `not_found` | RAS PDF全文、R595六页；关键词 BIST/built-in/self-test | checked no support；与 telemetry value并存 | factor `no_reliable_result`；不再整体关闭 `FIELD-RAS-TELEMETRY-BIST` 为 missing。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-RAS-SILENT-DATA-ERROR` | `not_found`，限定 Tensor/CUDA compute datapath SDE detection | RAS PDF、R595、whitepaper；silent/SDC/redundant execution 检索 | ECC/contained UCE 都以已检测错误为前提，不替代 SDE | `no_reliable_result` + 每端点 `checked_no_support`。 |
| 同 target / `FIELD-RAS-CHECKPOINT-RESTART` | `not_found` 于 general die/job checkpoint；2020 MIG Migration只作 concept lead | whitepaper p.52；RAS PDF p.10；MIG610 Concepts/Virtualization/Deployment | 没有 delivered API、job restart、consistency；r23 vGPU suspend/resume是产品软件事实 | vGPU source若未入产品对象，只作 out-of-scope positive/GA100 negative evidence。 |
| same target / RAS Repair negative boundary | 不建正向 fact；`checked_no_support` | R595 Supported GPUs Table 1 GA100 blank；GPU Memory Repair 明确 select Blackwell products | 同族 current revision negative qualifier | 仅在正式保留 current negative boundary时选 R595；不能计 independent corroboration。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-VIRT-MULTI-TENANCY` | `value`，只写支持 MIG 的 GA100 product条件下多 GI并行、QoS/fault isolation | `SRC-NVIDIA-MIG-USER-GUIDE-610`；`END-NVIDIA-MIG-USER-GUIDE-610-INTRODUCTION`首三段、`END-NVIDIA-MIG-USER-GUIDE-610-CONCEPTS` Terminology/GPU Instance | direct software/product-conditioned mechanism | `supports_requirement`；不得写 up-to-7为full die常量。 |
| 同 target / `FIELD-VIRT-PARTITIONING` | `value`，GI切 SM/crossbar/L2/memory path；CI切 dedicated SM、共享父GI memory/engines | `END-NVIDIA-MIG-USER-GUIDE-610-INTRODUCTION`；`END-NVIDIA-MIG-USER-GUIDE-610-CONCEPTS` Partitioning/Profile Placement；`END-NVIDIA-MIG-USER-GUIDE-610-PROFILES` A100/A30 tables | direct；CI isolation是不对称边界 | `supports_requirement`；profile geometry/instance count保留产品条件。 |
| 同 target / `FIELD-VIRT-PREEMPTION-QOS` | `value` 只到 GI QoS/isolation与独立 context switch；preemption子因素 `not_found` | `END-NVIDIA-MIG-USER-GUIDE-610-INTRODUCTION`、`END-NVIDIA-MIG-USER-GUIDE-610-CONCEPTS` Table 3；whitepaper p.51 | direct QoS；MIG610全文无 preempt/context-switch，whitepaper无保存状态/latency | field `supports_requirement`；preemption factor `no_reliable_result`。 |
| 同 target / `FIELD-SW-CHIP-BOUND-SCHEDULING` | `value`，Sys Pipe向GPC/SM调度、不同CI可独立context switch；不写队列/priority/fairness/latency | whitepaper pp.48,51；MIG610 Introduction | direct，A100/MIG conditions | `supports_requirement`。CUDA Graph对该 exact target `checked_no_support`。 |
| GI/CI mode、geometry与monitoring factors | `value`；MIG mode reset/persistence、GI/CI create/destroy idle reconfigure、DCGM v3+及A100 attribution限制 | `END-NVIDIA-MIG-USER-GUIDE-610-DEPLOYMENT`、`END-NVIDIA-MIG-USER-GUIDE-610-GETTING-STARTED`、`END-NVIDIA-MIG-USER-GUIDE-610-CONCEPTS` | direct software lifecycle；workload variables不进入 factor | 真实 VIRT职责可以使 MIG610参与反向移除；identity角色必须移除。 |
| raw MIG migration / raw GI checkpoint / raw hardware preemption factors | `not_found` | MIG610固定章节无 migration/checkpoint/save-restore/preempt；whitepaper p.52只concept | checked no support | `no_reliable_result`；不由r23的vGPU delivered features反推。 |
| A100 vGPU Live Migration、Suspend-Resume、time-sliced preemption | 不写 GA100 reachable fact；产品对象越界 | r23 AI Enterprise 8.2 vGPU docs与vGPU User Guide 20.0-20.2 remote HTML/PDF | direct delivered product/software behavior；当前HTML未本地固定 | 只作条件/negative evidence/card外相关证据；若以后建A100/vGPU对象再接收。 |

### Special mechanism factors

下面每行的 exact target 都是 `OBJ-NVIDIA-GA100-DIE + card-scope factor label`，不是 capability 实体。本报告不创建 factor ID。检索 corpus 至少覆盖 whitepaper v1.0、ISSCC、CUDA PG11、PTX70/72，并按相关性补 HPEC；每个最终 `not_found` 要有 factor-specific search log、actual endpoint 与精确 locator。

| factor label | 建议 | 已查来源中的排除边界 |
|---|---|---|
| Compute Data Compression | `value`，但落真实 `COMP-R1-GA100-L2 / FIELD-MEM-COMPRESSION` | 白皮书/ISSCC正向；假 capability删除。 |
| Attention-bound data movement | `not_found` | `cp.async`是通用 global→shared instruction；没有 Attention buffer/engine。 |
| network collective offload | `not_found` | NVLink是transport；`redux.sync`仅single warp；NCCL是软件库。 |
| dedicated dequantization | `not_found` | datatype conversion与TensorRT工具不等于die内dedicated engine。 |
| KV Cache management | `not_found` | L2 residency/MIG memory partition不是KV manager。 |
| MoE dispatch | `not_found` | CUDA Graph依赖、NVLink transport均无token/expert dispatch queue。 |
| MoE routing | `not_found` | 无expert routing table/token route engine；架构placeholder不作GA100 value。 |
| dedicated quantization | `not_found` | INT8/INT4执行与TensorRT calibration不证明die内quantizer。 |
| Softmax | `not_found` | warp reduce无exponent/normalization/floating chain。 |
| Top-k | `not_found` | reduce无ranking/index selection；架构placeholder不作implementation证据。 |
| transpose/permute | `not_found` | tile/shared copy不等于专用transpose/permute module或instruction。 |
| BIST structure | `not_found` | 与telemetry/Field Diagnostics正向value严格分开。 |

模型、batch、sequence/context length、MoE通信量、KV Cache迁移量、访问window、transaction width、SM-to-chunk/group-to-chunk都属于 workload/experiment variables，不得出现在 chip factor ID、label、selector 或 explains field 中。

### Benchmark、price 与 current status

| exact target + field | 建议 | 来源与 evidence | search-result / 后续 |
|---|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | `pending` | whitepaper/ISSCC无condition-complete workload latency；HPEC cycle是component/instruction measurement；random-access无latency | 需要新 benchmark source，且主体通常是A100产品/系统。 |
| 同 target / `FIELD-BENCH-THROUGHPUT` | `pending` | HPEC Table III单位冲突拒绝；random-access 1240-1600 GB/s是A100 SXM4-80GB product measurement | 产品对象越界；不能当GA100 die benchmark。 |
| 同 target / `FIELD-BENCH-POWER` | `pending` | 两份microbenchmark均未测power；board TDP不是measured workload power | 需要新来源。 |
| 同 target / `FIELD-BENCH-ENERGY-PER-TOKEN` | `pending` | 无J/token | 需要完整model/phase/batch/device/software/measurement scope。 |
| 同 target / `FIELD-BENCH-TOKENS-PER-JOULE` | `pending` | 无token/J；不能从缺失字段倒算 | 需要新来源。 |
| 同 target / `FIELD-BENCH-UTILIZATION` | `pending` | 无MFU/HFU/MBU/scaling-efficiency定义；`full-speed`不能当ratio | 需要新来源。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ECON-PUBLISHED-PRICE` | `not_found` | whitepaper、ISSCC、官方A100页、Product Brief、Newsroom均无standalone die MSRP/list price | `no_reliable_result`；DGX A100 `$199,000`明确rejected，不能除以8。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-STATUS` | `not_found` | 官方未找到GA100/A100 hardware EOS/EOL或current-orderability；vGPU/AI Enterprise只证明software support | `no_reliable_result`；A100 software status为卡外related evidence。 |

Benchmark 的 model、stage、precision、batch、device count、software、power/frequency、statistic 等必须进入 condition set，不得变成 chip factor。若未来仍只有 A100/card/system 实测，而 reachability 不包含相应产品对象，应保持 GA100 benchmark pending 或按 policy 裁为无可达 target，不能把产品 measurement 下放。

## 候选 source-family pool 与反向移除输入

这里列的是候选池，不是最小集，更不预设最终 family 数量。正式 reverse-removal 必须在 field/factor closure、actual endpoint、derived DAG、missing-data evidence 与 product-boundary result 都稳定后逐 family 删除重算。

| source family / 同族版本 | 唯一职责候选 | 可替代关系与反向移除问题 |
|---|---|---|
| `SFAM-M2NA-NVIDIA-AMPERE-WP-2020` v1.0 | GA100 direct identity、full 128 vs A100 108、physical、components、NVLink、L2、ECC、MIG concept | 核心身份与full-design数值最难替代。Technical Blog可替代dated identity一部分，ISSCC可替代实现摘要，均不能完全替代full/enabled边界。 |
| `SFAM-NVIDIA-A100-ISSCC-2021` | 同行评审实现摘要、die photo、54B rounding、NVLink/MIG implementation corroboration | NVIDIA作者来源，不算外部独立验证。若所有accepted facts已由whitepaper覆盖，可能被反向移除；先检查die-photo/implementation role。 |
| `SFAM-NVIDIA-A100-IEEE-MICRO-2021` | A100实现补页与替代endpoint | 与whitepaper/ISSCC高度重合，默认lead。删除若不损失unique fact则不选。 |
| `SFAM-NVIDIA-CUDA-C-PROGRAMMING-GUIDE` 11.0.3 | CUDA runtime/compiler/custom kernel、CC8.0 scheduler、API-level async/barrier/WMMA semantics | PTX不能替代runtime/API，r24 release notes不能替代Programming Guide语义。 |
| `SFAM-NVIDIA-PTX-ISA` 7.0、7.2；7.1 introduction record | exact opcode、tile、rounding/subnormal/saturation/sparsity、sm_80版本链 | 全部revision同族。若7.2覆盖语义且不保留launch contemporaneity，7.0可删除；若保留CUDA11 launch binding，两版可承担不同版本职责，但不增加independent count。 |
| `SFAM-NVIDIA-GPU-MEMORY-ERROR-MGMT` fixed PDF v001、R595 snapshot | fixed PDF承担GA100 RAS正向流程/telemetry；R595仅current Blackwell-only repair negative qualifier | 同族版本。R595若不承接current negative boundary即可删除；不能用它给相同正向事实制造corroborated。 |
| `SFAM-NVIDIA-MIG-USER-GUIDE` version 610 | GI/CI definition、QoS、mode/geometry lifecycle、deployment/monitoring与raw-MIG negative closure | 移除冗余identity role。只有accepted VIRT/lifecycle/factor事实需要时才参选；同guide多个HTML endpoint不增来源数。 |
| `SFAM-NVIDIA-AMPERE-MICROBENCH-2022` arXiv:2208.11174v1 | on-die memory/instruction cycles与PTX-SASS mapping的独立measurement | whitepaper/ISSCC/CUDA/PTX无同类测量，接受任何cycle fact时通常不可替代；若合同或对象条件拒绝全部measurement，则可只留coverage role或删除。IEEE final未核等同。 |
| `SFAM-NVIDIA-A100-RANDOM-ACCESS-2024` arXiv:2405.11425v1 | A100 SXM4-80GB random-access product observation与GA100 benchmark/memory negative-boundary check | 不形成GA100 positive fact；若发布not_found需要证明已检查最相关A100测量，可作为`coverage_obligation_evidence`；否则可能删除。 |
| NVIDIA Technical Blog，2020-05-14（未注册、未快照） | dated GA100 direct naming + full128/A100108同页边界 | 白皮书替代大部分identity，但无同样网页发布日期；是否保留取决于release-date语义。当前只能 ingestion_pending。 |
| NVIDIA Newsroom A100 launch，2020-05-14 HTML+PDF（未注册、未快照） | A100 production/shipping dated event，承担GA100 availability negative boundary | 不形成GA100 value。若die availability `not_found` closure需要该product counterexample则保留，否则可删除。 |
| A100 Product Brief family，40/80GB（未注册、未快照） | card→GA100 SKU映射、产品边界 | whitepaper/blog已覆盖主身份；只有产品SKU或boundary需要时保留。两个brief是产品版本/变体，不算GA100独立核心来源。 |
| vGPU lifecycle + AI Enterprise 8.2 support matrix（各自独立work family；未快照） | A100 current software-support status与exact release/driver binding | 不能替代hardware lifecycle；只在保存卡外status evidence时参选。当前 ingestion_pending。 |
| AI Enterprise 8.2 vGPU feature docs（同一文档家族多个页面；未快照） | A100 vGPU Live Migration、Suspend-Resume、time-slice scheduler、MIG-backed limits | A100 profile页与feature页互为必要binding；不产生raw GA100/MIG fact。当前 ingestion_pending。 |
| vGPU User Guide 20.0-20.2 fixed PDF | command-level migration/save-restore与same-GPU/ECC/topology条件 | AI Enterprise HTML可证明feature存在，不能替代固定PDF的操作与一致性条件；仅产品层使用。 |
| PyTorch Container Release Notes 20.06/20.07（同族；未快照） | PyTorch版本、CUDA11/A100绑定、known issue | TensorFlow family不能替代PyTorch条目；同族月版不算两份来源。当前 ingestion_pending。 |
| TensorFlow Container Release Notes 20.06/20.07（同族；未快照） | TensorFlow版本、A100绑定、NCCL2.7.5→2.7.6 launch issue | PyTorch family不能替代TensorFlow事实。当前 ingestion_pending。 |
| NCCL Release Notes 2.7.5/2.7.6（同族；未快照） | NCCL自身CUDA11兼容与限制 | container只能证明打包，不能替代library compatibility。当前 ingestion_pending。 |
| CUDA Toolkit Release Notes 11.0 GA/Update（同族；未快照） | compute_80/sm_80 reachability、cuBLAS精确版本与Ampere优化 | Programming Guide不完整承担component release/version；当前 ingestion_pending。 |
| cuDNN 8.x Release Notes（同族；未快照） | A100支持起点与TF32 operator覆盖边界 | container只证明包含8.0.1；当前 ingestion_pending。 |
| cuSPARSELt Guide 0.0.1；Release Notes 0.0.1/0.1.0 | SM8.0/CUDA11 sparse library semantics；后续revision仅版本演进 | Guide若闭合launch事实，0.1.0 release notes可lead-only；当前 ingestion_pending。 |
| TensorRT Release Notes 7.1.3/8.6.1、Support Matrix 8.6.1、Developer Guide 8.6.1 | 三个不同work family分别承担lifecycle、CC8.0 reachability、dynamic-shape/INT8 semantics | 不可因同一产品名合成一个family。若只保留2020 Preview，可删除8.6.1两family但字段成熟度必须保持Preview；若要稳定documented value，三类职责需逐一反向移除。当前 ingestion_pending。 |

r23 曾给出六组“建议最小”而 r24 曾给出九组“selected candidate”。这两个数量都不能继承为 v3 结论；它们只是各自子问题里的局部建议。最终 selection member 只能由完整 closure 的反向移除结果决定。

## Pending 分流

| 分流 | 当前 pending 项 | 进入下一状态的门 |
|---|---|---|
| 需要新来源 | full-GA100 benchmark六字段；L1/shared transaction granularity若要重开；GA100 die hardware lifecycle；可能的直接 GA100 software-visible shared capacity；任何仍想量化的degrade/preemption/QoS保证 | 新来源必须直接命名正确主体，固定actual endpoint与locator；benchmark还要完整condition set。 |
| 合同/单位阻塞 | `FIELD-COMP-INSTRUCTION-LATENCY` 的scalar/WMMA cycle；`FIELD-MEM-LATENCY` 的L1/L2/shared cycle；FP64 `.rm/.rp`若要结构化枚举 | 先完成冻结v3合同迁移与fixture；cycle保持原单位，未知frequency不换算。 |
| 产品对象越界 | A100 108-SM/HBM/clock/power；global-memory 290 cycles；random-access throughput；A100 shipping/status/SKU；vGPU migration/suspend/preemption；MIG profile geometry/up-to-7 | 只有产品对象进入本卡reachable inventory或另开产品工作包才能写positive fact；否则只保留condition/negative/related evidence。 |
| 可直接落盘 | 已有本地固定endpoint的identity、physical、128/8192/512/12、11 component names、L1/REG capacity、L2 compression/coherence/pooling、NVLink、PCIe、9×12已裁numerics、RAS fixed PDF、MIG610真实VIRT职责 | 合同迁移完成后，逐事实生成actual-endpoint-aware assertion/search/evidence；通过exact-target、condition、review与reverse-removal门。 |
| ingestion_pending | r23 official-web release/status/vGPU HTML；r24 software五字段的全部HTML family | 保存raw payload/print-to-PDF、最终URL、内部版本、access/snapshot date、bytes、SHA-256；此前不得把语义命中写成completed value。 |

## 实现顺序

第一步先完成独立合同事务，不触碰GA100：核验141-field postimage、新 instruction-latency field、memory cycle/s unit policy、actual endpoint列、factor tables、77个enum group/562行、fixture与审批链。

第二步从合同postimage构建reachable inventory，只接收 `OBJ-NVIDIA-GA100-DIE`、批准的 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`、关系可达的Ampere targets及真实GA100 targets。删除12个fake GAP entity和它们的旧requirement/search/result；不要创建替代实体。

第三步先落本地固定、direct facts，再落derived facts。6144-bit、NVLink per-link/injection/aggregate都必须递归绑定输入fact、formula与source；54B/54.2B按rounding处理，不建伪冲突。随后闭合9×12 mandatory cells，不允许任一格pending或NA逃逸。

第四步处理cycle measurement。只有合同迁移通过后才能新增instruction-latency与memory-latency facts；每条保留A100-conditioned subject、instruction/cache operator、dependency、working-set、SASS mapping、clock domain及unknown software条件。HPEC Table III throughput与124 SM在这一阶段明确写入rejected search语义，不进入fact。

第五步重建RAS/MIG。先用fixed RAS PDF落storage/process/telemetry，再把BIST structure与SDE建factor-specific negative closure；MIG610移除identity角色，只在GI/CI/QoS/lifecycle等真实VIRT职责被接受时参与selection。

第六步固定r23/r24网页。没有本地快照前保持ingestion_pending；完成payload登记后才把GA100 dated naming与Ampere软件五字段转为value。A100/vGPU positive evidence继续留在产品条件或negative boundary，不能越过reachability。

第七步完成special-factor、benchmark、price/status的逐来源search，再生成coverage package。不要先宣告最小来源数量；对每个family做反向移除，重算field/factor closure、derived DAG、actual endpoint、source authority/type与卡外negative evidence。

最后生成13域completeness、coverage manifest与独立批准，再进入chip transaction。任何 `pending_verification`、`conflicting_unresolved`、未固定endpoint或未裁产品边界的行都不得进入provisional/formal closure。

## 逐事实验收清单

1. target ID 必须来自迁移后的真实reachable inventory；只有一个七目标列非空。不存在真实target的机制走factor，不能造capability/topology。
2. 事实主体必须逐字匹配locator：full GA100、A100 enabled product、card/module、vGPU/software、system/cloud分开。除`FIELD-ID-ARCH`外不得投影。
3. 每个`value`都有accepted fact、AFPV2 assertion、同source actual endpoint与非空locator；r23/r24 HTML未落本地时只能ingestion_pending。
4. 每个`not_found`都有factor/field-specific `no_reliable_result`，每个实际检查source都有actual endpoint、locator和`checked_no_support`或受控duplicate；不能用模板检索句。
5. `not_public`只接受明确的supports_not_public证据。本报告没有可直接使用的not_public裁决。
6. `not_applicable`必须由结构predicate证明。HBM stack对die可走结构N/A；108 mandatory numerics cell不得NA，所以integer/logical rounding与subnormal按exact-path `not_found`关闭并保留语义说明。
7. derived fact必须有唯一derived-metric row、连续input order与可复算formula；6144 bit与NVLink三项的direction、traffic basis、unit逐项检查。
8. numerics每个path×field一条requirement；`not_specified`是value，INT8/INT4 saturation拆有/无`satfinite`条件，INT4 4:8保留pair-wise语义。
9. 16×8×16只出现在instruction-tile，physical array保持not_found。HPEC Table III GB/s不改单位，124 SM不进入事实或冲突。
10. instruction/memory cycle必须使用冻结condition contract。未知频率写unknown，不从A100公版clock补齐，不自动换算second。
11. BIST验收拆两层：`FIELD-RAS-TELEMETRY-BIST`接telemetry/Field Diagnostics value；BIST structure factor接not_found。二者不得互相覆盖。
12. MIG610不得再以identity不可替代职责入选；若VIRT facts被接受，再用architecture_mechanism或合同允许角色参与反向移除。
13. PTX 7.0/7.2、RAS PDF/R595、container月版都按同family版本链去重；同族不能把evidence state抬成独立corroborated。
14. HPEC只登记arXiv v1实际endpoint；没有publisher PDF比对前不声称等同IEEE final。
15. workload variables只进condition set。model、batch、sequence/context length、transaction width、random-access window、MoE/KV量不得写入chip factor。
16. A100/vGPU/card事实若没有reachable产品对象，只能进入condition、negative evidence或卡外相关证据；不得成为GA100 accepted fact。
17. source selection不设目标数量。逐family删除后重跑closure，仍满足全部obligation者才可移除；承担missing/factor negative closure者使用`coverage_obligation_evidence`。
18. 最终复算13个completeness domain，不以“有来源标题”代替fact/factor closure，也不以网页可访问代替固定snapshot。

## 质量与失败分类

本报告只新增当前文件，没有修改正式表、合同设计、模板、validator、进度或任何 staging CSV。写作完成后按 `report-humanizer` 对本文件单独扫描，结果为 `No machine-detectable AI tells found`。人工从末节开始逆向复读：先核pending分流与实现顺序，再核source-family职责、各矩阵主体、9×12 cells、真实ID清单，最后回到摘要检查投影与产品边界；未发现主体倒置、状态越级、来源同族误计或前后裁决冲突。

本轮有一次只读文件枚举把不存在的通用 `staging/` 路径写入命令，返回 `No such file or directory`，分类为 model/operator path assumption mistake；随后改用项目中的 `r1_ga100_14_atomic_staging_v2/` 精确路径重查，未影响覆盖范围。几次合并显示输出触发长度截断，分类为 tool/runtime output truncation；已按报告分段和精确行范围重新读取。状态检查先后误把主线子目录和项目外层目录当作 Git checkout，两次都返回 `not a git repository`，分类为 model/operator context mistake；它们均为只读检查，没有产生额外文件或内容变更。没有 user interruption、sandbox denial、approval denial、approval-review connection failure、remote service error 或写入失败。
