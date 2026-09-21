# AWS Trainium3 芯片实现资料卡

状态：`ready_for_independent_review`；对象层级：`package`；候选事实：27 条。

## 对象边界

本卡只描述 `OBJ-AWS-TRAINIUM3-CHIP` 的单芯片实现量。正式关系 `OREL-AWS-TRAINIUM3-IMPLEMENTS-ARCH` 将它连接到架构对象 `OBJ-AWS-TRAINIUM3-ARCH`；执行机制、数值语义和软件接口沿该关系复用，不在 package 对象上复制。云实例中的芯片数、服务器或机架聚合值均不进入本卡。NeuronCore-v4（NCv4，AWS 第四代 Neuron 计算核）是该芯片的实现组件。HBM 指高带宽存储器，DMA 指直接存储器访问，CC-Core 指集合通信核；SBUF 是软件管理的片上缓冲区，PSUM 是部分和缓冲区。

现有一手页面能证明“芯片/器件”边界，但不能证明它是单裸片，也没有给出封装方式、芯粒数量、中介层、裸片面积或晶体管数。因此这里的 `package` 是保守的事实容器，不是对物理封装构造的结论。

## 实现事实候选

| fact_id | 作用域与字段 | 条件 | 原文值 | 规范值 | 来源与稳定定位 | 原文短摘录 |
|---|---|---|---|---|---|---|
| `FACT-M2W2-AWS-TRN3-NCV4-COUNT` | `CMP-M2W2-AWS-TRN3-NCV4 / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A06: 8 NeuronCore-v4 per chip<br>SRC-M2-GA-A07: 8 NeuronCore-v4 per device | 8 count | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1887-1898, Trainium3 device overview<br>SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2015-2022, device list | “contains eight NeuronCore-v4 cores”<br>“8 NeuronCores (v4)” |
| `FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK` | `PP-M2W2-AWS-TRN3-CHIP-MX / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-MX` | SRC-M2-GA-A06: 2517 MXFP8/MXFP4 TFLOPS | 2517000000000000 FLOP/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1894-1901, Compute row | “2,517 MXFP8/MXFP4 TFLOPS” |
| `FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC` | `PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC` | SRC-M2-GA-A08: 2.52 FP8 PFLOPS per Trainium3 chip | 2520000000000000 FLOP/s | SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2116, Trainium3 chip paragraph | “Each AWS Trainium3 chip provides 2.52 petaflops (PFLOPs) of FP8 compute” |
| `FACT-M2W2-AWS-TRN3-CHIP-MIXED-PEAK` | `PP-M2W2-AWS-TRN3-CHIP-MIXED / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-MIXED` | SRC-M2-GA-A06: 671 BF16/FP16/TF32 TFLOPS | 671000000000000 FLOP/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1894-1901, Compute row | “671 BF16/FP16/TF32 TFLOPS” |
| `FACT-M2W2-AWS-TRN3-CHIP-SPARSE-PEAK` | `PP-M2W2-AWS-TRN3-CHIP-MIXED / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-SPARSE` | SRC-M2-GA-A06: 2517 FP16/BF16/TF32 sparse TFLOPS | 2517000000000000 FLOP/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1894-1901, Compute row | “2,517 FP16/BF16/TF32 sparse TFLOPS” |
| `FACT-M2W2-AWS-TRN3-CHIP-FP32-PEAK` | `PP-M2W2-AWS-TRN3-CHIP-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-FP32` | SRC-M2-GA-A06: 183 FP32 TFLOPS | 183000000000000 FLOP/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1894-1901, Compute row | “183 FP32 TFLOPS” |
| `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MX` | `PP-M2W2-AWS-TRN3-NCV4-MX / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-MX` | SRC-M2-GA-A07: 315 MXFP8/MXFP4 TFLOPS per NCv4<br>SRC-M2-GA-A10: 315 MXFP8/MXFP4 TFLOPS per NCv4 | 315000000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2073, Tensor Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1930, Tensor Engine paragraph | “delivers 315 MXFP8/MXFP4 TFLOPS”<br>“delivers 315 MXFP8/MXFP4 TFLOPS” |
| `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MIXED` | `PP-M2W2-AWS-TRN3-NCV4-MIXED / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-MIXED` | SRC-M2-GA-A07: 79 BF16/FP16/TF32 TFLOPS per NCv4<br>SRC-M2-GA-A10: 79 BF16/FP16/TF32 TFLOPS per NCv4 | 79000000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2073, Tensor Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1930, Tensor Engine paragraph | “79 BF16/FP16/TF32”<br>“79 BF16/FP16/TF32” |
| `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-FP32` | `PP-M2W2-AWS-TRN3-NCV4-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-FP32` | SRC-M2-GA-A07: 20 FP32 TFLOPS per NCv4<br>SRC-M2-GA-A10: 20 FP32 TFLOPS per NCv4 | 20000000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2073, Tensor Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1930, Tensor Engine paragraph | “20 FP32 TFLOPS”<br>“20 FP32 TFLOPS” |
| `FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32` | `PP-M2W2-AWS-TRN3-NCV4-VECTOR-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-VECTOR` | SRC-M2-GA-A07: 1.2 FP32 TFLOPS per NCv4 Vector Engine<br>SRC-M2-GA-A10: 1.2 FP32 TFLOPS per NCv4 Vector Engine | 1200000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2128, Vector Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1936, Vector Engine paragraph | “The NeuronCore-v4 Vector Engine delivers a total of 1.2 TFLOPS of FP32 computations”<br>“deliver a total of 1.2 TFLOPS of FP32 computations” |
| `FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32` | `PP-M2W2-AWS-TRN3-NCV4-SCALAR-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-SCALAR` | SRC-M2-GA-A07: 1.2 FP32 TFLOPS per NCv4 Scalar Engine<br>SRC-M2-GA-A10: 1.2 FP32 TFLOPS per NCv4 Scalar Engine | 1200000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2167, Scalar Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1945, Scalar Engine paragraph | “The NeuronCore-v4 Scalar Engine delivers a total of 1.2 TFLOPS of FP32 computations”<br>“deliver a total of 1.2 TFLOPS of FP32 computations” |
| `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK` | `CMP-M2W2-AWS-TRN3-TENSOR / FIELD-PHY-CLOCK` | `COND-M2W2-AWS-TRN3-CORE-MX` | SRC-M2-GA-A07: 2.4 GHz | 2400000000 Hz | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2047-2050, Table 11 Tensor row | “Trainium3 Tensor 8x128 (MXFP8 dense input) or 2x128 (non-MXFP8 dense input) or 5x128 (sparse input); 1x128 (output) 2.4” |
| `FACT-M2W2-AWS-TRN3-SBUF-CAPACITY` | `CMP-M2W2-AWS-TRN3-SBUF / FIELD-MEM-CAPACITY` | `COND-NONE` | SRC-M2-GA-A07: 32 MiB per NCv4 SBUF | 33554432 byte | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2030, NCv4 memory paragraph | “SBUF capacity is 32 MiB” |
| `FACT-M2W2-AWS-TRN3-PSUM-CAPACITY` | `CMP-M2W2-AWS-TRN3-PSUM / FIELD-MEM-CAPACITY` | `COND-NONE` | SRC-M2-GA-A07: 2 MiB per NCv4 PSUM | 2097152 byte | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2030, NCv4 memory paragraph | “PSUM capacity remains the same at 2 MiB” |
| `FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-CAPACITY` | `COND-M2W2-AWS-TRN3-DEVICE-BW` | SRC-M2-GA-A06: 144 GiB<br>SRC-M2-GA-A07: 144 GiB | 154618822656 byte | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1904-1905, Device memory row<br>SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2016-2020, device list | “144 GiB of device memory”<br>“device memory capacity of 144 GiB” |
| `FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-CAPACITY` | `COND-M2W2-AWS-TRN3-DEVICE-BW` | SRC-M2-GA-A08: 144 GB | 144000000000 byte | SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2116, single-chip sentence | “144 GB of HBM3e memory” |
| `FACT-M2W2-AWS-TRN3-HBM-BW-49` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN3-DEVICE-BW` | SRC-M2-GA-A06: 4.9 TB/sec<br>SRC-M2-GA-A08: 4.9 TB/s | 4900000000000 byte/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1904-1905, Device memory row<br>SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2116, single-chip sentence | “4.9 TB/sec of bandwidth”<br>“4.9 TB/s of memory bandwidth” |
| `FACT-M2W2-AWS-TRN3-HBM-BW-47` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN3-DEVICE-BW` | SRC-M2-GA-A07: 4.7 TB/s | 4700000000000 byte/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2018-2020, device list | “bandwidth of 4.7 TB/s” |
| `FACT-M2W2-AWS-TRN3-HBM-STACKS` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-INSTANCE-COUNT` | `COND-NONE` | SRC-M2-GA-A07: 4 HBM stacks per device | 4 count | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2016-2020, device list | “4 HBM stacks” |
| `FACT-M2W2-AWS-TRN3-DMA-COUNT` | `CMP-M2W2-AWS-TRN3-DMA / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A07: 128 DMA engines per device | 128 count | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2020-2021, device list | “128 DMA (Direct Memory Access) engines” |
| `FACT-M2W2-AWS-TRN3-DMA-BW` | `CMP-M2W2-AWS-TRN3-DMA / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN3-DMA-BW` | SRC-M2-GA-A06: 4.9 TB/sec | 4900000000000 byte/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1907-1908, Data movement row | “4.9 TB/sec of DMA bandwidth” |
| `FACT-M2W2-AWS-TRN3-CC-COUNT-16` | `CMP-M2W2-AWS-TRN3-CC / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A06: 16 CC-Cores per device | 16 count | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1916-1917, Collective communication row | “16 CC-Cores” |
| `FACT-M2W2-AWS-TRN3-CC-COUNT-20` | `CMP-M2W2-AWS-TRN3-CC / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A07: 20 CC-Cores per device | 20 count | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2020-2022, device list | “20 CC-Cores” |
| `FACT-M2W2-AWS-TRN3-NEURONLINK-COUNT` | `LINK-M2W2-AWS-TRN3-NEURONLINKV4 / FIELD-INT-PHYSICAL-LINK-COUNT` | `COND-NONE` | SRC-M2-GA-A07: 4 NeuronLink-v4 interfaces per device | 4 count | SRC-M2-GA-A07: A07 v2.31.0 snapshot lines 2021-2023, device list | “4 NeuronLink-v4” |
| `FACT-M2W2-AWS-TRN3-NEURONLINK-BW` | `LINK-M2W2-AWS-TRN3-NEURONLINKV4 / FIELD-INT-AGGREGATE-BW` | `COND-M2W2-AWS-TRN3-NEURONLINK-BW` | SRC-M2-GA-A06: 2.56 TB/sec per device | 2560000000000 byte/s | SRC-M2-GA-A06: A06 v2.28.1 snapshot lines 1910-1911, NeuronLink row | “provides 2.56 TB/sec bandwidth per device” |
| `FACT-M2W2-AWS-TRN3-PROCESS` | `OBJ-AWS-TRAINIUM3-CHIP / FIELD-PHY-PROCESS` | `COND-NONE` | SRC-M2-GA-A08: first 3nm AWS AI chip | 3 nm | SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2113, announcement lead | “our first 3nm AWS AI chip” |
| `FACT-M2W2-AWS-TRN3-HBM-TYPE` | `CMP-M2W2-AWS-TRN3-HBM / FIELD-MEM-NAME` | `COND-NONE` | SRC-M2-GA-A08: HBM3e memory | HBM3e | SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2116, single-chip sentence | “144 GB of HBM3e memory” |

## 冲突与口径

| conflict_group_id | 类型 | 候选 fact_id | 当前处理 |
|---|---|---|---|
| `CONFLICT-M2W2-AWS-TRN3-HBM-CAPACITY` | `unit_disagreement` | `FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB`<br>`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB` | 官方开发文档写 144 GiB，定日公告写 144 GB；两种原始单位及规范值均保留，不能静默归一。 |
| `CONFLICT-M2W2-AWS-TRN3-HBM-BW` | `value_disagreement` | `FACT-M2W2-AWS-TRN3-HBM-BW-49`<br>`FACT-M2W2-AWS-TRN3-HBM-BW-47` | 官方页面对同一芯片级 HBM 带宽分别给出 4.9 TB/s 与 4.7 TB/s；未找到版本关系说明。 |
| `CONFLICT-M2W2-AWS-TRN3-CC-COUNT` | `value_disagreement` | `FACT-M2W2-AWS-TRN3-CC-COUNT-16`<br>`FACT-M2W2-AWS-TRN3-CC-COUNT-20` | 官方 Trainium3 页面写 16 个 CC Core，NKI 实现页面写 20 个 CC Core；当前不选择其一。 |

## 物理构造缺口

| requirement_id | 字段 | 状态 | 处理原则 |
|---|---|---|---|
| `REQ-M2W2-AWS-PKG-066` | `FIELD-PHY-PACKAGE` | `not_found` | 已固定的一手实现页面未给出该 package 对象的封装方式；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-067` | `FIELD-PHY-DIE-COUNT` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片或芯粒数量；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-068` | `FIELD-PHY-INTERPOSER` | `not_found` | 已固定的一手实现页面未给出该 package 对象的中介层或基板；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-069` | `FIELD-PHY-DIE-AREA` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片面积；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-070` | `FIELD-PHY-TRANSISTORS` | `not_found` | 已固定的一手实现页面未给出该 package 对象的晶体管数量；不从产品名、实例配置或相邻代际推断。 |

## 最小来源候选

以下来源都通过逐来源反向移除：删去任何一个，当前 57 条跨对象事实集合中都会有至少一条事实失去唯一直接证据。这里按 `source_id` 计数；同一正文的 latest 与 v2.31.0 抓取入口不会增加证据数量。

| source_id | 本卡中的不可替代作用 |
|---|---|
| `SRC-M2-GA-A06` | 在本卡直接支持 10 条事实：`FACT-M2W2-AWS-TRN3-NCV4-COUNT`、`FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK`、`FACT-M2W2-AWS-TRN3-CHIP-MIXED-PEAK`、`FACT-M2W2-AWS-TRN3-CHIP-SPARSE-PEAK`、`FACT-M2W2-AWS-TRN3-CHIP-FP32-PEAK`、`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB`、`FACT-M2W2-AWS-TRN3-HBM-BW-49`、`FACT-M2W2-AWS-TRN3-DMA-BW`、`FACT-M2W2-AWS-TRN3-CC-COUNT-16`、`FACT-M2W2-AWS-TRN3-NEURONLINK-BW`。这些事实的完整反向移除理由见 structured/selection-members.csv。 |
| `SRC-M2-GA-A07` | 在本卡直接支持 15 条事实：`FACT-M2W2-AWS-TRN3-NCV4-COUNT`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MX`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MIXED`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK`、`FACT-M2W2-AWS-TRN3-SBUF-CAPACITY`、`FACT-M2W2-AWS-TRN3-PSUM-CAPACITY`、`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB`、`FACT-M2W2-AWS-TRN3-HBM-BW-47`、`FACT-M2W2-AWS-TRN3-HBM-STACKS`、`FACT-M2W2-AWS-TRN3-DMA-COUNT`、`FACT-M2W2-AWS-TRN3-CC-COUNT-20`、`FACT-M2W2-AWS-TRN3-NEURONLINK-COUNT`。其中 8 条在移除 A07 后失去唯一直接证据；完整清单见 structured/selection-members.csv。 |
| `SRC-M2-GA-A08` | 在本卡直接支持 5 条事实：`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB`、`FACT-M2W2-AWS-TRN3-HBM-BW-49`、`FACT-M2W2-AWS-TRN3-PROCESS`、`FACT-M2W2-AWS-TRN3-HBM-TYPE`、`FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC`。其中 4 条在移除 A08 后失去唯一直接证据；完整清单见 structured/selection-members.csv。 |
A10 仍为五条 Trainium3 事实提供直接断言，也继续支撑既有架构链；但 A07 已覆盖这五条事实，所以 A10 不属于本轮 package 八源最小集，来源、endpoint 和旧断言均不删除。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| `identity` | `partial` | 芯片/器件身份与 architecture 实现关系已有正式对象和关系；package 物理构造仍未证明。 |
| `physical` | `partial` | 只登记来源明确给出的制程或 HBM 堆叠等实现量；封装、裸片数、中介层、裸片面积和晶体管数均保留 not_found。 |
| `compute` | `partial` | 登记芯片级或每 NeuronCore 的公开峰值，不复制执行机制。 |
| `numerics` | `partial` | 仅登记带明确输入精度和作用域的峰值路径；累加器物理位宽等机制仍由架构对象负责。 |
| `memory` | `partial` | 登记容量、带宽和公开片上层级；有单位或数值分歧时并列。 |
| `interconnect` | `partial` | 仅登记芯片级接口数或聚合额定速率；方向与有效载荷未公开。 |
| `special_engines` | `partial` | 只登记实现数量；功能机制保留在架构对象。 |
| `software` | `not_applicable` | 软件栈不属于本轮 package 实现对象，沿 implements_architecture 关系复用，不重复建事实。 |
| `evidence` | `needs_review` | 11 个同日抓取件均已登记新 endpoint 候选；latest 与 v2.31.0 同正文只算一个 source_id，仍待独立复核。 |

## 复核入口

逐来源断言位于 `structured/fact-assertions.csv`，其中保留完整 raw 值、规范值映射、稳定 locator、短摘录和作用域。`audit/card-fact-coverage.csv` 反向列出本卡全部 fact_id。结构化候选尚未进入正式库，独立复核者应重点检查对象层级、条件一致性、GB/GiB 口径、同正文去重和冲突组成员。
