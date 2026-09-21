# 华为 Ascend 950 共享裸片资料卡

> 2026-09-16 复核提示：本卡是旧版架构笔记，不能继续按“一个共享物理裸片”使用。新官方白皮书明确完整封装含 2 个 AI Die 与 2 个 IO Die，且披露了原卡缺失的资源和互联规格。当前事实请以 [950PR 产品卡](华为_Ascend950PR_封装资料卡.md)和 [950DT 产品卡](华为_Ascend950DT_封装资料卡.md)中的原始引用为准；下文仅供追溯，不用于新统计。

> 模板版本：0.2  
> 卡片状态：草稿，返修完成，待最终独立复核  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-HUAWEI-ASCEND-950-DIE`  
> 对象层级：共享裸片（正式 `object_type=die`）  
> 建卡人：`m2_w3_huawei_asc950_physical`

SIMD 是单指令多数据，SIMT 是单指令多线程，HBM 是高带宽内存，PFLOPS 表示每秒千万亿次浮点运算。MoE（Mixture of Experts）是专家混合模型，Top-k 指选取最高的 k 项，Attention 是注意力计算，KV Cache 是键值缓存。本卡只写 950PR 和 950DT 共用的 Ascend 950 裸片；两种封装的 HBM、商用状态和定位留在各自资料卡。

## 1. 对象和范围

| 字段 | 内容 | 事实或要求标识 |
|---|---|---|
| 厂商 | Huawei | `FACT-M2W3-HUAWEI-ASC950-DIE-VENDOR` |
| 正式名称 | Huawei Ascend 950 die | `FACT-M2W3-HUAWEI-ASC950-DIE-NAME` |
| 产品系列 | Ascend 950 series | `FACT-M2W3-HUAWEI-ASC950-DIE-FAMILY` |
| 对象类型 | `die` | `FACT-M2W3-HUAWEI-ASC950-DIE-OBJECT-TYPE` |
| 首次公开日期 | 2025-09-18 | `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` |
| SKU、独立状态、可用日期 | `not_applicable`；裸片不是独立销售对象 | `REQ-M2W3-HUAWEI-ASC950-DIE-SKU`；`...-STATUS`；`...-AVAILABILITY` |
| 架构代际 | 未建立 | 正式库没有 Da Vinci `implements_architecture` 关系 |

950PR 与 950DT 分别通过既有关系 `OREL-HUAWEI-950PR-CONTAINS-950-DIE` 和 `OREL-HUAWEI-950DT-CONTAINS-950-DIE` 包含本裸片。本包不新建关系，也不迁移 15 条旧 Da Vinci 实现待办。

## 2. 物理实现

H-2 只确认两种封装共用这颗裸片，没有披露制程、代工厂、面积、晶体管数、时钟或裸片功耗。这些字段均为 `not_found`，对应 `REQ-M2W3-HUAWEI-ASC950-DIE-PROCESS`、`...-DIE-AREA`、`...-TRANSISTORS`、`...-CLOCK` 和 `...-POWER`。HiBL 1.0 与 HiZQ 2.0 是分别与裸片封装的 HBM，不能写成本裸片的片上容量。

## 3. 计算资源和吞吐

H-2 先说明 950PR 与 950DT 使用同一颗 Ascend 950 裸片，随后用 “Ascend 950 chips” 给出四个厂商算力标签、SIMD 与 SIMT 混合设计、128 byte 访问粒度和 2 TB/s 互联。七项取值都由来源直接给出；把复数芯片主语归一化到共享裸片，则是依据前一句“同一颗裸片”作出的推断。相应逐来源断言因此使用 `assertion_mode=inferred`，七项事实仍只保存一次。来源没有说明矩阵、向量或标量路径，也没有说明稠密/稀疏、乘加计数、功耗或频率，因此 `operation_class=other`、`operation_count_rule=vendor_label`，不能改写成矩阵峰值。

| 厂商格式标签 | 原始值 | 规范化值 | 条件 | 事实标识 |
|---|---:|---:|---|---|
| FP8 | 1 PFLOPS | $1\times10^{15}$ FLOP/s | 2025-09-18 路线图，口径未决 | `FACT-M2W3-HUAWEI-ASC950-DIE-FP8-THROUGHPUT` |
| MXFP8 | 1 PFLOPS | $1\times10^{15}$ FLOP/s | 同上 | `FACT-M2W3-HUAWEI-ASC950-DIE-MXFP8-THROUGHPUT` |
| HiF8 | 1 PFLOPS | $1\times10^{15}$ FLOP/s | 华为专有格式；编码未披露 | `FACT-M2W3-HUAWEI-ASC950-DIE-HIF8-THROUGHPUT` |
| MXFP4 | 2 PFLOPS | $2\times10^{15}$ FLOP/s | 同上 | `FACT-M2W3-HUAWEI-ASC950-DIE-MXFP4-THROUGHPUT` |

向量路径采用 SIMD+SIMT 混合设计，见 `FACT-M2W3-HUAWEI-ASC950-DIE-VECTOR-EXECUTION`。来源只说向量处理更强，没有给独立向量吞吐；该缺口是 `REQ-M2W3-HUAWEI-ASC950-DIE-VECTOR-THROUGHPUT`。

## 4. 数值格式和累加

四条路径只确认厂商格式标签和吞吐。程序员可见累加、物理累加位宽或语义均为 `not_found`，分别记录在每条精度路径的 `...-ACCUM` 与 `...-PHYSICAL-ACCUM` 要求中。H-2 的通用段落写 `MXFP4`，DT 段落另写 `XMFP4`；本包保留原文差异，不把后者悄悄建成新格式，也不判定它一定是笔误。

## 5. 存储层次和数据搬运

H-2 说访问粒度由 512 byte 缩到 128 byte，但没有指出对应缓存或 SRAM 层级。`FACT-M2W3-HUAWEI-ASC950-DIE-MEM-GRANULARITY` 因而挂在逻辑 load/store 组件，不挂到虚构缓存。片上存储名称、容量和带宽仍是 `not_found`，见 `REQ-M2W3-HUAWEI-ASC950-DIE-MEMORY-*`。

## 6. 计算与存储配比

不计算存算比。公开吞吐的运算类别和计数未决，片上存储带宽也不存在对象匹配定值；拿 PR/DT 的 HBM 带宽除共享裸片吞吐会跨越对象和条件。

## 7. 大模型相关特殊能力

没有找到 MoE 路由、Top-k、Attention、采样或 KV Cache 的专用硬件模块证据。`REQ-M2W3-HUAWEI-ASC950-DIE-SPECIAL-DETAIL` 为 `not_found`，本包没有创建 capability 占位对象。

## 8. 互联

H-2 给出的共同芯片标签是 2 TB/s，规范化为 $2\times10^{12}$ byte/s，见 `FACT-M2W3-HUAWEI-ASC950-DIE-INTERCONNECT-BW`。方向、有效载荷、链路数、单链路速率和拓扑都未披露；链路数与单链路速率分别保留 `not_found`。这条共同芯片记录、950DT 路线图中的 2 TB/s，以及 950PR 当前灵衢 2.0 的 2 TB/s 分属不同主体和条件，不能相加，也不能据此认定存在三套独立物理带宽池。

## 9. 软件、可靠性和实测

没有对象匹配的编译器或运行时版本，见 `REQ-M2W3-HUAWEI-ASC950-DIE-COMPILER` 与 `...-RUNTIME`。四份固定一手资料也没有裸片级可靠性、可用性和可维护性（RAS） 或独立实测，本卡不使用第三方补齐。

## 10. 来源、缺口和完整度

本卡 12 条事实的取值全部回到 `SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918`。其中七项共同芯片规格的值是直接来源事实，但共享裸片主体是规范化推断；对应断言为 `inferred`，事实的 `fact_kind=direct_statement`、`evidence_state=source_with_caveat` 和单来源计数不变。H-6 只补充 PR 当前正文和 DT 路由，不给共享裸片定值；H-7 是 Atlas 350 卡页；H-12 是 PR 嵌入商用状态。最小集对整个三对象包保留 H-2、H-6 和 H-12，H-7 由 H-12 完整覆盖当前入选事实并反向移除。

九域完整度恰有 identity、physical、compute、numerics、memory、interconnect、special_engines、software、evidence 九行，见 `card-completeness.csv`。本卡身份和证据可用；物理、片上存储、特殊能力与软件仍缺公开定值。

复核结论：返修已完成，待最终独立复核。正式库未合并。