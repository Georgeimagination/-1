# GH100 内容验收与事实缺口矩阵

> 当前状态：主会话工作稿，等待核心资料、独立微基准以及软件、MIG、RAS 三份交接合并后复核。本表只裁决资料卡怎样写，不代表正式 CSV、selection run 或发布门已经完成。默认主体为 `OBJ-NVIDIA-GH100-DIE`，即 full GH100 裸片设计；H100 SXM5、H100 PCIe、H100 NVL、H200、H800、Grace Hopper、HGX、DGX 和 NVLink Switch System 都是相邻对象。

状态沿用五类：`可直接写值`、`条件化写值`、`not_found`、`not_applicable` 和 `仍 pending`。`not_found` 只表示在本轮计划语料中未找到可归属 exact target 的可靠值；本工作稿中的 `not_found` 要到逐项检索记录完成后才能进入正式数据。

来源简称暂定：`WP` 为 *NVIDIA H100 Tensor Core GPU Architecture* v1.04；`DS` 为 2024 H100 Datasheet；`TG` 为 CUDA Hopper Tuning Guide 13.3；`HC` 为 Hot Chips 34；`IEEE` 为 2023 IEEE Micro；`PTX` 为待固定版本的 PTX ISA；`MIG` 为 NVIDIA MIG User Guide；`RAS` 为 NVIDIA GPU Memory Error Management；`MB24/25` 为两版 H800 Hopper 微基准。最终简称、版本与 endpoint 以 `gh100_minimal_sources.md` 为准。

## 1. 对象、物理实现和公开定位

| ID | 资料卡项 | 当前裁决 | target | 可写内容或缺口 | 证据与边界 |
|---|---|---|---|---|---|
| M001 | 正式名称、family、vendor、object type | 可直接写值 | GH100 die | `NVIDIA GH100`；family=`GH100`；vendor=`NVIDIA`；object type=`die` | WP pp.17-19；MIG Supported GPUs 把 H100/H200/H20 的 microarchitecture 写为 GH100 |
| M002 | 架构代际 | 可直接写值 | `GH100 implements Hopper` relation candidate | Hopper architecture / compute capability 9.0；只用关系表达 | WP；MIG Supported GPUs。同一证据还需形成独立关系断言 |
| M003 | release date | 仍 pending | GH100 die | 2022-03-22 只能作为官方文章首次直接命名 GH100/Hopper 的候选观察日；不能自动等于裸片发布日期 | NVIDIA Hopper Architecture In-Depth 页面；全库 release-date 语义迁移仍未完成 |
| M004 | availability date | not_found | GH100 die | 未找到 standalone GH100 裸片可订购或首次供货日期 | 2022-09-20 full-production 新闻稿直接主体为 H100 产品和系统 |
| M005 | current hardware status | not_found | GH100 die | 未找到直接绑定裸片的在产、停售、EOS/EOL 或可订购状态 | 当前 H100 产品页存在不等于 GH100 裸片状态 |
| M006 | SKU | not_found | GH100 die | `GH100` 是设计/微架构名，不是 standalone 销售 SKU | H100/H200/H20 产品 SKU 不下放 |
| M007 | public deployment | not_found | GH100 die | 未找到 standalone die 部署记录 | H100、H200、GH200、HGX、DGX 或云实例属于上层对象 |
| M008 | market-access constraint | not_found | GH100 die | 已知出口限制直接命名 H100/H800/H20 等产品时，只作 wrong-subject 结果 | 不沿产品身份链投给完整裸片设计 |
| M009 | design objective | 条件化写值 | Hopper/H100 architecture context | strong scaling、AI/HPC、数据局部性、异步执行和可编程性目标 | WP 与 2022 技术博客；不是 GH100 裸片独立市场定位 |
| M010 | target-use positioning | 条件化写值 | Hopper/H100 product context | AI、HPC、data analytics；H100 产品同时面向训练和推理 | WP/DS/current product page；不改写成 die 专用用途 |
| M011 | vendor positioning | 条件化写值 | Hopper/H100 product context | 厂商称其提升性能、扩展性、安全与能效 | 保留厂商语境和比较基线，不当作第三方实测 |
| M012 | GH100 die design objective | not_found | GH100 die | 直接材料多以 Hopper architecture 或 H100 product 为主语 | 不从 M009 投影 |
| M013 | GH100 die target-use positioning | not_found | GH100 die | 未找到 standalone die 的训练、推理或 HPC 定位句 | 不把产品用途下放 |
| M014 | GH100 die vendor positioning | not_found | GH100 die | `full GH100 powers H100` 是身份桥，不是裸片市场定位 | WP p.17 |
| M015 | foundry 与 process | 可直接写值 | GH100 die | `TSMC 4N customized for NVIDIA` | WP p.17、Table 3；正式事实 `FACT-NVIDIA-GH100-PROCESS` |
| M016 | die area | 可直接写值 | GH100 die | `814 mm²` | WP p.17、Table 3；正式事实 `FACT-NVIDIA-GH100-DIE-AREA` |
| M017 | transistor count | 可直接写值 | GH100 die | `80 billion` | WP p.17、Table 3；正式事实 `FACT-NVIDIA-GH100-TRANSISTORS` |
| M018 | die count | not_applicable | GH100 die | target 本身就是一颗 die design，不写 package-level `1` | 结构判断，不由 Figure 6 反推封装芯粒数 |
| M019 | HBM stack count | 仍 pending | GH100 die | WP 的 full implementation 写 6 stacks，但 HBM 位于 package/product path；exact pair 的结构适用性需按正式合同裁决 | H100 SXM5/PClE 只启用 5 栈；不得填成 die 内部组件数 |
| M020 | HBM total interface | 可直接写值 | GH100 die memory-controller interface | `12 × 512 bit = 6144 bit`，标 `public_derived` | WP p.18；H100 启用配置为 10×512 bit |
| M021 | die clock | not_found | GH100 die | 未找到 full 144-SM GH100 的对象级时钟 | WP Table 3 的 1830/1980 MHz 属 H100 SKU/path |
| M022 | die power | not_found | GH100 die | 未找到 full GH100 die power | 700/350 W 等属于 H100 模组或卡 |

## 2. 计算资源、数据流和控制

| ID | 资料卡项 | 当前裁决 | target | 可写内容或缺口 | 证据与边界 |
|---|---|---|---|---|---|
| M023 | GPC count | 可直接写值 | full GH100 GPC | `8` | WP p.18 |
| M024 | TPC count | 可直接写值 | full GH100 TPC | `72`，9/GPC | WP p.18 |
| M025 | SM count | 可直接写值 | full GH100 SM | `144`，2/TPC | WP p.18、Figure 6 |
| M026 | FP32 CUDA Core count | 可直接写值 | full GH100 FP32 component | `18,432`，128/SM | WP p.18 |
| M027 | fourth-generation Tensor Core count | 可直接写值 | full GH100 Tensor component | `576`，4/SM | WP p.18、Figure 7 |
| M028 | memory-controller organization | 可直接写值 | full GH100 memory controller | `12` 个、每个 `512 bit` | WP p.18、Figure 6 |
| M029 | enabled product configurations | 条件化写值 | H100 SXM5 / PCIe product | SXM5=`132 SM/66 TPC/528 TC/10 controller/50 MB L2`；PCIe=`114/57/456/10/50 MB` | 只作对象边界，不与 M023-M028 建冲突 |
| M030 | per-SM Tensor throughput | 条件化写值 | Hopper/H100 SM | 第四代 Tensor Core 对既有 datatype 的 raw dense/sparse matrix math 每 SM、同频率相对 A100 为 2×；FP8 再提高 | WP/技术博客为相对口径；没有 full GH100 绝对总峰值 |
| M031 | physical Tensor array shape | not_found | GH100 Tensor component | 指令 tile 和示意图不披露物理阵列行列、FMA lane 或 accumulator 数 | WP/PTX |
| M032 | instruction tile | 条件化写值 | Hopper `sm_90a` precision path | 可按 PTX 固定版本保存 WGMMA/MMA 的 datatype 与 tile set | PTX 版本、target 与稀疏条件必须随值保存；不等于物理阵列 |
| M033 | dataflow residency | 条件化写值 | Hopper Tensor/TMA path | warpgroup 异步矩阵执行、shared-memory operand 路径、TMA feeding 和显式 barrier 形成软件可见流水 | WP/TG/PTX；不推导物理内部 buffer 容量 |
| M034 | SM control、concurrency 与 shared resources | 可直接写值 | GH100/Hopper SM | 4 processing blocks、4 warp schedulers、每块 32 thread/clk；REG、FP32/INT32/FP64、LD/ST、SFU 与 Tensor Core 共享 SM | WP Figure 7；仲裁、queue、scoreboard 和 dual-issue RTL 未公开 |
| M035 | utilization limits | 条件化写值 | Hopper/H100 software path | occupancy 受 warp/thread-block、register、shared memory、cluster 和 shape 限制；TMA/WGMMA overlap 需显式流水 | TG/PTX；模型、batch 和 tile 只作条件 |
| M036 | full-design aggregate compute throughput | not_found | GH100 die | 缺 full-design clock 与同对象的绝对 precision peak | 不用 H100 SXM5/PCIe 峰值按 SM 比例外推 |

## 3. 数值格式与稀疏路径

GH100 内容卡暂按 11 条软件可见路径建立候选：FP8、FP16 Tensor、BF16 Tensor、TF32 Tensor、FP64 Tensor、INT8 Tensor，以及 FP16、BF16、FP32、FP64、INT32 非 Tensor 路径。每条路径都必须裁决操作数 A、操作数 B、程序员可见累加、中间乘积、物理内部累加、输出、舍入、缩放方式、缩放粒度、饱和、subnormal 和稀疏，共 132 个 cell。不能沿用 H100 模组现有 `PPATH-NVIDIA-H100-*` 行作为 GH100 路径。

| 路径 | 当前可确认内容 | 仍需逐 cell 闭合的重点 |
|---|---|---|
| FP8 Tensor | E4M3/E5M2，可混合输入；程序员可见累加为 FP16 或 FP32；Hopper Transformer Engine 配合缩放和格式转换；支持结构化稀疏峰值口径 | E4M3/E5M2 的 exact A/B 组合、output、rounding、subnormal、per-tensor/delayed scaling 的版本边界、物理 accumulator |
| FP16 Tensor | FP16 输入；FP16 或 FP32 累加；dense 与 2:4 sparse | product、physical accum、output/rounding/subnormal 和 exact sparse metadata |
| BF16 Tensor | BF16 输入；FP32 累加；dense 与 2:4 sparse | 同上 |
| TF32 Tensor | TF32 输入，公开峰值区分 dense/sparse | 程序员可见累加、product、physical accum、output 和异常语义需由 PTX 定位 |
| FP64 Tensor | FP64 路径存在，未见结构化稀疏峰值 | product、physical accum、舍入和 subnormal |
| INT8 Tensor | S8/U8 到 S32 候选；dense 与结构化稀疏 | signedness 组合、饱和/回绕、output 与 metadata |
| FP16/BF16/FP32/FP64/INT32 非 Tensor | H100 产品表给出这些路径，但 full GH100 aggregate peak 不可继承 | component ownership、程序员可见累加/output、舍入/异常、是否需要按标量/向量另拆 |

最终矩阵必须在 PTX 和数值独立证据定版后给出 D/C/NF/NA 的 132-cell 分布；当前不以空白代替裁决。

## 4. 存储、互联和数据搬运

| ID | 资料卡项 | 当前裁决 | target | 可写内容或缺口 | 证据与边界 |
|---|---|---|---|---|---|
| M037 | register-file capacity | 可直接写值 | GH100 REG per SM | `4 × 16,384 × 32 bit = 256 KiB/SM` | WP Figure 7；不把 144×汇总写成统一池 |
| M038 | register-file instance count | 可直接写值 | GH100 REG per SM | 4 个 processing-block RF instance/SM | WP Figure 7 |
| M039 | combined L1/shared physical capacity | 可直接写值 | GH100 L1/shared per SM | `256 KB/SM` | WP pp.21、27；与可配置 shared maximum 分开 |
| M040 | software-visible shared capacity | 条件化写值 | Hopper/H100 allocation | configurable up to `228 KB/SM`；per-block 上限、系统保留与 CUDA 版本另行固定 | WP p.27；TG 13.3 |
| M041 | L2 capacity | 可直接写值 | full GH100 L2 | `60 MB` | WP p.18；H100 SXM5/PCIe 只启用 50 MB |
| M042 | L2 organization、residency、pooling | 条件化写值 | Hopper/H100 L2 | partitioned crossbar、local partition affinity、L2 residency control；full-GPU 与 MIG 模式分开 | WP pp.36-37；不推导 full GH100 slice 数或 crossbar 端口 |
| M043 | compression/decompression | 条件化写值 | HBM/L2 path | HBM3/HBM2e 与 L2 支持 data compression/decompression | WP p.37；external HBM 与 on-die L2 分目标 |
| M044 | L1/shared/RF transfer、ports、banks、granularity | not_found | GH100 on-die memory | 尚无 exact port、bank、每周期读写和 transaction granularity 的完整公开值 | TMA operation size不能替代物理 bank/port |
| M045 | on-die latency/bandwidth measurement | 仍 pending | GH100 component on H800/H100 carrier | 等待 MB24/25 和其他 H100 PCIe 微基准的对象、频率与方法审查 | 所有数值必须保留 SKU、CUDA、锁频和 access pattern |
| M046 | virtual-memory responsibility at L2 | not_found | GH100 L2 | 未证明 L2 独自负责 page size、migration 或 address translation | NVLink Network translation、Unified Memory 和 GH200 coherence 是相邻机制 |
| M047 | PCIe interface | 可直接写值 | GH100 host link | PCIe Gen5 x16 interface | WP Figure 6、p.49 |
| M048 | PCIe bandwidth | 条件化写值 | H100/PCIe Gen5 endpoint | 64 GB/s per direction、128 GB/s bidirectional vendor convention | 协议代际可归 link；不是应用有效载荷或 die workload 实测 |
| M049 | NVLink interface/link count | 可直接写值 | full GH100 NVLink4 link | Figure 6 显示 18 个 NVLink block；H100 明确为 18 links | WP Figure 6、p.47 |
| M050 | NVLink lane 与 per-link rate | 可直接写值 | NVLink4 link | 2 differential pairs per direction；25 GB/s effective per link per direction | WP p.47 |
| M051 | NVLink injection bandwidth | 可直接写值 | GH100/H100 device with 18 links enabled | 450 GB/s per direction | 18×25 GB/s，标 `public_derived`；不等于 GPU-pair 或系统 bisection |
| M052 | NVLink aggregate bandwidth | 可直接写值 | GH100/H100 device with 18 links enabled | 900 GB/s bidirectional aggregate | WP pp.11、47 |
| M053 | NVLink remote memory/addressing/fault behavior | 条件化写值 | NVLink4/NVLink Network | regular NVLink common address space；NVLink Network 使用独立 network address space 和 H100 translation hardware；link detection/replay | regular NVLink 与 network fabric、product 与 system 条件分开 |
| M054 | NVLink absolute latency | not_found | GH100 NVLink4 link | 公开材料未给 exact single-hop 或 endpoint latency | `low latency` 不是数值 |
| M055 | topology、bisection、degree、hops、scale、oversubscription | not_found | GH100 die/link factor | 裸片只提供 endpoint，HGX/DGX/NVSwitch/fat-tree 属系统 | 256 GPU、57.6 TB/s、2:1 tapered fat tree 不下放 |
| M056 | die-side collective offload | not_found | GH100 die factor | SHARP/multicast 位于 NVSwitch；NCCL 是软件 | 不把 TMA reduction、DPX 或 warp reduction当网络 collective engine |

## 5. 专用机制、软件、虚拟化和 RAS

| ID | 资料卡项 | 当前裁决 | target | 可写内容或缺口 | 证据与边界 |
|---|---|---|---|---|---|
| M057 | structured sparsity | 可直接写值 | Hopper Tensor path | fine-grained 2:4 class sparse MMA；metadata/压缩和 exact datatype 由 PTX 定版 | 有效 2× 不表示物理 MAC 翻倍或自动发现任意零值 |
| M058 | TMA | 可直接写值 | Hopper/GH100 SM data mover | hardware address generation；global↔shared 1D-5D tensor copy、cluster shared copy、部分 reduction/layout 能力 | WP pp.32-34；TG；不是 attention/KV 专用 DMA |
| M059 | asynchronous transaction barrier | 可直接写值 | Hopper SM/cluster control | split barrier 同时跟踪 thread arrivals 和 asynchronous transactions | WP pp.34-35；不是跨 GPU/job checkpoint |
| M060 | thread-block cluster、DSM 与 warpgroup execution | 可直接写值 | Hopper SM/GPC | cluster 保证协同 thread blocks 同时调度到一组 SM；DSM 支持跨 block shared-memory load/store/atomic；WGMMA 使用 warpgroup | portable/nonportable cluster size和 `sm_90a` 条件保留 |
| M061 | Optical Flow Accelerator | 条件化写值 | H100 product/MIG media profile | H100 full MIG profile显示 1 OFA；是否为 full GH100 直接模块和数量等待 Figure/source 复核 | 不能从 product profile静默下放 |
| M062 | OFA throughput | not_found | GH100/OFA candidate | 未找到 exact GH100 throughput | SDK 或产品 benchmark 需另建条件 |
| M063 | media decode/JPEG | 条件化写值 | H100 product implementation | H100 80GB full profile有 7 NVDEC、7 JPEG；白皮书给产品 decode能力 | 数量不无条件下放 full GH100；不由缺失推 NVENC/RT/display 电路不存在 |
| M064 | Attention-specific data mover | not_found | GH100 die factor | TMA 是通用 tensor mover，未找到 attention-specific buffer/data mover | 不把 workload 使用方式改写为硬件归属 |
| M065 | Softmax | not_found | GH100 die factor | 未找到完整 exponent、normalization 与 reduction 的专用模块 | SFU/warp reduction/TMA reduction 均不足 |
| M066 | Top-k / ranking | not_found | GH100 die factor | 未找到通用排序、索引选择专用单元 | DPX min/max 不是 Top-k engine |
| M067 | MoE routing / dispatch | not_found | GH100 die factor | 未找到 expert routing table、token dispatch queue 或专用 network path | NVLink/NCCL只提供通信基础 |
| M068 | KV Cache management | not_found | GH100 die factor | 未找到 KV-specific allocation、placement、eviction 或 migration manager | Unified Memory、L2 residency、TMA和TensorRT-LLM是相邻机制 |
| M069 | quantize/dequantize and conversion | 条件化写值 | Hopper Tensor/Transformer Engine | software 与 custom Hopper Tensor Core technology按 tensor statistics/scales选择 FP8或16-bit并转换 | 不解释为独立可计数“量化核”；版本化 scaling语义另由 TE/PTX 文档闭合 |
| M070 | transpose/permute/layout transform | 条件化写值 | TMA/software path | TMA支持多维tensor layout和部分变换；exact transpose/permute指令与吞吐待定 | 不从copy descriptor名称推任意置换硬件 |
| M071 | compiler | 条件化写值 | Hopper software | `nvcc`、PTX/cubin、`sm_90`/`sm_90a` target | 绑定 CUDA/PTX 固定版本；不是裸片自带软件 |
| M072 | runtime and custom-kernel interface | 条件化写值 | Hopper software | CUDA Runtime/C++ kernel、cluster/TMA/WGMMA API或PTX接口 | 版本与最低架构目标必须保存 |
| M073 | framework support | 仍 pending | H100/GH100 software stack | 等待固定 PyTorch/JAX/TensorFlow 容器或支持矩阵 | 文档支持、可运行验证与benchmark分层 |
| M074 | communication library | 仍 pending | H100/NVLink software stack | NCCL 可作为条件化库，但需固定版本、支持范围和已知限制 | 不等于 die内collective offload |
| M075 | operator libraries | 仍 pending | H100/GH100 software stack | cuBLAS/cuDNN/Transformer Engine/TensorRT/cuSPARSELt 等逐版本裁决 | 库名不证明所有operator/datatype/shape |
| M076 | dynamic shape | 仍 pending | inference runtime | 需固定 TensorRT/TensorRT-LLM 或框架版本与对象支持 | 不泛化为任意 graph |
| M077 | quantization tool | 仍 pending | Hopper/H100 software | Transformer Engine或TensorRT量化、校准和scale管理需按版本拆分 | 硬件FP8支持不等于工具成熟度 |
| M078 | MIG partition mechanism | 条件化写值 | supported GH100 product, MIG mode | H100/H200/H20均以 GH100 microarchitecture支持最多7实例；GI分割SM、L2、memory-controller/DRAM path并提供隔离 | profile容量、SM比例、media/copy engine是产品配置，不是full die常量 |
| M079 | MIG lifecycle/control plane | 条件化写值 | MIG software/control plane | mode、GI/CI create/destroy、NVML/`nvidia-smi`和持久性按当前guide写 | driver表异常、重启/reset和监控边界必须保留 |
| M080 | raw MIG migration/checkpoint/preemption | not_found | GH100/MIG factor | 当前资料未证明raw GI state migration、checkpoint/save-restore或general hardware preemption | vGPU/VM迁移和job scheduler不是同一能力 |
| M081 | on-die ECC and NVLink replay | 可直接/条件化写值 | GH100 on-die memory and NVLink4 | L2、L1、all-SM register file支持SECDED；NVLink有error detection和packet replay | external HBM sideband ECC另作产品/package条件 |
| M082 | containment、dynamic page offlining、row remapping | 条件化写值 | Hopper/GA100-aware driver and HBM service flow | Ampere及以后支持error containment、DPO和row-remapping；GH100支持表需固定 | 这些跨越HBM、driver、reset/service，不写成纯die电路事实 |
| M083 | telemetry and Field Diagnostics | 条件化写值 | product/software diagnostic flow | XID、NVML、`nvidia-smi`、SMBPBI、InfoROM和Field Diagnostics按各自层级记录 | 不等于公开BIST结构 |
| M084 | BIST structure | not_found | GH100 die | 未找到BIST block、coverage或test path | diagnostics/telemetry不能替代 |
| M085 | general checkpoint/restart | not_found | GH100 die/raw job state | 未找到general chip/job checkpoint-restart mechanism | system trainer checkpoint和VM suspend/resume是上层行为 |

## 6. 实测、经济性和派生指标

| ID | 资料卡项 | 当前裁决 | target | 可写内容或缺口 | 证据与边界 |
|---|---|---|---|---|---|
| M086 | workload latency | not_found | full GH100 die | 未找到full 144-SM GH100、完整condition set的workload latency | H100/H800/DGX/Grace Hopper结果均为wrong subject或需独立条件化 |
| M087 | workload throughput | not_found | full GH100 die | 未找到full GH100 workload throughput | 厂商H100 benchmark和MLPerf系统结果不下放 |
| M088 | measured workload power | not_found | full GH100 die | TDP不是workload power；无die-only测量 | card/module/system wall power不下放 |
| M089 | energy per token | not_found | full GH100 die | 无同scope能量、token、模型阶段和统计条件 | 不从TDP与吞吐拼接 |
| M090 | tokens per joule | not_found | full GH100 die | 无direct token/J或可合法组合的同scope输入 | 不对缺失量取倒数 |
| M091 | benchmark utilization | not_found | full GH100 die | 未找到MFU/HFU/MBU/scaling efficiency的full-design workload值 | microbenchmark peak ratio不是workload utilization |
| M092 | published price | not_found | GH100 die | 未找到standalone GH100 die MSRP/list price | H100 card、cloud、DGX和reseller价格均为wrong subject |
| M093 | capacity/compute | not_found | GH100 derived | 缺同对象external-memory capacity和absolute precision peak | 不混用H100 80GB与full 144-SM设计 |
| M094 | specified compute/bandwidth | not_found | GH100 derived | 缺full-design absolute compute与HBM nameplate bandwidth | NVLink带宽不能替代memory bandwidth |
| M095 | sustained compute/bandwidth | not_found | GH100 derived | 无same-object sustained compute和memory bandwidth | H800微基准需条件化，不能作为full die比值 |
| M096 | interconnect/compute and movement/matrix | not_found | GH100 derived | NVLink侧可闭合，但缺full-design compute；TMA也无same-scope公开吞吐 | 不把相对倍数、latency或systemaggregate拼成比值 |

## 7. 当前计数与待复核点

本工作稿已经逐项列出 96 个主字段，但数值路径的 132 个 cell 尚未完成逐格裁决，因此不能先报总计或声称内容验收完成。待合并的四类证据是：核心白皮书/Hot Chips/IEEE逐页精读、H800两版独立微基准、软件/MIG/RAS定向资料，以及 PTX/Transformer Engine 的精度语义。合并后必须机械核对主字段=96、precision cell=132、总单元=228，并给出五种状态的准确分布。

当前最重要的对象边界有三条。第一，full GH100 的 144 SM、60 MB L2、12 memory controller和18 NVLink block可以写，H100 SXM5的132 SM、50 MB L2、80GB HBM3、700W和产品峰值不能下放。第二，TMA、cluster、DSM、DPX、WGMMA、Transformer Engine和MIG需要区分Hopper architecture、GH100实现、H100产品以及软件版本。第三，模型、batch、上下文、MoE All-to-All与KV Cache迁移量只进入实测条件，不能成为本矩阵的芯片属性。

