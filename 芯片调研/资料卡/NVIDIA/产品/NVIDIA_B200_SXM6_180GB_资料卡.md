# NVIDIA B200 SXM6 180GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡的主语是一个 NVIDIA B200 SXM6 180GB GPU 模组。HGX B200 与 DGX B200 是八 GPU 系统；GB200 Grace Blackwell Superchip 是两个 Blackwell GPU 加一个 Grace CPU 的更高层对象；GB200 NVL72 是 72 GPU rack-scale 系统。这些聚合值不属于本 SKU。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | B200 SXM6 180GB | `[1, p. 8, Individual Blackwell GPU Specifications]` `[6, p. 7]` |
| 产品家族 | NVIDIA Blackwell B200 Tensor Core GPU | 非 Blackwell Ultra B300 | `[4, A Massive Superchip]` |
| 完整 SKU | NVIDIA B200 SXM6 180GB | 单 GPU 模组；官方信任计算文档明确列为 SXM6 180GB HBM3e | `[6, p. 7, supported hardware SKUs]` |
| 对象形态 | SXM6 GPU 模组 | 不是 PCIe 卡或 HGX baseboard | `[6, p. 7]` |
| 架构代际 | NVIDIA Blackwell，Compute Capability 10.0 | B200 | `[3, §1.4 and Revision History]` |
| 发布与可用状态 | 2024-03-18 发布 Blackwell 平台、B200 和 HGX B200，当时称合作伙伴产品将于 2024 年晚些时候供应；当前 NVIDIA 文档继续支持 HGX B200/B200 SXM6 | 发布日与合作伙伴系统供货分开 | `[4, page header, A Massive Superchip and Global Network of Blackwell Partners]` `[6, p. 7]` |
| 厂商定位 | 面向 generative AI、LLM training/inference、data analytics 与 HPC 的数据中心 GPU | 厂商产品范围，不引入 benchmark 比较 | `[1, pp. 1, 6-7]` |
| 产品目标 | 以第五代 Tensor Core、第二代 Transformer Engine、NV-HBI 双裸片统一 GPU、HBM3e 和第五代 NVLink 提高计算与 scale-up 能力 | 单 GPU 实现与系统互联分层记录 | `[2, pp. 7-10]` |

本卡包含：B200 SXM6 180GB 的 Blackwell Core/die/package 实现、单 GPU 峰值、HBM3e、PCIe/NVLink 端点、MIG、功耗和模组形态。

本卡不包含：HGX/DGX B200 的八卡聚合值、NVSwitch 数量、host CPU/NIC，GB200 Superchip 的 Grace CPU/LPDDR5X/NVLink-C2C，以及 GB200 NVL72 的 rack-scale 指标。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Blackwell SM、第五代 Tensor Core、第二代 Transformer Engine | 与 GB200 中的 Blackwell GPU 共享架构，具体配置不同 | 复用 [Blackwell 架构资料](../架构/NVIDIA_Blackwell_架构.md) | `[2, pp. 8-9]` |
| die / chiplet | 两个 reticle-limited GPU die，以 NV-HBI 连成一个 coherent GPU | Blackwell B200 实现 | `[2, pp. 7-8]` |
| package | 双 GPU die、NV-HBI 与 180GB HBM3e 的 B200 SXM6 实现 | 与 PCIe 卡/系统配置不同 | `[1, pp. 8-9]` `[6, p. 7]` |
| 产品 SKU | NVIDIA B200 SXM6 180GB | 不适用 | 正式比较单位 | `[1, p. 8]` `[6, p. 7]` |
| 相关系统 | HGX B200 partner/NVIDIA-Certified Systems，8 GPU | 多种部署 | 只记录单 GPU 端点与 8-GPU NVLink 域的边界 | `[1, p. 8, Server Options]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵与数值路径 | Blackwell 架构支持 FP64、FP32、TF32、FP16、BF16、FP8、INT8、FP6 和 FP4；第二代 Transformer Engine 使用 micro-tensor scaling 和动态范围管理 | Table 1 是架构数据类型表，不能全归入 Tensor Core；Tensor 与 non-Tensor 路径按 SKU 性能表分别记录 | `[2, pp. 8-9, Table 1]` |
| 执行模型与调度 | CC 10.0 每 SM 最多 64 concurrent warps、32 thread blocks；register file 为 64K 个 32-bit register；B200 可 opt-in 16-block nonportable Thread Block Cluster | 共享 B200 SM 程序员可见上限，不表示全 GPU SM 数 | `[3, §1.4.1.1-§1.4.1.2]` |
| 局部存储 | 每 SM 最大 256KB combined L1/texture/shared memory，shared-memory capacity 228KB，单 block 最多可寻址 227KB | cache/shared-memory carveout 由软件选择 | `[3, §1.4.2.3]` |
| Tensor Memory | PTX 提供 tcgen05 Tensor Memory 动态分配和 MMA 数据通路 | 程序员可见 scratchpad；不把逻辑地址空间写成 GPU 物理 SRAM 总量 | `[9, §§9.7.18.1.2, 9.7.18.7.1 and 9.7.18.10]` |
| 稀疏、专用与 RAS | 支持 structured-sparse Tensor Core operation；有专用 Decompression Engine 和 RAS Engine | B200 规格表明确 Decompression Engine=Yes；峰值的 sparse/dense 口径另列 | `[1, pp. 8-9]` `[2, pp. 11-12]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 物理组织 | 两个 reticle-limited GPU die 在一个 package 中统一为一个 coherent GPU | 两个 die 不是两个独立 SKU/GPU | `[2, pp. 7-8]` `[1, p. 9, AI Superchip]` |
| die-to-die 互联 | NVIDIA High-Bandwidth Interface（NV-HBI）10TB/s chip-to-chip | 封装内 D2D；不是 NVLink 设备端点 | `[2, pp. 7-8]` |
| 工艺与晶体管 | custom TSMC 4NP；整个 Blackwell GPU 约 208 billion transistors | 整个双裸片 GPU，不是每个 die 各208B | `[1, p. 9]` `[2, p. 7]` |
| 实际计算资源 | B200 实际使能 148 SM；GPC/TPC、CUDA Core、Tensor Core 与 L2 实际总数未在 per-GPU 规格表中列出 | 148 SM 是 NVIDIA CUDA MPS 技术文章对 HGX B200 的直接披露；Tuning Guide 将 126MB L2 明确写给“GB200 GPU”，本卡不自动改挂 | `[8, MLOPart device capabilities and characteristics, Streaming multiprocessor count]` `[3, §1.4.2.2]` |
| 封装内 HBM | 180GB HBM3e，peak 7.7TB/s | HBM stack 数、bus width、interposer 细节未找到 | `[1, p. 8]` |
| RAS 与安全 | 专用 RAS Engine；Confidential Computing、TEE-I/O 与 NVLink inline protection | Blackwell 单 GPU 实现 | `[1, p. 9]` `[2, pp. 9, 11-12]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 148 SM；7 NVDEC、7 nvJPEG、Decompression Engine；Core/Tensor/L2 总数未公开 | 148 SM 来自 NVIDIA 对 HGX B200 normal GPU 的直接说明；decoder/decompression 为 Individual Blackwell GPU 规格 | `[8, Streaming multiprocessor count]` `[1, p. 8]` |
| 时钟 | 未公开 | 不从峰值反推 clock | `[1, p. 8]` |
| 理论峰值 | NVFP4 Tensor 18 sparse / 9 dense PFLOPS；FP8/FP6 Tensor 9 sparse / 4.5 dense PFLOPS；INT8 Tensor 9 sparse / 4.5 dense POPS；FP16/BF16 Tensor 4.5 sparse / 2.2 dense PFLOPS；TF32 Tensor 2.2 sparse / 1.1 dense PFLOPS；FP32 75TFLOPS；官方合并标签“FP64 Tensor Core / FP64”为 37TFLOPS | dense/sparse 对取 Technical Brief Table 3 的官方直接显示值；FP16 dense 按表中四舍五入的 2.2，不自行写成2.25；不拆分合并 FP64 标签 | `[2, pp. 25-26, Table 3, Per GPU Specs]` `[1, p. 8, notes 1-2]` |
| 内存 | 180GB HBM3e，7.7TB/s | 单 GPU；Tuning Guide 也明确 B200 最多 180GB HBM3/HBM3e | `[1, p. 8]` `[3, §1.4.2.1]` |
| 主机接口 | PCIe Gen5 128GB/s | 官方表没有在数值旁明说单向或双向 | `[1, p. 8, Interconnect]` |
| 设备互联端点 | 第五代 NVLink，18 links，每 link 每方向 50GB/s，每 GPU 1.8TB/s bidirectional | B200 单 GPU endpoint；NVSwitch 在 SXM6 模组外 | `[2, p. 10, Fifth-Generation NVLink and NVLink Switch]` `[1, p. 8]` |
| 内存访问语义 | NV-HBI 将两个 die 统一为 coherent GPU；NVLink peer transfer 在 CUDA 中需用 peer-access API 启用 | 前者是 package 内语义，后者是 GPU 间语义 | `[2, pp. 7-8]` `[3, §1.4.3]` |
| 跨设备集合通信 | 单 GPU 未找到独立 collective engine；SHARP FP8 属于外部 NVLink Switch 能力 | 不下放为 SXM6 模组内单元 | `[1, p. 9, NVLink and NVLink Switch]` |
| 功耗 | configurable up to 1,000W | 单 GPU maximum TDP，不是 HGX/DGX 系统功耗 | `[1, p. 8]` |
| 形态与散热 | SXM6 模组；具体风冷/液冷由 HGX/OEM 系统配置决定 | 官方文档同时列出 HGX B200 AC 与 PC 配置；原支持表未展开 PC 的含义，不把系统散热写成模组固定属性 | `[6, p. 7]` |
| MIG | 最多 7 instances；profiles 为 1g.23gb、1g.23gb+me、1g.45gb、2g.45gb、3g.90gb、4g.90gb、7g.180gb | B200 180GB；profile 表同时给出各实例的 SM/L2 fraction 和 media/copy engine 分配 | `[5, B200 MIG Profiles, Table 5]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | HGX B200 使用 8 个 B200 GPU 和外部 NVLink/NVSwitch；官方表的 total NVLink bandwidth 为 14.4TB/s | 本 SKU 只提供 1.8TB/s per-GPU endpoint；14.4TB/s 不是单模组值 | `[1, pp. 6, 8]` |
| Scale-out | HGX B200 系统可搭配 InfiniBand/Ethernet networking | NIC 和 scale-out fabric 不在 B200 SXM6 模组内 | `[4, A Massive Superchip]` |
| 相关系统 | HGX B200 partner 与 NVIDIA-Certified Systems，8 GPU | 1.4TB HBM3e、62TB/s memory bandwidth、144/72 PFLOPS FP4 都是八卡系统值 | `[1, pp. 6, 8]` |
| 更高层对象 | GB200 Superchip 把两个 Blackwell GPU（配置有别于 B200 SXM）和 Grace CPU 通过 NVLink-C2C 连接；NVL72 包含 72 GPU/36 CPU | Superchip 与 rack-scale 数据不写入本 SKU 属性 | `[4, A Massive Superchip]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| B200 GPC/TPC/Core/L2 | 未找到直接 per-SKU 数值 | Blackwell datasheet、Technical Brief、Tuning Guide、MIG Guide；SM 数已由 NVIDIA 技术文章固定为 148 | 不用峰值反推；Tuning Guide 的“GB200 GPU 126MB L2”保持原主语 |
| clock | 未公开 | 上述 per-GPU 官方资料 | 不用系统测得 clock 或第三方数据库补齐 |
| HBM 带宽 | 版本/口径差异 | 2025-10 datasheet 为 7.7TB/s；当前 Enterprise RA Components 页为 up to 8TB/s | 主规格采用对于 Individual HGX B200 GPU 的 7.7TB/s，保留当前页面的 up-to 口径 `[7, Table 1]` |
| B200 HBM 容量 | 官方文档口径差异 | Technical Brief v2.1 Table 3 写 up to 192GB；2025-10 datasheet、当前 MIG Guide 和 HGX 支持文档对本 SKU 为 180GB | 本卡固定 180GB SKU，不用192GB up-to 值回填 |
| FP64 峰值 | 官方合并标签 | datasheet 只列“FP64/FP64 Tensor Core 37TFLOPS” | 不拆分成 CUDA FP64 与 Tensor FP64 两个独立规格 |
| PCIe 128GB/s 方向 | 未在表中明说 | Blackwell datasheet p. 8 | 原样记录，不自行标成单向或双向 |
| 模组散热 | 由系统决定 | B200 信任计算支持列表同时有 AC/PC 系统 | 只写 SXM6 与 1,000W TDP，不固定为某一散热方式 |
| NVLink/NVSwitch | 对象层级差异 | 1.8TB/s per GPU 对 14.4TB/s HGX B200 total | 分别写入 SKU 端点和系统上下文 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA Blackwell Datasheet*，4204213，2025-10 | 官方 datasheet | B200 单 GPU 峰值、HBM3e、NVLink/PCIe、MIG、media、decompression、power 和系统边界 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2025_NVIDIA_Blackwell_Datasheet_4204213_OCT25.pdf) |
| `[2]` | NVIDIA，*NVIDIA Blackwell Architecture Technical Brief*，v2.1 | 官方架构技术简报 | 双裸片/NV-HBI、第五代 Tensor Core、Transformer Engine、NVLink、Decompression/RAS 与安全 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/NVIDIA_Blackwell_Architecture_Technical_Brief_v2.1.pdf) |
| `[3]` | NVIDIA，*Blackwell Tuning Guide* | 当前官方 CUDA 文档 | CC 10.0 SM occupancy、cluster、L1/shared memory、HBM 和 NVLink 程序语义 | <https://docs.nvidia.com/cuda/blackwell-tuning-guide/> |
| `[4]` | NVIDIA，*NVIDIA Blackwell Platform Arrives to Power a New Era of Computing*，2024-03-18 | 官方发布公告 | 发布时间、B200/HGX/GB200/NVL72 边界与初始供货计划 | <https://nvidianews.nvidia.com/news/nvidia-blackwell-platform-arrives-to-power-a-new-era-of-computing> |
| `[5]` | NVIDIA，*MIG User Guide: Supported GPUs and B200 MIG Profiles* | 当前官方开发文档 | B200/GB100/180GB/7-instance 身份与各 MIG profile | <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html>；<https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-mig-profiles.html> |
| `[6]` | NVIDIA，*NVIDIA Trusted Computing Solutions R595 GA Release Notes*，RN-12817-001_v02 | 官方支持文档 | HGX B200 的 B200 SXM6 180GB HBM3e 形态与当前支持 | <https://docs.nvidia.com/595trd1-trusted-computing-solutions-release-notes.pdf> |
| `[7]` | NVIDIA，*HGX AI Factory: Components* | 当前官方参考架构 | B200 SXM 单 GPU 与 HGX B200 节点的容量/带宽边界 | <https://docs.nvidia.com/enterprise-reference-architectures/hgx-ai-factory/latest/components.html> |
| `[8]` | NVIDIA，*Boost GPU Memory Performance with No Code Changes Using NVIDIA CUDA MPS*，2025-12-16，2026-06 更新 | 官方 CUDA 技术文章 | HGX B200 每 GPU 实际 148 SM，以及双 die MLOPart/NV-HBI 边界 | <https://developer.nvidia.com/blog/boost-gpu-memory-performance-with-no-code-changes-using-nvidia-cuda-mps/> |
| `[9]` | NVIDIA，*Parallel Thread Execution ISA* | 官方指令集文档 | tcgen05 Tensor Memory 地址、分配与 MMA 路径 | <https://docs.nvidia.com/cuda/parallel-thread-execution/#tensor-memory-allocation> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 HBM、设备互联和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：NVIDIA B200 SXM6 180GB 的单 GPU 主语、双裸片/NV-HBI 封装、148 SM、分精度峰值、180GB HBM3e、7.7TB/s、PCIe/NVLink、MIG、1,000W TDP 和 SXM6 形态已由 NVIDIA 一手资料固定。HGX/DGX、GB200 Superchip 和 NVL72 聚合值没有下放到本 SKU；未公开的 GPC/TPC/Core/L2 与 clock 保持缺失。
