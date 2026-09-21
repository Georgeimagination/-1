# Google TPU v5e 架构资料卡

- 对象：`OBJ-GOOGLE-TPU-V5E-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：v5e 的公开材料以 Google Cloud 动态文档为主。本卡只固定架构机制，产品页中的芯片总量放入实现对象待办。

## 架构事实

v5e 的 TensorCore 包含 MXU、VPU 和标量/控制路径；MXU 的公开架构口径是 128×128 脉动阵列（`FACT-M2GA-GV5E-EXEC`、`FACT-M2GA-GV5E-ARRAY`）。BF16 矩阵输入采用 FP32 累加语义（`FACT-M2GA-GV5E-BF16-IN`、`FACT-M2GA-GV5E-BF16-ACC`）。产品页还列出 INT8 支持，但本卡没有把芯片总 TOPS 写入架构对象。

v5e 产品页列出 HBM，但当前入选来源没有直接建立本代 VMEM 的管理方式或 DMA 机制，因此本卡不沿用其他代际的通用描述。SparseCore、专用 Top-K 和 MoE routing 物理模块也保留为证据缺口。

ICI 作为设备间直接传输机制记录；端口数、带宽和二维 torus 部署是具体云加速器或配置事实（`FACT-M2GA-GV5E-ICI-MECH`）。当前入选来源没有形成可归属于 v5e 的软件栈事实。

结构化事实索引：本卡共有 6 条 `FACT-M2GA-GV5E-*` 事实，完整清单见下节及 `数据/facts.csv`。

## 结构化事实明细

本卡对应 6 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-GV5E-ARRAY`
- `FACT-M2GA-GV5E-BF16-ACC`
- `FACT-M2GA-GV5E-BF16-IN`
- `FACT-M2GA-GV5E-EXEC`
- `FACT-M2GA-GV5E-ICI-MECH`
- `FACT-M2GA-GV5E-NAME`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | v5e 代际身份明确 |
| physical | not_applicable | 工艺、封装和功耗下沉 |
| compute | partial | 路径和阵列明确；实现数量与峰值下沉 |
| numerics | partial | BF16→FP32 语义明确；INT8 的乘积、累加和输出精度未在所选机制源中完整给出 |
| memory | missing_public_data | 产品页列出 HBM；本代 VMEM 管理方式和 DMA 机制未由入选来源直接建立 |
| interconnect | partial | ICI 机制明确；带宽/拓扑归实现与配置 |
| special_engines | missing_public_data | 没有找到 v5e 专用 SparseCore、MoE router 或硬件 Top-K 证据 |
| software | missing_public_data | 当前入选来源没有形成可归属于 v5e 的软件栈事实 |
| evidence | complete | 两个官方页面覆盖现有机制，但均需快照 |

专用 MoE/Top-K 检索为 `SEARCH-M2GA-GV5E-MOE-HW`，结果 `no_reliable_result`；`REQ-M2GA-GV5E-MOE-HW=not_found`。芯片峰值、容量、内存带宽和 ICI 聚合带宽的四条 `REQ-M2GA-GOOGLE_TPU_V5E_ARCH-*` 均为 `not_applicable`，原因是这些是 cloud_accelerator 实现值。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G05` | TPU architecture 的 MXU/VPU/标量路径、阵列与 BF16→FP32 数值行为 | 保留现有执行和数值事实；动态页需快照，不把其他代际的存储或软件描述归到 v5e |
| `SRC-M2-GA-G08` | v5e 页标题和 interconnect architecture | 保留，限定对象身份并确认 ICI 入口；芯片总量转入 待办 |

目前没有能替代 G08 的固定 v5e 架构论文。实现对象待办 为 `DEF-M2GA-GV5E-01` 至 `DEF-M2GA-GV5E-04`，建议目标是 TPU v5e `cloud_accelerator`。卡内事实满足七目标 XOR，未使用 Pod 聚合值或媒体来源。正式合并状态：`accepted / explicit_gaps`。