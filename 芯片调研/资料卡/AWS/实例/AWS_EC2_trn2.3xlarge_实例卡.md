# AWS EC2 trn2.3xlarge 实例卡

> 卡片状态：`已验收`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2-3XLARGE`  
> 正式对象类型：`cloud_instance`  
> 复核人：`m2_review_trn2_correction`

## 1. 对象和范围

`trn2.3xlarge` 是 Amazon Elastic Compute Cloud（EC2，弹性计算云）Trn2 家族的单实例规格。它通过 `OREL-AWS-TRN2-3XLARGE-VARIANT-OF-FAMILY` 归入配置族，并通过 `OREL-AWS-TRN2-3XLARGE-CONTAINS-TRAINIUM2` 连接 Trainium2。实例到架构的引用继续经过 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH`，不新建捷径关系。

S07 的 Product details 表在 `Trn2.3xlarge` 行、`Trainium2 chips` 列给出 1。对应事实为 `FACT-AWS-TRN2-3XL-CHIP-QTY`，唯一断言改为 `ASSERT-FACT-AWS-TRN2-3XL-CHIP-QTY-S07`。S06 没有这个规格，原 S06 断言删除。

首次可用日期仍为 `pending_verification`，由 `REQ-AWS-TRN2-0194` 跟踪。UltraServer 的 64 芯片、跨实例 ring（环）和系统供货状态不属于本卡。

## 2. 物理实现

实例卡不承接裸片面积、封装尺寸、晶体管数、芯片功耗或散热定值。这些字段留在 Trainium2 器件或系统对象，不从云实例资源反推。

## 3. 计算资源与数值格式

本对象没有独立的一手实例级峰值事实。虽然它包含一颗 Trainium2，芯片的矩阵、向量、标量、格式和累加事实只通过对象关系引用，不复制为实例事实。

## 4. 存储层次

| 来源口径 | 原始值 | 规范化值 | 正式记录 |
|---|---:|---:|---|
| S07 产品页 | 96 GB | 96,000,000,000 byte | `FACT-AWS-TRN2-3XL-MEM-CAP` |
| S15 通用 EC2 表 | 512 GiB | 549,755,813,888 byte | `FACT-AWS-TRN2-3XL-MEM-CAP-GENERIC` |

两条声明均保留在 `CG-AWS-TRN2-006-3XL-MEM`。S15 的筛选状态是 `rejected_unreliable`，但正式冲突组尚未设置 `preferred_fact_id`；本卡不使用“采用值”或“错误值”提前代替冲突层裁决。GB 与 GiB 按各自原始单位换算。

## 5. 计算与存储配比

本卡不计算 FLOP/byte。实例级吞吐没有独立事实，把芯片吞吐直接搬到实例层会越过对象边界。

## 6. 特殊能力

Attention、Top-K、Mixture of Experts（MoE，混合专家）和集合通信的实现属于 Trainium2 架构、芯片或软件栈。本卡只引用相应对象，不新增实例专用硬件事实。

## 7. 互联和系统扩展

Elastic Fabric Adapter v3（EFAv3，第三代弹性网络适配器）在 S07 Product details 表中按实例给出 0.2 Tbps。`FACT-AWS-TRN2-3XL-EFA-RATE` 使用 `FIELD-INT-INJECTION-BW`：原始值仍留在断言中，规范值为 25,000,000,000 byte/s，条件为 `COND-AWS-TRN2-EFA-INSTANCE-INJECTION`。源文没有物理链路数量、方向或有效载荷口径，因此不解释为单链路速率。

EFAv3 是实例级 scale-out（横向扩展）网络，与芯片内 NeuronLink-v3 分开记录。

## 8. 软件、可靠性和部署

共享软件通过 `FACT-AWS-TRN2-ARCH-SW-MODEL` 与 `FACT-AWS-TRN2-ARCH-SW-RUNTIME` 引用，事实主语仍是 Trainium2 架构。实例专属的纠错码覆盖、故障域、虚拟化隔离和可用性服务等级没有本包的一手定值。

## 9. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| 首次可用日期 | `pending_verification` | `REQ-AWS-TRN2-0194`；不能由当前产品页反推首发日期 |
| 内存容量 | `conflicting_unresolved` | S07 与 S15 声明并列，正式冲突组未设置优选事实 |
| 实例内拓扑、实例内内存带宽、实例级峰值 | `not_found` 或未建要求 | 不从单颗 Trainium2 定值补写 |

## 10. 最小参考资料

`SRC-AWS-TRN2-S07` 是本卡三条可采纳事实的唯一直接来源：芯片数、96 GB 内存和 0.2 Tbps 实例网络。2026-08-13 快照与 2026-08-12 快照只在 nonce（一次性随机值）上不同，正文归一化后相同。`SRC-AWS-TRN2-S15` 只保存 512 GiB 声明的质量审计链，不进入 39 条可采纳事实的最小来源集。

## 11. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | SKU、家族和一颗 Trainium2 已确认；首次可用日期待核 |
| 物理实现 | `not_applicable` | 裸片、封装和散热留在器件或系统对象 |
| 计算资源 | `not_applicable` | 不复制芯片计算事实 |
| 数值格式 | `not_applicable` | 不复制芯片格式与累加事实 |
| 存储层次 | `partial` | 两条容量声明已记录，冲突尚未正式裁决 |
| 互联 | `partial` | 实例 EFAv3 注入带宽有值；实例内拓扑与带宽未找到 |
| 特殊能力 | `not_applicable` | 架构和软件能力只引用 |
| 软件 | `partial` | 共享软件链可引用，未抽取实例专属版本 |
| 来源证据 | `partial` | S07 已固定并复核；首次可用日期仍缺证据 |

## 12. 复核状态

本卡映射 4 条正式实例事实，分布为 S07 三条、S15 审计声明一条。唯一映射见 `sources/card-fact-map.csv`。本卡与修复 overlay 须由未参与撰写者独立复核后才能合并。