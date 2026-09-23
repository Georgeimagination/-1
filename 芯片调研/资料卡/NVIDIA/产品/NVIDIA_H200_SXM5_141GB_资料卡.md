# NVIDIA H200 SXM5 141GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡的主语是 NVIDIA H200 SXM5 141GB 单 GPU 模组。当前产品页简称“H200 SXM”，MIG 文档使用“H200-SXM5”；H200 NVL 141GB、HGX H200、DGX H200 和 GH200 Superchip 均不是本卡的产品配置。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | H200 SXM5 141GB | `[1, p. 4, Technical Specifications]` `[6, Supported GPUs, Table 1]` |
| 产品家族 | NVIDIA H200 Tensor Core GPU | 家族包含 SXM 与 NVL 两种不同配置 | `[1, pp. 1, 4]` |
| 完整 SKU | NVIDIA H200 SXM5 141GB | 单 GPU SXM5 模组；141GB HBM3e | `[1, p. 4]` `[6, Supported GPUs, Table 1]` |
| 对象形态 | SXM5 模组 | H200 NVL 才是 PCIe dual-slot air-cooled 卡 | `[1, p. 4, Form Factor]` `[6, Supported GPUs, Table 1]` |
| 架构代际 | NVIDIA Hopper；GH100 microarchitecture | MIG 文档明确 H200-SXM5 为 Hopper/GH100 | `[6, Supported GPUs, Table 1]` |
| 发布与可用状态 | NVIDIA 于 2023-11-13 发布 H200，原计划 2024Q2 起由系统厂商和云服务商供货；当前产品页标明 Now available | 系统供货时间不改写成裸模组零售日期 | `[5, announcement and Availability]` `[4, page header]` |
| 厂商定位 | generative AI 与 HPC GPU | H200 单 GPU 定位；不把 HGX benchmark 写入卡属性 | `[1, pp. 1-2]` `[4, The GPU for Generative AI and HPC]` |
| 目标 workload | LLM training/inference、memory-intensive simulation、scientific computing 与其他 HPC/AI workload | 厂商产品范围 | `[1, pp. 1-2]` `[5, NVIDIA H200 Form Factors]` |
| 产品目标 | 用更大、更快的 HBM3e 缓解容量与带宽瓶颈，同时保持 Hopper 计算与 NVLink 端点 | 单 GPU 目标；系统扩展另列 | `[1, pp. 1-2, 4]` |

本卡包含：H200 SXM5 141GB 的 GH100/Hopper 计算资源、HBM3e、PCIe/NVLink 端点、MIG、功耗与模组形态。

本卡不包含：H200 NVL 的 600W/PCIe/bridge 配置、HGX/DGX 的 4/8 GPU 聚合值、NVSwitch、host CPU 或 benchmark。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Hopper SM 与第四代 Tensor Core | 与 H100/GH100 SKU 共享 | 复用 [Hopper 架构资料](../架构/NVIDIA_Hopper_架构_复用.md)，本卡补 H200 的 132 SM 与 HBM3e | `[2, p. 4]` `[3, pp. 19-24]` |
| die / chiplet | GH100 GPU die | 与 H100 SXM5 等共享设计 | 满配 144 SM 与本 SKU 132 SM 分开 | `[2, p. 4]` `[3, pp. 17-19]` |
| package | 一个 GH100 GPU 与 141GB HBM3e 的 SXM5 配置 | H200 SXM5 特有 memory configuration | 不把 HGX baseboard、NVSwitch 或 host CPU 写入 package | `[2, p. 4, GPU Overview]` |
| 产品 SKU | NVIDIA H200 SXM5 141GB | 不适用 | 正式比较单位 | `[1, p. 4]` `[6, Supported GPUs, Table 1]` |
| 相关系统 | HGX H200 4-GPU/8-GPU 与 NVIDIA-Certified Systems | 多种部署 | 只记录本 SKU 的 NVLink/PCIe 端点与外部交换边界 | `[1, p. 4, Server Options]` `[5, NVIDIA H200 Form Factors]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 Hopper SM 有 128 FP32 CUDA Core、64 非 Tensor FP64 Core、64 INT32 Core 和 4 第四代 Tensor Core；SM 分四个处理分区，各有 warp scheduler、dispatch、register file、Tensor Core、LD/ST 与 SFU | 共享 Hopper SM；H200 直接公开 132 SM | `[3, pp. 21, 39-41, Tables 3-4]` `[2, p. 4]` |
| 执行模型与调度 | 每 warp 32 threads；每 SM 最多 64 warps、2,048 threads 与 32 thread blocks；Thread Block Cluster 把多个 block 调度到同一 GPC 的一组 SM | Hopper Compute Capability 9.0 | `[3, pp. 29, 41, Table 4]` `[6, Supported GPUs, Table 1]` |
| 局部存储与数据搬运 | 每 SM 有 256KB register file 和 256KB combined L1/shared memory，shared memory 最多 228KB；TMA 支持 1D-5D tensor 异步搬运 | L1 与 shared memory 共用资源；H200 实际 L2 为 50MB | `[3, pp. 21, 27, 32-35, 40]` `[2, p. 4]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 与 INT8 MMA；FP8 包含 E4M3/E5M2 | H200 产品表只给分精度峰值，没有重新列 accumulator 条件 | `[3, pp. 22-24, 44-46]` |
| 稀疏与专用单元 | structured sparsity 可使相应 Tensor Core operation 的有效吞吐提高 2 倍；另有 DPX 与 GPC 内 DSMEM | H200 表中的 TF32/BF16/FP16/FP8/INT8 headline 均为 with sparsity | `[3, pp. 22, 27, 29-30]` `[1, p. 4, note 2]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 GH100：8 GPC、72 TPC、144 SM、18,432 FP32 CUDA Core、576 Tensor Core | GH100 full implementation，不是 H200 SXM5 实际使能数 | `[3, pp. 18-19]` |
| 片上存储 | 满配 GH100 为 60MB L2；H200 SXM5 实际为 50MB L2 | L2 全 GPU 共享；register/L1/shared memory 按 SM 分布 | `[3, pp. 18, 21, 27]` `[2, p. 4]` |
| 片内互联 | GH100 由 GPC/TPC/SM、中央 L2 与 HBM controller 组成；GPC 内有供 Thread Block Cluster 使用的 SM-to-SM network | 完整 NoC 拓扑、带宽与一致性未公开 | `[3, pp. 18-19, 29]` |
| 内存控制器与 PHY | GH100 满配有 12 个 512-bit HBM controller、18 个 NVLink block 与 PCIe Gen5 host interface | H200 实际 memory-controller enable 数未单列 | `[3, pp. 18-19]` `[2, p. 4]` |
| 工艺与物理规模 | NVIDIA 定制 TSMC 4N；约 800 亿晶体管；814mm² | GH100 bare die，不是 SXM5 模组面积 | `[3, pp. 17, 40]` |
| 封装组成 | 一个 GH100 GPU 与 141GB HBM3e 构成 H200 SXM5 的单 GPU 模组配置 | HBM stack 数、interposer 与基板细节未在所选 per-SKU 资料中明确列出 | `[2, p. 4]` |
| 封装内互联 | 未公开 | NVLink 与 PCIe 是设备接口，不是 GH100-HBM 的 D2D 协议 | `[2, p. 4]` |
| RAS | Hopper HBM 路径、L2、L1 与 register file 使用 SECDED ECC；H200 支持 Confidential Computing | 前者是共享 Hopper RAS，后者为 SKU 功能 | `[3, p. 38]` `[1, p. 4]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 132 SM、50MB L2、7 NVDEC、7 JPEG；由 Hopper 每 SM 结构可得 16,896 FP32 CUDA Core和528 Tensor Core，但这是官方数值间推导 | 132 SM/L2/media 为 H200 SXM block diagram 直接值；GPC/TPC 未直接公开 | `[2, p. 4]` `[3, pp. 21, 39-41]` |
| 时钟 | 未公开 | 所选 H200 per-SKU 资料没有 base/boost/SM clock，不从 H100 SXM5 或第三方数据库补齐 | `[1, p. 4]` `[2, p. 4]` |
| 理论峰值 | FP64 34TFLOPS；FP64 Tensor 67TFLOPS；FP32 67TFLOPS；TF32 Tensor 989TFLOPS；BF16/FP16 Tensor 1,979TFLOPS；FP8 Tensor 3,958TFLOPS；INT8 Tensor 3,958，官方表单位写为 TFLOPS | 后五项是官方 with-sparsity headline；dense 值未在 H200 表中单列。INT8 通常使用 TOPS，但此处不静默改写原表单位 | `[1, p. 4, Technical Specifications and notes]` |
| 比较用 dense 推导值 | FP16/BF16 989.5TFLOP/s；FP8 1,979TFLOP/s | 对上述 1,979/3,958TFLOPS 稀疏峰值分别按 Hopper 明确的 2 倍关系折半；带原表舍入误差，非官方另列 dense 规格 | `[1, p. 4, note 2]` `[3, pp. 11, 21-23]` |
| 内存类型与容量 | 141GB HBM3e | 单 GPU SXM5 | `[1, pp. 1, 4]` `[2, p. 4]` |
| 内存带宽 | 4.8TB/s | 单 GPU peak memory bandwidth | `[1, pp. 1, 4]` |
| 主机接口 | PCIe Gen5，128GB/s bidirectional | 每 GPU host endpoint，不是 NVLink 带宽 | `[2, p. 4]` `[1, p. 4]` |
| 设备互联端点 | 第四代 NVLink，900GB/s bidirectional per GPU | 每 GPU 端点；HGX/NVSwitch 拓扑在模组外 | `[2, p. 4]` `[1, p. 4]` |
| 内存访问语义 | 常规 NVLink 连接的 GPU 共享 common address space，并按 GPU physical address 路由 | 共享 Hopper 语义；不等于 cache coherence 或系统统一内存池 | `[3, p. 47]` |
| 跨设备集合通信能力 | 未找到模组内独立 collective engine | HGX 中的 SHARP 属外部 NVSwitch，不下放成 H200 SXM5 单模组能力 | `[3, pp. 15, 47-48]` |
| 功耗 | up to 700W，configurable | 单 GPU maximum TDP，不是 HGX 系统功耗 | `[1, p. 4]` |
| 形态与散热 | SXM5 模组；散热方式未由 per-GPU 资料指定 | 空冷/液冷由 HGX/OEM 系统设计决定，不能借用 H200 NVL 的 dual-slot air-cooled | `[1, p. 4, Form Factor]` `[6, Supported GPUs, Table 1]` |
| MIG | 最多 7 个 instance；当前 profiles 包括 1g.18gb、1g.35gb、2g.35gb、3g.71gb、4g.71gb、7g.141gb，以及一个 1g.18gb+me | 当前 MIG Guide 口径；18GB 是最小 profile，不是所有 instance 固定大小 | `[6, H200 MIG Profiles, Table 11]` |

### 5.1 MIG 中计算与内存份额的组合

MIG（Multi-Instance GPU，多实例 GPU）分别分配计算和内存资源。Hopper 的实例拥有独立的 crossbar 端口、L2 bank、内存控制器和 DRAM 地址总线路径；这些是共享架构的隔离机制，不将整颗 GPU 的 L2/HBM 数值当作每个实例的资源。`[3, p. 43, MIG Technology Review]`

| H200 141GB profile | HBM 份额 | SM 份额 | L2 份额 | Copy engine 数 | 同类实例数上限 |
|---|---:|---:|---:|---:|---:|
| 1g.18gb | 1/8 | 1/7 | 1/8 | 1 | 7 |
| 1g.35gb | 1/4 | 1/7 | 1/8 | 1 | 4 |
| 2g.35gb | 2/8 | 2/7 | 2/8 | 2 | 3 |

表中份额采用 H200 141GB 专门 profile 表。1g.35gb 与 1g.18gb 的 SM、L2、copy engine 配额相同，HBM 份额不同；2g.35gb 又在相同 HBM 份额下配置更多 SM 和 L2。实例容量与计算规模并非固定比例，各 profile 的最大数量也不能相加当作可同时启用的总数。`[6, H200 MIG Profiles, Table 11]`

## 6. 系统级互联上下文

本节只解释 H200 SXM5 的 NVLink 端点怎样接入 HGX。系统聚合算力、容量、功耗和 benchmark 不属于本 SKU。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | HGX H200 提供 4-way 与 8-way 配置；GPU 通过 NVLink 互联，具体交换拓扑须按相应系统确认，不能由 4/8-way 产品名称推断两者均使用 NVSwitch | H200 SXM5 只提供 900GB/s per-GPU NVLink endpoint；NVSwitch 不在模组内 | `[5, NVIDIA H200 Form Factors]` `[1, p. 4, Server Options]` |
| Scale-out | 未记录 | H200 SXM5 没有集成的 scale-out network endpoint；系统 NIC 不下放为 GPU 属性 | `[1, p. 4]` |
| 系统可靠性 | NVLink 链路支持 error detection 与 packet replay | 这是端点/链路 RAS；节点冗余和维修域未公开 | `[3, p. 47]` |
| 相关系统 | NVIDIA HGX H200 partner 与 NVIDIA-Certified Systems，4 或 8 GPU | 八卡 1.1TB aggregate HBM 与超过 32PFLOPS FP8 是系统值 | `[1, p. 4]` `[5, NVIDIA H200 Form Factors]` |
| HGX 平台兼容性 | 官方发布稿明确四卡、八卡 HGX H200 server board 与 HGX H100 系统的硬件和软件兼容，合作伙伴可据此升级已有系统设计 | 这是系统平台兼容声明；不等于任意服务器可直接换装 H200 模组，也不提供具体散热或固件改造步骤 | `[5, NVIDIA H200 Form Factors]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| H200 clock/GPC/TPC | 未公开 | H200 datasheet、当前产品页、官方 training block diagram | 记录 132 SM 与可严格推导的 CUDA/Tensor Core 数，不借用 H100 时钟或推断 GPC/TPC |
| dense Tensor 峰值 | 未直接列出 | H200 表只给 with-sparsity headline | 保留厂商原值与条件，不把折半小数冒充官方直接规格 |
| INT8 单位 | 官方表疑似单位异常 | Datasheet 与当前产品页均把 INT8 3,958 的单位写成 TFLOPS | 原样记录并单列异常，不自行改成 TOPS |
| datasheet 状态 | preliminary 与已供货并存 | 2024 datasheet/current spec footnote 仍写 preliminary；当前页面标明 Now available，MIG/认证文档继续支持 | 采用当前数值，同时保留 preliminary 注记 |
| H200 SXM 与 H200 NVL | 对象差异 | Datasheet p.4 两列 | SXM 使用700W、900GB/s直接端点与 HGX；不混入 NVL 600W、air-cooled PCIe、bridge 与 MGX |
| MIG 最小 profile | 版本差异 | 当前 Guide 为 18GB；部分旧资料曾出现 16.5GB 口径 | 采用当前 H200-SXM5 18GB profile |
| package/HBM stack | 未公开 | H200 datasheet 与 block diagram | 只记录单 GH100、141GB HBM3e 与 SXM5，不从示意图猜 stack/基板结构 |
| 散热方式 | 未公开 | Datasheet Form Factor 行 | 只写 SXM5 与700W configurable TDP；不借用 H200 NVL 的 dual-slot air-cooled |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA H200 Tensor Core GPU Datasheet*，3512650，Nov. 2024 | 官方数据手册 | SXM/NVL 边界、分精度峰值、HBM3e、media、功耗、MIG、互联和系统选项 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2024_NVIDIA_H200_Tensor_Core_GPU_Datasheet_3512650.pdf) |
| `[2]` | NVIDIA，*CUDA Programming and Optimization*，2024 | 官方培训材料 | H200 SXM block diagram、132 SM、50MB L2、HBM3e、PCIe/NVLink 方向口径 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2024_NVIDIA_CUDA_Programming_and_Optimization_H200.pdf) |
| `[3]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Architecture*，v1.04，2022 | 官方架构白皮书 | Hopper SM、GH100 满配 die、存储、数值、RAS 与 NVLink 语义 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf) |
| `[4]` | NVIDIA，*NVIDIA H200 GPU* | 当前官方产品页 | 当前规格、Now available 状态与 SXM/NVL 边界 | <https://www.nvidia.com/en-us/data-center/h200/> |
| `[5]` | NVIDIA，*NVIDIA Supercharges Hopper, the World’s Leading AI Computing Platform*，2023-11-13 | 官方发布公告 | 发布、供货计划、定位、HGX 4/8-way 与系统聚合边界 | <https://nvidianews.nvidia.com/news/nvidia-supercharges-hopper-the-worlds-leading-ai-computing-platform> |
| `[6]` | NVIDIA，*MIG User Guide: Supported GPUs and H200 MIG Profiles* | 当前官方开发文档 | H200-SXM5/GH100 身份、141GB、最多7 MIG及各 profile | <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html>；<https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-mig-profiles.html> |

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

复核结论：NVIDIA H200 SXM5 141GB 的单 GPU 身份、132 SM/50MB L2、HBM3e、峰值、PCIe/NVLink、MIG、功耗和模组形态已由 NVIDIA 一手资料固定。H200 NVL 与 HGX/DGX 聚合值没有下放到本 SKU，时钟和 package 细节等未公开字段保持缺失。
