# AWS Inferentia 第一代架构卡（草稿）

- 对象：`OBJ-AWS-INFERENTIA1-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：本卡描述 NeuronCore-v1（NCv1）的执行与数值路径；芯片核心数、总峰值、DRAM 容量/带宽和 EC2 实例配置下沉。

## 架构事实

NCv1 是独立的异构计算核，包含 Tensor、Vector 和 Scalar 三条执行路径，并配有软件管理的片上 SRAM（`FACT-M2GA-AIF1-EXEC`）。Tensor Engine 使用面向能效的脉动阵列；所选来源没有公开物理阵列尺寸（`FACT-M2GA-AIF1-TENSOR`）。Vector Engine 处理激活和一般向量运算，Scalar Engine 处理标量与控制型计算（`FACT-M2GA-AIF1-VECTOR`、`FACT-M2GA-AIF1-SCALAR`）。

浮点 Tensor 路径接受 FP16 或 BF16，并输出 FP32 结果；整数路径接受 INT8 并输出 INT32（`FACT-M2GA-AIF1-FP-IN`、`FACT-M2GA-AIF1-FP-OUT`、`FACT-M2GA-AIF1-I8-IN`、`FACT-M2GA-AIF1-I8-OUT`）。原文没有单独给出物理累加器位宽，因此这里只记录结果/累加语义，不补物理实现。

存储层次包括设备 DRAM 和 NCv1 片上 SRAM；SRAM 是显式调度的 scratchpad，不是硬件缓存（`FACT-M2GA-AIF1-MEM`）。所选 A01/A02 页面没有直接说明 NCv1 的编译器或运行时映射，因此不建立软件事实。本轮也没有找到可归到 Inferentia1 架构代际的 NeuronLink 机制或专用 MoE/Top-K 模块。

结构化事实索引：`FACT-M2GA-AIF1-NAME`、`...-EXEC`、`...-TENSOR`、`...-VECTOR`、`...-SCALAR`、`...-FP-IN`、`...-FP-OUT`、`...-I8-IN`、`...-I8-OUT`、`...-MEM`。

## 结构化事实明细

本卡对应 10 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-AIF1-EXEC`
- `FACT-M2GA-AIF1-FP-IN`
- `FACT-M2GA-AIF1-FP-OUT`
- `FACT-M2GA-AIF1-I8-IN`
- `FACT-M2GA-AIF1-I8-OUT`
- `FACT-M2GA-AIF1-MEM`
- `FACT-M2GA-AIF1-NAME`
- `FACT-M2GA-AIF1-SCALAR`
- `FACT-M2GA-AIF1-TENSOR`
- `FACT-M2GA-AIF1-VECTOR`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | Inferentia/NCv1 身份明确 |
| physical | not_applicable | 工艺、封装、核心数与 DRAM 实现下沉 |
| compute | partial | 三引擎职责明确，阵列尺寸和定量吞吐不在架构事实中 |
| numerics | partial | 输入/输出格式明确，物理累加器和舍入细节未找到 |
| memory | partial | DRAM/SRAM 层级和管理明确，片上带宽/延迟缺失 |
| interconnect | missing_public_data | 所选一手架构资料没有给芯片间互联机制 |
| special_engines | missing_public_data | 未找到专用 MoE routing/router Top-K 硬件 |
| software | missing_public_data | 所选一手架构页没有直接说明编译器或运行时映射 |
| evidence | complete | NCv1 版本化文档覆盖核心机制 |

`SEARCH-M2GA-AIF1-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-AIF1-MOE-HW=not_found`。四条 `REQ-M2GA-AWS_INFERENTIA1_ARCH-*` 为 `not_applicable`，因为它们请求芯片 total，而本对象是架构代际。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-A02` | NCv1 overview、TensorEngine、VectorEngine、ScalarEngine | 必须保留，承担执行、格式和 SRAM 管理；版本化入口 |
| `SRC-M2-GA-A01` | Inferentia architecture 产品身份 | 保留产品身份；实例芯片数与芯片总量只进入 backlog |

实现 backlog 为 `DEF-M2GA-AIF1-01` 至 `DEF-M2GA-AIF1-03`；NCv1 各引擎每周期操作率也应在目标 silicon_package/component 建立后再录入。EC2 Inf1 实例数量和主机网络不进入本卡。七目标 XOR 已检查。当前自检状态：`draft / explicit_gaps`。