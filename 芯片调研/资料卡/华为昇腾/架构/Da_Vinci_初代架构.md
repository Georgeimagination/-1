# 华为 Da Vinci 初代架构资料卡

对象 ID：`OBJ-HUAWEI-DA-VINCI-INITIAL-ARCH`。本卡只承接 2019 年 Da Vinci 原始论文直接描述的人工智能核心（AI Core），以及 2021 年论文明确复述的共享核心机制。Ascend 910、610、310 的 SoC、服务器、片外存储、片上网络和集群参数都不投射到这个架构代际对象。

## 执行组织

Da Vinci AI Core 把标量控制、向量计算、矩阵计算和数据搬运分开。scalar unit 执行类似精简指令集（RISC）的控制与简单标量操作，vector unit 执行单指令多数据（SIMD）向量操作，cube unit 执行矩阵运算，Memory Transfer Engine（内存搬运引擎，MTE）负责层级间的数据移动与变换。不同路径通过独立队列发射，依赖关系由 barrier 控制，因此 cube、vector 与 MTE 可以并行工作。

这部分机制分别记录为 `FACT-HUAWEI-DV-EXECUTION` 和 `FACT-HUAWEI-DV-CONCURRENCY`。论文中的 16×16×16 cube、乘法器和累加器数量属于具体实现配置，不能代表整个 Da Vinci 代际，已从架构事实移到 `审计/M2-GHC-ARCH_实现对象待办.csv`。

## 数值路径

cube 的 FP16 路径只保留论文明确给出的信息：两个源操作数均为 FP16，destination 为 FP32，对应 `FACT-HUAWEI-DV-CUBE-FP16-OPERAND-A`、`FACT-HUAWEI-DV-CUBE-FP16-OPERAND-B` 和 `FACT-HUAWEI-DV-CUBE-FP16-OUTPUT`。这里的 destination 不能等同于物理累加精度，因此此前的 FP32 accumulation 推断已经删除，并以 `REQ-HUAWEI-DV-CUBE-FP16-ACCUM` 保留缺口。

INT8 路径目前只能确认一个源操作数为 INT8，即 `FACT-HUAWEI-DV-CUBE-INT8-OPERAND-A`；第二个源操作数、累加和输出精度仍未找到可靠定值。vector unit 明确支持 INT32、FP16 与 INT8 之间的格式转换，这一机制写在 `FACT-HUAWEI-DV-NUM-CONVERSION`，但不据此推断舍入、缩放或饱和语义。Hot Chips 论文还写到向量路径可以执行 FP32 运算；现有字段不能在不夸大含义的前提下表达“通用支持”，所以该线索只进入 `GAP-HUAWEI-007`，没有强塞进 Operand A 字段。

## 存储与搬运

架构层保留 L1、L0A、L0B、L0C 和 Unified Buffer（统一缓冲区，UB）的层级与连接关系。MTE 从 L1 向 L0A、L0B、L0C 搬运数据，并支持 zero decompression、img2col 和 transpose。数据搬运机制对应 `FACT-HUAWEI-DV-MTE-DMA`，其中解压与重排能力还分别拆为 `FACT-HUAWEI-DV-MTE-DECOMP` 和 `FACT-HUAWEI-DV-MTE-RESHAPE`。

2019 年框图里的 L0A、L0B、L0C、UB、L1 容量，以及 2021 年 Table 5 的 Ascend-Max 每周期吞吐和 A、B、UB 带宽，都是具体配置。它们已逐条原子化写入实现对象待办，不再作为架构事实，也不据此计算 Da Vinci 代际的通用存算比。原文容量单位保留为 KB 或 MB，不擅自换算成 KiB 或 MiB；带宽方向未由表格明确时，也不推断成读、写或双向。

## 互联、物理边界与软件

初代 AI Core 架构没有定义通用的片间互联拓扑。2021 年论文中的 Ascend 910 片上网络、链路、HBM 和系统通信属于具体 SoC 或系统对象，架构级互联因此记为 `not_applicable`。制程、面积、晶体管、功耗和时钟同样由后续实现对象承接，其中 Ascend-Max 的 1 GHz 条件已在实现待办中写明。

TBE、TIK 和 CCE-C 是映射到 Da Vinci AI Core 操作的软件接口，对应 `FACT-HUAWEI-DV-SW-PROGRAMMING`；它们不是物理执行模块。两篇入选论文都没有说明专用的专家混合模型（Mixture of Experts，MoE）routing 或 Top-K 单元，相关字段记为 `not_found`。

## 最小来源集

`SRC-HUAWEI-DAVINCI-HOTCHIPS31-2019` 负责首代名称、组件、存储层级和编程接口，并为若干具体配置保留实现对象线索；`SRC-HUAWEI-ASCEND-HPCA2021` 负责共享执行机制、数值路径、MTE 和另一组实现配置线索。两篇来源的角色不同，不能互相完全替代。引用 2021 年论文时需注明“共享核心机制”或“Ascend-Max 示例配置”，不能把 Table 5 的数字写成 2019 初代架构的统一定值。

## 追溯合同

| 卡片结论 | fact_id | assertion / source / 定位 |
|---|---|---|
| Da Vinci 可扩展 AI Core 架构名称 | `FACT-HUAWEI-DV-NAME` | `ASRT-HUAWEI-DV-NAME` → `SRC-HUAWEI-DAVINCI-HOTCHIPS31-2019`，PDF pp.1、9 |
| scalar、vector、cube 与 MTE 分路执行 | `FACT-HUAWEI-DV-EXECUTION` | `ASRT-HUAWEI-DV-EXECUTION` → `SRC-HUAWEI-ASCEND-HPCA2021`，PDF pp.3 至 4 |
| cube、vector 与 MTE 可并行并用 barrier 控制依赖 | `FACT-HUAWEI-DV-CONCURRENCY` | `ASRT-HUAWEI-DV-CONCURRENCY` → 同源，PDF p.4 |
| FP16 路径的两个源操作数均为 FP16 | `FACT-HUAWEI-DV-CUBE-FP16-OPERAND-A`、`FACT-HUAWEI-DV-CUBE-FP16-OPERAND-B` | 对应同名 `ASRT-*` → 同源，PDF p.3 |
| FP16 路径的 destination 为 FP32，不据此推断累加精度 | `FACT-HUAWEI-DV-CUBE-FP16-OUTPUT` | `ASRT-HUAWEI-DV-CUBE-FP16-OUTPUT` → 同源，PDF p.3 |
| INT8 cube 路径的源操作数 A 为 INT8 | `FACT-HUAWEI-DV-CUBE-INT8-OPERAND-A` | `ASRT-HUAWEI-DV-CUBE-INT8-OPERAND-A` → 同源，PDF p.3 |
| vector 路径支持 INT32、FP16、INT8 之间的格式转换 | `FACT-HUAWEI-DV-NUM-CONVERSION` | `ASRT-HUAWEI-DV-NUM-CONVERSION` → 同源，PDF pp.3 至 4 |
| MTE 负责 L1 与 L0A/L0B/L0C 之间的数据搬运 | `FACT-HUAWEI-DV-MTE-DMA` | `ASRT-HUAWEI-DV-MTE-DMA` → 同源，PDF p.4 |
| MTE 支持 zero decompression | `FACT-HUAWEI-DV-MTE-DECOMP` | `ASRT-HUAWEI-DV-MTE-DECOMP` → 同源，PDF p.4 |
| MTE 支持 img2col 和 transpose | `FACT-HUAWEI-DV-MTE-RESHAPE` | `ASRT-HUAWEI-DV-MTE-RESHAPE` → 同源，PDF p.4 |
| TBE、TIK、CCE-C 映射到 AI Core 操作 | `FACT-HUAWEI-DV-SW-PROGRAMMING` | `ASRT-HUAWEI-DV-SW-PROGRAMMING` → 同源，PDF p.9 |

九域完整度为：identity 与 evidence 为 `complete`；physical 与 interconnect 为 `not_applicable`；compute、numerics、memory、special_engines、software 为 `partial`。结构化记录见 `CC-HUAWEI-DA-VINCI-INITIAL-ARCH-*`。

具体配置已经从架构 facts、assertions、value-available requirements 及卡内正式追溯中移出。实现待办共 15 行：原有 Ascend-Max 1 GHz 时钟一行，加上本轮拆出的 cube 形状、单元数、两种向量宽度、五级容量、每周期吞吐和三项带宽十四行。它们保留来源、定位、条件、原始单位与方向边界，等待建立对应的 die、SoC 或实现配置对象。

验收：独立复核结论为 `accept`。总控已将本卡对应的结构化数据与来源链写入正式库；正式验证器通过 46,985 项检查，资料池校验核对 107 份 PDF，并保留 1 个既有解析器警告。