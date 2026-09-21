# NVIDIA H100 SXM5 80GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-08-24

本卡的主语是 NVIDIA H100 SXM5 80GB 模组 SKU。Hopper SM 与 GH100 die 用来解释本 SKU；H100 PCIe、H100 NVL、Grace Hopper、HGX、DGX 和 NVLink Switch System 均不是本卡的产品配置。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | H100 SXM5 80GB | `[1, p. 15, H100 SXM5 GPU]` |
| 产品家族 | H100 Tensor Core GPU | 家族不代替具体 SXM5 配置 | `[2, p. 2, Technical Specifications]` |
| 完整 SKU | NVIDIA H100 SXM5 80GB | SXM5 board form-factor，80 GB HBM3 | `[1, p. 18, NVIDIA H100 GPU with SXM5 board form-factor]` |
| 对象形态 | SXM5 模组 | NVIDIA custom-built SXM5 board 承载 H100 GPU 与 HBM3 stacks | `[1, p. 15, H100 SXM5 GPU]` |
| 架构代际 | NVIDIA Hopper；GH100 die | Hopper 是架构，GH100 是实现该架构的 GPU die | `[1, pp. 17-18]` |
| 发布与可用状态 | NVIDIA 于 2022-03-22 宣布 H100；2022-09-20 宣布 H100 已进入 full production，合作伙伴产品计划从 2022-10 推出；2024-09 数据手册给出定版 H100 SXM 规格 | full production 是 H100 家族状态，不能改写成独立模组零售日期 | `[4, NVIDIA H100 at Every Scale; Availability]` `[3, Global Rollout of Hopper]` `[2, p. 2 与页脚 Sep24]` |
| 厂商定位 | 数据中心 AI、HPC 与 data analytics；支持训练与推理 | H100/H100 SXM5 产品定位，不把系统 benchmark 作为 SKU 事实 | `[1, pp. 15, 18]` `[2, pp. 1-3]` |
| 目标 workload | 大规模 AI training、inference、HPC 和多 GPU 扩展 workload | 厂商产品范围 | `[1, p. 15, H100 SXM5 GPU]` `[2, pp. 1-3]` |
| 产品目标 | 提高矩阵计算、内存带宽和 GPU 间通信能力，并支持多 GPU 服务器扩展 | SKU 与系统共同目标，具体端点和系统拓扑分开记录 | `[1, pp. 15, 17, 47]` |

本卡包含：H100 SXM5 80GB 的实际使能 GH100 资源、HBM3、SXM5 模组、PCIe Gen5 与第四代 NVLink 端点。

本卡不包含：满配 GH100 未使能单元、H100 PCIe/H100 NVL、Grace Hopper、HGX/DGX 的聚合规格、NVSwitch 或跨服务器 NVLink Switch System 的交换能力。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Hopper Streaming Multiprocessor（SM）与第四代 Tensor Core | 与其他 GH100/H100 SKU 共享架构 | 复用 [Hopper 架构资料](../架构/NVIDIA_Hopper_架构_复用.md)，本卡补 H100 SXM5 的实际使能数 | `[1, pp. 19-21, Figures 6-7]` |
| die / chiplet | GH100 GPU die | H100 SXM5、H100 PCIe 等共享 GH100 设计，实际使能数不同 | 满配 144 SM 与本 SKU 132 SM 分开 | `[1, pp. 17-19]` |
| package | GH100 GPU 与五个 HBM3 stack 位于同一 physical package，并安装在 SXM5 board 上 | 本 SKU 的 80 GB HBM3 配置 | 不把 HGX baseboard、NVSwitch 或 host CPU 写入 package | `[1, pp. 15, 18, 36]` |
| 产品 SKU | NVIDIA H100 SXM5 80GB | 不适用 | 正式比较单位 | `[1, p. 18]` |
| 相关系统 | HGX H100 4-GPU/8-GPU、DGX H100、NVLink Switch System | 多种部署 | 只记录与 NVLink 端点及地址语义相关的系统结构 | `[1, pp. 15-16, 47-48]` `[2, p. 2, Server Options]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 SM 有 128 个 FP32 CUDA Core、64 个非 Tensor FP64 Core、64 个 INT32 Core和 4 个第四代 Tensor Core。SM 分成四个处理分区，每区有 warp scheduler、dispatch unit、register file、Tensor Core、LD/ST 与 SFU | 每 SM；NVIDIA 使用 SIMT/warp 执行模型，没有发布独立“向量总峰值”和“标量总峰值” | `[1, pp. 21, 39-41, Figure 7, Tables 3-4]` |
| 执行模型与调度 | 每 warp 32 threads；每 SM 最多 64 warps、2,048 threads 和 32 thread blocks。Thread Block Cluster 保证多个 block 并发调度到同一 GPC 内的一组 SM | Hopper Compute Capability 9.0；Cluster 不跨任意 GPC | `[1, pp. 29, 41, Table 4]` |
| 局部存储与数据搬运 | 每 SM 有 256 KB register file，以及 256 KB combined L1 data cache/shared memory；shared memory 最高可配置 228 KB。TMA 由单个选中线程发起 1D-5D tensor 的 global/shared-memory 异步搬运 | L1 与 shared memory 共用组合资源，不能把 256 KB 与 228 KB 相加；TMA 的地址生成与边界处理由硬件完成 | `[1, pp. 21, 27, 32-35, 40]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、FP64 和 INT8 MMA。FP8 含 E4M3 与 E5M2，支持 FP16 或 FP32 accumulator；Transformer Engine 按 tensor statistics 与 scaling factor 在 FP8 和 16-bit 之间选择 | Transformer Engine 是 Hopper Tensor Core 技术与软件共同机制，不是独立可枚举 Core | `[1, pp. 22-24, 44-46, Figure 9, Figure 25]` |
| 稀疏与专用单元 | Tensor Core structured sparsity 可把相应 Tensor Core operation 的有效吞吐提高 2 倍；另有 DPX fused instructions。Cluster 内 DSMEM 支持远端 shared-memory load/store/atomic | 白皮书未在所引段落给出 sparsity metadata 数据路；DPX 是指令能力，不是独立核；DSMEM 只在单 GPU/GPC cluster 内 | `[1, pp. 22, 27, 29-30]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 GH100：8 GPC、72 TPC、144 SM、18,432 FP32 CUDA Core、576 Tensor Core | GH100 full implementation；不是 H100 SXM5 实际使能数 | `[1, pp. 18-19, Figure 6]` |
| 片上存储 | 满配 GH100 为 60 MB L2；H100 SXM5 使能 50 MB L2。L2 使用 partitioned crossbar 并支持 residency control；每 SM 有独立 register file 和组合 L1/shared-memory | L2 为全 GPU 共享，register/L1/shared memory 按 SM 分布 | `[1, pp. 18, 21, 27, 37, 40]` |
| 片内互联 | GH100 由 GPC/TPC/SM、中央 L2 与 HBM controller 组成；GPC 内有面向 Thread Block Cluster 的专用 SM-to-SM network | 完整 NoC 拓扑、链路宽度和带宽未公开 | `[1, pp. 18-19, 29, Figure 6]` |
| 内存控制器与 PHY | 满配 GH100 有 12 个 512-bit HBM controller、18 个 NVLink block 和 PCIe Gen5 host interface；H100 SXM5 使能 10 个 512-bit HBM controller | 满配 die 与 SKU 使能状态分开；本 SKU HBM interface 为 5,120 bit | `[1, pp. 18-19, 40, Figure 6, Table 3]` |
| 工艺与物理规模 | NVIDIA 定制 TSMC 4N；约 800 亿晶体管；814 mm² | GH100 bare die，不是 SXM board 或 HGX baseboard | `[1, pp. 17, 40, Table 3]` |
| 封装组成 | 一个 GH100 GPU 与五个 HBM3 stack 位于同一 physical package；SXM5 board 承载该 GPU/package 并提供 NVLink 与 PCIe Gen5 | 80 GB HBM3、五个 stack 是本 SKU 配置 | `[1, pp. 15, 18, 36]` |
| 封装内互联 | 未公开 | 所选来源没有给出 interposer、基板或 GH100-HBM 物理互联协议；公开实现为单个 GH100 logic die，不能把 NVLink 当作 D2D | `[1, pp. 15, 18, 36]` |
| RAS | HBM3 使用 sideband SECDED ECC；L2、L1 与 register file 也受 SECDED ECC 保护。HBM 支持坏 row 失效与 boot-time row remapping；NVLink 有 link-level error detection 和 packet replay | 分别属于 HBM、片上存储与设备链路 RAS | `[1, pp. 38, 47]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 8 GPC、66 TPC、132 SM、16,896 FP32 CUDA Core、8,448 非 Tensor FP64 Core、8,448 INT32 Core、528 第四代 Tensor Core；7 NVDEC 与 7 JPEG decoder | H100 SXM5 单 GPU；仅两个 TPC 具备 graphics pipeline 能力 | `[1, pp. 18, 39-40, Table 3]` `[2, p. 2, Technical Specifications]` |
| 时钟 | 1,830 MHz：FP8/FP16/BF16/TF32 Tensor Core 表项；1,980 MHz：FP64 Tensor Core、FP32 与 FP64 non-Tensor 表项 | GPU boost clock；白皮书没有把所有非 Tensor 路径逐项绑定到相邻时钟 | `[1, p. 39, Table 3]` |
| 理论峰值 | FP8 Tensor：1,978.9/3,957.8 TFLOPS（dense/structured sparse，FP16 或 FP32 accumulate）；FP16/BF16 Tensor：989.4/1,978.9 TFLOPS；TF32 Tensor：494.7/989.4 TFLOPS；FP64 Tensor：66.9 TFLOPS；INT8 Tensor：1,978.9/3,957.8 TOPS；non-Tensor FP16/BF16 133.8 TFLOPS、FP32 66.9 TFLOPS、FP64 33.5 TFLOPS、INT32 33.5 TOPS | 全部为理论峰值。斜杠前为 dense，后为 NVIDIA structured-sparsity 条件；FP64 Tensor 与 non-Tensor 路径没有稀疏值 | `[1, pp. 20, 39-40, Tables 1, 3]` |
| 内存类型与容量 | 80 GB HBM3，五个 stack，5,120-bit interface | H100 SXM5 单 GPU | `[1, pp. 18, 36, 40]` `[2, p. 2]` |
| 内存带宽 | 3.35 TB/s | 2024 数据手册的当前名义值；白皮书 Table 3 的细化值为 3,352 GB/s | `[2, p. 2, Technical Specifications]` `[1, pp. 39-40, Table 3]` |
| 主机接口 | PCIe Gen5 x16，64 GB/s 每方向，128 GB/s 双向合计 | 每 GPU 主机端点；不等于 NVLink 带宽 | `[1, pp. 49-50]` `[2, p. 2]` |
| 设备互联端点 | 18 条第四代 NVLink；每链路 25 GB/s 每方向；每 GPU 900 GB/s 双向聚合 | 每 GPU 端点铭牌口径；payload、持续带宽和延迟未公开 | `[1, p. 47]` `[2, pp. 2-3]` |
| 内存访问语义 | 常规 NVLink 连接的 GPU 共享 common address space，并按 GPU physical address 路由；跨节点 NVLink Network 使用独立 Network Address Space 与 H100 address-translation hardware，endpoint 连接需由软件显式建立 | 两种系统连接模式不同，不能笼统写成统一内存或缓存一致性 | `[1, p. 47]` |
| 跨设备集合通信能力 | 未找到 H100 GPU 内独立 collective engine | HGX 8-GPU 的 SHARP/in-network reduction 属外部 NVSwitch；TMA reduction 属单 GPU 数据搬运机制，均不写成 SKU 内跨设备 collective engine | `[1, pp. 15, 32-35, 47-48]` |
| 功耗 | 最高 700 W，可配置 | Max TDP，不是固定持续功耗 | `[2, p. 2, Technical Specifications]` |
| 形态与散热 | SXM5 模组；散热方式未公开 | 数据手册只把 `PCIe dual-slot air-cooled` 写在 H100 NVL 列，不能下放给 H100 SXM | `[1, p. 15]` `[2, p. 2, Form Factor]` |

## 6. 系统级互联上下文

本节只解释 H100 SXM5 的 NVLink 端点怎样接入外部交换结构。系统聚合算力、内存、功耗和 benchmark 不属于本 SKU。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | HGX H100 4-GPU 使用 GPU 间 point-to-point NVLink；8-GPU 配置使用 NVSwitch，可在任意 GPU 对之间提供完整 900 GB/s NVLink 带宽，并由 NVSwitch 提供 SHARP in-network reduction | H100 SXM5 只提供 18-link/900 GB/s 端点；NVSwitch、SHARP 与 HGX topology 都在模组外 | `[1, p. 15, H100 SXM5 GPU]` |
| 跨节点 Scale-up | 2022 白皮书描述的 NVLink Network 目标是让最多 256 个 GPU 跨多个 compute node 通信，并使用独立 Network Address Space | 这是发布期网络架构说明；白皮书同时注明该系统当时尚未随 H100 systems 提供，不能当作已交付 H100 scale-up 域 | `[1, pp. 10, 47-48, Figure 2 note; Fourth-Generation NVLink and NVLink Network]` |
| 系统可靠性 | NVLink 链路提供 link-level error detection 与 packet replay | 这是 H100 端点/链路 RAS；外部交换机、节点冗余和维修域未公开 | `[1, p. 47]` |
| 相关系统 | NVIDIA HGX H100、DGX H100、NVLink Switch System 与 partner/NVIDIA-Certified systems | 4/8/256 GPU 数量都是系统配置，不是单 SKU 计算资源 | `[1, pp. 15-16, 47-48]` `[2, p. 2, Server Options]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| SXM5 散热方式 | 未公开 | 白皮书 p. 15、数据手册 p. 2 | 只记录 SXM5 与最高 700 W configurable TDP，不借用 H100 NVL 的 air-cooled 描述 |
| package/interposer/D2D | 未公开 | 白皮书 pp. 15, 18, 36 | 只记录单 GH100 与五个 HBM3 stack 同 package，不猜测基板或物理协议 |
| die NoC 与片上带宽 | 未公开 | GH100 Figure 6、L2 与 SM 小节 | 不填写 L1/L2/register/NoC 带宽或延迟 |
| NVLink/PCIe payload 与持续性能 | 未公开 | 白皮书 pp. 47, 49、数据手册 p. 2 | 保留厂商铭牌带宽和方向，不写实测或有效载荷值 |
| Tensor Core 部分累加语义 | 未公开 | 白皮书 pp. 20-24, 39 | FP8/FP16/BF16 按明示累加格式记录；TF32/FP64/INT8 未从相邻格式补写 |
| HBM 带宽版本 | 已解释 | 2022 发布材料曾给 3 TB/s，白皮书 v1.04 Table 3 给 3,352 GB/s，2024 数据手册给 3.35 TB/s | 当前 SKU 采用数据手册 3.35 TB/s；旧值仅视作发布期规格演进 |
| H100 模组精确供货日 | 未找到 | 两份官方 PDF 与 full-production 公告 | 记录 H100 家族 2022-09-20 full production 和 2022-10 合作伙伴产品计划，不把家族状态改写成单独 SXM5 模组零售日期 |
| 256-GPU NVLink Switch System | 发布期未交付 | 2022 白皮书 Figure 2 注释与 NVLink Network 小节 | 只保留架构目标，不写成 H100 SXM5 已交付系统能力 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Architecture*，v1.04，2022 | 官方架构白皮书 | SXM5 身份、Hopper SM、GH100 die、SKU 使能资源、存储、NVLink/PCIe、RAS 与系统边界 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf) |
| `[2]` | NVIDIA，*NVIDIA H100 Tensor Core GPU Datasheet*，Sep. 2024，3440270 | 官方数据手册 | 当前 H100 SXM 80GB 峰值、HBM 带宽、功耗、MIG、形态和部署选项 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/01_厂商直接架构论文/2024_NVIDIA_H100_Tensor_Core_GPU_Datasheet_2430615.pdf) |
| `[3]` | NVIDIA，*NVIDIA Hopper in Full Production; Systems with H100 GPU Coming Soon from World’s Top Computer Makers*，2022-09-20 | 官方发布公告 | H100 家族 full-production 状态与合作伙伴产品时间边界 | <https://nvidianews.nvidia.com/news/nvidia-hopper-in-full-production> |
| `[4]` | NVIDIA，*NVIDIA Announces Hopper Architecture, the Next Generation of Accelerated Computing*，2022-03-22 | 官方发布公告 | H100 首次发布、SXM/PCIe 形态与计划可用时间 | <https://nvidianews.nvidia.com/news/nvidia-announces-hopper-architecture-the-next-generation-of-accelerated-computing> |

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

复核结论：H100 SXM5 80GB 的 SKU 配置、共享 Hopper/GH100 实现、设备端点和外部系统边界已按一手资料固定。未公开字段已登记，旧发布期 HBM 带宽与当前数据手册值已按版本解释。
