# GA100 事实冻结前覆盖矩阵与对象边界

> 子任务：`r1_ga100_07_fact_coverage_map`  
> 状态：已完成覆盖和主体裁决，待总控复核  
> 目标对象：`OBJ-NVIDIA-GA100-DIE`，`object_type=die`  
> 截止日：2026-08-21  
> 写入边界：只新增本报告和同名 CSV；未修改正式 CSV、资料卡、来源表、选择运行、进度或总控文档

## 冻结口径

GA100 工作包的芯片主体应当是 full GA100 physical die design。白皮书明确区分 full GA100 和 A100 implementation，因此 128 SM、8192 FP32 CUDA Core、512 Tensor Core 和 12 个 512-bit memory controller 可以在 `full_implementation` 条件下作为 GA100 直接候选。108 SM、6912 FP32 CUDA Core、432 Tensor Core、10 个启用的 memory controller 属于 A100 enabled implementation，不与 full design 构成冲突，也不得覆盖前一组数值。

`OBJ-NVIDIA-GA100-DIE implements_architecture OBJ-NVIDIA-AMPERE-ARCH` 是必需的证据关系。Ampere 的执行模型、Tensor Core 数值路径、structured sparse MMA、asynchronous copy/barrier、L1/shared memory 管理和 NVLink 3 协议仍归架构对象。GA100 卡可通过关系阅读，不再生成同义的 die 事实。现有 Ampere 正式事实还有字段误用和定位问题，必须先完成 `r1_ga100_06_ampere_formal_fact_repair_audit.md` 提出的修复，才能用作冻结后的架构投影。

本轮没有找到一手资料明确声明某个 GA100 字段“不公开”，因而矩阵不把单纯缺少定值标为 `not_public`。已经覆盖完整计划阅读范围、仍无合格证据的项目建议 `not_found`；活文档尚未固定、对象关系未建或条件不足的项目保留 `pending_verification`。正式写入 `not_found` 前仍需生成对应 `search_id`。

## 对象与标识裁决

| 对象或关系 | 冻结前裁决 | 全库检查结果 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE` | 建议新建的冻结芯片对象，显示名 `NVIDIA GA100 die` | 正式 `数据/` 与 `最小参考资料库/` 的主键列中未出现；只在既有交接的拟议文本中出现，不得声称已是正式对象 |
| `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | 建议新建，方向为 GA100 die 到 `OBJ-NVIDIA-AMPERE-ARCH` | 正式表主键列中未出现；只在既有交接建议中出现 |
| `CAND-R1-GA100-01` 至 `CAND-R1-GA100-12` | 已有来源盘点行标识，本轮只引用 | 它们不是正式 `source_id`，不作新 ID 预留 |

矩阵没有为 GA100 SM、memory controller、link、capability 或 condition set 预造新主键。CSV 中对这些目标使用“候选组件”、“候选链路”或“A100 实测对象”等描述，由总控在正式 staging 中统一分配 ID。

## 0.3 领域覆盖结果

| 资料卡领域 | 可冻结内容 | 必须保留的边界 | 冻结前状态 |
|---|---|---|---|
| 产品身份 | GA100 名称、NVIDIA、`die`、Ampere 关系 | A100 发布、SKU、产品定位不自动成为 die 身份 | `partial`；对象和关系尚未正式建立 |
| 物理实现 | TSMC N7、826 mm²、54.2 billion transistors；full GA100 资源用作组件事实 | HBM stack、SXM/PCIe、250/300/400 W、冷却和封装是上层产品值 | `partial` |
| 计算资源 | full design 的 GPC/TPC/SM、FP32 Core、Tensor Core 数量；Figure 7 的 GA100 SM 结构 | A100 108 SM 与产品聚合峰值只能带 `A100_enabled` 条件 | `partial` |
| 数值格式 | 经修复的 Ampere precision path 可经关系复用 | 物理累加位宽、乘积编码、舍入和 subnormal 处理仍无定值 | `partial` |
| 存储层次 | GA100 SM 内 register file 和 192 KB combined L1/shared；Ampere async copy 和管理机制 | 40 MB L2、5120 B/clk、HBM 容量和带宽绑定 A100 实现或产品 | `partial` |
| 互联 | Ampere NVLink 3 协议与链路机制；full GA100 图示 PCIe Gen4 host interface | 12 links、300 GB/s per direction、600 GB/s bidirectional 先保留 A100 设备条件；DGX/NVSwitch 拓扑排除 | `partial` |
| 特殊能力 | GA100 Optical Flow Accelerator 可直接接受；sparse MMA、async copy/barrier、warp reduce 经架构关系复用 | Attention、Softmax、Top-k、MoE route/dispatch、collective offload 和 KV Cache manager 没有专用硬件证据 | `partial` |
| 软件 | CUDA 11、PTX 7.x、`sm_80` 的文档支持 | 只到 `documented_supported`；CUDA 8.0 表述与开发文档不一致 | `partial` |
| 调度与服务机制 | GI/CI 资源边界、MIG mode 和空闲时重配置 | 7-way/4-way、profile 几何、P2P/NCCL 支持均绑定产品和软件版本 | `partial` |
| 可靠性 | GA100 error containment、row remapping、dynamic page offlining；A100 实现的 SECDED 范围 | DPO 和 row remap 是 GPU、HBM、driver 与 reset 流程的组合能力；Blackwell RAS Repair 明确排除 | `partial` |
| 实测指标 | 2022 年 A100 微基准的 instruction/memory cycles；2024 年 A100 SXM4 80GB 随机访存观察 | 必须保留 A100 SKU 不完整、software/frequency 缺失、access pattern 和 author inference；不作 GA100 无条件属性 | `partial` |
| 经济性 | 无 die 级公开单价 | 不用 A100 卡、云实例或 DGX/HGX 价格反推 | `not_applicable` 候选 |
| 来源证据 | 白皮书已有正式架构来源链；ISSCC、MIG、RAS、CUDA/PTX 和微基准有候选职责 | 除白皮书外的候选尚未正式登记，活文档尚未形成项目内固定快照 | `needs_review` |

完整的 field 级结果在 `r1_ga100_07_fact_coverage_map.csv`。CSV 覆盖 `fields.csv` 的全部 141 个 `field_id`，对需要同时保存正向值、条件化观察和排除值的字段使用多行表达。

## 需要单独锁住的边界

### full GA100 与 A100 enabled implementation

full GA100 可用的直接数值是 8 GPC、64 TPC、128 SM、8192 FP32 CUDA Core、512 Tensor Core 和 12 个 512-bit memory controller。A100 产品值包括 7 GPC、108 SM、6912 FP32 CUDA Core、432 Tensor Core、10 个启用的 memory controller、40 MB L2、40/80 GB HBM、1410 MHz 及各 precision 的聚合峰值。后一组可用于说明 GA100 设计如何在 A100 中启用，但必须有 A100 实现主体或明确的 `enabled_implementation` 条件。

### MIG 和 RAS

MIG 的硬件分区机制可与 GA100 绑定，但 GI 是 memory QoS 和故障隔离的直接证据边界，CI 只获得专用 SM slices，同一 GI 内仍共享 memory slices 和 engines。A100 的 7-way 上限、A30 的 4-way 上限和各 profile 的容量与 engine 数量均属于产品配置。当前 MIG guide 没有证明通用 checkpoint/restart、live migration、GI 等于 SR-IOV VF，也没有证明 CI 具有完整地址空间和 memory QoS 隔离。

GA100 的 RAS 正向能力包括 error containment、row remapping 和 dynamic page offlining。Row remapping 使用 HBM/DRAM spare row 并需要 reset 生效；DPO 由 driver 定位 framebuffer page 并排除后续分配。二者都不是纯 die 内自治修复。R595 对 GA100 的 `RAS Repair for GPU Memory` 未标记支持，DRAM channel swap、L2 slice swap 和 XID 160 repair 不进入 GA100 正向事实。

### NVLink PHY、CUDA/PTX 和微基准

NVLink 3 协议、per-signal-pair 速率、per-link per-direction 口径和 error detection/replay 应当放在架构或 link 主体。12 links、300 GB/s each direction 和 600 GB/s bidirectional aggregate 有明确的 A100 device 语境，full GA100 的物理端点数仍需更直接的文字证据。ISSCC 的 NRZ、无 FEC、BER 和 PRML/Viterbi 是 NVLink3 LR PHY 细节，不是 GA100 全芯片 RAS。

CUDA/PTX 可以支持 SIMT、`cp.async`、`mbarrier`、`mma.sp` 和 datatype-specific sparse metadata，证据层级是公开机器模型、虚拟 ISA 和文档支持。这些资料不公开 scheduler RTL、native opcode、Tensor Core physical array、sparse selector RTL、copy-engine 数量或持续性能。ISSCC 中的 `CUDA 8.0` 与 CUDA 11.0/PTX 7.0 开发文档不一致，不采用这个软件版本值；“将 Compute Capability 8.0 误写为 CUDA 8.0”只能作为推断。

2022 年微基准只能表达“在未解决具体 SKU 的 A100 产品上测得”。Instruction cycles、L1/L2/shared-memory cycles 与 WMMA/SASS Tile 要保留 dependency、layout、cache operator、未报告的 CUDA/driver/frequency 和周期单位。Table III 的 `GB/s` 与官方 TFLOPS/TOPS 数字不同口径，在作者或最终版本没有澄清前不代为修正。2024 年来源只支持 A100 SXM4 80GB 的条件化随机访存现象；约 64 GB cliff 和 group-to-chunk 规避效果是观察，“每个 group 有独立 64 GB TLB”是作者推断。

## 明确排除的上层值和负载变量

| 类型 | 不进入 GA100 die 无条件事实的内容 | 可保留位置 |
|---|---|---|
| A100 启用实现 | 108 SM、6912 FP32 CUDA Core、432 Tensor Core、10 个启用 memory controller、40 MB L2、1410 MHz 和产品峰值 | A100 实现对象或带 `A100_enabled` 条件的观察 |
| 模组与卡 | 40/80 GB HBM2/HBM2e、5 个 active stack、1555/1935/2039 GB/s、SXM4/PCIe、250/300/400 W、冷却和卡时钟 | 后续上层产品对象 |
| 系统 | DGX/HGX 的 GPU/NVSwitch 数、fat-tree 或 NVSwitch 拓扑、系统聚合带宽、InfiniBand/Ethernet 和系统功耗 | 关系背景或 system 对象 |
| 价格 | A100 采购价、云实例价、DGX/HGX 报价和二手价 | 具体 card/cloud/system economics |
| 负载与测量条件 | 模型、training/prefill/decode、batch、sequence/context/input/output length、并发、请求率、设备数、并行方式、MoE All-to-All 量、KV Cache 容量或迁移量 | `condition-sets.csv` 或后续 workload mapping |
| 测试者选择 | 128/256/512-byte warp access、random window、cache operator、layout、dependency chain、graph topology | 对应实测 `condition_set_id` |

## 冲突和缺口处理

54B 与 54.2B、1.56 TB/s 与 1555 GB/s 是精度或舍入差异，后一组还是 A100 HBM 产品口径，不登记为未解决冲突。128 与 108 SM、12 与 10 个 memory controller、40 GB 与 80 GB、7-way 与 4-way MIG 也都有 full design、enabled implementation 或 product profile 差异，不通过选取其中一个值“解决”。

需要保留冲突记录的项目有三类：ISSCC `CUDA 8.0` 与 CUDA 11.0/PTX 7.0 开发文档不一致；当前 MIG guide 的 A100/A30 与 H100/H200 最低 driver 表存在行顺序异常；2022 微基准 Table III 以 `GB/s` 标记与官方 TFLOPS/TOPS 数值相同的聚合吞吐。前两类分别阻止软件版本和最低 driver 定值，第三类阻止把作者单位静默改成 FLOP/s 或 OP/s。

## 交接与验证

本轮写入：

- `审计/子代理交接/r1_ga100_07_fact_coverage_map.md`
- `审计/子代理交接/r1_ga100_07_fact_coverage_map.csv`

总控正式 staging 前需先完成 Ampere 事实修复，再以同一事务建立 GA100 die 和 `implements_architecture` 关系。随后按 CSV 中的 `target_kind`、`decision` 和 `condition_scope` 生成组件、链路、精度路径、字段要求和来源断言。任何 `not_found` 正式化都要先补 `search_id`，任何实测都要有完整或明确标注缺失的 `condition_set_id`。

已做的只读检查包括：字段注册表 141 个 `field_id` 与 CSV 唯一 field 集合的全覆盖比对；输出 CSV 的 UTF-8 解析、必需列、行宽和受控决策值检查；建议对象与关系 ID 的全库主键查重。当前 macOS 环境没有可用的 PowerShell 硬门，本轮也未修改正式结构化数据，因而未运行 `Validate-ResearchData.ps1`。

`report-humanizer` 机器扫描返回 `No machine-detectable AI tells found`。人工逆向复读检查了标题、各节首段、表格引导、边界转场和结尾，没有发现需要继续修改的模板化表述。项目没有提供同类人工报告样本，剩余表达风险是无法做样本文风对照；这不影响对象、字段和证据范围的裁决。
