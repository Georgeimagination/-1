# Google TPU v4 架构卡（草稿）

- 对象：`OBJ-GOOGLE-TPU-V4-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：只写共同微架构。芯片峰值、核心/链路数、存储容量/带宽，以及光交换和 Pod 配置均不挂到本对象。

## 架构事实

TPU v4 延续 VLIW 控制的标量、向量和矩阵路径，数据搬运可与计算异步安排；MXU 是 128×128 脉动阵列（`FACT-M2GA-GV4-EXEC`、`FACT-M2GA-GV4-ARRAY`）。BF16 矩阵输入采用 FP32 累加语义，物理累加器位宽仍未公开（`FACT-M2GA-GV4-BF16-IN`、`FACT-M2GA-GV4-BF16-ACC`）。

程序员可见的存储层次包括设备 HBM、TensorCore VMEM、共享 CMEM 和 SparseCore 的本地 Sparse Vector Memory。入选来源支持把 TensorCore VMEM 记为编译器管理的 scratchpad，并把 CMEM 记为软件 scratchpad；异步 DMA 负责设备内存与片上存储的数据交换（`FACT-M2GA-GV4-MEM-MGMT`、`FACT-M2GA-GV4-CMEM-MGMT`、`FACT-M2GA-GV4-DMA`）。Sparse Vector Memory 的存在由 SparseCore 事实覆盖，本卡不另行断言其管理机制。SparseCore 具有本地存储和可编程向量处理，还公开了排序、过滤、前缀类跨 lane 操作（`FACT-M2GA-GV4-SPARSE`、`FACT-M2GA-GV4-SORT`）。G01 第 5 页另有 SparseCore 曾开始卸载 Top-K 的跨代叙述，但没有给出首次代际，也没有逐代绑定，因此只保留为边界记录，不进入本卡事实。专用 MoE router 仍按独立缺口处理。

ICI 只作为芯片外直接互联机制记录；光交换、三维布线、slice 和 Pod 规模属于系统/云配置（`FACT-M2GA-GV4-ICI-MECH`）。入选的跨代来源只直接支持 XLA 是 TPU v2 至 Ironwood 软件栈中一贯使用的编译器（`FACT-M2GA-GV4-SW`）；本卡不把 Pallas 或 Mosaic 归到 v4。

结构化事实索引：本卡共有 12 条 `FACT-M2GA-GV4-*` 事实，完整清单见下节及 `structured/facts.csv`。

## 结构化事实明细

本卡对应 12 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-GV4-ARRAY`
- `FACT-M2GA-GV4-BF16-ACC`
- `FACT-M2GA-GV4-BF16-IN`
- `FACT-M2GA-GV4-CMEM-MGMT`
- `FACT-M2GA-GV4-DMA`
- `FACT-M2GA-GV4-EXEC`
- `FACT-M2GA-GV4-ICI-MECH`
- `FACT-M2GA-GV4-MEM-MGMT`
- `FACT-M2GA-GV4-NAME`
- `FACT-M2GA-GV4-SORT`
- `FACT-M2GA-GV4-SPARSE`
- `FACT-M2GA-GV4-SW`
## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 代际身份明确 |
| physical | not_applicable | 工艺、封装、频率归实现对象 |
| compute | partial | 执行路径和阵列明确，芯片总量排除 |
| numerics | partial | BF16/FP32 语义明确，物理累加细节缺失 |
| memory | partial | VMEM、CMEM、Sparse Vector Memory 层级明确，VMEM/CMEM 管理和 DMA 有据；Sparse Vector Memory 管理方式与容量、带宽仍缺 |
| interconnect | partial | ICI 机制明确，光交换/Pod 拓扑排除 |
| special_engines | partial | SparseCore 和跨 lane 操作明确，MoE 专用模块未找到 |
| software | partial | XLA 的跨代适用性明确；不据此推断 v4 的 Pallas/Mosaic 支持 |
| evidence | complete | 固定论文覆盖主要机制 |

`SEARCH-M2GA-GV4-MOE-HW` 对专用 MoE routing/router 模块的结果为 `no_reliable_result`，`REQ-M2GA-GV4-MOE-HW=not_found`。四项芯片实现数值要求 `REQ-M2GA-GOOGLE_TPU_V4_ARCH-{COMP-THROUGHPUT,MEM-CAPACITY,MEM-READ-BW,INT-AGGREGATE-BW}` 均为 `not_applicable`，适用性理由是本对象不是具体芯片或云加速器。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G03` | 芯片架构章节和 PDF 第 7 页表 4 | 保留，提供 v4 执行、阵列、CMEM 与 SPMEM 层次 |
| `SRC-M2-GA-G01` | 存储、DMA、SparseCore 和软件章节 | 保留，补足统一机制描述 |
| `SRC-M2-GA-G05` | MXU 数值行为 | 保留 BF16/FP32 语义；动态页需快照 |
| `SRC-M2-GA-G15` | SparseCore architecture | 保留排序、过滤、前缀操作的独有证据 |
| `SRC-M2-GA-G07` | 当前 v4 产品页 | `redundant_covered`；固定论文已经覆盖架构事实 |

实现 backlog 为 `DEF-M2GA-GV4-01` 至 `DEF-M2GA-GV4-05`。光交换与 Pod 内容只在边界日志保留，不进入 backlog 的芯片事实。卡内事实满足七目标 XOR，没有系统聚合和架构差异结论。当前自检状态：`draft / ready_for_parent_review`。