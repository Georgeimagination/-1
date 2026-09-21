# NVIDIA GA100 die 身份与实现边界独立核验

日期：2026-08-21  
任务：`R1-CHIP-NVIDIA-GA100` 的对象边界、身份链和实现来源独立核验  
对象：冻结名单中的 `NVIDIA GA100 die`，层级为 `die`  
范围：只读正式数据，核对本地固定资料与公开一手资料；未下载文件，未写正式事实、CSV、资料卡、进度或总控文档。

## 核验结论

GA100 可以建立稳定的裸片身份，但不能把 “GA100”“A100”“A100 SXM4/PCIe 卡”和 “DGX/HGX 系统”当成同一个主体。NVIDIA A100 架构白皮书 v1.0 第 9 页直接称 A100 由基于 NVIDIA Ampere 架构的 GA100 GPU 驱动；第 14 页再次称 GA100 GPU 为 A100 提供基础；第 19 页则明确区分完整 GA100 设计的 128 SM 与 A100 启用的 108 SM。NVIDIA 当前的 MIG Supported GPUs 表又把 A100-SXM4、A100-PCIE 和 A30 的 `Microarchitecture` 明确列为 `GA100`，把 `Architecture` 列为 `NVIDIA Ampere`。这两类直接证据足以支撑后续建立 `OBJ-NVIDIA-GA100-DIE`，并以 `implements_architecture` 关系连接 `OBJ-NVIDIA-AMPERE-ARCH`。

白皮书中的数值必须按主体拆分。TSMC 7 nm N7、826 mm²、54.2 billion transistors，以及完整设计的 8 GPC、64 TPC、128 SM、8192 FP32 CUDA Cores、512 Tensor Cores、12 个 512-bit memory controllers，可以作为 GA100 裸片或完整物理设计候选。A100 的 7 GPC、108 SM、6912 FP32 CUDA Cores、432 Tensor Cores、10 个启用的 512-bit memory controllers，则是 A100 启用实现，不能覆盖 GA100 的完整设计值。40/80 GB HBM2/HBM2e、5 个启用的 HBM stack、SXM4 或 PCIe 形态、250/300/400 W board power，以及卡级时钟和带宽属于模组或板卡。DGX A100、HGX A100、NVSwitch 和多卡总吞吐属于系统或底板。它们都不能向下变成 GA100 裸片的无条件属性。

资料卡 0.3 新增的 virtualization/scheduling、RAS、软件和实测领域都有 GA100 绑定的一手候选；经济性没有找到可直接绑定 GA100 裸片的公开价格。最清楚的虚拟化证据来自 NVIDIA MIG User Guide，RAS 证据来自 NVIDIA GPU Memory Error Management 文档，软件映射来自 CUDA Ampere Tuning Guide 和 Compatibility Guide。实测可以采用 MLCommons 原始提交库或独立微基准，但事实主体仍是特定 A100 产品、设备组合或系统，并必须带完整条件集。GA100 裸片并非单独面向公开市场销售，不能用 A100 板卡、云实例或整机价格替代。

## 身份链与直接证据

下表只列能直接连接 GA100、Ampere 和 A100 实现的一手资料。所有网页访问日期均为 2026-08-21。

| 来源 | 精确定位 | 可支持的身份断言 | 边界与不确定性 |
|---|---|---|---|
| [NVIDIA A100 Tensor Core GPU Architecture Whitepaper v1.0](https://images.nvidia.com/aem-dam/en-zz/Solutions/data-center/nvidia-ampere-architecture-whitepaper.pdf) | PDF p.9、p.14、p.19；本地固定文件 `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf` | A100 基于 Ampere 架构的 GA100 GPU；GA100 驱动 A100；完整 GA100 为 128 SM，A100 基于 GA100 且启用 108 SM。 | 最强的直接身份与完整设计/启用实现分界来源。p.36 和 p.37 的规格表题头是 A100，表内同时出现裸片和 SXM4 产品值，不能按整表同一主体写入。 |
| [NVIDIA MIG User Guide: Supported GPUs](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html) | `Supported GPUs` → Table 1 | A100-SXM4 40/80GB、A100-PCIE 40/80GB、A30 的 `Microarchitecture=GA100`、`Architecture=NVIDIA Ampere`、`Compute Capability=8.0`。 | 直接而清楚的产品到微架构映射，可补强对象关系。它是动态文档，正式入库前应固定版本或网页快照。 |
| [NVIDIA A100 Tensor Core GPU Architecture in ISSCC 2021](https://doi.org/10.1109/ISSCC42613.2021.9365803) | 论文 pp.48、49、50；本地固定文件 `论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf` | 7 nm N7 实现、约 54 billion transistors、826 mm²、108 SM、A100 die photo，并公开 A100 的 MIG 和 NVLink 3 实现。 | 论文正文称主体为 “A100 die”，不稳定使用 GA100 codename；应与白皮书或 MIG 对照表共同完成身份映射。54 billion 是四舍五入值，不与白皮书 54.2 billion 构成实质冲突。 |
| [NVIDIA A100 40GB PCIe Product Brief](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/A100-PCIE-Prduct-Brief.pdf) | 文档 p.4、p.6、p.7 | PCIe 卡基于 Ampere GA100；给出具体 GA100 SKU、PCI device ID、卡级时钟、功耗、HBM 和 SR-IOV 配置。 | 可支持 GA100 die 与具体板卡/SKU 的关系。除身份关系外，数值主体主要是 PCIe 卡。文件名保留了官方 URL 中的 `Prduct` 拼写。 |
| [NVIDIA A100 80GB PCIe Product Brief](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/PB-10577-001_v02.pdf?ncid=so-pr-463033) | 文档 p.4、p.6、p.7、p.13 | 卡基于 Ampere GA100；列出 GA100-893 系列 GPU SKU、80GB HBM2e、软件最低要求、SR-IOV 和 chip root of trust 等。 | URL 文件名含 `v02`，文档内页标识为 `PB-10577-001_v03`，存在端点/版本不一致。正式引用前必须固定文件并记录哈希。 |

按这条证据链，建议关系方向是 `OBJ-NVIDIA-GA100-DIE implements_architecture OBJ-NVIDIA-AMPERE-ARCH`。A100 SXM/PCIe、A30 和具体 `GA100-...` SKU 如果后续建对象，应以产品或实现关系指向 GA100，不应把产品名直接作为 GA100 裸片的别名。现有 Ampere 架构卡已经接收的 21 条机制事实仍归架构对象；GA100 只通过关系读取，不再复制同义事实。

## 白皮书和论文中的四类主体

### GA100 完整物理设计

白皮书第 14 页把制程、晶体管数和裸片面积直接放在 GA100 GPU 语境中；第 19 页把 full GA100 implementation 与 A100 implementation 并列区分。后续可作为 GA100 裸片事实候选的内容是：TSMC 7 nm N7、826 mm²、54.2 billion transistors、8 GPC、8 TPC/GPC、2 SM/TPC、128 SM、8192 FP32 CUDA Cores、512 Tensor Cores，以及 12 个 512-bit memory controllers。这里的 `memory controllers` 是裸片内控制器；同一句中的 6 个 HBM2 stacks 是裸片外堆叠，不能因为同列出现就改变主体。

白皮书第 20 页 Figure 6 是完整 GA100 方框图。图中可以辨认 PCIe Gen4 host interface、HBM2 interface blocks 和 NVLink blocks，但仅靠数图形得到的 block 数量属于 `diagram_inferred`，不宜替代文字明确值。12 个 NVLink links 在 A100 产品语境中有文字说明；是否把同一数量无条件写成完整 GA100 die 的实现数量，应保留 `design_full` 与 `A100_enabled` 两种范围标签，或等待另一条明确针对完整 GA100 的文字证据。

### A100 启用配置

白皮书第 19 页明确给出 A100 implementation：7 GPC、每 GPC 7 或 8 TPC、108 SM、6912 FP32 CUDA Cores、432 Tensor Cores、10 个 512-bit memory controllers 和 5 个启用的 HBM2 stacks。ISSCC 论文的 108 SM、6912 CUDA Cores、40 MB L2 和 1.56 TB/s HBM2 也是 A100 的可用实现，不是完整 GA100 的全设计值。

这些数值不是无关信息。它们可以作为 `A100 enabled implementation of GA100` 的关系投影或变体事实保留，但必须同时带上 A100 产品配置。若当前正式模型只有 GA100 die，没有 A100 产品对象，则可在 GA100 阅读卡中以 “A100 启用实现” 小节展示，不能写进无条件的 GA100 数量字段，更不能用 108 SM 覆盖 128 SM。

### HBM、模组和板卡

白皮书第 35 页明确说 40 GB HBM2 位于 A100 的 SXM-style circuit board 上，且 A100 使用 5 个启用的 HBM2 stacks；同页的 1555 GB/s 是该外存配置的总带宽。第 36 页和第 37 页 Table 4 又把 `Form Factor=SXM4`、40 GB HBM2、1555 GB/s 和 400 W TDP 与裸片面积、晶体管数混在同一张 A100 规格表中。表格排版不能改变事实主体：容量、stack 类型和数量、HBM 时钟/带宽、SXM/PCIe form factor、board power、NVLink bridge 数量、PCI device ID 和产品时钟都应归模组或卡。

40GB PCIe brief 给出的 250 W，80GB PCIe brief 给出的 300 W，以及 A100 产品页中 SXM 的 400 W 都是产品功耗。它们可以在上层对象建立后投影到 GA100 卡的 “被哪些产品采用” 关系说明，却不得作为 GA100 die 自身的 TDP。类似地，80 GB HBM2e 的 1935/2039 GB/s 差异对应 PCIe 与 SXM 产品变体，不是 GA100 裸片出现了两个互相冲突的外存带宽。

### 底板与系统

DGX A100 的 8 GPU、6 NVSwitch、4.8 TB/s 聚合交换带宽、系统级算力，或 HGX A100 的 4/8/16 GPU 配置，都属于 baseboard 或 system。多卡的 NVLink/NVSwitch 拓扑和集合通信实测也属于系统条件。不能除以 GPU 数量后写成 GA100 单裸片事实，也不能用这些值填写 GA100 的片上网络、单设备注入带宽或板级功耗字段。

## GA100 卡片的写入边界

| 资料中的值或机制 | 后续建议主体 | 在 GA100 卡中的处理 |
|---|---|---|
| GA100 codename、NVIDIA vendor、Ampere 代际 | GA100 die 与架构关系 | 可直接进入身份；代际必须使用 `implements_architecture` 关系，不另建同义文本事实。 |
| N7、826 mm²、54.2 billion transistors | GA100 die | 可作为裸片直接事实候选。ISSCC 的 54 billion 保留为舍入证据，不创建数值冲突。 |
| 128 SM、8192 FP32 cores、512 Tensor Cores、12×512-bit memory controllers | GA100 full design | 可进入，但条件/范围必须写明 `full GA100 implementation`，不要与 A100 可用单元混合。 |
| 108 SM、6912 FP32 cores、432 Tensor Cores、10×512-bit active controllers | A100 enabled implementation | 只作关系投影或条件化变体；若没有 A100 对象，不作为 GA100 的无条件字段值。 |
| L2 40 MB、每 SM 共享内存、GPU Boost 下的 peak FLOPS/TOPS | A100 enabled implementation | 条件化记录。峰值还要保留精度、dense/sparse、boost clock 和运算计数规则。 |
| HBM2/HBM2e 40/80 GB、5 个 active stacks、1555/1935/2039 GB/s | A100 module/card variant | 不能下放到 GA100 die；可以通过产品关系展示。12 个 on-die memory controllers 与 HBM stack 要分开。 |
| SXM4/PCIe、250/300/400 W、PCI ID、bridge、GPU SKU、card clock | A100 card/module | 不得下放。具体 `GA100-...` SKU 只用来连接板卡和 die 实现。 |
| NVLink 3 协议机制 | Ampere architecture | 继续复用已接收架构事实。链路数、每链路速率和聚合带宽须另按 GA100 完整设计、A100 产品或系统分别取证。 |
| MIG、SR-IOV、实例隔离、QoS、fault attribution | GA100 绑定机制与 A100 产品/软件版本 | 可以进入 virtualization/scheduling，但要写明适用设备、MIG profile、驱动和软件版本；不能把多租户吞吐当裸片固定值。 |
| ECC、row remapping、dynamic page offlining、error containment | GA100 绑定 RAS 机制 | 可以进入 RAS，但应按覆盖的 HBM/SRAM/互联和恢复粒度拆事实，不写成笼统的“支持 RAS”。 |
| MLPerf、厂商 benchmark、独立微基准 | A100 SKU/card/system measurement | 只能作为条件化测量；模型、阶段、精度、batch、设备数、软件、功率/频率和统计口径必须进入 `condition_set_id`。 |
| A100 市价、云实例费用、DGX/HGX 报价 | card/cloud/system economics | 不得进入 GA100 die 的价格字段，也不得按设备数反推 die price。 |

## 资料卡 0.3 新领域的一手来源候选

### Virtualization 与 scheduling

[MIG User Guide: Concepts](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/concepts.html) 是首选来源。`GPU Instances` 和 `Compute Instances` 章节说明 GPU context 具有独立调度和地址空间；GPU Instance 提供内存 QoS 和故障隔离；Compute Instance 可拥有专用 SM，但共享所属 GPU Instance 的 memory slices 和 engines。该文档还能支持 A100-40GB profile、MPS 与实例碎片化等限制。`MIG Migration` 名称出现在 2020 白皮书中，但名称本身不等于任意工作负载可无损在线迁移，不能升级为未证明的完整 checkpoint/restore 能力。

[MIG User Guide: Virtualization](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/virtualization.html) 可支持 PCI pass-through 和 MIG-backed vGPU 的 VM 隔离语境；[Deployment Considerations](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/deployment-considerations.html) 可补充动态实例管理、reset 权限和部署限制。三者属于同一个 NVIDIA MIG User Guide 家族，不应按三个独立来源计数。

明确缺口是：这些资料主要描述可见的软件/产品行为，没有给出 GA100 内部调度器的完整队列结构、抢占保存状态、上下文切换延迟或 QoS 数值保证。当前动态文档中的部分 A100/A30 与 H100/H200 driver/CUDA 最低版本行看起来存在版本排序异常；在取得带版本的固定快照前，不建议正式写最低 driver 数值。

### RAS

[NVIDIA GPU Memory Error Management](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/index.html) 是 GA100 RAS 的优先来源家族。[Supported GPUs](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/595/supported-gpus.html) 直接把 `GA100` 标为支持 error containment、row remapping 和 dynamic page offlining。家族内的 [Error Containment](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/error-containment.html)、[Dynamic Page Offlining](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/dynamic-page-offlining.html)、[Row Remapping](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/row-remapping.html)、[Response to Uncorrectable Contained ECC Errors](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/response-to-uncorrectable-contained-ecc-errors.html)、[User-visible Statistics](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/user-visible-statistics.html) 和 [SRAM Uncorrectable Errors](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/latest/sram-uncorrectable-errors.html) 可分别支持故障隔离、恢复与遥测字段。

白皮书第 35 页还直接给出 HBM、L2、L1 和 register files 的 ECC 保护范围；第 53 页和第 54 页描述 SR-IOV 下的 error/fault attribution、isolation、containment 与 recovery。当前 Supported GPUs 表没有把 GA100 标为支持 `RAS Repair GPU Memory`，因此不得把后续架构的 repair 流程下放到 GA100。公开资料也不足以回答 Tensor Core/CUDA Core 计算路径的静默数据错误检测覆盖、BIST 细节、现场故障率和完整降级模式，这些应保留明确缺口。

### 软件支持

[CUDA C++ Best Practices Guide: Ampere Tuning Guide](https://docs.nvidia.com/cuda/ampere-tuning-guide/index.html) 在 compute capability 8.0 章节直接把 A100 绑定到 Ampere，并公开 async global-to-shared copy、split arrive/wait barrier、Tensor Core format 和共享内存配置。它适合证明编程模型和 ISA/库可见机制，不证明某一深度学习框架版本已经实测跑通。

[Ampere Compatibility Guide](https://docs.nvidia.com/cuda/ampere-compatibility-guide/index.html) 可支持 CUDA 11 native cubin、PTX forward compatibility 和 compute capability 8.0 的兼容边界。[CUDA 11 Features Revealed](https://developer.nvidia.com/blog/cuda-11-features-revealed/) 是带日期的 NVIDIA 原始发布说明，可补充 NVML、`nvidia-smi`、容器和 Kubernetes 的 MIG 管理入口。白皮书第 58 页也介绍 CUDA 11 task graphs 与异步 API。

明确缺口是：尚未对 cuDNN、cuBLASLt、NCCL、TensorRT、PyTorch 和 JAX 的 GA100/A100 最低版本、支持周期和可运行证据逐项核验。通用框架声明不能自动升级为 `runnable_verified`；后续若填写软件成熟度，必须区分 `documented_supported`、实际可运行和公开 benchmark。

### 实测

[MLCommons Inference v0.7 Results](https://github.com/mlcommons/inference_results_v0.7) 与 [MLCommons Training v0.7 Results](https://github.com/mlcommons/training_results_v0.7) 是可审计的原始提交库，适合在选定 A100 提交后建立完整 workload 和 system 条件。它们证明的是特定 A100 数量、主机、框架、精度和软件配置的结果，不是 GA100 die 的固有吞吐。

两个本地独立研究可作为微基准候选。[Demystifying the Nvidia Ampere Architecture through Microbenchmarking and Instruction-level Analysis](https://doi.org/10.1109/HPEC55821.2022.9926299) 报告指令、内存和 Tensor Core 的 latency/throughput，但正文设备写作 “Nvidia Tesla AI100 GPU”，且缺少精确 A100 SKU、driver/CUDA、时钟和功率条件，当前只能 `needs_review`。[A100 GPU: Full Speed Random Access Memory](https://arxiv.org/abs/2405.11425) 明确使用 A100 SXM4-80GB，研究随机/coalesced 访问、TLB 和 SM resource groups；但 driver、软件、时钟和系统条件仍不完整，图上约 1400 到 1600 GB/s 的读数不应直接录为高置信度事实。

厂商白皮书第 14 页和第 15 页以及 [A100 产品页](https://www.nvidia.com/en-us/data-center/a100/) 也给出多项训练/推理结果，但必须把脚注中的模型版本、精度、稀疏性、batch、设备数、软件版本和对比基线一并保存。产品页会更新，只有固定快照和完整脚注才能进入断言链。

### 经济性

本轮没有找到 NVIDIA 面向市场单独销售 GA100 die 的公开目录价，也没有找到可把晶圆或 die 成本可靠归一到 GA100 的原始成本资料。GA100 的 die-price 字段更接近 `not_applicable`：对象不是独立销售品，理由应写清楚；若字段定义要求寻找公开单价，也可以登记 `not_found`，但不能用 A100 PCIe/SXM 卡、云实例、DGX/HGX 系统或二手市场价格替代。

A100 产品采购价本身属于 card/module economics，而且公开报价受到地区、渠道、数量、时间和服务合同影响。若后续确实需要经济性比较，应先建对应产品对象并保存报价日期与渠道条件，仍不得向下推算 GA100 die 成本。

## 来源家族去重与最小集建议

NVIDIA A100 白皮书、NVIDIA Architecture in Depth 博文、IEEE Micro 论文和 ISSCC 论文高度重合，且主要由 NVIDIA 作者给出。它们可以是不同出版物或端点，但不能被解释为四条相互独立的外部佐证。对 GA100 核心身份与物理实现，白皮书 v1.0 已经覆盖直接命名、完整设计/启用实现分界和物理规格；ISSCC 的保留价值是同行评审发表形态、die photo 和芯片实现摘要。IEEE Micro 论文 [NVIDIA A100 Tensor Core GPU: Performance and Innovation](https://doi.org/10.1109/MM.2021.3061394) 主要重复 108 SM、40 MB L2、HBM2、NVLink 3 和 MIG，可作为替代端点或补页，不应仅为增加来源数进入最小集。

建议 GA100 的初始最小来源集由四个角色组成：白皮书负责身份、完整设计和 A100 实现边界；ISSCC 负责原始芯片实现与 die photo；MIG User Guide 家族负责 GA100/A100 对应和 virtualization/scheduling；GPU Memory Error Management 家族负责 GA100 RAS。软件字段需要时再加入 Ampere Tuning Guide，只有兼容性字段确实进入完整度合同才加入 Compatibility Guide。40/80GB PCIe product brief 只在需要建立具体卡到 GA100 的 SKU 关系时保留，不要把两个产品 brief 都当成 GA100 核心规格来源。Benchmark 来源应由实际选中的测量事实决定，不在核心身份包中预占席位。

每个动态文档应在正式登记时记录页面版本、访问日期和固定快照；一个文档家族内部的多个章节与 URL 只计算为一个来源家族。白皮书的本地固定端点已存在且有哈希，后续可复用现有来源链，但 GA100 芯片范围仍需独立 screening、coverage 和 reverse-removal，不能把 `SELRUN-M2NA-ARCH-20260812` 当成 GA100 selection run。

## 不确定性与待补证

GA100 的身份已经有直接证据，当前最重要的不确定性是如何同时保存完整设计、A100 可用实现和产品变体，又不让它们互相覆盖。正式 schema 尤其需要明确 `design_full`、`enabled_implementation` 与 `product_variant` 的表示方法。若只允许一个 GA100 die 主体而没有实现变体关系，108/128 SM、10/12 memory controllers 等值容易被错误合并成冲突。

第二个不确定性是链路和存储外围边界。白皮书把 full GA100 的 memory controllers 与 HBM stacks 放在同一段，但 controller 在 die 内、stack 在封装/板上；Figure 6 的 NVLink block 数量又需要图区推断。正式写入前应逐项检查定位句是否明确说 full GA100，图区计数只能标 `diagram_inferred`。

第三个不确定性来自活文档。MIG 和 RAS 文档会随 driver 与产品代际更新；80GB PCIe brief 的 URL 与内页版本已不一致。它们足以做候选来源，却不应在未固定快照、版本与哈希时承担长期稳定的精确版本事实。

最后，实测和经济性仍存在实质缺口。两个独立微基准的条件不够完整，不能直接成为高置信度 benchmark；GA100 die 也没有独立公开价格。最稳妥的处理是保留 `needs_review`、`not_found` 或 `not_applicable`，而不是借用 A100 卡和系统数据填满表格。

## 写入与验证

本子任务只新增 `审计/子代理交接/r1_ga100_04_identity_boundary_review.md`。未修改正式对象、事实、来源、资料卡、selection run 或进度文件，也未下载任何网络资料。

本地固定白皮书已核对第 9、14、19、20、35、36、37、43 至 54、58 页；ISSCC PDF 已核对出版页 48、49、50；IEEE Micro 论文、2022 HPEC 微基准和 2024 A100 random-access 论文已核对相关正文与实验条件。白皮书第 19、20、35、36、37 页和 ISSCC 全文页另作了页面渲染并人工查看，确认表头、图注与正文的主体没有被纯文本抽取错位。首次渲染时出现字体缓存目录不可写的运行时警告，改用临时可写缓存后重跑成功；警告没有影响页面内容或本次只读结论。
