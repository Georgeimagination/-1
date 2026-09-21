# Google TPU v6e（Trillium）架构资料卡

- 对象：`OBJ-GOOGLE-TPU-V6E-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：动态产品页中的核心数、峰值、容量和带宽只进实现对象待办；本卡保留 v6e 的程序员可见机制。

## 架构事实

v6e 的 TensorCore 包含矩阵、向量和标量/控制路径，MXU 的公开阵列形态为 256×256（`FACT-M2GA-GV6E-EXEC`、`FACT-M2GA-GV6E-ARRAY`）。BF16 矩阵输入采用 FP32 累加语义（`FACT-M2GA-GV6E-BF16-IN`、`FACT-M2GA-GV6E-BF16-ACC`）；INT8 路径已经登记为 `PP-M2GA-GV6E-INT8`，但所选机制来源没有给出完整的乘积、累加和输出精度链。

v6e 产品页列出 HBM，SparseCore 来源也说明本地存储、分块向量处理和动态执行；但当前入选来源没有直接建立本代 VMEM/Sparse Vector Memory 的管理方式或 DMA 机制，因此这些内容保留为缺口。SparseCore 的排序、过滤和前缀类跨 lane 操作仍有直接证据（`FACT-M2GA-GV6E-SPARSE`、`FACT-M2GA-GV6E-SORT`）。

ICI 作为设备间直接传输机制记录；端口、带宽和二维 torus 部署归具体 cloud_accelerator 或配置（`FACT-M2GA-GV6E-ICI-MECH`）。当前入选来源没有形成可归属于 v6e 的软件栈事实。

结构化事实索引：本卡共有 8 条 `FACT-M2GA-GV6E-*` 事实，完整清单见下节及 `数据/facts.csv`。

## 结构化事实明细

本卡对应 8 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-GV6E-ARRAY`
- `FACT-M2GA-GV6E-BF16-ACC`
- `FACT-M2GA-GV6E-BF16-IN`
- `FACT-M2GA-GV6E-EXEC`
- `FACT-M2GA-GV6E-ICI-MECH`
- `FACT-M2GA-GV6E-NAME`
- `FACT-M2GA-GV6E-SORT`
- `FACT-M2GA-GV6E-SPARSE`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | Trillium/v6e 身份明确 |
| physical | not_applicable | 工艺、封装、功耗下沉 |
| compute | partial | 执行路径与 256×256 阵列明确，芯片总量排除 |
| numerics | partial | BF16→FP32 明确；INT8 完整语义未找到 |
| memory | partial | HBM 与 SparseCore 本地存储的存在有据；本代片上存储管理方式、DMA、容量和带宽仍缺 |
| interconnect | partial | ICI 机制明确，端口/带宽/部署拓扑下沉 |
| special_engines | partial | SparseCore 跨 lane 能力明确，MoE 专用模块未找到 |
| software | missing_public_data | 当前入选来源没有形成可归属于 v6e 的软件栈事实 |
| evidence | complete | 通用 TPU 页、v6e 页和 OpenXLA 页相互补充，均需按截止日保存快照 |

`SEARCH-M2GA-GV6E-MOE-HW` 的结果为 `no_reliable_result`；`REQ-M2GA-GV6E-MOE-HW=not_found`。四项以芯片 total 为目标的 `REQ-M2GA-GOOGLE_TPU_V6E_ARCH-*` 为 `not_applicable`，表示目标层级不适用，不表示该代硬件没有峰值、容量或带宽。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G05` | TPU architecture 的执行路径、阵列与 BF16→FP32 数值行为 | 保留现有执行和数值事实；动态入口仍需快照，不把其他代际的存储或软件描述归到 v6e |
| `SRC-M2-GA-G10` | v6e 身份与 ICI architecture | 保留；芯片总量转入 待办，网页仍需快照 |
| `SRC-M2-GA-G15` | SparseCore 的本地存储、动态执行、向量处理及跨 lane 操作 | 保留特殊能力独有证据；网页需快照，不据此断言存储管理方式 |

实现对象待办 为 `DEF-M2GA-GV6E-01` 至 `DEF-M2GA-GV6E-04`，目标是 v6e cloud_accelerator。卡内事实满足七目标 XOR，未使用系统聚合或媒体材料。正式合并状态：`accepted / explicit_gaps`。