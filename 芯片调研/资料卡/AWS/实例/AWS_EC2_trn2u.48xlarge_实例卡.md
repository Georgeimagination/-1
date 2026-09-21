# AWS EC2 trn2u.48xlarge 实例卡

> 卡片状态：`已验收`  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-AWS-TRN2U-48XLARGE`  
> 正式对象类型：`cloud_instance`  
> 正式对象复核状态：`needs_resolution`  
> 复核人：`m2_review_trn2_correction`

## 1. 对象和范围

`trn2u.48xlarge` 是 Trn2 UltraServer 的 16 芯片组成实例规格，与普通 `trn2.48xlarge` 分开建模。它通过 `OREL-AWS-TRN2U-48XLARGE-VARIANT-OF-FAMILY` 归入 Trn2 配置族，通过 `OREL-AWS-TRN2U-48XLARGE-CONTAINS-TRAINIUM2` 连接 Trainium2；架构引用继续经过 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH`。

`FACT-AWS-TRN2U-48XL-CHIP-QTY` 记录 16 颗 Trainium2。首次可用日期仍为 `pending_verification`，由 `REQ-AWS-TRN2-0195` 跟踪。

`OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER` 仍为 `needs_resolution`。`FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 表示一个 UltraServer 包含 4 个此类实例，属于系统组成，不计入本卡 17 条实例事实。

## 2. 物理实现

实例的裸片、封装、晶体管、芯片功耗和散热不在本卡事实范围。UltraServer 系统信息不能反推单实例或单芯片的物理规格。

## 3. 计算资源

| 格式 | 稠密峰值 | 当前结构化稀疏峰值 | 历史值 | 当前处理 |
|---|---:|---:|---:|---|
| FP8 | 20.8 PFLOPS | 41 PFLOPS | 无直接支持 | S06 当前值为 `single_source / provisional / reviewed` |
| BF16 | 10.7 PFLOPS | 41 PFLOPS | 无直接支持 | 同上 |
| FP16 | 10.7 PFLOPS | 41 PFLOPS | 无直接支持 | 同上 |
| TF32 | 10.7 PFLOPS | 41 PFLOPS | 无直接支持 | 同上 |
| FP32 | 2.9 PFLOPS | 未列 | 未列 | S06 当前直接值 |

S10 的 2024 文本只写 “Each Trn2 instance” 与 FP8，没有直接命名后来单独建模的 `trn2u.48xlarge`。因此本对象原有四条 S10 历史事实、断言、要求、条件及冲突组全部删除。当前峰值来自 S06 的 `trn2u.48xlarge` 实例列，不由单芯片数值乘 16 生成。

## 4. 数值格式和累加

实例事实只记录 FP8、BF16、FP16、TF32 和 FP32 的峰值标签。操作数、内部乘积、累加、缩放和舍入属于架构或芯片路径，本卡不复制。

## 5. 存储层次

| 项目 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 加速器内存 | 1,536 GiB | 1,649,267,441,664 byte | 16 芯片实例聚合直报值 | `FACT-AWS-TRN2-TRN2U-48XL-MEM-CAP` |
| 实例内存带宽 | 46.4 TB/s | 46,400,000,000,000 byte/s | 实例聚合；方向未完整披露 | `FACT-AWS-TRN2-TRN2U-48XL-MEM-BW` |

通用 EC2 表没有为该规格建立受信内存事实。本卡不从 `trn2.48xlarge` 的 S15 声明类推，也不把实例聚合值除以 16 回写到 Trainium2 器件。

## 6. 计算与存储配比

本包不新增 FLOP/byte。虽然当前峰值不再有 S10 伪冲突，内存带宽的方向、持续性以及工作负载条件仍不完整。

## 7. 大模型相关特殊能力

Mixture of Experts（MoE，混合专家）、Router Top-K、Attention、集合通信、转置和压缩由 Trainium2 架构、芯片及 Neuron 软件事实承接。本卡不把软件支持写成实例内专用硬件。

## 8. 互联和系统扩展

| 层级 | 原始值 | 规范化值 | 条件与边界 | 正式事实 |
|---|---:|---:|---|---|
| 实例内 NeuronLink-v3 | 1,024 GB/s/chip | 1,024,000,000,000 byte/s | 实例内；方向和有效载荷未完整说明 | `FACT-AWS-TRN2-TRN2U-48XL-INTRA-BW` |
| 拓扑 | 4×4 two-dimensional torus；16 节点 | `torus`；4×4；16 count | 本实例内部 | `FACT-AWS-TRN2-TRN2U-48XL-TOPO-TYPE`、`-DIMS`、`-NODES` |
| EFAv3 scale-out | 3.2 Tbps | 400,000,000,000 byte/s | `FIELD-INT-INJECTION-BW`；按实例；不假设物理链路数 | `FACT-AWS-TRN2-TRN2U-48XL-EFA-RATE` |

S07 Product details 表按实例给出 `Network bandwidth (Tbps)`。3.2 Tbps 的原始值保留在断言，规范字段按 byte/s 存储。UltraServer 的跨实例 ring、64 芯片聚合和 12.8 Tbps 系统 EFAv3 不进入本卡。

## 9. 软件、可靠性和实测补充

共享软件通过 `FACT-AWS-TRN2-ARCH-SW-MODEL` 与 `FACT-AWS-TRN2-ARCH-SW-RUNTIME` 引用。实例专属的纠错码、故障域、虚拟化隔离、服务等级和第三方微基准没有本包正式事实。

## 10. 缺失、冲突和待核

| 项目 | 状态 | 说明 |
|---|---|---|
| 首次可用日期与当前供货状态 | `pending_verification` | 当前页可见性不能替代固定首发日期或状态公告 |
| 当前结构化稀疏峰值 | `value_available` | S06 直接命名该实例；不存在受支持的 S10 历史事实 |
| UltraServer 部署关系 | `needs_resolution`，包外 | 关系与数量留给系统卡 |
| 带宽方向、有效载荷、延迟和对分带宽 | `not_found` 或未建要求 | 不根据 torus 或系统聚合值推算 |

## 11. 最小参考资料

本卡的 17 条映射只需要两个来源：S06 支持 16 条实例配置、峰值、内存、拓扑和实例内互联；S07 支持 3.2 Tbps 实例 EFAv3。S10 不直接命名本规格，修复后不再进入本卡最小来源。

## 12. 九域完整度

| 领域 | 状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | SKU、家族和 16 芯片已确认；首次可用日期与当前状态待核 |
| 物理实现 | `not_applicable` | 器件与系统物理事实不上卷或下放 |
| 计算资源 | `partial` | 当前实例峰值有值；持续工作负载性能未找到 |
| 数值格式 | `partial` | 峰值格式标签明确；内部精度语义只引用架构事实 |
| 存储层次 | `partial` | 实例容量与带宽有直接值；方向和持续性条件不完整 |
| 互联 | `partial` | torus、实例内带宽和 EFAv3 注入带宽有值；系统 ring 明确排除 |
| 特殊能力 | `not_applicable` | 不复制架构或软件能力 |
| 软件 | `partial` | 共享软件链可引用，未抽取实例专属版本 |
| 来源证据 | `partial` | 17 条映射闭合到 S06/S07；固定首次可用日期仍缺失 |

## 13. 复核状态

本卡映射 17 条正式实例事实。系统层 `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 明确排除。唯一映射见 `sources/card-fact-map.csv`。本卡与修复 overlay 须由未参与撰写者独立复核后才能合并。