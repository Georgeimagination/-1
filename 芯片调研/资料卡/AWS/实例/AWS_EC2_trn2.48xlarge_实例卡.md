# AWS EC2 trn2.48xlarge 实例卡

> 卡片状态：`已验收`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2-48XLARGE`  
> 正式对象类型：`cloud_instance`  
> 复核人：`m2_review_trn2_correction`

## 1. 对象和范围

`trn2.48xlarge` 是 EC2 Trn2 家族的 16 芯片实例规格。它通过 `OREL-AWS-TRN2-48XLARGE-VARIANT-OF-FAMILY` 归入配置族，通过 `OREL-AWS-TRN2-48XLARGE-CONTAINS-TRAINIUM2` 连接 Trainium2；架构引用继续经过 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH`。

`FACT-AWS-TRN2-48XL-CHIP-QTY` 记录 16 颗 Trainium2。`FACT-AWS-TRN2-48XL-STATUS-GA` 与 S09 记录 2024-12-03 的 `available` 状态。本卡不包含 UltraServer 的 64 芯片、跨实例 ring、系统 EFAv3 或供货状态。

## 2. 物理实现

实例的裸片、封装、晶体管、芯片功耗和冷却不是本对象事实。云实例资源不能反推单颗 Trainium2 的物理规格。

## 3. 计算资源

| 格式 | 稠密峰值 | 当前结构化稀疏峰值 | 2024 历史值 | 当前处理 |
|---|---:|---:|---:|---|
| FP8 | 20.8 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | 当前值与历史值分别保留在 `CG-AWS-TRN2-003-48XL-FP8` |
| BF16 | 10.7 PFLOPS | 41 PFLOPS | 无受支持历史值 | S06 当前值为 `single_source / provisional / reviewed` |
| FP16 | 10.7 PFLOPS | 41 PFLOPS | 无受支持历史值 | S06 当前值为 `single_source / provisional / reviewed` |
| TF32 | 10.7 PFLOPS | 41 PFLOPS | 无受支持历史值 | S06 当前值为 `single_source / provisional / reviewed` |
| FP32 | 2.9 PFLOPS | 未列 | 未列 | S06 当前直接值 |

S10 只写 FP8：2024 年发布时 “Each Trn2 instance” 为 83.2 PFLOPS sparse FP8。该语境对应当时的 `trn2.48xlarge`，所以只保留 `FACT-AWS-TRN2-48XL-FP8-SPARSE-HIST2024`。原先扩写出的 BF16、FP16 和 TF32 三条历史事实、断言、要求、条件及冲突组全部删除。

上述当前峰值均是实例级一手直报，不由单芯片数值乘 16 生成。源文仍未统一说明运算计数规则、频率或稀疏条件，FP8 的 41 与 83.2 PFLOPS 不相互覆盖。

## 4. 数值格式和累加

FP8、BF16、FP16、TF32 与 FP32 的峰值标签保留在各自 precision path（精度路径）。操作数、内部乘积、累加和舍入语义属于 Trainium2 架构或芯片事实，本卡不复制。

## 5. 存储层次

| 来源口径 | 原始值 | 规范化值 | 正式记录 |
|---|---:|---:|---|
| S06 实例内存 | 1,536 GiB | 1,649,267,441,664 byte | `FACT-AWS-TRN2-48XL-MEM-CAP` |
| S15 通用 EC2 表 | 8,192 GiB | 8,796,093,022,208 byte | `FACT-AWS-TRN2-48XL-MEM-CAP-GENERIC` |
| S06 实例内存带宽 | 46.4 TB/s | 46,400,000,000,000 byte/s | `FACT-AWS-TRN2-48XL-MEM-BW` |

两条容量声明属于 `CG-AWS-TRN2-006-48XL-MEM`。S15 已筛为 `rejected_unreliable`，但正式冲突组没有设置 `preferred_fact_id`，本卡不提前称其中一条为采用值。带宽原文没有完整方向和持续性条件。

## 6. 计算与存储配比

本包不新增 FLOP/byte 派生指标。FP8 稀疏峰值仍有版本冲突，内存带宽的方向和持续性条件也未闭合。

## 7. 大模型相关特殊能力

Mixture of Experts（MoE，混合专家）、Router Top-K、Attention、集合通信、转置和压缩由 Trainium2 架构、芯片及 Neuron 软件事实承接。实例卡不把软件算子写成专用物理模块。

## 8. 互联和系统扩展

| 层级 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 实例内 NeuronLink-v3 | 1,024 GB/s/chip | 1,024,000,000,000 byte/s | 实例内；方向和有效载荷未完整说明 | `FACT-AWS-TRN2-48XL-INTRA-BW` |
| 拓扑 | 4×4 two-dimensional torus；16 节点 | `torus`；4×4；16 count | 16 颗 Trainium2 的实例内拓扑 | `FACT-AWS-TRN2-48XL-TOPO-TYPE`、`-DIMS`、`-NODES` |
| EFAv3 scale-out | 3.2 Tbps | 400,000,000,000 byte/s | `FIELD-INT-INJECTION-BW`；按实例；不假设物理链路数 | `FACT-AWS-TRN2-48XL-EFA-RATE` |
| 对分带宽 | `not_found` | 不填零 | `REQ-AWS-TRN2-0185` | 无事实 |

S07 Product details 表的表头是 `Network bandwidth (Tbps)`，因此 3.2 Tbps 属于实例网络注入口径，不是 `FIELD-INT-PER-LINK-RATE`。原始 Tbps 保留在断言，规范字段按 byte/s 存储。

## 9. 软件、可靠性和实测补充

共享编程模型与运行时通过 `FACT-AWS-TRN2-ARCH-SW-MODEL`、`FACT-AWS-TRN2-ARCH-SW-RUNTIME` 引用。实例专属的纠错码、故障降级、过订阅、服务等级和第三方微基准没有本包合格事实。

## 10. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| FP8 当前与历史稀疏峰值 | `conflicting_unresolved` | 只保留 `CG-AWS-TRN2-003-48XL-FP8`；41 与 83.2 PFLOPS 条件未调和 |
| BF16、FP16、TF32 当前稀疏峰值 | `value_available` | S10 不支持相应历史值，三条伪冲突链删除 |
| 内存容量 | `conflicting_unresolved` | S06 与 S15 声明并列，正式冲突组未设置优选事实 |
| 带宽方向、有效载荷与对分带宽 | `not_found` | 不根据 torus 或系统聚合值推算 |

## 11. 最小参考资料

39 条可采纳事实的全局最小集中，S06、S07、S09 和 S10 均不可移除。本卡的 20 条映射中，S06 支持 16 条，S07 支持实例 EFAv3 一条，S09 支持状态一条，S10 支持 FP8 历史值一条；S15 的一条容量声明只作 rejected audit claim（被拒绝的审计声明），不计入可采纳分母。

## 12. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `complete` | 实例身份、家族、16 芯片组成和 2024-12-03 状态有一手证据 |
| 物理实现 | `not_applicable` | 器件与系统物理事实不上卷或下放 |
| 计算资源 | `partial` | 当前峰值有值；FP8 历史条件未调和，持续性能未找到 |
| 数值格式 | `partial` | 峰值格式标签明确；内部精度语义只引用架构事实 |
| 存储层次 | `partial` | 容量与带宽有值；容量冲突未正式裁决 |
| 互联 | `partial` | torus、实例内带宽和 EFAv3 注入带宽有值；方向、延迟、对分带宽缺失 |
| 特殊能力 | `not_applicable` | 不复制架构或软件能力 |
| 软件 | `partial` | 共享软件链可引用，未抽取实例专属版本 |
| 来源证据 | `complete` | 20 条映射均有断言或明确的 rejected audit chain；最小来源分母另按 19 条可采纳事实计算 |

## 13. 复核状态

本卡映射 20 条正式实例事实，没有复制架构事实或 UltraServer 系统事实。唯一映射见 `sources/card-fact-map.csv`。本卡与修复 overlay 须由未参与撰写者独立复核后才能合并。