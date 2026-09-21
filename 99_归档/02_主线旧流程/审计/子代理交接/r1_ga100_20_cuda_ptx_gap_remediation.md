# GA100 v3：CUDA 11 与 PTX 7.x 缺口补证

> 输入：`r1_ga100_05_cuda_official_docs_reading.md`、`r1_ga100_14_atomic_staging_v2/`、`r1_ga100_15_atomic_v2_independent_review.md`、`r1_ga100_16_whitepaper_isscc_gap_remediation.md`  
> 固定来源：`SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`、`SRC-NVIDIA-PTX-ISA-7-0`、`SRC-NVIDIA-PTX-ISA-7-2`  
> 写入边界：本轮只新增这份 source-reading 审计报告，未改正式表、v2/v3 staging、合同、资料卡或进度

## 裁决

这组三份官方文档能直接补上三类缺口。软件侧，CUDA C++ Programming Guide 11.0.3 明确给出 `nvcc`、CUDA Runtime 的 `cudart` 实现和自定义 `__global__` kernel 接口，因此 compiler、runtime 和“自定义内核接口”可以有值；它没有给 framework/backend、NCCL、量化工具或 dynamic-shape 绑定，这些要求仍应留给对应的软件发布记录。计算与存储侧，`cp.async`、`mbarrier`、warp reduction、L2 persistence 和 CUDA Graph 都有可复查的 API/ISA 定义，但它们分别只是通用异步搬运、CTA/warp 同步、L2 访问策略和工作提交模型，不能改写成 DMA engine 数量、Tensor Core 内部驻留、KV Cache manager、Softmax/Top-k 单元或 GA100 die 的硬件调度器。

数值语义是本轮改动最大的部分。PTX 已经直接写出矩阵指令的 destination type、FP16/BF16/TF32 的 rounding 与 subnormal handling 为 `unspecified`、FP64 的默认 `.rn`，以及整数 `.satfinite` 与省略该 modifier 时的 wrap。v2 把这些格子统一写成 `not_found`，其中 output、若干 rounding/subnormal 和 INT8/INT4 saturation 应改为条件化 `value`；product 精确格式、physical accumulator、scaling mode/granularity 仍没有公开值。PTX 给的是 virtual ISA contract，不是 native SASS 或 RTL，不能从 `.ctype/.dtype` 反推出物理累加位宽，也不能把 `at least single precision` 归一成“FP32 product”。

CUDA 版本冲突可以结束。ISSCC 的 `CUDA 8.0` 与两份版本化官方文档不相容：PTX 7.2 的 release table 把 CUDA 8.0 对应到 PTX 5.0 和 `sm_60/61/62`，把 CUDA 11.0 对应到 PTX 7.0 和 `sm_80`；Programming Guide 又明确写出 CUDA 11 引入 split arrive/wait barrier，CUDA 11.0 引入 async-copy。v3 应保留 ISSCC 原 assertion 为 conflict，canonical mapping 使用 CUDA 11.0/11.0.3；“CUDA 8.0 是笔误或把 Compute Capability 8.0 写错”只能作为解释性猜测，不能入事实。

本轮没有发现厂商明确声称某项信息不公开，因而不建议新增 `not_public`。下文的 `not_found` 指实际检查了列明的固定章节后仍无值；`pending` 表示还存在职责明确的下一类来源，不能提前作为发布闭合。

## 固定来源、版本与同族关系

| source_id / 版本 | 固定入口与校验 | 本轮证据职责 |
|---|---|---|
| `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`；`PG-02829-001_v11.0`，CUDA Toolkit 11.0.3，2020-08 | `审计/子代理交接/r1_ga100_source_staging/downloads/cuda-c-programming-guide-11.0.pdf`；405 页；4,252,150 byte；SHA-256 `af4235e08e4ebb0f7651896db7ed05344f5e4ae6e9ce5da3cba3bc5ec6c69174`；官方归档端点 <https://docs.nvidia.com/cuda/archive/11.0/cuda-c-programming-guide/index.html> | CUDA 11 首发语境、compiler/runtime、kernel interface、L2 policy、CUDA Graph、WMMA API、CC8.0 scheduler 与 software-visible limits |
| `SRC-NVIDIA-PTX-ISA-7-0`；PTX ISA 7.0，CUDA Toolkit 11.0.3，2020-08 | `审计/子代理交接/r1_ga100_source_staging/downloads/ptx-isa-7.0.pdf`；414 页；4,107,461 byte；SHA-256 `a79f4e074eb8f03314025c690ec51fbb79231e35bde612a60d50f4f8ec31f924` | 同期 `sm_80` virtual ISA；`cp.async`、`mbarrier`、`redux.sync`、dense `mma/wmma` 的语义与版本锚点 |
| `SRC-NVIDIA-PTX-ISA-7-2`；PTX ISA 7.2，CUDA Toolkit 11.2.1，2021-02 | `审计/子代理交接/r1_ga100_source_staging/downloads/ptx-isa-7.2.pdf`；433 页；3,931,305 byte；SHA-256 `9a89c6817d1fd0d3b6357aaf71fbf3c29d08d9c4e12b5eaa6c851297b7d18b97`；官方归档端点 <https://docs.nvidia.com/cuda/archive/11.2.1/parallel-thread-execution/index.html> | `mma.sp` 的 datatype-dependent sparsity、PTX 7.1 引入记录、PTX/CUDA/driver/target 对照表 |

PTX 7.1 没有在 v2 注册 source_id，也没有固定本地快照。本轮核对的官方端点是 <https://docs.nvidia.com/cuda/archive/11.1.1/parallel-thread-execution/index.html>，文档标识为 PTX ISA 7.1；它只作 revision bridge。PTX 7.2 PDF p.416-417（印刷 p.402-403）已经直接记录 PTX 7.1 对应 CUDA 11.1、driver r455，并在 §12.2 写出 `.sp` modifier 与 `mbarrier` phase parity 的引入。因此不能为了“7.1 是首发版本”临时创造 source_id，也不能把 7.0、7.1、7.2 当三份独立来源。

Ampere Tuning Guide 11.0.3 和 11.2.1 的官方端点分别是 <https://docs.nvidia.com/cuda/archive/11.0/ampere-tuning-guide/index.html> 与 <https://docs.nvidia.com/cuda/archive/11.2.1/ampere-tuning-guide/index.html>。二者同样没有 v2 source_id。本轮只用它们核对 CC8.0/8.6 边界与版本修订，不把网页 revision 算成新的独立证据。若后续确有唯一字段职责，再注册一个固定 revision 和一个 source family；不要同时把 11.0 与 11.2 计作两份最小来源。

为避免长表反复写全名，下文 `PG11`、`PTX70`、`PTX72` 分别严格指 `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`、`SRC-NVIDIA-PTX-ISA-7-0`、`SRC-NVIDIA-PTX-ISA-7-2`，不是新的 source_id。

## 事实主体与投影边界

CUDA Programming Guide PDF p.370（印刷 p.352）以 §I.7 `Compute Capability 8.0` 描述 SM，并在 p.371（印刷 p.353）明确把它称为 NVIDIA Ampere GPU architecture。PTX 的 `sm_80` target 也只建立 CC8.0 virtual ISA contract。它们可以支持 `OBJ-NVIDIA-AMPERE-ARCH`、`COMP-M2NA-AMPERE-*` 和该架构下的 precision path；若句子仅写 `compute capability 8.x`，还要防止把 8.6 的差异带入 8.0。Ampere Tuning Guide 11.2.1 特别区分 8.0 与 8.6，正好说明“generic CC8.x”不是 GA100 的同义词。

当前合同只允许 `FIELD-ID-ARCH` 沿唯一 `implements_architecture` 关系作特殊投影。compiler、runtime、design objective、numerics、memory、scheduler 等其他字段若只由 Ampere/CC8.0 来源支持，必须落在 architecture/component/precision-path target，再由资料卡 reachability 展示；不能复制成 `OBJ-NVIDIA-GA100-DIE` 的 same-target fact。A100 的 164 KB shared-memory partition、MIG 限制或 software-visible product limit 也不能下放给 full GA100 die。此边界修正只约束 v3 写入，不回改 r16 历史报告。

PTX 还在 PDF p.16（印刷 p.2）自述其目标是跨 GPU 世代的 machine-independent ISA，并由编译器翻译到 native target instruction。公开 PTX 因而可以证明“程序可请求什么语义”，不能证明 native opcode 数量、pipeline stage、scoreboard、物理 MAC array、内部 accumulator width 或 RTL arbitration。

## CUDA 11 与 ISSCC `CUDA 8.0` 冲突

| 实际检查的 locator | 原文要点 | 裁决作用 |
|---|---|---|
| `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`，PDF p.2，`Changes from Version 10.2` | 11.0 新增 CC8.0、L2 access management、global-to-shared async copy、split arrive/wait barrier、warp reduce、TF32/BF16/FP64 Tensor Core 和 CUDA Graph update 文档 | 版本封面与改版表共同限定为 CUDA Toolkit 11.0.3 |
| 同源 PDF p.204（印刷 p.186），§B.23，关键词 `CUDA 11 introduces` | CUDA 11 引入 split arrive/wait barrier；CC8.0+ 有硬件加速 | 与 ISSCC 所述同一类 barrier，不是泛指旧版 `__syncthreads()` |
| 同源 PDF p.215、217（印刷 p.197、199），§B.24.1、§B.24.1.2，关键词 `experimental in CUDA 11.0`、`single instruction` | async-copy 在 CUDA 11.0 仍为 experimental；CC8.0+ 可成为无需中间 register 的单条指令 | 同时关闭版本与 launch-time maturity，不能写成“CUDA 8 已稳定支持” |
| `SRC-NVIDIA-PTX-ISA-7-0`，PDF p.398（印刷 p.384），release table / §12.1 | PTX 7.0 对应 CUDA 11.0、driver r445，并新增 `sm_80`、async copy、`mbarrier`、`redux.sync` | 建立 CUDA 11.0 - PTX 7.0 - `sm_80` 链 |
| `SRC-NVIDIA-PTX-ISA-7-2`，PDF p.416-417（印刷 p.402-403），release table / §12.2-12.3 | CUDA 8.0 对应 PTX 5.0 和 `sm_60/61/62`；CUDA 11.0 对应 PTX 7.0 和 `sm_80`；PTX 7.1 才引入 sparse `.sp` | 直接排除“CUDA 8.0 是 `sm_80` 首发软件”的解释 |

建议把 `REQ-M2NA-AVAIL-0021 / FIELD-SW-PROGRAMMING-MODEL` 维持为 `value`，raw value 写 CUDA C++ / PTX，条件写 CUDA Toolkit 11.0.3、PTX 7.0、`sm_80`。ISSCC assertion 继续保留原文、页码和 `conflicts`，不可静默删除，也不可降格成“最低版本”。

## 软件字段

这里的 `value` 对应正式 requirement 的 `value_available`。没有版本和 hardware/backend binding 的品牌名不算值。

| requirement / target | 建议状态 | 实际 source_id、locator 与检索词 | 命中或排除理由 |
|---|---|---|---|
| `REQ-R1-GA100-V2-SW-COMPILER`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-COMPILER` | `value` | `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`，PDF p.33-35（印刷 p.15-17），§3.1、§3.1.1-3.1.4，`nvcc`、`PTX code`、`cubin`、`-arch`、`-code`；`SRC-NVIDIA-PTX-ISA-7-0`，PDF p.398，`sm_80` | 建议值限定为 `nvcc compiler driver in CUDA Toolkit 11.0.3, targeting PTX/cubin for sm_80`。文档没有给内部 compiler build，也不能把 driver JIT 与 nvcc 合成一个版本。 |
| `REQ-R1-GA100-V2-SW-RUNTIME`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-RUNTIME` | `value` | Programming Guide PDF p.37-38（印刷 p.19-20），§3.2-3.2.1，`implemented in the cudart library`、`libcudart`、`primary context`；p.41 把 L2 policy 限定到 CUDA 11.0/CC8.0+ | 建议值 `CUDA Runtime (cudart), CUDA Toolkit 11.0.3`。`cudart.lib/libcudart.a/cudart.dll/libcudart.so` 是链接形态，不是四个 runtime。 |
| `REQ-R1-GA100-V2-SW-CUSTOM-OPERATOR`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-CUSTOM-OPERATOR` | `value`，但只到 custom kernel interface | Programming Guide PDF p.25（印刷 p.7），§2.1，`__global__` 与 `<<<...>>>`；p.33，§3，`define a kernel as a C++ function` | 字段定义允许“自定义算子或内核接口”。这里能证明 CUDA C++ custom kernel interface，不能证明 PyTorch/TensorFlow custom-op registration、graph lowering 或某个 framework ABI。 |
| `REQ-R1-GA100-AMPERE-SW-MATURITY`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-SUPPORT-MATURITY` | `value`，`documented_supported` | Programming Guide 封面与 p.2；p.204、215；PTX 7.0 p.16、398 | 固定、版本化的一手文档足以支持 `documented_supported`。async-copy 在 11.0 明写 experimental，应形成 feature-scoped 限定；没有安装运行、benchmark 或 framework test，不能升成 `runnable_verified`。 |
| `REQ-R1-GA100-V2-SW-CHIP-BOUND-SCHEDULING`；`OBJ-NVIDIA-GA100-DIE / FIELD-SW-CHIP-BOUND-SCHEDULING` | `pending` | Programming Guide PDF p.59-60（印刷 p.41-42），§3.2.6.6-3.2.6.6.1，`CUDA Graphs`、`Scheduling is left up to the CUDA system` | CUDA Graph 是 definition/instantiation/execution 的通用 work-submission model，文档把 scheduling 留给 CUDA system；没有 GA100-owned queue、job placement、graph engine 或硬件调度路径。r16 的 Sys Pipe 候选若要保留，必须回到直接命名的真实 target，不得由 Graph 补强后下放 die。 |
| `REQ-R1-GA100-V2-SW-FRAMEWORK`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-FRAMEWORK` | `pending` | 三份固定文档检索 `PyTorch`、`TensorFlow`、`MXNet`、`framework`；没有 framework version + backend + CC8.0/GA100 绑定 | PTX 与 CUDA Runtime 不是 framework。下一来源应是 framework release/support matrix 或 NVIDIA framework container manifest。 |
| `REQ-R1-GA100-V2-SW-COMMUNICATION-LIBRARY`；同一 architecture target | `pending` | Programming Guide 与 PTX 检索 `NCCL`、`communication library`；无版本化命中 | Warp/CTA reduction、NVLink transport、CUDA IPC 均不能替代 NCCL 名称、版本和 backend/interconnect 范围。 |
| `REQ-R1-GA100-V2-SW-OPERATOR-LIBRARY`；同一 architecture target | `pending` | Programming Guide PDF p.379（印刷 p.361），§J.4 仅举 `cuFFT`、`cuBLAS`；p.256 的 Cooperative Groups `reduce` 是 API primitive | 固定文档没有给 library version、支持对象和 backend。r16 的 cuSOLVER/A100 句子应留在它直接支持的 A100 product condition；不能投影成无条件 Ampere architecture fact。 |
| `REQ-R1-GA100-V2-SW-DYNAMIC-SHAPE`；同一 architecture target | `pending` | Programming Guide §2.1 的 grid/block launch 与 §3.2.6.6 CUDA Graph；检索 `dynamic shape` 无命中 | 动态 grid size 或 kernel 参数不是 framework/compiler dynamic-shape support。需要 shape specialization、recompilation/fallback 和 backend 版本来源后再裁决。 |
| `REQ-R1-GA100-V2-SW-QUANTIZATION-TOOL`；同一 architecture target | `pending` | 三份文档检索 `quantization tool`、`calibration`、`scale`、`zero point`；矩阵章节只给低精度执行格式 | INT8/INT4/Binary `mma` 支持不等于有量化/校准工具。下一来源应是 TensorRT/quantization toolkit 的版本化支持文档。 |

## 计算、同步与存储机制

### 可以直接使用的 architecture/CC8.0 locator

| target / field | 建议状态 | locator | 边界 |
|---|---|---|---|
| `PPATH-M2NA-AMPERE-TENSOR-FP16 / FIELD-COMP-INSTRUCTION-TILE` | `value` | `SRC-NVIDIA-PTX-ISA-7-0`，PDF p.325-327（印刷 p.311-313），§9.7.13.4.14 `mma`；FP16 shapes `.m8n8k4`、`.m16n8k8`、`.m16n8k16`；`SRC-NVIDIA-PTX-ISA-7-2`，PDF p.348-350，sparse FP16 shapes `.m16n8k16`、`.m16n8k32` | 应存成 opcode/format/稀疏条件下的 shape 集合，不能只留一个无条件 `16×8×16`，更不能把 instruction tile 当 physical array。 |
| `COMP-M2NA-AMPERE-TENSOR / FIELD-COMP-DATAFLOW-RESIDENCY` | `value`，只到 interface-level staging/residency | Programming Guide PDF p.41-42，§3.2.3-3.2.3.2，L2 set-aside/access-policy window；p.215、217、222、224-225，§B.24，global-to-shared async-copy、warp-shared pipeline、4/8/16-byte primitives；PTX 7.0 PDF p.201-202，§9.7.8.16.1 `cp.async` | 可记录 software-managed L2 persistence 与 global-to-shared staging；不能声称 Tensor Core operand 在内部哪个 buffer 驻留、回写路径、容量或持续带宽。若正式 target 保持 Tensor component，fact 文本必须明确是 feeding path，不是 Tensor datapath 内部。 |
| `COMP-M2NA-AMPERE-ASYNC-COPY / FIELD-MEM-DMA` | `value`，implementation level 为 instruction | PTX 7.0 PDF p.201-204，`cp.async.ca/cg.shared.global`、4/8/16 byte、`sm_80`；Programming Guide p.215、217 | 它是发起 global-to-shared non-blocking copy 的 thread instruction，可绕过中间 RF；不能注册为独立 DMA engine，也没有 engine count、queue depth、latency 或 bandwidth。 |
| `COMP-M2NA-AMPERE-SM / FIELD-COMP-CONTROL-SCHEDULING` | `value` | Programming Guide PDF p.370，§I.7.1：4 warp scheduler、static warp distribution、每个 issue time 从 ready warp 发一条 instruction；PTX 7.0 PDF p.23，§3.1 是 generic SIMT model | 只记录 CC8.0 software-visible scheduler organization。PTX 的 ready-warp 抽象不能证明 arbitration policy、scoreboard、dual issue 或 scheduler RTL。 |
| `CAP-R1-GA100-AMPERE-WARP-REDUCE / FIELD-CAP-*` | `value` | Programming Guide PDF p.191（印刷 p.173），§B.19，CC8.x+ `__reduce_sync`；p.256，Cooperative Groups reduce；PTX 7.0 PDF p.248-249，§9.7.12.10 `redux.sync` | 限定 single warp、32-bit signed/unsigned add/min/max 与 unsigned/b32 and/or/xor；`.add` 结果截断到 32 bit。它不是 Softmax、Top-k、CTA-wide reduction 或 network collective。 |
| Ampere/CC8.0 barrier mechanism | `value` | Programming Guide PDF p.204，§B.23；PTX 7.0 PDF p.249-250，§9.7.12.11，`mbarrier` 为 shared-memory opaque `.b64` object，8-byte alignment，CTA synchronization 与 async-copy completion | `mbarrier` 由 shared-memory 容量限制，不等于公开了硬件 barrier unit 的数量、状态 RAM 或调度 RTL。 |

### 仍不能由 CUDA/PTX 关闭的 compute requirement

| requirement | CUDA/PTX 建议 | 实际排除范围 |
|---|---|---|
| `REQ-R1-GA100-V2-COMP-CONCURRENCY`；`COMP-R1-GA100-SM` | `pending`，CUDA/PTX 不新增 exact-target value | Programming Guide p.353 的 `maximum resident grids` 和 p.370 的 warp scheduling 是 residency/scheduling limits，不证明 FP32、INT32、Tensor、LD/ST 等 subpath 能否同时达到峰值。r16 的 FP32+INT32 窄事实若直接由白皮书命名 GA100 SM，可单独保留；不能扩成所有单元 concurrency。 |
| `REQ-R1-GA100-V2-COMP-UTILIZATION-LIMIT`；`COMP-R1-GA100-TENSOR` | `pending`，除非 r16 的直接目标重新核对通过 | PTX 的 tile shapes、warp-uniform `.sync/.aligned` 要求和 Programming Guide p.222 的 warp entanglement 是 instruction/API constraint，没有给 GA100 Tensor 对小矩阵、窄矩阵、小 batch 或 irregular shape 的利用率。若只支撑 Ampere 架构约束，应落 architecture component。 |
| `REQ-R1-GA100-V2-COMP-ARRAY-SHAPE`；`COMP-R1-GA100-TENSOR` | 维持 `not_found` | PTX p.325 与 p.348 的 M×N×K 是 warp-level instruction semantics；register fragment mapping 也明确为分布式/opaque。三份文档都没有 physical MAC array rows/columns。 |

### Memory requirement 的状态

| requirement / target | 建议状态 | 实际检查的章节与理由 |
|---|---|---|
| Architecture-level L2 management；不新造 requirement_id | `value` | Programming Guide PDF p.41-46，§3.2.3-3.2.3.8：CUDA 11.0、CC8.0+ 可设置 L2 persisting set-aside 与 stream/Graph kernel-node access-policy window；`hitRatio` 是提示性分配。MIG 下 set-aside disabled，MPS 只能在 server startup 设上限。应落 Ampere/CC8.0 memory-management fact，不投影 GA100 die。 |
| `REQ-R1-GA100-V2-MEM-GRANULARITY`；`COMP-R1-GA100-L1SMEM` | `pending` | `cp.async` 的 4/8/16 byte 是 instruction copy size，不是 L1 cache line、transaction 或 bank-access granularity。Programming Guide §I.7.3 没给 CC8.0 bank count/line size；§I.3.3 和 §I.4.3 的 32-bank 描述分别属于 CC3.x 与 CC5.x，不能跨代搬用。 |
| `REQ-R1-GA100-V2-MEM-CONSISTENCY`；`COMP-R1-GA100-L2` | r16 若有 direct full-GPU value 可保留；CUDA/PTX 不扩大范围 | PTX 7.0 p.202 明写 `cp.async` 是 weak memory operation，只规定该 instruction 的 completion/order；它不披露 GA100 L2 coherence protocol、participant、atomics scope 或 MIG instance 间一致性。 |
| `REQ-R1-GA100-V2-MEM-POOLING-MODE`；`COMP-R1-GA100-L2` | r16 的 direct source 决定；CUDA/PTX 结果为 `pending` | L2 set-aside/access window 是逻辑访问策略，不证明 L2 slice 的物理分布、共享池组织或 MIG 分区后的 pooling mode。 |
| `REQ-R1-GA100-V2-MEM-USABLE-CAPACITY`；`COMP-R1-GA100-L1SMEM` | `pending`，不要由 architecture/A100 revision 下放 | Programming Guide 11.0 PDF p.371 写 CC8.0 `160 KB per block`、4 KB reserved；Ampere Tuning Guide 11.2.1 §1.4.3 写 A100/CC8.0 `163 KB per block`、1 KB reserved。它们是 software-version-visible limit 的修订，不是两种 GA100 物理配置。若采纳，应按 source revision 与 A100/CC8.0 target 建条件化事实，不能复制给 full GA100 die component。 |
| `REQ-R1-GA100-V2-MEM-VIRTUAL-MEMORY`；`COMP-R1-GA100-L2` | `pending` | Programming Guide runtime/context、L2 policy 与 PTX address spaces 没有给 page size、migration、oversubscription、remote-fault semantics，也没有把 virtual-memory 职责归给 L2。需 CUDA Driver/Unified Memory/MIG 专门文档。 |
| `REQ-R1-GA100-V2-MEM-COMPRESSION`；`COMP-R1-GA100-L2` | CUDA/PTX 无新结论；由 r16 白皮书/ISSCC direct target 裁决 | `cp.async.cg` 的 cache operator 与 L2 persistence 都不是 Compute Data Compression；不能用本轮文档给 compression 做第二来源。 |
| `REQ-R1-GA100-V2-MEM-LATENCY`、`MEM-READ-TRANSFER-PER-CYCLE`、`MEM-WRITE-TRANSFER-PER-CYCLE` | 维持 `pending` 或既有 `not_found`，取决于其他计划来源是否已查完 | 三份 fixed docs 没有 GA100 L2 latency、L1/shared per-cycle transfer 或相应 clock domain。`cp.async` copy size、L2 hit hint 和 scheduler issue rate 不能相乘派生带宽/延迟。 |

## 9×12 numerics 的逐格建议

矩阵只列 v2 仍有争议的九列；operand A/B 与 programmer-visible accumulation 已有值，不在本轮重复。`V(x)` 表示建议 `value` 并在括号中给 normalized/raw 值，`NF` 为 `not_found`，`NA` 为 `not_applicable`。每一行就是该 precision-path target，对应 requirement_id 仍沿用 v2 `REQ-R1-GA100-PATH-...-<FIELD>` 或既有 `REQ-M2NA-GAP-0059` 至 `0063`；本报告不创造新 ID。

| precision_path target | product | physical accum | output | rounding | scaling mode | scaling granularity | saturation | subnormal | sparsity |
|---|---|---|---|---|---|---|---|---|---|
| `PPATH-M2NA-AMPERE-TENSOR-FP16` | NF | NF | V(`FP32`) | V(`not_specified`) | NF | NF | NF；另有 WMMA `satf=true` API lead | V(`not_specified`) | 维持 V(`structured_sparse`, A 2:4) |
| `PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16` | NF | NF | V(`FP16`) | V(`not_specified`) | NF | NF | NF；另有 WMMA `satf=true` API lead | V(`not_specified`) | V(`structured_sparse`, A 2:4；PTX 7.1+/`sm_80`) |
| `PPATH-M2NA-AMPERE-TENSOR-BF16` | NF | NF | V(`FP32`) | V(`not_specified`) | NF | NF | NF；另有 WMMA `satf=true` API lead | V(`not_specified`) | 维持 V(`structured_sparse`, A 2:4) |
| `PPATH-M2NA-AMPERE-TENSOR-TF32` | NF | NF | 维持 V(`FP32`) | V(`not_specified`) | NF | NF | NF；另有 WMMA `satf=true` API lead | V(`not_specified`) | 维持 V(`structured_sparse`, A 1:2) |
| `PPATH-M2NA-AMPERE-TENSOR-FP64` | NF | NF | V(`FP64`) | V(default `rne`; raw options `.rz/.rm/.rp`) | NF | NF | NF | NF | 维持 NF |
| `PPATH-M2NA-AMPERE-TENSOR-INT8` | NF | NF | V(`INT32`/PTX `.s32`) | NA | NF | NF | V(`satfinite`→`saturate`; modifier absent→`wrap`) | 维持 NA | 维持 V(`structured_sparse`, A 2:4) |
| `PPATH-R1-GA100-AMPERE-TENSOR-INT4` | NF | NF | V(`INT32`/PTX `.s32`) | NA | NF | NF | V(`satfinite`→`saturate`; modifier absent→`wrap`) | 维持 NA | 维持 V(`structured_sparse`, A pair-wise 4:8) |
| `PPATH-R1-GA100-AMPERE-TENSOR-BINARY` | NF | NF | V(`INT32`/PTX `.s32`) | NA | NF | NF | NF | 维持 NA | 维持 NF |
| `PPATH-R1-GA100-TENSOR-FP16-DENSE` | 维持 NF | 维持 NF | 维持 NF | 维持 NF | 维持 NF | 维持 NF | 维持 NF | 维持 NF | 维持 V(`dense`) |

最后一行是 `COMP-R1-GA100-TENSOR` 下的 implementation-specific GA100 path。即使它的 label 是 FP16 input / FP32 accumulation，也不能把 Ampere PTX 的 D type、rounding 或 subnormal 直接复制过去；只有 `FIELD-ID-ARCH` 享有关系投影例外。若后续找到直接命名 GA100 implementation 的数值语义来源，再从 `not_found` 重开。

### product、physical accumulator 与 output

PTX 7.0 的 dense `wmma.mma` 在 PDF p.273-276（印刷 p.259-262），`mma` 在 p.325-327（印刷 p.311-313）；PTX 7.2 的 sparse `mma.sp` 在 PDF p.348-350（印刷 p.334-336）。三个真实 search scope 都检查了 `dtype`、`ctype`、`element-wise multiplication`、`at least single precision`、`specified precision`、`intermediate values` 与 `fragments`。

这些章节把 D、A、B、C 的 programmer-visible type 明确分开，因此 output 可按 exact instruction path 记录：FP16/BF16/TF32 的 FP32-accum path 为 `.f32` D，FP16-acc16 path 为 `.f16` D，FP64 为 `.f64` D，INT8/INT4/Binary 为 `.s32` D。`dtype` 不是 memory store format 的保证；如果字段还要表达最终 store/conversion，需另用 `wmma.store`/store instruction 条件，不能把 D register type写成无条件外部存储格式。

同一段落只说 FP16 element-wise multiplication 至少 single precision，BF16/TF32 使用 `specified precision`，FP64 operation precision 与 `.f64 fma` 相同。它们都没有给一个可规范化的独立 product encoding。Binary 路径直接说明 multiplication 被 XOR+POPC 逻辑序列替代，但仍没有公开中间 bit-vector/register 的规范格式。九条 `FIELD-NUM-PRODUCT` 因而保持 `not_found`。`.ctype/.dtype` 和 per-thread fragment 也只描述接口寄存器，九条 `FIELD-NUM-PHYSICAL-ACCUM` 全部保持 `not_found`。

### rounding 与 subnormal

PTX 7.0 PDF p.275 与 p.326、PTX 7.2 PDF p.349 原文都写 FP16 的 accumulation order、rounding、subnormal handling 为 `unspecified`；BF16/TF32 同样为 `unspecified`。项目枚举已存在 `rounding_mode=not_specified` 和 `subnormal_mode=not_specified`，所以这些是直接 `value`，不是搜索失败。不要把 `at least single precision` 推成 RNE，也不要把 TF32 输入 conversion 的独立 rounding 规则混到 matrix accumulation。

FP64 dense `mma/wmma` 在 PTX 7.0 p.274-275、325-326 直接写 default `.rn`，并支持 `.rz/.rm/.rp`。默认值可规范化为 `rne`；现有枚举没有 round-down/round-up，原始 modifier 必须留在 assertion/notes 或先补合同，不能丢掉后两项后声称只支持 RNE/RTZ。PTX p.117 的普通 `.f64 fma` 写支持 subnormal，但 matrix MMA 段只说 operation precision 与 FMA 相同，没有把 subnormal behavior 一并引用；按本轮禁止过推的边界，FP64 matrix `FIELD-NUM-SUBNORMAL` 仍为 `not_found`。

INT8、INT4 和 Binary 的 exact matrix operation 是 integer/logical to `.s32`，没有浮点舍入阶段，`FIELD-NUM-ROUNDING` 建议 `not_applicable`；这不等于对后续 quantize/dequantize conversion 做了判断。

### saturation、scaling 与 sparsity

PTX 7.0 p.275、326-327 与 PTX 7.2 p.348-349 对 INT8/INT4 直接给出两种 overflow behavior：有 `.satfinite` 时 clamp 到 signed 32-bit range，没有 modifier 时 wrap。应拆成两个 instruction-condition facts，不能只选 `saturate` 或 `wrap` 作为路径的无条件属性。Binary syntax 没有 `.satfinite`，相邻 integer 段的 wrap 句不能跨语法套用，故保持 `not_found`。

Programming Guide PDF p.199（印刷 p.181），§B.22.1 对 CUDA WMMA API 的 `satf=true` 明写 +Inf→+MAX_NORM、-Inf→-MAX_NORM、NaN→+0。PTX 7.0 PDF p.276 与 p.400 又写 floating `wmma.mma .satfinite` 自 PTX 6.5 移除。两者并不矛盾：前者是可由 compiler/library 实现的 high-level API option，后者是 PTX matrix opcode 的 modifier contract。当前 precision path 没有 `WMMA satf=true` 条件，故不把 API lead 填入硬件 saturation 格；若 v3 建立 operation/API condition，可新增一条条件化 software-visible behavior，不能覆盖 raw PTX path。

在 dense/sparse MMA 的实际语法范围内检索 `scale`、`scaling`、`block scale` 没有 scale operand、mode 或 granularity。这个“未出现在 ISA syntax”不能证明芯片或库没有 pre/post scaling，九条 scaling mode/granularity 维持 `not_found`。

PTX 7.2 PDF p.330-332（印刷 p.316-318），§9.7.13.5.1 明确给出 sparse A 的 datatype-dependent pattern：FP16/BF16 为 2:4，TF32 为 1:2，INT8 为 2:4，INT4 为 pair-wise 4:8。PDF p.348-350 的 `mma.sp` syntax 又允许 FP16 `.ctype/.dtype` 为 `.f16` 或 `.f32`，p.350 还给 FP16 C/D 为 `.f16` 的例子，因此 FP16-acc16 sparsity 由 `not_found` 改为 `value`。范围只到 matrix A、PTX 7.1+、`sm_80`；不能写成 A/B 双稀疏，也不能把 pair-wise INT4 4:8 简写成普通 element-wise 4:8。

## 候选 factor 与假 capability target

v2 的 `CAP-R1-GA100-GAP-*` 是 coverage placeholder，不是公开实体。v3 应删除这些 capability entity/requirement target；下面的状态只描述 card-scope mechanism search，不授权继续保留假 ID。

| card-scope factor | CUDA/PTX 结果 | 精确排除依据 |
|---|---|---|
| Attention data movement、KV Cache management | `not_found` | `cp.async` 的 source/destination 仅是 global→shared，L2 policy 仅是 persisting/streaming access hint；三份文档没有 Attention/KV-bound buffer、迁移、复制、页表或调度机制。 |
| MoE dispatch、MoE routing、Top-k | `not_found` | CUDA Graph 只表达 operation dependency；`redux.sync` 只给 warp reduction，没有 token/expert table、selection index、ranking 或 dispatch queue。 |
| Softmax | `not_found` | warp reduction 只支持整数 add/min/max 与逻辑 reduce；没有 exponent、normalization、floating reduction chain 或 Softmax unit。 |
| network collective offload | `not_found` | `redux.sync` 明确限制在 single warp，`mbarrier` 限制在 CTA/shared memory；都不是跨 GPU collective。此来源也没有 NCCL 或 NVLink collective engine。 |
| quantize / dequantize | `not_found` | low-precision `mma` 只证明 operand/accumulator format；没有 scale/zero-point、calibration 或 dedicated conversion pipeline。TF32 input conversion 也不是 INT8/INT4 quantizer。 |
| transpose / permute | `not_found` | matrix layout qualifier 与 global→shared copy 不等于专用 transpose/permute engine；三份文档没有相应 module/instruction 陈述。 |
| compression | CUDA/PTX 不新增；回到 r16 的真实 Ampere/L2 mechanism | `.cg/.ca` 是 cache hint，structured sparsity 是 sparse MMA，二者都不是 Compute Data Compression。placeholder 仍应删除。 |

`not_found` 只覆盖上述固定 CUDA/PTX 章节，并与 r16 的白皮书/ISSCC search 合并后形成 card-scope evidence。它不能反向证明 NVIDIA 硬件“不可能有”这些机制，也不能给不存在的 capability entity 填 `not_applicable` 后继续保留实体。

## 最小来源与 reverse removal

三份 fixed PDF 均为 NVIDIA first-party，publisher 相同；跨文档一致只能称 internal corroboration，不能增加独立来源计数。PTX 7.0/7.1/7.2 更是同一 source family 的 revision chain。

对本轮新增职责，最小集合建议保留 Programming Guide 11.0 与 PTX 7.2。前者不可移除，因为 compiler/runtime、CUDA Graph、L2 MIG/MPS 限制、WMMA `satf` 和 CUDA 11.0 experimental maturity 都没有被 PTX 覆盖；后者不可移除，因为它同时给完整 `mma.sp` datatype pattern、PTX 7.1 引入记录和 CUDA/PTX/driver/target 对照表。

PTX 7.0 是否留在最终最小集取决于是否保留“GA100 launch-time contemporaneous ISA”这项独立证据职责。PTX 7.2 §12.1-12.3 对 7.1/7.2 均写 `Semantic Changes and Clarifications: None`，并重述 7.0 新功能；若 v3 只存 instruction semantics 与版本映射，PTX 7.0 可经 reverse removal 标为同族冗余。若 v3 要保存 2020-08 同期文档直接证明 `sm_80/cp.async/mbarrier/redux.sync` 在 CUDA 11.0 首发时已经成文，则可以留两份 revision，但 selection reason 必须写成“launch contemporaneity”和“later sparse consolidation”两个不同职责，仍只计一个 family。

PTX 7.1 建议 reverse-remove：没有固定快照、没有注册 source_id，且 PTX 7.2 已完整覆盖它的 `.sp` 引入与版本表。Ampere Tuning Guide 11.0/11.2 同样先不进入最小集；它们目前只做 CC8.0/8.6 和 shared-memory limit revision cross-check，Programming Guide 与 PTX 已覆盖所有准备写入的本轮事实。

## 可复查 search scope 与核验

本轮没有沿用 v2 的整包模板句。软件实际检查 Programming Guide §2.1、§3.1-3.2、§3.2.3、§3.2.6.6、§B.19、§B.22-24、§C.6.3、§I.7 和 §J.4；PTX 实际检查 §1.3、§3.1、§9.7.8.16、§9.7.12.10-11、§9.7.13.3.5、§9.7.13.4.14、§9.7.13.5、release table 与 §12.1-12.3。关键词包括 `nvcc`、`cudart`、`framework`、`NCCL`、`dynamic shape`、`quantization tool`、`cp.async`、`mbarrier`、`redux.sync`、`L2 persistence`、`CUDA Graph`、`dtype`、`ctype`、`rounding`、`subnormal`、`satfinite`、`scale`、`mma.sp` 和各 datatype。

三份 PDF 的上述相关页均以 Poppler 渲染后视觉核对，文本提取只用于定位。视觉核对特别确认了 source/version 封面、表格列头、instruction syntax、modifier 可选性、`unspecified` 原句、sparse 图示/metadata 和 PDF 页码与印刷页码的偏移，未用 OCR 猜测代码符号。

本报告不创建 fact/assertion/requirement/source ID。v3 落盘时，应先执行 target-boundary 审核，再把数值矩阵的 `value` 拆成 exact opcode/format/software-version 条件；假 capability target 先删后做 card-scope closure。

`report-humanizer` 已对本文件单独扫描，结果为 `No machine-detectable AI tells found`。随后按候选 factor、最小来源、numerics、memory/compute、软件、CUDA 冲突、对象边界和来源注册的逆序人工复读，重点核对了 PTX page/printed-page 偏移、三个 source_id、9 条 precision path、同族来源计数与 architecture/GA100 target 边界。最终 SHA-256 在文件冻结后单独回报总控，避免把 hash 写回文件造成自引用变化。
