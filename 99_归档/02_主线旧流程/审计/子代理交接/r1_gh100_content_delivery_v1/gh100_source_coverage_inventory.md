# NVIDIA GH100 die 现有来源盘点与内容层最小来源候选

## 交接状态

状态：完成盘点，未写入正式库。  
对象：`OBJ-NVIDIA-GH100-DIE`，裸片（die），冻结名单中的主样本，共享设计组 `NV-GH100`。  
资料截止：沿用当前工作包的本地资料池状态，未联网扩源。  
本交接只给出内容层来源、字段覆盖和候选最小集；不改变任何 CSV、资料卡、选择运行或进度记录。

本次已读取主线协作约定、冻结名单、DEC-036、DEC-037、资料卡模板 0.3、字段字典 0.3，以及正式的 `source-families.csv`、`sources.csv`、`source-endpoints.csv`、`source-screening.csv`、`selection-runs.csv`、`selection-members.csv`、`source-coverage.csv` 和 `source-selected-roles.csv`。还审阅了 `论文/NVIDIA_GPU/` 下的 65 份 PDF 的题名和可检索正文；对下文列为候选的材料核对了摘要、对象说明、实验平台或相关章节。

当前正式库已经有 `OBJ-NVIDIA-GH100-DIE`，并已有 3 条以 GH100 为主体的物理事实，全部由 v1.04 白皮书支撑：TSMC 4N、800 亿晶体管和 814 mm²。它们仍是 `provisional`，且没有 GH100 专属的字段要求、完整度记录或选择运行。现有 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813` 的范围是 `M1-H100-TRAINIUM2-MLU590`，不能改名后当作 GH100 的反向移除结果。

## 对象边界

GH100 指裸片。白皮书第 17 页明确称“full GH100 GPU that powers the H100 GPU”，随后把 full GH100 与 H100 SXM5、H100 PCIe 两种启用配置并列列出。由此可直接归入 GH100 的是裸片制程、晶体管数、裸片面积和 full implementation 的组织；H100 SXM5 或 PCIe 的启用 SM 数、时钟、峰值吞吐、HBM 容量和带宽、TDP、板形态等仍属于产品或模组配置。

正式关系目前只有 `OREL-NVIDIA-H100-SXM5-CONTAINS-GH100`，即 H100 SXM5 模组包含 GH100 die；`OREL-NVIDIA-H100-IMPLEMENTS-HOPPER` 则挂在 H100 SXM5 上。GH100 自身尚无到 `OBJ-NVIDIA-HOPPER-ARCH` 的 `implements_architecture` 关系。建立该关系后，Hopper 的程序模型、TMA、Thread Block Cluster、Distributed Shared Memory、Transformer Engine、DPX、MIG 和 CUDA 行为应优先保留在 architecture 对象，通过关系阅读，而不复制成 GH100 的裸片物理规格。

下表是本次所有归属判断的工作口径。

| 层级 | 可进入 GH100 die 内容的条件 | 必须排除或仅作条件 |
|---|---|---|
| GH100 die | 原文明确指向 full GH100，或不依赖 H100 SKU 配置的裸片物理实现 | 不能把 full implementation 的可能单元数和某 SKU 的启用数混写 |
| Hopper architecture | 描述 compute capability 9.0、ISA、执行和共享机制时，可作为 GH100 实现 Hopper 的关系证据 | 这些是 architecture 事实，不是 H100 模组或 GH100 裸片的产品规格 |
| H100 产品、SXM、PCIe、NVL | 可证明某个 GH100 派生产品采用了有关机制，或作为明确标注的实测条件 | 80 GB、3.35 TB/s、700 W、132/114 SM、SXM/PCIe、900/600 GB/s 等不得下放给裸片 |
| H800 | 可留作 Hopper 条件下的后续独立微基准线索 | H800 PCIe 的实测带宽、延迟、频率和性能不能写为 GH100 或 H100 值 |
| Grace Hopper、GH200、NVLink-C2C | 仅能说明 CPU-GPU 组合系统的 C2C、一致性或统一内存研究 | CPU、LPDDR、系统页表、C2C 性能和系统测量不是 GH100 die 属性 |
| DGX、HGX、SuperPOD、NVLink Switch System | 可说明系统对象或架构背景 | GPU 数、系统拓扑、聚合带宽、集群 benchmark 和系统功耗不能下放 |

## 已登记来源家族、版本与入口

`source-families.csv` 是来源家族表，`sources.csv` 中的一行是一个内容版本。下表只列出正式表中与 GH100、H100 或 Hopper 直接相关的家族和版本；每项的 GH100 角色均按本次对象边界重新判断，并不沿用 H100 SXM5 试填的结论。

| 家族和内容版本 | 权威性与复核状态 | 已登记入口 | 对 GH100 的内容角色 |
|---|---|---|---|
| `SFAM-NVIDIA-H100-ARCH-WHITEPAPER` / `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，*NVIDIA H100 Tensor Core GPU Architecture*，V1.04 | NVIDIA 一手；版本、来源和筛选均 `reviewed`，`current` | NVIDIA Resources 落地页、Widen 文档入口、首选本地 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf`；71 页；SHA-256 `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27` | 正证据，GH100 的唯一已登记直接物理核心来源。第 17 页给出制程、晶体管数、面积；第 18 页列出 full GH100 的 8 GPC、72 TPC、144 SM、6 组 HBM3/HBM2e 接口、60 MB L2 与 NVLink/PCIe Gen5，同时明确区分 H100 SXM5 和 PCIe 配置。 |
| `SFAM-NVIDIA-H100-DATASHEET` / `SRC-NVIDIA-H100-DATASHEET-20240924`，*NVIDIA H100 Tensor Core GPU Datasheet* | NVIDIA 一手；来源版本 `reviewed`，家族与已选角色仍为 `draft`，`current` | Widen 直链和首选本地 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2024_NVIDIA_H100_Tensor_Core_GPU_Datasheet_2430615.pdf`；3 页；SHA-256 `17494a1792c15c55bae2453305e265ad508987b474e9235ecbc6f7c815399b98` | H100 产品边界。第 2 页的 SXM 与 NVL 表格以及第 3 页的 NVLink Switch System 都不能成为 GH100 die 的数值来源。它可保留为“产品未下放”审计证据，不进入 GH100 最小集。 |
| `SFAM-NVIDIA-HOPPER-TUNING-GUIDE` / `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3`，*CUDA Hopper Tuning Guide*，CUDA 13.3 | NVIDIA 一手；来源版本和两个 endpoint 为 `reviewed`，家族及已选角色为 `draft`，`current` | NVIDIA PDF 直链和首选本地 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2026_NVIDIA_CUDA_Hopper_Tuning_Guide_13.3.pdf`；22 页；SHA-256 `25c37c679b059681cc95fc5affe5f1797afee86c13c460d9069c8366a6e5d6d4` | Hopper architecture 的软件可见资源和机制来源。第 9 至 13 页给出 TMA、cluster、DSM、228 KB shared-memory carveout、inline compression 和 H100 NVLink 行为。现有筛选为 `redundant_covered`，理由是其 7 条已结构化 H100 断言被 v1.04 覆盖；GH100 物理最小集不选它。若以后 architecture 对象需要保留白皮书没有的当前编程限制，应在 Hopper 范围单独重跑选择。 |
| `SFAM-NVIDIA-H100-HOTCHIPS34` / `SRC-NVIDIA-H100-HOTCHIPS34-2022`，Hot Chips 34 演讲 | NVIDIA 一手；版本、endpoint、选中角色为 `draft`，筛选记录 `reviewed` | 首选本地 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_Hopper_H100_GPU_HotChips34.pdf`；46 页；SHA-256 `2b974db4a313e255ee4e5885a3dd01424e0723fd5c89163aee42ae4e1bc75c5c` | 仅 H100 发布期版本证据。80 GB HBM3、3 TB/s 和 132 SM 的页面带有发布期或产品条件；3 TB/s 还带“not finalized”脚注。不能补充 GH100 当前裸片事实。 |
| `SFAM-NVIDIA-H100-IEEE-MICRO` / `SRC-NVIDIA-H100-IEEE-MICRO-2023`，*NVIDIA Hopper H100 GPU: Scaling Performance* | 厂商作者的 IEEE Micro 文章；版本、endpoint、家族均有 `draft` 项，筛选记录 `reviewed` | 首选本地 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2023_NVIDIA_Hopper_H100_GPU_IEEE_Micro.pdf`；9 页；SHA-256 `234570fa695217139fc891bfb22a8ed252eb8b4de40030cb32c529283db06fbd` | H100/Hopper 的叙述性材料。正式 `source-coverage.csv` 已限定：对 H100 SXM5 当时选用的事实集合，v1.04 白皮书已完全覆盖；该判断不等价于全文逐句相同。GH100 也没有发现该文独有的直接裸片事实，因此不选。 |
| `SFAM-NVIDIA-HOPPER-MICROBENCH` / `SRC-NVIDIA-HOPPER-MICROBENCH-2024` 与 `SRC-NVIDIA-HOPPER-MICROBENCH-2025` | 独立实测；均 `draft`，家族为 `draft` | 两个首选本地 PDF：`2024_Benchmarking_Dissecting_NVIDIA_Hopper.pdf`，12 页，SHA-256 `6ce81fecf9c4a9d2edb2eaf476af97ec65b7107ec1293b506bd3a4d696e1ff78`；`2025_Dissecting_NVIDIA_Hopper_Extended.pdf`，33 页，SHA-256 `eb7d66d97d42f749f5a219b2a6fb652a17f000904802c1c01bb546b5796b67ea` | 两版都实测 H800 PCIe。正式筛选均为 `out_of_scope`；2025 扩展版只在以后确有 H800 条件的 architecture 独立验证需要时优先保留。不得迁移其 L1、L2、HBM、TMA、DSM 的数值到 GH100。 |

以上 7 个正式内容版本共有 11 个相关 endpoint，其中白皮书 3 个、数据手册 2 个、调优指南 2 个，其余四个版本各 1 个本地 endpoint。它们的本地文件都已固定；本任务未新建 source family、source version 或 endpoint。

## 本地 PDF 中尚未登记为正式来源的线索

65 份 NVIDIA PDF 全量文本检索中，只有 v1.04 白皮书直接出现 `GH100` 并给出其 full implementation。另有一份 Blackwell GB203 论文只是比较文字，不能支持 GH100。下面五份材料明确使用 H100 或 H100 PCIe 进行实验，正文相关段已经审阅，但它们目前没有 `sources.csv`、`source-endpoints.csv` 或 `source-screening.csv` 中的对应登记。它们在这次交接中全部是 `lead_only`，不因本地 PDF 存在而成为内容层正证据。

| 本地文件 | 已核对的对象和内容 | 可能的后续用途 | 目前为何只作 lead |
|---|---|---|---|
| `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Benchmarking_Thread_Block_Cluster.pdf`，7 页，SHA-256 `94ad0e69f8fb6f4cfa9a02df7facde68e54b2561b8eb647427cb0f5f4190df14` | 第 IV 节说明实验平台为 H100 PCIe，114 SM、50 MB L2、最大 228 KB shared memory；研究 cluster、DSM 和 SM-to-SM 通信延迟。 | Hopper 的 Thread Block Cluster 独立验证，所有数值必须附 H100 PCIe、CUDA 12.3 和实验条件。 | 观测对象是 PCIe 产品配置，不是 full GH100；尚未有正式来源版本、endpoint 和字段级断言。 |
| `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_FTTN_Numerical_Properties_Matrix_Accelerators.pdf`，10 页，SHA-256 `bcc23b21e1e0bff3ffec8f85ee5262e49ddc26737db19e188ae766c8f5ff48dc` | 摘要和 Table III 给出 H100 Tensor Core 的数值行为探测；作者明确说对 H100 的访问有限，对部分内部宽度只给下界。 | `FIELD-NUM-*` 的独立验证或限制说明。 | 不是厂商披露，且“至少”结果不能升级为物理内部累加的精确值；平台形态未成为 GH100 裸片断言。 |
| `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Uncovering_Real_GPU_NoC_Characteristics.pdf`，14 页，SHA-256 `b934b461be8baeff39f4b12eedca5e1e783e584442badd9566ed756e1a9c3874` | Table I 以 H100 的 132 SM、66 TPC 为实验对象，研究 L2/SM 的片上 NoC 时延和 CPC 级层次。 | 片上拓扑与时延的独立验证线索。 | 132 SM 表明它是启用后的 H100 配置；论文也把部分拓扑称为推测，不可作为 full GH100 物理布局或裸片带宽规格。 |
| `论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Accurate_Models_NVIDIA_Tensor_Cores.pdf`，25 页，SHA-256 `20c0594f2f91b8df7618e6d6bd00a04ee0b7bf557a5ce19d08927241f78fdee4` | 第 4.1.6 节以测试向量校验 H100/H200 Tensor Core 的 FP16、BF16、TF19 与 FP8 数值模型。 | 需要内部数值行为时，可作为带完整方法和精度条件的独立验证候选。 | H100 与 H200 合并描述，不能把结论默认为所有 GH100 die 的无条件物理参数；尚未登记且需逐项确认测试对象和计算路径。 |
| `论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Behind_Bars_NVIDIA_MIG_Cache.pdf`，20 页，SHA-256 `038050b59b89034eb2a97e00b38325f5a9179fb134380bb928c880d3f483f8b3` | Table 1 的平台为 H100 PCIe，80 GB、50 MB L2，研究二代 MIG 下跨实例 memory barrier 对 L2 的影响。 | 若资料卡有“独立验证的 MIG 隔离限制”字段，可作为 `conflict_evidence` 或带条件的实测来源。 | 该结果说明特定 PCIe、驱动和 MIG 配置下的行为，不能据此否定或改写 GH100/Hopper 的厂商机制事实，也不能写成通用裸片时延。 |

另有 2023 年 Tensor Core 微基准、2025 年 GPU core modeling、2025 年矩阵乘法方法论文和 2026 年 Hawkeye 等文件出现 H100 名称或引用白皮书，但本次检查未确认它们提供可独立落到 GH100 的直接对象事实，因此没有列为 lead。Grace Hopper、GH200、C2C、DGX、HGX、SuperPOD 和 Blackwell 相关 PDF 也仅保留为负向边界，不进入候选集。

## 正证据、负向边界和 lead 的处置

### 正证据

`SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` 是唯一可以直接支撑 GH100 内容层核心的已登记版本。其可直接支持的原文定位如下：

| GH100 内容 | 白皮书定位 | 可用范围 |
|---|---|---|
| GH100 与 H100 的关系、TSMC 4N、800 亿晶体管、814 mm² | p.17 | GH100 die 物理身份与实现 |
| full GH100 的 8 GPC、72 TPC、144 SM、每 SM 128 FP32 core 和 4 个第四代 Tensor Core、6 组 HBM 接口、60 MB L2 | p.18，Figure 6 | full GH100；不能替换成 H100 SXM5 的 132 SM 或 PCIe 的 114 SM |
| SM、第四代 Tensor Core、FP8、DPX、L1/shared memory、TMA、Thread Block Cluster、DSM | pp.22-34 | Hopper 架构机制；建议通过 GH100 到 Hopper 的关系使用 |
| HBM/L2、ECC、row remapping | pp.36-38 | H100 HBM3/HBM2e memory subsystem；容量和带宽有 SKU 条件，机制可作为 Hopper 证据 |
| 二代 MIG、Transformer Engine、NVLink 4 与 NVLink Network | pp.42-49 | Hopper/H100 机制和系统能力；链路数、每设备带宽和系统规模不得直接下放给裸片 |

### 负向边界

现有正式 H100 数据手册、Hot Chips 演讲和 IEEE Micro 文章都留在资料池，但本工作包不把它们当作 GH100 物理事实来源。H100 SXM5 的 132 SM、5 组 HBM、80 GB、3.35 TB/s 和 700 W，H100 PCIe 的 114 SM、HBM2e、不同频率或 TDP，H100 NVL 的 94 GB/188 GB 表述，都有产品、模组或双卡边界。白皮书第 39 至 40 页的每 GPU 吞吐和频率表也是 H100 SXM5 与 H100 PCIe 的 SKU 表，不能据 full GH100 的 144 SM 推算一个未发布的 GH100 规格峰值。

两份 H800 PCIe 微基准材料是另一个硬边界。即使 H800 与 H100 同为 Hopper，2025 扩展版第 4 节仍明确写明其实验设备为 H800 PCIe，并报告具体的频率、HBM2e、L2 时延和吞吐。它们不能给 GH100 die 或 H100 SXM5 填数。Grace Hopper 与 GH200 文献测的是 CPU、GPU、C2C 和统一内存组成的系统；DGX、HGX、NVLink Switch System 与 SuperPOD 则测系统互联或系统规模。它们都不得替代裸片、封装或单设备的来源。

### lead-only

上节五份未登记的 H100 条件独立论文可以在后续实际缺口出现时复查。进入正式候选前需要同时完成三件事：注册家族、固定内容版本和 endpoint；为每项结论记录 H100 SKU、驱动、CUDA、频率或 MIG 条件；判断该结论应挂在 Hopper architecture、H100 产品，还是仅保留为测试条件。仅有一个本地 PDF、一个产品名或 compute capability 9.0 均不足以把实测结果改写成 GH100 die 事实。

## 字段域覆盖与缺口

资料卡 0.3 的 13 个完整度域在 GH100 上不应追求把每个 H100 产品字段填满。以下“可覆盖”表示已有材料能够支撑本对象或明确的关系投影，“待补”表示在不越过对象边界的前提下还没有可接收内容。

| 资料卡域 | 当前覆盖 | 建议内容归属 | 缺口和处理 |
|---|---|---|---|
| identity | 部分 | 白皮书可支撑 GH100 名称、与 H100 的关系和 die 身份；冻结名单的 MIG Supported GPUs 链接尚未成为正式来源版本 | GH100 到 Hopper 的 `implements_architecture` 关系尚未登记；首次发布日期、供货日期、市场状态不应从 H100 产品日期自动继承 |
| physical | 较强但未完整 | TSMC 4N、800 亿晶体管、814 mm²，以及 full GH100 的 GPC/TPC/SM/L2/控制器组织 | 封装、HBM 堆叠、散热、TDP、板形态属于 H100/H200 等上层对象；die 的封装字段应为不适用或另有实际封装对象 |
| compute | 部分 | full GH100 的 144 SM、每 SM FP32 core 与 Tensor Core 可作为实现组织；SM 执行机制属于 Hopper | 不给 die 填 H100 SXM/PCIe 的峰值、时钟、启用数量或从 144 SM 推导的理论吞吐；需要全裸片可达频率或性能时当前无合格来源 |
| numerics | 部分 | FP8、FP16、BF16、TF32、FP64、INT8 支持和 Transformer Engine 属 Hopper；白皮书可作机制来源 | 物理内部累加、舍入、subnormal、精确流水阶段未被官方完整公开；FTTN 和 Accurate Models 只可作带条件的未来独立验证，不能填为定值 |
| memory | 部分 | 60 MB full GH100 L2、12 个 512-bit memory controller 是 full implementation 信息；L1/shared memory、压缩与管理属于 Hopper | HBM 容量、数据率、带宽、堆叠数、可分配容量均有 H100 SKU 或封装条件；不从 H100 80 GB 或 H200 容量回填裸片 |
| interconnect | 部分 | NVLink 4 与 PCIe Gen5 的代际能力可作为 full GH100/Hopper 机制描述 | 18 链路、900 GB/s、NVLink Network 最大 256 GPU、NVSwitch 聚合吞吐均是 H100 或系统口径；片上拓扑与时延尚没有可接收的 GH100 定值 |
| special_engines | 部分 | TMA、DSM、Thread Block Cluster、Transformer Engine、DPX 是 Hopper 机制，可经关系投影 | 不把 CUDA API、软件算子或单篇 H100 PCIe 微基准的时间结果写成 GH100 专用硬件吞吐 |
| software | 部分 | Hopper Tuning Guide 能说明 compute capability 9.0 的软件可见限制和 CUDA 使用边界 | 当前来源筛选已判调优指南对既有 H100 事实冗余；GH100 需先建立 architecture 关系并按 Hopper 工作包判断是否新增事实 |
| scheduling | 部分 | cluster 的共同调度、异步 barrier、DSM 访问语义是 Hopper 机制 | H100 PCIe 的 cluster 开销、SM 映射与 SLURM 测试结果只是实验条件，不能作为裸片调度定值 |
| reliability | 部分 | HBM/L2/L1/register 的 SECDED、memory row remapping、MIG 隔离是白皮书机制说明 | 覆盖粒度、实际故障率、MIG 侧信道和恢复表现均需按产品与软件版本保留条件；当前无 GH100 die 专属测量 |
| benchmark | 缺失 | 无 | 模板要求完整 condition set；H100、H800、Grace Hopper 和 DGX 的基准不能成为 GH100 die benchmark。若以后保留 H100 PCIe 实测，应放在该产品条件下 |
| economics | 不适用或缺失 | GH100 bare die 没有可比的公开定价对象 | H100 卡或云价格不下放。应在 GH100 卡片中写 `not_applicable` 或由总控决定其字段要求状态 |
| evidence | 部分 | 物理三项已有一手固定版和 source_checked 断言 | 尚无 GH100 专属字段要求、全域来源覆盖、内容选择运行和反向移除记录；相关 H100 试填记录不能代替 |

## 内容层最小来源候选与反向移除判断

### 候选集合

对于严格的 GH100 die 核心内容集合，初步最小集只有一项：

| 候选来源 | 建议角色 | 不可替代贡献 | 当前能否直接入选 |
|---|---|---|---|
| `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` | `identity` 与 `core_spec` | 唯一已登记的一手固定版同时明确 GH100 名称、full GH100 与 H100 的关系、制程、800 亿晶体管、814 mm² 和 full implementation 单元组织 | 可作为 GH100 内容层最小集的唯一核心候选；正式写入前仍需 GH100 范围的断言、字段要求、selection run 和独立复核 |

不将数据手册、Hot Chips、IEEE Micro、调优指南和两份 H800 微基准加入这个核心集合。前四项不能为 GH100 core facts 提供新增的独有内容，H800 两项又是错误产品对象。调优指南的合理位置是 Hopper architecture 的后续来源选择，不是为消除 GH100 物理缺口而重复入选。

如果后续把资料卡的目标扩大到“包含 Hopper 架构关系的完整可读卡”，不应直接把 H100 最小集复制过来。应先登记 GH100 到 Hopper 的关系，再对 Hopper 架构事实建立来源覆盖；只有白皮书无法定位且调优指南确有独有、仍适用于该架构的字段时，才考虑把 `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` 作为该 architecture 范围的候选。未登记独立论文也只在某个公开字段确实缺失时进入正式筛选。

### 反向移除判断

在“GH100 direct physical core”这一事实集下，移除 v1.04 白皮书会同时失去全部 3 条现有 GH100 物理事实以及 full GH100 的实现组织。没有另一份已登记来源能完整替代它，因此该来源保留。移除调优指南、数据手册、Hot Chips、IEEE Micro 或 H800 微基准不损失这个集合中的任何合格 GH100 direct fact；它们不应以“来源更多”为理由加入最小集。

这个判断还不是可发布的正式反向移除记录，原因有三点：GH100 尚未建立字段要求和完整度基线；现有断言只有 3 条物理事实，尚未把 full implementation、关系和缺失状态拆成新的原子记录；selection run 的范围和成员必须以 GH100 当前事实集重新生成。正式运行时应把每条字段需求的对象层级一同带入，特别检查 H100 产品数据是否被错误地计入覆盖分母。

## 建议下一步

主代理可先以 v1.04 白皮书完成 GH100 的直接物理事实和缺失要求，再决定是否登记 GH100 到 Hopper 的架构关系。随后按关系复用或重抽 Hopper 机制，避免将 H100 SXM5 的历史试填事实复制到 GH100。若后续需要独立验证，应从本交接列出的 `lead_only` 文献中按具体字段和测试对象挑选，并先完成来源注册和条件化抽取。

## 输入、验证与未解决事项

本次写入文件只有本交接文档。已做的只读验证包括：核对 65 份 NVIDIA PDF 的在库数量；核对 7 个相关正式来源版本、11 个 endpoint、筛选状态、覆盖行和 H100 历史 selection run；核对 `OBJ-NVIDIA-GH100-DIE`、现有 3 条 GH100 事实及对应 3 条 source_checked 断言；核对五份未登记独立 PDF 的页数、SHA-256、摘要和实验对象。

未解决事项是 GH100 到 Hopper 的关系尚未登记、GH100 的字段要求和完整度记录尚未建立，以及 H100 条件独立论文尚未完成正式来源注册与逐字段抽取。这些是内容层后续工作，不是本次盘点的失败。
