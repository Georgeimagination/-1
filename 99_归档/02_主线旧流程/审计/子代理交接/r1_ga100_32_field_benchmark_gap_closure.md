# GA100 field 与 benchmark 缺口定向闭合

## 裁决

本轮把 r28 点出的 15 个漏失 field、6 个 benchmark field，以及仍未收口的 die 状态、发布日期、可用日期和公开价格逐项重查。建议结果中没有 `pending`：5 项可写 `value`，1 项为结构性 `not_applicable`，其余 19 项为完成定向检索后的 `not_found`。这里的 `not_found` 表示在列明的来源族、实际 endpoint 和主体边界内没有可接受值，不表示数值为零，也不表示厂商明确宣称不公开。

来源内容本身已经足以作上述裁决。正式发布仍有三类实现前置：GA100 die 及其 component 还没有进入正式 reachability；v4 设计中的 instruction-latency field 与 memory-latency cycle 合同尚未迁移；除 Ampere whitepaper 外，本报告使用的 HPEC、CUDA Programming Guide 和 official-web v2 payload 还没有注册成正式 source/version/actual endpoint。它们都不是新的事实检索缺口。`ingestion_pending` 只能描述这类来源包生命周期，不能写进 requirement status。

本报告只增加本文件，没有修改 r25、正式 32 张数据表、合同设计、模板、validator、进度或任何 staging CSV。下文沿用 r14 已提出且 r28 复核过的 target ID，不创建新 ID。当前正式层只有 `OBJ-NVIDIA-AMPERE-ARCH` 及其 Ampere components；`OBJ-NVIDIA-GA100-DIE`、`COMP-R1-GA100-*` 和 GA100 relation 仍只是未来 chip transaction 的拟议 postimage。

## 检索边界与实际来源

为避免在逐 field 表里反复塞入长 URL，先固定本报告实际使用的来源简称。表中“正式”只表示已在当前 `source-endpoints.csv` 登记；“staging 已验收”表示 bytes、hash 和页面身份已由 r29 接受，但还不是正式 endpoint。

| 简称 | source family / version | 实际 endpoint 与本地状态 | 本轮使用的 locator |
|---|---|---|---|
| `WP` | `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，v1.0 | 正式 `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`，`论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`，SHA-256 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`；官方 URL `https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/nvidia-ampere-architecture-whitepaper.pdf` | PDF pp.8-14、18-20、35-42、52、57-64；特别是 p.19 full GA100/A100 implementation，pp.38-40 strong scaling/data sharing，Table 4 与 Figures 4、5、14、15 |
| `ISSCC` | `SRC-NVIDIA-A100-ISSCC-2021` | 本地固定 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf`，SHA-256 `55765d2680678ba46045da1902496ddd3995d5964a5f0ef68a99362e2c43b601`；尚无正式 endpoint row | PDF pp.1-3，Figure 3.2.2、3.2.4、3.2.7；对象始终按 A100 product/implementation 解读 |
| `BLOG` | NVIDIA Technical Blog，2020-05-14 | official-web v2 `R1GA100-WEB-001`，`https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/`；staging 已验收，SHA-256 `ced8cd095756924ef61121e83eb69f66ceeb100c6616f71ed8c2bb3cb1e76e52` | 页首日期；`Introducing the NVIDIA A100 Tensor Core GPU`；`Key features` 首段；GA100 powers A100 与 54.2B/826 mm² 句 |
| `NEWS` | NVIDIA Newsroom A100 launch，2020-05-14 | `R1GA100-WEB-002` HTML 与 `R1GA100-WEB-003` PDF，均为 staging 已验收；`https://nvidianews.nvidia.com/news/nvidias-new-ampere-data-center-gpu-in-full-production` | HTML 日期和首段；PDF p.1 的 A100 full-production/shipping 陈述。只作 A100 产品事件 |
| `PB` | NVIDIA A100 PCIe Product Brief，40 GB/80 GB | `R1GA100-WEB-004` `PB-10137-001_v03`、`R1GA100-WEB-005` `PB-10577-001_v03`；staging 已验收 | 两份 PDF viewer pp.5、7（document pp.1、3），A100 card based on GA100 与 GPU SKU；价格关键词全文检查 |
| `CUDA-PG` | `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`，`PG-02829-001_v11.0`，Toolkit 11.0.3 | staging `END-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0-LOCAL`，实际文件 `审计/子代理交接/r1_ga100_source_staging/downloads/cuda-c-programming-guide-11.0.pdf`，SHA-256 `af4235e08e4ebb0f7651896db7ed05344f5e4ae6e9ce5da3cba3bc5ec6c69174`；官方 archive `https://docs.nvidia.com/cuda/archive/11.0/cuda-c-programming-guide/index.html` | PDF pp.33-35 §3.1，pp.37-38 §3.2-3.2.1，p.370 §I.7；`nvcc`、PTX/cubin、`cudart`、CC8.0 |
| `PTX` | NVIDIA PTX ISA 7.0/7.2，同一 PTX ISA family 的两个 revision | staging `ptx-isa-7.0.pdf`、`ptx-isa-7.2.pdf`；没有把两个 revision 算成独立 corroboration | PTX 7.0 PDF p.398 release table；PTX 7.2 pp.416-417 version table。用于 CUDA 11.0/PTX 7.0/`sm_80` 版本链，不替代 compiler/runtime 正文 |
| `CUDA-RN` | NVIDIA CUDA Toolkit Release Notes，11.0 GA | official-web v2 `R1GA100-WEB-021`，`https://docs.nvidia.com/cuda/archive/11.0_GA/cuda-toolkit-release-notes/index.html`；staging 已验收 | `CUDA Toolkit Major Component Versions`、`General CUDA`；`compute_80/sm_80` 和 A100 reachability。只作版本旁证 |
| `HPEC-v1` | `SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022`，`arXiv:2208.11174v1` | staging `END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`；本地 PDF SHA-256 `86013d806532a281e7878415cc1a55aa426f8fbd8ae0e9dc02285882fbdd8227`；`https://arxiv.org/pdf/2208.11174` | pp.4-7，Sections IV/V，Tables II-V。固定内容是 arXiv v1；DOI/HPEC 书目关系不证明与 IEEE final 内容等同 |
| `RAND-v1` | `SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024`，`arXiv:2405.11425v1` | staging `END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`；本地 PDF SHA-256 `6ca888b92691f06de9d5d15b268f2e2c738c9f0ef44441e6fd785f65a113a8a9`；`https://arxiv.org/pdf/2405.11425` | 全文，尤其 Sections 1.3、2.1、2.4 与 Figures 1、6；主体是 A100 SXM4-80GB product path |
| `A100-BENCH` | NVIDIA MIG BERT benchmark blog；MLCommons Inference v0.7 | 在线定向检查 `https://developer.nvidia.com/blog/getting-the-most-out-of-the-a100-gpu-with-multi-instance-gpu/` 与 `https://github.com/mlcommons/inference_results_v0.7`；本轮未落快照 | NVIDIA blog Figure 8/表格的 BERT Large、SQuAD、TensorFlow、batch 1、A100/MIG latency 与 throughput；MLCommons repository 的 system/submission 结构。两者都是产品或系统结果 |
| `STATUS` | NVIDIA vGPU lifecycle 与 AI Enterprise Infra 8.2 | official-web v2 `R1GA100-WEB-009`、`R1GA100-WEB-010`，staging 已验收 | lifecycle Appendix A 的 A100 variants full-support 列表；Infra 8.2 的 supported GPU/software tables。只证明 A100 软件支持，不证明 GA100 die hardware lifecycle |
| `TRADE` | NVIDIA 向 SEC 提交的 2022 Form 10-Q 与 2025 Form 10-K | 在线定向检查 `https://www.sec.gov/Archives/edgar/data/1045810/000104581022000147/nvda-20220731.htm`、`https://www.sec.gov/Archives/edgar/data/1045810/000104581025000023/nvda-20250126.htm`；本轮未落快照 | `Global Trade`/出口许可段直接点名 A100/H100 integrated circuits 与产品。没有点名 GA100 full-die design |

本轮联网检索只补本地材料没有覆盖的 exact-target 问题。技术结论只采用厂商正式文档、监管申报、MLCommons 原始结果库和作者论文；没有使用媒体、经销商报价、论坛或聚合网站。在线新增的 `A100-BENCH`、`TRADE` 只作排除或交叉对象线索，不是 GA100 正向 fact 来源；如果后续 reverse removal 判定它们不增加 exact-target closure，可以不入最小集。

## 15 个漏失 field 的 exact-target 裁决

“证据类型”列中的 `direct` 表示来源直接陈述，`measured` 表示第三方测量，`derived` 表示必须由已闭合输入计算。本表没有把 A100、vGPU、外部 HBM 或 system 数值沿 `implements_architecture` 逆向投给 GA100。

| exact target / field | 建议状态和值 | searched families、locator 与证据类型 | 支持或排除理由 |
|---|---|---|---|
| `COMP-M2NA-AMPERE-TENSOR / FIELD-COMP-DATAFLOW-RESIDENCY` | `value`：third-generation Tensor Core 在 32-thread warp 内共享 operand，减少 RF bandwidth 与从 SMEM 到 RF 的冗余装载 | `WP` pp.38-39，`Data sharing improvements` 与 Figure 14；`direct` | 句子主语直接是 NVIDIA Ampere architecture third-generation Tensor Core，target 正确。`cp.async` 位于 `COMP-M2NA-AMPERE-ASYNC-COPY` feeding path，不能合并进 Tensor Core 内部 residency assertion；A100 的 8× instruction/2.9× RF-access 对比也不作为架构常量写入本值 |
| `COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT` | `value`：在 fixed-work-per-GPU strong scaling 条件下，GEMM 分片到更多 SM 后每 SM tile 不增长，而 A100 Tensor Core 的数据消耗更快，feeding bandwidth 与可用并行度成为约束 | `WP` p.19 “A100 implementation of the GA100 GPU”、pp.38-39 strong-scaling 段；`ISSCC` p.1 左栏对应段；`direct`、A100 implementation condition | p.19 先建立 A100 implementation 到 GA100 的正向桥；后文所述是 per-SM/per-Tensor feeding constraint，不是 108-SM aggregate benchmark。故可条件化归属物理 component；这不是沿 architecture relation 投影，也不能写成“所有小矩阵利用率低” |
| `OBJ-NVIDIA-GA100-DIE / FIELD-DER-CAPACITY-COMPUTE` | `not_found` | `WP` p.19 full-design compute resources、Table 4 A100 40 GB；`ISSCC` p.1 A100 HBM；`BLOG` key features；`direct inputs checked, derived output rejected` | full GA100 没有同对象 external-memory capacity 与 precision-specific aggregate dense peak。A100 40 GB 是外部 HBM/product capacity，不能与 full 128-SM design 混算 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SPEC` | `not_found` | `WP` pp.19-20、35-37；`ISSCC` Figure 3.2.2；`HPEC-v1` Table III；`RAND-v1`；`derived` candidate rejected | full GA100 缺 clock 与同精度 aggregate dense peak；A100 1555 GB/s、1.41 GHz、108-SM peaks 是产品条件。HPEC Table III 的 `GB/s` 单位与 operation-count rule 不闭合，RAND-v1 也是 A100 SXM4-80GB |
| `OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SUSTAINED` | `not_found` | `WP`/`ISSCC` nameplate values；`HPEC-v1` Tables III-IV；`RAND-v1` Figures 1、6；`derived` candidate rejected | 没有 same-object sustained bandwidth。global-memory 290 cycles 跨外部 HBM/product path，不是带宽；random-access GB/s 是 A100 product measurement |
| `OBJ-NVIDIA-GA100-DIE / FIELD-DER-INTERCONNECT-COMPUTE` | `not_found` | `WP` p.20 Figure 6、p.52 NVLink；`ISSCC` p.1；`derived` input audit | 12-link full-design interface可给 300 GB/s/方向的 vendor-nameplate input，但 full-design precision-specific aggregate compute 仍缺 clock/peak，派生 DAG 不完整 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-DER-MOVE-MATRIX` | `not_found` | `WP` Figures 14、15 与 pp.39-40；`HPEC-v1` Tables III-IV；`derived` candidate rejected | RF/SMEM access-count example、async-copy 路径和 latency cycle 都不是具有明确宽度、方向与 traffic basis 的 movement throughput；Table III 不能修单位后使用 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-DEPLOYMENT` | `not_found` | `WP` pp.8-14、69-74 DGX/A100；`NEWS`；`PB`；`BLOG` introduction；`direct wrong-subject results` | 命中的部署均以 A100 card/module、DGX/HGX、cloud 或 system 为主体。`GA100 powers A100` 是实现身份关系，不是 standalone die deployment |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-DESIGN-OBJECTIVE` | `not_found` | `WP` p.38 strong scaling、p.58 CUDA goals；`ISSCC` p.1；`BLOG` introduction；`direct wrong-target result` | strong scaling 和 programmability 句子的主体是 Ampere architecture，产品尺度/TCO 句子的主体是 A100。可在 `OBJ-NVIDIA-AMPERE-ARCH` 另建 direct architecture fact并由 reachability 展示，但 `FIELD-ID-ARCH` 之外不能投影关闭 die requirement |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` | `not_found` | `WP`、`ISSCC`、`BLOG`、`NEWS`、`PB` 全文；`TRADE` 的 A100/H100 出口许可段；`direct wrong-subject result` | SEC filings 精确点名 A100 product/integrated circuit 与 performance-threshold products，没有点名 GA100 full-die design。地区、有效日期与对象不能靠“GA100 powers A100”拼接 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-TARGET-USE-POSITIONING` | `not_found` | `WP` pp.8-14、36，`BLOG` introduction/Introducing A100，`ISSCC` p.1；`direct wrong-subject result` | AI training/inference、HPC、data analytics、cloud/data center 的用途定位均直接修饰 A100 或 Ampere platform，没有直接修饰 full GA100 die。产品用途不得逆向投影 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-VENDOR-POSITIONING` | `not_found` | `BLOG` `Key features` 首段；`WP` pp.5-14；`ISSCC` p.1；`NEWS` 与 `PB`；`direct wrong-semantics/wrong-subject results` | “GA100 GPU that powers A100” 是 identity/implementation bridge，不是市场定位。训练、推理、数据中心平台等厂商措辞均直接修饰 A100 产品或 Ampere 架构，不能借字段只保存原文的定义绕过事实语义，也不能逆投给 die |
| `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-DIE-COUNT` | `not_applicable`，reason=`target_is_a_die_not_a_containing_package` | `WP` pp.19-20 full GA100/Figure 6；`ISSCC` p.3 die photo；结构 predicate | target 本身是一个 die design，当前没有 package/chiplet-container target；自计数 `1` 没有可解释的“计算/I/O/其他功能 die”语义。die photo 只证明对象形态，不能把 package-level die count 写成 1 |
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-COMPILER` | `value`：`nvcc compiler driver, CUDA Toolkit 11.0.3, generating PTX/cubin for sm_80` | `CUDA-PG` pp.33-35 §3.1-3.1.4；`PTX` 7.0 p.398；`CUDA-RN`；`direct` | target 是正式 Ampere architecture，不需要也不允许投到 GA100 die。文档未给 compiler internal build；driver JIT 与 nvcc 不合并成一个版本 |
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-RUNTIME` | `value`：`CUDA Runtime (cudart), CUDA Toolkit 11.0.3` | `CUDA-PG` pp.37-38 §3.2-3.2.1，p.41 CUDA 11.0/CC8.0；`CUDA-RN` 旁证；`direct` | `cudart` 的静态/动态、Windows/Linux 链接形式是同一 runtime 的分发形态，不拆成多个 runtime。软件字段直接落 Ampere，不借 A100 product reachability 下放 die |

这 15 项的状态分布为 4 `value`、10 `not_found`、1 `not_applicable`。其中两个 software value 的事实 target 已正式存在；GA100 die/component 行仍要等 chip transaction 把拟议 target 正式化后才能落盘。

## 六个 benchmark field 的发布性闭合

六项均建议 `not_found`，而不是保留 `pending`。我没有把它们写成结构性 N/A，因为当前合同只把 subject kind 限到 `object`，尚未给“bare die 不可作为 workload benchmark subject”配置一条已批准 predicate。用完整 exact-target 搜索闭合 `not_found` 比自行扩 N/A policy 更稳妥。以后若合同正式增加 bare-die benchmark N/A predicate，可以迁移状态，但不能在本报告中预先假定。

共同检查范围包括 `WP` Figures 4、5 和 Table 4、`ISSCC` Figure 3.2.4、`HPEC-v1` pp.4-7、`RAND-v1` 全文、`A100-BENCH` 的 A100 BERT/MIG 与 MLCommons submission，以及 `PB`/`NEWS` 的产品条件。工作负载、模型、batch、sequence length、software、MIG mode、enabled-SM、HBM、card/system power scope 都是 benchmark condition，不是 GA100 chip factor。

| exact target / field | 建议状态 | 逐字段 locator 与排除理由 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | `not_found` | `HPEC-v1` Tables II、IV、V 只有 instruction/memory cycle；可接收部分另入 instruction/memory latency，不是 workload seconds。NVIDIA A100 BERT/MIG blog 给 batch 1 的 product latency；MLCommons 给 system/SUT latency。两者都不能下放 full GA100 die |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` | `not_found` | `HPEC-v1` Table III 的 `GB/s` 与 operation definition 冲突；`RAND-v1` 是 A100 SXM4-80GB random-memory GB/s；NVIDIA BERT/MIG 和 MLCommons 是 A100 product/system samples/s。白皮书/ISSCC 只有 A100 相对 speedup或产品 peak |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-POWER` | `not_found` | `WP` Table 4 的 400 W 是 A100 SXM4 TDP，不是 measured workload power。MLPerf Power 方法测的是完整 system at the wall，SUT 包含 host、memory、accelerator 和 software；没有 die-only measurement scope |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-ENERGY-PER-TOKEN` | `not_found` | `WP`、`ISSCC`、`HPEC-v1`、`RAND-v1` 与 A100-era MLPerf/BERT 结果均无 token 定义、模型阶段、服务约束和 die-only energy scope；system joule/sample 也不能改写为 J/token |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-TOKENS-PER-JOULE` | `not_found` | 与上一项相同的来源逐项检查；没有同一 run 的 token count 与 die-only measured energy。不得用 TDP、samples/s 或后世 LLM 工具的 metric definition倒推 GA100 值 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-UTILIZATION` | `not_found` | `WP` strong-scaling 段是设计动机，Figure 14 是 per-SM illustration；`HPEC-v1` `Measured-theoretical` 没有项目要求的 MFU/HFU/MBU/efficiency 定义；A100 BERT/MIG throughput ratio 仍是产品实验，不能变成 GA100 die 利用率 |

HPEC background 的 `124 SM` 继续拒绝：它与 full GA100 128 SM 和 A100 enabled 108 SM 均冲突，且没有测试配置支持。该数值不参与任何 benchmark、derived 或 test-carrier bridge。

## die 日期、状态与经济字段

| exact target / field | 建议状态和值 | searched families、locator 与理由 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` | `value = 2020-05-14`，语义固定为 `first official publication directly naming GA100` | `BLOG` 页首日期与 `Key features` 直接 GA100 句；`WP`/`NEWS` 作同日上下文。该日期不是 A100 shipping 的逆向投影，也不表示 standalone die 开售 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-AVAILABILITY-DATE` | `not_found` | `NEWS` 的 full production/shipping 主体是 A100；`PB` 是 card SKU；`BLOG` 没有 standalone GA100 supply/ordering date。release/public naming 与 availability 分开 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-STATUS` | `not_found` | `STATUS` 只证明 A100 variants 的 vGPU software full support 与 Infra 8.2 compatibility；`NEWS` 只固定 2020-05-14 A100 production；当前页面存在也不证明 GA100 die 生产、销售、EOS 或 EOL |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ECON-PUBLISHED-PRICE` | `not_found` | `WP`、`ISSCC`、`BLOG`、`NEWS`、`PB` 已逐文档检查 `price/pricing/MSRP/list price/USD/dollar`，没有 standalone GA100 die price。DGX/system、cloud、reseller 与 A100 card价格均属其他对象，不能除算或下放 |

## HPEC test-carrier bridge 与 cycle 分域

`HPEC-v1` 的测试载体在正文写作 `Nvidia Tesla AI100 GPU`，Table V 又写 `Amepere A100`。结合论文标题、正文反复出现的 A100，以及 `WP`/`BLOG` 的 A100 到 GA100 identity，`AI100` 可裁为 A100 product-family 拼写歧义，不创建新对象。这个桥只允许把能明确隔离到 on-die path 的测量条件化归属给 GA100 component；它不是 `implements_architecture` 投影，也不把 A100 40/80GB、SXM/PCIe、108 SM、MIG/ECC configuration 补成已知值。

| 候选测量 | 可接收 target / field | 状态与条件 | 拒绝边界 |
|---|---|---|---|
| Table II/V scalar PTX→SASS cycles | opcode 对应的 `COMP-R1-GA100-SM` 或已有更窄 on-die compute component / `FIELD-COMP-INSTRUCTION-LATENCY` | v4 迁移后可 `value`，单位原样 `cycle`，evidence=`measured`；逐条保留 opcode、datatype、dependent/independent、initialization、PTX→SASS mapping、clock-read overhead；未披露 clock/software/config 写 `unknown` 或 contract-null | 不能写进 workload `FIELD-BENCH-LATENCY`，不能换算秒，不能升级为无条件 RTL pipeline constant |
| Table III WMMA 4/8/16 cycles | `COMP-R1-GA100-TENSOR / FIELD-COMP-INSTRUCTION-LATENCY`；只有已有 GA100-specific precision path 且 datatype/operation 完全匹配时才挂 path | v4 迁移后可按 WMMA shape、layout、datatype、SASS expansion 分条 `value`，单位 `cycle`，A100 carrier 条件 | 不挂 `PPATH-M2NA-AMPERE-*`，避免把单一 GA100 implementation 推广到全部 Ampere；Table III `GB/s` throughput 列仍拒绝 |
| Table IV L2 200 cycles | `COMP-R1-GA100-L2 / FIELD-MEM-LATENCY` | v4 memory-latency unit合同迁移后可 `value`；保留 pointer chasing、cache operator、working set、dependency、clock domain unknown | current formal field canonical unit 是 `s`，当前不能落盘；不把 200 cycles 当 L2 固定规格 |
| Table IV L1 33 cycles、shared load/store 23/19 cycles | `COMP-R1-GA100-L1SMEM / FIELD-MEM-LATENCY` | 同上，按 L1、shared load、shared store 拆 assertion；原单位 `cycle` | 不合并为一个 combined-cache latency，不从 `u64` 推 cache line/transaction size |
| Table IV global memory 290 cycles | A100 product test path only | 对 GA100 exact component `checked_wrong_scope` | 路径跨 on-die controller、外部 HBM、product form、enabled configuration 与 runtime，不能归属 full GA100 die |

当前正式 `fields.csv` 有 141 个 data row，不是 142 个 field；它尚无 `FIELD-COMP-INSTRUCTION-LATENCY`，且 `FIELD-MEM-LATENCY.canonical_unit` 仍为 `s`。v4 设计通过删除 `FIELD-ID-DATA-CUTOFF`、增加 instruction latency 保持 141 个 field，并允许 memory-latency direct fact 使用 `cycle` 或 `s`。因此，以上 cycle measurement 是“来源已闭合、合同迁移未完成”，不能借 raw-value 旁路伪装成已发布 fact。

## external HBM、MIG 与 RAS 的防串线

full GA100 p.19 的 12 个 512-bit controller 可按已批准的 `public_derived` 规则得到 6144-bit die interface；这个值既不是 HBM stack count，也不是 memory capacity/bandwidth。六个 HBM stack、40/80 GB capacity、1555/1935 GB/s、framebuffer ECC、DPO/row-remap 的物理存储对象和 A100 card service 条件都留在 external-HBM/product path。它们可以成为 GA100 controller/RAS mechanism 的条件或关联证据，不能作为 derived 五字段的同对象输入。

MIG/RAS 同样按 mechanism 与 product/software 分层。`WP` p.35 的 on-die L2/L1/RF SECDED 和 p.52 NVLink detection/replay可作条件化 GA100 mechanism；固定 RAS PDF 的 GA100 support table、DPO、containment、row remap 可证明 driver/service/HBM 协同流程，但不能声称已公开 detector RTL 或 whole-chip protection。telemetry 与 NVIDIA Field Diagnostics 可以进入 `FIELD-RAS-TELEMETRY-BIST` 的相应子语义，公开 BIST structure 仍是 `checked_no_support`。

MIG Guide 通过 supported-products 表把 A100/A30 product implementation 关联到 GA100，GI 的 crossbar/L2/controller/DRAM path 隔离、CI dedicated SM 与父 GI shared memory/engines、GI QoS/fault isolation可作“supported GA100 product implementation”条件化 mechanism。最多 7 个 instance、profile capacity、vGPU migration、Suspend-Resume、time-sliced preemption、driver lifecycle 与 monitoring 都是 product/software/control-plane 事实。它们不能用来填 GA100 die status、deployment、benchmark 或 chip-factor value。

## 逐事实实施顺序与验收

后续实现应先完成 contract v4 正式迁移，再注册 `OBJ-NVIDIA-GA100-DIE`、拟议 components 与单向 `GA100 implements Ampere` reachability；这一步不能增加 card→die 或 software→die 的反向投影。随后把 `WP` 之外实际被选中的 HPEC、CUDA-PG、official-web v2 source/version/endpoint 正式登记并复制 stable payload，逐 endpoint 复算 hash。online-only 的 A100 benchmark/SEC lead 只有在 reverse removal 后仍承担 negative-evidence obligation 时才需要快照入库。

事实层的验收顺序是：先落 Ampere direct 的 dataflow/compiler/runtime；再落 BLOG direct 的 GA100 release；随后落 GA100 Tensor utilization-limit 的 A100-implementation 条件化 assertion；接着写 die-count structural N/A 和全部 field-specific `not_found` search/result，其中 vendor-positioning 必须记录 BLOG identity bridge 为 wrong-semantics；最后在 v4 单位合同通过后拆 HPEC instruction/memory cycle。五个 derived requirement 只写缺失输入与 search closure，不建空 DAG，不生成零值。

逐事实验收至少检查以下同层条件：target ID 已正式 reachable；field/target kind 合法；每个 value 有 actual endpoint 与 canonical locator；A100/HBM/system/vGPU 名称只出现在 condition、wrong-subject result 或 related evidence；HPEC 每条 measured fact 保留 opcode/path 与 unknown/null 语义；`cycle` 没进 workload latency，也没无频率换算；benchmark 六项各自有独立 search result；所有 `not_found` 都没有 literal fact row；die count N/A 有结构 predicate 与独立 proof；derived 五项没有混用 128-SM full design、108-SM A100、A100 clock/HBM；最后运行 reverse removal，而不是预设来源数量。

## 发布阻断与失败分类

本报告所列 25 个 requirement closure 没有真正的剩余“还需找一类来源”缺口。release、dataflow、utilization-limit、compiler/runtime 有正向来源；die count 有结构证明；vendor-positioning 等其余项已经完成 exact-target 检索并可合法闭合为 `not_found`。如果实现仍显示 `pending_verification`，应先核对是否漏导入本报告的 search/result，而不是把 A100 值补进 GA100。

仍然阻断正式发布的事项均不属于来源内容缺失：`OBJ-NVIDIA-GA100-DIE` 与 GA100 component/reachability 未正式入库；v4 合同未应用；official-web v2 与 r14 固定 payload 未正式登记 actual endpoint；相应 AFPV2 assertion、coverage manifest、reverse removal 与独立批准尚未执行。online-only lead 若被 reverse removal 保留，还需另做快照固定。这些分别归类为 contract/schema implementation blocker、target/reachability implementation blocker 和 source-ingestion blocker。

本轮联网访问成功，没有 sandbox denial、user/auto-review approval denial、approval-review connection failure或 remote service error。网页搜索返回过与 GA100 无关的后代产品和论坛结果，均在主语复核时排除，属于正常的 `irrelevant_search_result`，不是工具失败。完成正文后，一次辅助 `git status` 检查因当前工作根不是 Git repository 而返回 `not a git repository`；这是环境前置不满足，不是 sandbox/approval/联网失败，也不影响直接文件 hash 与行数核验。没有工具停滞、运行时中断或破坏性操作。

## 质量复核

`report-humanizer` 已对本文件执行单文件机器扫描。人工逆向复读按发布阻断、实施验收、MIG/RAS/HBM、HPEC cycle、日期/status/price、benchmark、15-field 表、来源身份、开头裁决的顺序返回检查，重点核对了 15+6+4=25 个 requirement、4/10/1 的 15-field 分布、六个 benchmark 全部 `not_found`、HPEC arXiv v1/IEEE final 区分、124/128/108 SM、Table III 单位、external HBM、141-field 口径、software 落 Ampere，以及唯一允许的 `FIELD-ID-ARCH` relation projection。未发现 target 倒置、把 workload variable 写成 chip factor，或把 `ingestion_pending` 写进 requirement status。
