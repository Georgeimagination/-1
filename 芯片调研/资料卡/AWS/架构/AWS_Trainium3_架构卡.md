# AWS Trainium3 架构资料卡

- 对象：`OBJ-AWS-TRAINIUM3-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：卡内只写 NCv4 的程序员可见机制。八核、芯片峰值、频率、SBUF/PSUM/HBM 容量、带宽、CC-Core/NeuronLink 数量和 3 nm 均进入 silicon_package 待办。

## 架构事实

NCv4 保留 Tensor、Vector、Scalar 和 GpSimd 四类独立 sequencer 执行引擎，并通过 Sync Engine 协调（`FACT-M2GA-ATRN3-EXEC`）。Tensor Engine 的物理阵列为 128×128 PE；MX 模式向软件暴露有效 512×128 的 contraction 接口。MX 输入通路比普通 dense 与 structured-sparse 通路更宽，结果通路是一条 128 元素向量（`FACT-M2GA-ATRN3-TENSOR-SHAPE`、`FACT-M2GA-ATRN3-TENSOR-IO`）。Vector 与 Scalar 路径宽度依赖格式，BF16/FP16/FP8 使用较宽模式（`FACT-M2GA-ATRN3-VECTOR`、`FACT-M2GA-ATRN3-SCALAR`）。

MX 路径接受 MXFP8 或 MXFP4，并允许 MXFP8×MXFP4；MXFP4 在 Tensor Engine 计算前转换为 MXFP8。内部采用 FP32 累加，结果可写为 FP32 或 BF16（`FACT-M2GA-ATRN3-MX-IN`、`...-MX-PRODUCT`、`...-MX-ACC`、`...-MX-OUT`）。BF16/FP16/TF32 路径同样以 FP32 内部累加，可在写 PSUM 前立即降为 BF16；舍入模式分别记录为 round-to-nearest-even 和 stochastic rounding（`FACT-M2GA-ATRN3-BF16-ACC`、`FACT-M2GA-ATRN3-BF16-ROUND`、`FACT-M2GA-ATRN3-BF16-ROUND-STOCHASTIC`）。结构稀疏公开了 4:16、4:12、4:8、2:8、2:4、1:4 和 1:2 模式（`FACT-M2GA-ATRN3-SPARSE`）。

设备 HBM、软件管理 SBUF 与 PSUM 构成主要层次；异步 DMA 支持流量整形和显式搬运（`FACT-M2GA-ATRN3-SBUF`、`...-PSUM`、`...-DMA`）。专用 CC-Core 用于集合通信，NeuronLink-v4 是设备直连传输机制；本卡分别记录两项公开事实，不推断其内部编排关系（`FACT-M2GA-ATRN3-COLL`、`FACT-M2GA-ATRN3-NL`）。另外公开了 SBUF read-add-write 的近存累加、可与矩阵乘重叠的后台转置，以及四类引擎的间接 gather/scatter（`FACT-M2GA-ATRN3-NEARMEM`、`...-BGTRANSPOSE`、`...-INDIRECT`）。NKI 向程序员公开 NCv4 的 MX 数据类型和 `nc_matmul_mx` 接口（`FACT-M2GA-ATRN3-SW`），代际 GA 状态为 `FACT-M2GA-ATRN3-STATUS`。

结构化事实索引：本卡共有 24 条 `FACT-M2GA-ATRN3-*` 事实，完整清单见下节及 `数据/facts.csv`。

## 结构化事实明细

本卡对应 24 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-ATRN3-BF16-ACC`
- `FACT-M2GA-ATRN3-BF16-ROUND`
- `FACT-M2GA-ATRN3-BF16-ROUND-STOCHASTIC`
- `FACT-M2GA-ATRN3-BGTRANSPOSE`
- `FACT-M2GA-ATRN3-COLL`
- `FACT-M2GA-ATRN3-DMA`
- `FACT-M2GA-ATRN3-EXEC`
- `FACT-M2GA-ATRN3-INDIRECT`
- `FACT-M2GA-ATRN3-MX-ACC`
- `FACT-M2GA-ATRN3-MX-IN`
- `FACT-M2GA-ATRN3-MX-OUT`
- `FACT-M2GA-ATRN3-MX-PRODUCT`
- `FACT-M2GA-ATRN3-NAME`
- `FACT-M2GA-ATRN3-NEARMEM`
- `FACT-M2GA-ATRN3-NL`
- `FACT-M2GA-ATRN3-PSUM`
- `FACT-M2GA-ATRN3-SBUF`
- `FACT-M2GA-ATRN3-SCALAR`
- `FACT-M2GA-ATRN3-SPARSE`
- `FACT-M2GA-ATRN3-STATUS`
- `FACT-M2GA-ATRN3-SW`
- `FACT-M2GA-ATRN3-TENSOR-IO`
- `FACT-M2GA-ATRN3-TENSOR-SHAPE`
- `FACT-M2GA-ATRN3-VECTOR`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | Trainium3/NCv4 及 GA 状态明确 |
| physical | not_applicable | 工艺、封装、核心数、频率和 HBM 实现下沉 |
| compute | partial | 四引擎、阵列和相对通路宽度明确，吞吐/频率下沉 |
| numerics | partial | MX 与 BF16 累加/舍入链较完整，物理累加器位宽仍缺 |
| memory | partial | HBM/SBUF/PSUM/DMA 管理明确，容量/带宽下沉 |
| interconnect | partial | NeuronLink-v4 与 CC-Core 各自的公开用途明确，内部编排、数量、速率和方向下沉 |
| special_engines | partial | 稀疏、近存累加、后台转置和间接寻址明确，MoE 专用 router 未找到 |
| software | partial | NKI 的 NCv4 MX 类型和 `nc_matmul_mx` 接口明确，API 状态需版本限定 |
| evidence | complete | 产品身份、版本化指南、NCv4 页和 GA 公告分工清楚 |

`SEARCH-M2GA-ATRN3-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-ATRN3-MOE-HW=not_found`。四条 `REQ-M2GA-AWS_TRAINIUM3_ARCH-*` 为 `not_applicable`。16/20 CC-Core 与 4.9/4.7 TB/s 是实现层真冲突候选，分别记录为 `M2GA-CF-004`、`M2GA-CF-005`；目标芯片对象建立前不在本卡择值或建 formal conflict group。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-A07` | NCv4 compute/memory、MX 与 BF16 PSUM、DMA、特殊能力及 NKI MX 接口 | 必须保留，承担主要微架构事实；动态 current 页需快照 |
| `SRC-M2-GA-A10` | MXFP4 计算前转换为 MXFP8，以及 Tensor Engine structured sparsity | 保留 MX 转换与七种 M:N 模式的独有版本化证据 |
| `SRC-M2-GA-A06` | Trainium3 Architecture | 保留代际身份；芯片峰值/容量/带宽转 待办 |
| `SRC-M2-GA-A08` | 2025-12-02 GA 公告 | 只保留 GA 状态；3 nm/HBM3e/UltraServer 转实现或系统 待办 |

实现对象待办 为 `DEF-M2GA-ATRN3-01` 至 `DEF-M2GA-ATRN3-09`。NeuronSwitch-v1、UltraServer 和 144 芯片聚合只见 `M2GA-BD-004`。本卡没有派生存算比，七目标 XOR 已检查。正式合并状态：`accepted / reviewed`。