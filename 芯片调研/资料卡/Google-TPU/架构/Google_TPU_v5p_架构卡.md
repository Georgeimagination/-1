# Google TPU v5p 架构资料卡

- 对象：`OBJ-GOOGLE-TPU-V5P-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：只记录共同执行、数值、存储管理和互联机制。95/96 GiB 等容量口径属于具体实现，不在架构卡中择值。

## 架构事实

v5p 采用 VLIW 控制的标量、向量和矩阵路径，异步 DMA 可与计算调度重叠；公开的 MXU 阵列形态为 128×128（`FACT-M2GA-GV5P-EXEC`、`FACT-M2GA-GV5P-ARRAY`）。BF16 路径使用 FP32 累加语义（`FACT-M2GA-GV5P-BF16-IN`、`FACT-M2GA-GV5P-BF16-ACC`）。另有 FP8/BF8 路径登记为 `PP-M2GA-GV5P-FP8`，但本轮没有把芯片总峰值写入本对象。

存储层次包括设备 HBM、TensorCore VMEM 和 SparseCore 的本地 Sparse Vector Memory。入选来源支持把 TensorCore VMEM 记为编译器管理的 scratchpad，并说明 DMA 负责与设备内存之间的显式搬运（`FACT-M2GA-GV5P-MEM-MGMT`、`FACT-M2GA-GV5P-DMA`）。Sparse Vector Memory 的存在由 SparseCore 事实覆盖，本卡不另行断言其管理机制。SparseCore 用于稀疏/embedding，并支持排序、过滤、前缀类跨 lane 操作（`FACT-M2GA-GV5P-SPARSE`、`FACT-M2GA-GV5P-SORT`）。G01 第 5 页另有 SparseCore 曾开始卸载 Top-K 的跨代叙述，但没有给出首次代际，也没有逐代绑定，因此只保留为边界记录，不进入本卡事实。专用 MoE router 仍按独立缺口处理。

ICI 作为设备间直接传输机制保留，端口数、聚合带宽和三维 torus 配置下沉（`FACT-M2GA-GV5P-ICI-MECH`）。入选的跨代来源只直接支持 XLA 是 TPU v2 至 Ironwood 软件栈中一贯使用的编译器（`FACT-M2GA-GV5P-SW`）；本卡不把 Pallas 或 Mosaic 归到 v5p。

结构化事实索引：本卡共有 11 条 `FACT-M2GA-GV5P-*` 事实，完整清单见下节及 `数据/facts.csv`。

## 结构化事实明细

本卡对应 11 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-GV5P-ARRAY`
- `FACT-M2GA-GV5P-BF16-ACC`
- `FACT-M2GA-GV5P-BF16-IN`
- `FACT-M2GA-GV5P-DMA`
- `FACT-M2GA-GV5P-EXEC`
- `FACT-M2GA-GV5P-ICI-MECH`
- `FACT-M2GA-GV5P-MEM-MGMT`
- `FACT-M2GA-GV5P-NAME`
- `FACT-M2GA-GV5P-SORT`
- `FACT-M2GA-GV5P-SPARSE`
- `FACT-M2GA-GV5P-SW`
## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 代际身份明确 |
| physical | not_applicable | 封装、工艺和 HBM 物理数量下沉 |
| compute | partial | 执行与阵列明确，总峰值/数量排除 |
| numerics | partial | BF16 累加语义明确；FP8/BF8 的完整乘积/累加/输出链未找到 |
| memory | partial | HBM、VMEM、Sparse Vector Memory 层级明确，VMEM 管理和 DMA 有据；Sparse Vector Memory 管理方式与容量、带宽仍缺 |
| interconnect | partial | ICI 机制明确；配置与带宽下沉 |
| special_engines | partial | SparseCore 与跨 lane 操作明确，MoE 专用模块未找到 |
| software | partial | XLA 的跨代适用性明确；不据此推断 v5p 的 Pallas/Mosaic 支持 |
| evidence | complete | 固定论文与 OpenXLA 架构页相互补充 |

`SEARCH-M2GA-GV5P-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-GV5P-MOE-HW=not_found`。四条 `REQ-M2GA-GOOGLE_TPU_V5P_ARCH-*` 实现数值要求为 `not_applicable`。95 GiB 与 96 GiB 没有建架构冲突：它们保存在 `DEF-M2GA-GV5P-03`，等待 silicon_package 与 cloud_accelerator 分层后再解释作用域。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G01` | 表 1、执行、存储、DMA 与 SparseCore 章节 | 保留，承担大部分架构事实 |
| `SRC-M2-GA-G05` | MXU 数值行为 | 保留 BF16→FP32 语义；动态页需快照 |
| `SRC-M2-GA-G15` | SparseCore architecture | 保留排序/过滤/前缀操作的独有证据 |
| `SRC-M2-GA-G09` | 当前 v5p 产品页 | 架构层 `redundant_covered`；95 GiB 与 ICI 数值转入 deferred |

实现对象待办 为 `DEF-M2GA-GV5P-01` 至 `DEF-M2GA-GV5P-06`。卡内事实通过七目标 XOR 检查，未生成存算比，因为算力、容量和带宽不属于本对象。正式合并状态：`accepted / reviewed`。