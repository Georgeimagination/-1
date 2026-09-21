# 华为 Ascend 950PR 封装资料卡

> 模板版本：0.2  
> 卡片状态：草稿，返修完成，待最终独立复核  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-HUAWEI-ASCEND-950PR`  
> 对象层级：封装（正式 `object_type=package`）  
> 建卡人：`m2_w3_huawei_asc950_physical`

HBM 是高带宽内存，LLM 是大语言模型，TFLOPS 是厂商使用的每秒万亿次浮点运算标签，Prefill 是推理中的提示词处理阶段。MoE（Mixture of Experts）是专家混合模型，Top-k 指选取最高的 k 项，Attention 是注意力计算，KV Cache 是键值缓存。本卡只写 Ascend 950PR 封装；Atlas 350 的卡级规格全部排除。

## 1. 对象和范围

| 字段 | 内容 | 事实或要求标识 |
|---|---|---|
| 厂商 | Huawei | `FACT-M2W3-HUAWEI-ASC950PR-VENDOR` |
| 正式名称 / SKU | Huawei Ascend 950PR / Ascend 950PR | `FACT-M2W3-HUAWEI-ASC950PR-NAME`；`FACT-M2W3-HUAWEI-ASC950PR-SKU` |
| 产品系列 | Ascend 950 series | `FACT-M2W3-HUAWEI-ASC950PR-FAMILY` |
| 对象类型 | `package` | `FACT-M2W3-HUAWEI-ASC950PR-OBJECT-TYPE` |
| 首次公开日期 | 2025-09-18 | `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` |
| 截止日状态 | `available`；由 Atlas 350 上市归一化推断，仅限嵌入已正式上市的卡 | `FACT-M2W3-HUAWEI-ASC950PR-STATUS` |
| 独立封装首次可用日期 | `not_found` | `REQ-M2W3-HUAWEI-ASC950PR-AVAILABILITY` |
| 厂商定位 | LLM Prefill 阶段与高性能推荐 | `FACT-M2W3-HUAWEI-ASC950PR-POSITIONING` |
| 公开部署 | H-12 直接说明 Atlas 350 正式上市，七家伙伴展示基于该卡的整机 | `FACT-M2W3-HUAWEI-ASC950PR-DEPLOYMENT` |

既有关系 `OREL-HUAWEI-950PR-CONTAINS-950-DIE` 表示本封装包含 `OBJ-HUAWEI-ASCEND-950-DIE`。正式库没有 Da Vinci `implements_architecture` 关系，本卡不新建或猜测。

## 2. 物理实现

H-2 说明 HiBL 1.0 HBM 与共享裸片分别封装，形成 950PR，见 `FACT-M2W3-HUAWEI-ASC950PR-PACKAGE`。裸片制程、面积和晶体管数只应挂共享裸片，本卡将这些要求标为 `not_applicable`。封装内裸片数量、HBM 堆叠数、HBM 总接口宽度、中介层或基板、封装功耗均为 `not_found`。散热属于卡或系统而不是封装；Atlas 350 的被动散热不能下放。

## 3. 计算资源和吞吐

H-6 当前 950PR 正文写“支持多种精度格式，最大支持 1784 TFLOPS”，但没有说明这个最大值对应哪种格式、矩阵还是向量、稠密还是稀疏，也没有运算计数、功耗或频率条件。结构化记录因此使用未决精度路径，规范化为 $1.784\times10^{15}$ FLOP/s，见 `FACT-M2W3-HUAWEI-ASC950PR-VENDOR-MAX-THROUGHPUT`。它不能和 H-2 的共享裸片格式值相加，也不能改写成矩阵峰值。

共享裸片的四条低精度标签、SIMD+SIMT 机制、128 byte 粒度和共同 2 TB/s 只在裸片卡记录一次。本卡通过 `package_contains_die` 关系读取，这是数据模型中的事实复用；H-2 的直接主语是复数 “Ascend 950 chips”，并未逐字把七项规格写给 die。把主体归一化到共享裸片的七条断言均为 `inferred`，本卡不复制这些事实。

## 4. 数值格式和累加

950PR 的 1784 TFLOPS 标签连输入格式都没有指明，程序员可见累加与物理累加分别为 `not_found`，见 `REQ-M2W3-HUAWEI-ASC950PR-ACCUM` 和 `...-PHYSICAL-ACCUM`。资料没有提供舍入、缩放、乘积或输出精度，不能从 Atlas 350 卡的 mxFP4、mxFP8、HiF8、FP16 或 BF16 表格反推。

## 5. 存储层次和数据搬运

| 层级 | 原始值 | 规范化值 | 口径 | 事实标识 |
|---|---:|---:|---|---|
| HiBL 1.0 HBM | 厂商专有 HBM | 未量化 | 与共享裸片分别封装 | `FACT-M2W3-HUAWEI-ASC950PR-MEM-NAME` |
| 最大容量 | 128 GB | $128\times10^9$ byte | H-6 当前 PR 正文；十进制 GB | `FACT-M2W3-HUAWEI-ASC950PR-MEM-CAPACITY` |
| 内存带宽 | 1.6 TB/s | $1.6\times10^{12}$ byte/s | 方向未注明，铭牌值，不是持续实测 | `FACT-M2W3-HUAWEI-ASC950PR-MEM-BW` |

来源没有给延迟或读写模型，见 `REQ-M2W3-HUAWEI-ASC950PR-MEM-LATENCY` 和 `...-MEM-RW-MODEL`。Atlas 350 卡页的 112 GB、1.4 TB/s 是卡级规格，迁移数为 0。

## 6. 计算与存储配比

不计算存算比。1784 TFLOPS 的精度、运算类别和计数规则未决，1.6 TB/s 的方向与可持续性也不清楚。即便算术可做，也不满足同精度、同条件的派生字段合同。

## 7. 大模型相关特殊能力

没有找到 950PR 专用 MoE 路由、Top-k、Attention、采样或 KV Cache 硬件模块。`REQ-M2W3-HUAWEI-ASC950PR-SPECIAL-DETAIL` 为 `not_found`；“面向 Prefill 与推荐”只是厂商定位，不等于专用算子硬件。

## 8. 互联

H-6 当前 PR 正文给出灵衢 2.0 协议和最高 2 TB/s 双向互联带宽，见 `FACT-M2W3-HUAWEI-ASC950PR-INTERCONNECT-PROTOCOL` 与 `FACT-M2W3-HUAWEI-ASC950PR-INTERCONNECT-BW`。带宽规范化为 $2\times10^{12}$ byte/s，条件明确为 `bidirectional_aggregate`。单链路速率、链路数量、有效载荷和拓扑均为 `not_found`。Atlas 350 的 318/424 GB/s 卡间互联不属于本封装。

## 9. 软件、可靠性和实测

没有对象匹配的编译器或运行时版本，见 `REQ-M2W3-HUAWEI-ASC950PR-COMPILER` 和 `...-RUNTIME`。H-6 有资源入口，但入口存在不等于已固定版本证据。也没有独立封装级实测或客户交付量。

## 10. 状态、来源筛选和完整度

H-2 在 2025-09-18 预告 950PR 于 2026 年第一季度可用；H-12 在 2026-03-20 直接写明搭载 950PR 的 Atlas 350 正式上市。本卡把后一句归一化为 950PR package 在嵌入条件下 `available`，这一主体和状态转换使用 `assertion_mode=inferred`，不是 H-12 对独立 package 状态的直接陈述。H-12 对 Atlas 350 搭载关系和七家伙伴整机的 deployment 断言仍为 `direct_statement`。该状态不表示 950PR 独立零售、单独交付或已有客户出货量。

本卡的不可替代来源是 H-2、H-6 和 H-12。H-7 只重复 Atlas 350 采用 950PR，H-12 已覆盖这个关系并提供日期；H-7 的其余内容是卡级参数，所以在本包最小集中 `redundant_covered`。九域完整度恰有九行。身份、内存和互联有部分公开事实；物理细节、数值语义、特殊能力与软件仍缺定值。

复核结论：返修已完成，待最终独立复核。正式库未合并。