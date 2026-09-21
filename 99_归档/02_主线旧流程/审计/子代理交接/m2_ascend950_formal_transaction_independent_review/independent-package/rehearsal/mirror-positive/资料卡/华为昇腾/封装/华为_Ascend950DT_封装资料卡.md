# 华为 Ascend 950DT 封装资料卡

> 模板版本：0.2  
> 卡片状态：草稿，返修完成，待最终独立复核  
> 资料截止日：2026-08-13  
> 对象标识：`OBJ-HUAWEI-ASCEND-950DT`  
> 对象层级：封装（正式 `object_type=package`）  
> 建卡人：`m2_w3_huawei_asc950_physical`

HBM 是高带宽内存，Decode 是推理中逐 token 生成的阶段。MoE（Mixture of Experts）是专家混合模型，Top-k 指选取最高的 k 项，Attention 是注意力计算，KV Cache 是键值缓存。本卡只写 Ascend 950DT 封装，并把 2025 年路线图与 2026-08-13 截止日状态分开。华为当前处理器页的 `?tag=950dt` 路由虽然可访问，服务器返回正文仍是 950PR，不能用来证明 950DT 已经上市或已经交付。

## 1. 对象和范围

| 字段 | 内容 | 事实或要求标识 |
|---|---|---|
| 厂商 | Huawei | `FACT-M2W3-HUAWEI-ASC950DT-VENDOR` |
| 正式名称 | Huawei Ascend 950DT | `FACT-M2W3-HUAWEI-ASC950DT-NAME` |
| SKU | Ascend 950DT | `FACT-M2W3-HUAWEI-ASC950DT-SKU` |
| 产品系列 | Ascend 950 series | `FACT-M2W3-HUAWEI-ASC950DT-FAMILY` |
| 对象类型 | `package` | `FACT-M2W3-HUAWEI-ASC950DT-OBJECT-TYPE` |
| 首次公开日期 | 2025-09-18 | `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` |
| 截止日状态 | `announced` | `FACT-M2W3-HUAWEI-ASC950DT-STATUS` |
| 精确可用日期 | `pending_verification`；路线图写 2026 年第四季度，截止日尚未到达 | `REQ-M2W3-HUAWEI-ASC950DT-AVAILABILITY` |
| 厂商定位 | Decode 阶段推理与模型训练 | `FACT-M2W3-HUAWEI-ASC950DT-POSITIONING` |

既有关系 `OREL-HUAWEI-950DT-CONTAINS-950-DIE` 表示本封装包含 `OBJ-HUAWEI-ASCEND-950-DIE`。本包不新建 Da Vinci `implements_architecture` 关系，也不迁移旧待办中的 15 条实现事实。

## 2. 物理实现

H-2 说明 Ascend 950 裸片与 HiZQ 2.0 专有 HBM 分别封装，形成 950DT，见 `FACT-M2W3-HUAWEI-ASC950DT-PACKAGE`。裸片制程、面积和晶体管数只应挂共享裸片，本封装的相应要求为 `not_applicable`。封装内裸片数量、HBM 堆叠数、总接口宽度、中介层或基板、封装功耗均为 `not_found`。散热属于卡或系统层，950DT 还没有对象匹配的一手卡级资料，因此该字段也是 `not_applicable`。

## 3. 计算资源和吞吐

本卡不复制共享裸片的 FP8、MXFP8、HiF8、MXFP4 算力，也不把它们改写成 950DT 封装专属吞吐。H-2 的通用段落在说明两种封装共用同一裸片后，以 “Ascend 950 chips” 给出四条算力、SIMD+SIMT、128 byte 粒度和共同 2 TB/s。七项值直接来自来源，但归一化到共享裸片的主体是推断；950DT 通过 `package_contains_die` 关系读取这些事实，属于数据模型复用，并非厂商逐字把共同规格写给 die。950DT 封装没有独立、对象匹配的计算吞吐事实。

## 4. 数值格式和累加

H-2 的通用段落写 `MXFP4`，950DT 段落另写 `XMFP4`。本包保留这个原文差异，不把 `XMFP4` 当成已确认的新格式，也不自行认定它是笔误。950DT 封装没有独立的输入、乘积、累加或输出精度定值；程序员可见累加和物理累加要求分别是 `REQ-M2W3-HUAWEI-ASC950DT-ACCUM` 与 `REQ-M2W3-HUAWEI-ASC950DT-PHYSICAL-ACCUM`，状态均为 `not_found`。

## 5. 存储层次和数据搬运

| 层级 | 原始值 | 规范化值 | 口径 | 事实标识 |
|---|---:|---:|---|---|
| HiZQ 2.0 HBM | 厂商专有 HBM | 未量化 | 2025-09-18 路线图；与共享裸片分别封装 | `FACT-M2W3-HUAWEI-ASC950DT-MEM-NAME` |
| 容量 | 144 GB | $144\times10^9$ byte | 十进制 GB；路线图值 | `FACT-M2W3-HUAWEI-ASC950DT-MEM-CAPACITY` |
| 内存带宽 | 4 TB/s | $4\times10^{12}$ byte/s | 方向和持续性未说明；路线图值 | `FACT-M2W3-HUAWEI-ASC950DT-MEM-BW` |

公开资料没有给内存延迟、读写模型或更细的缓存层次。本包只建立 HiZQ 2.0 HBM 这一条已命名层级，不创建未知缓存占位对象。

## 6. 计算与存储配比

不计算存算比。950DT 的 144 GB 和 4 TB/s 属于封装路线图值，共享裸片算力的运算类别、计数规则和实现条件仍未说明。把两者直接相除会把不同主体和未决条件拼成一个看似精确的结果。

## 7. 大模型相关特殊能力

“面向 Decode 阶段推理和模型训练”是厂商定位，不等于存在 MoE 路由、Top-k、Attention、采样或 KV Cache 专用硬件。四份固定一手资料没有提供这些模块的对象匹配证据，`REQ-M2W3-HUAWEI-ASC950DT-SPECIAL-DETAIL` 为 `not_found`，本包没有创建 capability 占位对象。

## 8. 互联

H-2 给出 950DT 总互联带宽 2 TB/s，规范化为 $2\times10^{12}$ byte/s，见 `FACT-M2W3-HUAWEI-ASC950DT-INTERCONNECT-BW`。原文没有说明方向、有效载荷、链路数、单链路速率或拓扑，这些都不能从 950PR 的灵衢 2.0 当前正文或 Atlas 350 卡级参数外推。该值、共同芯片 2 TB/s 和 950PR 当前灵衢 2.0 的 2 TB/s 分属不同条件记录，不能相加。`REQ-M2W3-HUAWEI-ASC950DT-TOPOLOGY` 因而为 `not_found`。

## 9. 软件、可靠性和实测

没有对象匹配的编译器或运行时版本，见 `REQ-M2W3-HUAWEI-ASC950DT-COMPILER` 和 `REQ-M2W3-HUAWEI-ASC950DT-RUNTIME`。也没有 950DT 封装的独立实测、可靠性定值、客户交付或正式上市证据，本卡不使用第三方资料填空。

## 10. 状态、来源筛选和完整度

H-2 是 950DT 身份、定位、封装、HBM、互联和路线图状态的唯一有效一手来源。H-6 的 `?tag=950dt` 路由只证明导航入口存在；2026-08-13 固定的服务器响应正文仍显示 950PR，所以不能升级 950DT 状态，也不能把 PR 的 128 GB、1.6 TB/s、1784 TFLOPS 或灵衢 2.0 参数复制过来。H-7 和 H-12 都是 Atlas 350／950PR 资料，对 950DT 没有直接贡献。

截止 2026-08-13，950DT 仍标为 `announced`。H-2 给出的 2026 年第四季度是未来路线图窗口，不是已经发生的通用可用或客户交付。九域完整度恰有 identity、physical、compute、numerics、memory、interconnect、special_engines、software、evidence 九行；身份、路线图内存和互联有事实，其余缺口按要求表保留。

复核结论：返修已完成，待最终独立复核。正式库未合并。