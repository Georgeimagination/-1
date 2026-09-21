# Google TPU 8t 架构卡（观察对象草稿）

- 对象：`OBJ-GOOGLE-TPU-8T-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 状态：已宣布，截止日仍为即将提供
- 取证规则：未来对象只采纳截止日前一手明确内容，不按相对倍数补齐，也不把 Virgo/Pod 系统值下放。

## 架构事实

Google 明确披露 8t 具有原生 FP4 矩阵输入路径，但没有说明乘积、累加和输出精度（`FACT-M2GA-G8T-FP4`）。TensorCore、MXU、VPU、设备 HBM 和片上 VMEM 只作为已披露层级/组件登记；每芯片数量、峰值、容量与带宽均转入具体封装实现 backlog。

8t 公开了三类专用或数据搬运能力。SparseCore 可卸载 embedding，并支持 data-dependent all-gather（数据相关的全收集）；另有名为 LLM Decoder Engine 的专用模块，但公开材料没有给其内部算子和吞吐；TPUDirect 提供绕过 host CPU/DRAM 的 HBM 到 NIC 或托管存储直达路径（`FACT-M2GA-G8T-SPARSE`、`FACT-M2GA-G8T-ALLGATHER`、`FACT-M2GA-G8T-LDE`、`FACT-M2GA-G8T-TPUDIRECT`）。这些事实不能直接解释为专用 MoE router。

软件侧明确列出 JAX、XLA、Pallas/Mosaic、Keras，以及公告时仍处于 preview 的原生 PyTorch 支持（`FACT-M2GA-G8T-SW`）。状态断言为 `FACT-M2GA-G8T-STATUS`。Virgo 网络、机架和集群聚合只在边界日志记录。

结构化事实索引：`FACT-M2GA-G8T-NAME`、`...-STATUS`、`...-FP4`、`...-SPARSE`、`...-ALLGATHER`、`...-LDE`、`...-TPUDIRECT`、`...-SW`。

## 结构化事实明细

本卡对应 8 条 staging 事实。下列标识逐条回指 `structured/facts.csv`：

- `FACT-M2GA-G8T-ALLGATHER`
- `FACT-M2GA-G8T-FP4`
- `FACT-M2GA-G8T-LDE`
- `FACT-M2GA-G8T-NAME`
- `FACT-M2GA-G8T-SPARSE`
- `FACT-M2GA-G8T-STATUS`
- `FACT-M2GA-G8T-SW`
- `FACT-M2GA-G8T-TPUDIRECT`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 名称、公告日和截止日状态明确 |
| physical | not_applicable | 封装、工艺和 HBM 实现归未来 silicon_package |
| compute | partial | FP4 路径和组件存在性明确，执行组织未完整公开 |
| numerics | missing_public_data | 只明确 native FP4，累加/输出语义未找到 |
| memory | partial | HBM/VMEM 层级与 TPUDirect 路径明确，管理细节有限 |
| interconnect | partial | TPUDirect 数据路径明确；ICI 芯片机制未在所选深潜中定清 |
| special_engines | partial | SparseCore、data-dependent all-gather 和 LLM Decoder Engine 明确，内部细节有限 |
| software | partial | 框架与低层内核栈明确，PyTorch 状态需版本限定 |
| evidence | complete | 两个同日一手公告覆盖现有断言 |

`SEARCH-M2GA-G8T-ACC` 检查一手深潜后仍未找到 FP4 累加语义，`REQ-M2GA-G8T-ACC=not_found`。四条 `REQ-M2GA-GOOGLE_TPU_8T_ARCH-*` 为 `not_applicable`，因为它们是未来芯片 total，而不是架构代际机制。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-G13` | TPU 8t、SparseCore、LLM Decoder Engine、TPUDirect 和 Software enablement | 必须保留，承担全部微架构独有内容；带日期页面仍登记快照候选 |
| `SRC-M2-GA-G14` | 2026-04-22 状态公告 | 只保留 `announced/pending availability`，宣传性汇总不重复采用 |

实现 backlog 为 `DEF-M2GA-G8T-01` 至 `DEF-M2GA-G8T-03`，只含一手明确的未来芯片值，不生成任何相对推导。Board/机架/Virgo/Pod 值不进入 structured。七目标 XOR 已检查。当前自检状态：`draft / future_explicit_only`。