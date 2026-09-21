# AMD Instinct MI455X 模组资料卡

> 模板版本：0.2  
> 卡片状态：草稿，待独立复核  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AMD-MI455X`  
> 对象层级：封装模组（正式 `object_type=module`）  
> 建卡人：`m2_w3_mi455x_module`  
> 复核人：尚未复核

本卡中的 EAM 是 Enhanced Accelerator Module，即增强型加速器模组；XCD 是 accelerated compute die，即加速计算裸片；IOD 是 I/O die，即输入输出裸片；WGP 是 Work Group Processor，即工作组处理器；HBM 是 High Bandwidth Memory，即高带宽内存；RAS 是 Reliability, Availability and Serviceability，即可靠性、可用性和可维护性；LDS 是 Local Data Share，即本地数据共享存储。卡片只记录单个 MI455X 模组，不把 tray、rack 或 Helios 系统值除算后下放。

## 1. 对象和范围

| 字段 | 内容 | 事实或关系标识 |
|---|---|---|
| 厂商 | AMD | `FACT-M2W3-AMD-MI455X-VENDOR` |
| 产品系列 | AMD Instinct | `FACT-M2W3-AMD-MI455X-FAMILY` |
| 正式名称 | AMD Instinct MI455X | `FACT-M2W3-AMD-MI455X-NAME` |
| SKU | MI455X | `FACT-M2W3-AMD-MI455X-SKU` |
| 架构代际 | AMD CDNA 5 | `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` |
| 对象类型 | `module`；官方形态为 EAM module | `FACT-M2W3-AMD-MI455X-OBJECT-TYPE` |
| Launch date | 2026-07-23 | `FACT-M2W3-AMD-MI455X-RELEASE-DATE` |
| 当前产品状态 | `announced`；表示已公开宣布，不等于已出货、量产爬坡或一般可用 | `FACT-M2W3-AMD-MI455X-STATUS` |
| 首次可用日期 | `not_found` | `REQ-M2W3-AMD-MI455X-AVAILABILITY` |

架构代际来自正式 `implements_architecture` 关系，不另建架构文本事实。MI455X 专页含有面向推理、训练和微调的厂商定位，但这类营销语句没有进入本包 facts；它也不用于提前比较训练芯片和推理芯片。

本卡包含单个 MI455X 模组的身份、物理实现、公开矩阵与向量峰值、L2 与 HBM4、产品接口以及缺失字段。本卡不包含 `OBJ-AMD-HELIOS-72-MI455X` 的 72 模组构成、tray、机架算力、31 TB HBM4、机架通信、供电或冷却分配，也不包含 MI440X、MI430X、MI500、OAM（Open Accelerator Module，开放加速器模组）、PCIe（Peripheral Component Interconnect Express）卡或合作伙伴服务器。

### 1.1 与其他对象的关系

| 关系 | 对象 | 说明 |
|---|---|---|
| `implements_architecture` | `OBJ-AMD-CDNA5-ARCH` | 既有正式关系 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5`；CDNA 5 的执行模型、缓存、LDS 和指令机制留在架构卡中 |

brochure 给出的 8 个 XCD 和 2 个 IOD 是模组内数量事实。本包没有为这些裸片预留子对象，所以不临时创建 `package_contains_die` 关系，也不把 256 个 WGP 平均分配到各 XCD。

## 2. 物理实现

| 项目 | 原始值 | 规范化值 | 条件和作用域 | 事实或要求标识 |
|---|---:|---:|---|---|
| 制程 | TSMC 2nm/3nm；专页写 2 nm 与 3 nm FinFET | TSMC 2 nm 和 3 nm FinFET | 两种节点未在产品表中逐一映射到 XCD 或 IOD | `FACT-M2W3-AMD-MI455X-PROCESS` |
| 裸片组成 | 8 XCD、2 IOD | 8 个加速计算裸片、2 个 I/O 裸片 | 单个多芯粒 MI455X 模组 | `FACT-M2W3-AMD-MI455X-XCD-COUNT`；`FACT-M2W3-AMD-MI455X-IOD-COUNT` |
| 裸片面积 | 未给出 | `not_found` | 不从封装图估算 | `REQ-M2W3-AMD-MI455X-DIE-AREA` |
| 晶体管 | 320 Billion | $320\times10^9$ | 单个产品，十进制 billion | `FACT-M2W3-AMD-MI455X-TRANSISTORS` |
| 封装 | chiplet、stacked 3D hybrid-bonded compute dies、AMD Infinity Fabric、advanced CoWoS-L | 多芯粒封装；采用 CoWoS-L（台积电先进封装平台） | MI400 landing 中明确以 MI455X 为主语的句子 | `FACT-M2W3-AMD-MI455X-PACKAGE` |
| HBM 堆叠 | 12 stacks | 12 | 单个 MI455X | `FACT-M2W3-AMD-MI455X-HBM-STACKS` |
| HBM 总接口宽度 | 未给出 | `not_found` | 不由 12 stacks 反推 | `REQ-M2W3-AMD-MI455X-HBM-INTERFACE` |
| 峰值引擎时钟 | 2.4 GHz / 2400 MHz | $2.4\times10^9$ Hz | 峰值，不代表持续频率 | `FACT-M2W3-AMD-MI455X-CLOCK` |
| 功耗 | 未给出 | `not_found` | EAM 与液冷形态不能反推瓦数 | `REQ-M2W3-AMD-MI455X-POWER` |
| 形态和散热 | EAM module；Liquid / Direct Liquid Cooling | EAM 模组；液冷 | 只记录官方形态，不外推冷却能力 | `FACT-M2W3-AMD-MI455X-FORM-FACTOR`；`FACT-M2W3-AMD-MI455X-COOLING` |

## 3. 计算资源

### 3.1 单元组成

| 计算资源 | 数量 | 本卡能确认的内容 | 未作的推断 | 事实标识 |
|---|---:|---|---|---|
| WGP | 256 | 专页明确写 Work Group Processors | brochure 的 “256 Compute Units” 不被当成独立术语等价证明；不平均到每 XCD | `FACT-M2W3-AMD-MI455X-WGP-COUNT` |
| 矩阵路径 | 未公开物理单元数 | brochure 给出 10 条矩阵峰值路径 | 不把精度路径数当作硬件单元数 | `COMP-M2W3-AMD-MI455X-MATRIX` |
| 向量路径 | 未公开物理单元数 | brochure 给出 FP16、FP32、FP64 向量峰值 | 不从吞吐反推 lane 数 | `COMP-M2W3-AMD-MI455X-VECTOR` |
| 标量、控制与数据搬运 | 产品级定值未找到 | 架构机制只通过 CDNA 5 关系查看 | 不复制架构卡组件到产品卡 | `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` |

`COMP-M2W3-AMD-MI455X-MATRIX` 和 `COMP-M2W3-AMD-MI455X-VECTOR` 是用于挂接公开峰值的逻辑分组，不代表 AMD 公布了两个物理模块。

### 3.2 吞吐

brochure 的表题是 “AI PEAK THEORETICAL PERFORMANCE”。OCP 指 Open Compute Project；TFLOP/s 是每秒万亿次浮点运算，TOP/s 是每秒万亿次运算。因此下表都是单个 MI455X 的厂商理论峰值，不是实测或持续性能。单位按 brochure 原文保留；资料没有说明一次乘加计一次还是两次。

| 路径 | 厂商性能格式标签 | 稀疏口径 | brochure 精确值 | 专页值 | 条件说明 | 事实标识 |
|---|---|---|---:|---:|---|---|
| OCP matrix | MXFP4 | `not_specified` | 40,265 TFLOP/s | 40.3 PFLOP/s | 专页为舍入复核；未说明 dense/sparse 或计数规则 | `FACT-M2W3-AMD-MI455X-MXFP4-PEAK` |
| OCP matrix | MXFP6 | `not_specified` | 20,133 TFLOP/s | 20.1 PFLOP/s | 同上 | `FACT-M2W3-AMD-MI455X-MXFP6-PEAK` |
| OCP matrix | MXFP8 | `not_specified` | 20,133 TFLOP/s | 20.1 PFLOP/s | 同上 | `FACT-M2W3-AMD-MI455X-MXFP8-PEAK` |
| OCP matrix | FP8 | `not_specified` | 20,133 TFLOP/s | 20.1 PFLOP/s | 编码变体和稀疏口径未说明 | `FACT-M2W3-AMD-MI455X-FP8-PEAK` |
| matrix base column | FP16 | `not_specified` | 5,033 TFLOP/s | 5 PFLOP/s | 原表没有打印 dense | `FACT-M2W3-AMD-MI455X-FP16-MATRIX-BASE-PEAK` |
| matrix structured column | FP16 | `structured_sparse` | 10,066 TFLOP/s | 10.1 PFLOP/s | 稀疏图样未说明，不补成 2:4 | `FACT-M2W3-AMD-MI455X-FP16-MATRIX-SPARSE-PEAK` |
| vector | FP16 | `not_applicable` | 315 TFLOP/s | 315 TFLOP/s | 无 lane 数和累加格式 | `FACT-M2W3-AMD-MI455X-FP16-VECTOR-PEAK` |
| matrix base column | FP32 | `not_specified` | 315 TFLOP/s | 315 TFLOP/s | 原表没有打印 dense，也没有稀疏值 | `FACT-M2W3-AMD-MI455X-FP32-MATRIX-PEAK` |
| vector | FP32 | `not_applicable` | 315 TFLOP/s | 315 TFLOP/s | 厂商理论峰值 | `FACT-M2W3-AMD-MI455X-FP32-VECTOR-PEAK` |
| matrix base column | FP64 | `not_specified` | 5 TFLOP/s | 5 TFLOP/s | 原表没有打印 dense，也没有稀疏值 | `FACT-M2W3-AMD-MI455X-FP64-MATRIX-PEAK` |
| vector | FP64 | `not_applicable` | 5 TFLOP/s | 5 TFLOP/s | 厂商理论峰值 | `FACT-M2W3-AMD-MI455X-FP64-VECTOR-PEAK` |
| matrix base column | INT8 | `not_specified` | 5,033 TOP/s | 5 POP/s | 整数路径用 OP/s，不写成 FLOP/s | `FACT-M2W3-AMD-MI455X-INT8-MATRIX-BASE-PEAK` |
| matrix structured column | INT8 | `structured_sparse` | 10,066 TOP/s | 10.1 POP/s | 稀疏图样未说明 | `FACT-M2W3-AMD-MI455X-INT8-MATRIX-SPARSE-PEAK` |
| matrix base column | BF16 | `not_specified` | 5,033 TFLOP/s | 5 PFLOP/s | 原表没有打印 dense | `FACT-M2W3-AMD-MI455X-BF16-MATRIX-BASE-PEAK` |
| matrix structured column | BF16 | `structured_sparse` | 10,066 TFLOP/s | 10.1 PFLOP/s | 稀疏图样未说明 | `FACT-M2W3-AMD-MI455X-BF16-MATRIX-SPARSE-PEAK` |

本卡不把矩阵、向量或不同精度的峰值相加成“总算力”。公开资料也没有给出功耗模式、小矩阵利用率、动态形状损失或模型实测，因此不能把这些理论峰值解释为训练或推理吞吐。

## 4. 数值格式和累加

下表中的 MXFP4 等名称只是厂商性能表标签。本包没有找到 MI455X 产品级的 A/B 操作数编码、乘积格式、程序员可见累加、物理累加或输出编码证据。

| 路径组 | 已确认 | 程序员可见累加 | 物理内部累加 | 说明 |
|---|---|---|---|---|
| OCP MXFP4/MXFP6/MXFP8/FP8 matrix | 产品表有独立峰值行 | `not_found` | `not_found` | 产品表没有给 A/B 编码细节、累加或输出类型 |
| FP16/BF16/INT8 matrix | 有 base 与 structured-sparsity 两列 | `not_found` | `not_found` | 不由 2 倍峰值反推稀疏图样或累加位宽 |
| FP32/FP64 matrix 与 FP16/FP32/FP64 vector | 产品表有峰值行 | `not_found` | `not_found` | 不从厂商性能格式标签推导操作数、乘积、累加或输出格式 |

CDNA 5 白皮书可以解释架构代际的数值语义，但本包只通过 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 引用，不把架构级格式、指令或内部路径复制成 MI455X 产品事实。对应缺口是 `REQ-M2W3-AMD-MI455X-ACCUMULATION` 和 `REQ-M2W3-AMD-MI455X-PHYSICAL-ACCUM`。

## 5. 存储层次和数据搬运

| 层级 | 实例和作用域 | 容量 | 公开带宽 | 方向和性质 | 其他缺口 | 事实标识 |
|---|---|---:|---:|---|---|---|
| L2 cache | 单个 MI455X 产品级总量；实例数未公开 | 192 MB | 未找到 | 不适用 | 读写端口、bank、延迟、每周期传输量未找到 | `FACT-M2W3-AMD-MI455X-L2-CAPACITY` |
| HBM4 | 单个 MI455X，12 stacks | 432 GB | 23.3 TB/s | peak theoretical；读写方向未说明 | 总接口宽度、持续带宽、延迟未找到 | `FACT-M2W3-AMD-MI455X-HBM4-CAPACITY`；`FACT-M2W3-AMD-MI455X-HBM4-BW` |

GB、MB 和 TB 都按来源的十进制单位记录，不改写为 GiB、MiB 或 TiB。产品资料没有公开寄存器、LDS、WGP cache 等层级的产品启用容量和带宽；这些架构机制留在 CDNA 5 架构卡。也没有足够证据建立 DMA、异步复制、压缩或布局转换的 MI455X 产品级事实。

## 6. 计算与存储配比

本包不计算 MI455X 的产品级存算比。`FIELD-DER-COMPUTE-BW-SPEC` 要求同对象、同精度的矩阵稠密峰值除以铭牌带宽；当前 brochure 只给出基准列和结构化稀疏列，没有把基准列标成 dense，也没有给出 MI455X 产品级累加语义。HBM4 的 23.3 TB/s 虽然是同一模组的 peak theoretical 值，读写方向仍未说明。缺少这些前置条件时，算术可复算不代表派生字段合同成立。

| 候选分子 | 分母 | 未满足的前置条件 | 处理 |
|---|---:|---|---|
| OCP MXFP4、MXFP8 理论峰值 | 23.3 TB/s HBM4 | OCP 行的稀疏口径、操作数和累加语义未说明 | 不计算 |
| FP16、FP32 matrix base-column 理论峰值 | 23.3 TB/s HBM4 | 基准列未标成 dense，产品级累加语义未找到 | 不计算 |

L2 没有产品级带宽，也不计算 L2 的 FLOP/byte。容量/算力、矩阵/向量吞吐比和数据搬运/矩阵吞吐比同样不在本包派生。
## 7. 大模型相关特殊能力

| 能力组 | 本包结论 | 原因 | 结构化状态 |
|---|---|---|---|
| MoE（Mixture of Experts，混合专家）routing、Top-K、排序和采样 | 未找到 MI455X 专用硬件证据 | 产品页和 brochure 没有命名对应模块、指令或吞吐 | `REQ-M2W3-AMD-MI455X-SPECIAL-IMPLEMENTATION`：`not_found` |
| Attention、Softmax、归约和 KV Cache 管理 | 未找到产品级专用实现定值 | 支持相应软件工作负载不等于有专用硬件 | 不建 capability |
| 稀疏和跳零 | 只确认 FP16、INT8、BF16 的 structured-sparsity 峰值列 | 资料没有给稀疏图样或单独模块 | 作为 throughput 条件，不建专用引擎 |
| All-to-All 或集合通信卸载 | 未找到专用卸载单元证据 | 有 scale-up/scale-out 带宽不等于有集合通信引擎 | 不建 capability |
| 压缩、解压缩和格式转换 | 未找到产品级实现定值 | 不从 CDNA 5 架构机制下放 | 不建 capability |

## 8. 互联和系统扩展

UALoE 是 AMD 产品页用于 scale-up 端点的接口标签；UALink 是 Ultra Accelerator Link，即超加速器链路，同页把它写在 scale-out 行。本卡照录厂商标签，不自行改写协议归类。

| 层级 | 厂商标签 | 公开带宽 | 方向和性质 | 未公开或未采用 | 事实标识 |
|---|---|---:|---|---|---|
| 封装内 | AMD Infinity Fabric、高密度互联 | 未给数值 | 物理封装描述 | 不建片内拓扑 | `FACT-M2W3-AMD-MI455X-PACKAGE` |
| 主机接口 | CPU to GPU AMD Infinity Fabric | 256 GB/s | 方向、payload、峰值或持续口径均未说明 | 不补 PCIe 代际或带宽 | `FACT-M2W3-AMD-MI455X-CPU-GPU-BW` |
| Scale-up | UALoE | 3.6 TB/s | peak、bidirectional；按产品聚合值记录 | 链路数、单链路速率、payload 和拓扑未公开 | `FACT-M2W3-AMD-MI455X-SCALEUP-BW` |
| Scale-out | 产品页写 UALink | 600 GB/s | peak、bidirectional；按产品聚合值记录 | 不改写为 NIC 或机架二分带宽 | `FACT-M2W3-AMD-MI455X-SCALEOUT-BW` |

`topologies.csv` 保持空表，因为三个公开带宽值都不足以确定单链路数量、交换层级或拓扑。Helios 的 tray/rack 拓扑和 72 模组数量迁移为 0。

## 9. 软件、可靠性和实测补充

| 类别 | 内容 | 版本或条件 | 事实或要求标识 |
|---|---|---|---|
| 软件生态 | 产品页列出 ROCm（AMD 开放软件平台）生态和框架线索 | 没有形成最低版本或兼容矩阵 | `REQ-M2W3-AMD-MI455X-RUNTIME-VERSION`：`not_found` |
| ECC 与 RAS | Full-chip ECC（Error-Correcting Code，纠错码）memory、page retirement | brochure 固定版产品表 | `FACT-M2W3-AMD-MI455X-RAS` |
| 虚拟化和分区 | brochure 列出 SR-IOV（Single Root I/O Virtualization，单根 I/O 虚拟化）和四个 memory partitions | 本包未扩为结构化事实，待独立复核是否有必要增加 | deferred |
| 固定功能 | brochure 列出视频解码引擎和 JPEG/MJPEG cores | 不属于本工作包的核心比较字段，未建 facts | deferred |
| 微基准或实测 | 没有入选来源 | 不用理论峰值代替实测 | 无 |

## 10. 缺失、冲突和待核问题

### 10.1 缺失字段

| 字段 | 状态 | 检索记录 | 仍需要的证据 |
|---|---|---|---|
| 首次可用日期 | `not_found` | `SEARCH-M2W3-AMD-MI455X-AVAILABILITY` | 实际可用日期，不能只是 launch 或未来计划 |
| 单模组功耗 | `not_found` | `SEARCH-M2W3-AMD-MI455X-POWER` | 明确以 MI455X module 为主语的 TDP、TBP、典型值或上限 |
| 程序员可见累加 | `not_found` | `SEARCH-M2W3-AMD-MI455X-ACCUMULATION` | 产品/路径级接口或指令文档 |
| 物理累加器 | `not_found` | `SEARCH-M2W3-AMD-MI455X-PHYSICAL-ACCUM` | 产品级内部位宽或数值语义的一手说明 |
| MoE/Top-K 等专用实现 | `not_found` | `SEARCH-M2W3-AMD-MI455X-SPECIAL-IMPLEMENTATION` | 命名模块、指令、硬件路径或吞吐 |
| HBM 总接口宽度 | `not_found` | `SEARCH-M2W3-AMD-MI455X-HBM-INTERFACE` | 产品规格书中的 bit 宽度或通道定义 |
| die 面积 | `not_found` | `SEARCH-M2W3-AMD-MI455X-DIE-AREA` | XCD、IOD 或总裸片面积的一手定值 |
| 版本化 runtime | `not_found` | `SEARCH-M2W3-AMD-MI455X-RUNTIME-VERSION` | 最低 ROCm/runtime/compiler 版本和兼容范围 |

### 10.2 来源差异

当前没有登记为 unresolved conflict 的来源差异。brochure 的 40,265/20,133/5,033/10,066 TFLOP/s 是精确表值，专页的 40.3/20.1/5/10.1 PFLOP/s 是兼容舍入；规范事实采用固定 brochure 数字，专页断言标为 `qualifies`。早期第三方 19.6 TB/s 转述没有进入注册表，不能与截止日官方 23.3 TB/s 并列成正式冲突。

## 11. 最小参考资料

### 11.1 本卡入选来源

| 来源标识 | 来源角色 | 不可替代贡献 | 定位 | 状态 |
|---|---|---|---|---|
| `SRC-M2W3-AMD-MI455X-PRODUCT-20260813` | identity、core_spec | 当前 exact-object 页面；L2、WGP、晶体管、launch date、`announced` 状态语境、UALoE/UALink 标签和舍入复核 | HTML title、GPU Specifications、Board Specifications | `selected` |
| `SRC-M2W3-AMD-MI455X-BROCHURE-202607` | core_spec | 固定版本的精确峰值表、8 XCD、2 IOD、主机带宽和 RAS | p. 1 两张规格表 | `selected` |
| `SRC-M2W2-AMD-MI400-LANDING-20260813` | core_spec | 单个 MI455X 的 3D hybrid-bonded dies、Infinity Fabric、CoWoS-L 和 12 stacks 复核 | 固定 HTML 的 MI455X 产品段 | `selected` |
| `SRC-M2NA-AMD-CDNA5-WP` | architecture_mechanism | 支撑架构关系和架构级数值语义边界 | CDNA 5 白皮书相关章节 | `selected` |

反向移除运行是 `SELRUN-M2W3-AMD-MI455X-20260813`。删除任何一个成员，都会失去上表相应的独有覆盖。动态专页以后变化、事实集合调整或新增固定产品规格书时，必须重跑选择运行。

### 11.2 被覆盖或未采用的来源

| 来源 | 状态 | 原因 | 覆盖来源 |
|---|---|---|---|
| 专页与 brochure 的重叠规格 | `partially_covered` | 两者互相覆盖一部分，但动态 exact-object 信息与固定精确表各有独有贡献 | 见 `source-coverage.csv` 两条互向记录 |
| 媒体、论坛和早期 19.6 TB/s 转述 | `lead_only / rejected_unreliable` | 没有增加截止日一手事实，也不能填补功耗、可用日期或累加缺口 | 当前官方专页与 brochure |
| Helios brochure 第 2 页系统段 | `out_of_scope` | 主语是 tray、rack 或未来部署，不是单个 MI455X module | 不适用；迁移量 0 |

## 12. 完整度和复核

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | 身份、形态、launch date、`announced` 状态和架构关系已支持；实际可用日期缺失 |
| 物理实现 | `partial` | 制程、封装、die 数、晶体管、时钟、形态、散热和 HBM stacks 已支持；功耗、接口宽度和面积缺失 |
| 计算资源 | `partial` | WGP 数和矩阵/向量峰值已支持；没有物理矩阵单元数、per-die 速率或持续实测 |
| 数值格式 | `partial` | base 与 structured-sparsity 列分开；累加和物理内部语义缺失，因此不派生产品级存算比 |
| 存储层次 | `partial` | L2 与 HBM4 有容量，HBM4 有峰值带宽；其他层级和带宽主要留在架构卡或缺失 |
| 互联 | `partial` | 三个产品级带宽有条件；链路数、payload 与拓扑缺失 |
| 特殊能力 | `missing_public_data` | 没有 MI455X 专用 MoE routing、Top-K 等硬件证据 |
| 软件 | `partial` | 有生态线索，没有版本化 runtime 支持下限 |
| 来源证据 | `needs_review` | 四来源最小集和逐事实断言已暂存，尚未独立复核 |

自检：

- [x] 对象层级没有混用；Helios 系统事实迁移量为 0
- [x] 数字区分矩阵/向量、base/structured sparse、理论峰值/实测
- [x] 带宽保留方向和名义口径缺口
- [x] 支持格式、架构机制、专用硬件和公开峰值分开
- [x] 39 条直接事实都有 `source_checked` 断言
- [x] 8 个 `not_found` 要求都有检索日志和四来源检查结果
- [x] 不满足稠密和累加前置条件的 4 条派生链已全部删除
- [x] 四个入选来源都有反向移除理由
- [ ] 独立复核与总控合并验收

复核结论：同表头暂存校验和临时镜像 gate 验证已通过，尚待独立复核；本卡不构成正式合并。

数据校验：定点修复后，临时正式合并镜像在 `gate` 模式通过 32 张表和 102,752 项检查；正式 32 份 CSV 保持只读，哈希变化为 0。
