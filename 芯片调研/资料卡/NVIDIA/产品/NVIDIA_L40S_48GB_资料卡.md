# NVIDIA L40S 48GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡的主语是一张 NVIDIA L40S 48GB PCIe 加速卡，即 PG133 SKU 242。Ada Lovelace 与 AD102 用来解释该 SKU；L40 300W、OVX 服务器和多卡聚合规格不属于本卡。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | L40S 48GB | `[1, p. 2, Table 1]` |
| 产品家族 | NVIDIA L40S GPU Accelerator | 单 GPU 数据中心 PCIe 卡 | `[2, NVIDIA L40S GPU Specifications]` |
| 完整 SKU | NVIDIA L40S 48GB；PG133 SKU 242；NVPN 669-2G133-242-xxx | 单卡、单 AD102 GPU、48GB GDDR6 ECC | `[1, pp. 2-3, Tables 1-2]` `[5, Ada Lovelace]` |
| 对象形态 | FHFL 10.5-inch、dual-slot PCIe Gen4 卡 | 被动散热，依赖服务器 airflow | `[1, pp. 1-2, 5, 10-11]` |
| 架构代际 | NVIDIA Ada Lovelace；AD102 | NVIDIA NuRec 当前硬件文档把 L20/L40/L40S 映射到 AD102 | `[2, GPU Architecture]` `[5, Ada Lovelace]` |
| 发布与可用状态 | NVIDIA 于 2023-08-08 发布 L40S，当时计划从 2023 年秋季供货；当前产品页提供 partner purchase 入口 | 不把发布期 partner system 时间写成单卡精确 GA 日 | `[4, Availability]` `[2, Ready to Purchase]` |
| 厂商定位 | 面向 AI、graphics 与 media 的 universal data-center GPU | 产品级定位，不引入 benchmark | `[2, The Most Powerful Universal GPU]` `[4, announcement lead]` |
| 目标 workload | generative AI、LLM training/inference、3D graphics、rendering、video、simulation、virtual workstation 与 cloud gaming | 厂商列举的单卡适用范围 | `[1, p. 1, Overview]` `[2, Workloads]` |
| 产品目标 | 用单卡 48GB 内存、FP8 Transformer Engine、RT 与 media engine 覆盖 AI 和可视化多类负载 | 产品目标，不把 OVX 系统能力写入卡 | `[2, Features and Workloads]` |

本卡包含：PG133 SKU 242 的 AD102 实际使能资源、48GB GDDR6 ECC、PCIe 端点、媒体与显示能力、功耗和卡形态。

本卡不包含：NVIDIA L40、满配 AD102 未使能单元、OVX 服务器、1 至 8 卡聚合值和 benchmark。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Ada SM、第四代 Tensor Core、第三代 RT Core | 与其他 AD10x SKU 共享 | 复用 [Ada Lovelace 架构资料](../架构/NVIDIA_Ada_Lovelace_架构.md)，本卡补 L40S 实际总数 | `[3, pp. 8-12]` |
| die / chiplet | AD102 单 GPU die | 与 L40 等产品共享设计 | 满配 144 SM 与 L40S 实际 142 SM 分开；142 SM 由 SKU 总数与 Ada 每 SM 资源关系交叉得到。满配每 TPC 含 2 个 SM，但本卡 TPC 使能数未直接披露，不能据此确认 71 TPC | `[3, pp. 7-8]` `[2, GPU Specifications]` `[5, Ada Lovelace]` |
| package | 一个 AD102 GPU 与板上 48GB GDDR6 ECC | 本 SKU 的显存与板卡配置 | package、基板和 die-to-memory 物理结构未公开 | `[1, pp. 1-3]` |
| 产品 SKU | NVIDIA L40S 48GB，PG133 SKU 242 | 不适用 | 正式比较单位 | `[1, p. 2, Table 1]` |
| 相关系统 | OVX 与 partner data-center/edge systems | 多种服务器配置 | 只保留本卡没有 NVLink 的设备边界 | `[1, p. 1]` `[4, Availability]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 Ada SM 有 128 CUDA Core、1 第三代 RT Core、4 第四代 Tensor Core、4 Texture Unit、256KB register file 和 128KB L1/shared memory；SM 分四个 processing block | 每个 block 有 warp scheduler、dispatch、FP32/INT32 路径、Tensor Core、LD/ST 与 SFU | `[3, pp. 8-11, Figures 2, 5]` |
| 执行模型与调度 | Ada SM 沿用 warp/SIMT 组织；每个处理分区含 warp scheduler 与 dispatch；每 SM 最多驻留 48 个 warp、24 个 thread block，64K 个 32-bit 寄存器由驻留线程共享，单线程最多使用 255 个寄存器 | Ada compute capability 8.9 的共同上限；寄存器、shared memory 和 block 大小共同限制实际 occupancy，不能把各项上限视为必然同时达到 | `[3, pp. 8, 10-11]` `[6, §1.4.1.1, Occupancy]` |
| 局部存储与数据搬运 | 每 SM 有 256KB register file 和 128KB unified L1 data cache/shared memory | L1 与 shared memory 共用资源；L40S per-SKU L2 容量未直接公开 | `[3, pp. 8, 12]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、INT8 与 INT4；Transformer Engine 可在 FP8/FP16 间重铸 | FP8/FP16 可累加到 FP16 或 FP32，BF16 使用 FP32 accumulator | `[3, pp. 24, 27, 30, Table 2]` `[2, Transformer Engine]` |
| 稀疏与专用单元 | structured sparsity 可把相应 Tensor Core effective throughput 提高 2 倍；第三代 RT Core 含 Opacity Micromap 与 Displaced Micro-Mesh 单元 | dense/sparse 峰值在 SKU 表中分列 | `[3, pp. 9, 30]` `[2, Fourth-Generation Tensor Cores]` |

### 3.1. shared memory 配额与媒体格式

每 SM 的 128KB unified L1/shared memory 中，软件可选择 0、8、16、32、64 或 100KB 的 shared-memory carveout（为软件管理工作区分配的容量）。CUDA 为每个 thread block 保留 1KB，因此单 block 最多寻址 99KB；静态分配上限仍为 48KB，更大的动态分配需要显式 opt-in。GPU 总 SM 数增加不改变这些单 SM、单 block 的限制。`[6, §§1.4.1.1, 1.4.2.2]`

Ada 的 NVENC 为第八代专用编码器，新增 AV1 编码；第五代 NVDEC 支持 MPEG-2、VC-1、H.264、H.265/HEVC、VP8、VP9 和 AV1 解码。引擎数量与 Tensor Core 数量分开统计，不由媒体引擎个数推算未给出 codec、分辨率和帧率条件的视频流数。`[3, pp. 24-25, NVIDIA Broadcast/Video]`

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 满配 AD102：12 GPC、72 TPC、144 SM、18,432 CUDA Core、576 Tensor Core | AD102 full implementation，不是 L40S 实际使能数 | `[3, pp. 7-8, Figure 1]` |
| 片上存储 | 每 SM 有 128KB unified L1/shared memory；满配 AD102 有 98,304KB L2 | L40S per-SKU L2 未直接公开，不把 L40 同配置表的 98,304KB 自动转写为本 SKU | `[3, pp. 12, 37]` |
| 片内互联 | AD102 由 GPC/TPC/SM 和 memory controller 层次组成 | NoC 拓扑、带宽与一致性未公开 | `[3, pp. 7-12]` |
| 内存控制器与 PHY | 满配 AD102 为 384-bit memory interface、12 个 32-bit memory controller；L40S 实际也配置 384-bit GDDR6 与 PCIe Gen4 x16 | 只记录直接公开的 interface，不推断内部 PHY 布局 | `[3, p. 7]` `[1, pp. 2-3]` |
| 工艺与物理规模 | TSMC 4N NVIDIA custom process；AD102 约 763 亿晶体管、608.5mm² | AD102 bare die，不是 L40S 板卡面积 | `[3, pp. 12-14]` |
| 封装组成 | 一个 AD102 GPU 配 48GB GDDR6 ECC，安装在双槽 PCIe 卡上 | package/interposer/基板细节未公开 | `[1, pp. 1-3]` `[5, Ada Lovelace]` |
| 封装内互联 | 不适用 D2D；memory package 物理互联未公开 | 公开对象是单个 AD102 logic die，PCIe 是设备接口 | `[3, pp. 7-8]` |
| RAS | GDDR6 ECC enabled；CEC root of trust 支持 secure boot、rollback protection、key revocation、OOB secure update、recovery 与 remote attestation | ECC 是产品配置，CEC 是板卡安全机制 | `[1, pp. 3-4, 7]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 18,176 CUDA Core、568 第四代 Tensor Core、142 第三代 RT Core；由每 SM 128 CUDA/4 Tensor/1 RT 得到 142 SM；GPC 与 TPC 实际使能数未由 L40S 资料直接公开；3 NVENC、3 NVDEC | Core 总数与 media engine 为当前 L40S 页直接值；SM 是官方数值间的精确推导，TPC 不从 142÷2 推定 | `[2, NVIDIA L40S GPU Specifications]` `[3, pp. 7-8]` |
| 时钟 | base 1,065MHz；boost 2,520MHz | PG133 SKU 242；页面注明峰值按 boost clock | `[1, p. 2, Table 1]` `[2, Highlights note]` |
| 理论峰值 | FP32 91.6TFLOPS；TF32 Tensor 183/366TFLOPS；BF16/FP16 Tensor 官方网页列 362.05/733TFLOPS（dense 项待核）；FP8 Tensor 733/1,466TFLOPS；INT8 Tensor 733/1,466TOPS；INT4 Tensor 733/1,466TOPS；RT Core 212TFLOPS | 斜杠前为 dense，后为 with sparsity；FP16/BF16 的 362.05×2=724.1，与所列 733 不自洽。该 dense 值和 INT4 原值均不可当作无争议比较数据 | `[2, NVIDIA L40S GPU Specifications and note]` |
| 内存类型与容量 | 48GB GDDR6 ECC；9,001MHz；384-bit bus | 单卡 | `[1, pp. 3-4, Tables 2-3]` |
| 内存带宽 | 864GB/s | 单卡 peak memory bandwidth | `[1, p. 3, Table 2]` |
| 主机接口 | PCIe Gen4 x16，64GB/s bidirectional；也可协商 Gen4 x8 或 Gen3 x16 | 支持 lane/polarity reversal | `[2, Interconnect Interface]` `[1, pp. 2, 6-7]` |
| 设备互联端点 | NVLink 不支持；除 PCIe 外没有公开专用 GPU-to-GPU 端点 | MIG 也不支持 | `[1, p. 2, Table 1]` `[2, NVIDIA NVLink Support and MIG Support]` |
| 内存访问语义 | 未公开 | 没有公开统一地址、远端显存、页迁移或 cache coherence 语义 | `[1, pp. 2-8]` |
| 跨设备集合通信能力 | 未找到 | 无卡内 collective engine；软件通信库不写成硬件属性 | `[1, pp. 1-8]` |
| 功耗 | 350W default/maximum total board power；minimum 为 TBD | 一个 PCIe 16-pin auxiliary connector；低于支持的 power-sense 档位时卡不会启动 | `[1, pp. 2, 11-13, Tables 1, 7-8]` |
| 形态与散热 | 4.4-inch × 10.5-inch、dual-slot FHFL PCIe 卡；passive bidirectional heatsink；4 个 DisplayPort 1.4a | 依赖服务器气流，支持左右两种 airflow | `[1, pp. 1-2, 5, 10-11]` `[2, GPU Specifications]` |

### 5.1. 显示、虚拟化模式与可编程功耗

L40S 默认使用 Display Off 模式，此时物理功能 PF 的 BAR1 为 64GiB，支持 32 个 SR-IOV 虚拟功能 VF，运行 NVIDIA vGPU 软件要求采用此模式。两种 Display On 模式分别为 8GiB BAR1 的 scalable visualization 配置和 256MiB BAR1 的 professional desktop 配置，均可驱动最多四个 DisplayPort 显示器；这些显示模式不适用 VF BAR 配置。切换模式后需重启系统。BAR1 是 PCIe 地址窗口，不能把其大小写成 GPU 显存容量或硬件隔离配额。`[1, pp. 3, 7-8, Tables 3 and 5; Switching Operating Modes]`

跨卡画面同步及 frame lock 通过外加 Quadro Sync II 板实现，不是 L40S 内置的 GPU-to-GPU 计算互联。`[1, pp. 8-9, Display On Modes and Frame Lock]`

板卡允许配置 power cap（功耗上限）以适配服务器供电、散热或性能/功耗目标。通过 `nvidia-smi` 设置的上限需要在重新加载驱动后重新设置；通过 SMBPBI 带外通道设置的上限可配置为跨驱动重载及系统启动保持。产品简报给出的 150W 命令只是操作示例，Table 1 的最低可配置功耗仍为 TBD；也不能把 350W 标称最大板级功耗当作所有负载的实测功耗。`[1, p. 2, Table 1; pp. 9-10, Programmable Power]`

## 6. 系统级互联上下文

L40S 没有 NVLink，普通多卡服务器不形成由本 SKU 专用端点定义的 scale-up fabric。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 未找到专用 GPU-to-GPU scale-up endpoint | PCIe Gen4 x16 是每卡 host interface，不能写成 NVLink | `[1, pp. 2, 6-7]` |
| Scale-out | 未记录 | L40S 没有集成 scale-out NIC，OVX 中的 Spectrum-X/ConnectX 属服务器外部网络 | `[1, p. 1]` `[2, NVIDIA OVX L40S]` |
| 系统可靠性 | 未公开 | 单卡 ECC、root of trust 与 NEBS-ready 不等于服务器冗余或故障绕行 | `[1, pp. 3-7]` `[2, Efficiency and Security]` |
| 相关系统 | NVIDIA OVX 与 partner systems 可配置多张 L40S | 2023 公告所述最多 8 卡/服务器是系统配置，不是单卡资源 | `[4, New NVIDIA L40S GPU]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| L40S GPC/TPC/L2 与完整使能表 | 未直接公开 | 当前 L40S 页、Product Brief、Ada whitepaper | 只写直接资源总数与可严格推导的 SM；满配每 TPC 2 SM 不能证明实际恰为 71 TPC；不把 L40 的 12 GPC/98,304KB L2 冒充 L40S 原表值 |
| RT Core 峰值 | 版本差异 | 2023 L40S datasheet 为 209TFLOPS，当前产品页与发布公告为 212TFLOPS | 采用当前 212，并保留旧值差异，不猜测原因 |
| L40 与 L40S 功耗 | 对象差异 | Ada whitepaper Appendix C 主语是 L40，300W；L40S Product Brief 为 350W | 本卡采用 L40S 350W，不混用 L40 300W |
| minimum board power | 未公开 | Product Brief Table 1 为 TBD；可编程功耗章节的 150W 只是命令示例 | 保留 TBD，不把示例值写成下限 |
| FP16/BF16 dense 峰值 | 官方表内部不自洽 | 官网列 362.05/733TFLOPS；362.05 的两倍为 724.1，不是 733 | 保留原表并标待核，不自行改成 366.5；跨产品计算应排除此有疑点的 dense 值 |
| INT4 峰值 | 待核的官方页面口径 | 当前 L40S 表把 INT4 与 INT8 均写为 733/1,466TOPS，Product Brief 未给分精度峰值 | 原样记录并标明页面口径，不依架构倍数自行修正 |
| JPEG engine 与 L2 | 未直接公开 | L40S 当前页只给 3 NVENC/3 NVDEC；Ada whitepaper L40 表另有 4 JPEG decoder/98,304KB L2 | 不从相邻 L40 自动转写 |
| 内存与多卡语义 | 未公开 | Product Brief、当前产品页 | 不推断 P2P、统一内存、cache coherence 或 collective offload |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA L40S GPU Accelerator Product Brief*，PB-11470-001_v02，2023-08-08 | 官方产品简报 | SKU/PCI ID、时钟、GDDR6、PCIe、SR-IOV、MIG/NVLink、功耗、形态与安全 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2023_NVIDIA_L40S_GPU_Accelerator_Product_Brief_v02.pdf) |
| `[2]` | NVIDIA，*NVIDIA L40S GPU for AI and Graphics Performance* | 当前官方产品页 | 资源总数、dense/sparse 峰值、media、PCIe、形态、MIG/NVLink 与定位 | <https://www.nvidia.com/en-us/data-center/l40s/> |
| `[3]` | NVIDIA，*NVIDIA Ada GPU Architecture*，v2.02，2022 | 官方架构白皮书 | Ada SM、满配 AD102、数值路径、cache、工艺与相邻 L40 边界 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2022_NVIDIA_Ada_Architecture_Whitepaper.pdf) |
| `[4]` | NVIDIA，*NVIDIA, Global Data Center System Manufacturers to Supercharge Generative AI and Industrial Digitalization*，2023-08-08 | 官方发布公告 | L40S 发布、计划供货口径、资源与服务器边界 | <https://nvidianews.nvidia.com/news/nvidia-global-data-center-system-manufacturers-to-supercharge-generative-ai-and-industrial-digitalization> |
| `[5]` | NVIDIA，*Hardware Setup and Requirements: NVIDIA Omniverse NuRec*，更新于 2026-06-24 | 官方硬件文档 | L20/L40/L40S 与 AD102 codename 映射 | <https://docs.nvidia.com/nurec/basics/hardware.html> |
| `[6]` | NVIDIA，*Ada Tuning Guide*，13.4，网页标注更新于 2026-09-13 | 官方 CUDA 架构调优指南 | Ada 8.9 的驻留上限、寄存器配额与 shared-memory carveout、单 block 保留容量和显式 opt-in 条件 | [本地快照](../../../原始资料/网页快照/NVIDIA/产品详解补充/2026-09-17/ref-1b87ffef1f91-index.html)，[原文](https://docs.nvidia.com/cuda/ada-tuning-guide/index.html) |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 GDDR6、设备接口和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写，没有为普通 SKU 强制扩展调查范围
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：NVIDIA L40S 48GB 的 PG133 SKU 242 身份、AD102 资源、GDDR6、分精度峰值、PCIe、媒体、功耗和形态已由 NVIDIA 一手资料固定。L40 的 300W、L2/JPEG 条目和 OVX 多卡值没有下放到本 SKU；官方页面仍待核的 INT4 行已原样保留。
