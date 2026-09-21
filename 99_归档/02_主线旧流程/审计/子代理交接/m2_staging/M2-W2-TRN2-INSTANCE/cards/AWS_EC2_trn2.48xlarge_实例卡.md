# AWS EC2 trn2.48xlarge 实例卡（草稿）

> 卡片状态：`draft`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2-48XLARGE`  
> 正式对象类型：`cloud_instance`  
> 复核人：尚未指定

## 1. 对象和范围

`trn2.48xlarge` 是 EC2 Trn2 家族中的 16 芯片实例 SKU。实例、家族、Trainium2 package 和 Trainium2 architecture 已有正式对象；本卡使用现有关系，不建立实例到架构的捷径关系。

| 项目 | 内容 | 正式标识 |
|---|---|---|
| 厂商与名称 | AWS；Amazon EC2 `trn2.48xlarge` | `OBJ-AWS-TRN2-48XLARGE` |
| 配置族 | Amazon EC2 Trn2 instance family | `OREL-AWS-TRN2-48XLARGE-VARIANT-OF-FAMILY` |
| 加速器组成 | 16 个 AWS Trainium2 chip | `OREL-AWS-TRN2-48XLARGE-CONTAINS-TRAINIUM2`；`FACT-AWS-TRN2-48XL-CHIP-QTY` |
| 架构引用链 | 实例 → Trainium2 chip → Trainium2 architecture | `OREL-AWS-TRN2-48XLARGE-CONTAINS-TRAINIUM2`；`OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` |
| 2024-12-03 状态 | `available` | `FACT-AWS-TRN2-48XL-STATUS-GA`；`SRC-AWS-TRN2-S09` |

本卡不包含 UltraServer 的 64 芯片、跨实例 ring、系统 EFA 或供货状态，也不把 Trainium2 芯片定值复制到实例名下。

## 2. 物理实现

实例的封装、裸片、晶体管、芯片功耗和冷却不是本对象事实。相关内容留在 `OBJ-AWS-TRAINIUM2-CHIP` 或系统对象；实例资源不能反推单芯片物理规格。

## 3. 计算资源

### 3.1 实例级厂商直报峰值

| 格式 | 稠密峰值 | 当前结构化稀疏值 | 2024 发布博客历史值 | 正式事实 |
|---|---:|---:|---:|---|
| FP8 | 20.8 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-48XL-FP8-DENSE`；`FACT-AWS-TRN2-48XL-FP8-SPARSE`；`FACT-AWS-TRN2-48XL-FP8-SPARSE-HIST2024` |
| BF16 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-48XL-BF16-DENSE`；`FACT-AWS-TRN2-48XL-BF16-SPARSE`；`FACT-AWS-TRN2-48XL-BF16-SPARSE-HIST2024` |
| FP16 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-48XL-FP16-DENSE`；`FACT-AWS-TRN2-48XL-FP16-SPARSE`；`FACT-AWS-TRN2-48XL-FP16-SPARSE-HIST2024` |
| TF32 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-48XL-TF32-DENSE`；`FACT-AWS-TRN2-48XL-TF32-SPARSE`；`FACT-AWS-TRN2-48XL-TF32-SPARSE-HIST2024` |
| FP32 | 2.9 PFLOPS | 未列 | 未列 | `FACT-AWS-TRN2-48XL-FP32-DENSE` |

这些数值都是实例级直接断言，不由 16 倍芯片峰值生成。AWS 未在当前事实中统一说明运算计数规则、频率条件或 2024 与当前表之间的版本差异。八条稀疏事实保持 `conflict_member`，不能挑一组覆盖另一组。

## 4. 数值格式和累加

FP8、BF16、FP16、TF32 与 FP32 的峰值标签保留在各自 precision path。操作数、内部乘积、累加和舍入语义属于 Trainium2 架构或芯片事实，本卡只通过正式关系引用，不复制为实例事实。

## 5. 存储层次

| 项目 | 原始值 | 规范化值 | 当前处理 | 正式事实 |
|---|---:|---:|---|---|
| 加速器内存 | 1,536 GiB | 1,649,267,441,664 byte | 产品/架构页直接值；保持冲突成员以与通用表并列 | `FACT-AWS-TRN2-48XL-MEM-CAP` |
| 通用 EC2 表候选 | 8,192 GiB | 8,796,093,022,208 byte | `SRC-AWS-TRN2-S15` 已筛为 `rejected_unreliable`，只作冲突审计 | `FACT-AWS-TRN2-48XL-MEM-CAP-GENERIC` |
| 实例内存带宽 | 46.4 TB/s | 46,400,000,000,000 byte/s | 实例聚合直报值；方向细节未完整披露 | `FACT-AWS-TRN2-48XL-MEM-BW` |

GiB 与 TB/s 的原始单位分别保留。本卡不把 1,536 GiB 或 46.4 TB/s 除以 16 后写成芯片事实。

## 6. 计算与存储配比

本包不增加派生指标。当前事实虽在同一实例对象上，但稀疏峰值存在版本冲突，内存带宽方向和持续性条件也不完整；保留原值比生成未经裁决的 FLOP/byte 更安全。

## 7. 大模型相关特殊能力

MoE、Router Top-K、集合通信、转置与压缩的硬件或软件实现由 Trainium2 架构和芯片事实承接。实例卡不把软件算子写成专用物理模块，也不把实例聚合峰值解释为持续工作负载性能。

## 8. 互联和系统扩展

| 层级 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 实例内 NeuronLink-v3 | 1,024 GB/s/chip | 1,024,000,000,000 byte/s | 实例内；原表未完整说明方向或有效载荷 | `FACT-AWS-TRN2-48XL-INTRA-BW` |
| 拓扑 | 4×4 two-dimensional torus；16 节点 | `torus`；4×4；16 count | 16 个 Trainium2 的实例内拓扑 | `FACT-AWS-TRN2-48XL-TOPO-TYPE`；`FACT-AWS-TRN2-48XL-TOPO-DIMS`；`FACT-AWS-TRN2-48XL-TOPO-NODES` |
| EFAv3 scale-out | 3.2 Tbps | 3,200,000,000,000 bit/s | 实例级；不等同于 NeuronLink-v3 | `FACT-AWS-TRN2-48XL-EFA-RATE` |
| 对分带宽 | `not_found` | 未填零 | `REQ-AWS-TRN2-0185` | 无事实 |

UltraServer 跨实例同坐标 ring 和系统 EFA 不在本卡内。

## 9. 软件、可靠性和实测补充

共享编程模型与运行时通过 `FACT-AWS-TRN2-ARCH-SW-MODEL`、`FACT-AWS-TRN2-ARCH-SW-RUNTIME` 引用，事实目标保持 `OBJ-AWS-TRAINIUM2-ARCH`。实例专属 ECC、故障降级、过订阅、可用性 SLA 与第三方微基准没有本包合格事实。

## 10. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| 当前与历史稀疏峰值 | `conflicting_unresolved` | 四个 `CG-AWS-TRN2-003-48XL-*` 组；41 与 83.2 PFLOPS 不相互覆盖 |
| 内存容量 | `conflicting_unresolved` | `CG-AWS-TRN2-006-48XL-MEM`；1,536 GiB 对 8,192 GiB，后者来源已拒绝 |
| 对分带宽 | `not_found` | `REQ-AWS-TRN2-0185`；不从 4×4 torus 推算 |
| 带宽方向与有效载荷 | `not_found` | 1,024 GB/s/chip 和 3.2 Tbps 只保留厂商原口径 |

## 11. 最小参考资料

| 来源 | 角色 | 独有贡献 | 筛选结论 |
|---|---|---|---|
| `SRC-AWS-TRN2-S06` | `core_spec` | 16 芯片、实例峰值、1,536 GiB、46.4 TB/s、实例内互联和拓扑 | `selected` |
| `SRC-AWS-TRN2-S07` | `core_spec` | 3.2 Tbps EFA；2026-08-13 同日页已固定 | `selected` |
| `SRC-AWS-TRN2-S09` | `status_version_evidence` | 2024-12-03 正式可用状态 | `selected` |
| `SRC-AWS-TRN2-S10` | `conflict_evidence` | 2024 年 83.2 PFLOPS 稀疏历史值 | `selected` |
| `SRC-AWS-TRN2-S15` | `conflict_evidence` | 8,192 GiB 错误候选审计链 | `rejected_unreliable`，不进入最小入选集 |

## 12. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `complete` | 实例身份、家族、16 芯片组成和 2024-12-03 状态均有固定证据 |
| 物理实现 | `not_applicable` | package 与系统物理事实不上卷或下放 |
| 计算资源 | `partial` | 稠密值完整；稀疏当前与历史口径未决 |
| 数值格式 | `partial` | 格式标签可确认；内部精度语义只引用架构事实 |
| 存储层次 | `partial` | 容量与带宽有值；容量存在被拒绝来源冲突 |
| 互联 | `partial` | torus、节点数、实例内带宽和 EFA 有值；方向、延迟、对分带宽缺失 |
| 特殊能力 | `not_applicable` | 本卡不复制架构或软件能力 |
| 软件 | `partial` | 软件链可引用，未抽取实例专属版本 |
| 来源证据 | `complete` | 四个入选一手来源均有固定版本或当日快照；S15 保留为被拒绝审计来源 |

## 13. 复核状态

本卡映射 23 条正式实例事实，没有新建或复制事实、断言、关系或字段要求。卡片到正式 fact_id 的唯一映射见 `sources/card-fact-map.csv`。当前仅为初稿，须由未参与撰写者独立复核。
