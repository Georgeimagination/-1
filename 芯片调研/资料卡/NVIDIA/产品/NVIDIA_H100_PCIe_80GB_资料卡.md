# NVIDIA H100 PCIe 80GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-08-24

本卡的主语是标准 NVIDIA H100 PCIe 80GB 加速卡，即 P1010 SKU 200 / GH100-200。H100 SXM5、94 GB H100 NVL、Grace Hopper、HGX 与 DGX 均不是本卡的产品配置。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | H100 PCIe 80GB | `[2, p. 3, Table 1]` |
| 产品家族 | H100 Tensor Core GPU | 家族不代替具体 PCIe 配置 | `[1, pp. 15, 18]` |
| 完整 SKU | NVIDIA H100 PCIe 80GB；P1010 SKU 200；NVPN 699-21010-0200-xxx；GPU SKU GH100-200 | 本卡主语 | `[2, p. 3, Table 1]` |
| 对象形态 | FHFL 10.5-inch、dual-slot PCIe 加速卡，单卡承载一个 GH100 GPU | 被动散热，需要服务器 airflow | `[2, pp. 1, 3, 7-8]` |
| 架构代际 | NVIDIA Hopper；GH100 die | Hopper 是架构，GH100 是 GPU die | `[1, pp. 17-18]` |
| 发布与可用状态 | H100 家族于 2022-09-20 进入 full production；本卡产品简报 v02 日期为 2022-11-30 | 家族状态不改写成该卡的单独零售日期 | `[3, Global Rollout of Hopper]` `[2, Document History]` |
| 厂商定位 | 主流服务器中的 AI、data analytics 与 HPC 加速 | 产品简报对 H100 PCIe 的定位 | `[2, p. 1, Overview]` |
| 目标 workload | 对话式 AI、推荐、视觉 AI，以及需要 FP64、FP32、FP16 或 INT8 的 AI/HPC workload | 厂商列举，不等于 benchmark 结果 | `[2, p. 1, Overview]` |
| 产品目标 | 在标准 PCIe 服务器中提供高计算与内存吞吐，并允许七个硬件隔离 MIG 实例或两卡桥接 | 目标与实际端点配置分开记录 | `[2, pp. 1, 4, 8-9]` |

本卡包含：H100 PCIe 80GB 的实际使能 GH100 资源、HBM2e、PCIe 接口、可选 NVLink bridge、功耗和卡形态。

本卡不包含：H100 SXM5、H100 NVL、满配 GH100 未使能单元，以及服务器或集群的聚合规格。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Hopper Streaming Multiprocessor（SM）与第四代 Tensor Core | 与其他 GH100/H100 SKU 共享 | 复用 [Hopper 架构资料](../架构/NVIDIA_Hopper_架构_复用.md)，本卡补 PCIe SKU 的实际使能数 | `[1, pp. 19-21, Figures 6-7]` |
| die / chiplet | GH100 GPU die | H100 SXM5、H100 PCIe 等共享设计，实际使能数不同 | 满配 144 SM 与本 SKU 114 SM 分开 | `[1, pp. 17-19]` |
| package | 一个 GH100 与五个 HBM2e stack 的 80 GB 配置 | 本 SKU 的 HBM2e 配置 | 不把 PCIe PCB、NVLink bridge 或 host CPU 写入 package | `[1, p. 18]` `[2, pp. 1, 4]` |
| 产品 SKU | NVIDIA H100 PCIe 80GB，P1010 SKU 200 | 不适用 | 正式比较单位 | `[2, p. 3, Table 1]` |
| 相关系统 | 单卡 PCIe 服务器，或两张相邻 H100 PCIe 卡的 bridge 配置 | 多种服务器可用 | 只记录本卡端点及外部 bridge 边界 | `[2, pp. 8-10]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 SM 有 128 个 FP32 CUDA Core、64 个非 Tensor FP64 Core、64 个 INT32 Core和 4 个第四代 Tensor Core；SM 分成四个处理分区，各有 warp scheduler、dispatch、register file、Tensor Core、LD/ST 与 SFU | 每 SM；NVIDIA 使用 SIMT/warp 执行模型 | `[1, pp. 21, 39-41, Tables 3-4]` |
| 执行模型与调度 | 每 warp 32 threads；每 SM 最多 64 warps、2,048 threads 与 32 thread blocks。Thread Block Cluster 让多个 block 并发调度到同一 GPC 内的一组 SM | Hopper Compute Capability 9.0；Cluster 不跨任意 GPC | `[1, pp. 29, 41, Table 4]` |
| 局部存储与数据搬运 | 每 SM 有 256 KB register file，以及 256 KB combined L1 data cache/shared memory；shared memory 最多配置 228 KB。TMA 由选中线程发起 1D-5D tensor 的异步 global/shared-memory 搬运 | L1 与 shared memory 共用组合资源，256 KB 与 228 KB 不能相加 | `[1, pp. 21, 27, 32-35, 40]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 与 INT8 MMA；FP8 包含 E4M3/E5M2，可用 FP16 或 FP32 accumulator | Transformer Engine 结合 Tensor Core 与软件按 tensor statistics/scaling factor 选择 FP8 或 16-bit | `[1, pp. 22-24, 44-46]` |
| 稀疏与专用单元 | Tensor Core structured sparsity 可使相应 operation 的有效吞吐提高 2 倍；另有 DPX fused instructions；Cluster 内 DSMEM 支持远端 shared-memory load/store/atomic | 白皮书没有公开 sparsity metadata 数据路；DSMEM 只在单 GPU/GPC cluster 内 | `[1, pp. 22, 27, 29-30]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 GH100：8 GPC、72 TPC、144 SM、18,432 FP32 CUDA Core、576 Tensor Core | GH100 full implementation，不是 PCIe SKU 实际使能数 | `[1, pp. 18-19, Figure 6]` |
| 片上存储 | 满配 GH100 为 60 MB L2；本 SKU 使能 50 MB L2。L2 使用 partitioned crossbar，并支持 residency control | L2 全 GPU 共享；register/L1/shared memory 按 SM 分布 | `[1, pp. 18, 27, 37, 40]` |
| 片内互联 | GH100 由 GPC/TPC/SM、中央 L2 与 HBM controller 组成；GPC 内有供 Thread Block Cluster 使用的 SM-to-SM network | 完整 NoC 拓扑、链路宽度与带宽未公开 | `[1, pp. 18-19, 29, Figure 6]` |
| 内存控制器与 PHY | 满配 GH100 有 12 个 512-bit HBM controller、18 个 NVLink block 和 PCIe Gen5 host interface；本 SKU 使能 10 个 512-bit HBM controller | 满配 die 与 SKU 使能分开；本卡 HBM interface 为 5,120 bit | `[1, pp. 18-19, 40]` |
| 工艺与物理规模 | NVIDIA 定制 TSMC 4N；约 800 亿晶体管；814 mm² | GH100 bare die，不是 PCIe 卡面积 | `[1, pp. 17, 40, Table 3]` |
| 封装组成 | 一个 GH100 GPU 与五个 HBM2e stack 构成本 SKU 的 80 GB GPU/package 配置，安装于 PCIe PCB | HBM 类型与卡形态由 SKU 资料确认 | `[1, p. 18]` `[2, pp. 1, 4]` |
| 封装内互联 | 未公开 | 所选来源未给出 interposer、基板或 GH100-HBM 物理协议；NVLink bridge 位于卡外，不是 D2D | `[1, p. 18]` `[2, pp. 8-10]` |
| RAS | HBM2e 使用 sideband SECDED ECC；L2、L1 与 register file 受 SECDED ECC 保护；HBM 支持坏 row 失效与 boot-time row remapping；产品简报列明 ECC enabled | 分别属于 HBM、片上存储与产品配置 | `[1, p. 38]` `[2, p. 4, Table 3]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 7 或 8 GPC、57 TPC、114 SM、14,592 FP32 CUDA Core、7,296 非 Tensor FP64 Core、7,296 INT32 Core、456 第四代 Tensor Core | H100 PCIe 单 GPU；仅两个 TPC 有 graphics pipeline，白皮书对 GPC 数保留“7 or 8” | `[1, pp. 18, 39-40, Table 3]` |
| 时钟 | 产品简报：base 1,125 MHz、boost 1,755 MHz；白皮书性能表另以 1,620 MHz 计算 FP8/FP16/BF16/TF32 Tensor 项，以 1,755 MHz 计算 FP64 Tensor 和 FP32/FP64 non-Tensor 项 | 前者是 SKU clock 字段，后者是各理论峰值的计算条件 | `[2, p. 3, Table 1]` `[1, pp. 39-40, Table 3 note 2]` |
| 理论峰值 | FP8 Tensor：1,513/3,026 TFLOPS；FP16/BF16 Tensor：756/1,513 TFLOPS；TF32 Tensor：378/756 TFLOPS；FP64 Tensor：51.2 TFLOPS；INT8 Tensor：1,513/3,026 TOPS；non-Tensor FP16/BF16 102.4 TFLOPS、FP32 51.2 TFLOPS、FP64 25.6 TFLOPS、INT32 25.6 TOPS | 斜杠前为 dense，后为 structured sparse；FP8 支持 FP16/FP32 accumulate，FP16 支持 FP16/FP32 accumulate，BF16/TF32 为 FP32 accumulate | `[1, pp. 20, 39-40, Tables 1, 3]` |
| 内存类型与容量 | 80 GB HBM2e；1,593 MHz；5,120-bit interface | 单卡，五个 stack、十个 512-bit controller | `[1, pp. 18, 40]` `[2, p. 4, Table 2]` |
| 内存带宽 | 2,000 GB/s | 采用 2022-11 产品简报定版值；白皮书的 2,039 GB/s 明示尚未 finalized | `[2, p. 4, Table 2]` `[1, p. 40, Table 3, GPU Memory Bandwidth row: Not Finalized]` |
| 主机接口 | PCIe Gen5 x16、Gen5 x8 或 Gen4 x16；Gen5 x16 为每方向 64 GB/s、双向合计 128 GB/s | lane/polarity reversal supported；带宽只对应 Gen5 x16 | `[2, p. 4, Table 1 continued]` `[1, pp. 49-50]` |
| 设备互联端点 | 三个两槽 NVLink bridge 可把本卡与一张相邻 H100 PCIe 卡连接；Table 6 给出 48 条 Rx+Tx lane、每 lane 每方向 100 Gbps、最大 600 GB/s | 三个 bridge 必须全部安装才有 peak bridge bandwidth；产品简报 p. 1 的 900 GB/s 与 Table 6 冲突 | `[2, pp. 8-9, Table 6]` |
| 内存访问语义 | 常规 NVLink 连接的 GPU 共享 common address space，并按 GPU physical address 路由 | 不等同于 cache coherence；资料未说明 PCIe bridge 配置的远端访问性能 | `[1, p. 47]` |
| 跨设备集合通信能力 | 未找到 H100 PCIe 卡内独立 collective engine | 两卡 bridge 提供点到点链路，不能据此写入卡内 collective offload | `[2, pp. 8-10]` |
| 功耗 | 350 W maximum board power；支持的 300 W cable mode 将 default/maximum 限制为 310 W，minimum 为 200 W | 350 W 需要 450 W 或 600 W power mode；不是固定持续功耗 | `[2, pp. 3, 11-12, Tables 1, 7-8]` |
| 形态与散热 | FHFL 10.5-inch、dual-slot PCIe 卡；passive heatsink，支持两种服务器气流方向 | 卡自身无风扇，依赖 system airflow | `[2, pp. 1, 3, 7-8]` |

## 6. 系统级互联上下文

本节只解释 H100 PCIe 的两卡 bridge 条件。服务器聚合算力、内存、功耗和 benchmark 不属于本 SKU。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 三个 NVLink bridge 只连接一对相邻 H100 PCIe 卡；最佳拓扑是两卡位于同一 CPU 或 PCIe switch 域，且三个 bridge 全部安装 | 本 SKU 提供 bridge connector；bridge 与 host topology 在卡外 | `[2, pp. 8-10, Figure 4, Table 6]` |
| Scale-out | 未记录 | 本 SKU 没有集成的 scale-out network endpoint；服务器 NIC 不下放成 GPU 属性 | `[2, pp. 3-4]` |
| 系统可靠性 | 未公开 | 所选资料只披露卡上 ECC 和接口支持，没有给出服务器冗余、绕行或维修域 | `[2, pp. 4-6]` |
| 相关系统 | 主流 PCIe 服务器；单卡或一对 bridge-connected 卡 | qualified server list 在该简报中仍为 TBD，不指定代表服务器 | `[2, p. 1, Overview]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| NVLink bridge 带宽 | 来源冲突 | 产品简报 p. 1 写 900 GB/s bidirectional；p. 9 Table 6 写最大 600 GB/s，48 lanes × 100 Gbps/方向也对应 600 GB/s 双向合计 | 主规格采用更具体且可复算的 Table 6 口径，同时保留冲突 |
| HBM 带宽 | 版本差异 | 白皮书 Table 3 为 2,039 GB/s，并注明未 finalized；产品简报 Table 2 为 2,000 GB/s | 采用后发布且面向该产品的 2,000 GB/s |
| 实际 GPC 数 | 厂商保留范围 | 白皮书写 7 or 8 GPC、57 TPC、114 SM | 原样记录，不推算固定 GPC 数 |
| package/interposer/D2D | 未公开 | 白皮书与产品简报 | 只记录 GH100、五个 HBM2e stack 与 PCIe 卡，不猜测物理协议 |
| NoC 与片上带宽 | 未公开 | GH100 Figure 6、L2 与 SM 小节 | 不填写 L1/L2/register/NoC 带宽或延迟 |
| NVLink/PCIe 有效带宽与延迟 | 未公开 | 白皮书与产品简报接口章节 | 只保留厂商铭牌带宽、方向与拓扑条件 |
| 标准 H100 PCIe 80GB 的 EOL | 未找到 | 产品简报、H100 官方发布材料 | 只记录发布和 full-production 状态，不据当前营销页缺列推断停产 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Architecture*，v1.04，2022 | 官方架构白皮书 | Hopper/GH100、PCIe SKU 使能资源、理论峰值、存储、PCIe、NVLink 语义与 RAS | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf) |
| `[2]` | NVIDIA，*NVIDIA H100 PCIe GPU Product Brief*，PB-11133-001_v02，2022-11-30 | 官方产品简报 | 料号、形态、HBM、PCIe、MIG、功耗、NVLink bridge 拓扑与来源冲突 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2022_NVIDIA_H100_PCIe_GPU_Product_Brief_v02.pdf) |
| `[3]` | NVIDIA，*NVIDIA Hopper in Full Production; Systems with H100 GPU Coming Soon from World’s Top Computer Makers*，2022-09-20 | 官方发布公告 | H100 家族 full-production 状态 | <https://nvidianews.nvidia.com/news/nvidia-hopper-in-full-production> |

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

复核结论：H100 PCIe 80GB 的 P1010 SKU 200 对象边界、实际 GH100 使能资源、HBM2e、接口、功耗和形态已由官方一手资料固定。产品简报内部的 NVLink bridge 带宽冲突已显式保留，未公开字段没有用 H100 SXM5 或 H100 NVL 数据补齐。
