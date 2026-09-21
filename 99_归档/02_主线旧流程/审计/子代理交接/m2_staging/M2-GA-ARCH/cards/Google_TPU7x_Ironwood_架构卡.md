# Google TPU7x（Ironwood）架构卡（草稿）

- 对象：`OBJ-GOOGLE-TPU7X-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：卡内记录 Ironwood 的共同执行路径和 ICI 机制；D2D 协议与集合通信管理、双 chiplet 数量、峰值、存储和互联带宽均归 silicon_package。

## 架构事实

Ironwood 的执行组织仍由 VLIW 控制的标量、向量和矩阵路径构成，并通过异步 DMA 安排数据搬运（`FACT-M2GA-G7X-EXEC`）。矩阵路径分开公开了 256×256 BF16 阵列和 512×512 FP8 阵列；这里记录阵列形态，不记录每芯片阵列数量或总峰值（`FACT-M2GA-G7X-ARRAY`）。BF16 输入采用 FP32 累加语义（`FACT-M2GA-G7X-BF16-IN`、`FACT-M2GA-G7X-BF16-ACC`）；FP8 路径登记为 `PP-M2GA-G7X-FP8`，其完整累加/输出语义仍缺。

公开存储层次包括设备 HBM、TensorCore VMEM 和 SparseCore 的本地 Sparse Vector Memory。入选来源支持把 TensorCore VMEM 记为编译器管理的 scratchpad，并说明 HBM 与片上层之间由异步 DMA 搬运（`FACT-M2GA-G7X-MEM-MGMT`、`FACT-M2GA-G7X-DMA`）。Sparse Vector Memory 的存在由 SparseCore 事实覆盖，本卡不另行断言其管理机制。SparseCore 用于稀疏和 embedding 工作（`FACT-M2GA-G7X-SPARSE`）。G01 第 5 页另有 SparseCore 曾开始卸载 Top-K 的跨代叙述，但没有给出首次代际，也没有逐代绑定，因此只保留为边界记录，不进入本卡事实。专用 MoE router 仍按独立缺口处理。

Ironwood 的封装内 D2D（裸片间互联）数量、相对带宽和 collective 管理机制都属于封装实现，已转入 `DEF-M2GA-G7X-06` 与 `DEF-M2GA-G7X-07`，不再登记为架构事实。ICI 只保留设备间直接传输机制，三维 mesh/torus 部署归云配置（`FACT-M2GA-G7X-ICI-MECH`）。入选的跨代来源只直接支持 XLA 是 TPU v2 至 Ironwood 软件栈中一贯使用的编译器（`FACT-M2GA-G7X-SW`）；本卡不额外登记 Pallas 或 Mosaic。

结构化事实索引：本卡共有 10 条 `FACT-M2GA-G7X-*` 事实，完整清单见下节及 `structured/facts.csv`；其中不含 D2D 架构事实。

## 结构化事实明细

本卡对应 10 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-G7X-ARRAY`
- `FACT-M2GA-G7X-BF16-ACC`
- `FACT-M2GA-G7X-BF16-IN`
- `FACT-M2GA-G7X-DMA`
- `FACT-M2GA-G7X-EXEC`
- `FACT-M2GA-G7X-ICI-MECH`
- `FACT-M2GA-G7X-MEM-MGMT`
- `FACT-M2GA-G7X-NAME`
- `FACT-M2GA-G7X-SPARSE`
- `FACT-M2GA-G7X-SW`
## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | TPU7x/Ironwood 身份明确 |
| physical | not_applicable | 双 chiplet、HBM 栈、工艺与封装均下沉 |
| compute | partial | BF16/FP8 阵列形态明确，总数与总峰值排除 |
| numerics | partial | BF16 累加明确；FP8 完整数值链未找到 |
| memory | partial | HBM、VMEM、Sparse Vector Memory 层级明确，VMEM 管理和 DMA 有据；Sparse Vector Memory 管理方式与容量、带宽仍缺 |
| interconnect | partial | ICI 架构机制明确；D2D 机制、绝对速率和配置拓扑下沉到封装实现 |
| special_engines | partial | SparseCore 明确；MoE 专用模块未找到 |
| software | partial | XLA 的跨代适用性明确；Pallas/Mosaic 不在本卡形成代际事实 |
| evidence | complete | 固定跨代论文与当前 Ironwood 页面互补 |

`SEARCH-M2GA-G7X-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-G7X-MOE-HW=not_found`。四项芯片 total 要求 `REQ-M2GA-GOOGLE_TPU7X_ARCH-*` 为 `not_applicable`。7300/7380 GB/s 视为显示精度或版本限定，不属于架构事实冲突；两者只在实现 backlog 留痕。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G01` | 表 1及执行、DMA、SparseCore 章节 | 保留，承担固定架构事实 |
| `SRC-M2-GA-G05` | MXU 数值行为 | 保留 BF16→FP32 语义；动态页需快照 |
| `SRC-M2-GA-G11` | Ironwood 身份与 ICI architecture；dual-chiplet、D2D 协议及集合通信管理转实现层 | 保留身份和 ICI 事实；动态页需快照 |
| `SRC-M2-GA-G04` | Hot Chips 37 演讲 | 架构事实层 `redundant_covered`；双 die/HBM/I/O 实现信息转 backlog |
| `SRC-M2-GA-G12` | performance guide | `redundant_covered`；每 TensorCore 容量属于实现口径 |

实现 backlog 为 `DEF-M2GA-G7X-01` 至 `DEF-M2GA-G7X-07`。卡内没有 Pod 规模、三维部署 topology fact 或由相对量推算的绝对值；七目标 XOR 已检查。当前自检状态：`draft / ready_for_parent_review`。