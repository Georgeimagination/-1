# NVIDIA GH100 核心资料精读交接

> 子任务：`gh100_core_sources`  
> 状态：核心证据层完成，待总控复核  
> 对象：冻结名单中的 `NVIDIA GH100 die`，共享设计组 `NV-GH100`  
> 资料截止：2026-08-21  
> 写入边界：只新增本交接文件；未修改正式 CSV、进度、资料卡或其他代理文件  
> 检索边界：只读现有本地语料，没有联网扩源

## 交付范围和对象边界

冻结对象是完整 GH100 裸片设计，不是 H100 SXM5 模组、H100 PCIe/NVL 产品、Grace Hopper 模组，也不是 Hopper 架构代际。五份核心资料经常在同一段里交替使用 `GH100 GPU`、`H100 GPU` 和 `Hopper architecture`。本交接按原文主语、图表列名和物理层级拆开，后续不能因为这些对象共享硅实现就互相下放数值。

这批资料对完整 GH100 裸片的直接证据集中在 NVIDIA H100 Architecture Whitepaper v1.04 的 pp.17-21。可直接确认 TSMC 4N、800 亿晶体管、814 mm²、完整设计的 8 个 GPC、72 个 TPC、144 个 SM、18,432 个 FP32 CUDA Core、576 个第四代 Tensor Core、12 个 512-bit memory controller、60 MB L2，以及完整框图中的 PCIe 5.0 host interface 和 18 个 NVLink 端点。GPC（GPU Processing Cluster）是 GPU 处理集群，TPC（Texture Processing Cluster）是纹理处理集群，SM（Streaming Multiprocessor）是流式多处理器。

H100 SXM5 的 132 SM、50 MB L2、80 GB HBM3、3.35 TB/s、700 W、1,830/1,980 MHz 和整卡峰值属于启用后的产品配置。H100 PCIe 与 H100 NVL 还有另一组启用数量、显存、功率和 NVLink 值。它们可以说明 GH100 设计如何被裁剪和产品化，不能覆盖完整 GH100 的物理上限。

Hopper 的 Thread Block Cluster、Distributed Shared Memory、Tensor Memory Accelerator、异步事务屏障、DPX 指令、FP8 数值路径、Transformer Engine、inline compression 和第四代 NVLink 协议属于架构机制。只有白皮书的 GH100 框图或明确的 GH100 主语把机制落到裸片结构时，才可建立 GH100 组件事实；其余机制应由 `implements_architecture` 关系复用。现有正式库只有 H100 SXM5 到 Hopper、H100 SXM5 到 GH100 的关系，尚未看到 GH100 die 到 Hopper architecture 的正式关系，后续总控需要补裁决，不能复制一套 Hopper 文本事实到 GH100 对象。

## 来源身份、版本和阅读范围

下表的页数均按 PDF 物理页。白皮书、数据手册的物理页与页脚页码一致；Tuning Guide 和 IEEE Micro 另列文内页码，避免后续定位偏移。

| 代号 | 正式来源标识 | 固定本地文件 | 页数与实际阅读 | SHA-256 | 主要证据职责 |
|---|---|---|---:|---|---|
| WP104 | `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf` | 71 页；阅读 PDF pp.1-71 | `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27` | 完整 GH100 物理设计、H100 启用配置、SM、存储、互联、安全与固定功能 |
| HC34 | `SRC-NVIDIA-H100-HOTCHIPS34-2022` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_Hopper_H100_GPU_HotChips34.pdf` | 46 页；阅读 PDF pp.1-46 | `2b974db4a313e255ee4e5885a3dd01424e0723fd5c89163aee42ae4e1bc75c5c` | 发布期架构演示、每 SM Tensor Core MAC/cycle、异步执行、初始 HBM 版本 |
| DS24 | `SRC-NVIDIA-H100-DATASHEET-20240924` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2024_NVIDIA_H100_Tensor_Core_GPU_Datasheet_2430615.pdf` | 3 页；阅读 PDF pp.1-3 | `17494a1792c15c55bae2453305e265ad508987b474e9235ecbc6f7c815399b98` | 2024 H100 SXM 和 H100 NVL 产品规格，不直接支持完整 GH100 数量 |
| TG133 | `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2026_NVIDIA_CUDA_Hopper_Tuning_Guide_13.3.pdf` | 22 页；阅读 PDF pp.1-22 | `25c37c679b059681cc95fc5affe5f1797afee86c13c460d9069c8366a6e5d6d4` | CUDA 13.3 下 Hopper/H100 的可编程限制、API 语义、占用率和数据搬运细节 |
| IEEE23 | `SRC-NVIDIA-H100-IEEE-MICRO-2023` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2023_NVIDIA_Hopper_H100_GPU_IEEE_Micro.pdf` | 9 页；阅读 PDF pp.1-9，即期刊 pp.9-17 | `234570fa695217139fc891bfb22a8ed252eb8b4de40030cb32c529283db06fbd` | NVIDIA 作者的成文架构说明、Thread Block Reconfiguration、FP8 证据条件 |

WP104 封面标为 v1.04，并注明包含最终 GPU/内存时钟与最终 TFLOPS；PDF 元数据创建于 2023-05-05，版权页为 2023。文件名中的 2022 反映资料归档年份，不能用来替代正式发布日期。HC34 封面日期为 2022 年 8 月。IEEE23 的正式发布日期为 2023-03-14，当前版本日期为 2023-05-15，见 PDF p.1、期刊 p.9。TG133 封面为 Release 13.3、2026-06-25，文档内部 revision history 仍写 Version 1.0 initial release，见 PDF p.19、文内 p.15。

视觉核验覆盖 WP104 Figure 6、Figure 7、Table 3 两页，HC34 的每 SM Tensor Core 表，DS24 技术规格表，以及 IEEE23 Figure 6-8。文本抽取只用于检索，框图数量、表格列归属、脚注和图中测试条件以渲染页为准。

## 完整 GH100 die 的直接事实

### 物理实现和顶层组织

| 编号 | 原文事实 | 精确定位 | 建议字段或实体 | 使用边界 |
|---|---|---|---|---|
| DIE-01 | 原文称 “The full GH100 GPU that powers the H100 GPU”，把 GH100 定义为承载 H100 的完整裸片设计。 | WP104 p.17，`NVIDIA H100 GPU Architecture In-Depth` 末段 | GH100 对象身份；补 `implements_architecture` 关系的证据 | H100 是产品语境，GH100 是本轮裸片主体。 |
| DIE-02 | TSMC 为 NVIDIA 定制的 4N 工艺，800 亿晶体管，814 mm²。 | WP104 p.17；Table 3 pp.39-40 只作同源复核 | `FIELD-PHY-FOUNDRY`、`FIELD-PHY-PROCESS`、`FIELD-PHY-TRANSISTORS`、`FIELD-PHY-DIE-AREA` | 可直接归属 `OBJ-NVIDIA-GH100-DIE`。现有三条正式事实未单列 foundry，后续可补 TSMC。 |
| DIE-03 | 完整实现有 8 GPC、72 TPC，每 GPC 9 TPC，每 TPC 2 SM，共 144 SM。 | WP104 p.18；Figure 6 p.19 | GPC、TPC、SM component 的 `FIELD-COMP-UNIT-COUNT` | 这是 physical/full implementation；H100 SXM5 的 66 TPC/132 SM 和 PCIe 的 57 TPC/114 SM是启用配置。 |
| DIE-04 | 每 SM 128 个 FP32 CUDA Core，完整设计 18,432 个；每 SM 4 个第四代 Tensor Core，完整设计 576 个。 | WP104 p.18；Figure 7 p.21 视觉复核每 SM 4 个 Tensor Core | 计算组件数量 | 总数可直接使用，不需要从 H100 SKU 反推。 |
| DIE-05 | 完整实现列出 12 个 512-bit memory controller 和 60 MB L2。 | WP104 p.18；Figure 6 p.19 | memory-controller component 数量、L2 component capacity | 12 个 controller 属于裸片。原文同列的 6 个 HBM3/HBM2e stack 位于封装周边，不能登记为 die 内存堆叠事实。不得静默把 `12 x 512-bit` 派生成 6,144-bit 总接口。 |
| DIE-06 | Figure 6 的完整 GH100 框图显示 PCIe 5.0 host interface、GigaThread Engine with MIG Control、两大片 L2、6 组 HBM site/12 个 memory controller，以及底边 18 个 NVLink block。 | WP104 Figure 6 p.19，视觉核验 | PCIe/NVLink link 实体、MIG control component 候选 | 图能证明物理结构和 block 数，不能单独证明有效载荷、持续带宽、产品启用状态或协议软件成熟度。 |
| DIE-07 | Figure 6 同时显示 8 个 GPC 的组织；每个 GPC 由 9 个 TPC 构成，每个 TPC 含 2 个 SM。 | WP104 Figure 6 p.19 | 层级关系与组件局部性 | 适合形成 component-to-object 层级说明。不要把 GPC 内 SM 的共享资源求和解释为统一池。 |

白皮书 p.18 把 “6 HBM3 or HBM2e stacks” 写在 full implementation 列表里，容易误读成裸片属性。白皮书 p.36 明确 HBM stack 与 GPU 位于同一 physical package，Figure 6 p.19 也把 HBM 画在计算裸片边缘之外。GH100 die 可以记录 12 个 memory controller；HBM 堆叠数量、容量、数据率、封装布线和带宽应挂到相应 H100 模组或封装对象。

### GH100 SM 组件

| 编号 | 原文事实 | 精确定位 | 建议字段或实体 | 使用边界 |
|---|---|---|---|---|
| SM-01 | GH100 SM 由 4 个 processing partition 构成。每个 partition 有 L0 instruction cache、一个 32 thread/clock warp scheduler、一个 32 thread/clock dispatch unit、16,384 x 32-bit register file 和一个第四代 Tensor Core；SM 顶部有 L1 instruction cache。 | WP104 Figure 7 p.21，视觉核验 | scheduler、dispatch、register、Tensor Core component；控制与发射字段 | 图可安全支持 4 个 partition、4 个 scheduler/dispatch、4 组 RF 和 4 个 Tensor Core。小型 ALU 方格应结合 Table 3，不能按图形像素自行计数。 |
| SM-02 | 每 SM 有 65,536 个 32-bit register，即 256 KiB，最大 255 register/thread。 | WP104 Table 3 pp.39-40、Table 4 p.41；TG133 PDF p.13、文内 p.9，§4.1.1 | `FIELD-MEM-CAPACITY`、occupancy 条件 | 这是每 SM 分布资源。144 倍汇总不构成统一可寻址寄存器池。 |
| SM-03 | Figure 7 明示每 SM 一个名为 Tensor Memory Accelerator 的横向模块。 | WP104 Figure 7 p.21 | TMA capability 的 `dedicated_physical_module` 候选 | 正文 pp.32-34 又称 TMA 为 unit、硬件负责地址生成和搬运。现有 formal fact 把实现层级留为 `needs_resolution`；从这组一手证据看，`dedicated_physical_module` 比 `configurable_engine` 更贴近原文，但仍须总控按正式枚举复核。 |
| SM-04 | 每 SM 的 combined L1 data cache/shared memory 物理容量为 256 KB，共享内存 carveout 最多 228 KB；H100 单个 thread block 最多可寻址 227 KB，因为 CUDA 为每 block 保留 1 KB。 | WP104 p.22、p.27、Figure 7 p.21；TG133 PDF pp.13、16，文内 pp.9、12，§§4.1.1、4.2.4 | combined capacity、shared carveout、per-block usable capacity | 256 KB 与 228/227 KB 不能相加。TG133 还给出 carveout 取值 0、8、16、32、64、100、132、164、196、228 KB；静态 shared allocation 仍限 48 KB，超过需显式 opt-in。 |
| SM-05 | H100/CC 9.0 的软件可见上限为 64 warps/SM、2,048 threads/SM、32 blocks/SM、1,024 threads/block。 | WP104 Table 4 p.41；TG133 PDF p.13、文内 p.9，§4.1.1 | `FIELD-COMP-CONCURRENCY`、利用率限制 | 这是 H100 device/Compute Capability 9.0 的运行时上限，可作为 GH100 软件暴露配置候选，不要提升为所有 Hopper 实现永远相同的物理常数。 |
| SM-06 | Table 3 给出 H100 SM 每 SM 128 FP32 Core、64 FP64 Core、64 INT32 Core、4 Tensor Core。Figure 7 的单元分区与这些数目一致。 | WP104 Figure 7 p.21；Table 3 p.39 | SM 内 component count | Table 3 的列是 H100 SXM5/PCIe，但每 SM 数量一致，且 Figure 7 标为 GH100 SM。可归入 GH100 SM；产品每 GPU 总数仍按启用 SM 数记录。 |
| SM-07 | 每个 SM 内的 L1 和 register file，以及 GPU 共享的 L2，均受 SECDED ECC 保护。SECDED（Single-Error Correcting, Double-Error Detecting）表示单错纠正、双错检测。 | WP104 p.38，`ECC Memory Resiliency` | `FIELD-RAS-ECC`、`FIELD-RAS-PROTECTION-SCOPE` | 原文主语是 H100；这些结构位于 GH100 内部，可作为 die 组件保护候选。不要扩写为所有计算状态、控制状态和安全状态都受 SECDED。 |

### 每 SM 计算率和数值路径

HC34 的表按每 SM、每时钟给出 Tensor Core MAC 数。MAC（multiply-accumulate）表示乘加，不能在没有计数规则时直接写成两倍 FLOP。稀疏列是结构化稀疏下的等效 MAC 率，不代表物理乘法器数量翻倍。

| 格式 | H100 SM dense MAC/clock | H100 SM sparse effective MAC/clock | 精确定位 | GH100 用法 |
|---|---:|---:|---|---|
| FP64 | 128 | 未给稀疏值 | HC34 PDF p.33；该格排版为 `0128`，同表 2x 列与 A100 的 64 表明数值语义为 128 | 可作为 GH100 SM 路径候选；保留原版排版异常，不把前导 0 当新数值。 |
| TF32 | 1,024 | 2,048 | HC34 PDF p.33；IEEE23 PDF p.6、期刊 p.14 | 可作为每 SM、每时钟事实；不推导完整 144 SM 总 TFLOP/s，因为 full die clock 未公开。 |
| FP16 | 2,048 | 4,096 | HC34 PDF p.33；IEEE23 PDF p.6、期刊 p.14 | 同上。 |
| BF16 | 2,048 | 4,096 | HC34 PDF p.33；IEEE23 PDF p.6、期刊 p.14 | 同上。 |
| INT8 | 4,096 | 8,192 | HC34 PDF p.33；IEEE23 PDF p.6、期刊 p.14 | 单位是 MAC/clock/SM，产品聚合表使用 TOPS。 |
| FP8 | 4,096 | 8,192 | HC34 PDF p.33；IEEE23 PDF pp.6-7、期刊 pp.14-15 说明 FP8 为 FP16/BF16 的 2x | 只支持 E4M3/E5M2 相关输入语义；不要把 sparse effective 值解释为稠密物理执行率。 |

WP104 p.22 和 HC34 p.33 还声称第四代 Tensor Core 的 operand delivery power 最多降低 30%。这是厂商的相对上限，没有电压、频率、操作数分布和测量方法，适合放在 capability limitation 或相对能效说明中，不适合登记为 GH100 固定功耗值。

FP8 直接支持 E4M3 和 E5M2 两种输入编码。E4M3 为 1 sign、4 exponent、3 mantissa，E5M2 为 1 sign、5 exponent、2 mantissa；FP8 matrix multiply 可以累加到 FP16 或 FP32。定位为 WP104 pp.23-24，HC34 pp.35-36，IEEE23 PDF pp.6-7、期刊 pp.14-15。来源没有公开 Tensor Core 的物理阵列形状、内部乘积编码、metadata decoder、selector RTL、物理累加位宽、舍入模式、subnormal 处理或饱和规则。这些字段应保留缺失状态。

## 只属于 H100 enabled configuration、产品或模组的事实

### 白皮书 v1.04 中的 H100 配置

| 对象 | 启用资源和物理配置 | 频率、峰值与功率 | 定位和边界 |
|---|---|---|---|
| H100 SXM5 | 8 GPC、66 TPC、132 SM、16,896 FP32 Core、528 Tensor Core、5 个 HBM3 stack、10 个 512-bit memory controller、80 GB HBM3、50 MB L2。 | FP8/FP16/BF16/TF32 Tensor 路径 boost 1,830 MHz；FP64 Tensor、FP32/FP64 non-Tensor 1,980 MHz；TDP 700 W。 | WP104 p.18；Tables 1、3 pp.20、39-40。全部是 SXM5 产品/模组值，不能写到完整 GH100。 |
| H100 PCIe Gen 5 | 7 或 8 GPC、57 TPC、114 SM、14,592 FP32 Core、456 Tensor Core、5 个 HBM2e stack、10 个 512-bit memory controller、80 GB HBM2e、50 MB L2。 | 对应两组 boost 为 1,620/1,755 MHz；TDP 350 W。 | WP104 p.18；Tables 1、3 pp.20、39-40。p.15 另有单卡应用性能与功耗的厂商相对比较，只能作为条件化产品结果。 |
| H100 SXM5 Tensor 峰值 | TF32 494.7/989.4 TFLOP/s，FP16 989.4/1,978.9，BF16 989.4/1,978.9，FP8 1,978.9/3,957.8，INT8 1,978.9/3,957.8 TOPS，FP64 Tensor 66.9 TFLOP/s。斜杠后为结构化稀疏等效值。 | 理论峰值，基于对应 boost clock。 | WP104 Tables 1、3 pp.20、39-40。完整 GH100 既没有公开 full-die clock，也没有 full-die aggregate peak，不能按 144/132 比例外推。 |
| H100 SXM5 non-Tensor 峰值 | FP16 133.8、BF16 133.8、FP32 66.9、FP64 33.5 TFLOP/s，INT32 33.5 TOPS。 | 理论峰值；WP104 未把 FP16/BF16/INT32 三行逐项绑定到某一 boost clock 行。 | WP104 Table 3 pp.39-40。保留频率条件缺口。 |
| H100 SXM5 HBM | 5,120-bit HBM3、80 GB、2,619 MHz DDR、3,352 GB/s。 | 表内仍有 `Not Finalized for H100` 旧标签。 | WP104 Table 3 p.40。该值属于 SXM5 的 HBM subsystem，不属于 die。 |
| H100 PCIe HBM | 5,120-bit HBM2e、80 GB、1,593 MHz DDR、2,039 GB/s。 | 同一表内的产品规格。 | WP104 Table 3 p.40。 |

WP104 p.40 的注释说明 H100/A100 数据中心产品不含 display connector、RT Core 和 NVENC encoder。主语是 H100 产品，不能仅凭该注释断言完整 GH100 floorplan 绝无任何未启用逻辑。Figure 6 没有画出这些模块，但框图省略也不等于晶体管级 absence proof。后续若要给 die 登记 `not_applicable`，宜补更直接的芯片论文或官方设计说明。

### 2024 数据手册中的 H100 SXM 与 H100 NVL

DS24 p.2 的星号明确表示表内 TF32、BF16、FP16、FP8 和 INT8 Tensor Core 数值 `With sparsity`。数据手册没有同时给稠密值，不能把星号值复制到 dense 条件。

| 对象 | 当前产品值 | 精确定位 | 使用边界 |
|---|---|---|---|
| H100 SXM | FP64 34 TFLOP/s、FP64 Tensor 67、FP32 67、TF32 sparse 989、BF16/FP16 sparse 1,979、FP8 sparse 3,958 TFLOP/s、INT8 sparse 3,958 TOPS。 | DS24 p.2，`Technical Specifications`，H100 SXM 列与 `*With sparsity` 脚注 | 是 WP104 精确值的显示四舍五入，仍属产品峰值。 |
| H100 SXM | 80 GB、3.35 TB/s、7 NVDEC、7 JPEG engine、最高 700 W configurable、最多 7 MIG，每实例 10 GB、NVLink 900 GB/s、PCIe Gen5 128 GB/s。 | DS24 p.2，H100 SXM 列 | 容量、功率、MIG 切分和总带宽都是产品或模组条件。 |
| H100 NVL | 94 GB HBM3、3.9 TB/s、FP64 Tensor 60 TFLOP/s、FP8 sparse 3,341 TFLOP/s、350-400 W、最多 7 MIG，每实例 12 GB、NVLink 600 GB/s。 | DS24 p.2，H100 NVL 列 | H100 NVL 是 PCIe dual-slot air-cooled 产品，不能与 WP104 的普通 H100 PCIe 80 GB HBM2e 列按“新版覆盖旧版”合并。 |

白皮书 p.15 的普通 H100 PCIe、数据手册 p.2 的 H100 NVL 是不同产品配置。两者的 80 GB HBM2e 与 94 GB HBM3、2.039 TB/s 与 3.9 TB/s、350 W 与 350-400 W 不构成同一 SKU 的版本冲突。

### MIG、安全、媒体和系统边界

MIG（Multi-Instance GPU）指把一颗 GPU 分成隔离实例的多实例技术。H100 SXM5 和 H100 PCIe 最多支持 7 个实例；每实例有独立 crossbar port、L2 bank、memory controller 和 DRAM address bus，Hopper 版本还提供硬件 firewall、每实例 performance monitor、至少一个 NVDEC 和 NVJPG。定位为 WP104 pp.42-44。Figure 6 p.19 能证明完整 GH100 设计有 MIG control；“最多 7 个实例”和每实例容量仍是 H100 启用配置。

H100 产品包含 7 个 NVDEC 视频解码单元和 7 个 single-core NVJPG 引擎，见 WP104 pp.58-59、Tables 5-7，以及 DS24 p.2。解码流数和 JPEG images/s 绑定编码格式、位深、分辨率、压缩比和时钟条件。它们不能当成完整 GH100 物理数量，当前五源没有明确写 “full GH100 contains seven”。

Grace Hopper 的 900 GB/s CPU-GPU coherent link、最高 512 GB LPDDR5/LPDDR5X，DGX H100 的 8 GPU 和 4 NVSwitch，HGX 的四卡/八卡拓扑，NVLink Switch System 的 256 GPU、57.6/70.4 TB/s、1 ExaFLOP，以及 ConnectX/BlueField 网络均位于模组或系统层。定位包括 WP104 pp.9、15-16、47-49、60-62，HC34 pp.40-41，IEEE23 PDF pp.8-9、期刊 pp.16-17。它们只能用于关系和上层背景。

## 只在 Hopper architecture 层成立的机制

### Thread Block Cluster、DSMEM 和异步执行

| 机制 | 原文支持 | 精确定位 | 架构层用法与限制 |
|---|---|---|---|
| Thread Block Cluster | 新增 Threads -> Thread Blocks -> Thread Block Clusters -> Grids 层级。cluster 内 block 保证同时运行，并映射到同一 GPC 的不同 SM；cluster 可为 1D/2D/3D。 | WP104 pp.29-30；HC34 pp.17-19；IEEE23 PDF pp.2-3、期刊 pp.10-11 | 属于 Hopper 编程和硬件局部性机制。运行时调度保证可记录为 control/scheduling，不等于通用作业调度器。 |
| cluster size | Hot Chips/IEEE 写最多 16 block。CUDA 13.3 说明最大 portable size 为 8，H100 可设置 `cudaFuncAttributeNonPortableClusterSizeAllowed` opt-in 到 16；更大 cluster 可能降低全 GPU active block 数。 | HC34 p.18；IEEE23 PDF p.3、期刊 p.11；TG133 PDF p.14、文内 p.10，§4.1.3 | 这组表述是 portability 条件补全，不是冲突。正式事实必须同时保存 portable 8 和 H100-specific opt-in 16。 |
| DSMEM | cluster 内 block 可直接 load、store、atomic 和 synchronize 到其他 SM 的 shared memory；地址空间逻辑分布，专用 SM-to-SM network 位于 GPC 内。 | WP104 pp.29-31；HC34 pp.19、28-30；IEEE23 PDF pp.3、6，期刊 pp.11、14 | DSMEM（Distributed Shared Memory）是分布式共享内存，资源仍按 SM 分布，不应求和成统一 shared-memory pool。 |
| DSMEM access guidance | DSMEM 与 L2 access 可同时发生；推荐 32-byte segment 对齐、coalesced access，避免 non-unit stride。 | TG133 PDF p.14、文内 p.10，§4.1.3 | 这是 CUDA 13.3 的编程限制，白皮书未给出。Tuning Guide 因此不再是完整事实集合中的纯冗余来源。 |
| Asynchronous Barrier | Ampere 已有 arrive/wait split barrier。Hopper 让 wait thread 睡眠，增加硬件加速以降低等待开销。 | WP104 pp.33-35；HC34 pp.25-26；IEEE23 PDF p.5、期刊 p.13 | 属于同步机制；没有公开绝对 latency、队列深度或 barrier 数量。 |
| Asynchronous Transaction Barrier | barrier 同时计数 thread arrival 与 memory transaction/byte count，直到两者完成才释放 waiter。 | WP104 pp.34-35；HC34 p.26；IEEE23 PDF p.5、期刊 p.13 | 用于 async copy 和 cluster data exchange，不可泛化为任意事务处理引擎。 |
| Thread Block Reconfiguration | 同一 grid 的不同阶段可调整 SM thread 数和 per-thread RF allocation，让 FFT 各 radix 阶段在 SMEM/DSMEM 中保持数据。 | HC34 pp.21-22；IEEE23 PDF p.4、期刊 p.12 | NVIDIA 作者明确称其为 Hopper capability，但 TG133 没有相应章节、API 或版本约束。当前适合列 `pending_verification` 的架构线索，不能标成 CUDA 13.3 已验证可用。 |

WP104 p.30 给出的 DSMEM 对 global memory 数据交换约 7x，HC34 p.28 和 IEEE23 PDF p.6、期刊 p.14 给出 one-way cluster exchange 的 7x latency reduction。这些都是厂商相对值，缺少消息大小、访问模式、频率和测量方法。可记录为 `relative_only` 的 vendor claim，不能把 7x 当 GH100 固定延迟。

### Tensor Memory Accelerator

TMA（Tensor Memory Accelerator）是 Hopper 的异步张量搬运模块。它支持 global memory 与 shared memory 双向的 1D 到 5D tensor copy，以及同一 cluster 内不同 SM shared memory 之间的 copy。copy descriptor 用维度和 block coordinate 描述搬运，硬件处理 stride、offset、boundary 和 padding；单个 thread 发起后，其余 thread 可以继续计算。定位为 WP104 pp.32-34、HC34 pp.29-30、38、IEEE23 PDF pp.5-8、期刊 pp.13-16、TG133 PDF pp.13-14、文内 pp.9-10，§4.1.2。

TG133 还给出两项白皮书没有讲清的限制。第一，TMA 搬运不使用 register staging，也不消耗 SM instruction 逐元素搬运。第二，从 shared memory 写回 global memory 时，可指定 element-wise add/min/max 和常见类型上的 bitwise and/or reduction。该能力是搬运时归约，不支持由此推断 Softmax、Top-k、MoE routing 或 network collective offload。

### DPX 指令

DPX 是面向 dynamic programming 内循环的融合指令，不是一个可独立计数的专用核。它支持三操作数 max/min、返回 predicate 的 max/min、add 与 max/min 融合，数据类型包括 signed/unsigned 32-bit int、打包 16-bit short 和 `half2`。所有 16-bit short 类型 DPX 指令达到 128 operations/cycle/SM。定位为 WP104 p.27，TG133 PDF p.15、文内 p.11，§4.1.5；HC34 p.5 只列出机制名称。

WP104 和 DS24 的 “up to 7x over A100” 以及 DS24 的 “40x compared to CPUs” 绑定 Smith-Waterman、Floyd-Warshall 等具体算法和 baseline。芯片级事实是指令语义与 16-bit per-SM rate，7x/40x 应进入带条件的厂商 benchmark 或相对性能断言。

### Tensor Core、FP8、稀疏和 Transformer Engine

第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 和 INT8 MMA。MMA（Matrix Multiply-Accumulate）指矩阵乘加。WP104 p.22、HC34 p.33、IEEE23 PDF p.6、期刊 p.14 说明相同旧格式相对 A100 per-SM clock-for-clock 为 2x；FP8 相对 FP16/BF16 再提高 2x。来源只写 fine-grained structured sparsity 或 “one operand is sparse” 并给 2x effective throughput，没有给 N:M 模式、metadata encoding、pruning responsibility 或 selector 实现。不能从其他代 NVIDIA 资料补写为 GH100 的 2:4 物理实现。

Transformer Engine 由 software 与 custom Hopper Tensor Core technology 配合。它按 layer output statistics 和 next-layer precision 需求选择 FP8 或 16-bit target format，计算 scaling factor，再做 recast/format conversion。HC34 p.37 说明用户可启用或关闭，且对 deep-learning framework 透明；WP104 pp.44-46 说明概念流程；DS24 p.3 给出产品简述。原文没有证明一个独立、可枚举的 Transformer 专用核，`configurable_engine` 也可能让读者误以为它是一块独立硬件。更稳妥的结构化方式是拆成 Tensor Core precision path、scaling/conversion capability 和 software binding。

HC34 p.38 的 FP8 training 表与 IEEE23 Figure 8 有重要条件：所有模型是在 A100 上用 “emulated FP8 input/output” 的 pre-silicon/pre-software methodology 训练。该表验证的是数值方法可行性，不是 H100 silicon benchmark。GPT-3、BERT、WMT、WikiText、模型参数量、BLEU、loss 和 perplexity 都是条件集内容，不能写成 GH100 属性。

### 缓存、压缩和内存管理

完整 GH100 有 60 MB L2，H100 enabled products 使用 50 MB。Hopper L2 采用 partitioned crossbar，允许 CUDA 程序控制 data persistence；HBM 与 L2 支持 compression/decompression，见 WP104 pp.36-38。TG133 PDF p.15、文内 p.11，§4.2.3 将 inline compression 的软件语义补充为：按 allocation 请求，硬件在多种算法或不压缩之间自动选择；可压缩数据减少实际传输，从而可能超过名义 global-memory bandwidth；分配的逻辑 footprint 不会缩小，因为数据之后可能变得不可压缩。

Inline compression 不得与结构化稀疏 Tensor Core 混成同一机制，也不能把压缩后的可能带宽提升加到 HBM 名义带宽上。五份资料没有公开压缩算法、压缩比保证、压缩 metadata 容量、持续带宽、L2 port/bank 数、L2 latency 或 L2 byte/cycle。

### NVLink、PCIe 和虚拟化

第四代 NVLink 是 lossless GPU-to-GPU interconnect，带 link-level error detection 和 packet replay。每 link 每方向 25 GB/s，由每方向 2 对 high-speed differential pair 构成；双向每 link 50 GB/s。完整 GH100 Figure 6 显示 18 个 NVLink block，H100 SXM 启用 18 条并给出 900 GB/s 双向聚合。定位为 WP104 pp.47-49、Figure 6 p.19；TG133 PDF pp.16-17、文内 pp.12-13，§4.3。

H100 NVL 只给 600 GB/s，见 DS24 p.2；因此 18 条/900 GB/s 不能无条件下放给所有使用 GH100 的产品。TG133 把 18 links 泛称为 H100 device 值，阅读时必须结合具体 SKU。五份资料没有 NVLink protocol payload、sustained measured bandwidth、单跳 latency、routing table、congestion 和 power 数值。

完整 GH100 Figure 6 显示 PCIe 5.0 host interface；H100 产品实现 PCIe 5.0 x16，厂商口径为每方向 64 GB/s、双向聚合 128 GB/s，并支持 32/64-bit native atomic CAS、exchange、fetch-add 和 SR-IOV。SR-IOV（Single Root Input/Output Virtualization）是单根 I/O 虚拟化。定位为 WP104 pp.49-50。64/128 GB/s 是协议名义口径，不是应用 payload 实测。

NVLink Network 的 Network Address Space、H100 address-translation hardware 和显式 endpoint connection 属于 H100/Hopper 的端点机制，见 WP104 p.47。第三代 NVSwitch 的 multicast、SHARP in-network reduction、all-gather、reduce-scatter 和 broadcast atomic 位于外部 switch，见 WP104 pp.47-48。它们不能登记为 GH100 的 network-offload component，也不能用来证明 die 内有 MoE router。

### 安全和可靠性

WP104 pp.51-57 把下列能力绑定 H100/Hopper：secure boot、measured boot、attestation、on-die Root of Trust、hardware-protected memory region、privileged access-control register、on-die sensor、专用 on-chip security processor，以及 PCIe line-rate AES-GCM 256 encryption/decryption。AES-GCM（Advanced Encryption Standard Galois/Counter Mode）同时保护传输机密性和完整性。安全章节没有逐项标出这些 block 在 full GH100 floorplan 的位置或数量，因此适合作为 H100 implementation/Hopper architecture 机制，暂不形成完整 GH100 component count。

HBM3/HBM2e 使用 sideband SECDED ECC，并支持 boot-time row remapping；L2、L1 和 SM register file 也有 SECDED，见 WP104 pp.37-38。HBM ECC 和 row remapping 属于 H100 package memory subsystem；L1/L2/RF 保护可关联 GH100 内部组件。五份资料没有公开 silent data error detector、compute replay、watchdog、BIST、health telemetry、reset/failure-domain、degraded-mode、checkpoint/restart 的完整机制。MIG performance monitor 不能自动解释为 RAS telemetry。

## 工作负载、测量条件与芯片属性分层

这批资料含有大量训练、推理、HPC 和系统性能图。它们能说明机制的目标场景，但都需要保留 workload、设备数、网络、软件和统计口径。

| 来源位置 | 原始条件 | 可以保留的机制证据 | 不能写成芯片属性的内容 |
|---|---|---|---|
| WP104 Figure 3 pp.8-9；HC34 p.8 | Climate、LQCD、genomics、3D FFT、MT-NLG、GPT-3、DLRM、MoE 等；GPU 数从 8 到 16K，batch 和 latency target 不同，A100/H100 网络分别为 HDR/NDR InfiniBand，部分 H100 加 NVLink Network；结果标 preliminary/projected。 | H100 产品目标覆盖 AI/HPC/data analytics，NVLink Network 支持多节点扩展。 | 2x-30x 不能成为 GH100 固定 speedup；模型大小、batch、MoE expert 数、GPU 数和网络属于 condition set。 |
| DS24 pp.1-2 | GPT-3 175B training、Switch-XXL 395B、Megatron 530B chatbot，输入 128、输出 20、1/1.5/2 s latency target，不同 cluster network。 | H100 产品支持 Transformer Engine、MIG、NVLink。 | 4x、5x、9x、16x、20x、30x 属于模型和系统条件化 vendor benchmark。 |
| WP104 Figure 16 p.31；HC34 p.31；IEEE23 Figure 6，PDF p.6、期刊 p.14 | 64K FFT、Longstaff-Schwartz pricing、histogram with/without cluster；只给 1.7x-2.7x。 | Cluster、DSMEM、TMA 和 async execution 可提升局部数据复用。 | 缺输入规模、kernel、频率、软件版本和统计方法，不可登记为通用芯片性能。 |
| HC34 p.38；IEEE23 Figure 8，PDF p.7、期刊 p.15 | A100 emulated FP8 的 pre-silicon/pre-software 训练；WMT、WikiText、Wikipedia、GPT-3 多尺寸。 | E4M3/E5M2 与 scaling 的算法可行性。 | accuracy/perplexity 不是 H100 实测，也不是 GH100 数值单元无条件精度保证。 |
| WP104 pp.58-59 | NVDEC/NVJPG stream 与 images/s；绑定 H264/HEVC/VP9、bit depth、chroma、1080p、30 fps、JPEG 10:1 compression。 | H100 产品有固定解码引擎及格式支持。 | stream count 与 image throughput 必须进入 condition set；224x224 反而可能低 30%-40%，不能用 1080p 数值外推。 |
| WP104 Appendix C pp.68-70 | Smith-Waterman cell update 和 genomics 数据流程。 | DPX 指令对应 add/min/max 融合。 | genome size、read length、算法 speedup 属于 workload；不能变成 DPX 固定端到端性能。 |

五源内没有可用于完整 GH100 die 的端到端 training time、TTFT、TPOT、goodput、MFU/HFU/MBU、token/J、J/token 或价格。TTFT（Time to First Token）是首 token 时间，TPOT（Time per Output Token）是每输出 token 时间，MFU/HFU/MBU 分别是模型 FLOP、硬件 FLOP 和内存带宽利用率。对应资料卡字段应保持 `pending_verification`，不能用系统投影图补值。

## 版本漂移、表内异常和表面冲突

| 编号 | 资料表述 | 裁决 |
|---|---|---|
| VER-01 HBM bandwidth | HC34 p.6 给 3 TB/s，并写 data rates not finalized。WP104 p.36 写 over 3 TB/s，Figure 21 p.37 仍保留 not finalized；Table 3 p.40 给 3,352 GB/s，但该行标题仍写 `Not Finalized for H100`。WP104 封面又声明 v1.04 包含 final GPU/memory clocks。DS24 p.2 给 3.35 TB/s。IEEE23 PDF p.1、期刊 p.9 写 over 3 TB/s。TG133 PDF p.15、文内 p.11 仍写 up to 3 TB/s。 | 对 H100 SXM 产品采用 DS24 当前 3.35 TB/s；WP104 3,352 GB/s 是精确版本值，HC34 3 TB/s 是发布期值，TG133 是架构开发文档中的保守/陈旧概述。它们都不能成为 GH100 die bandwidth。 |
| VER-02 full die 与 enabled product | WP104 p.18 给 full GH100 144 SM、72 TPC、576 TC、60 MB L2；同页给 H100 SXM5 132/66/528/50 MB 和 PCIe 114/57/456/50 MB。 | 这是 physical design 与启用配置，不是事实冲突。正式数据需要不同 condition/scope，不能选一组覆盖另一组。 |
| VER-03 H100 PCIe 与 H100 NVL | WP104 普通 PCIe 为 80 GB HBM2e、2,039 GB/s、350 W；DS24 H100 NVL 为 94 GB HBM3、3.9 TB/s、350-400 W、600 GB/s NVLink。 | 是不同 SKU/变体。不要用 2024 数据手册把普通 PCIe 记录标为 superseded，除非补到明确的产品生命周期证据。 |
| VER-04 NVLink aggregate | WP104/TG133 对 H100 SXM 写 18 links/900 GB/s；DS24 H100 NVL 写 600 GB/s。 | 产品启用配置不同。Figure 6 支持 full die 有 18 个物理 NVLink block，具体产品总带宽仍绑定 SKU。 |
| VER-05 cluster size | HC34/IEEE23 写最多 16；TG133 写 portable 8、H100 opt-in nonportable 16。 | Tuning Guide 补充 portability 和 occupancy 条件；两值要并列保存。 |
| ERR-01 INT8 unit | WP104 Table 2 p.26 的 H100 INT8 Tensor 行误写 TFLOPS；Table 1 p.20、Table 3 p.39 和 DS24 p.2 都写 TOPS。 | 采用 TOPS，Table 2 只作同源 speedup 图，不作单位证据。 |
| ERR-02 HC34 FP64 cell | HC34 p.33 显示 `0128` MAC/clock/SM。同行 A100 64 与 speedup 2x 表明数值为 128。 | 保留排版异常说明；结构化值可写 128，并由 WP104 每 SM/产品峰值关系和 2x narrative 复核。 |
| VER-06 transistor wording | WP104 明确 80 billion；IEEE23 PDF p.1、期刊 p.9 写 over 80 billion。 | 属于精确值与概述取整差异，不建立冲突组。完整 GH100 使用 WP104 的 80 billion。 |
| VER-07 H100 Tensor peaks | WP104 的 66.9、989.4、1,978.9、3,957.8 与 DS24 的 67、989、1,979、3,958。 | 是显示精度四舍五入。完整 GH100 不使用这些产品 aggregate peaks。 |
| VER-08 DGX/SuperPOD bandwidth | WP104 Figure 26 p.49 写 57.6 TB/s all-to-all，HC34 p.40 与 IEEE23 PDF p.8、期刊 p.16 写 70.4 TB/s bisection。 | 指标名称和可能的系统版本不同，不能互相替换，更不能下放到 die。若后续研究系统对象，应按 all-to-all 与 bisection 两个 metric 拆开。 |

## 按资料卡 0.3 的覆盖和缺口

| 资料卡领域 | 五源覆盖情况 | GH100 内容层处理建议 |
|---|---|---|
| 对象、范围和公开定位 | GH100 名称、与 H100 的关系、Hopper 代际可确认。精确首次发布/可用日期、当前产品状态、公开部署、地区和市场准入未由五源给出。 | identity 保持 `partial`。Hot Chips 日期不能替代产品发布日期。 |
| 物理实现 | 工艺、foundry、面积、晶体管、完整 GPC/TPC/SM、controller、L2 强。封装、interposer、substrate、die clock、die power、cooling 不足。 | physical 为 `partial`。HBM stack 和 TDP 不挂 die。 |
| 计算资源、数据流和控制 | full-die unit count、SM partition、每 SM core count、Tensor MAC/cycle、TMA、cluster 和 barrier 较强。physical Tensor Core array shape、instruction tile、独立 scalar/vector aggregate、端口和并发达峰关系缺失。 | compute 为 `partial`。不要把 CUDA Core 自动分类为跨厂商可比的独立 vector/scalar peak。 |
| 数值格式和稀疏 | FP8 E4M3/E5M2、FP16/FP32 accumulation、FP16/BF16/TF32/FP64/INT8 支持和 sparse effective rate 可确认。product、physical accumulation、rounding、saturation、subnormal、N:M pattern、metadata 未公开。 | numerics 为 `partial`。稀疏模式保持 `pending_verification`，不要借用 Ampere 2:4。 |
| 存储层次和搬运 | 64K register/SM、256 KB combined、228/227 KB shared、60 MB full L2、TMA、residency、compression 可确认。L0/L1/L2/register bandwidth、latency、bank/port、full-die HBM capacity/bandwidth、virtual-memory page behavior 未形成定值。 | memory 为 `partial`。L2 60 MB 与 H100 50 MB 分 scope。 |
| 芯片侧派生指标 | full GH100 没有公开工作频率、HBM product configuration 或 full-die aggregate peak。 | 不计算 full-die FLOP/byte、容量/算力和互联/算力。H100 SXM 派生值不能迁到 GH100。 |
| 特殊机制 | TMA、DPX、DSMEM、sparse Tensor、conversion/scaling、inline compression、media decode 有证据。Attention data move、Softmax、Top-k、sort、MoE route/dispatch、KV Cache manager、transpose/permute 专用单元和 die-local collective offload没有证据。 | special engines 为 `partial`。本次只读五源，未执行该字段的全计划检索，缺失状态暂用 `pending_verification`，不要直接改成 `not_found`。 |
| 互联和拓扑 | full-die PCIe/NVLink block，NVLink protocol behavior、名义 link rate、atomics、SR-IOV 可确认。payload、sustained bandwidth、latency、topology、oversubscription 和 failure reroute 不足。 | interconnect 为 `partial`。NVSwitch 和 SuperPOD 属上层对象。 |
| 软件、调度和虚拟化 | CUDA CC 9.0、cluster launch/occupancy API、TMA API、compression API、L2 persistence、MIG、SR-IOV 有 documented support。framework、compiler/runtime/library 版本全表、runnable verification、job/request scheduler、preemption/QoS 细节不足。 | software/scheduling 为 `partial`。Thread Block Reconfiguration 仍 pending verification。 |
| 可靠性、安全和可维护性 | SECDED、HBM row remap、NVLink detection/replay、secure/measured boot、attestation、RoT、AES-GCM 可确认。SDC detection、compute replay、telemetry/BIST、recovery/degrade、checkpoint/restart 不完整。 | reliability 为 `partial`。安全机制与 RAS 字段分开，不把 confidential computing 宣传语当故障恢复能力。 |
| 实测、利用率和能效 | 有 vendor projected/relative 图、operand-delivery relative power、decode throughput 和数值精度表，但条件不完整或对象是系统/H100 product。 | benchmark 对 GH100 为 `missing_public_data` 或 `partial`，取决于是否接收相对结果；所有数值必须带 condition set。 |
| 经济性 | 五源无裸片或产品公开价格。 | economics 为 `missing_public_data`，本轮不能写 `not_found`，因为未执行价格专项检索。 |
| 来源证据 | 五份均为固定本地 PDF，路径、页数、哈希可复核；WP104、DS24、TG133 已 reviewed，HC34、IEEE23 在正式 sources 表仍为 draft。 | evidence 可先记 `partial`，等待总控完成来源生命周期、反向移除和原子事实独立复核。 |

## 核心来源的去留建议

WP104 对完整 GH100 的物理数量、SM 框图、H100 裁剪配置和机制边界不可替代，应承担 `identity`、`core_spec` 与 `architecture_mechanism`。TG133 提供 portable cluster 8、H100 opt-in 16、DSMEM 访问规则、TMA reduction、DPX type/rate、shared-memory reserve/carveout 和 inline compression footprint 限制，已经不满足“所有事实均被白皮书覆盖”的旧判断；若这些字段进入 GH100/Hopper 内容层，TG133 应作为 `architecture_mechanism` 入选。

HC34 仍有三项独有职责：每 SM 的完整 Tensor Core MAC/cycle 表、2022 发布期 3 TB/s/not-finalized 版本证据，以及 Thread Block Reconfiguration 的原始演示。只要这些事实进入交付，它不能标 `redundant_covered`。IEEE23 大部分内容与 HC34/WP104 重叠，但对 Thread Block Reconfiguration、异步 one-way exchange、每 SM MAC/cycle 和 FP8 数值流程提供了成文交叉确认；若最小集合已经保留 HC34 和 WP104，可把 IEEE23 设为 `redundant_covered`，前提是其引用的每条事实都已有覆盖关系。若下游更重视正式论文而不保留发布期幻灯片，则可以让 IEEE23 承担 architecture mechanism，并单独保留 HC34 的 status-version 与每 SM 表。

DS24 只承担 H100 SXM/NVL 的 2024 产品规格和 HBM 版本漂移，不直接增加完整 GH100 物理事实。GH100 资料卡若只保留 die 与 Hopper mechanism，可把 DS24 放在 `status_version_evidence` 或产品关系背景；不能用它替代 WP104。

## 下游原子抽取建议

优先建立的 GH100 直接候选包括：正式名称和 Hopper 关系、TSMC/4N、800 亿晶体管、814 mm²、8 GPC、72 TPC、144 SM、每 SM 128 FP32/64 FP64/64 INT32/4 Tensor Core、完整 18,432 FP32/576 Tensor Core、12 个 512-bit memory controller、60 MB L2、18 个 NVLink block、PCIe 5.0 host interface、4 个 SM processing partition、64K x 32-bit register/SM、256 KB combined L1/shared、Figure 7 中的 TMA module，以及内部 L1/L2/RF 的 SECDED coverage。每项仍须按 object、component、link、precision path 或 capability 的主体合同拆分，不能全部挂在 GH100 object。

Hopper 关系侧应优先承接：Thread Block Cluster、portable/nonportable size、DSMEM、async barrier、transaction barrier、TMA copy/reduction semantics、DPX instruction semantics 和 16-bit rate、FP8 E4M3/E5M2、FP8 accumulation、structured sparse effective rate、Transformer precision/scaling workflow、L2 persistence、inline compression、NVLink protocol/error behavior、PCIe atomics，以及 documented CUDA APIs。Thread Block Reconfiguration 先建 requirement 或 audit lead，不直接批准为 runnable capability。

明确排除出 GH100 die 直接事实的数值包括：H100 SXM5/PCIe/NVL 的 enabled SM/TPC/Tensor Core、所有产品 boost clock 和 aggregate peak、HBM stack/capacity/data rate/bandwidth、TDP、MIG instance capacity、NVDEC/NVJPG enabled count、NVLink product aggregate、Grace Hopper coherent link、DGX/HGX/SuperPOD/NVSwitch/InfiniBand 系统值和所有 workload speedup。

## 未决事项

1. 正式对象关系缺少 `OBJ-NVIDIA-GH100-DIE implements_architecture OBJ-NVIDIA-HOPPER-ARCH`。总控需要确认并建立唯一关系，避免把 Hopper facts 复制到 GH100。
2. Figure 7 足以证明 TMA 是 GH100 SM 中的 named hardware block，正式 `implementation_level` 仍需在 `dedicated_physical_module` 与现有 provisional `configurable_engine` 之间裁决。
3. full GH100 Figure 6 显示 18 个 NVLink block，但产品启用带宽因 SXM/NVL 而异。结构化时应拆 physical link count、enabled link count、per-link rate 和 product aggregate。
4. full implementation 列表中的 6 个 HBM site 属封装语境；12 个 memory controller 属 die。是否建立 6,144-bit derived interface 需要明确主体和推导用途，当前建议不算。
5. Thread Block Reconfiguration 在 HC34/IEEE23 有明确叙述，TG133 13.3 没有 API 或调优章节。需要 CUDA Programming Guide、PTX/ISA 或可运行样例补证后再判断支持成熟度。
6. HC34/IEEE23/WP104 没有公开 Hopper 稀疏 Tensor Core 的 N:M pattern 和 metadata。不能从 A100 或后续 Blackwell 资料直接继承。
7. Figure 7 和 per-SM MAC 表没有公开 Tensor Core physical array shape、instruction tile、内部 accumulation 和 metadata selector。若这些字段重要，需要 ISA 或独立微架构来源。
8. RAS 仍缺 compute path、control state、silent data error、replay/recovery、telemetry/BIST 和 checkpoint/restart。安全章节不能代替 RAS 完整性。
9. 五源没有 GH100 die 的工作频率、功耗、封装热设计、价格或端到端实测。H100 产品值不能按比例换算到 full die。

## 验证与交接

本轮逐页阅读范围为 71 + 46 + 3 + 22 + 9 = 151 个 PDF 物理页。关键表格和框图已做视觉复核，确认了 WP104 Figure 6 的 18 个 NVLink block、Figure 7 的四分区 SM/TMA/寄存器结构、Table 3 的列与脚注，HC34 p.33 的 `0128` 排版异常，DS24 p.2 的 `With sparsity` 脚注，以及 IEEE23 Figure 8 的 FP8 测试条件。

下一步由总控复核对象裁决、字段主体和最小来源职责，再决定哪些候选进入 GH100 原子事实 staging。本文没有写入正式 facts、requirements、assertions、selection run、card completeness 或进度记录。
