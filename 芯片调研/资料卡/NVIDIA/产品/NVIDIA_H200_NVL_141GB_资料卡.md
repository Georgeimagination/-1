# NVIDIA H200 NVL 141GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡的主语是一张 NVIDIA H200 NVL 141GB PCIe 卡，官方产品号为 P1010 SKU 230。两张或四张卡加 NVLink bridge 构成的互联组、MGX H200 NVL 服务器和其他 NVIDIA-Certified Systems 都不是本卡的 SKU 主语。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | H200 NVL 141GB | `[1, p. 3, Table 2-1]` |
| 产品家族 | NVIDIA H200 Tensor Core GPU | H200 家族的 PCIe/NVL 配置 | `[3, NVIDIA H200 GPU specifications]` |
| 完整 SKU | NVIDIA H200 NVL 141GB；P1010 SKU 230；NVPN 900-21010-xx40-xxx | 单张卡 | `[1, p. 3, Table 2-1]` |
| 对象形态 | PCIe Gen5 ×16，FHFL 10.5-inch，dual-slot，passive air-cooled | 单张全高全长卡 | `[1, pp. 1, 3, 11]` |
| 架构代际 | NVIDIA Hopper；GH100 microarchitecture；Compute Capability 9.0 | H200 NVL 141GB | `[1, p. 1]` `[5, Supported GPUs, Table 1]` |
| 发布与可用状态 | 2024-11-18 宣布 H200 NVL PCIe GPU 可用，合作伙伴系统计划从 2024 年 12 月起供货；当前 H200 产品页标为 Now available | 日期指 H200 NVL 产品/平台发布与系统供货，不是裸 GPU 零售日期 | `[4, page header and Platforms with H200 NVL]` `[3, page header]` |
| 厂商定位 | 主要优化 LLM inference，同时面向低功耗、风冷企业机架的 AI 与 HPC 加速 | 简报 p.1 明确 LLM inference 优化目标；用途支持不表示排他定位 | `[1, p. 1, Overview]` `[3, Accelerating AI Acceleration for Mainstream Enterprise Servers With H200 NVL]` |
| 目标 workload | LLM inference 与 fine-tuning（模型微调）、AI/data analytics 与 HPC；支持 FP64、FP32、FP16、FP8 和 INT8 compute | 官方发布文章明确支持 fine-tuning；不把偏推理理解为不支持训练 | `[1, p. 1]` `[4, opening paragraphs: fine-tune LLMs / inference and fine-tuning]` |
| 产品目标 | 在标准 PCIe 卡形态中提供 141GB HBM3e、4.8TB/s 级内存带宽和最多四卡 NVLink bridge 扩展 | 单卡属性与多卡能力分开记录 | `[1, pp. 1, 4, 9-10]` |

本卡包含：H200 NVL 141GB 单卡的 GH100/Hopper 共享架构、实际时钟、分精度峰值、HBM3e、PCIe/NVLink 端点、MIG、功耗与机械形态。

本卡不包含：两卡/四卡 bridge 组的聚合算力和内存、MGX 或 OEM 服务器配置、host CPU、NIC 与 benchmark。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Hopper SM 与第四代 Tensor Core | 与 H100/H200 SXM 共享 | 复用 [Hopper 架构资料](../架构/NVIDIA_Hopper_架构_复用.md) | `[2, pp. 21-30]` |
| die / chiplet | GH100 GPU die | 与 H100/H200 共享设计 | 满配 GH100 与 H200 NVL 实际产品配置分开 | `[2, pp. 17-19]` `[5, Supported GPUs, Table 1]` |
| package | GH100 GPU 与 141GB HBM3e 的封装实现 | 与 H200 SXM 共享容量/带宽档，板卡不同 | 不从板卡信息推断 HBM stack 和 interposer 细节 | `[1, p. 4, Table 2-2]` |
| 产品 SKU | P1010 SKU 230 H200 NVL 141GB | 不适用 | 正式比较单位 | `[1, p. 3, Table 2-1]` |
| 相关系统 | MGX H200 NVL partner 与 NVIDIA-Certified Systems，最多 8 GPU | 多种部署 | 只记录单卡端点和 bridge 可达域 | `[3, NVIDIA H200 GPU specifications]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 Hopper SM 有 128 FP32 CUDA Core、64 个非 Tensor FP64 Core、64 INT32 Core 和 4 个第四代 Tensor Core；SM 分四个处理分区 | 共享 Hopper SM；H200 NVL 的实际 SM 数未在所选 per-SKU 资料中列出 | `[2, pp. 21, 39-41, Tables 3-4]` |
| 执行模型与调度 | 每 warp 32 threads；每 SM 最多 64 warps、2,048 threads 和 32 thread blocks；Thread Block Cluster 将多个 block 调度到同一 GPC | Hopper Compute Capability 9.0 | `[2, pp. 29, 41, Table 4]` `[5, Supported GPUs, Table 1]` |
| 局部存储与数据搬运 | 每 SM 有 256KB register file 和 256KB combined L1/shared memory，shared memory 最多 228KB；TMA 支持 1D-5D tensor 异步搬运 | 共享 Hopper 实现；本 SKU 的实际 L2 容量未找到 | `[2, pp. 21, 27, 32-35, 40]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 与 INT8 MMA；FP8 包含 E4M3/E5M2 | H200 NVL 峰值另见 SKU 配置 | `[2, pp. 22-24, 44-46]` |
| 稀疏与专用单元 | structured sparsity 可使相应 Tensor Core operation 的有效吞吐提高 2 倍；另有 DPX 与 GPC 内 DSMEM | 产品页中 TF32/BF16/FP16/FP8/INT8 headline 都带 with sparsity 条件 | `[2, pp. 22, 27, 29-30]` `[3, NVIDIA H200 GPU specifications, note 2]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 GH100：8 GPC、72 TPC、144 SM、18,432 FP32 CUDA Core、576 Tensor Core | GH100 full implementation，不是 H200 NVL 实际使能数 | `[2, pp. 18-19]` |
| 片上存储 | 满配 GH100 为 60MB L2 | 本 SKU 实际 L2 未在官方 per-card 规格中列出 | `[2, pp. 18, 21, 27]` |
| 片内互联 | GH100 由 GPC/TPC/SM、中央 L2 与 HBM controller 组成；GPC 内有供 Thread Block Cluster 使用的 SM-to-SM network | 完整 NoC 拓扑、带宽与一致性未公开 | `[2, pp. 18-19, 29]` |
| 内存控制器与 PHY | GH100 满配有 12 个 512-bit HBM controller、18 个 NVLink block 与 PCIe Gen5 host interface | H200 NVL 公开板卡规格给出 6016-bit memory bus，不等于满配 GH100 控制器全部使能 | `[2, pp. 18-19]` `[1, p. 4, Table 2-2]` |
| 工艺与物理规模 | NVIDIA 定制 TSMC 4N；约 800 亿晶体管；814mm² | GH100 bare die，不是 PCIe 卡面积 | `[2, pp. 17, 40]` |
| 封装与板卡组成 | GH100/HBM3e 封装搭载于 H200 NVL PCIe 卡；141GB HBM3e，memory bus 6016 bits | HBM stack 数、interposer 与基板细节未找到；不把 NVLink bridge 算入 GPU package | `[1, pp. 1, 4, Table 2-2]` |
| 封装内互联 | 未公开 | NVLink bridge 和 PCIe 是设备间/主机接口，不是 GPU-HBM 的 D2D 协议 | `[1, pp. 7, 9-10]` |
| RAS 与启动信任 | Hopper HBM、L2、L1 和 register file 使用 SECDED ECC；H200 NVL 支持 secure boot 与 Confidential Computing。板上 CEC 硬件信任根在 GPU 从 ROM 启动前认证固件，并支持防回滚、密钥撤销、带外安全更新、处理器恢复和远程证明 | ECC 为共享 Hopper 机制；CEC 的固件认证与恢复是本板卡简报明示功能，不能等同于作业实测可靠性 | `[2, p. 38]` `[1, p. 8, §4.2]` `[3, NVIDIA H200 GPU specifications]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | SM、GPC、TPC、CUDA Core、Tensor Core 与 L2 实际使能数未公开；官方列出 7 NVDEC 与 7 JPEG | 单张 H200 NVL；不从四舍五入的峰值反推资源数 | `[3, NVIDIA H200 GPU specifications]` |
| 时钟 | Base 1,230MHz；Boost 1,785MHz；HBM memory clock 3,201MHz | P1010 SKU 230 单卡官方值 | `[1, pp. 3-4, Tables 2-1 and 2-2]` |
| 理论峰值 | FP64 30TFLOPS；FP64 Tensor 60TFLOPS；FP32 60TFLOPS；TF32 Tensor 835TFLOPS；BF16/FP16 Tensor 1,671TFLOPS；FP8 Tensor 3,341TFLOPS；INT8 Tensor 3,341，官方页面单位写为 TFLOPS | 后五项是官方 with-sparsity headline；dense 值未直接列出。INT8 通常使用 TOPS，此处不静默改写官方单位 | `[3, NVIDIA H200 GPU specifications and note 2]` |
| 比较用 dense 推导值 | FP16/BF16 835.5TFLOP/s；FP8 1,670.5TFLOP/s | 对上述 1,671/3,341TFLOPS 稀疏峰值分别按 Hopper 明确的 2 倍关系折半；带原表舍入误差，非官方另列 dense 规格 | `[3, NVIDIA H200 GPU specifications and note 2]` `[2, pp. 11, 21-23]` |
| 内存类型与容量 | 141GB HBM3e；6016-bit memory bus | 单张卡 | `[1, p. 4, Table 2-2]` |
| 内存带宽 | 4,813GB/s；产品页四舍五入为 4.8TB/s | 单 GPU peak memory bandwidth | `[1, p. 4, Table 2-2]` `[3, NVIDIA H200 GPU specifications]` |
| 主机接口 | PCIe Gen5 ×16，同时支持 Gen5 ×8 或 Gen4 ×16；Gen5 ×16 官方表记 128GB/s | 当前 H200 NVL 表没有在这个数值旁明说单向或双向，不自行补充 | `[1, pp. 3, 7]` `[3, NVIDIA H200 GPU specifications]` |
| PCIe 地址映射窗口 | PF（物理功能）的 BAR2 为 256 GiB；VF（虚拟功能）的 BAR1 聚合窗口为 256 GiB，64-bit，每 VF 8 GiB；最多 32 VF | BAR（Base Address Register，基址寄存器）规定设备地址映射窗口；这里的 GiB 是二进制单位，窗口大小不等于物理 HBM 容量，也不表示接口吞吐 | `[1, p. 4, Table 2-3]` |
| PCIe 虚拟化 | SR-IOV 支持 32 个 VF（Virtual Function，虚拟功能）；仅支持 MSI-X 中断，不支持 MSI | 需服务器 BIOS 与 OS/hypervisor 配置支持；32 VF 是 PCIe 功能上限，不是 32 个 MIG instance；MIG 最多 7 个 | `[1, pp. 4, 7, Table 2-3 and §§4.1.2-4.1.3]` |
| 设备互联端点 | 1 个 wide NVLink bridge connector，18 条 link；单 GPU 最大 NVLink 带宽 900GB/s | 最多连接四张相邻 H200 NVL 卡；900GB/s 为 per-GPU 双向端点口径 | `[1, pp. 1, 9, Table 4-1]` `[3, NVIDIA H200 GPU specifications]` |
| 内存访问语义 | 常规 NVLink 连接的 GPU 共享 common address space，并按 GPU physical address 路由 | 共享 Hopper 语义；不等于 cache coherence 或系统统一内存池 | `[2, p. 47]` |
| 跨设备集合通信能力 | 未找到单卡内独立 collective engine | Bridge 只提供 GPU P2P 链路，不把外部 NVSwitch/SHARP 下放为卡内功能 | `[1, pp. 9-10]` `[2, pp. 47-48]` |
| 功耗 | 600W maximum/default，350W power compliance limit，200W minimum；programmable power cap | 单卡 total board power。16-pin 12VHPWR 线缆必须识别为 600W 档，Sense0/Sense1=0/0；即使软件设置更低功率也要满足该启动条件，较低线缆档位不支持 | `[1, pp. 3, 8, 12-13, Tables 2-1 and 4-3]` |
| 形态与散热 | FHFL 10.5-inch dual-slot PCIe card，passive bidirectional heatsink，板重 1,217g（不含 bracket、extender 和 bridge） | 需要系统风道，支持从左到右或从右到左的 airflow | `[1, pp. 3-6, Tables 2-1 and 2-4]` |
| MIG | 最多 7 个硬件隔离 GPU instance；当前 H200 141GB profiles 包括 1g.18gb、1g.35gb、2g.35gb、3g.71gb、4g.71gb、7g.141gb 和 1g.18gb+me | H200 NVL 明确列为 GH100/141GB/7-instance 支持产品；profile 表以 H200 141GB 为主语 | `[1, pp. 1, 3, 8]` `[5, Supported GPUs, Table 1; H200 MIG Profiles, Table 11]` |

### 5.1 MIG 中计算与内存份额的组合

MIG（Multi-Instance GPU，多实例 GPU）分别分配计算和内存资源。Hopper 的实例拥有独立的 crossbar 端口、L2 bank、内存控制器和 DRAM 地址总线路径；这些是共享架构的隔离机制，不将整颗 GPU 的 L2/HBM 数值当作每个实例的资源。`[2, p. 43, MIG Technology Review]`

| H200 141GB profile | HBM 份额 | SM 份额 | L2 份额 | Copy engine 数 | 同类实例数上限 |
|---|---:|---:|---:|---:|---:|
| 1g.18gb | 1/8 | 1/7 | 1/8 | 1 | 7 |
| 1g.35gb | 1/4 | 1/7 | 1/8 | 1 | 4 |
| 2g.35gb | 2/8 | 2/7 | 2/8 | 2 | 3 |

表中份额采用 H200 141GB 专门 profile 表。1g.35gb 与 1g.18gb 的 SM、L2、copy engine 配额相同，HBM 份额不同；2g.35gb 又在相同 HBM 份额下配置更多 SM 和 L2。实例容量与计算规模并非固定比例，各 profile 的最大数量也不能相加当作可同时启用的总数。`[5, H200 MIG Profiles, Table 11]`

## 6. 系统级互联上下文

本节只说明 H200 NVL 单卡端点如何组成 bridge 域。系统聚合算力、内存、功耗和 benchmark 不属于本 SKU。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 2-slot bridge 跨两张卡，part number 900-23945-xx00-xxx，表列 total NVLink BW 900GB/s；4-slot bridge 跨四张卡，part number 900-23946-xx00-xxx，表列 total NVLink BW 1,800GB/s | 两个值属于 bridge 组；单张卡端点仍为最大 900GB/s | `[1, pp. 9-10, Tables 4-1 and 4-2]` |
| 拓扑约束 | 官方建议 bridge-connected 卡位于同一 CPU 或 PCIe switch/domain，保持 CPU:GPU:NIC 对称；跨 CPU domain 允许但不推荐 | 这是服务器拓扑约束，不是单卡属性 | `[1, pp. 9-10, PCIe and NVLink Topology]` |
| Scale-out | 未记录 | H200 NVL 卡未集成 scale-out network endpoint；系统 NIC 不下放为 GPU 属性 | `[1, pp. 3, 7, 9-10]` |
| 相关系统 | MGX H200 NVL partner 与 NVIDIA-Certified Systems，最多 8 GPU | 最多四张卡可进入一个 NVLink bridge 域，8-GPU 服务器不表示八卡一个直连域 | `[3, NVIDIA H200 GPU specifications]` `[1, pp. 9-10]` |

## 7. 证据缺口与来源冲突

产品简报 Table 4-1 把每 lane 每方向速率写为 50GB/s，但 Hopper 白皮书 p.47 给每 link 每方向 25GB/s，18 links 的双向合计才为 900GB/s。lane/link 名称与方向口径无法直接对齐，主字段仅保留已交叉确认的 900GB/s 双向总量，不把 50GB/s 当作已核实的单向 link 速率。`[1, p.9, Table 4-1]` `[2, p.47]`

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| H200 NVL SM/GPC/TPC/Core/L2 | 未公开 | 2025 product brief、H200 datasheet、当前产品页与 MIG 文档 | 保留缺失，不从 rounded peak 和 clock 反推 |
| dense Tensor 峰值 | 未直接列出 | 当前产品页只给 with-sparsity headline | 保留厂商原值与条件，不把折半小数冒充官方规格 |
| INT8 单位 | 官方页面疑似单位异常 | H200 产品页把 INT8 3,341 单位写成 TFLOPS | 原样记录并单列异常，不自行改成 TOPS |
| 内存带宽描述 | product brief 概述不精确 | p. 1 只称“greater than 900 GBps”，Table 2-2 列出 4,813GB/s，产品页为 4.8TB/s | 概述只是宽松下界；规格字段采用 Table 2-2 精确值 |
| MIG 最小容量 | 当前官方页面不一致 | H200 产品页的 NVL 列写“7 MIGs @16.5GB each”；当前 MIG Guide 的 H200 141GB profile 为 18GB 起 | 用专项 MIG Guide 的 profile 名称，同时保留产品页冲突 |
| NVLink 聚合口径 | 不同对象层级 | 单 GPU 最大 900GB/s；2-slot bridge 表列 900GB/s total；4-slot bridge 表列 1,800GB/s total | 分别按 per-GPU endpoint 和 bridge group 记录，不将 1,800GB/s 写成单卡带宽 |
| HBM package 细节 | 未公开 | product brief、H200 datasheet 与 Hopper whitepaper | 只记录 141GB HBM3e、6016-bit bus 和带宽，不猜 stack/interposer |
| Product Brief 发布标记 | 公开入口与文档页脚不一致 | PDF 由 NVIDIA 当前 H200 产品页公开直链，但封面和页脚仍有 NVIDIA CONFIDENTIAL / PREPARED AND PROVIDED UNDER NDA | 仅摘要规格并保留原始页码；不大段转录原文 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA H200 NVL GPU Product Brief*，PB-12128-001_v01，2025-04 | 官方产品规格 | SKU/NVPN、clock、HBM3e、PCIe、NVLink bridge、MIG、power、form factor 与 topology | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2025_NVIDIA_H200_NVL_Product_Brief.pdf) |
| `[2]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Architecture*，v1.04，2022 | 官方架构白皮书 | Hopper SM、GH100 die、存储、数值、RAS 与 NVLink 语义 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf) |
| `[3]` | NVIDIA，*NVIDIA H200 GPU* | 当前官方产品页 | 峰值、media、HBM3e、power、PCIe/NVLink、形态、系统边界和可用状态 | <https://www.nvidia.com/en-us/data-center/h200/> |
| `[4]` | NVIDIA，*Hopper Scales New Heights, Accelerating AI and HPC Applications for Mainstream Enterprise Servers*，2024-11-18 | 官方发布文章 | H200 NVL 可用声明、定位和合作伙伴系统供货时间 | <https://blogs.nvidia.com/blog/hopper-h200-nvl/> |
| `[5]` | NVIDIA，*MIG User Guide: Supported GPUs and H200 MIG Profiles* | 当前官方开发文档 | H200 NVL/GH100 身份、141GB、7 instances 与 H200 profiles | <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html>；<https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-mig-profiles.html> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 HBM、设备互联和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写，没有为普通 SKU 强制扩展调查范围
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：NVIDIA H200 NVL 141GB 的 P1010 SKU 230 单卡身份、实际时钟、141GB HBM3e、4,813GB/s、PCIe/NVLink、MIG、600W 功耗和 dual-slot 被动散热形态已由 NVIDIA 一手资料固定。两卡/四卡 bridge 与 MGX 系统值没有下放到单卡；未公开的实际 SM/Core/L2 和封装细节保持缺失。
