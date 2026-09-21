# GA100 内容验收与事实缺口矩阵

> 交付边界：本表只裁决“资料卡作者现在可以怎样写”，不设计合同，不生成正式 CSV，也不宣称已经完成正式入库、来源选择或发布门。研究对象默认是 `OBJ-NVIDIA-GA100-DIE`，即 full GA100 物理设计；只有表中明确写出 Ampere、A100、软件栈或 system 条件的行，才允许换主体。`not_found` 表示在本轮已列明的计划语料内没有找到可归属到该 exact target 的可靠值，不表示全网绝对不存在。

## 验收口径

状态只有五种。`可直接写值` 表示来源主语、对象层级和 locator 已足以支撑内容；派生值仍须保留公式。`条件化写值` 表示可以写，但必须把 A100 测试载体、软件版本、模式、方向或上界一并写入。`not_found` 不生成数值事实，只保留逐项检索结论。`not_applicable` 只用于已有结构 predicate 明确覆盖的主体。`仍 pending` 表示字段语义、版本条件或适用性 predicate 尚未裁清。

来源简称：`WP` 为 *NVIDIA Ampere Architecture In-Depth* 白皮书 v1.0；`ISSCC` 为 2021 A100/GA100 ISSCC 论文；`CUDA-PG11` 为 CUDA C Programming Guide 11.0.3；`PTX70/72` 为 PTX ISA 7.0/7.2；`HPEC-v1` 为 arXiv:2208.11174v1；`RAS-PDF` 为 NVIDIA *GPU Memory Error Management* 固定 PDF；`MIG610` 为 MIG User Guide 610；`WEB001-005` 为已验收的 Technical Blog、Newsroom 及 A100 Product Brief 快照；`Matrix` 为 NVIDIA Matrix Multiplication Background Guide 快照；`MLC-36d324b5` 为 MLCommons 固定提交；`SEC-10Q` 为 NVIDIA 2022-07-31 10-Q 固定快照。

## 1. 对象、物理实现和公开定位

| ID | 资料卡项 | 状态 | target 层级 | 可写内容或缺口 | 来源 / locator | 禁止误用的相邻主体 |
|---|---|---|---|---|---|---|
| M001 | 正式名称、family、vendor、object type | 可直接写值 | GA100 die | `NVIDIA GA100`；family=`GA100`；vendor=`NVIDIA`；object type=`die` | WP pp.9,14,19；ISSCC die photo | `A100` 是启用产品，不是 full GA100 的别名 |
| M002 | 架构代际 | 可直接写值 | `GA100 implements Ampere` relation | GA100 implements NVIDIA Ampere architecture；只用关系表达 | WP pp.9,14,19 | 不得沿该关系把 Ampere 的其他字段复制到 GA100 die |
| M003 | release date | 仍 pending | GA100 die | 2020-05-14 只能写成“官方材料首次直接命名 GA100 的已固定观察日”；在全库 release 语义未统一前不写成对象发布日期 | WEB001 页首日期、metadata、`Key features`；r37/r39 | A100 同日 full production/shipping 不是 GA100 die release |
| M004 | availability date | not_found | GA100 die | 未找到 standalone GA100 供货或可订购日期 | WEB001-005；WP；ISSCC | A100 card/module shipping date |
| M005 | current status | not_found | GA100 die | 未找到 GA100 裸片生产、销售、EOS/EOL 或 current-orderability 的对象级状态 | WEB001-005；vGPU lifecycle / AI Enterprise 8.2 | A100 软件仍受支持不等于 GA100 硬件在售 |
| M006 | SKU | not_found | GA100 die | full design codename 不是公开 card SKU | A100 Product Briefs WEB004-005 | `GA100-883/893...` 等产品 GPU/SKU 不能写成 full-design SKU |
| M007 | deployment | not_found | GA100 die | 未找到 standalone die 的部署事实 | WP DGX/HGX/A100 章节；WEB001-005 | DGX、HGX、cloud、PCIe card、SXM module |
| M008 | market-access constraint | not_found | GA100 die | 已查 SEC 许可要求，直接主体为 A100/H100 integrated circuits 及其系统，未直接命名 full GA100 design | SEC-10Q `Item 1A. Risk Factors`；WP/WEB001/004/005 | A100 product 的出口限制不能借 identity bridge 投给 GA100 die |
| M009 | design objective | 可直接写值 | Ampere architecture | 面向 existing DNN 的 strong scaling；fixed workload per GPU | WP p.38 `Strong Scaling Deep Learning Performance` | 这是 architecture value，不是 GA100 die 的对象级目标 |
| M010 | target-use positioning | 可直接写值 | Ampere architecture | 保守写成“面向 existing DNN 的 strong-scaling deep-learning workload” | WP p.38 | 不扩成 GA100 覆盖全部 AI/HPC/data analytics 场景 |
| M011 | vendor positioning | 可直接写值 | Ampere architecture | 改善可编程性、降低 latency 与 AI/HPC 软件复杂度，并相对 Volta 提高 performance/W | WP p.11 | 厂商架构定位不是第三方实测，也不是 GA100 die positioning |
| M012 | GA100 die design objective | not_found | GA100 die | 现有直接主语是 Ampere 或 A100 | WP pp.11,38；ISSCC；WEB001-005 | 不从 M009 投影 |
| M013 | GA100 die target-use positioning | not_found | GA100 die | 现有用途句直接修饰 A100 产品或 Ampere 架构 | 同上 | 不把 A100 training/inference 定位下放 |
| M014 | GA100 die vendor positioning | not_found | GA100 die | `GA100 powers A100` 只是 identity bridge，不是厂商市场定位 | WEB001 `Key features`；WP pp.9,14,19 | identity 不等于 positioning |
| M015 | foundry 与 process | 可直接写值 | GA100 die | `TSMC N7 / 7 nm` | WP p.14、pp.36-37；ISSCC p.1 | 不把 7 nm 泛化成后续 Ampere 产品全部制程 |
| M016 | die area | 可直接写值 | GA100 die | `826 mm²` | WP p.14、pp.36-37；ISSCC p.1 | package/interposer area |
| M017 | transistor count | 可直接写值 | GA100 die | `54.2 billion`；ISSCC 的 `54 billion` 是同值舍入 | WP p.14、pp.36-37；ISSCC p.1 | 不建 54 与 54.2 的伪冲突 |
| M018 | die count | not_applicable | GA100 die | target 本身就是一颗 die design，不把自计数写成 package-level `1` | WP pp.19-20；ISSCC die photo；结构判断 | A100 package 的 die/chiplet count |
| M019 | HBM stack count | 仍 pending | GA100 die | 阅读层可说明 HBM stack 属于 package/product path；本轮既有合同没有覆盖该 exact pair 的 structural N/A predicate，formal requirement 先保持 pending，不新增全局 predicate | WP pp.19,35-37；`ga100_content_independent_review.md` M019 裁决 | full physical 6-stack package 与 A100 5-active-stack 产品均不得写入 die 行 |
| M020 | HBM total interface | 可直接写值 | GA100 die | `12 × 512 bit/controller = 6144 bit`，标记 `public_derived` 并保留两个输入及公式 | WP p.19 | A100 enabled `10×512=5120 bit`、HBM 容量和 stack 数 |
| M021 | die clock | not_found | GA100 die | 未找到 full GA100 design 的对象级时钟 | WP Table 4；ISSCC 1.41 GHz | A100 boost clock |
| M022 | die power | not_found | GA100 die | 未找到 full GA100 die power | WP p.37；Product Briefs | A100 SXM/PCIe 的 400/300/250 W TDP/TBP |

## 2. 计算资源、数据流和利用限制

| ID | 资料卡项 | 状态 | target 层级 | 可写内容或缺口 | 来源 / locator | 禁止误用的相邻主体 |
|---|---|---|---|---|---|---|
| M023 | GPC count | 可直接写值 | full GA100 GPC component | `8 GPC` | WP p.19 | A100 enabled product |
| M024 | TPC count | 可直接写值 | full GA100 TPC component | `64 TPC` | WP p.19 | 不把 `8×8` 再当第二份独立证据 |
| M025 | SM count | 可直接写值 | full GA100 SM component | `128 SM` | WP p.19 | A100 `108 SM`；HPEC 背景错误的 `124 SM` |
| M026 | FP32 CUDA core count | 可直接写值 | full GA100 FP32 component | `8192`，即 128 SM × 64 FP32/SM，且白皮书直接给出总数 | WP p.19 | A100 `6912` |
| M027 | third-generation Tensor Core count | 可直接写值 | full GA100 Tensor component | `512`，即 128 SM × 4/SM | WP p.19 | A100 `432` |
| M028 | memory-controller organization | 可直接写值 | full GA100 memory-controller component | `12` 个 controller，每个 `512 bit` | WP p.19 | A100 仅启用 10 个 controller |
| M029 | A100 enabled resource slice | 条件化写值 | A100 product implementation | `108 SM / 6912 FP32 / 432 Tensor Core / 10×512-bit controller`，只作为产品边界附注 | WP p.19；ISSCC p.1；WEB001 | 不得与 M025-M028 建成 same-target conflict |
| M030 | GA100 Tensor dense per-SM throughput | 可直接写值 | GA100 Tensor component | `1024 FP16/FP32 FMA per SM per clock`，保留 vendor count rule，不自行乘 2 | WP p.20 / SM-Tensor table | 不乘 A100 1.41 GHz 推 full-die TFLOP/s |
| M031 | physical Tensor array shape | not_found | GA100 Tensor component | 公开资料只给 instruction tile/opcode shape，没有物理阵列行列数 | PTX70/72；WP p.39 | `m16n8k16` 等指令 tile |
| M032 | instruction tile | 可直接写值 | Ampere precision path | 按 datatype、dense/sparse opcode 保存公开 tile set；例如 FP16 `m16n8k16` | PTX70 pp.325-327；PTX72 pp.348-350；WP p.39 | 不写成 physical array shape |
| M033 | dataflow residency | 可直接写值 | Ampere Tensor component | 32-thread warp 内 operand sharing，减少 RF bandwidth 和重复 SMEM→RF load | WP pp.38-39 `Data sharing improvements` / Figure 14 | `cp.async` 是 feeding path，不并入 Tensor 内部 residency |
| M034 | SM control、concurrency 与 shared resources | 可直接写值 | Ampere/GA100 SM component | 每 SM 四个 processing block；四 warp scheduler、static warp distribution；FP32+INT32 可并发发射；共享 REG、LD/ST、SFU、Tensor 等资源按图陈述 | WP Figure 7；CUDA-PG11 p.370 | 不推导端口数、queue 深度、dual issue 或所有单元同时峰值 |
| M035 | Tensor/GEMM utilization limit | 条件化写值 | GA100 Tensor component，A100-SXM4-80GB carrier | 可写 alignment、small-GEMM tile efficiency/parallelism tradeoff、tile quantization；保留 CUDA 11.2、cuBLAS 11.4、datatype、matrix/tile shape | Matrix §2.2、§2.3、§3.1；r37/r39 accept | §3.2 的 A100 `108 SM` wave/tail 不能换成 full GA100 `128 SM` |
| M036 | full-design aggregate compute throughput | not_found | GA100 die | 缺 full-design clock 与同对象、同 precision 的 aggregate peak | WP/ISSCC/HPEC-v1 | A100 108-SM peak、boost clock、sparse effective TOPS |

## 3. precision path 9×12 内容摘要

这一节按 108 个 cell 计数，但不预设任何来源数量或“多少项必须有值”的配额。代码为：`D`=可直接写值，`C`=条件化写值，`NF`=`not_found`，`NA`=`not_applicable`。前八条 path 的 target 是 Ampere Tensor；最后一条是 GA100 Tensor implementation。PTX 是 virtual ISA，不证明原生 RTL、物理阵列或内部 accumulator。

| precision path | operand A | operand B | accumulation | product | physical accum | output | rounding | scaling mode | scaling granularity | saturation | subnormal | sparsity |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FP16→FP32 | D:FP16 | D:FP16 | D:FP32 | NF | NF | D:FP32 | D:`not_specified` | NF | NF | NF | D:`not_specified` | D:A=2:4 |
| FP16→FP16 | D:FP16 | D:FP16 | D:FP16 | NF | NF | D:FP16 | D:`not_specified` | NF | NF | NF | D:`not_specified` | D:A=2:4 |
| BF16→FP32 | D:BF16 | D:BF16 | D:FP32 | NF | NF | D:FP32 | D:`not_specified` | NF | NF | NF | D:`not_specified` | D:A=2:4 |
| TF32→FP32 | D:TF32 | D:TF32 | D:FP32 | NF | NF | D:FP32 | D:`not_specified` | NF | NF | NF | D:`not_specified` | D:A=1:2 |
| FP64→FP64 | D:FP64 | D:FP64 | D:FP64 | NF | NF | D:FP64 | D:`rne/rtz/rtn/rtp`，按 modifier 分条件 | NF | NF | NF | NF | NF |
| INT8→INT32 | D:INT8 | D:INT8 | D:INT32 | NF | NF | D:INT32 | NA | NF | NF | C:`satfinite`→saturate；无 modifier→wrap | NA | D:A=2:4 |
| INT4→INT32 | D:INT4 | D:INT4 | D:INT32 | NF | NF | D:INT32 | NA | NF | NF | C:`satfinite`→saturate；无 modifier→wrap | NA | D:A pair-wise 4:8 |
| Binary→INT32 | D:binary | D:binary | D:INT32 | NF | NF | D:INT32 | NA | NF | NF | NF | NA | NF |
| GA100 FP16 dense | D:FP16 | D:FP16 | D:FP32 | NF | NF | NF | NF | NF | NF | NF | NF | D:dense |

定位：PTX70 dense `wmma/mma` pp.273-276、325-327；PTX72 sparse `mma.sp` pp.330-332、348-350；WP p.39/Table 3 与 p.20 SM/Tensor table。矩阵分布为 51 个 `D`、2 个 `C`、49 个 `NF`、6 个 `NA`。`not_specified` 是来源明确值；integer/logical rounding 与 subnormal 是结构不适用。所有 `NF` 都需按 path×field 保留检索结论，不能用一条家族级模板覆盖。

## 4. 存储、互联和数据搬运

| ID | 资料卡项 | 状态 | target 层级 | 可写内容或缺口 | 来源 / locator | 禁止误用的相邻主体 |
|---|---|---|---|---|---|---|
| M037 | register-file capacity | 可直接写值 | GA100 REG component，per SM | `256 KiB/SM`，图中为 `4×16,384×32-bit` | WP Figure 7 / Table 4 | A100 108-SM aggregate RF `27,648 KiB` |
| M038 | register-file instance count | 可直接写值 | GA100 REG component，per SM | `4` 个 processing-block RF instance/SM | WP Figure 7 | 不自动乘成共享容量或端口数 |
| M039 | combined L1/shared physical capacity | 可直接写值 | GA100 L1SMEM component，per SM | `192 KiB/SM` | WP Figure 7 / Table 4 | 不与 software-visible shared maximum 相加 |
| M040 | software-visible shared capacity | 仍 pending | CC8.0/A100 software-visible allocation | 白皮书 `164 KB/SM`，CUDA 修订又出现 160/163 KB per block；必须先固定版本和 per-SM/per-block 语义 | WP pp.36-37,43；CUDA-PG11 p.371；Tuning Guide 11.2.1 §1.4.3 | 192 KiB physical combined L1/shared |
| M041 | L2 capacity | 条件化写值 | A100 enabled implementation | `40 MiB` 只可作为 A100 108-SM product implementation 值 | WP Table 4 / p.35 | full GA100 L2 capacity未公开；不反推 128-SM 值 |
| M042 | L2 organization、coherence、pooling | 可直接写值 | GA100 L2 component / full GPU mode | logically shared、physically distributed；full-GPU hardware cache coherence；MIG 分区另加条件 | WP p.35；ISSCC p.1 | A100 `40×512 KiB` slice 组织、跨 GI coherence |
| M043 | Compute Data Compression | 条件化写值 | GA100 L2 component | compressible data/unstructured zeros；`up to` 4× DRAM R/W、4× L2 read、2× effective L2 capacity | WP pp.35,41；ISSCC p.1 | 不是 2:4 sparse MMA，也不能把上界当基础带宽/容量 |
| M044 | L1/shared transfers、ports、banks、granularity | not_found | GA100 L1SMEM component | 未找到 per-cycle R/W、端口数、bank 数或字段定义所需 transaction granularity | WP/ISSCC/CUDA-PG11/PTX70/72/HPEC-v1 | `cp.async` 4/8/16-byte operation size、A100 L2 5120 B/clk、random workload 128-byte request |
| M045 | on-die L1/L2/shared latency | 条件化写值 | GA100 on-die component，A100 carrier measurement | L2 约 200 cycles；L1 33 cycles；shared load/store 23/19 cycles；逐 operator、dependency、working-set、SASS mapping 保留 | HPEC-v1 Table IV | 不是 workload latency；不换算为秒；global memory 290 cycles 越过外部 HBM，拒绝 |
| M046 | virtual-memory responsibility at L2 | not_found | GA100 L2 component | 文档有 address space/peer fault，但未证明 L2 的 VM responsibility、page size 或 migration | WP pp.34,52-54；CUDA-PG11；PTX | CUDA Unified Memory 软件行为 |
| M047 | PCIe interface | 可直接写值 | GA100 link | `PCI Express 4.0 x16` host interface | WP p.20 Figure 6 | card connector/form factor |
| M048 | PCIe bandwidth 与 SR-IOV | 条件化写值 | A100 product/interface mode | `31.5 GB/s per direction` 与 SR-IOV 只在 A100 产品语境写入 | WP A100 interconnect/virtualization sections | 不写成 `63 GB/s per direction`；SR-IOV 不等于 MIG GI |
| M049 | NVLink interface/link count | 可直接写值 | GA100 NVLink link | `12` physical interfaces；12 enabled 时为 12 logical links/device | WP p.20 Figure 6、p.52；ISSCC pp.1-2 | DGX/NVSwitch topology |
| M050 | NVLink lane 与 per-link rate | 可直接写值 | NVLink3 logical link | 4 differential pairs per direction；每 pair 50 Gbit/s；派生 `200 Gbit/s/link/direction = 25 GB/s/link/direction` | WP p.52 | 50 Gbit/s 不是完整 link rate；方向不可省 |
| M051 | NVLink injection bandwidth | 可直接写值 | GA100 device，12 links enabled | `300 GB/s per direction per device` | WP p.52；ISSCC p.1 | 系统总量或双向相加值 |
| M052 | NVLink aggregate bandwidth | 可直接写值 | GA100 device，12 links enabled | `600 GB/s bidirectional aggregate` | WP pp.20,52；ISSCC | 不是单向注入，也不是 DGX bisection bandwidth |
| M053 | NVLink remote-memory 与 fault behavior | 条件化写值 | NVLink3/A100 software-visible path | peer memory、non-posted writes、page-fault return；link error detection/packet replay | WP p.52；ISSCC PHY/RAS sections | 不扩成跨 GPU cache coherence、透明迁移或零故障语义 |
| M054 | NVLink absolute latency | not_found | GA100 NVLink link | 仅有 `low-latency` 和省去 FEC round-trip 的相对表述，无绝对单跳/端到端值 | WP p.52；ISSCC | 不把 `tens of ns` 的节省量当链路延迟 |
| M055 | topology、bisection、degree、hops、max scale、oversubscription | not_found | GA100 die/link factor | 裸片资料未给一个可归属到 die 的系统拓扑闭合值 | WP p.52；ISSCC Figure 3.2.6 | DGX A100、NVSwitch、可能配置 |
| M056 | network collective offload | not_found | GA100 die factor | NVLink 是 transport；未找到 die 内 NCCL/collective engine | WP/ISSCC/CUDA-PG11/PTX70/72 | NCCL 软件、single-warp `redux.sync` |

## 5. 专用机制、软件、虚拟化和 RAS

| ID | 资料卡项 | 状态 | target 层级 | 可写内容或缺口 | 来源 / locator | 禁止误用的相邻主体 |
|---|---|---|---|---|---|---|
| M057 | structured sparsity | 可直接写值 | Ampere Tensor capability/path | 2:4/format-dependent sparse MMA；metadata 选择与已剪枝 A 对应的 B 元素；有效 2× 不等于物理 MAC 数翻倍 | WP pp.39-40 / Table 3；PTX72 `mma.sp` | 不写成硬件自动发现非零、任意 N:M 或 unstructured sparsity |
| M058 | async copy | 可直接写值 | Ampere async-copy component | `cp.async` 为 global→shared non-blocking thread instruction，可绕过中间 RF，支持 4/8/16 byte | PTX70 pp.201-204；CUDA-PG11 pp.215,217 | 不是独立 DMA engine；无 engine count、queue depth、BW/latency |
| M059 | split arrive/wait barrier | 可直接写值 | Ampere SM control | `mbarrier` 为 CTA/shared-memory scope 的 arrive/wait 同步机制 | PTX70 pp.249-250；CUDA-PG11 | 不是跨 GPU barrier、job scheduler 或 checkpoint |
| M060 | warp reduction | 可直接写值 | Ampere warp-reduce capability | single-warp 32-bit add/min/max 与 and/or/xor，implementation level=`dedicated_instruction` | CUDA-PG11 p.191；PTX70 pp.248-249 | 不是 Softmax、Top-k、CTA reduction 或 network collective |
| M061 | Optical Flow Accelerator | 可直接写值 | GA100 OFA component | GA100 图中直接命名 OFA，可写硬件模块存在 | WP Figure 6 / p.20 | 不从名称推 throughput、格式或训练用途 |
| M062 | OFA throughput | not_found | GA100 OFA component | 未找到对象级吞吐和完整条件 | WP | A100 SDK/product benchmark |
| M063 | video decode / media engine | 条件化写值 | GA100 component；A100 product count 分开 | 可写 GA100 有 video decode component；A100 的 NVDEC/NVJPG 数量与格式只作产品条件 | WP Figure 6 与 A100 media sections | `5×NVDEC/5×NVJPG` 不无条件下放 full die；不由缺失推 NVENC/RT/display 物理不存在 |
| M064 | Attention-bound data movement | not_found | GA100 die factor | 未找到 Attention 专用 buffer/data mover | WP/ISSCC/CUDA-PG11/PTX70/72 | `cp.async` 通用搬运不等于 Attention engine |
| M065 | Softmax | not_found | GA100 die factor | 未找到 exponent、normalization、floating reduction chain 的专用实现 | 同上 | warp reduction |
| M066 | Top-k / ranking | not_found | GA100 die factor | 未找到 ranking/index selection 专用实现 | 同上 | min/max reduction 与架构 placeholder |
| M067 | MoE routing / dispatch | not_found | GA100 die factor | 未找到 expert routing table、token route/dispatch queue | 同上 | CUDA Graph dependency、NVLink transport |
| M068 | KV Cache management | not_found | GA100 die factor | 未找到 KV-specific allocation、placement、eviction 或 migration manager | 同上 | L2 residency、MIG partition、Unified Memory |
| M069 | dedicated quantize/dequantize | not_found | GA100 die factor | 低精度执行和 datatype conversion 未证明专用量化/反量化 engine | PTX70/72；CUDA-PG11；TensorRT docs | TensorRT calibration/QDQ 是软件工具 |
| M070 | transpose/permute | not_found | GA100 die factor | 未找到专用 transpose/permute module 或指令 | WP/ISSCC/CUDA-PG11/PTX70/72 | shared-memory tile copy |
| M071 | compiler | 可直接写值 | Ampere architecture software | `nvcc`, CUDA Toolkit 11.0.3，生成 PTX/cubin 并面向 `sm_80` | CUDA-PG11 pp.33-35；PTX70 p.398 | 不是 GA100 裸片自带 compiler |
| M072 | runtime 与 custom-kernel interface | 可直接写值 | Ampere architecture software | CUDA Runtime (`cudart`) 11.0.3；CUDA C++ `__global__` 与 launch syntax | CUDA-PG11 pp.33-41 | 不把链接形态拆成多个 runtime；不等于 framework custom op |
| M073 | framework support | 条件化写值 | A100/CC8.0 software stack | NVIDIA PyTorch 20.06/20.07、TensorFlow 20.07，绑定 CUDA 11 与对应组件版本；maturity=`documented_supported` | PyTorch/TensorFlow release notes 20.06/20.07 | 未运行；20.06 TensorFlow NCCL 2.7.5 已知问题不得省略 |
| M074 | communication library | 条件化写值 | A100/CC8.0 software stack | NCCL 2.7.6，CUDA 11.0；可写 multi-GPU collective library 与已知限制 | NCCL 2.7.6 release notes；20.07 containers | `optimized for NVLink` 不等于 GA100 硬件 collective offload或任意拓扑闭合 |
| M075 | operator libraries | 条件化写值 | A100/CC8.0 software stack | cuBLAS 11.1.0.229、cuDNN 8.0.1、TensorRT 7.1.3 CUDA11/A100 Preview、cuSPARSELt 0.0.1，逐条保留范围 | CUDA 11 release notes；cuDNN/TensorRT/cuSPARSELt docs | 库存在不等于所有 datatype/operator/shape 都支持 |
| M076 | dynamic shape | 条件化写值 | TensorRT 8.6.1 / CC8.0 | runtime dimension、optimization profile、shape tensor及限制；7.1.3 只作 A100 Preview 首发背景 | TensorRT 8.6.1 Developer Guide/Support Matrix/Release Notes | 不泛化为任意 PyTorch/TensorFlow graph 动态 shape |
| M077 | quantization tool | 条件化写值 | TensorRT 8.6.1 / CC8.0 | INT8 calibration、Q/DQ explicit quantization；dynamic shape 需 calibration profile；7.1.3 仅 symmetric per-tensor 且 Preview | TensorRT 8.6.1 docs；7.1.3 release notes | INT8 Tensor Core、PTX low precision、cuSPARSELt pruning 都不是量化工具 |
| M078 | MIG partition mechanism | 条件化写值 | supported GA100 product implementation，MIG mode | GI 可分割 SM、crossbar、L2、memory controller/DRAM path并提供 QoS/fault isolation；CI dedicated SM、共享 parent GI memory/engines | MIG610 concepts/profiles/supported products；WP p.52 | A100 `up to 7`、A30 `up to 4`、profile geometry/capacity不是裸片常量 |
| M079 | MIG lifecycle/control plane | 条件化写值 | MIG software/control plane | MIG mode reset/admin条件；mode bit可跨 reboot，geometry不持久；GI/CI 在 idle 时 create/destroy；监控保留版本条件 | MIG610 getting-started/deployment | 不是 state-preserving resize、live migration 或硬件 checkpoint |
| M080 | raw MIG migration/checkpoint/preemption | not_found | GA100/MIG factor | MIG 固定章节未给 raw GI migration、checkpoint/save-restore 或 raw hardware preemption | MIG610；WP p.52 | A100 vGPU Live Migration、Suspend-Resume、time-sliced preemption |
| M081 | on-die ECC 与 NVLink replay | 条件化写值 | supported A100/GA100 implementation | on-die L2/L1/all-SM RF 的 SECDED；NVLink detection/replay，分 component 写 | WP p.35,p.52；RAS-PDF | external HBM ECC；不能合成“whole-chip protected” |
| M082 | containment、DPO 与 row remapping | 条件化写值 | GA100-aware driver/HBM/service flow | contained UCE、dynamic page offlining、row remapping；保留 framebuffer、driver、service-window reset 与外部 HBM 条件 | RAS-PDF supported-GPU / DPO / row-remap sections | 不写成纯 die 电路或零停机自动修复；Blackwell-only channel/L2 repair |
| M083 | telemetry 与 Field Diagnostics | 条件化写值 | product/software diagnostic flow | XID、NVML、`nvidia-smi`、SMBPBI、InfoROM、Field Diagnostics 可按各自层级写入 | RAS-PDF telemetry/diagnostics sections | 不等于公开 BIST 结构 |
| M084 | BIST structure | not_found | GA100 die factor | 未找到 GA100 具体 BIST block、coverage 或 test path | RAS-PDF；WP；ISSCC | telemetry 与离线 Field Diagnostics |
| M085 | general checkpoint/restart | not_found | GA100 die / raw job state | 未找到 general die/job checkpoint-restart 机制 | MIG610；vGPU docs negative boundary | A100 vGPU suspend/resume 是产品/软件条件 |

## 6. benchmark、价格和派生项

| ID | 资料卡项 | 状态 | target 层级 | 可写内容或缺口 | 来源 / locator | 禁止误用的相邻主体 |
|---|---|---|---|---|---|---|
| M086 | workload latency | not_found | GA100 die | 未找到 full 128-SM GA100 workload latency | HPEC-v1 Tables II/IV/V；Matrix；MLC-36d324b5 SingleStream | component cycle 与 DGX/A100 system `1,551,870 ns` |
| M087 | workload throughput | not_found | GA100 die | 未找到 full GA100 workload throughput | HPEC-v1 Table III；RAND-v1；Matrix；MLC Offline | HPEC 异常 `GB/s`、A100 random access、DGX BERT `3560.73 samples/s` |
| M088 | measured workload power | not_found | GA100 die | TDP 不是 workload power；选定 MLCommons x1 目录没有 power child | WP/WEB001-005；HPEC/RAND/Matrix；MLC directory endpoints | 250/300/400 W card TDP；system-at-wall power |
| M089 | energy per token | not_found | GA100 die | 无同 scope token 计数、模型阶段与 die-only energy measurement | 同上 | J/sample、TDP、后世 LLM metric definition |
| M090 | tokens per joule | not_found | GA100 die | 无直接 token/J，也无可合法组合的同 scope输入 | 同上 | 不从缺失量取倒数 |
| M091 | benchmark utilization | not_found | GA100 die | 未找到项目定义的 MFU/HFU/MBU/scaling-efficiency full-workload 值 | WP p.38；HPEC；RAND；Matrix；MLC | strong-scaling objective、`Measured-theoretical`、`full-speed`、GEMM peak-math utilization |
| M092 | published price | not_found | GA100 die | 未找到 standalone GA100 die MSRP/list price | WP/ISSCC/WEB001-005 的 price/MSRP/list-price 检索 | DGX A100 `$199,000`、A100 card/cloud/reseller 价格；禁止除以设备数 |
| M093 | capacity/compute | not_found | GA100 die derived field | full GA100 无同对象 external-memory capacity和precision-specific peak | WP p.19/Table 4；ISSCC | A100 40/80 GB 与 full 128-SM compute 混算 |
| M094 | specified compute/bandwidth | not_found | GA100 die derived field | 缺同对象 full-design peak、clock 与 nameplate bandwidth输入链 | WP/ISSCC/HPEC/RAND | 108-SM A100 clock/HBM BW |
| M095 | sustained compute/bandwidth | not_found | GA100 die derived field | 无 same-object sustained bandwidth；compression upper bound不是基础输入 | 同上 | A100 random-access GB/s |
| M096 | interconnect/compute 与 movement/matrix | not_found | GA100 die derived fields | NVLink侧可闭合，但 full-design compute、同scope movement/matrix throughput仍缺 | WP Figures 14/15、p.52；HPEC Tables III-IV | 用 access-count示意、cycle latency或异常单位吞吐拼比值 |

## 7. 训练/推理相关但公开资料没有闭合的内容

资料卡应保留这些空白的具体边界，不能把空白改写成“支持”。当前没有公开到可写值的内容包括：Attention 专用搬运、Softmax、Top-k、MoE routing/dispatch、KV Cache 管理、die 内专用 quantize/dequantize、transpose/permute 和 network collective offload；它们已分别在 M064-M070、M056 闭合为 `not_found`。同样未公开的还有 Tensor Core 物理阵列、product/internal accumulator、selector RTL 与 metadata SRAM、`cp.async` engine 数和 queue 深度、L1/RF 端口与每周期传输、full-design L2 容量、full-design clock/power/aggregate peak，以及可直接归属 GA100 die 的六项 workload benchmark。训练或推理“可能需要”这些机制，不构成 GA100“已经实现”的证据。

## 8. 卡片作者最容易犯的十个高风险越界

1. 把 full GA100 的 `128 SM / 8192 FP32 / 512 Tensor Core / 12 controller` 与 A100 启用值 `108 / 6912 / 432 / 10` 混成冲突，或取其一替换另一主体。
2. 把 A100 的 40/80 GB、5 active HBM stacks、5120-bit interface、时钟和 250/300/400 W 写成 GA100 裸片事实；full design 只能由 `12×512` 派生 6144-bit on-die interface。
3. 把 PTX/WMMA 的 instruction tile 当物理 Tensor array，把 virtual ISA 的 operand/accumulator contract 当内部 RTL 位宽或 native execution proof。
4. 把 sparse Tensor Core 的“有效 2×”当物理 MAC 数翻倍，或把 2:4 metadata selector写成硬件自动寻找非零；INT4 的 4:8 还必须保留 pair-wise 语义。
5. 把 Compute Data Compression 与 2:4 structured sparsity 合并，或把 `up to 4×/2×` 上界写成所有 workload 的基础 L2/HBM 带宽和容量。
6. 把 `cp.async` 写成独立 DMA engine，把 `mbarrier` 写成跨 GPU/job 同步，把 single-warp `redux.sync` 写成 Softmax、Top-k 或 network collective offload。
7. 把 NVLink `50 Gbit/s` signal pair 当完整 link rate，省略方向后混用 25 GB/s/link/direction、300 GB/s/device/direction 与 600 GB/s bidirectional；再把 DGX/NVSwitch topology下放到 die。
8. 把 A100/MLCommons/HPEC 数值变成 GA100 workload benchmark：component cycle不是 workload latency，TDP不是 measured power，samples/s不是 token/s，任何缺失能量项都不能用 TDP倒算。
9. 把 MIG、SR-IOV、vGPU 混成同一虚拟化机制：GI不等于 VF；vGPU live migration/suspend/preemption不证明 raw MIG 或 GA100 die checkpoint；A100 up-to-7 也不是 full GA100无条件上限。
10. 把软件和服务状态下放到硬件：CUDA/TensorRT/NCCL 的 `documented_supported` 不等于裸片自带能力，A100 vGPU fully supported不等于 GA100 die在售，SEC对 A100 IC 的限制也不能借 identity bridge变成 GA100 market-access值。

## 9. 计数、交付边界和剩余风险

本矩阵共有 204 个验收项：主矩阵 M001-M096 共 96 项，precision path 9×12 共 108 个 cell。状态分布为：可直接写值 86 项、条件化写值 20 项、`not_found` 88 项、`not_applicable` 7 项、仍 `pending` 3 项。这里的“可写”只表示内容验收通过；GA100 对象、组件、来源 endpoint、逐项 assertion/search result、selection、reverse removal 和正式发布仍须由后续工作完成。

本轮没有生成正式 CSV，没有修改资料卡模板、字段字典、validator、进度或既有 staging，也没有等待或声称通过 Windows hard gate。仍 pending 的三项是：release-date 的全库语义、HBM-stack exact pair 的 structural N/A predicate，以及 L1/shared software-visible capacity 的 164/160/163 KB 版本与 per-SM/per-block 差异。除此之外，所有 `not_found` 都必须在正式实现时拆成 exact target×field 的逐 endpoint 记录，不能把本报告的一行摘要直接复制成一个家族级模板结果。
