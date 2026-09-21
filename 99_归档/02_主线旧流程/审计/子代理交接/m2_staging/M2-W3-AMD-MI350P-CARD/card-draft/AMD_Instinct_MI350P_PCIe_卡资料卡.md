# AMD Instinct MI350P PCIe 卡资料卡

> 模板版本：0.2  
> 卡片状态：修正后冻结，待最终独立复核  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AMD-MI350P`  
> 对象层级：加速卡（正式 `object_type=card`）  
> 建卡人：`m2_w3_mi350p_source_prep`；定点修正：`m2_w3_mi350p_remediation`  
> 复核人：尚未复核

本卡中的 PCIe 是 Peripheral Component Interconnect Express，即高速外设互联；CEM 是 Card Electromechanical，即 PCIe 卡机电规范；XCD 是 Accelerated Compute Die，即加速计算裸片；IOD 是 I/O Die，即输入输出裸片；CU 是 Compute Unit，即计算单元；HBM 是 High Bandwidth Memory，即高带宽内存；LLC 是 Last Level Cache，即末级缓存；TBP 是 Typical Board Power，即板卡典型功耗口径。

## 1. 对象和范围

| 字段 | 内容 | 事实或关系标识 |
|---|---|---|
| 厂商 | AMD | `FACT-M2W3-AMD-MI350P-VENDOR` |
| 产品系列 | AMD Instinct | `FACT-M2W3-AMD-MI350P-FAMILY` |
| 正式名称 | AMD Instinct MI350P PCIe | `FACT-M2W3-AMD-MI350P-NAME` |
| SKU | MI350P | `FACT-M2W3-AMD-MI350P-SKU` |
| 对象类型 | `card`；官方形态为 PCIe add-in card | `FACT-M2W3-AMD-MI350P-OBJECT-TYPE` |
| 架构 | AMD CDNA 4 | 既有关系 `OREL-AMD-MI350P-IMPLEMENTS-CDNA4` |
| 截止日状态 | `available`；官方文章在 2026-05-07 已写出 available | `FACT-M2W3-AMD-MI350P-STATUS` |
| 发布日期 | `not_found` | `REQ-M2W3-AMD-MI350P-RELEASE-DATE` |
| 首次可用日期 | `not_found` | `REQ-M2W3-AMD-MI350P-AVAILABILITY-DATE` |

`available` 只表示截至 2026-05-07 已有一手“available”措辞。该日期是本包能确认的最早证据日期，不等于首次供货日，也不能替代 release date。

本卡只记录单张 MI350P PCIe 卡。MI350X、MI355X OAM（OCP Accelerator Module，开放加速器模组）、MI350 Series 八 OAM 平台、服务器最多八卡以及机架聚合值均不在本卡范围。CDNA 4 的每 CU 缓存、每周期吞吐、指令与累加语义留在架构卡，通过既有关系引用，不复制到产品卡。

## 2. 物理实现

| 项目 | 原始值 | 规范化值 | 作用域和限制 | 事实或要求标识 |
|---|---:|---:|---|---|
| 制程 | TSMC 3nm / 6nm FinFET | TSMC 3 nm 和 6 nm FinFET | 两种节点没有在产品表中逐一映射到 XCD 或 IOD | `FACT-M2W3-AMD-MI350P-PROCESS` |
| 晶体管数 | 73 Billion | 73,000,000,000 | 产品页直接给出整卡对象值；不拆分到 XCD 或 IOD | `FACT-M2W3-AMD-MI350P-TRANSISTORS` |
| 裸片组成 | Four XCDs；1 IOD | 4 个 XCD、1 个 IOD | 单张卡；不采用白皮书中 MI350X/MI355X 的 8 XCD、2 IOD | `FACT-M2W3-AMD-MI350P-XCD-COUNT`；`FACT-M2W3-AMD-MI350P-IOD-COUNT` |
| 裸片面积 | 未给出 | `not_found` | 不从封装图或相邻 OAM 型号估算 | `REQ-M2W3-AMD-MI350P-DIE-AREA` |
| 峰值引擎时钟 | 2200 MHz / 2.2 GHz | $2.2\times10^9$ Hz | 峰值，不代表持续频率 | `FACT-M2W3-AMD-MI350P-CLOCK` |
| 最大 TBP | 600 W | 600 W | `max_tbp` 条件 | `FACT-M2W3-AMD-MI350P-POWER-MAX` |
| 可配置 TBP | 450 W | 450 W | 厂商没有给出软件、频率或工作负载条件 | `FACT-M2W3-AMD-MI350P-POWER-CONFIG` |
| 散热 | Passive | `passive` | 卡级散热；文章的 air-cooled systems 是服务器部署条件 | `FACT-M2W3-AMD-MI350P-COOLING` |
| 卡形态 | FHFL 2-slot PCIe CEM Card | 全高、全长、双槽 PCIe CEM 插卡 | 专页还给出 10.5 英寸（267 mm）长度 | `FACT-M2W3-AMD-MI350P-FORM-FACTOR` |
| HBM 总接口 | 4096-bit | 4096 bit | 产品页直接值，不由容量反推 | `FACT-M2W3-AMD-MI350P-HBM-INTERFACE` |
| HBM 堆叠数 | 未给出 | `not_found` | 不能由 144 GB 或 4096 bit 反推 | `REQ-M2W3-AMD-MI350P-HBM-STACKS` |

“被动散热卡”和“部署在风冷服务器中”描述的是不同层级，没有登记为冲突，也没有把 `air` 写成第二个卡级 cooling fact。

## 3. 计算资源和吞吐

### 3.1 产品级资源数

| 资源 | 数量 | 本卡能确认的内容 | 未作的推断 | 事实标识 |
|---|---:|---|---|---|
| CU | 128 | 专页直接给出整卡启用数量 | 不用每 XCD 32 CU 乘 4 重算 | `FACT-M2W3-AMD-MI350P-CU-COUNT` |
| Matrix Cores | 512 | 专页直接给出整卡数量 | 不反推单核心宽度或每周期运算数 | `FACT-M2W3-AMD-MI350P-MATRIX-CORE-COUNT` |
| Stream Processors | 8,192 | 专页直接给出整卡数量 | 不转换成 vector lane 数 | `FACT-M2W3-AMD-MI350P-STREAM-PROCESSOR-COUNT` |

`COMP-M2W3-AMD-MI350P-MATRIX` 和 `COMP-M2W3-AMD-MI350P-VECTOR` 还承担峰值路径分组。它们不是新增的物理模块。

### 3.2 单卡厂商理论峰值

PFLOP/s 是每秒千万亿次浮点运算，TFLOP/s 是每秒万亿次浮点运算，POP/s 是每秒千万亿次整数或通用运算。下表作用域都是单张卡，也都不是实测或持续性能。矩阵峰值由 2026-08-13 固定产品页直接支持；FP16、FP32、FP64 三条向量峰值由固定简报第 1 页的 `HPC Peak Performance (Estimated)` 表直接支持，产品页只交叉核对 72、72、36 TFLOP/s 数值。资料没有说明乘加计一次还是两次，因此 operation count rule 保持 `vendor_label`。

| 路径 | 稀疏口径 | 原始峰值 | 规范化值 | 事实标识 |
|---|---|---:|---:|---|
| MXFP4 matrix | `not_specified` | 4.6 PFLOP/s | $4.6\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-MXFP4-MATRIX-PEAK` |
| MXFP6 matrix | `not_specified` | 4.6 PFLOP/s | $4.6\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-MXFP6-MATRIX-PEAK` |
| MXFP8 matrix | `not_specified` | 2.3 PFLOP/s | $2.3\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-MXFP8-MATRIX-PEAK` |
| OCP-FP8 matrix，base | `not_specified` | 2.3 PFLOP/s | $2.3\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-OCP-FP8-MATRIX-BASE-PEAK` |
| OCP-FP8 matrix，with structured sparsity | `structured_sparse` | 4.6 PFLOP/s | $4.6\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-OCP-FP8-MATRIX-SPARSE-PEAK` |
| FP16 matrix，base | `not_specified` | 1.15 PFLOP/s | $1.15\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP16-MATRIX-BASE-PEAK` |
| FP16 matrix，with structured sparsity | `structured_sparse` | 2.3 PFLOP/s | $2.3\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP16-MATRIX-SPARSE-PEAK` |
| BF16 matrix，base | `not_specified` | 1.15 PFLOP/s | $1.15\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-BF16-MATRIX-BASE-PEAK` |
| BF16 matrix，with structured sparsity | `structured_sparse` | 2.3 PFLOP/s | $2.3\times10^{15}$ FLOP/s | `FACT-M2W3-AMD-MI350P-BF16-MATRIX-SPARSE-PEAK` |
| INT8 matrix，base | `not_specified` | 2.3 POP/s | $2.3\times10^{15}$ OP/s | `FACT-M2W3-AMD-MI350P-INT8-MATRIX-BASE-PEAK` |
| INT8 matrix，with structured sparsity | `structured_sparse` | 4.6 POP/s | $4.6\times10^{15}$ OP/s | `FACT-M2W3-AMD-MI350P-INT8-MATRIX-SPARSE-PEAK` |
| FP32 matrix | `not_specified` | 72 TFLOP/s | $72\times10^{12}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP32-MATRIX-PEAK` |
| FP64 matrix | `not_specified` | 36 TFLOP/s | $36\times10^{12}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP64-MATRIX-PEAK` |
| FP16 non-matrix / vector | `not_applicable` | 72 TFLOP/s | $72\times10^{12}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK` |
| FP32 non-matrix / vector | `not_applicable` | 72 TFLOP/s | $72\times10^{12}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK` |
| FP64 non-matrix / vector | `not_applicable` | 36 TFLOP/s | $36\times10^{12}$ FLOP/s | `FACT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK` |

基础行与“with structured sparsity”行分别记录。基础行没有被擅自写成 dense；稀疏行也没有从架构或相邻 SKU 补成 2:4。三条向量事实保留简报的 estimated 条件，产品页的同值通用 performance 行不重复登记为向量断言。本卡不把矩阵、向量或不同精度的数值相加成“总算力”。
## 4. 数值格式和累加

产品页中的 MXFP4、OCP-FP8、FP16 等名称是峰值行的格式标签。它们确认了厂商为这些路径发布整卡峰值，但没有给出完整的 A/B 操作数配对、乘积格式、程序员可见累加、物理累加器或输出编码。

| 数值环节 | 本卡状态 | 原因 | 要求标识 |
|---|---|---|---|
| A 操作数 | `not_found` | 没有一个可覆盖产品峰值路径的统一 A 格式合同 | `REQ-M2W3-AMD-MI350P-OPERAND-A` |
| B 操作数 | `not_found` | OCP-FP8 行同时列 E5M2/E4M3，但没有说明 A/B 配对 | `REQ-M2W3-AMD-MI350P-OPERAND-B` |
| 乘积或中间结果 | `not_found` | 输入标签不能决定乘积精度 | `REQ-M2W3-AMD-MI350P-PRODUCT-FORMAT` |
| 程序员可见累加 | `not_found` | 产品资料没有把某种累加格式绑定到这些峰值行 | `REQ-M2W3-AMD-MI350P-ACCUMULATION` |
| 物理内部累加 | `not_found` | 没有 MI350P 产品级内部位宽或数值语义 | `REQ-M2W3-AMD-MI350P-PHYSICAL-ACCUM` |
| OCP-FP8 输出 | `not_found` | E5M2/E4M3 标签没有说明输出或转换条件 | `REQ-M2W3-AMD-MI350P-OUTPUT-FORMAT` |

CDNA 4 ISA（Instruction Set Architecture，指令集架构）的正式架构记录已经覆盖部分 MFMA 指令的 C/D 与稀疏语义。本卡只通过 `OREL-AMD-MI350P-IMPLEMENTS-CDNA4` 引用该信息。产品峰值行与具体指令之间没有公开的一对一映射，所以不能把架构级累加事实复制成 MI350P 产品事实。

## 5. 存储层次

| 层级 | 容量 | 公开带宽 | 方向和性质 | 仍缺少的内容 | 事实标识 |
|---|---:|---:|---|---|---|
| LLC / AMD Infinity Cache | 128 MB | 未给出 | 不适用 | 实例数、读写端口、bank、延迟、每周期传输量 | `FACT-M2W3-AMD-MI350P-LLC-CAPACITY` |
| HBM3E | 144 GB | 4 TB/s | 厂商 peak；读写方向未说明 | 堆叠数、持续带宽、延迟 | `FACT-M2W3-AMD-MI350P-HBM3E-CAPACITY`；`FACT-M2W3-AMD-MI350P-HBM3E-BW` |

GB、MB 和 TB/s 按来源的十进制单位记录，不改写成 GiB、MiB 或 TiB/s。`FIELD-MEM-BIDIR-BW` 是当前字段合同允许的存储带宽字段，但事实条件明确为 `direction_not_specified`，不能把字段名理解成来源已经证明双向聚合。

简报第 2 页还写到每 XCD 的 32 KB L1 per CU、4 MB shared L2，以及四 XCD 共享 128 MB Infinity Cache。前两项属于每 CU 或每 XCD 的架构/局部配置；本包没有相应的子对象和完整层级带宽，因此不复制到整卡资料卡。128 MB 总 LLC 已由产品页直接支撑，不需要从 per-XCD 描述重建。

## 6. 计算与存储配比

本包不计算产品级存算比。虽然整卡峰值和 4 TB/s HBM3E 带宽都已公开，但矩阵基础行没有标成 dense，operation count rule 仍是厂商标签，产品级累加语义也没有建立。带宽方向同样未说明。缺少这些前置条件时，算术上能做除法不等于字段合同成立。

| 候选分子 | 分母 | 未满足的前置条件 | 处理 |
|---|---:|---|---|
| MXFP4、MXFP8 或 OCP-FP8 理论峰值 | 4 TB/s HBM3E | 稀疏口径或完整精度路径合同不闭合 | 不计算 |
| FP16、FP32 matrix 基础行 | 4 TB/s HBM3E | 基础行未标 dense；累加和计数规则缺失 | 不计算 |
| 任何计算峰值 | 128 MB LLC | 没有 LLC 带宽 | 不计算 |

也不计算每瓦性能。600 W 是最大 TBP，450 W 是可配置点；资料没有说明各峰值对应哪一个功耗条件，不能把任一峰值直接除以这两个瓦数。

## 7. 大模型相关特殊能力

| 能力组 | 本包结论 | 原因 | 结构化处理 |
|---|---|---|---|
| MoE（Mixture of Experts，混合专家）routing、Top-K、排序和采样 | 未找到产品级专用硬件证据 | 产品页、简报、文章及 CDNA 4 架构记录没有把命名模块或指令绑定到 MI350P | `REQ-M2W3-AMD-MI350P-SPECIAL-IMPLEMENTATION`：`not_found` |
| 稀疏 | 确认 OCP-FP8、FP16、BF16、INT8 有 structured-sparsity 峰值行 | 资料未给稀疏图样或独立专用引擎 | 只作为吞吐条件，不建 capability |
| Attention、Softmax、归约、KV Cache 管理或集合通信卸载 | 没有产品级专用实现定值 | 能运行相关工作负载不等于有专用硬件 | 不建 capability |

`special-capabilities.csv` 保持空表。缺少证据时创建一个“待核实能力”实体，会让占位符看起来像已经存在的产品模块，因此本包只保留要求和检索记录。

## 8. 主机互联和扩展边界

| 层级 | 公开值 | 方向和口径 | 未采用的推断 | 事实标识 |
|---|---|---|---|---|
| 单卡主机接口 | PCIe 5.0 x16 | 协议代际和通道宽度 | 不从协议理论值自行算带宽 | `FACT-M2W3-AMD-MI350P-PCIE-PROTOCOL` |
| 同一 PCIe 端点 | 128 GB/s | 简报未写方向、payload、峰值或持续口径 | 不拆成 64 GB/s 单向，也不翻倍为 256 GB/s 双向 | `FACT-M2W3-AMD-MI350P-PCIE-BW` |

单卡资料没有给出设备直连、scale-up、scale-out 或集合通信链路，因此只建立一条 `host_device` link。`topologies.csv` 保持空表。服务器“最多八卡”是系统配置上限，不是单卡互联拓扑或聚合带宽。

## 9. 软件、可靠性和实测

| 类别 | 本包能确认的内容 | 处理 |
|---|---|---|
| 软件 | 产品资料列出 ROCm 与 Enterprise AI 软件栈 | 没有最低 runtime、compiler 或 library 版本；`REQ-M2W3-AMD-MI350P-RUNTIME-VERSION=not_found` |
| RAS（Reliability, Availability and Serviceability，可靠性、可用性和可维护性） | 简报给出 full-chip ECC、page retirement、page avoidance | 因 40 条事实预算与核心比较字段优先级，保留为已读来源内容，未扩为本包结构化事实 |
| 虚拟化 | 简报写 Future SR-IOV support up to four partitions | 明确是 future，不写成当前产品能力 |
| 视频与图像固定功能 | 简报列出 decoder 与 JPEG/MJPEG codec | 不属于本工作包核心比较字段，未建 facts |
| 实测 | 没有入选的独立微基准 | 理论峰值不替代 sustained performance |

## 10. 缺失、差异和冲突处理

12 条 `not_found` 要求都完成了来源检索：release date、first availability date、HBM stack count、die area、A/B、product、programmer-visible accumulation、physical accumulator、OCP-FP8 output、MoE/Top-K 专用实现和 versioned runtime。每条要求都有单独的 `search-log.csv` 记录，并检查三个产品来源；数值语义和特殊实现相关要求还检查了既有 CDNA 4 白皮书与 ISA 记录。

当前没有 unresolved true conflict，因此 `conflict-groups.csv` 和 `conflict-members.csv` 都是空表。需要区分的来源差异如下：

- 专页写 `Cooling: Passive`，文章和简报写 standard air-cooled servers。前者是卡级散热，后者是服务器环境，主体不同；
- 固定简报的峰值表标为 estimated，并且直接区分 matrix 与 vector；2026-08-13 产品页给出同值的通用 FP16、FP32、FP64 performance 行，却没有 vector 标签。因此，三条向量断言由简报承担，产品页只作数值交叉核对；文章中的 April 2026 engineering estimates 不进入事实链；
- 专页显示 4 TB/s，D-1 嵌入数据的内部数值表示不作为 4096 GiB/s 解释；规范值来自可见产品页与固定简报；
- D-1 的 Product Basics `Form Factor=Servers` 是目录分类，Board Specifications 的 `PCIe Add-in Card` 才是物理对象形态；
- CDNA 4 白皮书中的 MI350X、MI355X 是 OAM/平台对象，8 XCD、2 IOD、288 GB、8 TB/s、1000 W、1400 W 等数值迁移量为 0。

## 11. 最小参考资料集

反向移除运行是 `SELRUN-M2W3-AMD-MI350P-20260813`。修正后的 40 条事实集只需要三个对象级来源：

| 来源标识 | 角色 | 删除后会丢失的内容 |
|---|---|---|
| `SRC-M2W3-AMD-MI350P-PRODUCT-20260813` | identity、core_spec | 当前精确对象身份、730 亿晶体管、卡级 passive、资源数、LLC、HBM 接口和矩阵峰值行 |
| `SRC-M2W3-AMD-MI350P-BROCHURE-202605` | core_spec | 固定版本、四 XCD/一 IOD、完整 FHFL CEM 形态、PCIe 128 GB/s，以及直接标注的三条向量峰值 |
| `SRC-M2W3-AMD-MI350P-BLOG-20260507` | status_version_evidence | 2026-05-07 的 exact-product available 状态证据 |

CDNA 4 白皮书与 ISA 仍用于边界核对和 `checked_no_support` 缺口检索，但不直接支持 MI350P 卡事实，因而筛选状态改为 `lead_only`，不再占用对象最小集的 selected role、coverage 或 selection member。

D-1 加速器规格数据库和 D-7 MI350 Series 页面完成了身份门职责：二者均有 2026-08-13 快照、标题、URL、字节数和 SHA-256。精确产品页已经覆盖 D-1 的产品条目，D-7 的独有作用是说明 MI350P PCIe 卡与 MI350X/MI355X platforms 的边界。它们继续保留在 `source-freeze-register.csv` 和身份审计中，不再新增为本包结构化内容版本。媒体和第三方资料没有增加独有事实，未进入最小集。

## 12. 完整度和待复核项

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | 身份、状态和架构关系已支持；release 与 first availability date 缺失 |
| 物理实现 | `partial` | 制程、730 亿晶体管、die 数、时钟、TBP、散热、卡形态和 HBM 接口已支持；stack count 与 die area 缺失 |
| 计算资源 | `partial` | 三项产品资源数和 16 条峰值已支持；没有持续实测或从每 CU 派生的整卡值 |
| 数值格式 | `partial` | 基础/结构化稀疏、矩阵/向量、FLOP/s/OP/s 已分开；A/B/product/accumulate/output 不闭合 |
| 存储层次 | `partial` | LLC 和 HBM3E 容量、HBM3E 峰值带宽已支持；片上带宽与方向缺失 |
| 互联 | `partial` | PCIe 代际和 128 GB/s 已支持；方向、payload、持续口径和拓扑缺失 |
| 特殊能力 | `missing_public_data` | 未找到产品级 MoE routing、Top-K 等专用实现 |
| 软件 | `partial` | 有软件生态线索，没有版本化最低支持下限 |
| 来源证据 | `needs_review` | 40 条事实、49 条断言、46 条要求、12 次缺口检索和三来源选择运行已暂存，尚待最终独立复核 |

自检：

- [x] MI350X、MI355X OAM、八 OAM 平台和服务器聚合值迁移量为 0
- [x] CDNA 4 机制只通过关系引用，没有复制每 CU 数值或缓存机制
- [x] 40 条事实均为对象匹配的一手直接事实，未超出 40 条上限
- [x] 49 条断言均为 `source_checked`，结构化来源不超过 3 个新增内容版本和 6 个 endpoint
- [x] 46 条字段要求与 40 条事实的主体合同不一致均为 0
- [x] 九个完整度领域恰有九行
- [x] 没有派生事实、占位 capability 或拓扑
- [x] 修正后包内 1,082 项校验通过；正式 32 表在 f152 基线上哈希不变
- [x] f152 基线临时正式合并通过 111,343 项 gate 检查，临时镜像已清理
- [ ] 最终独立复核与总控验收

本卡目前是 staging 草稿，不构成正式合并。