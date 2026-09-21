# AWS Trainium 第一代架构资料卡

- 对象：`OBJ-AWS-TRAINIUM1-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 边界：记录 NeuronCore-v2（NCv2）的架构机制；芯片总核心数、峰值、SBUF/PSUM/HBM 容量与带宽、CC-Core/NeuronLink 数量均归具体实现。

## 架构事实

NCv2 包含 Tensor、Vector、Scalar 和 GpSimd 四类可异步并行的执行引擎，各自有独立 sequencer，并通过 Sync Engine 协调（`FACT-M2GA-ATRN1-EXEC`）。Tensor Engine 是 128×128 PE 脉动阵列（`FACT-M2GA-ATRN1-TENSOR-SHAPE`）。Vector 路径负责逐元素、激活和规约型操作，Scalar 路径处理标量/控制算术，GpSimd 提供通用可编程 SIMD（`FACT-M2GA-ATRN1-VECTOR`、`...-SCALAR`、`...-GPSIMD`）。

BF16/FP16 Tensor 路径采用 FP32 累加语义；cFP8 和 TF32 也是公开输入格式（`FACT-M2GA-ATRN1-FP-IN`、`FACT-M2GA-ATRN1-FP-ACC`、`FACT-M2GA-ATRN1-CFP8`）。物理累加器位宽和 cFP8/TF32 的完整输出/舍入链未公开。

设备 HBM、软件管理 SBUF 和 PSUM 构成主要存储层次。SBUF 由四类执行引擎共享，PSUM 是 Tensor Engine 的累加/结果存储；异步 DMA 在 HBM 与 SBUF 之间搬运数据；Trainium 产品页另明确支持内联压缩和解压缩（`FACT-M2GA-ATRN1-SBUF`、`...-PSUM`、`...-DMA`、`...-COMPRESS`、`...-DECOMPRESS`）。设备包含专用 CC-Core 用于集合通信，NeuronLink-v2 是设备直连传输机制；当前证据不推定两者内部如何编排（`FACT-M2GA-ATRN1-COLL`、`FACT-M2GA-ATRN1-NL`）。NKI（Neuron Kernel Interface）内核由 Neuron Compiler 编译，编译器可按内核数据依赖插入引擎同步（`FACT-M2GA-ATRN1-SW`）。

结构化事实索引：本卡全部 17 条 `FACT-M2GA-ATRN1-*` 机制/数值语义事实；完整清单见 `数据/facts.csv`。

## 结构化事实明细

本卡对应 17 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-ATRN1-CFP8`
- `FACT-M2GA-ATRN1-COLL`
- `FACT-M2GA-ATRN1-COMPRESS`
- `FACT-M2GA-ATRN1-DECOMPRESS`
- `FACT-M2GA-ATRN1-DMA`
- `FACT-M2GA-ATRN1-EXEC`
- `FACT-M2GA-ATRN1-FP-ACC`
- `FACT-M2GA-ATRN1-FP-IN`
- `FACT-M2GA-ATRN1-GPSIMD`
- `FACT-M2GA-ATRN1-NAME`
- `FACT-M2GA-ATRN1-NL`
- `FACT-M2GA-ATRN1-PSUM`
- `FACT-M2GA-ATRN1-SBUF`
- `FACT-M2GA-ATRN1-SCALAR`
- `FACT-M2GA-ATRN1-SW`
- `FACT-M2GA-ATRN1-TENSOR-SHAPE`
- `FACT-M2GA-ATRN1-VECTOR`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | Trainium/NCv2 身份明确 |
| physical | not_applicable | 工艺、封装、核心和链路数量下沉 |
| compute | partial | 四引擎、同步与阵列明确，频率/吞吐下沉 |
| numerics | partial | BF16/FP16→FP32 和 cFP8/TF32 支持明确，完整精度链仍缺 |
| memory | partial | HBM/SBUF/PSUM 与 DMA 机制明确，容量/带宽下沉 |
| interconnect | partial | NeuronLink-v2 与 CC-Core 分别明确；内部编排关系、速率、方向和数量不在本卡推定 |
| special_engines | partial | 压缩/解压和 collective offload 明确，MoE 专用模块未找到 |
| software | partial | NKI 内核的 Neuron Compiler 同步处理明确，其他软件栈范围仍需版本限定 |
| evidence | complete | 产品代际页与版本化 NCv2 指南互补 |

`SEARCH-M2GA-ATRN1-MOE-HW` 的结果为 `no_reliable_result`，`REQ-M2GA-ATRN1-MOE-HW=not_found`。四条 `REQ-M2GA-AWS_TRAINIUM1_ARCH-*` 为 `not_applicable`。820 GiB/s 与 820 GB/s 是实现层同条件单位标签冲突，记录为 `M2GA-CF-007`；本架构对象不建 formal conflict group。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-A05` | NCv2 compute engines、Tensor data path、SBUF/PSUM、DMA 与 collective | 必须保留，承担共同微架构机制；版本化入口 |
| `SRC-M2-GA-A03` | Trainium 产品身份、cFP8/TF32 与内联压缩/解压缩 | 保留 identity、数值格式和数据搬运机制；芯片总量转入 待办 |
| 更早 Neuron 页 | 旧 420 INT8 TOPS | `superseded` 线索；不进入事实链，也不猜差值原因 |

实现对象待办 为 `DEF-M2GA-ATRN1-01` 至 `DEF-M2GA-ATRN1-05`，目标是 Trainium1 silicon_package。EC2 Trn1 实例与系统聚合不下放。七目标 XOR 已检查；没有派生存算比。正式合并状态：`accepted / reviewed`。