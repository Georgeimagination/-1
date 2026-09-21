# 已判缺口与对象边界（阶段快照）

> 核对日期：2026-08-12。本记录区分“厂商明确未公开”“完成本轮计划检索仍未找到”“尚待动态资料核验”和“不适用于架构对象”。具体状态会在 `structured/field-requirements.csv` 逐字段落表；这里先保存判断依据，避免长期任务只依赖会话上下文。

## 共用边界

本包的对象是架构代际，不是裸片、封装、加速卡、服务器或机架。某份白皮书即使同时给出架构机制和产品数字，也只抽取能明确归属于架构的机制、每执行单元的程序员可见能力或代际接口。启用单元数、整卡峰值、HBM 容量与总带宽、功耗、系统 GPU 数和机架聚合互联留给后续物理对象、SKU 或系统卡。

“没有找到专用 MoE routing 或 top-k 硬件”只表示本轮官方白皮书、架构简报、ISA 或开发文档未给出可核验的专用实现，状态记为 `not_found`；不能写成厂商确认不存在，也不能把软件库、专家并行或通用矩阵路径改写成专用硬件。只有来源明确说某项未公开时才用 `not_public`。

## NVIDIA

### Ampere

A100 架构白皮书可以支撑第三代 Tensor Core、标量/向量/矩阵执行路径、混合精度、2:4 稀疏、异步复制、统一 L1/共享内存和第三代 NVLink。架构级寄存器/L1/L2 的容量与带宽、各层存算比、Tensor Core 的物理累加器位宽、专用 MoE routing 与 top-k 模块没有在本轮一手架构来源中找到，拟记 `not_found`。A100 整卡的 SM、显存、L2、峰值与 NVLink 汇总不回填 Ampere。

### Hopper

Hopper 卡只复用 M1 的 H100/GH100 正式事实、组件、精度路径、TMA、DSM、DPX 和 Transformer Engine 来源链，不再建立重复事实。架构对象层仍缺专用 MoE routing/top-k、片上各层持续带宽和存算比；复用的 H100 数字不能直接上卷为所有 Hopper 实现共有的架构值。

### Ada Lovelace

Ada 白皮书可以支撑第四代 Tensor Core、FP8/FP16/BF16/TF32/INT8/INT4 路径、程序员可见的累加选项和统一 L1/共享内存。白皮书中的 RTX 4090 峰值、启用单元、L2 容量与显存属于 SKU。架构级片上带宽、存算比、物理累加器位宽、专用 MoE routing/top-k 和数据中心互联拓扑均未找到可靠一手定值，拟记 `not_found`；图形专用模块不因为可用于 AI 工作负载就改记为大模型专用模块。

### Blackwell

技术简报与 Hot Chips 资料可以支撑第五代 Tensor Core、微张量缩放、第二代 Transformer Engine、NV-HBI/NVLink 5 机制和 RAS；PTX ISA 可以补足 Tensor Memory 和 `tcgen05` 指令语义。双计算裸片、NV-HBI 10 TB/s，以及简报中以 GB200 为主语的解压引擎、编解码器和 800 GB/s 均属于封装或具体实现，已经移到 `implementation-fact-backlog.csv`，不挂架构对象。具体 GPU 的 HBM 容量/带宽、SM 数和整卡峰值同样不进入架构卡。Tensor Memory 的程序员可见 32-bit cell 是每 CTA 逻辑地址空间组织，不等于物理总容量或累加器位宽。专用 MoE routing/top-k 模块、架构级 L1/L2 带宽和各层存算比在本轮官方资料中未找到，记 `not_found`。

### Blackwell Ultra

Blackwell Ultra 只记录官方直接归于 Ultra 的公开增量，不在没有对象关系的情况下隐式继承或复制 Blackwell 共有事实。技术简报给出 attention 新指令的概括描述，2026 年 NVIDIA 开发者文章进一步把 softmax 加速定位到 SFU 的指数运算路径和 `MUFU.EX2`。若总控以后建立正式 `successor_of` 或其他复用关系，共有机制才可沿该关系读取。除此之外，Ultra 专属的缓存层次、片上带宽、矩阵累加接口、专用 MoE routing/top-k 与物理实现细节没有独立公开到可建立原子事实的程度，分别拟记 `not_found` 或 `pending_verification`，不从 GB300 等 SKU 值倒推。

### Rubin

截至 2026-08-12，Rubin 只有 NVIDIA 开发者文章达到本包需要的微架构粒度，因此作为 `observation` 卡处理。架构事实记录第三代 Transformer Engine、TMA inline descriptor update、矩阵 K 维吞吐提升、3-bit LUT 权重、激活稀疏与压缩、指数路径和 NVLink counted writes。双裸片及其中的 NV-HBI 只说明具体实现，已下沉 `implementation-fact-backlog.csv`。缓存容量与带宽、内存层次的架构通用定值、程序员可见累加精度、完整格式矩阵、MoE routing/top-k 专用模块和互联有效载荷仍待后续固定白皮书或 ISA 核验，拟记 `pending_verification`；新闻中产品级 SM/HBM/整卡数字不进入架构卡。

## AMD

### CDNA 2

白皮书可支撑 CU 内标量、向量和矩阵路径、Wave64、4×16-wide SIMD、FP64 Matrix Core、LDS 原子与 Infinity Fabric 边界；MI200 ISA 可支撑 MFMA 的 A/B 与 C/D 格式语义。架构级 L1/L2 带宽、完整缓存容量、每层存算比、专用 MoE routing/top-k 和互联有效载荷未找到一手定值，拟记 `not_found`。MI200 的启用 CU、HBM、总峰值和封装级链路数不回填 CDNA 2。

### CDNA 3

白皮书可支撑 XCD/CU 组织、FP8/TF32 与 4:2 稀疏 Matrix Core、LDS/L1/L2/Infinity Cache 层次和明确标注的片上带宽；ISA 可支撑 FP8/BF8、FP16/BF16、INT8 的 C/D 格式。专用 MoE routing/top-k、累加器物理位宽与 Infinity Fabric 有效载荷未找到，拟记 `not_found`。凡依赖“最多 8 个 XCD”或 MI300X/MI325X 配置的容量与聚合带宽，合并时仍需总控确认是否应下沉至物理对象。

### CDNA 4

白皮书可支撑 MXFP8/MXFP6/MXFP4、TF32 的 BF16 软件模拟、transcendental 路径、格式转换、160 KB LDS 与每周期带宽、L1/L2 组织和 Infinity Fabric 单链路语义；ISA 可补足 MFMA 累加格式与稀疏布局。专用 MoE routing/top-k、物理累加器位宽和持续有效带宽未找到，拟记 `not_found`。MI350 系列的 HBM 与整卡聚合值不进入架构卡。

### CDNA 5

白皮书可支撑 Wave32 WGP、四个 SIMD 与四个标量单元、BF16 向量、MX 缩放块、TDM 异步搬运、多播、DRAM↔LDS 直达以及 LDS/缓存组织。白皮书中的 192 MB L2、54 TB/s 和 UALoE/HBM4 规模大多与 MI455X 实现绑定，不能直接当 CDNA 5 架构通用值。截至截止日已找到 2026-07-27 版 CDNA 5 ISA，可确认 WMMA 的 FP32/FP16 C/D、INT8→INT32、block-scale 16/32、RNE 舍入和 2:4 稀疏 SWMMAC；物理累加器位宽仍不能从程序员可见 C/D 格式倒推。专用 MoE routing/top-k 和互联有效载荷在白皮书、ISA 与官方架构页中仍未找到，拟记 `not_found`。

### CDNA 6

官方 CES 2026 新闻稿明确 CDNA 6 是下一代架构名称；2 nm、HBM4E 和计划于 2027 年推出的谓词主语是 MI500 产品或实现，不能写成 CDNA 6 架构事实。该来源也不能支撑执行组织、矩阵/向量/标量路径、精度与累加、缓存与带宽、互联拓扑或专用算子模块，因此本卡仅作未来架构观察，其余核心字段记 `pending_verification`。官方演示文稿下载在 60 秒远程传输中超时并形成损坏半成品，已核对路径后删除；这属于远程传输/工具超时，不是来源不存在。

## 合并时需要总控裁决的三处

第一，CDNA 3 白皮书同时给出每 XCD 与最多八个 XCD 的 L2/Infinity Cache 汇总，只有每 XCD 明确不随具体产品配置变化的值适合留在架构层；聚合值应优先下沉。第二，CDNA 4 的 Infinity Fabric 单链路位宽与速率看起来属于架构接口，但链路数量和卡级汇总可能受实现影响，建议总控合并时拆开。第三，Blackwell 的 Tensor Memory 是 PTX 可见的专用片上存储，适合建 `memory_level` 组件，但其组织数字应带上 PTX/compute-capability 条件，不能表述为所有 Blackwell SKU 的物理总容量。