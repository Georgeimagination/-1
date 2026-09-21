# Google TPU v3 架构卡（草稿）

- 对象：`OBJ-GOOGLE-TPU-V3-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：本卡描述 TPU v3 的执行与编程模型。每芯片核心数、峰值、存储容量/带宽和互联端口数属于实现对象，不在本卡定值。

## 架构事实

TPU v3 的 TensorCore 由标量/控制、向量和矩阵路径组成，依靠超长指令字（VLIW）和编译器安排执行及数据搬运；矩阵乘单元是 128×128 脉动阵列。对应事实为 `FACT-M2GA-GV3-EXEC` 和 `FACT-M2GA-GV3-ARRAY`。矩阵路径接受 BF16 操作数并采用 FP32 累加语义，但这不等同于公开了物理累加器位宽（`FACT-M2GA-GV3-BF16-IN`、`FACT-M2GA-GV3-BF16-ACC`）。

存储层次包括设备 HBM、TensorCore 的 VMEM，以及 SparseCore 的本地 Sparse Vector Memory。入选来源明确支持把 TensorCore 片上存储记为编译器管理的 scratchpad，并说明 HBM 与片上存储之间的数据由异步、编译器调度的 DMA 搬运（`FACT-M2GA-GV3-MEM-MGMT`、`FACT-M2GA-GV3-DMA`）。Sparse Vector Memory 的存在由 SparseCore 事实覆盖，但本卡不另行断言其管理机制。SparseCore 是分块处理器，用于稀疏和 embedding 访问（`FACT-M2GA-GV3-SPARSE`）。G01 第 5 页另有 SparseCore 曾开始卸载 Top-K 的跨代叙述，但没有给出首次代际，也没有逐代绑定，因此只保留为边界记录，不进入本卡事实。专用 MoE router 仍按独立缺口处理。

芯片外只记录 ICI（Inter-Chip Interconnect，芯片间互联）作为直接加速器传输机制；具体 torus 维度、Pod 节点数、端口数和带宽是部署或芯片实现事实（`FACT-M2GA-GV3-ICI-MECH`）。入选的跨代来源只直接支持 XLA 是 TPU v2 至 Ironwood 软件栈中一贯使用的编译器（`FACT-M2GA-GV3-SW`）；本卡不把 Pallas 或 Mosaic 归到 v3。

结构化事实索引：本卡共有 10 条 `FACT-M2GA-GV3-*` 事实，完整清单见下节及 `structured/facts.csv`。

## 结构化事实明细

本卡对应 10 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-GV3-ARRAY`
- `FACT-M2GA-GV3-BF16-ACC`
- `FACT-M2GA-GV3-BF16-IN`
- `FACT-M2GA-GV3-DMA`
- `FACT-M2GA-GV3-EXEC`
- `FACT-M2GA-GV3-ICI-MECH`
- `FACT-M2GA-GV3-MEM-MGMT`
- `FACT-M2GA-GV3-NAME`
- `FACT-M2GA-GV3-SPARSE`
- `FACT-M2GA-GV3-SW`
## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 身份和对象层级已冻结 |
| physical | not_applicable | 工艺、封装、功耗属于具体实现 |
| compute | partial | 路径和阵列明确；向量/标量实现定量值不在架构层采用 |
| numerics | partial | BF16 输入和 FP32 累加语义明确；物理累加器位宽未找到 |
| memory | partial | HBM、VMEM、Sparse Vector Memory 的存在及 TensorCore scratchpad/DMA 机制明确；Sparse Vector Memory 管理方式与容量、带宽仍缺 |
| interconnect | partial | ICI 机制明确；部署拓扑和带宽下沉 |
| special_engines | partial | SparseCore 明确；未找到专用 MoE router |
| software | partial | XLA 的跨代适用性明确；不据此推断 v3 的 Pallas/Mosaic 支持 |
| evidence | complete | 关键机制均有一手来源定位 |

专用 MoE routing/router 硬件的计划检索为 `SEARCH-M2GA-GV3-MOE-HW`，结果 `no_reliable_result`；对应 `REQ-M2GA-GV3-MOE-HW=not_found`，含义只是本轮一手资料未找到。芯片峰值、容量、内存带宽和互联总带宽分别由 `REQ-M2GA-GOOGLE_TPU_V3_ARCH-COMP-THROUGHPUT`、`...-MEM-CAPACITY`、`...-MEM-READ-BW`、`...-INT-AGGREGATE-BW` 标为 `not_applicable`，原因是对象层级不匹配。

## 最小来源与反向移除

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G02` | TensorCore/MXU/VPU 与 v3 编程模型章节 | 保留，承担 v3 原始执行组织和阵列形态 |
| `SRC-M2-GA-G01` | 表 1、存储/DMA、SparseCore 和软件章节 | 保留，补足跨代统一术语和 SparseCore 机制 |
| `SRC-M2-GA-G05` | MXU 数值行为 | 保留，提供统一的 BF16→FP32 累加语义；动态页需快照 |
| `SRC-M2-GA-G06` | 当前 v3 产品页 | `redundant_covered`；架构事实由 G01/G02 覆盖，产品总量移入实现 backlog |

实现 backlog 为 `DEF-M2GA-GV3-01` 至 `DEF-M2GA-GV3-04`，目标是未来的 TPU v3 `silicon_package`，不是本架构对象。卡内事实均满足七目标 XOR；没有云配置、Pod 或派生存算比。当前自检状态：`draft / ready_for_parent_review`。