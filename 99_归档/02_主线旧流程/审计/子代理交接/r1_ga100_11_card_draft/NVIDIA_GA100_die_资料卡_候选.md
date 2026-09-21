# NVIDIA GA100 die 资料卡（审计候选）

> 模板版本：0.3（审计区候选，不是正式资料卡）  
> 数据链：本候选只读取 `r1_ga100_08_atomic_staging/` 的事实、断言、要求、覆盖与裁决；没有把字段汇总表本身当作事实  
> 卡片状态：`draft / provisional`  
> 资料截止日：`pending_contract_gap`；工作包检索截止为 2026-08-21，但尚无合规事实链写入 `FIELD-ID-DATA-CUTOFF`  
> 对象标识：`OBJ-NVIDIA-GA100-DIE`  
> 对象层级：full GA100 bare die design；模板 0.3 的阅读层枚举没有 `die`，这是待总控处理的模板契约问题  
> 建卡人：`r1_ga100_11_card_draft`  
> 复核人：尚未复核

本卡的主语始终是完整 GA100 裸片设计。A100 enabled implementation、SXM/PCIe 模组或卡、HBM 配置、MIG profile、系统拓扑以及第三方实测设备都不是本卡对象。Ampere 架构能力只通过 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 投影阅读，不复制为 GA100 die 的同义事实。

## 1. 对象、范围和公开定位

| 字段 | 内容 | 条件或时间版本 | 事实或关系标识与证据 |
|---|---|---|---|
| 厂商 | NVIDIA | full GA100 die | `FACT-R1-GA100-ID-VENDOR`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF title and pp.18-19 |
| 正式名称 | NVIDIA GA100 | full GA100 die | `FACT-R1-GA100-ID-NAME`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.18-19；`SRC-NVIDIA-MIG-USER-GUIDE-610` 仅以 Supported GPUs snapshot 的 GA100 rows 限定 A100-SXM4/PCIe 到 GA100 的身份映射 |
| 家族 | GA100 | full GA100 die | `FACT-R1-GA100-ID-FAMILY`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.18-19；`SRC-NVIDIA-MIG-USER-GUIDE-610`，Supported GPUs snapshot, GA100 rows |
| SKU 或配置 | `not_applicable` | 裸片不是 A100 SKU | `FIELD-ID-SKU` 的适用性裁决 |
| 架构代际 | Ampere，关系投影 | 只读 `implements_architecture` | `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`，指向 `OBJ-NVIDIA-AMPERE-ARCH` |
| 对象类型 | die | full physical design | `FACT-R1-GA100-ID-TYPE`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, GA100 full GPU diagram and die photo |
| 首次发布日期、首次可用日期 | `pending_verification` | 现有公开日期绑定 A100 产品 | `FIELD-ID-RELEASE-DATE`、`FIELD-ID-AVAILABILITY-DATE` |
| 产品状态 | `pending_contract_gap` | 冻结名单中的“历史锚点”是项目范围元数据，不是厂商产品状态 | `FIELD-ID-STATUS` |
| 地区或变体 | `not_applicable` | 裸片对象不承载销售地区或 SKU 变体 | `FIELD-ID-REGION` |
| 厂商定位、目标用途、设计目标 | `conditional_product_lead` | 现有措辞主要针对 A100 产品 | `FIELD-ID-VENDOR-POSITIONING`、`FIELD-ID-TARGET-USE-POSITIONING`、`FIELD-ID-DESIGN-OBJECTIVE` |
| 公开部署、部署约束 | 部署为 `conditional_product_lead`；部署约束对 bare die 为 `not_applicable` | DGX/HGX、卡、模组、功率和散热不下放 | `FIELD-ID-DEPLOYMENT`、`FIELD-ID-DEPLOYMENT-CONSTRAINT` |
| 市场准入约束 | `pending_verification` | 需要带地区和有效日期的对象化证据 | `FIELD-ID-MARKET-ACCESS-CONSTRAINT` |

本卡包含 full GA100 physical die design 的直接披露，以及经唯一架构关系投影的 Ampere 公共架构契约。本卡不包含 A100 enabled implementation 的启用资源数、L2/HBM 容量、时钟、功耗、产品峰值、媒体引擎数量、MIG 配置或 NVLink device aggregate，也不包含 card/module、云实例和系统级配置。

### 1.1 与其他对象的关系

| 关系 | 对象 | 说明 |
|---|---|---|
| `implements_architecture` | `OBJ-NVIDIA-AMPERE-ARCH` | `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`；本卡所有标为“架构投影”的事实均由此读取 |
| `sku_variant_of` | `not_applicable` | GA100 die 不是 SKU |
| 上层产品关系 | `pending_verification` | MIG guide 只用于 A100-SXM4/PCIe 到 GA100 的身份限定，不把产品属性下放 |
| `FIELD-REL-QUANTITY` | `not_applicable` | 一条已建关系不等于 quantity=1 |

## 2. 物理实现与部署边界

| 项目 | 原始值 | 规范化值 | 条件和作用域 | 事实标识与证据 |
|---|---:|---:|---|---|
| 代工 | TSMC | TSMC | full GA100 die | `FACT-R1-GA100-PHY-FOUNDRY`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.18, GA100 specifications |
| 制程 | TSMC 7 nm N7 | TSMC N7 | full GA100 die | `FACT-R1-GA100-PHY-PROCESS`；同源 PDF p.18；`SRC-NVIDIA-A100-ISSCC-2021` 仅作限定核验，PDF p.1, Figure 3.2.2 and die summary |
| 裸片数量 | `pending_verification` | 不填 1 | 对象名与 die photo 不能单独证明数量 | `REQ-R1-GA100-PHY-DIE-COUNT` |
| 裸片面积 | 826 mm² | 826 mm² | full GA100 die | `FACT-R1-GA100-PHY-AREA`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.18；`SRC-NVIDIA-A100-ISSCC-2021`，PDF p.1, Figure 3.2.2 and die summary |
| 晶体管 | 54.2 billion | 54,200,000,000 | full GA100 die | `FACT-R1-GA100-PHY-TRANSISTORS`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.18；`SRC-NVIDIA-A100-ISSCC-2021`，PDF p.1 的 54B 是舍入限定，不是冲突 |
| 封装、中介层、基板 | `not_applicable` | 不适用 | 属于 package/module | `REQ-R1-GA100-PHY-PACKAGE`、`REQ-R1-GA100-PHY-INTERPOSER` |
| HBM 堆叠 | `not_applicable` | 不适用 | 堆叠不在 bare die 内 | `REQ-R1-GA100-PHY-HBM-STACKS` |
| HBM interface 总宽 | `pending_verification` | 不派生 6144 bit | 已接收的是 12 个 512-bit controller 组件数，不等于来源直接给出总宽 | `REQ-R1-GA100-PHY-HBM-INTERFACE` |
| 时钟 | `not_found` | 无合格值 | 已完成检索；A100 boost clock 不作为 full-die clock | `REQ-R1-GA100-PHY-CLOCK` |
| 功耗 | `not_found` | 无合格值 | 已完成检索；card/module power 不下放 | `REQ-R1-GA100-PHY-POWER` |
| 散热、形态 | 散热 `not_applicable`；形态为 bare die，card form factor `not_applicable` | 不适用 | 对象边界 | `REQ-R1-GA100-PHY-COOLING`、`REQ-R1-GA100-PHY-FORM-FACTOR` |

## 3. 实测结果的条件

本候选没有接收任何 GA100 die 实测结果，因此不建立负载条件集。A100 memory/cache latency cycles、random-access bandwidth 和容量 cliff 都是产品条件线索或被排除 claim；它们没有被写成芯片属性，模型、访问模式、频率、软件和统计口径也没有被抽成 GA100 固有字段。

## 4. 计算资源、数据流和控制

### 4.1 单元组成与执行方式

| 计算资源 | 数量或结构 | 执行、控制与共享关系 | 事实标识与精确证据 |
|---|---|---|---|
| GPC | 8 | full GA100 design | `FACT-R1-GA100-COMP-COUNT-GPC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| TPC | 64 | full GA100 design | `FACT-R1-GA100-COMP-COUNT-TPC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| SM | 128 | full GA100 design | `FACT-R1-GA100-COMP-COUNT-SM`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| FP32 CUDA Core | 8192 | full GA100 design | `FACT-R1-GA100-COMP-COUNT-FP32`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| third-generation Tensor Core | 512 | full GA100 design | `FACT-R1-GA100-COMP-COUNT-TENSOR`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| 512-bit memory controller | 12 | 组件数量；不派生总 HBM interface width | `FACT-R1-GA100-COMP-COUNT-MEMCTRL`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19, full GA100 versus A100 implementation diagram |
| SM 内部 | 4 个 processing block | 每块含 warp scheduling、dispatch、register file、FP32/INT32、Tensor Core、load/store 和 special-function resources | `FACT-R1-GA100-SM-SHARED`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20 Figure 7 |
| 每 processing block 发射宽度 | 32 per clock | 只适用于该 processing block，不外推为整个 SM 发射宽度 | `FACT-R1-GA100-SM-ISSUE`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20 Figure 7；`COND-R1-GA100-SM-PROCESSING-BLOCK` |
| SIMT SM | 架构投影 | public SIMT machine model 与 GA100 结构图联合支撑；不声称 scheduler RTL | `FACT-M2NA-AMPERE-SM-EXEC`，经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20 Figure 7；`SRC-NVIDIA-PTX-ISA-7-0`，PTX ISA 7.0 §2.2 |
| FP32/INT32 per-thread path | 架构投影 | SIMT 标量 ALU 路径；无 aggregate scalar peak | `FACT-M2NA-AMPERE-CUDA-EXEC`，经同一关系；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20 Figure 7；`SRC-NVIDIA-PTX-ISA-7-0`，PTX ISA 7.0 §§2.2, 3.1 |
| async global-to-shared copy | 架构投影 | 不经 register-file staging；不等同独立 DMA engine | `FACT-M2NA-AMPERE-ASYNC-EXEC`，经同一关系；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.21 and Figure 15 p.40；`SRC-NVIDIA-PTX-ISA-7-0`，PTX ISA 7.0 `cp.async` and `sm_80` target sections |
| split barrier | 架构投影 | arrive/wait barrier 协调 block-wide 或 shared-memory pipeline stages | `FACT-R1-GA100-AMPERE-BARRIER-SCHED`，经同一关系；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.21 and Figure 15 p.40 |

物理 Tensor Core array shape、未公开的 scheduler RTL、native opcode、内部 pipeline 与并发限制均为 `not_found` 或 `pending_verification`，不能用 PTX instruction tile 替代。

### 4.2 吞吐与利用限制

| 路径 | 运算 | 输入与累加格式 | 稠密或稀疏 | 原始吞吐 | 频率与功耗条件 | 对象作用域 | 事实标识与证据 |
|---|---|---|---|---:|---|---|---|
| Tensor Core FP16 | FMA | FP16 A/B，FP32 programmer-visible accumulation | dense | 1024 FMA per SM per clock | 不需要绝对频率；没有转成 FLOP/s | 每 SM | `FACT-R1-GA100-FP16-FMA-PER-SM`、`FACT-R1-GA100-FP16-COUNT-RULE`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20, third-generation Tensor Core throughput statement；格式见 PDF p.27 Table 3 |

运算计数规则保留 vendor label：FMA per SM per clock。没有把一次 FMA 静默乘二，也没有把 per-SM 值乘 128 得到全裸片峰值。厂商总算力、利用率限制与并发上限没有合格的 full-GA100 无条件值。

## 5. 数值格式和稀疏机制

下表中的“架构投影”均由 `OBJ-NVIDIA-AMPERE-ARCH` 经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 读取，不是复制到 GA100 die 的事实。表中格式是 programmer-visible contract，不代表物理内部乘积或累加器宽度。

| 路径 | A / B | 程序员可见累加或输出 | 稀疏模式 | 事实标识与精确证据 |
|---|---|---|---|---|
| FP16 direct GA100 path | FP16 / FP16 | accumulation FP32；output `not_found` | dense direct；2:4 为架构投影 | `FACT-R1-GA100-FP16-A`、`FACT-R1-GA100-FP16-B`、`FACT-R1-GA100-FP16-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3；`FACT-R1-GA100-AMPERE-SPARSE-FP16`，`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 and revision history |
| BF16，架构投影 | BF16 / BF16 | accumulation FP32；output `not_found` | 2:4 | `FACT-M2NA-AMPERE-BF16-A`、`FACT-R1-GA100-AMPERE-BF16-B`、`FACT-M2NA-AMPERE-BF16-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3 BF16 row；`FACT-R1-GA100-AMPERE-SPARSE-BF16`，`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 |
| TF32，架构投影 | TF32 / TF32；外围 FP32 input 转为 TF32 乘法输入 | accumulation FP32；output FP32 | 1:2 | `FACT-M2NA-AMPERE-TF32-A`、`FACT-R1-GA100-AMPERE-TF32-B`、`FACT-M2NA-AMPERE-TF32-ACC`、`FACT-R1-GA100-AMPERE-TF32-CONVERSION`、`FACT-R1-GA100-AMPERE-TF32-OUTPUT`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.26 and Figure 9 p.27、p.27 Table 3；`FACT-R1-GA100-AMPERE-SPARSE-TF32`，`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 |
| IEEE FP64，架构投影 | IEEE FP64 / IEEE FP64 | accumulation IEEE FP64；output `not_found` | 未接收 sparse pattern | `FACT-M2NA-AMPERE-FP64-A`、`FACT-R1-GA100-AMPERE-FP64-B`、`FACT-R1-GA100-AMPERE-FP64-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3 IEEE FP64 row |
| INT8，架构投影 | INT8 / INT8 | accumulation INT32；output `not_found` | 2:4 | `FACT-M2NA-AMPERE-INT-A`、`FACT-R1-GA100-AMPERE-INT8-B`、`FACT-R1-GA100-AMPERE-INT8-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3 INT8 row；`FACT-R1-GA100-AMPERE-SPARSE-INT8`，`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 |
| INT4，架构投影 | INT4 / INT4 | accumulation INT32；output `not_found` | pair-wise 4:8 | `FACT-R1-GA100-AMPERE-INT4-A`、`FACT-R1-GA100-AMPERE-INT4-B`、`FACT-R1-GA100-AMPERE-INT4-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3 INT4 row；`FACT-R1-GA100-AMPERE-SPARSE-INT4`，`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 |
| Binary，架构投影 | Binary / Binary | accumulation INT32；output `not_found` | 未接收 sparse pattern | `FACT-R1-GA100-AMPERE-BINARY-A`、`FACT-R1-GA100-AMPERE-BINARY-B`、`FACT-R1-GA100-AMPERE-BINARY-ACC`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.27 Table 3 Binary row |

结构化稀疏的通用机制是 dedicated instruction：硬件读取已压缩 sparse operand A 与 metadata，据此选择匹配的 dense operand B，并跳过结构化零乘法。它不在运行时发现非零，也不证明 runtime pruning、selector RTL 或持续 2× speedup。证据为 `FACT-M2NA-AMPERE-SPARSE-LEVEL` 和 `FACT-M2NA-AMPERE-SPARSE-DETAIL`，经架构关系投影；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.31-32 Figures 12-13，以及 `SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1。

物理内部累加器、product encoding、rounding、saturation、scaling mode/granularity 与 subnormal 行为均为 `not_found`，没有从格式名称反推。

## 6. 存储层次和数据搬运

| 层级 | 实例和局部性 | 管理与汇聚方式 | 物理容量 | 带宽、延迟、端口或 Bank | 事实标识与精确证据 |
|---|---|---|---:|---|---|
| SM register file | 每 SM 4 个 register-file group | 256 KiB 是 aggregate capacity only | 262,144 B per SM | read/write bandwidth 与端口 `not_found` | `FACT-R1-GA100-REG-CAPACITY-PER-SM`、`FACT-R1-GA100-REG-INSTANCE-COUNT-PER-SM`、`FACT-R1-GA100-REG-AGGREGATION`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.22 Figure 7 and p.37 Table 4 |
| unified L1 data cache/shared memory | 每 SM | combined physical resource；不把 software-visible allocation 当物理总量 | 196,608 B（192 KiB）per SM | read/write bandwidth、latency in seconds、ports/banks `not_found` 或 `pending` | `FACT-R1-GA100-L1SMEM-CAPACITY-PER-SM`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.21 and p.22 Figure 7 |
| L2 cache | full GA100 有该组件实体 | 容量不能从 A100 enabled implementation 下放 | `pending_verification` | bandwidth/latency `not_found` | `FACT-R1-GA100-COMP-NAME-L2`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.19 full GA100 diagram and pp.20-21 |
| 片外 HBM | 不属于 bare die 内存实体 | 产品容量、可用容量、带宽和堆叠数不下放 | `not_applicable` / product-conditioned lead | 无 accepted full-die value | 物理边界要求与 claim dispositions |

架构投影的 async global-to-shared copy 见 4.1。虚拟内存、压缩、pooling、consistency 和 software-visible usable capacity 只保留产品条件线索；完整 GA100 die 的 read/write model、每周期传输量与持续带宽没有合格值。

## 7. 芯片侧配比指标

六类派生指标全部保持 `pending_verification`：compute/bandwidth 规格比、持续比、capacity/compute、matrix/vector、data-move/matrix 和 interconnect/compute。当前缺少同一主体、同一 precision、同一方向、同一 count rule 与相容作用域的输入事实，因此不能计算。full GA100 资源数也不能与 A100 HBM、L2 或 NVLink device aggregate 混算。

## 8. 可能形成架构差异的专用机制

| 候选机制 | 状态与实现层级 | 边界 | 事实或要求标识与证据 |
|---|---|---|---|
| Attention 数据搬运 | `not_found` | general async copy 不证明 attention 专用路径 | `REQ-R1-GA100-CAP-GAP-ATTENTION-MOVE` |
| Softmax | `not_found` | warp reduction 不是 Softmax unit | `REQ-R1-GA100-CAP-GAP-SOFTMAX` |
| warp reduction，架构投影 | `dedicated_instruction` | warp scope 仅支持 ADD/MIN/MAX 与 AND/OR/XOR；其他类型或操作走软件 | `FACT-R1-GA100-AMPERE-REDUCE-LEVEL`、`FACT-R1-GA100-AMPERE-REDUCE-DETAIL`、`FACT-R1-GA100-AMPERE-REDUCE-LIMIT`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.67 Figure 35；经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` |
| Top-k、MoE route/dispatch | `not_found` | 没有接收 dedicated unit/instruction | `REQ-R1-GA100-CAP-GAP-TOPK`、`REQ-R1-GA100-CAP-GAP-MOE-ROUTE`、`REQ-R1-GA100-CAP-GAP-MOE-DISPATCH` |
| 集合通信卸载 | `not_found` | NVLink protocol 不证明 network collective offload | `REQ-R1-GA100-CAP-GAP-COLLECTIVE` |
| sparse skip，架构投影 | `dedicated_instruction` | datatype-specific pattern 见第 5 节 | `FACT-M2NA-AMPERE-SPARSE-LEVEL`、`FACT-M2NA-AMPERE-SPARSE-DETAIL`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.31-32；`SRC-NVIDIA-PTX-ISA-7-2`，§9.7.13.5.1 |
| quantize / dequantize | `not_found` | 格式转换不证明 dedicated quantizer | `REQ-R1-GA100-CAP-GAP-QUANTIZE`、`REQ-R1-GA100-CAP-GAP-DEQUANTIZE` |
| transpose / permute | `not_found` | 没有接收 dedicated physical mechanism | `REQ-R1-GA100-CAP-GAP-TRANSPOSE` |
| compression | `pending_verification` | A100 L2 compression 仍是产品条件线索 | `REQ-R1-GA100-CAP-GAP-COMPRESSION` |
| KV Cache management | `not_found` | 没有接收 chip-bound KV Cache manager | `REQ-R1-GA100-CAP-GAP-KV-CACHE` |
| Optical Flow Accelerator | `dedicated_physical_module` | optical flow 与 stereo disparity；quality/performance 可调；无 accepted throughput | `FACT-R1-GA100-OFA-LEVEL`、`FACT-R1-GA100-OFA-DETAIL`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.56, Optical Flow Accelerator paragraph |
| hardware video decoder | `dedicated_physical_module` | H.264 8-bit 4:2:0；HEVC 8/10/12-bit 4:2:0、4:4:4；VP9 8/10/12-bit 4:2:0。A100 decoder count/throughput 排除 | `FACT-R1-GA100-VIDEO-LEVEL`、`FACT-R1-GA100-VIDEO-DETAIL`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.56-57 Table 7 |

## 9. 互联和拓扑

| 层级 | 协议和代际 | 链路、速率与带宽 | 故障机制或边界 | 事实标识与精确证据 |
|---|---|---|---|---|
| 片内 | `pending_verification` | topology、routing、latency 未接收 | 不从结构图推断 | field requirements |
| 主机接口 | PCI Express 4.0 x16 | 未接收带宽值 | full GA100 block diagram | `FACT-R1-GA100-PCIE-PROTOCOL`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20 Figure 6 |
| NVLink，架构投影 | NVLink 3 | full-GA100 link count、per-link rate、injection/aggregate bandwidth 均 `pending_verification` 或不下放 | 改进 link-level error detection and recovery；不外推为全芯片 RAS | `FACT-R1-GA100-AMPERE-NVLINK-FAULT`，经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF pp.16-17, third-generation NVLink reliability description |
| 设备直连、Scale-up、Scale-out 拓扑 | `not_applicable` 于 bare die | degree、hops、bisection、routing、max scale 属于上层设备/系统 | A100/DGX/HGX 数值不下放 | interconnect field requirements |

## 10. 软件、调度和虚拟化

| 类别 | 内容 | 版本、证据层级或条件 | 事实标识与精确证据 |
|---|---|---|---|
| 编程模型 | CUDA 11.0 与 PTX 7.0 expose Ampere `sm_80` async-copy 和 split-barrier capabilities | 架构投影；documented interface，不是 runnable validation | `FACT-M2NA-AMPERE-SW`，经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`；`SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`, Compute Capability 8.x async-copy/barrier sections；`SRC-NVIDIA-PTX-ISA-7-0`, revision history and sm_80 target sections |
| 软件支持成熟度 | `documented_supported` | CUDA 11.0 async-copy API 有 experimental 边界；不升级为 runnable_verified/benchmarked | `FACT-R1-GA100-AMPERE-SW-MATURITY`，经同一关系；`SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`，CUDA C++ Programming Guide 11.0, Compute Capability 8.x and async-copy sections |
| ISSCC `CUDA 8.0` | `conflicting_unresolved`，不接收 | 疑似 Compute Capability 8.0 只能作为推断，不能暗改 | `ASSERT-R1-GA100-AMPERE-SW-ISSCC-CAVEAT`；`SRC-NVIDIA-A100-ISSCC-2021`, PDF p.2, asynchronous barrier paragraph |
| framework、operator library、communication library | `pending_verification` | 必须固定版本和对象 | software field requirements |
| custom operator、dynamic shape、quantization tool | `not_found` | 完成计划检索后未形成 chip-specific accepted fact | software field requirements/search logs |
| runtime、compiler、chip-bound scheduling | `conditional_product_lead` | 不把 driver table、CUDA Graph 或产品行为写成 die 常量 | field coverage decisions |
| MIG partitioning、多租户、QoS | `conditional_product_lead` | A100/A30 的 profile geometry、最大实例数、memory/engine count 不下放 | `SRC-NVIDIA-MIG-USER-GUIDE-610` 只在本卡承担身份映射；虚拟化 facts 未接收 |

## 11. 可靠性、可用性和可维护性

以下 RAS（Reliability, Availability and Serviceability）事实是 GA100 支持矩阵与机制链的条件化直接事实。它们涉及 external HBM、driver、application、InfoROM、service/reset flow，不能改写成纯 on-die autonomous repair。

| 维度 | 机制与覆盖范围 | 条件、粒度和限制 | 事实标识与精确证据 |
|---|---|---|---|
| dynamic page offlining | framebuffer uncorrectable error 通过 NVIDIA driver 下线页面 | driver 参与 | `FACT-R1-GA100-RAS-DPO`；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`，GPU Memory Error Management, June 2023, GA100 feature matrix and mechanism sections |
| 错误定位 | driver 在下线前定位 framebuffer UCE | detector circuit 与 page size 未公开 | `FACT-R1-GA100-RAS-DETECTION`；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`，GPU Memory Error Management, June 2023, GA100 feature matrix and mechanism sections |
| 恢复过程 | 受影响 application 终止，页面标为 unusable；回收依赖 reset/recovery flow | 不是无损继续运行 | `FACT-R1-GA100-RAS-RECOVERY`；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`，同一文档的 GA100 feature matrix and mechanism sections |
| row remapping | failing external HBM/DRAM row 在 driver、service、reset 流程后映射到 spare row | 外部内存与软件流程共同参与 | `FACT-R1-GA100-RAS-ROW-REMAP`；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`，同一文档的 GA100 feature matrix and mechanism sections |
| error containment | contained UCE 可隔离；rare uncontained UCE 仍可能发生 | 不宣称绝对隔离或量化 coverage | `FACT-R1-GA100-RAS-CONTAINMENT`；`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`，同一文档的 GA100 feature matrix and mechanism sections |
| ECC 与 protection scope | `conditional_product_lead` | 没有 full-GA100 all-state ECC map | reliability field coverage |
| silent data error | `not_found` | memory ECC/link replay 不证明 Tensor/CUDA Core SDE coverage | `REQ-R1-GA100-RAS-SDE` |
| telemetry / BIST | telemetry 为 conditional lead；die-internal BIST `not_found` | Field Diagnostic/RMA policy 不证明 BIST structure | `REQ-R1-GA100-RAS-BIST` |
| checkpoint/restart | `pending_verification` | MIG migration 描述不证明 delivered general checkpoint/restart 或 live migration | `REQ-R1-GA100-RAS-CKPT` |

## 12. 实测、利用率、能效和公开价格

### 12.1 实测指标

| 指标领域 | 状态 | 原因 |
|---|---|---|
| latency、throughput、power、utilization、energy/token、token/J | `missing_public_data` 于本卡对象 | A100 microbenchmark 和 random-access 观察没有 formal A100 subject 与完整条件，不能作为 full GA100 die 实测；本卡不建立虚构 workload condition set |

### 12.2 公开价格

公开价格为 `not_applicable`。GA100 bare die 不是单独公开定价对象，A100 card、cloud instance、DGX/HGX 或二手价格不能折算成 die 价格。

## 13. 缺失、冲突和待核问题

### 13.1 缺失字段

| 字段或领域 | 状态 | 已检查范围或证据链 | 仍需要什么 |
|---|---|---|---|
| die count、HBM interface 总宽、GA100 link count | `pending_verification` | 白皮书图、component facts 与 search logs | direct atomic count/width statement 或总控接受的 diagram-count policy |
| die clock、power | `not_found` | `REQ-R1-GA100-PHY-CLOCK`、`REQ-R1-GA100-PHY-POWER` 对应完成检索 | full-die、非产品模式的明确披露 |
| L2 capacity、memory bandwidth、latency in seconds | `pending_verification` / `not_found` | memory requirements 与 search logs | 同一 full-die 主体、单位和作用域证据 |
| physical Tensor array、internal accumulator、rounding/saturation/scaling/subnormal | `not_found` | precision-path requirements 与 search logs | 公开微架构或 ISA contract，不接受作者推断 |
| benchmark | `missing_public_data` | claim dispositions | formal measurement subject 和完整 condition set |
| data cutoff、historical_anchor status | `pending_contract_gap` | 项目元数据可见，但事实契约不完整 | 总控决定管理元数据的落位方式 |

### 13.2 来源冲突与已排除 claim

| 事实分组 | 来源或 claim | 差异 | 当前处理 |
|---|---|---|---|
| software version | ISSCC `CUDA 8.0` vs official CUDA 11.0/PTX 7.0 | 实质冲突 | 拒绝 ISSCC version value；不暗改为 CC 8.0 |
| transistor count | ISSCC 54B vs whitepaper 54.2B | 舍入差异 | 54.2B 为规范值，54B 仅作 rounded qualifier |
| HPEC Table III | 表头 GB/s 与数值量级不一致 | source claim 内部冲突 | `rejected_claim`，不替作者改为 TFLOPS/TOPS |
| A100 latency cycles | schema 需要 seconds，且缺 clock/product condition | 单位和主体不闭合 | `conditional_gap` |
| A100 random-access bandwidth/cliff | product measurement、软件/频率/统计条件不完整 | 主体与条件不闭合 | `excluded_from_facts` |
| A100 MIG、NVDEC/NVJPG、link aggregate | enabled product/profile 值 | 不是 full GA100 die 常量 | excluded 或 pending product scope |

## 14. 最小参考资料

### 14.1 本卡候选入选来源

以下是 `SELRUN-GA100-DIE-20260821-PROVISIONAL` 的 draft 成员，不是正式最小来源结论。19 个 stable payload 尚未复制，formal merge、assertion review 和 Windows hard gates 均未完成，因此必须重跑 reverse removal。

| 来源标识 | 角色 | 独有贡献 | 精确定位 | 当前状态 |
|---|---|---|---|---|
| `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | core_spec | full-GA100 identity、physical/resource counts、per-SM capacity/FMA、media/OFA、PCIe 与多项架构机制 | PDF pp.18-22, 26-27, 31-32, 37, 40, 56-57, 67；各事实定位见前文 | provisional selected |
| `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` | core_spec | GA100 DPO、row remapping、containment、detection/recovery process | June 2023, GA100 feature matrix and mechanism sections | provisional selected |
| `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0` | architecture_mechanism | CUDA 11.0 `sm_80` API exposure 与 documented-support maturity | Compute Capability 8.x and async-copy/barrier sections | provisional selected |
| `SRC-NVIDIA-PTX-ISA-7-0` | architecture_mechanism | SIMT model、`sm_80` async-copy 与 split-barrier version boundary | §§2.2, 3.1；`cp.async`/`sm_80` target sections；revision history | provisional selected |
| `SRC-NVIDIA-PTX-ISA-7-2` | architecture_mechanism | datatype-specific `mma.sp` metadata 与 sparse pattern | §9.7.13.5.1 and revision history | provisional selected |
| `SRC-NVIDIA-MIG-USER-GUIDE-610` | identity | A100-SXM4/PCIe 到 GA100 的官方身份映射 | Supported GPUs snapshot, GA100 rows | provisional selected |

### 14.2 被覆盖或未采用的来源

| 来源标识或 claim | 状态 | 理由 | 覆盖来源或处理 |
|---|---|---|---|
| `SRC-NVIDIA-A100-IEEE-MICRO-2021` | `redundant_covered` | 当前 accepted claim set 全部由固定白皮书覆盖 | `SRC-M2NA-NVIDIA-AMPERE-WP-2020` |
| `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595` | `stronger_for_same_claim` / lead | 当前 accepted GA100 RAS 机制由固定 June 2023 PDF 承担；moving pages 不新增入选事实 | `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` |
| `SRC-NVIDIA-A100-ISSCC-2021` | lead/qualifier | 仅对 process、area、rounded transistor 与版本冲突提供限定，不是本轮 provisional selection member | 不适用 |
| HPEC、random-access、A100 product/MIG claims | lead、excluded 或 rejected | 主体、单位、条件或 source-internal consistency 不满足 | 见 13.2 |

## 15. 完整度和复核

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | name/family/type/vendor 与 architecture relation 已有候选；status/date/positioning 未闭合 |
| 物理实现 | `partial` | foundry/process/area/transistors 已有；die count、HBM interface、clock/power 未闭合 |
| 计算资源 | `partial` | full-design counts、SM structure 与 per-SM FP16 FMA path 已有 |
| 数值格式 | `partial` | direct FP16 与 Ampere projection 已有；physical arithmetic semantics 缺失 |
| 存储层次 | `partial` | per-SM register file、L1/shared 与 L2 entity 已有；L2/HBM 产品值不下放 |
| 互联 | `partial` | PCIe direct 与 NVLink architecture mechanism 已有；full-die link count/aggregate 未闭合 |
| 特殊能力 | `partial` | OFA、video decode、sparse、async copy、warp reduction 有记录；其他机制逐项缺失 |
| 软件 | `partial` | CUDA 11.0/PTX 7.x documented support；无 runnable validation |
| 调度与服务机制 | `partial` | split barrier、warp reduction 已有；CUDA Graph/MIG 仍属产品条件线索 |
| 可靠性 | `partial` | GA100 DPO、row remapping、containment 与 process chain 已有条件化候选 |
| 实测指标 | `missing_public_data` | 没有可归属 full GA100 die 且条件完整的实测 |
| 经济性 | `not_applicable` | bare die 无单独公开价格 |
| 来源证据 | `partial` | staging 断言、筛选、endpoint 和 provisional selection 齐备；payload copy 与 formal gates 未完成 |

自检结果：芯片属性、厂商/产品线索和负载条件已经分层；关键值均回到 `source_id` 与精确定位；architecture facts 均明确经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 投影；`not_found`、`not_applicable` 与 `pending_verification` 没有互换；本卡没有派生 6144-bit HBM interface、full-die peak 或任何负载变量。

复核结论：可作为总控审阅的审计候选，不能直接复制为正式资料卡。staging 静态 overlay validation 已报告 PASS，但 19 个 payload 尚未复制，selection run 仍是 provisional，formal assertion review 与 Windows `Test-SourcePool.ps1`、`Test-ChipScope.ps1`、`Validate-ResearchData.ps1` 均未运行。
