# AWS EC2 trn2.3xlarge 实例卡（草稿）

> 卡片状态：`draft`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2-3XLARGE`  
> 正式对象类型：`cloud_instance`  
> 复核人：尚未指定

## 1. 对象和范围

`trn2.3xlarge` 是 EC2 Trn2 家族中的单实例 SKU。正式对象和六条必要关系已经存在；本卡只收录该实例拥有的配置事实，不把 Trainium2 芯片或架构事实复制到实例名下。

| 项目 | 内容 | 正式标识 |
|---|---|---|
| 厂商与名称 | AWS；Amazon EC2 `trn2.3xlarge` | `OBJ-AWS-TRN2-3XLARGE` |
| 配置族 | Amazon EC2 Trn2 instance family | `OREL-AWS-TRN2-3XLARGE-VARIANT-OF-FAMILY` |
| 加速器组成 | 1 个 AWS Trainium2 chip | `OREL-AWS-TRN2-3XLARGE-CONTAINS-TRAINIUM2`；`FACT-AWS-TRN2-3XL-CHIP-QTY` |
| 架构引用链 | 实例 → Trainium2 chip → Trainium2 architecture | `OREL-AWS-TRN2-3XLARGE-CONTAINS-TRAINIUM2`；`OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` |
| 首次可用日期 | `pending_verification`；本轮仍未找到固定日期的一手证据 | `REQ-AWS-TRN2-0194` |

`OBJ-AWS-TRN2-ULTRASERVER-64`、64 芯片系统聚合、跨实例 ring 和系统供货状态不在本卡范围内。

## 2. 物理实现

云实例不公开对应的裸片面积、封装尺寸、晶体管、芯片功耗或散热定值。本卡把这些内容留在 Trainium2 package 或系统对象，不从实例资源反推。

## 3. 计算资源与数值格式

本对象没有独立的一手实例级峰值事实。虽然实例包含 1 个 Trainium2，芯片的矩阵、向量、标量、格式和累加事实也只通过上述关系链引用；本卡不把单芯片事实另建为实例事实。

## 4. 存储层次

| 项目 | 正向采用值 | 冲突审计值 | 当前处理 |
|---|---:|---:|---|
| 加速器内存 | 96 GB；规范化为 96,000,000,000 byte | 512 GiB；规范化为 549,755,813,888 byte | `FACT-AWS-TRN2-3XL-MEM-CAP` 与 `FACT-AWS-TRN2-3XL-MEM-CAP-GENERIC` 并列保留为 `conflict_member`；后者只作 `SRC-AWS-TRN2-S15` 的被拒绝冲突证据 |

96 GB 来自 2026-08-13 固定的 EC2 Trn2 产品页，原始单位按页面保留。512 GiB 来自通用 EC2 表；该来源的筛选状态为 `rejected_unreliable`，不能覆盖产品页值。GB 与 GiB 不互换。

## 5. 计算与存储配比

本卡不计算 FLOP/byte。实例级吞吐没有独立事实，把芯片吞吐除以或乘以实例资源会跨越对象边界。

## 6. 特殊能力

Attention、Top-k、MoE、集合通信和压缩的实现属于 Trainium2 架构、芯片或软件栈。本卡只引用相应对象，不据此声称实例拥有新的专用硬件。

## 7. 互联和系统扩展

| 层级 | 原始值 | 规范化值 | 条件 | 正式事实 |
|---|---:|---:|---|---|
| EFAv3 scale-out 网络 | 0.2 Tbps | 200,000,000,000 bit/s | 实例级；页面未补充有效载荷或方向口径 | `FACT-AWS-TRN2-3XL-EFA-RATE` |

EFAv3 是实例级横向扩展网络，不能和芯片 NeuronLink-v3 或 16 芯片实例内互联混为同一带宽。

## 8. 软件、可靠性和部署

共享软件通过 Trainium2 架构事实引用：`FACT-AWS-TRN2-ARCH-SW-MODEL` 与 `FACT-AWS-TRN2-ARCH-SW-RUNTIME`。这些 fact 的目标仍是 `OBJ-AWS-TRAINIUM2-ARCH`。芯片级 ECC、实例故障域、虚拟化隔离和可用性 SLA 没有本包的一手定值，不建立实例事实。

## 9. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| 首次可用日期 | `pending_verification` | `REQ-AWS-TRN2-0194`；不能由 2026-08-13 当前产品页反推 |
| 内存容量 | `conflicting_unresolved` | `CG-AWS-TRN2-006-3XL-MEM`；采用页值和被拒绝通用表值均保留 |
| 实例内拓扑、实例内内存带宽、实例级峰值 | `not_found` 或未建要求 | 不从 Trainium2 芯片定值补写 |

## 10. 最小参考资料

| 来源 | 角色 | 本卡独有贡献 | 筛选结论 |
|---|---|---|---|
| `SRC-AWS-TRN2-S06` | `core_spec` | 1 个 Trainium2 的直接组成关系 | `selected` |
| `SRC-AWS-TRN2-S07` | `core_spec` | 96 GB 内存、0.2 Tbps EFA；2026-08-13 同日页已固定 | `selected` |
| `SRC-AWS-TRN2-S15` | `conflict_evidence` | 512 GiB 错误候选的审计链 | `rejected_unreliable`，不进入最小入选集 |

## 11. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | SKU、家族和加速器数量已确认；首次可用日期待核 |
| 物理实现 | `not_applicable` | 裸片、封装、功耗和散热留在 package 或系统对象 |
| 计算资源 | `not_applicable` | 本卡不复制芯片计算事实 |
| 数值格式 | `not_applicable` | 本卡不复制芯片格式与累加事实 |
| 存储层次 | `partial` | 96 GB 正向值和 512 GiB 冲突审计值均已记录 |
| 互联 | `partial` | EFA 有值；实例内拓扑与带宽未找到 |
| 特殊能力 | `not_applicable` | 架构和软件能力仅引用 |
| 软件 | `partial` | 软件链可引用，未抽取实例专属版本 |
| 来源证据 | `partial` | 当日动态页已固定；日期缺口未解决 |

## 12. 复核状态

本卡映射 4 条正式实例事实，未新建或复制事实与断言。卡片到正式 fact_id 的唯一映射见 `sources/card-fact-map.csv`。当前仅为初稿，须由未参与撰写者独立复核。
