# AWS Inferentia1 芯片实现资料卡

状态：`accepted`；对象层级：`package`；正式事实：8 条。

## 对象边界

本卡只描述 `OBJ-AWS-INFERENTIA1-CHIP` 的单芯片实现量。正式关系 `OREL-AWS-INFERENTIA1-IMPLEMENTS-ARCH` 将它连接到架构对象 `OBJ-AWS-INFERENTIA1-ARCH`；执行机制、数值语义和软件接口沿该关系复用，不在 package 对象上复制。云实例中的芯片数、服务器或机架聚合值均不进入本卡。NeuronCore-v1（NCv1，AWS 第一代 Neuron 计算核）是该芯片的实现组件。DRAM 指动态随机存取存储器。

现有一手页面能证明“芯片/器件”边界，但不能证明它是单裸片，也没有给出封装方式、芯粒数量、中介层、裸片面积或晶体管数。因此这里的 `package` 是保守的事实容器，不是对物理封装构造的结论。

## 实现事实

| fact_id | 作用域与字段 | 条件 | 原文值 | 规范值 | 来源与稳定定位 | 原文短摘录 |
|---|---|---|---|---|---|---|
| `FACT-M2W2-AWS-INF1-NCV1-COUNT` | `CMP-M2W2-AWS-INF1-NCV1 / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A01: 4 NeuronCore-v1 per chip | 4 count | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1977-1987, Inferentia Architecture table | “each with four NeuronCore-v1” |
| `FACT-M2W2-AWS-INF1-CHIP-INT8-PEAK` | `PP-M2W2-AWS-INF1-CHIP-INT8 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-INF1-CHIP-INT8` | SRC-M2-GA-A01: 128 INT8 TOPS | 128000000000000 OP/s | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1983-1987, Compute row | “delivering 128 INT8 TOPS” |
| `FACT-M2W2-AWS-INF1-CHIP-FP16BF16-PEAK` | `PP-M2W2-AWS-INF1-CHIP-FP16BF16 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-INF1-CHIP-FP` | SRC-M2-GA-A01: 64 FP16/BF16 TFLOPS | 64000000000000 FLOP/s | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1983-1987, Compute row | “64 FP16/BF16 TFLOPS” |
| `FACT-M2W2-AWS-INF1-DRAM-CAPACITY` | `CMP-M2W2-AWS-INF1-DRAM / FIELD-MEM-CAPACITY` | `COND-M2W2-AWS-INF1-DEVICE-BW` | SRC-M2-GA-A01: 8 GiB | 8589934592 byte | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1989-1992, Device Memory row | “8GiB of device DRAM memory” |
| `FACT-M2W2-AWS-INF1-DRAM-BW` | `CMP-M2W2-AWS-INF1-DRAM / FIELD-MEM-BIDIR-BW` | `COND-M2W2-AWS-INF1-DEVICE-BW` | SRC-M2-GA-A01: 50 GiB/sec | 53687091200 byte/s | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1989-1992, Device Memory row | “50 GiB/sec of bandwidth” |
| `FACT-M2W2-AWS-INF1-NCV1-TENSOR-FP16BF16` | `PP-M2W2-AWS-INF1-NCV1-FP16BF16 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-INF1-CORE-FP` | SRC-M2-GA-A02: 16 FP16/BF16 TFLOPS | 16000000000000 FLOP/s | SRC-M2-GA-A02: A02 v2.9.1 snapshot lines 1766-1770, TensorEngine paragraph | “delivers 16 TFLOPS of FP16/BF16 tensor computations” |
| `FACT-M2W2-AWS-INF1-NCV1-VECTOR-OPS-CYCLE` | `PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-INF1-CORE-VECTOR` | SRC-M2-GA-A02: 256 floating operations/cycle | 256 OP/cycle | SRC-M2-GA-A02: A02 v2.9.1 snapshot lines 1759-1765, VectorEngine paragraph | “perform 256 floating point operations per cycle” |
| `FACT-M2W2-AWS-INF1-NCV1-SCALAR-OPS-CYCLE` | `PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-INF1-CORE-SCALAR` | SRC-M2-GA-A02: 512 floating operations/cycle | 512 OP/cycle | SRC-M2-GA-A02: A02 v2.9.1 snapshot lines 1753-1758, ScalarEngine paragraph | “process 512 floating point operations per cycle” |

## 冲突与口径

当前事实集合没有为该对象建立正式冲突组。这个结论只针对已固定的页面和已抽取字段，不代表没有资料缺口。

## 物理构造缺口

| requirement_id | 字段 | 状态 | 处理原则 |
|---|---|---|---|
| `REQ-M2W2-AWS-PKG-051` | `FIELD-PHY-PACKAGE` | `not_found` | 已固定的一手实现页面未给出该 package 对象的封装方式；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-052` | `FIELD-PHY-DIE-COUNT` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片或芯粒数量；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-053` | `FIELD-PHY-INTERPOSER` | `not_found` | 已固定的一手实现页面未给出该 package 对象的中介层或基板；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-054` | `FIELD-PHY-DIE-AREA` | `not_found` | 已固定的一手实现页面未给出该 package 对象的裸片面积；不从产品名、实例配置或相邻代际推断。 |
| `REQ-M2W2-AWS-PKG-055` | `FIELD-PHY-TRANSISTORS` | `not_found` | 已固定的一手实现页面未给出该 package 对象的晶体管数量；不从产品名、实例配置或相邻代际推断。 |

## 最小来源集

以下来源都通过逐来源反向移除：删去任何一个，当前 57 条跨对象事实集合中都会有至少一条事实失去唯一直接证据。这里按 `source_id` 计数；同一正文的 latest 与 v2.31.0 抓取入口不会增加证据数量。

| source_id | 本卡中的不可替代作用 |
|---|---|
| `SRC-M2-GA-A01` | 在本卡直接支持 5 条事实：`FACT-M2W2-AWS-INF1-NCV1-COUNT`、`FACT-M2W2-AWS-INF1-CHIP-INT8-PEAK`、`FACT-M2W2-AWS-INF1-CHIP-FP16BF16-PEAK`、`FACT-M2W2-AWS-INF1-DRAM-CAPACITY`、`FACT-M2W2-AWS-INF1-DRAM-BW`。这些事实的完整反向移除理由见 最小参考资料库/selection-members.csv。 |
| `SRC-M2-GA-A02` | 在本卡直接支持 3 条事实：`FACT-M2W2-AWS-INF1-NCV1-TENSOR-FP16BF16`、`FACT-M2W2-AWS-INF1-NCV1-VECTOR-OPS-CYCLE`、`FACT-M2W2-AWS-INF1-NCV1-SCALAR-OPS-CYCLE`。这些事实的完整反向移除理由见 最小参考资料库/selection-members.csv。 |

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| `identity` | `partial` | 芯片/器件身份与 architecture 实现关系已有正式对象和关系；package 物理构造仍未证明。 |
| `physical` | `missing_public_data` | 只登记来源明确给出的制程或 HBM 堆叠等实现量；封装、裸片数、中介层、裸片面积和晶体管数均保留 not_found。 |
| `compute` | `partial` | 登记芯片级或每 NeuronCore 的公开峰值，不复制执行机制。 |
| `numerics` | `partial` | 仅登记带明确输入精度和作用域的峰值路径；累加器物理位宽等机制仍由架构对象负责。 |
| `memory` | `partial` | 登记容量、带宽和公开片上层级；有单位或数值分歧时并列。 |
| `interconnect` | `missing_public_data` | 仅登记芯片级接口数或聚合额定速率；方向与有效载荷未公开。 |
| `special_engines` | `missing_public_data` | 只登记实现数量；功能机制保留在架构对象。 |
| `software` | `not_applicable` | 软件栈不属于本轮 package 实现对象，沿 implements_architecture 关系复用，不重复建事实。 |
| `evidence` | `complete` | 11 个同日抓取件均已固定并登记正式 endpoint；A01 与 A07 的 latest 和 v2.31.0 正文等价，各只计一个 source_id；最终独立复核已通过。 |

## 复核入口

逐来源断言已写入 `最小参考资料库/fact-assertions.csv`，其中保留完整 raw 值、规范值映射、稳定 locator、短摘录和作用域。本包的 `审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/audit/card-fact-coverage.csv` 反向列出本卡全部 fact_id；最终独立复核结论见 `审计/子代理交接/m2_final_review_aws_package.md`。
