# NVIDIA L4 24GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡的主语是一张 NVIDIA L4 24GB PCIe 加速卡，即 PG193 SKU 200。Ada Lovelace 架构与 AD104 用来解释该 SKU；包含多张 L4 的服务器和云实例不是本卡的产品配置。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | L4 24GB | `[1, p. 2, Table 1]` |
| 产品家族 | NVIDIA L4 Tensor Core GPU | 单一 GPU 加速卡产品 | `[3, Product Specifications]` |
| 完整 SKU | NVIDIA L4 24GB；PG193 SKU 200；NVPN 699-2G193-0200-xxx；four-part PCI ID 10DE:27B8:10DE:16CA | 一张物理 PCIe 卡、一个 AD104 GPU | `[1, pp. 2-3, Table 1 and note]` |
| 对象形态 | HHHL-SS，即 half-height/low-profile、half-length、single-slot PCIe 卡 | 被动散热，依赖服务器 airflow | `[1, pp. 1-2, 5, 7-8]` |
| 架构代际 | NVIDIA Ada Lovelace；AD104 | Ada 是架构，AD104 是 GPU code name | `[2, pp. 39-40, Appendix D, Table 5]` |
| 发布与可用状态 | NVIDIA 于 2023-03-21 发布 L4；同月发布 PG193 SKU 200 产品简报；当前 NVIDIA 产品页仍列出该卡 | 发布与当前页面状态截止本卡日期 | `[4, NVIDIA L4 for AI Video]` `[1, Document History]` `[3, Product Specifications]` |
| 厂商定位 | 面向 cloud 与 edge 的通用数据中心 GPU，覆盖 video、AI、graphics 与 virtualization | 厂商定位，不把服务器实测写入卡属性 | `[1, p. 1, Overview]` `[2, p. 39, Appendix D]` |
| 目标 workload | AI inference 与部分 training、video transcoding、AI audio/video effects、rendering、data analytics、virtual workstation、cloud gaming、simulation | 产品简报与架构白皮书列举的应用范围 | `[1, p. 1]` `[2, p. 39]` |
| 产品目标 | 以低矮单槽、72W 功耗包络提供高吞吐与低时延，适配从 edge 到 data center/cloud 的通用服务器 | 单卡产品目标 | `[2, p. 39, Appendix D]` |

本卡包含：PG193 SKU 200 的实际 AD104 使能资源、24GB GDDR6、PCIe 端点、媒体引擎、功耗和物理形态。

本卡不包含：未使能的完整 AD104 资源、包含 1 至 8 张 L4 的服务器聚合值、云实例或 benchmark。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Ada SM、第四代 Tensor Core、第三代 RT Core | 与其他 AD10x SKU 共享 | 复用 [Ada Lovelace 架构资料](../架构/NVIDIA_Ada_Lovelace_架构.md)，本卡补 L4 实际使能数 | `[2, pp. 8-12]` |
| die / chiplet | AD104 单 GPU die | 与其他 AD104 产品共享设计 | 只记录 L4 的 5 GPC/29 TPC/58 SM 实际配置；完整 AD104 满配数未在所选资料中给出 | `[2, pp. 39-40]` |
| package | 一个 AD104 GPU 与板上 24GB GDDR6 | 本 SKU 的显存配置 | package、基板与 die-to-memory 物理结构未公开 | `[1, pp. 1-3]` |
| 产品 SKU | NVIDIA L4 24GB，PG193 SKU 200 | 不适用 | 正式比较单位 | `[1, p. 2, Table 1]` |
| 相关系统 | Partner 与 NVIDIA-Certified systems | 多种 1 至 8 GPU 服务器配置 | 只记录 L4 是独立 PCIe endpoint，不把系统数量聚合到单卡 | `[3, Product Specifications]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 Ada SM 有 128 个 CUDA Core、1 个第三代 RT Core、4 个第四代 Tensor Core、4 个 Texture Unit、256KB register file 和 128KB L1/shared memory；SM 分四个 processing block | 每 SM；每个 block 有 warp scheduler、dispatch、FP32/INT32 路径、Tensor Core、LD/ST 与 SFU | `[2, pp. 8-11, Figures 2, 5]` |
| 执行模型与调度 | Ada SM 沿用 warp/SIMT 组织；每个处理分区含 warp scheduler 与 dispatch；每 SM 最多驻留 48 个 warp、24 个 thread block，64K 个 32-bit 寄存器由驻留线程共享，单线程最多使用 255 个寄存器 | Ada compute capability 8.9 的共同上限；寄存器、shared memory 和 block 大小共同限制实际 occupancy，不能把各项上限视为必然同时达到 | `[2, pp. 8, 10-11]` `[6, §1.4.1.1, Occupancy]` |
| 局部存储与数据搬运 | 每 SM 有 256KB register file 和 128KB unified L1 data cache/shared memory，可按 workload 配置 | L1 与 shared memory 是统一资源，不能相加；L4 的全 GPU L2 为 49,152KB | `[2, pp. 8, 12, 40]` |
| 数值与累加路径 | 第四代 Tensor Core 支持 FP8、FP16、BF16、TF32、INT8 与 INT4 matrix formats；FP8/FP16 可累加到 FP16 或 FP32，BF16 使用 FP32 accumulator | 程序员可见格式与实际物理累加器位宽分开 | `[2, pp. 24, 27, 30, Table 2]` |
| 稀疏与专用单元 | structured sparsity 可使相应 Tensor Core operation 的有效吞吐提高 2 倍；第三代 RT Core 含 Opacity Micromap 与 Displaced Micro-Mesh 专用单元 | 稀疏峰值与 dense 峰值在 SKU 表中成对记录 | `[2, pp. 9, 30, Table 2]` |

### 3.1. shared memory 配额与媒体格式

每 SM 的 128KB unified L1/shared memory 中，软件可选择 0、8、16、32、64 或 100KB 的 shared-memory carveout（为软件管理工作区分配的容量）。CUDA 为每个 thread block 保留 1KB，因此单 block 最多寻址 99KB；静态分配上限仍为 48KB，更大的动态分配需要显式 opt-in。GPU 总 SM 数增加不改变这些单 SM、单 block 的限制。`[6, §§1.4.1.1, 1.4.2.2]`

Ada 的 NVENC 为第八代专用编码器，新增 AV1 编码；第五代 NVDEC 支持 MPEG-2、VC-1、H.264、H.265/HEVC、VP8、VP9 和 AV1 解码。引擎数量与 Tensor Core 数量分开统计，不由媒体引擎个数推算未给出 codec、分辨率和帧率条件的视频流数。`[2, pp. 24-25, NVIDIA Broadcast/Video]`

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 完整 AD104 满配资源数未公开 | Appendix D 给的是 L4 实际 5 GPC、29 TPC、58 SM，不能自动当成完整 AD104 满配 | `[2, pp. 39-40]` |
| 片上存储 | Ada SM 各有 128KB unified L1/shared memory；L4 实际 L2 为 49,152KB | 前者按 SM，后者为本 SKU 全 GPU 配置 | `[2, pp. 8, 12, 40]` |
| 片内互联 | 未公开 | 白皮书说明 GPC/TPC/SM 层次，但没有披露 AD104 NoC 拓扑、带宽或一致性 | `[2, pp. 7-12]` |
| 内存控制器与 PHY | L4 配置 192-bit GDDR6 interface 与 PCIe x16 endpoint | 控制器数量、PHY 分区和 die 内拓扑未公开 | `[1, pp. 2-3, Tables 1-2]` |
| 工艺与物理规模 | TSMC 4N NVIDIA custom process | Ada GPU 工艺；AD104 die 面积与晶体管数未在所选资料中给出 | `[2, p. 12, 4N Manufacturing Process]` |
| 封装组成 | 一个 AD104 GPU 配 24GB GDDR6 ECC，安装在单槽低矮 PCIe 卡上 | package/interposer/基板细节未公开 | `[1, pp. 1-3]` `[2, pp. 39-40]` |
| 封装内互联 | 不适用 D2D；memory package 物理互联未公开 | 公开实现是单个 AD104 logic die，PCIe 是设备接口 | `[2, pp. 39-40]` |
| RAS | GDDR6 ECC 默认启用，可由软件关闭；GPU 提供 secure boot、secure firmware upgrade、rollback protection 与 secure application-processor recovery | ECC 是 SKU 配置；root of trust 属设备安全机制 | `[1, pp. 3, 7, Table 3]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 5 GPC、29 TPC、58 SM、7,424 CUDA Core、232 第四代 Tensor Core、58 第三代 RT Core；2 NVENC、4 NVDEC、4 JPEG decoder；MIG 不支持 | L4 单 GPU 实际配置；支持 time-sliced vGPU 与 SR-IOV，但不等同于 MIG | `[2, pp. 39-40, Appendix D, Table 5]` `[5, Recommended NVIDIA GPUs for NVIDIA vPC, Table 1]` |
| 时钟 | base 795MHz；boost 2,040MHz | PG193 SKU 200 | `[1, p. 2, Table 1]` |
| 理论峰值 | FP32 30.3TFLOPS；TF32 Tensor 60/120TFLOPS；BF16/FP16 Tensor 121/242TFLOPS；FP8 Tensor 242/485TFLOPS；INT8 Tensor 242/485TOPS；INT4 Tensor 484/969TOPS；RT Core 73.1TFLOPS | 斜杠前为 dense，后为 structured-sparsity effective；采用白皮书直接印出的整数，不从网页 headline 自行折半 | `[2, p. 40, Appendix D, Table 5 and note]` |
| 内存类型与容量 | 24GB GDDR6 ECC；6,251MHz；192-bit bus | ECC 默认开启，可由软件关闭 | `[1, p. 3, Tables 2-3]` |
| 内存带宽 | 300GB/s | 单卡 peak memory bandwidth | `[1, p. 3, Table 2]` |
| 主机接口 | 物理 x16 lanes；PCIe Gen4 x16/x8 或 Gen3 x16；当前产品页另列 PCIe Gen4 x16 64GB/s | 支持 lane/polarity reversal；64GB/s 原表未说明方向，保持厂商 headline 口径 | `[1, pp. 2, 6-7]` `[3, Product Specifications]` |
| 虚拟化与地址窗口 | SR-IOV 支持 32 个 VF；物理功能 PF 的 BAR1 为 32GiB，虚拟功能的 BAR1 合计 64GiB，即每 VF 2GiB | BAR 是 PCIe 地址窗口，不是新增显存容量，也不表示每个 VF 拥有独立的 2GiB 硬件内存分区；需要 SBIOS 与 OS/hypervisor 配合启用 SR-IOV | `[1, p. 3, Table 3; p. 6, Single Root I/O Virtualization Support]` |
| 设备互联端点 | 除 PCIe 外未找到 NVLink 或其他专用设备互联端点 | 多卡服务器需依赖主机 PCIe/外部网络，不把服务器结构写成卡内端点 | `[1, pp. 2, 6-7]` `[3, Product Specifications]` |
| 内存访问语义 | 未公开 | 所选资料没有说明统一地址、远端显存访问、页迁移或 cache coherence | `[1, pp. 2-7]` |
| 跨设备集合通信能力 | 未找到 | 没有公开卡内 collective engine；软件库支持不写入硬件卡 | `[1, pp. 1-7]` |
| 功耗 | 72W default/maximum，40W minimum total board power | 72W 是单卡上限，不是服务器聚合功耗 | `[1, p. 2, Table 1]` |
| 形态与散热 | 2.71-inch × 6.67-inch、single-slot low-profile PCIe 卡；passive bidirectional heatsink | 卡自身无风扇，支持左右两种系统气流方向 | `[1, pp. 1-2, 5, 7-8]` `[2, p. 40]` |

## 6. 系统级互联上下文

L4 是普通 PCIe 卡，没有公开专用 scale-up fabric。这里不为 1 至 8 GPU 服务器补写不存在的聚合架构。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 未找到专用 GPU-to-GPU scale-up endpoint | PCIe Gen4 x16 是每卡 host interface；不能写成 NVLink | `[1, pp. 2, 6-7]` |
| Scale-out | 未记录 | L4 没有集成 scale-out network endpoint，服务器 NIC 不下放成 GPU 属性 | `[1, pp. 1-7]` |
| 系统可靠性 | 未公开 | 单卡 secure boot 与 ECC 不等于服务器冗余或故障绕行 | `[1, pp. 3, 7]` |
| 相关系统 | Partner 与 NVIDIA-Certified systems 可配置 1 至 8 张 L4 | GPU 数量是服务器选项，不是单卡资源倍增 | `[3, Product Specifications]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| 完整 AD104 满配与物理规模 | 未公开 | Ada whitepaper 主体及 Appendix D | 只记录 L4 实际使能资源和共享 4N 工艺，不把相邻消费 SKU 倒推为完整 die |
| PCIe 64GB/s 方向 | 未公开 | 当前 L4 产品页只写 PCIe Gen4 x16 64GB/s | 原样保留 headline，不标成单向或双向 |
| Tensor 峰值舍入 | 已解释 | 白皮书给 242/485、484/969；产品页只展示 sparse headline 并说无稀疏时减半 | 采用白皮书直接给出的 dense/sparse 整数对，不产生 242.5 或 484.5 |
| 功耗术语 | 口径差异 | 产品简报写 total board power，产品页写 max TDP | 采用更具体的 72W maximum total board power，并保留 40W minimum |
| 内存与多卡语义 | 未公开 | 产品简报、架构白皮书与产品页 | 不推断统一内存、P2P、cache coherence 或 collective offload |
| MIG | 不支持 | 2026 vPC sizing guide 明确列 L4 `MIG Support: No`；产品简报列 SR-IOV 32 VF 与 vGPU | 记录 time-sliced vGPU/SR-IOV 与 MIG 是不同机制，不把 32 VF 当作 32 个 MIG instance |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA L4 GPU Accelerator Product Brief*，PB-11316-001_v01，2023-03-09 | 官方产品简报 | SKU/PCI ID、时钟、GDDR6、PCIe、SR-IOV、功耗、形态、散热与安全 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2023_NVIDIA_L4_GPU_Accelerator_Product_Brief_v01.pdf) |
| `[2]` | NVIDIA，*NVIDIA Ada GPU Architecture*，v2.02，2022 | 官方架构白皮书 | Ada SM、AD104/L4 实际资源、数值路径、cache、峰值、媒体引擎和工艺 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2022_NVIDIA_Ada_Architecture_Whitepaper.pdf) |
| `[3]` | NVIDIA，*NVIDIA L4 Tensor Core GPU* | 当前官方产品页 | 当前规格、PCIe headline、72W 与服务器选项 | <https://www.nvidia.com/en-us/data-center/l4/> |
| `[4]` | NVIDIA，*NVIDIA Launches Inference Platforms for Large Language Models and Generative AI Workloads*，2023-03-21 | 官方发布公告 | L4 发布日期与 AI video 定位 | <https://nvidianews.nvidia.com/news/nvidia-launches-inference-platforms-for-large-language-models-and-generative-ai-workloads> |
| `[5]` | NVIDIA，*NVIDIA Virtual PC: Sizing and GPU Selection Guide: Recommended NVIDIA GPUs for NVIDIA vPC*，更新于 2026-08-19 | 官方支持文档 | 单 GPU/board、24GB、72W、passive 形态与 MIG 不支持 | <https://docs.nvidia.com/vgpu/sizing/virtual-pc/latest/gpu-vpc.html> |
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

复核结论：NVIDIA L4 24GB 的 PG193 SKU 200 身份、AD104 实际使能资源、GDDR6、分精度峰值、PCIe、媒体引擎、功耗和物理形态已由 NVIDIA 一手资料固定。未公开的完整 AD104 配置、内存语义和多卡互联没有通过消费卡或服务器聚合值补齐。
