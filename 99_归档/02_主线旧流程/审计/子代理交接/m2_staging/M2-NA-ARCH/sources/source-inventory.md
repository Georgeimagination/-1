# 来源候选与独有贡献（阶段快照）

> 核对日期：2026-08-12。这里只记录 M2-NA-ARCH 的候选和筛选判断；正式来源 ID、最小集成员与筛除结论仍须总控合并后生效。

## NVIDIA

| 候选来源 | 对象 | 当前用途 | 独有贡献 | 反向移除判断 |
|---|---|---|---|---|
| NVIDIA A100 Tensor Core GPU Architecture Whitepaper，2020 | Ampere | 架构主来源，本地已有固定 PDF | 第三代 Tensor Core 的 FP16/BF16/TF32/FP64/INT8/INT4/Binary 路径，FP16/FP32 与 BF16/FP32 混合精度，2:4 稀疏，异步复制与异步屏障，统一 L1/共享内存，以及第三代 NVLink | 保留。若移除，Ampere 的矩阵路径、稀疏与异步搬运都失去同等强度的一手固定来源。A100 的启用单元、显存、总带宽和整卡峰值不进入架构卡。 |
| NVIDIA Ada GPU Architecture Whitepaper，2022 | Ada Lovelace | 架构主来源，本地已有固定 PDF | 第四代 Tensor Core、FP8 路径及 FP16/FP32 累加选项；统一 L1/共享内存；Ada 专用图形模块与 AI 计算路径的边界 | 保留。附录中的 RTX 4090 总吞吐、L2 容量与显存属于 SKU，不上卷到 Ada 架构对象。 |
| H100 Architecture Whitepaper v1.04、H100 Datasheet、Hopper Tuning Guide 13.3 | Hopper | 复用 M1 正式来源链 | M1 已覆盖 Hopper/H100 的执行、精度、TMA、DSM、DPX、Transformer Engine、存储与互联 | 不新建来源或事实。Hopper 卡只列复用标识和仍未解决的 MoE routing/top-k、片上带宽等缺口。 |
| NVIDIA Blackwell Architecture Technical Brief v2.1 | Blackwell | 架构主来源，本地已有固定 PDF | 第五代 Tensor Core 与 FP4/FP6/FP8 等格式、第二代 Transformer Engine、NV-HBI/NVLink 5 机制和 RAS | 保留。它是 Blackwell 架构机制的主来源。双裸片、NV-HBI 10 TB/s 和 GB200 解压引擎/800 GB/s 的主语属于封装或具体实现，已移到 implementation backlog；Ultra 增量不从本简报隐式继承。 |
| NVIDIA Blackwell Platform，Hot Chips 36，2024 | Blackwell | 架构补充来源，本地已有固定 PDF | micro-tensor 缩放方式与第二代 Transformer Engine 的演讲级说明 | 保留为补充。当前三条缩放/Transformer Engine 事实只有本演讲给出所需粒度；封装和解压实现信息不写入架构事实。 |
| PTX ISA 9.3 | Blackwell | 指令与存储语义补充，官方动态文档 | 五代 Tensor Core 专用 Tensor Memory 的组织与动态分配、`tcgen05.cp` 搬运、`tcgen05.mma.sp` 的稀疏粒度与块缩放语义 | 保留为开发文档角色。它补足技术简报未公开的程序员可见存储和指令语义；不把 PTX 虚拟 ISA 直接当作未声明的物理位宽。 |
| Blackwell Tuning Guide 12.8 | Blackwell | 软件映射与继承关系补充，本地已有固定 PDF | Thread Block Cluster、Distributed Shared Memory、统一 L1/纹理/共享内存和第五代 NVLink 的 CUDA 映射 | 暂不进入核心最小集。所选共享机制多为 Hopper 继承或可由 PTX/CUDA 文档覆盖；仅在卡片需要 CUDA 调优定位时保留角色。 |
| NVIDIA Blackwell Datasheet，OCT25 | Blackwell | 物理 SKU/系统边界核对，本地已有固定 PDF | 当前 Blackwell GPU 与系统配置、产品级显存和互联值 | 对架构卡建议移除。主要是产品和系统汇总，且架构核心机制已由技术简报覆盖；后续 SKU/系统卡可以重新评估。 |
| Making Softmax More Efficient with NVIDIA Blackwell Ultra，2026-02-25 | Blackwell Ultra | 代际差异主来源，官方动态网页 | Blackwell Ultra 的 SFU 指数运算吞吐相对 Blackwell 提升 2 倍，并明确 `MUFU.EX2` 与 softmax 的映射 | 保留。它把“attention-layer compute 提升”落实到具体 SFU 路径，技术简报只给了更概括的描述。 |
| Inside NVIDIA Rubin GPU Architecture，2026-07-21 | Rubin | 截止日前最新官方架构主来源 | 双裸片 NV-HBI、增强 TMA 的 inline descriptor update、K 维吞吐翻倍、3-bit LUT 权重、激活稀疏与压缩、指数吞吐、细粒度依赖触发、NVLink counted writes | 保留。Rubin 尚无同等粒度的固定白皮书；对象仍按 observation 处理，产品级 SM/HBM/整卡峰值不写入架构卡。 |

## AMD

| 候选来源 | 对象 | 当前用途 | 独有贡献 | 反向移除判断 |
|---|---|---|---|---|
| AMD CDNA 2 Architecture White Paper | CDNA 2 | 架构主来源；已下载 staging 固定 PDF | CU 内标量、向量、矩阵路径，Wave64 与 4×16-wide SIMD，FP64 Matrix Core，LDS 原子，封装内 Infinity Fabric 与互联类型 | 保留。MI200 的启用 CU、显存和整卡带宽不写入架构卡。 |
| AMD Instinct MI200 CDNA 2 ISA Reference | CDNA 2 | 精度语义补充，官方固定 PDF 入口 | MFMA 命名直接区分 A/B 与 C/D 格式，可核验程序员可见累加格式 | 保留为开发文档角色；白皮书没有系统给出累加接口语义。由于使用条款限制，本包不下载或复制整份 ISA。 |
| Introducing AMD CDNA 3 Architecture White Paper | CDNA 3 | 架构主来源；已下载 staging 固定 PDF | XCD/CU 组织、FP8/TF32 与稀疏 Matrix Core、L1/LDS/L2/Infinity Cache 层次及片上带宽、四代 Infinity Fabric | 保留。MI300A、MI300X 和 MI325X 的 HBM、XCD 数与系统拓扑留给物理对象或 SKU 卡。 |
| AMD Instinct MI300 CDNA 3 ISA Reference，2025-08-05 | CDNA 3 | 精度与稀疏语义补充，官方固定 PDF 入口 | FP8/BF8、FP16/BF16 的 MFMA C/D 为 FP32，INT8 的 C/D 为 INT32；V_SMFMAC 的 4:2 结构化稀疏定义 | 保留为开发文档角色。白皮书能证明格式与稀疏支持，但不能替代累加接口定位。 |
| Introducing AMD CDNA 4 Architecture White Paper | CDNA 4 | 架构主来源；已下载 staging 固定 PDF | MXFP8/MXFP6/MXFP4 硬件支持、TF32 改为 BF16 软件模拟、2 倍 transcendental rate、160 KB LDS 与 256 B/clk 读带宽、L1/L2/Infinity Cache、Infinity Fabric 链路 | 保留。产品级总吞吐、HBM3E 和整卡链路汇总不进入架构卡。 |
| AMD CDNA 4 ISA Reference | CDNA 4 | 精度、舍入与稀疏语义补充，官方固定 PDF 入口 | FP8/BF8 稠密与稀疏 MFMA 的 FP32 C/D、INT8 的 INT32 路径、稀疏矩阵布局和格式转换舍入 | 保留为开发文档角色。白皮书未给完整累加与舍入语义；本包不下载或复制整份 ISA。 |
| Introducing AMD CDNA 5 Architecture White Paper | CDNA 5 | 架构主来源；已下载 staging 固定 PDF | Wave32 WGP、四个 32-thread SIMD 与四个标量单元、BF16 向量、缩放块 16/32、TDM 异步搬运与 DRAM↔LDS 直达、多播、LDS/缓存层次、UALoE/Infinity Fabric 边界 | 保留。白皮书大量数字属于 MI455X；卡片只抽取明确属于 CDNA 5 共享机制的部分。 |
| AMD CDNA 5 ISA Reference，2026-07-27 | CDNA 5 | 精度、累加、缩放与稀疏语义补充；官方固定 PDF 入口 | FP4/FP6/FP8 及 BF8 的 WMMA 输入、FP32 或 FP16 C/D 路径、INT8→INT32、block-scale 16/32、RNE 舍入，以及 2:4 稀疏 SWMMAC 的程序员可见语义 | 保留为开发文档角色。它补足白皮书没有给出的 C/D 累加接口、指令 tile 和稀疏限制；因 832 页且附使用协议，本包只登记官方入口和定位，不复制整份 PDF。 |
| AMD CDNA Architecture landing page | CDNA 2/3/4/5 | 代际身份与当前状态核对，官方动态网页 | 官方把 CDNA 2/3/4/5 分别映射到 MI200/MI300/MI350/MI400 系列，并给出 CDNA 5 的计划边界 | 只作身份和状态来源。对微架构事实可由各代白皮书覆盖，不单独进入架构机制最小集。 |
| AMD CES 2026 press release / official deck | CDNA 6 | 未来架构身份来源 | 明确 AMD 已正式使用 CDNA 6 名称，并说明 MI500 产品系列计划采用该架构 | 保留官方新闻稿作身份与状态证据。2 nm、HBM4E 和计划 2027 年发布的谓词主语是 MI500 产品或实现，不写成 CDNA 6 架构事实。官方 deck 下载在 60 秒远程传输时超时并形成损坏半成品，已删除；网页入口仍可复核。 |

## 当前固定资料候选

staging 已保存并完成 PDF 可读性核对的四份 AMD 白皮书：CDNA 2（17 页，SHA-256 `62125a4a3f00e653556ca98c178712496b241e5c3d8a4edadee7578944c2cc6d`）、CDNA 3（28 页，`a0811d04f101f9127bd183d6e228f462b6fd988b0e0e6d263a25e4bed712f593`）、CDNA 4（21 页，`7ebf89edb9b82198b9edea7bb37eb7fe7c998842257eb21ef7a459a87774a4b2`）和 CDNA 5（24 页，`2381d60185f79989d3d5e4260c86f72504fcab256b40bb85fe4a6dd782afb3ef`）。NVIDIA 固定 PDF 已在项目正式资料池中，不在 staging 复制。