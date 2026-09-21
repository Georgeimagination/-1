# GA100 v3 benchmark 与独立微基准来源级补证

## 任务状态与写入边界

状态：`completed_read_only`

本轮逐页核验两份本地 PDF，并回查 `r1_ga100_14_atomic_staging_v2/` 中 benchmark、memory、compute 的 requirement、search 与 result。正式表、v2/v3 staging、合同、资料卡、进度文件和来源 PDF 均未修改。本轮唯一项目写入是本报告。

本报告处理的主体仍是 `OBJ-NVIDIA-GA100-DIE`。A100 SXM4、A100 product family、高带宽内存（HBM）封装路径和具体软件环境只作为测试条件或对象边界，不自动下放为 full GA100 裸片事实。

## 两份来源及实际入口

| source_id | 内容版本与身份 | 本轮实际 endpoint | 本地文件与固定校验 | 版本边界 |
|---|---|---|---|---|
| `SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022` | `arXiv:2208.11174v1`，2022-08-23，8 页 | `END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`；相关在线入口为 `END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-ARXIV`，`https://arxiv.org/pdf/2208.11174` | `论文/NVIDIA_GPU/02_独立逆向与微基准/2022_Demystifying_NVIDIA_Ampere_Architecture.pdf`；SHA-256 `86013d806532a281e7878415cc1a55aa426f8fbd8ae0e9dc02285882fbdd8227`；285169 bytes | 本地证据副本是 arXiv v1。论文与 HPEC 2022、DOI `10.1109/HPEC55821.2022.9926299` 的书目关系可以保留，但本轮没有 IEEE publisher PDF，不能声称 arXiv v1 与 IEEE 最终版逐页或逐字等同。source version 应明确写 arXiv v1，HPEC 发表身份放在 related-publication note，不把它写成已核实的 publisher version。 |
| `SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024` | `arXiv:2405.11425v1`，2024-05-19，6 页 | `END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`；相关在线入口为 `END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-ARXIV`，`https://arxiv.org/pdf/2405.11425` | `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_A100_Full_Speed_Random_Access_Memory.pdf`；SHA-256 `6ca888b92691f06de9d5d15b268f2e2c738c9f0ef44441e6fd785f65a113a8a9`；587055 bytes | 本地证据副本是 arXiv v1。当前 source row 没有声称会议或期刊最终版，本轮也没有发现可用于版本等同的 publisher endpoint。 |

两份 PDF 的页数、字节数和 SHA-256 与 v2 endpoint row 一致。后续 search result 必须绑定上述实际 local endpoint，并把页码、章节、表格、图或全文关键词写入 `checked_locator_or_scope`，不能继续使用 v2 的通用模板句。

## 来源级裁决

| 检查项 | Ampere microbenchmark | A100 random-access | 对 GA100 v3 的裁决 |
|---|---|---|---|
| workload benchmark latency | 没有完整模型或应用 workload 的秒级延迟。论文给 instruction 和 memory access 的 cycles | 没有 latency 数值 | 两源对 `FIELD-BENCH-LATENCY` 均为 `checked_no_support`。cycle 不能塞入 canonical unit 为 `s` 的 workload benchmark 字段。 |
| workload benchmark throughput | Table III 给 Tensor Core 数字，但原单位为 `GB/s`，对象和 operation-count rule 不完整 | 给 A100 SXM4-80GB random cache-line access 的 `GB/s` | 两源都不能给 `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` 赋值。前者因单位与对象冲突拒绝，后者只属于 A100 产品测试。 |
| measured power | 未测量 | 未测量 | `FIELD-BENCH-POWER` 无支持。论文提到他人 power/energy 工作或理论带宽不构成本来源实测。 |
| energy per token | 未测量 | 未测量 | `FIELD-BENCH-ENERGY-PER-TOKEN` 无支持；两篇都没有 token workload。 |
| tokens/J | 未测量 | 未测量 | `FIELD-BENCH-TOKENS-PER-JOULE` 无支持，不从缺失的功耗与吞吐倒算。 |
| utilization / scaling efficiency | 未报告模型 FLOP 利用率（MFU）、硬件 FLOP 利用率（HFU）、内存带宽利用率（MBU）或 scaling efficiency | “full-speed”是相对 128-byte random-access baseline 的描述，未报告利用率定义 | `FIELD-BENCH-UTILIZATION` 无支持。不能用 `measured/theoretical` 字样、约 1900 GB/s 理论带宽或图中平台值自行生成 ratio。 |
| L1/L2/shared latency | Table IV 给 L1 33 cycles、L2 200 cycles、shared load/store 23/19 cycles | 未测量 | 三项可作为 A100-conditioned GA100 on-die component 实测候选，原单位固定为 `cycle`。需要 cycle-compatible field 或合同允许保存 raw cycle 后才能形成正式 fact。 |
| global-memory latency | Table IV 给 290 cycles | 未测量 | 只作为 A100 product test path。路径包含 GA100、HBM、memory controller、产品启用配置和运行时，不能写成 full GA100 固有延迟。 |
| per-cycle transfer | 没有 byte/cycle；Table IV 是 latency cycle，Table III 是单位冲突的 compute throughput | 只有 GB/s，没有 clock 或 byte/cycle | `FIELD-MEM-READ-TRANSFER-PER-CYCLE` 与 `FIELD-MEM-WRITE-TRANSFER-PER-CYCLE` 均为 `checked_no_support`。禁止用 latency cycle、GB/s 或未披露时钟换算。 |
| random access | pointer chasing 用于串行 latency，不是全 HBM random-throughput workload | 核心结果是 SXM4-80GB 上的 random coalesced access、约 64 GB cliff 和 group-to-chunk 方法 | 只接收为 A100 产品测量和 GA100 相关 lead，不形成 full GA100 fact。 |
| instruction cycles | Table II、V 给 PTX（Parallel Thread Execution，NVIDIA 虚拟指令集）到 SASS（硬件相关汇编指令）的条件化周期结果 | 未覆盖 | 可作为 A100-conditioned GA100 execution-path 实测；保留 dependent/independent、初始化、SASS mapping、clock overhead 和软件版本缺失。不能升级成固定 RTL pipeline latency。 |
| WMMA tile 与 cycles | Table III 给 WMMA（warp matrix multiply-accumulate）PTX shape、SASS 展开和 4/8/16 cycles | 未覆盖 | 可作为 precision-path 的条件化 instruction tile/mapping 实测。8x4x8 physical implementation 来自二手引用，不能填物理阵列形状。 |
| compiler、driver、CUDA、clock | 实际 compiler、driver、CUDA、GPU frequency、锁频和 power mode 均未报告。参考文献中的 PTX ISA 7.7 与 CUDA guide 2022 不能当作测试环境 | compiler、driver、CUDA、clock、锁频、power mode、纠错码（ECC）/Multi-Instance GPU（MIG）状态均未报告 | 所有实测都必须显式保留这些缺口。缺失项不能由论文年份、参考文献版本或 A100 公版规格补齐。 |
| product configuration | 结果段原文写 `Nvidia Tesla AI100 GPU`，Table V 写 `Amepere A100`；容量、SXM/PCIe、启用 streaming multiprocessor（SM）数未给 | 明确 `SXM4-80GB GPU`；正文另述 A100 product 的 108-SM promised total | 前者只能解析为 A100 product family 且 SKU unresolved；后者只到 A100 SXM4-80GB product configuration。两者都不是 full GA100 128-SM 设计配置。 |

## Ampere microbenchmark 的可接收内容

### 测试对象和方法

PDF p.5 的 Section V lead-in 原文是 `We run all the microbenchmarks on the Nvidia Tesla AI100 GPU.`。`AI100` 必须保留在 raw text。结合标题、正文 A100 叙述以及 p.7 Table V 的 `Amepere A100`，可以把它裁为 A100 product family 的明显拼写歧义，不另建 `AI100` 对象；这一步只消除对象名歧义，不能恢复 A100 40GB/80GB、SXM/PCIe、实际启用 SM、board revision 或 serial。

PDF p.4 Section IV-A 使用单 thread per block，通过 `%clock` 或 `%clock64` 前后读数测 instruction cycle。作者至少重复 3 条指令以减小 first-launch overhead，并用 PPT-GPU tracing tool 动态检查 PTX 到 SASS 的实际展开；连续 clock reads 的开销测为 2 cycles。p.4 Section IV-B 对 global/L2/L1 使用 pointer chasing，以 `cv`、`cg`、`ca` cache operator 区分路径；shared memory 额外加入依赖指令避免 clock read 被提前。p.4 Section IV-C 的 WMMA 测试在循环内放 4 条独立 Tensor Core 指令，并扣除 2-cycle clock overhead。

这些方法信息足以解释测得的 cycle，但不能补齐测试环境。论文没有实际 compiler 版本、driver、CUDA toolkit、PTX JIT 路径、PPT-GPU commit、GPU clock domain、频率、锁频、温度、功耗模式、重复次数、方差或置信区间。作者写“4 TC instructions, 1 per TC”属于方法解释，不足以证明四条指令在物理上固定各占一个 Tensor Core。

### instruction cycle 与 concurrency

PDF p.5 Table II 给出 dependent/independent cycles per instruction（CPI）：`add.f16 3/2`、`add.u32 4/2`、`add.f64 5/4`、`mul.lo.u32 3/2`、`mad.rn.f32 4/2`。p.7 Table V 给出更完整的 PTX-SASS mapping 和 cycle，包括单点、范围、`0 or 6` 与 `changes`。初始化方式会改变 mapping，例如 `neg.f32` 可落到 `FADD` 或 `IMAD.MOV.U32`。正式记录必须逐 instruction、dependency、initialization 和 SASS result 拆分，不能把 Table V 压成一条无条件的 GA100 latency。

p.5 Section V-A 还报告两条 add 与两条 mad 总计约 4 cycles，并据此推断两类指令可在不同 pipeline 同时执行。该项应拆成 measured observation 与 author inference。它不能证明 `FIELD-COMP-CONCURRENCY` 所要求的 simultaneous peak，也不能替代白皮书对 FP32/INT32 并发的直接说明，因此只作 qualifier/lead，不作为该字段的唯一值。

### WMMA tile、SASS 展开和 Table III 单位冲突

PDF p.6 Table III 的可接收部分如下。原始 cycle 与 tile 均不得换算为秒或物理阵列形状。

| input -> accumulator | PTX supported shape | SASS mapping | 原始 cycles | 裁决 |
|---|---|---|---:|---|
| FP16 -> FP16 | `m16n16k16`、`m8n32k16`、`m32n8k16` | `2*HMMA.16816.F16`，每条 8 cycles | 16 | 条件化接收 instruction tile/mapping/cycle |
| FP16 -> FP32 | 同上 | `2*HMMA.16816.F32`，每条 8 cycles | 16 | 条件化接收 |
| BF16 -> FP32 | 同上 | `2*HMMA.16816.F32.BF16`，每条 8 cycles | 16 | 条件化接收 |
| TF32 -> FP32 | `m16n16k8` | `4*HMMA.1684.F32.TF32`，每条 4 cycles | 16 | 条件化接收 |
| FP64 -> FP64 | `m8n8k4` | `1*DMMA.884` | 16 | 条件化接收 |
| U8 -> U32 | `m16n16k16`、`m32n8k16`、`m8n32k16` | `2*IMMA.16816.U8.U8`，每条 4 cycles | 8 | 条件化接收 |
| U4 -> U32 | `m8n8k32` | `1*IMMA.8832.U4.U4` | 4 | 条件化接收 |

Table III 的 throughput 列标题是 `Measured-theoretical`，原始单位逐行写为 `GB/s`：FP16/BF16 约 `310-312 GB/s`、TF32 `132-156 GB/s`、FP64 `19-19.5 GB/s`、U8 `594-624 GB/s`、U4 `1229-1248 GB/s`。这些数字与 A100 公布的 312/156/19.5 TFLOPS 及 624/1248 TOPS 峰值重合，论文却没有给 operation-count rule、频率、启用 SM 数或从指令计数到 byte/s 的定义。本轮保留原单位和原文定位，裁为 `rejected_for_normalization`。不得静默改成 FLOP/s、OP/s 或 Tensor Core memory bandwidth，也不得用于 `FIELD-BENCH-THROUGHPUT`、`FIELD-MEM-BIDIR-BW` 或每周期传输字段。

论文 background 的 `Ampere ... 124 SM` 位于 PDF p.2 Section II。该值与 full GA100 的 128 SM 及 A100 产品的 108 enabled SM 都冲突，且没有测试对象或推导支持。裁决为 reject，不建立任何主体，不按“可能是笔误”改成 128 或 108。

### memory latency 与其他 memory field

PDF p.4 Sections IV-B、p.5 Section V-B、p.6 Table IV 给出：global memory 290 cycles、L2 200 cycles、L1 33 cycles、shared load/store 23/19 cycles。L1、L2 和 shared memory 位于 die 内，可在保留 A100 product、cache operator、pointer chasing、工作集相对 L2 大小、dependency 和未知软件/clock 条件后，作为 GA100 component 的第三方条件化测量。global value 跨越 HBM 和产品路径，只保留为 A100 product test path。

这些结果不提供 L1/shared bank 数、port 数、transaction size、cache-line size、read/write duplex model、L2 bidirectional bandwidth 或 byte/cycle。`ld.global.ca.u64`、`ld.global.cg.u64`、`ld.global.cv.u64` 和 shared `ld/st.u64` 是测试指令宽度，不等同硬件 transaction granularity 或每周期传输能力。

## A100 random-access 的可接收内容

### 对象和 benchmark 条件

PDF p.1 Section 1.1 明确测试设备为 `SXM4-80GB GPU`。同节描述 A100 product 为 8 个 graphics processing cluster（GPC）、每 GPC 8 个 texture processing cluster（TPC）、每 TPC 2 个 SM 的设计组织，随后说明产品只开放 7 个 GPC，每个开放 7 或 8 个 TPC，promised total 为 108 SM。这里的 108 是 A100 product enabled configuration 叙述，不是 full GA100 128-SM 设计，也不是对测试卡逐单元枚举的结果。

PDF p.1 Section 1.3 将 workload 限定为 warp-coalesced random access，每次 128 bytes，即 32 个 32-bit word。p.2 Section 2.1 的 Figure 1 比较 fully random 与 SM-to-chunk；p.5 Section 2.4 和 p.6 Figure 6 增加 group-to-chunk。论文没有公开 kernel source endpoint、iteration count、warm-up、重复次数、随机种子、误差条、统计量、memory allocation API、page size、compiler、driver、CUDA、GPU clock、锁频、power mode、ECC/MIG 状态或温度。

### throughput 与 64 GB cliff

Figure 1 和 Figure 6 的纵轴单位是 `GB/s`。128-byte coalesced access 在约 50-64 GB window 内的图示平台约为 `1240-1250 GB/s`，超过约 64 GB 后 fully random 与 SM-to-chunk 明显下降；这些是图读近似值，没有表格或 raw data，不能登记为高精度单点。Section 2.1 另以正文给出更大 transaction 的结果：32 个 64-bit word 约 `1400 GB/s`，32 个 128-bit word 约 `1600 GB/s`；作者同时写理论带宽约 `1900 GB/s`，并说明 sequential read 预计更高。

`full-speed` 在本文中的含义是 group-to-chunk 恢复到 128-byte random-access baseline，并不等于达到 1900 GB/s 理论峰值。不能由约 1250/1900、1400/1900 或 1600/1900 自行派生 MBU/utilization，因为论文没有固定同一 transaction、统计口径和测试条件，也没有把这些比值定义为利用率。

全部吞吐数值的主体是 A100 SXM4-80GB 产品路径，涉及 enabled GA100、80GB HBM、地址翻译、runtime 和访问映射。它们可用于未来 A100 product 条件卡或作为 GA100 die 卡的排除证据，不能填 full GA100 的 benchmark throughput、HBM bandwidth、sustained bandwidth 或 per-cycle transfer。

### 14 groups 与 TLB 推断

TLB 是 Translation Lookaside Buffer，即地址翻译缓存。PDF p.3 Section 2.2 通过双 SM probing 观察资源共享模式；p.4 Figure 3 重排 SM index 后得到 14 个 group，每组 6 或 8 SM。作者给出的解释是每个 GPC 的一半可能由某类 memory controller 服务。p.4 Figure 4 和 p.5 Figure 5 用单 group、双 group throughput 继续检查独立性，p.5 Conclusion 使用 `Apparently` 推断每个 SM group 有自己的 64GB TLB。

这条链是 A100 SXM4-80GB 上的 reverse-engineering inference。论文没有 page size、entry count、TLB level、controller identity、地址映射、实际物理 layout 或复现实验数据。14 group 不得改写为 14 memory controller、14 个 full-GA100 固有 group 或 TLB 数量。64 GB 是该 workload 下的 observable cliff/每 group 访问窗口推断，也不能当成精确 TLB reach 的直接硬件规格。来源级裁决为 `lead_only` 加 A100 product observation；对 GA100 component identity 不形成 accepted fact。

128-byte warp-coalesced access 是 workload request shape。论文没有证明它等于 L1/L2/HBM 的固定 transaction granularity，因此不能填 `FIELD-MEM-GRANULARITY`。SM pair/group 的 24-31 GB/s、约 90/120 GB/s 和 pair 约 2 倍关系也只属于 probing workload，不是 component port 或 per-cycle transfer。

## v3 requirement 与 search-result 补救建议

下表只给 v3 重建输入，不复用 v2 的 search/result PK 或 draft 状态。

| requirement / field | 实际检查入口与 locator | 结果关系 | v3 处理 |
|---|---|---|---|
| `REQ-R1-GA100-V2-BENCH-LATENCY` / `FIELD-BENCH-LATENCY` | Ampere arXiv-v1 local endpoint：pp.4-7，Sections IV-A/B/C、V-A/B/C、Tables II-IV；random-access local endpoint：pp.1-6，Sections 1-3，Figures 1-6 | 两源均 `checked_no_support` 于 GA100 workload benchmark target | Ampere cycle 另转 component/precision-path measurement；random paper 无 latency。完成其他计划来源后才可把 requirement 定为 `not_found`。 |
| `REQ-R1-GA100-V2-BENCH-THROUGHPUT` / `FIELD-BENCH-THROUGHPUT` | Ampere arXiv-v1 p.6 Table III；random pp.1-2 Sections 1.3/2.1、Figure 1，pp.5-6 Section 2.4/Figure 6 | 两源均 `checked_no_support` 于 full GA100 target | Ampere Table III 是单位/对象冲突；random 是 A100 product throughput。二者都要写明排除理由。 |
| `REQ-R1-GA100-BENCH-POWER` / `FIELD-BENCH-POWER` | 两份 local endpoint 全文；关键词 `power`、`W`、`watt`、`TDP` | `checked_no_support` | Ampere arXiv v1 的 power/energy 只在 related work/reference；random 无测量。不是 `not_public`。 |
| `REQ-R1-GA100-BENCH-ENERGY` / `FIELD-BENCH-ENERGY-PER-TOKEN` | 两份全文；关键词 `energy`、`joule`、`J/token`、`token` | `checked_no_support` | 两篇均非 token workload。完成计划来源后可作为 `not_found` closure 的逐源 result。 |
| `REQ-R1-GA100-BENCH-TPJ` / `FIELD-BENCH-TOKENS-PER-JOULE` | 同上 | `checked_no_support` | 不取倒数，不推导。 |
| `REQ-R1-GA100-BENCH-UTIL` / `FIELD-BENCH-UTILIZATION` | Ampere arXiv-v1 p.6 Table III 及全文；random pp.2/6 Figures 1/6 及全文；关键词 `utilization`、`MFU`、`HFU`、`MBU`、`efficiency`、`scaling` | `checked_no_support` | `full-speed`、`Measured-theoretical` 和 throughput ratio 都没有项目字段所需 metric definition。 |
| `REQ-R1-GA100-V2-MEM-LATENCY` / `FIELD-MEM-LATENCY` | Ampere arXiv-v1 p.4 Section IV-B、p.5 Section V-B、p.6 Table IV；random 全文 | Ampere source `candidate_found` 于 L2/L1/shared raw cycle，global 仅 A100 product；random `checked_no_support` | v3 先解决 canonical `s` 与 raw `cycle` 的合同冲突。不能换算。若不扩合同，保留为 source assertion/阅读证据，requirement 不得伪装闭合。 |
| `REQ-R1-GA100-V2-MEM-READ-TRANSFER-PER-CYCLE`、`REQ-R1-GA100-V2-MEM-WRITE-TRANSFER-PER-CYCLE` | Ampere arXiv-v1 Sections IV-B/V-B、Table IV；random Sections 1.3/2.1/2.4、Figures 1/6 | 两源 `checked_no_support` | Ampere cycle 是 latency；random 只有 GB/s 且无 clock。 |
| `REQ-R1-GA100-V2-MEM-BANKS`、`REQ-R1-GA100-V2-MEM-PORTS`、`REQ-R1-GA100-V2-MEM-READ-WRITE-MODEL`、`REQ-R1-GA100-V2-MEM-BIDIR-BW` | Ampere arXiv-v1 memory sections/Table IV；random Sections 2.1-2.4/Figures 1-6 | 两源 `checked_no_support` | 14 group、SM pair bandwidth 和 load/store instruction 都不能替代这些物理字段。 |
| `REQ-R1-GA100-V2-MEM-GRANULARITY` | random p.1 Section 1.3、p.2 Section 2.1；Ampere arXiv-v1 p.4 Section IV-B | 两源 `checked_no_support` | 128-byte request 与 `u64` load/store 是 benchmark access shape，不是公开 hardware transaction/cache-line contract。 |
| `REQ-R1-GA100-V2-COMP-INSTRUCTION-TILE` / `FIELD-COMP-INSTRUCTION-TILE` | Ampere arXiv-v1 p.4 Section IV-C、p.6 Table III、p.7 Table V | `candidate_found`，A100-conditioned | 按 precision path 拆 PTX shape、SASS mapping、cycle、layout 和 software unknown。FP16 的官方 16x8x16 value 仍由白皮书承担；本文保留第三方 mapping/measurement 与其他 datatype。 |
| `REQ-R1-GA100-V2-COMP-CONCURRENCY` | Ampere arXiv-v1 p.5 Section V-A item 1 | `candidate_found` 仅作 qualifier | measured 约 4 cycles 与 author pipeline inference 分开。白皮书已有更直接 FP32/INT32 concurrency，本文不承担不可替代正式值。 |
| `REQ-R1-GA100-V2-COMP-DATAFLOW-RESIDENCY` | Ampere arXiv-v1 p.6 Section V-C 的 MOVM/layout 观察；random 无相关内容 | `checked_no_support` 于 general residency policy | compiler/layout-dependent movement 观察只作 lead。 |
| `REQ-R1-GA100-V2-COMP-UTILIZATION-LIMIT` | Ampere arXiv-v1 p.4 Section IV-C 的单 instruction 测量不稳定；random 的 64GB throughput cliff | `checked_no_support` 于 Tensor component utilization limit | 前者是 microbenchmark method effect，后者是 A100 memory/TLB workload effect。 |
| `REQ-R1-GA100-V2-COMP-ARRAY-SHAPE` | Ampere arXiv-v1 p.6 Table III 下方引用 [21] 的 `8*4*8` | `checked_no_support` | 二手引用且对象语义不清；PTX/SASS tile 与物理 array shape 分开。 |

power、energy、token/J、utilization 的最终 `not_found` 只能在计划内相关来源全部完成后发布。本轮两源没有厂商“明确不公开”的陈述，因此不能使用 `not_public`。

## 最小来源集裁决

`SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022` 不应继续无条件停在 `lead_only`。v3 若接收任一 on-die cycle measurement 或 path-specific PTX-SASS/WMMA mapping，它应以 `independent_validation` 进入 selection run；移除该来源会失去白皮书、ISSCC、CUDA 与 PTX 文档没有提供的第三方测量。source-level 接收不等于立即写正式 fact：memory cycle 仍须先解决字段单位合同，instruction mapping 仍须绑定未知 toolchain 条件。

即使 v3 暂不接受 cycle fact，这份来源仍是 benchmark 与 memory gap 的计划内实查来源。合同设计已要求发布性 `not_found` 所依赖的 source 必须成为 selection member，并新增 `coverage_obligation_evidence` 角色。因此，只要 Ampere arXiv-v1 result 被用于关闭 benchmark、per-cycle transfer 或其他 field/factor 的 `not_found`，它仍须进入最小来源集，不能因为“没有 GA100 workload value”留在未选 lead。

`SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024` 不作为 accepted GA100 fact source；它的 1400/1600 GB/s、约 64GB cliff、14 groups 和 group-to-chunk 均停在 A100 product/lead 边界。该来源是 `FIELD-BENCH-THROUGHPUT`、memory granularity/per-cycle 的高相关独立测量候选，也是其他 benchmark gap 的计划内负面检查来源。若最终 GA100 requirement 发布为 `not_found`，删除这份来源会使“已检查最相关 A100 random-access measurement 并因主体/条件不匹配排除”的 closure 消失，所以它应以 `coverage_obligation_evidence` 进入 selection run。

旧六源只能作为 reverse-removal seed，不能预设为 v3 最终数量。在上述 accepted measurement 与 not_found obligation 被 manifest 采用的前提下，这两份来源都要进入 candidate selection；最终成员数须等全部 field/factor closure、endpoint binding 和反向移除完成后再计算。本报告不把当前候选数量写成最终八源，也不沿用 v2 的七源或 salvage map 的六源结论。

建议的 source-level screening 是：Ampere microbenchmark 为 `selected` candidate，角色至少 `independent_validation`，需要时再加 `coverage_obligation_evidence`；A100 random-access 为 `selected` candidate，仅承担 `coverage_obligation_evidence`，不赋予 GA100 fact 角色。若最终 policy 明确把某条逐源 result 标为非必要审计输入，相应来源才可在 reverse-removal 后降回 `lead_only`，不能预先决定。

## v3 写入前仍需解决的事项

第一，`FIELD-MEM-LATENCY` 的定义允许周期或时间，但当前 canonical unit 是 `s`。没有 clock domain 和频率时，Table IV 只能保留 raw `cycle`。v3 必须增加 cycle-compatible field/variant，或在合同中定义 raw-unit assertion 的发布方式；不能把 33、200、23/19 或 290 当秒，也不能用 A100 公版 boost clock 换算。

第二，instruction-level cycle 仍缺专用 field。`FIELD-COMP-INSTRUCTION-TILE` 可以接收 PTX/SASS shape 与 mapping，不宜混入全部 scalar latency。若项目决定不扩 field，Table II/V 的 cycle 只进入 source-reading assertion，不应借用 workload benchmark latency 或 utilization 字段。

第三，HPEC source row 的 version note 应区分“书目发表关系”和“内容版本等同”。当前固定证据是 arXiv v1；IEEE final PDF 未取得，不能把 peer-reviewed venue 身份用于覆盖本地预印本文字或表格风险。

第四，A100 random-access 没有 raw data、code endpoint 与完整软件配置。Figure 1/6 只能保留图读范围和趋势，正文 1400/1600 GB/s 也必须绑定 transaction width。任何产品对象若以后进入别的工作包，还需补 driver、CUDA、clock、ECC/MIG、统计方法和实际 SM inventory；本轮不扩对象范围。

## 验证与交接

两份 PDF 共 14 页已重新抽取文本并全部渲染。重点视觉复核了 HPEC p.1、p.6 Table III/Table IV、p.7 Table V，以及 random-access p.1、p.2 Figure 1、pp.3-5 Figures 2-5、p.6 Figure 6。Table III 的 `GB/s`、Table IV 的 `CPI (cycles)`、Table V 的 `Amepere A100`、正文 `AI100`、random-access 的 `SXM4-80GB`、108 SM、64GB、14 groups、1400/1600 GB/s 均按原文保留，没有静默改单位或对象。

本轮尚未创建 v3 fact、requirement、search result、selection role/member 或 operation。总控后续生成 v3 时，应把本报告的 endpoint、locator、原单位、对象层级和排除理由转成新合同 row，并在所有 gap 关闭后重跑 reverse-removal。

## 文本复核

`report-humanizer` 单文件机器扫描结果为 `No machine-detectable AI tells found`。人工逆向复读已从最小来源裁决、v3 search 补救、两份来源、对象边界和开头结论返回检查，并核对 Table III 单位、124/128/108 SM、AI100、arXiv/IEEE 版本、cycle/second、A100 product/full GA100 以及 accepted measurement/not_found obligation 的边界。没有发现需要继续修正的模板化表达；剩余风险来自 v3 字段合同和 selection closure 尚未实施。
