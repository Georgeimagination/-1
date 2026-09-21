# AWS Trainium2 试填资料卡（草稿）

> 状态：`draft`。资料截止日期为 2026-08-12。本卡用于 M1 试填与数据模型复审。七个 AWS 对象、179 条事实、164 条逐来源断言和 15 个来源版本已进入正式表；仍为 `draft`、`provisional` 或 `needs_resolution` 的记录必须继续保留这些状态。

## 1. 对象边界与产品身份

AWS 通常把 Trainium2 称为第二代 Trainium；另一些官方材料又使用“third-generation NeuronDevice”或“third-generation purpose-built ML chip”。这些说法的计数基准没有得到统一解释，本卡分别保留原文，并把代际称谓记为 `terminology_ambiguity`，不替厂商归并成唯一口径。[S1、S2 的标题及 §Trainium2 Device Diagram；S11，2023-11-28 新闻稿]

本卡把架构、芯片和云产品拆成七个对象，其中 `OBJ-AWS-TRN2-INSTANCE-FAMILY` 只承载三个实例 SKU 的配置族关系，不混入下表的具体规格。除“组成/搭载”关系外，各层数据不互相下放。

| 正式对象 | 对象层级 | 本卡采用的边界 | 状态与日期 | 证据定位 |
|---|---|---|---|---|
| `OBJ-AWS-TRAINIUM2-ARCH` | `architecture` | Trainium2 / NCv3 的计算、存储、数据搬运和通信架构 | 2023-11-28 正式公布产品；架构规格以 Neuron 2.29.1 文档为当前固定版本 | S11 标题、日期与 Trainium2 段；S1 §Trainium2 chip components |
| `OBJ-AWS-TRAINIUM2-CHIP` | `silicon_package/package` | 1 个 AWS Trainium2 器件，含 8 个 NCv3、4 组 HBM 和 NeuronLink-v3 | `cloud_available`；可由 2024-12-03 已正式可用的 Trn2 实例确认部署，但芯片没有独立销售状态 | S1 §Trainium2 chip components；S9 标题与正文 |
| `OBJ-AWS-TRN2-3XLARGE` | `product_sku/cloud_instance` | 单个 EC2 实例，1 个 Trainium2 芯片 | 当前产品页可见；首个固定发布日期未找到，记 `pending_verification` | S7 §Product details |
| `OBJ-AWS-TRN2-48XLARGE` | `product_sku/cloud_instance` | 单个 EC2 实例，16 个 Trainium2 芯片 | 2024-12-03 正式可用；当时限美国东部（俄亥俄）并通过 EC2 Capacity Blocks | S9 标题与正文；S10 §Using Trn2 Instances |
| `OBJ-AWS-TRN2U-48XLARGE` | `product_sku/cloud_instance` | UltraServer 的 16 芯片组成实例；不能和普通 `trn2.48xlarge` 合并 | 当前产品页和架构页可见；首个固定可用日期未找到，记 `pending_verification` | S6 §trn2.48xlarge / trn2u.48xlarge；S7 §Product details |
| `OBJ-AWS-TRN2-ULTRASERVER-64` | `system/server` | 4 个 `trn2u.48xlarge`、共 64 个 Trainium2 芯片 | 2024-12-03 固定公告称预览；当前动态页同时出现 “available now” 和 “available in preview”，记 `conflicting_unresolved`，不判定已正式可用 | S9 正文；S7 §Why 与 §Benefits |

`trn2.48xlarge`、`trn2u.48xlarge` 和 UltraServer 的总算力、总 HBM、总带宽均保留在对应实例或系统对象。这里不把聚合数值除以芯片数后当作芯片规格。芯片规格只取 S1 的单芯片表，或另行标明由公开单核值计算的候选派生项。

## 2. 计算架构

每个 Trainium2 芯片含 8 个独立 NCv3。每个 NCv3 由 Tensor Engine（矩阵/张量）、Vector Engine（向量归约与逐元素）、Scalar Engine（单元素映射及非线性函数）和 GPSIMD（可编程通用 SIMD）组成，并配有软件管理的片上 SRAM。[S1 §Trainium2 chip components；S3 开篇与 §Tensor/Vector/Scalar/GPSIMD]

### 2.1 单芯片公开峰值

下表采用 AWS Neuron 2.29.1 的 Trainium2 高层架构页作为当前芯片聚合口径。AWS 没有在该表中说明是否按每次乘加计 2 次操作、是否为 boost 时钟或其他峰值条件，因此 `operation_count_rule` 与详细频率条件均记 `not_found`。

| 本卡事实标识 | 对象 | 运算路径与格式 | 稠密/稀疏 | 数值 | 事实种类、证据与裁决状态 | 证据定位 |
|---|---|---|---|---:|---|---|
| `FACT-AWS-TRN2-CHIP-FP8-DENSE-PUB` | Trainium2 芯片 | Tensor，FP8 | dense | 1,299 TFLOPS | `direct_statement / single_source / provisional` | S1 §Trainium2 chip components / Compute |
| `FACT-AWS-TRN2-CHIP-BF16-DENSE-PUB` | Trainium2 芯片 | Tensor，BF16/FP16/TF32 | dense | 667 TFLOPS | `direct_statement / single_source / provisional` | 同上 |
| `FACT-AWS-TRN2-CHIP-FP32-DENSE-PUB` | Trainium2 芯片 | Tensor，FP32 | dense | 181 TFLOPS | `direct_statement / single_source / provisional` | 同上 |
| `FACT-AWS-TRN2-CHIP-FP8-SPARSE-PUB`、`FACT-AWS-TRN2-CHIP-FP16-SPARSE-PUB`、`FACT-AWS-TRN2-CHIP-BF16-SPARSE-PUB`、`FACT-AWS-TRN2-CHIP-TF32-SPARSE-PUB` | Trainium2 芯片 | Tensor，FP8/FP16/BF16/TF32 | structured sparse | 2,563 TFLOPS | `direct_statement / source_with_caveat / conflict_member` | 同上；冲突见 §9 |

“总算力”不能把矩阵、向量和标量数值相加。当前能直接采用的总量是上述按数据格式分别报告的 Tensor Engine 芯片聚合峰值；GPSIMD 没有一手 FLOPS 数值。

### 2.2 单核引擎与阵列形态

| 引擎 | 直接公开规格（每个 NCv3） | 数据通路与频率 | 芯片级候选派生 | 证据定位 |
|---|---|---|---|---|
| Tensor Engine | FP8 158 TFLOPS；BF16/FP16/TF32 79 TFLOPS；FP32 20 TFLOPS；结构化稀疏 316 TFLOPS | 2.4 GHz；稠密 FP8 输入 4×128 element/cycle，BF16/FP16 输入 2×128，稀疏输入 5×128，输出 1×128 | 每核值是直接断言；8 倍的 1,264、632、160、2,528 TFLOPS 仅为算术派生，`aggregation_validity=unresolved`，不作为第三组厂商芯片规格 | S2 Table 11 与 §Tensor Engine |
| Vector Engine | FP32 1.0 TFLOPS；支持 FP8、FP16、BF16、TF32、FP32、INT8、INT16、INT32 | 0.96 GHz；BF16/FP16 I/O 512 element/cycle，其余格式 256 element/cycle | 8 核简单乘算为 8.0 FP32 TFLOPS，记 `fact_kind=derived`、`performance_basis=public_derived`、`fact_resolution_state=provisional`，AWS 未单列芯片并发峰值 | S2 Table 11 与 §Vector Engine；S3 §Vector Engine |
| Scalar Engine | FP32 1.2 TFLOPS；格式集合与 Vector Engine 相同 | 1.2 GHz；128 element/cycle | 8 核简单乘算为 9.6 FP32 TFLOPS，记 `fact_kind=derived`、`performance_basis=public_derived`、`fact_resolution_state=provisional` | S2 Table 11；S3 §Scalar engine |
| GPSIMD | 每个 GPSIMD 含 8 个可编程 512-bit 处理器，可执行 C/C++ 自定义算子 | 1.2 GHz；未公开算术 FLOPS | `not_found` | S2 §Gpsimd Engine；S3 §GPSIMD engine |

Tensor Engine 的物理脉动阵列为 128×128 处理单元。FP8 double-row 模式在编程接口上呈现 256×128 收缩形态，物理阵列仍为 128×128；单条指令最大示例为 $M=128$、$K=256$、$N=512$。该模式不能与列切片、稀疏矩阵乘或转置模式同时使用。[S2 §Double FP8 Matmul Performance；S4 §Performance mode、§Tiling mode、§Tile size]

## 3. 数值格式、精度和稀疏

Tensor Engine 矩阵乘输入支持 `float8_e4m3`、`float8_e5m2`、BF16、FP16、TF32 和 FP32。两个输入格式可以不同；如果一侧为 TF32 或 FP32，另一侧也必须是 TF32 或 FP32。FP8 double-row 只接受 E4M3/E5M2，二者可以混用。S2 还说明 FP8_E3 可执行，但其矩阵乘吞吐与 BF16/FP16 相同。[S4 §Data types；S2 §Double FP8 Matmul Performance]

矩阵乘的 Tensor Engine 内部累加语义为 FP32，NCv3 的 PSUM 目标 tile 也必须是 FP32。物理累加器位宽、乘积中间位宽和舍入发生点没有在已检索的一手资料中给出，分别记 `not_found`；不能把“FP32 累加语义”改写成物理累加器必然为 32 bit。[S4 §Data types]

Vector Engine 的 BF16/FP16 性能模式可以按指令和布局提高 2 倍或 4 倍指令吞吐，但计算仍以 FP32 完成。Trainium2 支持 Round Nearest Even（RNE，最接近偶数舍入）和 stochastic rounding（随机舍入）；cFP8 支持可调指数偏置。[S2 §Vector Engine Performance Mode；S3 §Tensor Engine]

结构化稀疏由 Tensor Engine 支持。官方列出的 M:N 模式为 4:16、4:12、4:8、2:8、2:4、1:4 和 1:2。当前资料没有交代稀疏元数据编码、元数据带宽、剪枝/压缩是否由硬件在线完成，记 `not_found`。[S3 §Tensor Engine]

## 4. 存储层次与数据搬运

Trainium2 的设备端层次为 HBM → SBUF → PSUM。SBUF 和 PSUM 是每个 NCv3 内的片上存储，并不是芯片级统一共享缓存；官方把 SBUF 称为软件管理的 SRAM，而不是硬件管理 cache。[S2 §Data Movement Updates；S3 §On-chip SRAM]

| 层级/通路 | 对象与共享范围 | 容量 | 带宽或吞吐 | 管理方式与约束 | 证据定位 |
|---|---|---:|---:|---|---|
| HBM | 单个 Trainium2 芯片，4 个 HBM stack | 96 GiB | 2.9 TB/s（S2 另以 3 TB/s 四舍五入） | 4 个 24 GB bank；每个 bank 由两个物理 NCv3 共享 | S1 §Trainium2 chip components；S2 Device Diagram；S5 §LNC=1/2 |
| SBUF | 每个 NCv3 私有的片上软件管理 SRAM | 28 MiB/core；128 个 224 KiB partition；芯片聚合 224 MiB | 数值 `not_found` | HBM↔SBUF 由 DMA；VectorE 与 GPSIMD 可并行访问 | S2 §NeuronCore-v3 Compute Engine Updates、§Data Movement Updates；S1 §Memory |
| PSUM | 每个 NCv3 的部分和存储 | 2 MiB/core | 数值 `not_found` | Tensor Engine 写入；通过计算引擎 ISA 与 SBUF 交换；VectorE 与 ScalarE 在不碰同一 bank 时可全带宽并行访问 | S2 §NeuronCore-v3 Compute Engine Updates、§Data Movement Updates；S4 §Memory types |
| 主 DMA | 单个 Trainium2 芯片，共 128 个主 DMA engine | 不适用 | 3.5 TB/s 芯片聚合 | 支持 inline compression/decompression；典型每个 NCv3 配 16 个 DMA | S1 §Trainium2 chip components；S2 Device Diagram、§DMA Transpose |
| GPSIMD 集成 DMA | 每个 NCv3 的 8 个 GPSIMD 处理器合计 | 不适用 | 307 GB/s，总计；读、写方向各 153 GB/s | 可访问同一 Trn2 实例内的任意 SBUF/HBM；不能误写成单芯片聚合主 DMA | S2 §Gpsimd Engine |

容量原始单位按来源保留：S1/S6 的 96、1,536 和 6,144 使用 GiB，S2 的四个 bank 写作 24 GB，动态产品页部分位置也使用 GB。GB 与 GiB 不静默换算，也不让两个单位的断言共同支撑同一规范值；S2 的 `4 × 24 GB` 只保留为原始组织标签。

LNC（Logical NeuronCore，逻辑 NeuronCore）只支持 1 或 2。默认 LNC=2 把两个物理 NCv3 组合为一个逻辑核心，单芯片暴露 4 个逻辑核心；LNC=1 暴露 8 个。`trn2.48xlarge` 因而分别暴露 64 或 128 个逻辑核心。LNC 是编译器和运行时的资源组合配置，不等于面向多租户的硬件虚拟化或安全分区。[S5 §Logical NeuronCores、§LNC=1/2]

### 4.1 数据搬运能力

DMA 可在 HBM→SBUF 或 SBUF→SBUF 搬运时执行 bit-accurate transpose（位精确转置），支持 2-byte 和 4-byte 数据类型。布局合适时，HBM→SBUF 转置可达到主 DMA 吞吐的 90%，普通 copy 可到 100%；SBUF→SBUF 转置最高为 DMA 吞吐的 50%。这些百分比是利用率上限，不是独立带宽定值。[S2 §DMA Transpose]

每个 NCv3 有 2 个 Descriptor Generation Engine（DGE，描述符生成引擎），在硬件中按需生成 DMA copy/transpose 描述符。DGE 当前不支持间接 gather/scatter；从 Scalar Engine 触发的一条 DGE DMA 指令约 600 ns。该数字是指令执行时间，不是端到端访存延迟。[S2 §Descriptor Generation Engine]

## 5. 存算比候选派生

仅 HBM 有公开带宽，因此只计算单芯片“峰值算力/HBM 带宽”。公式为对应格式的芯片 TFLOPS 除以 2.9 TB/s；十进制前缀相消后单位为 FLOP/byte。它是硬件规格的机器平衡值，也就是 roofline ridge point（屋顶线脊点），不是工作负载自身的算术强度，也不代表持续性能。

| 格式与条件 | 输入事实 | 派生结果 | 状态 |
|---|---:|---:|---|
| FP8 dense | 1,299 TFLOPS；2.9 TB/s | 447.9 FLOP/byte | `public_derived` |
| BF16/FP16/TF32 dense | 667 TFLOPS；2.9 TB/s | 230.0 FLOP/byte | `public_derived` |
| FP32 dense | 181 TFLOPS；2.9 TB/s | 62.4 FLOP/byte | `public_derived` |
| structured sparse | 2,563 TFLOPS；2.9 TB/s | 883.8 FLOP/byte | `public_derived`，随稀疏峰值冲突待复核 |

SBUF 和 PSUM 的数值带宽未找到，不能计算相应 FLOP/byte。容量/算力比可以机械计算，但其解释依赖常驻数据格式和并发口径，本次不把它列为正式派生指标。

## 6. 特殊算子与专用模块

| 能力 | 已确认实现 | 实现层级判断 | 状态与边界 | 证据定位 |
|---|---|---|---|---|
| GEMM/CONV | Tensor Engine 脉动阵列 | `dedicated_physical_module` | 已确认 | S2 §Tensor Engine |
| 结构化稀疏矩阵乘 | Tensor Engine 的 M:N 稀疏模式 | `configurable_engine`（暂定） | 功能和模式已确认；实现层级仍为 `provisional`，没有独立“稀疏模块”证据 | S3 §Tensor Engine |
| Tensor Engine 转置 | Tensor Engine 原生 transpose mode | `dedicated_instruction`（暂定） | 模式存在已确认；实现层级为 `provisional`，不是独立 attention engine | S2 §Built-in Transpose Support |
| DMA 转置 | HBM→SBUF 与 SBUF→SBUF transpose | `configurable_engine`（暂定） | 搬运能力已确认；实现层级为 `provisional` | S2 §DMA Transpose |
| Attention 数据布局 | HBM→SBUF DMA transpose 可转换 K-cache 布局；SBUF→SBUF transpose 对 self-attention 有用 | `configurable_engine`（暂定） | 只确认通用搬运机制可用于 attention；实现层级为 `provisional` | S2 §HBM2SBUF DMA transpose、§SBUF2SBUF DMA transpose |
| 非线性函数 | Scalar Engine 加速 GELU、sqrt 等 | `general_compute_path` | 已确认；未公开完整函数表和每函数吞吐 | S2 §Scalar Engine |
| reduction / elementwise | Vector Engine 面向归约和逐元素运算 | `general_compute_path` | 已确认一般路径；未找到专用 softmax 模块 | S2 §Vector Engine |
| 自定义算子 | GPSIMD 执行 C/C++；NKI 直接访问 ISA | `general_compute_path` | 已确认 | S2 §Gpsimd Engine；S7 §State-of-the-art AI optimizations |
| DMA 描述符生成 | 每 NCv3 两个 DGE | `dedicated_physical_module` | 已确认；仅服务 copy/transpose 描述符 | S2 §Descriptor Generation Engine |
| 集体通信硬件 | CC-Cores + NeuronLink | `dedicated_physical_module`（暂定） | 硬件存在已确认，模块数有 16/20 冲突；具体卸载边界仍为 `provisional` | S1 §Collective communication；S2 Device Diagram |
| 集体通信软件接口 | NKI 提供 all-reduce、all-gather、reduce-scatter、all-to-all、all-to-all-v 和 permute API | `library_implementation` | API 集合已确认；不等于每个操作均有独立硬件单元 | S8 §NKI Collectives |
| MoE router / top-K | 2026 年 NKI Library 有实验性融合 RMSNorm、Router Top-K 内核，并有 MoE training collective 内核 | `library_implementation` | 已找到软件内核；未找到 Trainium2 专用 MoE routing/top-K 硬件，硬件字段记 `not_found` | S12 正文；S13 §Background/API Reference |
| sampling / sort | 未找到 Trainium2 专用物理模块或定值 | 未判定 | `not_found` | 见 §10 检索缺口 |

## 7. 互联、拓扑与系统聚合规格

### 7.1 芯片与实例内互联

单个 Trainium2 芯片有 4 个 NeuronLink-v3 接口，官方给出的芯片聚合带宽为 1.28 TB/s。该数字的单向/双向、线路/有效载荷口径没有说明，不能除以 4 推导每链路带宽。[S1 §Trainium2 chip components；S2 Device Diagram]

`trn2.48xlarge` 和 `trn2u.48xlarge` 各含 16 个 Trainium2 芯片，组成 4×4 二维 torus（环面）拓扑，并支持 16 芯片 HBM pooling。架构表把实例内 NeuronLink-v3 带宽写为 1,024 GB/s/chip。[S6 §trn2.48xlarge / trn2u.48xlarge、§Trn2 instance specifications]

UltraServer 由 4 个 `trn2u.48xlarge` 组成。每个实例内仍为 4×4 torus；四个实例中相同 XY 坐标的芯片再连接成 ring（环）。架构表给出 1,024 GB/s/chip 的实例内带宽和 256 GB/s/chip 的实例间带宽，两者相加正好等于 S1 的 1.28 TB/s/chip，但方向与有效载荷口径仍未说明，因此本卡不把这种相加关系升级为链路分解事实。[S6 §Trn2 UltraServer、§Trn2 instance specifications]

链路延迟、bisection bandwidth（对分带宽）、超售比、拥塞下有效带宽和故障降级拓扑均为 `not_found`。

### 7.2 对象级聚合值

| 对象 | 芯片数 | FP8 dense | BF16/FP16/TF32 dense | structured sparse | FP32 | 设备内存 | 设备内存带宽 | NeuronLink | EFAv3 | 证据定位 |
|---|---:|---:|---:|---:|---:|---:|---:|---|---:|---|
| `trn2.3xlarge` | 1 | 不从芯片值转抄到实例正式事实 | 同左 | 同左 | 同左 | 96 GB | 未单列实例值 | 拓扑 `not_found` | 0.2 Tbps | S7 §Product details |
| `trn2.48xlarge` | 16 | 20.8 PFLOPS | 10.7 PFLOPS | 41 PFLOPS | 2.9 PFLOPS | 1,536 GiB | 46.4 TB/s | 4×4 torus；1,024 GB/s/chip intra | 3.2 Tbps | S6 §Trn2 instance specifications；S7 §Product details |
| `trn2u.48xlarge` | 16 | 20.8 PFLOPS | 10.7 PFLOPS | 41 PFLOPS | 2.9 PFLOPS | 1,536 GiB | 46.4 TB/s | 4×4 torus；1,024 GB/s/chip intra | 3.2 Tbps | S6 同上；S7 §Product details |
| Trn2 UltraServer | 64 | 83.2 PFLOPS | 42.8 PFLOPS | 164 PFLOPS | 11.6 PFLOPS | 6,144 GiB | 185.6 TB/s | 4 个 torus + 跨实例同坐标 ring；另有 256 GB/s/chip inter | S6 表为 3.2 Tbps，S7 为 12.8 Tbps，`conflicting_unresolved`（疑似统计范围不同） | S6 同上；S7 §Benefits |

EFAv3 是实例/系统级 scale-out 网络，不属于 Trainium2 芯片内互联。S6 的 UltraServer 表写 3,200 Gbps，而 S7 明确写 12.8 Tbps 总量；前者可能沿用了组成实例口径，但原表未作说明，本卡不自行裁决。

## 8. 物理实现、软件与可靠性

### 8.1 物理实现

| 字段 | 状态 | 备注 |
|---|---|---|
| 工艺节点、代工厂 | `not_found` | 产品页只写“advanced silicon processes”，不足以形成定值 |
| 晶体管数、裸片面积 | `not_found` | 无一手定值 |
| 封装类型、封装尺寸 | `not_found` | 只确认器件集成 4 个 HBM stack，不能据此猜封装结构 |
| 标称功耗/TDP、典型功耗 | `not_found` | 云实例功耗也未公开，不能由整机估算 |
| HBM 接口位宽 | `not_found` | 只确认容量、stack 数与带宽 |
| 独立板卡 SKU/形态 | `not_applicable` | 当前正式对象是芯片与云实例，没有可单独购买的板卡对象 |
| 芯片或封装冷却定值 | `not_found` | 不能从云实例或整机反推芯片冷却参数 |
| 云实例/UltraServer 冷却 | `not_found` | 属于相应实例或系统对象，不回填到 Trainium2 芯片 |

### 8.2 软件栈

AWS Neuron SDK 是 Trainium2 的正式软件栈。固定发布记录显示 Neuron 2.21 在 2024-12-23 引入 Trainium2、`trn2.48xlarge`、UltraServer、PyTorch 2.5、NxD Inference 和 Neuron Profiler 2.0 beta 支持，并列出 MoE 模型、FP8 权重量化、flash decoding 和 speculative decoding 等软件能力。[S14 标题与正文]

截至资料截止日，Neuron 2.31.0 于 2026-07-08 发布。该版本在 Trn2 上默认启用重设计的编译后端，增加连续共享 scratchpad、NKI 0.5、MX FP8 scale dtype、tensor indirection 和 14 个实验性内核。它证明 MoE routing、attention 等能力已有软件实现，但不能反推 Trainium2 含专用物理模块。[S12 标题与正文]

公开框架与接口包括 PyTorch、JAX、Hugging Face、PyTorch Lightning、NeMo、OpenXLA、NKI、NxD Training 和 NxD Inference。[S7 §Built for Developers；S10 §Using Trn2 Instances]

### 8.3 可靠性、安全与管理

产品页确认 EFA 流量通过 Nitro System 提供传输中加密；这是实例网络属性，不是 Trainium2 芯片内存加密事实。[S7 §Reliably and securely scale]

芯片级 ECC 覆盖范围、内存巡检、故障域、可关闭核心/链路、虚拟化隔离、遥测计数器完整清单和可用性 SLA 均为 `not_found`。LNC 只表示逻辑核心组合，不作为虚拟化或故障隔离证据。

## 9. 官方来源之间的矛盾

| 冲突编号 | 原始断言 A | 原始断言 B | 当前处理 |
|---|---|---|---|
| 问题 001 | S1：芯片直接断言 1,299/667/181/2,563 TFLOPS | S2：每 NCv3 直接断言 158/79/20/316 TFLOPS；8 倍结果仅为派生 | `scope_disagreement`。两组直接断言分别保留；每核到芯片的汇聚规则为 `aggregation_validity=unresolved`。派生值不覆盖芯片直值；芯片向量/标量峰值也不由每核值自动汇总 |
| `CG-AWS-TRN2-002-CCCORE` | S1：16 个 CC-Cores | S2：20 个 CC-Cores | `conflicting_unresolved`。不确定是文档错误、统计边界或版本差异；正式卡不应填唯一数量 |
| 问题 003 | S1/S6 当前版本：稀疏 2,563 TFLOPS/chip、41 PFLOPS/16-chip instance | 2024-12-03 S10：5.2 PFLOPS/chip、83.2 PFLOPS/instance | 先按 `version_change` 与 `condition_disagreement` 审查；来源日期、精度、稀疏定义和计数规则尚未调和，暂不把它裁成同条件数值冲突，也不静默删除历史断言 |
| `CG-AWS-TRN2-004-ULTRA-STATUS` | S9 与 S10 正文：2024-12-03 UltraServer 为 preview | S7 同一动态页：一处 “available now”，另一处 “available in preview” | 带有效期的产品状态事实保持 `conflicting_unresolved`。2024-12-03 历史状态明确；截止日状态需另找固定公告，不以动态营销页裁决 |
| `CG-AWS-TRN2-005-ULTRA-EFA` | S6：UltraServer EFAv3 3,200 Gbps | S7：UltraServer 12.8 Tbps | `scope_disagreement`。表头统计范围未说明；3,200 Gbps 不自动解释成单实例，12.8 Tbps 也不反除为每实例 |
| 问题 006 | EC2 通用规格表称 `trn2.3xlarge` 为 512 GiB、`trn2.48xlarge` 为 8,192 GiB accelerator memory，且 `trn2u.48xlarge` 无 accelerator | S1/S6/S7 一致给出 96 GiB/chip、1,536 GiB/16 chips，且 `trn2u.48xlarge` 有 16 芯片 | 通用表的这些单元标 `rejected_unreliable`；不用于正式容量或器件数，但保留筛选记录 |
问题 001 按 FP8、BF16、FP16、TF32 和 FP32 拆为 `CG-AWS-TRN2-001-FP8`、`CG-AWS-TRN2-001-BF16`、`CG-AWS-TRN2-001-FP16`、`CG-AWS-TRN2-001-TF32`、`CG-AWS-TRN2-001-FP32`。问题 003 按芯片、`trn2.48xlarge`、`trn2u.48xlarge` 和四种格式拆成 12 个 `CG-AWS-TRN2-003-*` 组；问题 006 拆为 `CG-AWS-TRN2-006-3XL-MEM` 与 `CG-AWS-TRN2-006-48XL-MEM`。完整成员见 `conflict-members.csv`，这里不把派生值改写成厂商直值。

## 10. 缺口和字段状态

本轮按字段检查 AWS 官方产品页、固定公告和版本化 Neuron 文档，检索范围已落入 `search-log.csv`；仍缺：SBUF/PSUM 数值带宽、片上访存延迟、主 DMA 的读写方向口径；芯片工艺、面积、晶体管、功耗、封装尺寸；NeuronLink 单向/双向口径、每链路带宽、有效载荷、延迟、对分带宽和故障降级；物理累加器位宽与中间乘积位宽；专用 sort、sampling、MoE routing、router top-K 物理模块；芯片级 RAS/ECC 和虚拟化机制。这些字段统一记 `not_found`，表示本轮在适当一手范围内没有找到，而不是断言 AWS 从未公开。

`trn2.3xlarge`、`trn2u.48xlarge` 的首次固定可用日期和 UltraServer 在 2026-08-12 的正式供货状态记 `pending_verification`；UltraServer 状态另带 `conflicting_unresolved`。

## 11. 最小来源候选与独有贡献

下表第一列使用正式 `source_id`；正文的 S1 至 S14 只是便于阅读的短称。

下表区分 source family（来源家族）、content version（内容版本）和 access endpoint（访问入口）。同一版本的 HTML、RST、PDF 入口属于同一内容版本，不应当算多份独立证据。逐事实断言和反向移除已经完成，S1 至 S14 在当前选定事实、冲突和版本职责下均保留为 `selected`；15 个官方网页入口也已保存 2026-08-12 的本地快照和内容哈希。后续新增或删除事实时必须重新运行筛选。

| 来源 ID | 来源家族 / 内容版本 | 入口 | 本卡保留的独有贡献 | 正式筛选状态 / 选入角色 |
|---|---|---|---|---|
| `SRC-AWS-TRN2-S01` | AWS Neuron / Trainium2 Architecture / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trainium2.html> | 单芯片聚合算力、96 GiB/2.9 TB/s、3.5 TB/s DMA、1.28 TB/s NeuronLink、224 MiB SBUF、CC-Core=16 | `selected / core_spec` |
| `SRC-AWS-TRN2-S02` | AWS Neuron / Trainium2 Architecture Guide for NKI / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/guides/architecture/trainium2_arch.html> | 引擎通路/频率、FP8 模式、SBUF/PSUM、GPSIMD DMA、转置、DGE、CC-Core=20 冲突 | `selected / core_spec` |
| `SRC-AWS-TRN2-S03` | AWS Neuron / NeuronCore-v3 Architecture / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/neuron-core-v3.html> | M:N 稀疏模式全集、Vector/Scalar 格式、GPSIMD 512-bit 宽度 | `selected / architecture_mechanism` |
| `SRC-AWS-TRN2-S04` | AWS Neuron / `nki.isa.nc_matmul` / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/api/generated/nki.isa.nc_matmul.html> | 128×128 物理阵列、输入组合约束、FP32 内部累加与 NCv3 FP32 PSUM 目标 | `selected / architecture_mechanism` |
| `SRC-AWS-TRN2-S05` | AWS Neuron / Logical NeuronCore configuration / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-features/logical-neuroncore-config.html> | LNC=1/2、4×24 GB HBM bank 与双核共享映射 | `selected / architecture_mechanism` |
| `SRC-AWS-TRN2-S06` | AWS Neuron / Amazon EC2 Trn2 Architecture / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trn2-arch.html> | 16/64 芯片对象、4×4 torus、跨实例 ring、实例/系统聚合规格和 NeuronLink 分层 | `selected / core_spec` |
| `SRC-AWS-TRN2-S07` | AWS EC2 / Trn2 product page / 动态页，2026-08-12 观察 | <https://aws.amazon.com/ec2/instance-types/trn2/> | `trn2.3xlarge` 与 `trn2u.48xlarge` 当前配置、HBM3 名称、12.8 Tbps UltraServer EFA、当前状态矛盾 | `selected / core_spec; conflict_evidence; status_version_evidence` |
| `SRC-AWS-TRN2-S08` | AWS Neuron / NKI Collectives index / 2.29.1 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/api/nki.collectives.html> | Trainium2 可编程 collective API 操作集合 | `selected / architecture_mechanism` |
| `SRC-AWS-TRN2-S09` | AWS What's New / Trn2 GA / 2024-12-03 | <https://aws.amazon.com/about-aws/whats-new/2024/12/amazon-ec2-trn2-instances-available/> | `trn2.48xlarge` 正式可用与 UltraServer 预览的固定日期证据 | `selected / status_version_evidence` |
| `SRC-AWS-TRN2-S10` | AWS News Blog / Trn2 launch / 2024-12-03，页面注明当日修订 | <https://aws.amazon.com/blogs/aws/amazon-ec2-trn2-instances-and-trn2-ultraservers-for-aiml-training-and-inference-is-now-available/> | 首发时供货区域、95% HBM 利用率厂商声明、稀疏算力历史冲突 | `selected / conflict_evidence; status_version_evidence` |
| `SRC-AWS-TRN2-S11` | Amazon Press Center / Trainium2 announcement / 2023-11-28 | <https://press.aboutamazon.com/2023/11/aws-unveils-next-generation-aws-designed-chips> | Trainium2 首次正式公布日期与当时计划中的 16 芯片 Trn2 关系 | `selected / status_version_evidence` |
| `SRC-AWS-TRN2-S12` | AWS What's New / Neuron 2.31.0 / 2026-07-08 | <https://aws.amazon.com/about-aws/whats-new/2026/07/aws-announce-neuron-2-31-0/> | 截止日前当前软件能力、实验性 MoE/attention 内核与 Trn2 默认编译后端 | `selected / architecture_mechanism; status_version_evidence` |
| `SRC-AWS-TRN2-S13` | AWS Neuron / RMSNorm Router Top-K TKG / latest，2026-08-12 观察 | <https://awsdocs-neuron.readthedocs-hosted.com/en/latest/nki/library/api/rmsnorm-router-topk-tkg.html> | 直接证明 Router Top-K 是 NKI Library 实验性融合内核，不能据此宣称专用硬件 | `selected / architecture_mechanism` |
| `SRC-AWS-TRN2-S14` | AWS What's New / Neuron 2.21 / 2024-12-23 | <https://aws.amazon.com/about-aws/whats-new/2024/12/aws-neuron-trainium2-nxd-inference/> | Trainium2 初始 SDK 支持版本、NxD Inference、MoE/FP8 inference 软件能力 | `selected / status_version_evidence` |

可从最小集剔除的候选包括：同一 Neuron 内容版本的 RST/PDF 镜像入口只登记为非优先 endpoint，不重复建立 source；翻译后的 AWS What's New 页面记 `redundant_covered`；被 2.29.1 取代且没有独有历史数值的旧版架构页记 `superseded`；只复述 S1/S6 的媒体文章记 `redundant_covered`。AWS EC2 通用 accelerated-instance 规格页不进入容量最小集，因为相关单元与三份产品专页相互冲突且明显缺乏对象一致性；涉及这些错误单元的候选记 `rejected_unreliable`，页面只保留为冲突与质量审计记录。

## 12. 完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | 六个对象已分层；部分实例的首次固定可用日期和 UltraServer 截止日状态未解决 |
| 物理实现 | `missing_public_data` | 工艺、面积、晶体管、功耗和封装细节没有一手定值 |
| 计算资源 | `partial` | 芯片与每核矩阵直值均已保留，但汇聚规则、芯片向量/标量峰值仍未解决 |
| 数值格式 | `partial` | 主要格式和 FP32 累加语义可确认，内部位宽与舍入点未公开 |
| 存储层次 | `partial` | HBM、SBUF、PSUM 容量和主 DMA 有证据，片上带宽与延迟缺失 |
| 互联 | `partial` | NeuronLink 拓扑和若干聚合值已覆盖，方向、有效载荷、延迟与 EFA 范围仍有缺口 |
| 特殊能力 | `partial` | 稀疏、转置、DGE 与集合通信能力有证据；若干实现层级暂定，MoE/Top-K 专用硬件未找到 |
| 软件 | `partial` | Neuron SDK、NKI 与主要框架已有版本证据，软件能力不能反推专用硬件 |
| 来源证据 | `complete` | 正式逐事实断言、筛选角色和反向移除记录已落表；动态状态与冲突仍按版本保留，不影响证据链可追溯性 |
## 13. 草稿验收结论

本卡已经覆盖对象身份、矩阵/向量/标量路径、精度与累加、三级设备存储、DMA、特殊算子、互联拓扑、实例/系统聚合、软件、物理缺口、冲突和最小来源候选。结构化记录已经合并到正式表；合并后独立复核发现的语义问题完成修正后，最新全局校验结果为 39,519 项检查通过。仍需复核同版官方算力、CC-Core 数量、UltraServer 状态与 EFA 范围等未决项；没有公开一手定值的字段继续保留缺失状态，不使用第三方估算补齐。