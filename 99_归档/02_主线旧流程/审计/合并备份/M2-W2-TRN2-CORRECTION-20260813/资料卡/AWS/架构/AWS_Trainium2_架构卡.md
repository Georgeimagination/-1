# AWS Trainium2 架构资料卡（M1 事实复用说明）

- 对象：`OBJ-AWS-TRAINIUM2-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 合并方式：只引用 M1 已有正式事实，不复制 `facts`、`fact-assertions`、组件、来源或冲突组。
- 正式关系：`OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH`，即 `OBJ-AWS-TRAINIUM2-CHIP implements OBJ-AWS-TRAINIUM2-ARCH`。

## 实现对象事实投影（只用于说明当前实现，不上卷）

Trainium2 的 NCv3 包含 Tensor、Vector、Scalar 和 GpSimd 路径，并有 Descriptor Generation Engine、DMA、SBUF、PSUM、CC-Core 与 NeuronLink。执行和矩阵组织引用 `FACT-AWS-TRN2-TENSOR-EXECUTION-RATES`、`FACT-AWS-TRN2-TENSOR-ARRAY-SHAPE`、`FACT-AWS-TRN2-TENSOR-FP8-TILE`；向量和标量路径引用 `FACT-AWS-TRN2-VECTOR-FP32-CORE`、`FACT-AWS-TRN2-SCALAR-FP32-CORE`。这些事实仍属于现有 Trainium2 芯片/组件对象，架构卡只通过关系解释其实现，不把数值上卷。

矩阵路径的 FP8、BF16、FP16、TF32 和 FP32 操作数、累加与输出语义已经在正式事实链中逐项拆开，例如 `FACT-AWS-TRN2-TENSOR-FP8-{OPERAND-A,OPERAND-B,ACCUM,OUTPUT}` 和 `FACT-AWS-TRN2-TENSOR-BF16-{OPERAND-A,OPERAND-B,ACCUM,OUTPUT}`。结构化稀疏与缩放/舍入见 `FACT-AWS-TRN2-SPARSITY-MODES`、`FACT-AWS-TRN2-TENSOR-FP8-ROUNDING`、`FACT-AWS-TRN2-TENSOR-FP8-SCALING`。物理累加器位宽仍是缺口。

存储和搬运引用 `FACT-AWS-TRN2-HBM-CAPACITY`、`FACT-AWS-TRN2-HBM-BANDWIDTH`、`FACT-AWS-TRN2-SBUF-CAPACITY-CORE`、`FACT-AWS-TRN2-SBUF-MANAGEMENT`、`FACT-AWS-TRN2-PSUM-CAPACITY-CORE` 和 `FACT-AWS-TRN2-MAIN-DMA-BW`。互联机制引用 `FACT-AWS-TRN2-NEURONLINK-IF-COUNT`、`FACT-AWS-TRN2-NEURONLINK-AGG-BW` 与 `FACT-AWS-TRN2-CAP-COLLECTIVE-HW-LEVEL`；方向、有效载荷和每链路速率仍未找到。

特殊能力包括结构化稀疏、内置转置、DMA 转置、向量规约、GpSimd 自定义算子、collective offload 和 DMA 压缩/解压缩。MoE 与 Router Top-K 只找到 NKI 软件/库实现：`FACT-AWS-TRN2-CAP-MOE-NKI-LEVEL`、`FACT-AWS-TRN2-CAP-TOPK-NKI-LEVEL`，不能写成专用硬件。软件映射引用 `FACT-AWS-TRN2-ARCH-SW-MODEL` 和 `FACT-AWS-TRN2-ARCH-SW-RUNTIME`。

上述内容不是 `OBJ-AWS-TRAINIUM2-ARCH` 的自身事实，也不证明以后所有 Trainium2 实现共享相同容量、峰值、核心/链路数或物理参数。完整映射共有 110 行，覆盖 109 个唯一 `fact_id`；同一 fact 的两行表示不同来源断言。详见 `sources/trainium2_existing_reuse_map.csv`，每行都标为 `reference_existing_fact_do_not_copy`。

## 可上卷的机制边界

在不复制正式事实的前提下，本卡只把“NCv3 采用异构 Tensor/Vector/Scalar/GpSimd 路径、软件管理片上存储、显式 DMA、CC-Core/NeuronLink collective offload，以及 AWS Neuron/NKI 编程模型”作为当前实现所显示的机制候选。截至资料截止日，尚未建立以 Trainium2 架构代际为直接主语的新断言，因此本卡没有自动上卷这些机制。芯片峰值、执行单元数量、SBUF/PSUM/HBM 容量和带宽、链路数、频率、封装及所有派生存算比绝不属于这组候选。
## 结构化事实明细

本卡不新增 正式事实；Trainium2 仅引用正式库既有事实，映射见 sources/trainium2_existing_reuse_map.csv。

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | partial | 架构对象自身只有正式 implements 关系；身份通过当前芯片实现投影说明 |
| physical | not_applicable | 工艺、封装、HBM 栈和核心数量属于芯片对象 |
| compute | partial | 仅当前芯片投影显示四类执行路径和阵列；架构对象自身尚无独立 facts |
| numerics | partial | 仅当前芯片投影给出主要格式和累加语义；架构自身事实仍缺 |
| memory | partial | 当前芯片投影含 HBM/SBUF/PSUM/DMA；这些容量/带宽不向架构对象上卷 |
| interconnect | partial | 当前芯片投影含 NeuronLink/CC-Core；链路数与带宽不向架构对象上卷 |
| special_engines | partial | 当前芯片投影含多项能力；MoE/Top-K 只在软件层，架构自身未单列 facts |
| software | partial | 当前实现的软件投影明确；架构对象自身仍需独立版本化断言 |
| evidence | complete | 投影链可回到既有 fact/assertion；这不等于架构九域本身覆盖 |

缺口沿用 M1 正式检索：`SEARCH-AWS-TRN2-001` 至 `SEARCH-AWS-TRN2-014` 均为 `no_reliable_result`，覆盖片上带宽/延迟、物理累加、互联方向/载荷、专用 MoE/Top-K 硬件、物理实现和 RAS 等。不能把软件内核当作硬件缺口的正证据。

## 最小来源与反向移除

| 来源组 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-AWS-TRN2-S01` | Trainium2 Architecture：芯片组件、存储和 collective | 引用现有核心规格与冲突一侧 |
| `SRC-AWS-TRN2-S02`至`S05` | NKI architecture、NCv3、`nki.isa.nc_matmul`、LNC | 引用执行、阵列、格式、存储管理和逻辑共享的不可替代事实 |
| `SRC-AWS-TRN2-S07`、`S08` | 软件模型与 NKI Collectives | 只引用架构软件/collective；实例配置不下放 |
| `SRC-AWS-TRN2-S10`、`S11` | 历史版本与发布日期 | 保留版本/冲突证据；不把历史峰值写成当前架构事实 |
| `SRC-AWS-TRN2-S12`至`S14` | Neuron 2.31、Router Top-K、运行时支持 | 引用软件层 MoE/Top-K 与运行时状态 |

实现 `待办` `DEF-M2GA-ATRN2-01` 只说明现有事实应继续留在 `OBJ-AWS-TRAINIUM2-CHIP`。CC-Core 16/20 沿用 M1 `CF-006`，本卡不复制也不宣告解决。实例、UltraServer 和系统聚合全部排除。七目标 XOR 的检查对象是引用映射，不新增目标列。正式合并状态：`accepted / reference_existing_only`。