# AWS Inferentia2 架构卡（草稿）

- 对象：`OBJ-AWS-INFERENTIA2-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：本卡单独记录 Inferentia2 对 NCv2 的采用，不把它与 Trainium1 合并成同一个产品对象；具体芯片和 EC2 Inf2 配置下沉。

## 架构事实

Inferentia2 的 NCv2 由 Tensor、Vector、Scalar 和 GpSimd 四类独立 sequencer 执行引擎组成，并通过 Sync Engine 协调（`FACT-M2GA-AIF2-EXEC`）。Tensor Engine 使用 128×128 PE 脉动阵列（`FACT-M2GA-AIF2-TENSOR-SHAPE`）。现有入选来源没有给出可独立落库的输入、输出向量条数。Vector、Scalar 和 GpSimd 的职责分别由 `FACT-M2GA-AIF2-VECTOR`、`...-SCALAR`、`...-GPSIMD` 固定。

BF16/FP16 Tensor 路径采用 FP32 累加语义，产品代际页还明确 cFP8 与 TF32 支持（`FACT-M2GA-AIF2-FP-IN`、`FACT-M2GA-AIF2-FP-ACC`、`FACT-M2GA-AIF2-CFP8`）。cFP8/TF32 的完整乘积、输出和舍入语义仍未找到。

存储层次包括设备 HBM、软件管理的 SBUF 和 PSUM。SBUF 是共享 scratchpad，PSUM 保存 Tensor 累加或结果；异步 DMA 在 HBM 与本地 SBUF 之间搬运数据，并可与计算并行（`FACT-M2GA-AIF2-SBUF`、`...-PSUM`、`...-DMA`）。Inferentia2 产品页另行说明 DMA 路径支持内联压缩和解压缩（`FACT-M2GA-AIF2-COMPRESS`、`...-DECOMPRESS`）。专用 CC-Core 用于集合通信，NeuronLink-v2 是设备直连传输机制；本卡分别记录两项公开事实，不推断其内部编排关系（`FACT-M2GA-AIF2-COLL`、`FACT-M2GA-AIF2-NL`）。NKI 内核由 Neuron Compiler 编译，编译器依据数据依赖插入引擎同步（`FACT-M2GA-AIF2-SW`）。

结构化事实索引：本卡共有 17 条 `FACT-M2GA-AIF2-*` 事实，完整清单见下节及 `structured/facts.csv`。

## 结构化事实明细

本卡对应 17 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-AIF2-CFP8`
- `FACT-M2GA-AIF2-COLL`
- `FACT-M2GA-AIF2-COMPRESS`
- `FACT-M2GA-AIF2-DECOMPRESS`
- `FACT-M2GA-AIF2-DMA`
- `FACT-M2GA-AIF2-EXEC`
- `FACT-M2GA-AIF2-FP-ACC`
- `FACT-M2GA-AIF2-FP-IN`
- `FACT-M2GA-AIF2-GPSIMD`
- `FACT-M2GA-AIF2-NAME`
- `FACT-M2GA-AIF2-NL`
- `FACT-M2GA-AIF2-PSUM`
- `FACT-M2GA-AIF2-SBUF`
- `FACT-M2GA-AIF2-SCALAR`
- `FACT-M2GA-AIF2-SW`
- `FACT-M2GA-AIF2-TENSOR-SHAPE`
- `FACT-M2GA-AIF2-VECTOR`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | Inferentia2/NCv2 身份明确 |
| physical | not_applicable | 工艺、封装、核心和链路数量下沉 |
| compute | partial | 四引擎与阵列明确，频率/吞吐下沉 |
| numerics | partial | BF16/FP16→FP32 与 cFP8/TF32 支持明确，完整语义链仍缺 |
| memory | partial | HBM/SBUF/PSUM 与 DMA 明确，容量/带宽下沉 |
| interconnect | partial | NeuronLink-v2 与 CC-Core 各自的公开用途明确，内部编排、数量、速率和方向下沉 |
| special_engines | partial | DMA 内联压缩/解压和 CC-Core 集合通信明确，MoE 专用模块未找到 |
| software | partial | Neuron Compiler 插入引擎同步这一项行为明确，其他软件映射仍缺 |
| evidence | complete | 产品代际页与 NCv2 指南互补 |

`SEARCH-M2GA-AIF2-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-AIF2-MOE-HW=not_found`。四条 `REQ-M2GA-AWS_INFERENTIA2_ARCH-*` 为 `not_applicable`。820 GiB/s 与 820 GB/s 的实现层单位标签冲突记录为 `M2GA-CF-008`，待 Inferentia2 silicon_package 建立后再形成 formal conflict group。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-A05` | NCv2 engines、SBUF/PSUM、HBM↔SBUF DMA、CC-Core、NeuronLink-v2 与编译器同步 | 必须保留共同微架构机制；版本化入口 |
| `SRC-M2-GA-A04` | Inferentia2 身份、支持格式，以及 DMA 路径内联压缩/解压缩 | 保留代际独有事实；芯片总量转入 backlog |

实现 backlog 为 `DEF-M2GA-AIF2-01` 至 `DEF-M2GA-AIF2-05`，目标是 Inferentia2 silicon_package。EC2 Inf2 的芯片数、主机内存、网络和实例聚合均排除。七目标 XOR 已检查；没有派生存算比。当前自检状态：`draft / ready_for_parent_review`。