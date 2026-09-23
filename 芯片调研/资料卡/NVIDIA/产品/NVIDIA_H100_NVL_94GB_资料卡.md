# NVIDIA H100 NVL 94GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡的主语是一张 NVIDIA H100 NVL 94GB PCIe 卡，即 P1010 SKU 210。NVIDIA 资料也常用“H100 NVL”指两张 94GB 卡通过三个 NVLink bridge 组成的 188GB 配置；本卡把单卡 SKU 与双卡系统配置分开。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | H100 NVL 94GB | `[1, p. 3, Table 1]` |
| 产品家族 | H100 Tensor Core GPU | 家族不代替具体 NVL 配置 | `[2, pp. 1-2]` |
| 完整 SKU | NVIDIA H100 NVL 94GB；P1010 SKU 210；NVPN 699-21010-0210-xxx | 一张物理 PCIe 卡、一个 GPU、94GB HBM3 | `[1, pp. 3-4, Tables 1-2]` |
| 对象形态 | FHFL 10.5-inch、dual-slot PCIe Gen5 卡 | 被动散热，依赖服务器 airflow | `[1, pp. 1, 3, 6, 12]` |
| 架构代际 | NVIDIA Hopper；GH100 die | Hopper 是架构，GH100 是共享 GPU die | `[1, p. 1]` `[3, pp. 17-18]` |
| 发布与可用状态 | NVIDIA 于 2023-03-21 发布 H100 NVL；2024-03-14 发布 SKU 专属产品简报 | 发布稿中的 94GB 指单张卡 | `[4, NVIDIA H100 NVL and NVIDIA L4 for LLM Inference]` `[1, Document History]` |
| 厂商定位 | 针对 LLM inference 优化，同时覆盖 AI、data analytics 和 HPC | 厂商产品定位，不引入 benchmark | `[1, p. 1, Overview]` |
| 目标 workload | LLM inference，以及使用 FP64、FP32、FP16、FP8 或 INT8 的 AI/HPC workload | 单卡支持的计算范围；模型和集群结果不写成卡属性 | `[1, p. 1, Overview]` |
| 产品目标 | 以较高 compute density、HBM 带宽和能效服务大模型推理，并通过 NVLink bridge 扩展为两卡点到点配置 | 单卡资源与双卡扩展分开记录 | `[1, pp. 1, 9-11]` |

本卡包含：一张 P1010 SKU 210 H100 NVL 卡的一颗 GH100、94GB HBM3、PCIe 端点、三个 NVLink bridge 接口、功耗和物理形态。

本卡不包含：第二张 H100 NVL、三块外部 bridge、两卡合计 188GB HBM3、标准 H100 PCIe 80GB、H100 SXM5 或服务器聚合规格。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Hopper SM 与第四代 Tensor Core | 与其他 GH100/H100 SKU 共享 | 复用 [Hopper 架构资料](../架构/NVIDIA_Hopper_架构_复用.md)；不从相邻 SKU 回填使能数 | `[3, pp. 19-24]` |
| die / chiplet | GH100 GPU die | 与 H100 SXM5、H100 PCIe 等共享设计 | 只记录共享的满配 GH100；NVL 实际 SM 数未公开 | `[3, pp. 17-19]` |
| package | 一个 GH100 与 94GB HBM3 的单 GPU 配置 | 本 SKU 的 HBM3 容量和接口配置 | HBM stack 数与封装物理细节未公开 | `[1, pp. 1, 4]` |
| 产品 SKU | NVIDIA H100 NVL 94GB，P1010 SKU 210 | 不适用 | 正式比较单位 | `[1, pp. 3-4]` |
| 相关系统 | 一张卡，或两张相邻 H100 NVL 的 bridge pair | 多种 partner/NVIDIA-Certified systems | 双卡只放在系统互联上下文 | `[1, pp. 9-11]` `[2, p. 2]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 Hopper SM 包含 FP32、非 Tensor FP64、INT32 和四个第四代 Tensor Core，并分为四个处理分区，各有 warp scheduler、dispatch、register file、Tensor Core、LD/ST 与 SFU | 共享 Hopper SM；NVL 的 SM 数未公开 | `[3, pp. 21, 39-41, Tables 3-4]` |
| 执行模型与调度 | 每 warp 32 threads；每 SM 最多 64 warps、2,048 threads 与 32 thread blocks；Thread Block Cluster 将多个 block 并发调度到同一 GPC 的一组 SM | Hopper Compute Capability 9.0 | `[3, pp. 29, 41, Table 4]` |
| 局部存储与数据搬运 | 每 SM 有 256KB register file 和 256KB combined L1/shared memory，shared memory 最多 228KB；TMA 支持 1D-5D tensor 的异步 global/shared-memory 搬运 | 共享 Core 结构；L1 与 shared memory 容量不能相加 | `[3, pp. 21, 27, 32-35, 40]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 与 INT8 MMA；FP8 包含 E4M3/E5M2 | H100 NVL 资料没有单列各路径 accumulator 条件，不能从相邻 SKU 补写 | `[3, pp. 22-24, 44-46]` |
| 稀疏与专用单元 | structured sparsity 可使相应 Tensor Core operation 的有效吞吐提高 2 倍；另有 DPX instructions 与 GPC 内 DSMEM | Datasheet 带星号峰值均为 with sparsity | `[3, pp. 22, 27, 29-30]` `[2, p. 2, Technical Specifications note]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 GH100：8 GPC、72 TPC、144 SM、18,432 FP32 CUDA Core、576 Tensor Core | GH100 full implementation，不是 H100 NVL 实际使能数 | `[3, pp. 18-19]` |
| 片上存储 | 满配 GH100 为 60MB L2；每 SM 的 register/L1/shared-memory 结构见上一节 | H100 NVL 实际 L2 容量未公开 | `[3, pp. 18, 21, 27]` |
| 片内互联 | GH100 由 GPC/TPC/SM、中央 L2 与 HBM controller 组成；GPC 内有供 Thread Block Cluster 使用的 SM-to-SM network | 完整 NoC 拓扑、带宽与一致性未公开 | `[3, pp. 18-19, 29]` |
| 内存控制器与 PHY | 满配 GH100 有 12 个 512-bit HBM controller、18 个 NVLink block 与 PCIe Gen5 host interface | H100 NVL 只确认 6,016-bit HBM bus；控制器使能数不据满配图回填 | `[3, pp. 18-19]` `[1, p. 4, Table 2]` |
| 工艺与物理规模 | NVIDIA 定制 TSMC 4N；约 800 亿晶体管；814mm² | GH100 bare die，不是 PCIe 卡面积 | `[3, pp. 17, 40]` |
| 封装组成 | 一颗 GH100 GPU 与 94GB HBM3 构成单卡的 GPU/package 配置 | HBM stack 数、interposer 与基板未公开 | `[1, pp. 1, 4]` |
| 封装内互联 | 未公开 | NVLink bridge 位于两张独立卡之间，不是封装内 D2D | `[1, pp. 9-11]` |
| RAS | Hopper HBM 路径使用 sideband SECDED ECC，L2、L1 与 register file 受 SECDED ECC 保护；H100 NVL 简报确认 ECC enabled | 前者是共享 Hopper 机制，后者是该 SKU 配置 | `[3, p. 38]` `[1, p. 5, Table 3]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 未公开 SM/GPC/TPC、CUDA Core、Tensor Core 与实际 L2 数；确认 7 NVDEC、7 JPEG | SKU 专属简报与数据手册没有给出这些使能数，不用 H100 SXM5 或 PCIe 80GB 补齐 | `[1, pp. 3-5]` `[2, p. 2]` |
| 时钟 | base 1,080MHz；boost 1,785MHz | P1010 SKU 210 单卡 | `[1, p. 3, Table 1]` |
| 理论峰值 | FP64 30TFLOPS；FP64 Tensor 60TFLOPS；FP32 60TFLOPS；TF32 Tensor 835TFLOPS；BF16/FP16 Tensor 1,671TFLOPS；FP8 Tensor 3,341TFLOPS；INT8 Tensor 3,341TOPS | 后五项均为官方表中带星号的 with-sparsity 值；H100 NVL 表未单列 dense 值，不在主规格中用折半推算替代原值 | `[2, p. 2, Technical Specifications and note]` |
| 内存类型与容量 | 94GB HBM3；2,619MHz；6,016-bit bus | 单卡，不是两卡 188GB | `[1, p. 4, Table 2]` |
| 内存带宽 | 3,938GB/s | 单卡 peak；数据手册四舍五入为 3.9TB/s | `[1, p. 4, Table 2]` `[2, p. 2]` |
| 主机接口 | PCIe Gen5 x16、Gen5 x8 或 Gen4 x16；Gen5 x16 双向合计 128GB/s、每方向 64GB/s | 支持 lane/polarity reversal | `[1, pp. 3, 7]` `[2, p. 2]` `[3, pp. 49-50]` |
| PCIe 地址映射窗口 | PF（物理功能）的 BAR2 为 128 GiB；VF（虚拟功能）的 BAR1 聚合窗口为 128 GiB，64-bit，每 VF 4 GiB；最多 32 VF | BAR（Base Address Register，基址寄存器）规定设备地址映射窗口；这里的 GiB 是二进制单位，窗口大小不等于物理 HBM 容量，也不表示接口吞吐 | `[1, p. 4, Table 3]` |
| PCIe 事务与虚拟化 | Hopper 原生支持 32-bit 和 64-bit atomic CAS（比较并交换）、exchange 与 fetch-add；支持 SR-IOV（单根 I/O 虚拟化），PF（物理功能）或 VF（虚拟功能）可经 NVLink 访问 peer GPU | 共享 H100 架构能力；原子操作支持不等于 CPU/GPU cache coherence，VF 数也不等于 MIG 实例数 | `[3, p. 50, PCIe Gen 5]` |
| 设备互联端点 | 三个 bridge connector，合计 48 条 Rx+Tx lane，每 lane 每方向 100Gbps；双卡连接最大 600GB/s bidirectional | 单卡只能连接一张相邻 H100 NVL，须同时安装三块 bridge 才能正确工作并达到 peak | `[1, pp. 9-10, Table 6]` |
| 内存访问语义 | 简报仅定义 point-to-point peer transfer；没有声明两卡 HBM 自动形成单一统一 188GB 地址空间 | 188GB 是两张 94GB 卡容量相加 | `[1, pp. 9-10]` |
| 跨设备集合通信能力 | 未找到卡内独立 collective engine | 两卡 bridge 是 P2P 链路，不等于 collective offload | `[1, pp. 9-11]` |
| 功耗 | 450W/600W cable mode 下 default/maximum 400W、minimum 200W；300W cable mode 下 default/maximum 310W、minimum 200W | 产品页概括为 configurable 350 至 400W；精确供电条件采用 SKU 简报 | `[1, pp. 3, 13-15, Tables 1, 7-8]` `[2, p. 2]` |
| 可编程功率上限 | nvidia-smi 的带内设定需在每次重新加载驱动后恢复；SMBPBI（SMBus Post-Box Interface，带外管理接口）的设定可跨驱动加载和系统启动保持，完整功能仍需要驱动加载 | 用于匹配系统供电、散热或性能/功率目标；本段只记录 NVL 简报明示的保持行为，未给出降功率后的算力或频率曲线 | `[1, pp. 8-9, Programmable Power]` |
| 形态与散热 | FHFL 10.5-inch、dual-slot PCIe 卡；passive bidirectional heatsink | 依赖服务器强制气流，卡自身没有主动风扇 | `[1, pp. 1, 3, 6, 12]` |
| MIG 分区 | 最多 7 个 12 GB MIG 实例，采用 2024 数据手册列值；SR-IOV 支持 32 个 VF；Hopper 为每个 GPU instance 分配独占 crossbar port、L2 bank、memory controller 与 DRAM address bus | MIG（Multi-Instance GPU，多实例 GPU）通过硬件资源隔离提供服务质量；整 GPU 的 L2/HBM 汇总容量不能当作每个实例可用量，实例容量不据物理总量平均分配 | `[2, p. 2, Technical Specifications]` `[1, pp. 4, 7-8]` `[3, pp. 42-43, MIG Technology Review]` |
| MIG 媒体与性能监视 | Hopper 的每个 MIG GPU instance 可分配至少一个 NVDEC 视频解码器和一个 NVJPG JPEG 解码器；每个 instance 有独立 performance monitor，支持 concurrent profiling | 共享 Hopper 架构机制；实际分配取决于实例配置，不表示同一解码器可重复计给多个实例 | `[3, p. 44, H100 MIG Enhancements]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 两张相邻 H100 NVL 通过三块 NVLink bridge 形成 600GB/s bidirectional P2P 域；最佳条件是两卡位于同一 CPU 或 PCIe switch 下 | 188GB 是 2×94GB 容量合计；bridge 与第二张卡都不属于单卡 SKU | `[1, pp. 9-11, Figure 3, Table 6]` |
| Scale-out | 未记录 | 本卡没有集成 scale-out network endpoint；服务器 NIC 不下放为 GPU 属性 | `[1, pp. 3-4]` |
| 系统可靠性 | 未公开 | 产品简报未给出服务器冗余、绕行或维修域 | `[1, pp. 5, 9-11]` |
| 相关系统 | Partner 与 NVIDIA-Certified systems，支持 1 至 8 GPU 配置 | 1 至 8 GPU 是服务器选项；单个 NVLink bridge 域仍只有两卡 | `[2, p. 2, Server Options]` `[1, pp. 9-11]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| SM/Core/L2 使能数 | 未公开 | H100 NVL Product Brief、H100 Datasheet、Hopper whitepaper | 只记录共享 GH100 满配结构与单卡峰值，不借用相邻 SKU |
| dense Tensor 峰值 | 未直接列出 | H100 Datasheet 只给 with-sparsity 值；Hopper 白皮书说明 sparsity 为 2× | 主规格保留官方 sparse 值；不把折半推算写成厂商原始规格 |
| HBM stack 与 package 物理结构 | 未公开 | 产品简报、数据手册与白皮书 | 只记录 94GB HBM3 与 6,016-bit interface |
| 94GB 与 188GB | 容易混用 | Product Brief 单卡表与 Datasheet 双卡营销段落 | 94GB 固定为单卡；188GB 只作为两卡容量合计 |
| Product Brief p. 1 卡名 | 编辑疏漏 | 概述把 bridge pair 写成 two H100 PCIe cards；pp. 9-10 专门章节写 two H100 NVL cards | 采用专门章节与 Table 6 的 H100 NVL 对象 |
| HBM 带宽 | 低优先级官方冲突 | SKU 简报为 3,938GB/s，当前 H100 规格表为 3.9TB/s；一篇 H200 NVL 对比博客曾写 H100 NVL 3.35TB/s | 采用 SKU 专属简报的 3,938GB/s；四舍五入值视为一致，不用博客 3.35TB/s |
| 两卡内存语义 | 未公开 | Product Brief NVLink bridge 章节 | 记录 P2P transfer 与容量合计，不推断统一内存或 cache coherence |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA H100 NVL GPU Product Brief*，PB-11773-001_v01，2024-03-14 | 官方产品简报 | SKU、时钟、HBM、PCIe、MIG、功耗、形态与两卡 bridge | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2023_NVIDIA_H100_NVL_GPU_Product_Brief_v01.pdf) |
| `[2]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Datasheet*，Sep. 2024，3440270 | 官方数据手册 | 单卡分精度峰值、媒体引擎、HBM、MIG、互联和系统选项 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2024_NVIDIA_H100_Tensor_Core_GPU_Datasheet_2430615.pdf) |
| `[3]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Architecture*，v1.04，2022 | 官方架构白皮书 | Hopper SM、GH100 满配 die、存储、稀疏、RAS 与 PCIe 方向口径 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf) |
| `[4]` | NVIDIA，*NVIDIA Launches Inference Platforms for Large Language Models and Generative AI Workloads*，2023-03-21 | 官方发布公告 | H100 NVL 发布日期、94GB 单卡与产品定位 | <https://nvidianews.nvidia.com/news/nvidia-launches-inference-platforms-for-large-language-models-and-generative-ai-workloads> |

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

复核结论：H100 NVL 94GB 的单卡身份、HBM3、分精度峰值、PCIe/NVLink 端点、功耗和形态已由官方资料固定。两卡 188GB 配置已严格留在系统级上下文，未公开的 SM/Core/L2 和内存语义没有用相邻 H100 SKU 或算术推断补齐。
