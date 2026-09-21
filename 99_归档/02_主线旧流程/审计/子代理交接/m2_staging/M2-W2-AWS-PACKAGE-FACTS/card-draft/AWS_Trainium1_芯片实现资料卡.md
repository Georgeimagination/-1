# AWS Trainium1 芯片实现资料卡

状态：`ready_for_independent_review`；对象层级：`package`；候选事实：11 条。

## 对象边界

本卡只描述 `OBJ-AWS-TRAINIUM1-CHIP` 的单芯片实现量。正式关系 `OREL-AWS-TRAINIUM1-IMPLEMENTS-ARCH` 将它连接到架构对象 `OBJ-AWS-TRAINIUM1-ARCH`；执行机制、数值语义和软件接口沿该关系复用，不在 package 对象上复制。云实例中的芯片数、服务器或机架聚合值均不进入本卡。NeuronCore-v2（NCv2，AWS 第二代 Neuron 计算核）是该芯片的实现组件。HBM 指高带宽存储器，DMA 指直接存储器访问，CC-Core 指集合通信核。

现有一手页面能证明“芯片/器件”边界，但不能证明它是单裸片，也没有给出封装方式、芯粒数量、中介层、裸片面积或晶体管数。因此这里的 `package` 是保守的事实容器，不是对物理封装构造的结论。

## 实现事实候选

| fact_id | 作用域与字段 | 条件 | 原文值 | 规范值 | 来源与稳定定位 | 原文短摘录 |
|---|---|---|---|---|---|---|
| `FACT-M2W2-AWS-TRN1-NCV2-COUNT` | `CMP-M2W2-AWS-TRN1-NCV2 / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A03: 2 NeuronCore-v2 per chip<br>SRC-M2-GA-A05: 2 NeuronCore-v2 per device | 2 count | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1562-1573, Trainium chip table<br>SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1928-1932, device overview | “each Trainium include 2 x NeuronCore-v2”<br>“2 NeuronCores (v2)” |
| `FACT-M2W2-AWS-TRN1-CHIP-INT8-PEAK` | `PP-M2W2-AWS-TRN1-CHIP-INT8 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN1-CHIP-INT8` | SRC-M2-GA-A03: 380 INT8 TOPS | 380000000000000 OP/s | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1569-1573, Compute row | “delivering 380 INT8 TOPS” |
| `FACT-M2W2-AWS-TRN1-CHIP-MIXED-PEAK` | `PP-M2W2-AWS-TRN1-CHIP-MIXED / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN1-CHIP-MIXED` | SRC-M2-GA-A03: 190 FP16/BF16/cFP8/TF32 TFLOPS | 190000000000000 FLOP/s | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1569-1573, Compute row | “190 FP16/BF16/cFP8/TF32 TFLOPS” |
| `FACT-M2W2-AWS-TRN1-CHIP-FP32-PEAK` | `PP-M2W2-AWS-TRN1-CHIP-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN1-CHIP-FP32` | SRC-M2-GA-A03: 47.5 FP32 TFLOP/s | 47500000000000 FLOP/s | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1569-1573, Compute row | “47.5 FP32 TFLOP” |
| `FACT-M2W2-AWS-TRN1-HBM-CAPACITY` | `CMP-M2W2-AWS-TRN1-HBM / FIELD-MEM-CAPACITY` | `COND-M2W2-AWS-TRN1-DEVICE-BW` | SRC-M2-GA-A03: 32 GiB<br>SRC-M2-GA-A05: 32 GiB | 34359738368 byte | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1575-1578, Device Memory row<br>SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1928-1933, device overview | “32 GiB of device memory”<br>“total device memory capacity of 32GiB” |
| `FACT-M2W2-AWS-TRN1-HBM-BW-GIB` | `CMP-M2W2-AWS-TRN1-HBM / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN1-DEVICE-BW` | SRC-M2-GA-A03: 820 GiB/sec | 880468295680 byte/s | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1575-1578, Device Memory row | “820 GiB/sec of bandwidth” |
| `FACT-M2W2-AWS-TRN1-HBM-BW-GB` | `CMP-M2W2-AWS-TRN1-HBM / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN1-DEVICE-BW` | SRC-M2-GA-A05: 820 GB/s | 820000000000 byte/s | SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1928-1935, device overview | “bandwidth of 820 GB/s” |
| `FACT-M2W2-AWS-TRN1-DMA-BW` | `CMP-M2W2-AWS-TRN1-DMA / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-TRN1-DMA-BW` | SRC-M2-GA-A03: 1 TB/sec | 1000000000000 byte/s | SRC-M2-GA-A03: A03 v2.26.1 snapshot lines 1580-1583, Data Movement row | “1 TB/sec of DMA bandwidth” |
| `FACT-M2W2-AWS-TRN1-DMA-COUNT` | `CMP-M2W2-AWS-TRN1-DMA / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A05: 32 DMA engines per device | 32 count | SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1931-1934, device overview | “32 DMA engines” |
| `FACT-M2W2-AWS-TRN1-CC-COUNT` | `OBJ-AWS-TRAINIUM1-CHIP / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A05: 6 CC-Cores per device | 6 count | SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1933-1935, device overview | “6 CC-Cores for collective communication” |
| `FACT-M2W2-AWS-TRN1-NEURONLINK-COUNT` | `LINK-M2W2-AWS-TRN1-NEURONLINKV2 / FIELD-INT-PHYSICAL-LINK-COUNT` | `COND-NONE` | SRC-M2-GA-A05: 4 NeuronLink-v2 interfaces per Trainium device | 4 count | SRC-M2-GA-A05: A05 v2.29.1 snapshot lines 1933-1935, device overview | “4 (Trainium) NeuronLink-v2” |

## 冲突与口径

| conflict_group_id | 类型 | 候选 fact_id | 当前处理 |
|---|---|---|---|
| `CONFLICT-M2W2-AWS-TRN1-HBM-BW` | `unit_disagreement` | `FACT-M2W2-AWS-TRN1-HBM-BW-GIB`<br>`FACT-M2W2-AWS-TRN1-HBM-BW-GB` | 同一实现对象的官方页面分别写 820 GiB/s 与 820 GB/s；单位标签不同，当前不换算后合并。 |

## 物理构造缺口

| requirement_id | 字段 | 状态 | 处理原则 |
|---|---|---|---|
| `REQ-M2W2-AWS-PKG-056` | `FIELD-PHY-PACKAGE` | `not_found` | 已固定的一手实现页面未给出该 package 对象的封装方式；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-057` | `FIELD-PHY-DIE-COUNT` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片或芯粒数量；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-058` | `FIELD-PHY-INTERPOSER` | `not_found` | 已固定的一手实现页面未给出该 package 对象的中介层或基板；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-059` | `FIELD-PHY-DIE-AREA` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片面积；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-060` | `FIELD-PHY-TRANSISTORS` | `not_found` | 已固定的一手实现页面未给出该 package 对象的晶体管数量；不从产品名、实例配置或相邻代际推断。 |

## 最小来源候选

以下来源都通过逐来源反向移除：删去任何一个，当前 56 条跨对象事实集合中都会有至少一条事实失去唯一直接证据。这里按 `source_id` 计数；同一正文的 latest 与 v2.31.0 抓取入口不会增加证据数量。

| source_id | 本卡中的不可替代作用 |
|---|---|
| `SRC-M2-GA-A03` | 在本卡直接支持 7 条事实：`FACT-M2W2-AWS-TRN1-NCV2-COUNT`、`FACT-M2W2-AWS-TRN1-CHIP-INT8-PEAK`、`FACT-M2W2-AWS-TRN1-CHIP-MIXED-PEAK`、`FACT-M2W2-AWS-TRN1-CHIP-FP32-PEAK`、`FACT-M2W2-AWS-TRN1-HBM-CAPACITY`、`FACT-M2W2-AWS-TRN1-HBM-BW-GIB`、`FACT-M2W2-AWS-TRN1-DMA-BW`。这些事实的完整反向移除理由见 structured/selection-members.csv。 |
| `SRC-M2-GA-A05` | 在本卡直接支持 6 条事实：`FACT-M2W2-AWS-TRN1-NCV2-COUNT`、`FACT-M2W2-AWS-TRN1-HBM-CAPACITY`、`FACT-M2W2-AWS-TRN1-HBM-BW-GB`、`FACT-M2W2-AWS-TRN1-DMA-COUNT`、`FACT-M2W2-AWS-TRN1-CC-COUNT`、`FACT-M2W2-AWS-TRN1-NEURONLINK-COUNT`。这些事实的完整反向移除理由见 structured/selection-members.csv。 |

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| `identity` | `partial` | 芯片/器件身份与 architecture 实现关系已有正式对象和关系；package 物理构造仍未证明。 |
| `physical` | `missing_public_data` | 只登记来源明确给出的制程或 HBM 堆叠等实现量；封装、裸片数、中介层、裸片面积和晶体管数均保留 not_found。 |
| `compute` | `partial` | 登记芯片级或每 NeuronCore 的公开峰值，不复制执行机制。 |
| `numerics` | `partial` | 仅登记带明确输入精度和作用域的峰值路径；累加器物理位宽等机制仍由架构对象负责。 |
| `memory` | `partial` | 登记容量、带宽和公开片上层级；有单位或数值分歧时并列。 |
| `interconnect` | `partial` | 仅登记芯片级接口数或聚合额定速率；方向与有效载荷未公开。 |
| `special_engines` | `partial` | 只登记实现数量；功能机制保留在架构对象。 |
| `software` | `not_applicable` | 软件栈不属于本轮 package 实现对象，沿 implements_architecture 关系复用，不重复建事实。 |
| `evidence` | `needs_review` | 11 个同日抓取件均已登记新 endpoint 候选；latest 与 v2.31.0 同正文只算一个 source_id，仍待独立复核。 |

## 复核入口

逐来源断言位于 `structured/fact-assertions.csv`，其中保留完整 raw 值、规范值映射、稳定 locator、短摘录和作用域。`audit/card-fact-coverage.csv` 反向列出本卡全部 fact_id。结构化候选尚未进入正式库，独立复核者应重点检查对象层级、条件一致性、GB/GiB 口径、同正文去重和冲突组成员。
