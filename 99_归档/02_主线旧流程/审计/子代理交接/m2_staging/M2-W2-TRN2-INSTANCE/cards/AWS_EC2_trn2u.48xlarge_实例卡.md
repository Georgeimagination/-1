# AWS EC2 trn2u.48xlarge 实例卡（草稿）

> 卡片状态：`draft`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2U-48XLARGE`  
> 正式对象类型：`cloud_instance`  
> 正式对象复核状态：`needs_resolution`  
> 复核人：尚未指定

## 1. 对象和范围

`trn2u.48xlarge` 是 Trn2 UltraServer 的 16 芯片组成实例 SKU，与普通 `trn2.48xlarge` 分开建模。它的实例身份、家族归属和 Trainium2 数量已有正式记录；首次固定可用日期与当前供货状态仍待核，因此对象状态保持 `needs_resolution`。

| 项目 | 内容 | 正式标识 |
|---|---|---|
| 厂商与名称 | AWS；Amazon EC2 `trn2u.48xlarge` | `OBJ-AWS-TRN2U-48XLARGE` |
| 配置族 | Amazon EC2 Trn2 instance family | `OREL-AWS-TRN2U-48XLARGE-VARIANT-OF-FAMILY` |
| 加速器组成 | 16 个 AWS Trainium2 chip | `OREL-AWS-TRN2U-48XLARGE-CONTAINS-TRAINIUM2`；`FACT-AWS-TRN2U-48XL-CHIP-QTY` |
| 架构引用链 | 实例 → Trainium2 chip → Trainium2 architecture | `OREL-AWS-TRN2U-48XLARGE-CONTAINS-TRAINIUM2`；`OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` |
| 首次可用日期 | `pending_verification` | `REQ-AWS-TRN2-0195` |

`OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER` 仍为 `needs_resolution`。其数量事实 `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 表示一个 UltraServer 包含 4 个此类实例，属于系统组成，已从本卡的 21 条实例事实中显式排除。

## 2. 物理实现

实例的裸片、封装、晶体管、芯片功耗和散热不在本卡事实范围。即使该 SKU 参与 UltraServer，也不能用整套系统信息反推单实例或单芯片物理规格。

## 3. 计算资源

### 3.1 实例级厂商直报峰值

| 格式 | 稠密峰值 | 当前结构化稀疏值 | 2024 发布博客历史值 | 正式事实 |
|---|---:|---:|---:|---|
| FP8 | 20.8 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-TRN2U-48XL-FP8-DENSE`；`FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE`；`FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE-HIST2024` |
| BF16 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-TRN2U-48XL-BF16-DENSE`；`FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE`；`FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE-HIST2024` |
| FP16 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-TRN2U-48XL-FP16-DENSE`；`FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE`；`FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE-HIST2024` |
| TF32 | 10.7 PFLOPS | 41 PFLOPS | 83.2 PFLOPS | `FACT-AWS-TRN2-TRN2U-48XL-TF32-DENSE`；`FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE`；`FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE-HIST2024` |
| FP32 | 2.9 PFLOPS | 未列 | 未列 | `FACT-AWS-TRN2-TRN2U-48XL-FP32-DENSE` |

这些值来自实例级直接表述，不由 16 倍芯片值生成。当前表的 41 PFLOPS 与 2024 博客的 83.2 PFLOPS 没有统一条件说明，八条稀疏事实继续作为冲突成员。

## 4. 数值格式和累加

实例事实只保留 FP8、BF16、FP16、TF32 和 FP32 的峰值标签。操作数、乘积、累加、缩放和舍入属于架构或芯片路径；本卡引用正式关系，不复制这些实现事实。

## 5. 存储层次

| 项目 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 加速器内存 | 1,536 GiB | 1,649,267,441,664 byte | 16 芯片实例聚合直报值 | `FACT-AWS-TRN2-TRN2U-48XL-MEM-CAP` |
| 实例内存带宽 | 46.4 TB/s | 46,400,000,000,000 byte/s | 实例聚合；方向细节未完整披露 | `FACT-AWS-TRN2-TRN2U-48XL-MEM-BW` |

通用 EC2 表没有为该 SKU 建立受信内存事实。本卡不从 `trn2.48xlarge` 的通用表冲突值类推，也不把上述聚合值除以 16 后写回 Trainium2 package。

## 6. 计算与存储配比

本包不新增派生指标。稀疏峰值存在版本冲突，内存带宽的方向和持续性条件也未闭合，暂不生成 FLOP/byte。

## 7. 大模型相关特殊能力

MoE、Router Top-K、Attention、集合通信、转置和压缩由 Trainium2 架构、芯片及 Neuron 软件事实承接。本卡不把软件支持写成实例内专用硬件。

## 8. 互联和系统扩展

| 层级 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 实例内 NeuronLink-v3 | 1,024 GB/s/chip | 1,024,000,000,000 byte/s | 实例内；原表未完整说明方向或有效载荷 | `FACT-AWS-TRN2-TRN2U-48XL-INTRA-BW` |
| 拓扑 | 4×4 two-dimensional torus；16 节点 | `torus`；4×4；16 count | 本实例内部 | `FACT-AWS-TRN2-TRN2U-48XL-TOPO-TYPE`；`FACT-AWS-TRN2-TRN2U-48XL-TOPO-DIMS`；`FACT-AWS-TRN2-TRN2U-48XL-TOPO-NODES` |
| EFAv3 scale-out | 3.2 Tbps | 3,200,000,000,000 bit/s | 实例级；2026-08-13 产品页值 | `FACT-AWS-TRN2-TRN2U-48XL-EFA-RATE` |

UltraServer 的跨实例 ring、64 芯片聚合、12.8 Tbps 或其他系统 EFA 口径不进入本卡。

## 9. 软件、可靠性和实测补充

共享软件通过 `FACT-AWS-TRN2-ARCH-SW-MODEL` 与 `FACT-AWS-TRN2-ARCH-SW-RUNTIME` 引用，目标保持 `OBJ-AWS-TRAINIUM2-ARCH`。实例专属 ECC、故障域、虚拟化隔离、SLA 与第三方微基准没有本包正式事实。

## 10. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| 首次可用日期与当前供货状态 | `pending_verification` | `REQ-AWS-TRN2-0195`；动态产品页的当前可见性不能替代固定首发日期或状态公告 |
| 当前与历史稀疏峰值 | `conflicting_unresolved` | 四个 `CG-AWS-TRN2-003-TRN2U-48XL-*` 组；41 与 83.2 PFLOPS 并列 |
| UltraServer 部署关系 | `needs_resolution`，包外 | `OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER` 及数量事实留给系统包 |
| 带宽方向、有效载荷、延迟和对分带宽 | `not_found` 或未建要求 | 不根据 torus 或系统聚合值推算 |

## 11. 最小参考资料

| 来源 | 角色 | 独有贡献 | 筛选结论 |
|---|---|---|---|
| `SRC-AWS-TRN2-S06` | `core_spec` | 16 芯片、实例峰值、1,536 GiB、46.4 TB/s、实例内互联和拓扑 | `selected` |
| `SRC-AWS-TRN2-S07` | `core_spec` | 3.2 Tbps EFA 与当前 SKU 入口；2026-08-13 同日页已固定 | `selected` |
| `SRC-AWS-TRN2-S10` | `conflict_evidence` | 2024 年 83.2 PFLOPS 稀疏历史值 | `selected` |

`SRC-AWS-TRN2-S09` 只支持 UltraServer 在 2024-12-03 的预览状态，不支持本 SKU 的固定首次可用日期，因此不进入这张实例卡的最小来源。

## 12. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | SKU、家族与 16 芯片组成已确认；首次可用日期和当前状态待核 |
| 物理实现 | `not_applicable` | package 与系统物理事实不上卷或下放 |
| 计算资源 | `partial` | 稠密值完整；稀疏当前与历史口径未决 |
| 数值格式 | `partial` | 格式标签可确认；内部精度语义只引用架构事实 |
| 存储层次 | `partial` | 实例容量与带宽有直接值；方向和持续性条件不完整 |
| 互联 | `partial` | torus、节点数、实例内带宽和 EFA 有值；系统 ring 明确排除 |
| 特殊能力 | `not_applicable` | 本卡不复制架构或软件能力 |
| 软件 | `partial` | 软件链可引用，未抽取实例专属版本 |
| 来源证据 | `partial` | 当日产品页已固定；固定首次可用日期证据仍缺失 |

## 13. 复核状态

本卡映射 21 条正式实例事实。系统层 `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 已在 `sources/scope-exclusions.csv` 单独排除；卡片没有复制正式事实、断言、关系或字段要求。当前仅为初稿，须由未参与撰写者独立复核。
