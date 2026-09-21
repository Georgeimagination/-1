# Google TPU 8i 架构资料卡（观察对象）

- 对象：`OBJ-GOOGLE-TPU-8I-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 状态：已宣布，截止日仍为即将提供
- 取证规则：只采用一手明示内容。Boardfly、OCS、Pod 规模和 hop 数是系统/配置事实。

## 架构事实

8i 的一手材料明确给出 FP4 计算路径，但没有公开内部 MXU/VPU/标量组织，也没有说明 FP4 的乘积、累加与输出精度（`FACT-M2GA-G8I-FP4`）。因此本卡只登记 TensorCore 和存储层级的存在，不从发布的芯片总峰值反推阵列结构。

Collectives Acceleration Engine（CAE，集合通信加速引擎）是本代明确披露的专用模块，用于聚合、规约和同步卸载（`FACT-M2GA-G8I-CAE`）。这里不把 CAE 改写成 MoE router，也不把其独立 chiplet 数量挂到架构对象。

8i 暴露 ICI 端点，但所选架构材料没有在同一作用域说明方向、有效载荷口径或芯片边界 topology；因此 structured 只保留接口机制（`FACT-M2GA-G8I-ICI`）。19.2 Tb/s 属具体实现，已转入 `DEF-M2GA-G8I-05`。软件映射包括 JAX、XLA、Pallas/Mosaic、Keras 和公告时 preview 的原生 PyTorch（`FACT-M2GA-G8I-SW`）；状态为 `FACT-M2GA-G8I-STATUS`。

结构化事实索引：`FACT-M2GA-G8I-NAME`、`...-STATUS`、`...-FP4`、`...-CAE`、`...-ICI`、`...-SW`。

## 结构化事实明细

本卡对应 6 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-G8I-CAE`
- `FACT-M2GA-G8I-FP4`
- `FACT-M2GA-G8I-ICI`
- `FACT-M2GA-G8I-NAME`
- `FACT-M2GA-G8I-STATUS`
- `FACT-M2GA-G8I-SW`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 名称和截止日状态明确 |
| physical | not_applicable | on-core die/CAE chiplet 数、封装和工艺下沉 |
| compute | missing_public_data | 没有公开矩阵、向量、标量内部组织 |
| numerics | missing_public_data | FP4 存在，累加和输出语义未找到 |
| memory | partial | HBM/VMEM 层级明确，管理机制未公开 |
| interconnect | partial | ICI 端点存在；方向、payload 与拓扑缺失 |
| special_engines | partial | CAE 功能明确，内部数据通路和吞吐缺失 |
| software | partial | 框架与低层栈明确，状态需版本限定 |
| evidence | complete | 现有事实来自两个同日一手发布材料 |

`SEARCH-M2GA-G8I-ACC` 的结果为 `no_reliable_result`，`REQ-M2GA-G8I-ACC=not_found`。四条 `REQ-M2GA-GOOGLE_TPU_8I_ARCH-*` 对本层级为 `not_applicable`。这表示芯片 total 应进入 silicon_package，不表示官方没有发布这些数字。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G13` | TPU 8i、CAE、软件 enablement | 必须保留，承担微架构独有事实；带日期页面登记快照候选 |
| `SRC-M2-GA-G14` | 状态和 ICI 披露 | 保留状态与接口存在性；19.2 Tb/s 转入实现对象待办 |

实现对象待办 为 `DEF-M2GA-G8I-01` 至 `DEF-M2GA-G8I-05`。Boardfly 的四芯片环、全连接组、光电路交换与 Pod 尺度只在 `M2GA-BD-001` 留边界记录。卡内没有芯片/系统聚合，也没有由峰值反推阵列；七目标 XOR 已检查。正式合并状态：`accepted / future_explicit_only`。