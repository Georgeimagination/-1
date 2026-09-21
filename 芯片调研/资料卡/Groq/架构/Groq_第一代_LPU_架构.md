# Groq 第一代 LPU 架构资料卡

对象 ID：`OBJ-GROQ-LPU1-ARCH`。这里的 LPU 指 Language Processing Unit（语言处理单元）；论文原名是 Tensor Streaming Processor（张量流处理器，TSP）。对象层级为 `architecture_generation`，只记录第一代 TSP 跨实现成立的机制，不承接某颗裸片、封装、卡或产品修订的定值。

## 执行组织与数值路径

第一代 TSP 采用静态调度的空间执行。编译器预先安排指令、数据搬运和功能切片，硬件不依赖动态仲裁或硬件管理缓存。代际根组件下有指令控制单元（ICU）、矩阵执行模块（MXM）、向量执行模块（VXM）、数据重排模块（SXM）、存储模块（MEM）和芯片间通信（C2C）。

MXM 的公开接口包括 INT8 输入与 INT32 累加，以及 FP16 输入与 FP32 累加。ISCA 2020 第 9 页还写明，320-element sum 在矩阵操作末尾只发生一次舍入；这句话描述舍入发生的阶段，没有说明 RNE、RTZ 或随机舍入等具体模式，所以不再写入 `rounding_mode` 枚举。舍入模式由 `REQ-GROQ-LPU1-ROUNDING-MODE` 记录为 `not_found`。

VXM 通过 lane 内 ALU mesh 执行向量算术，产品简报 v1.7 给出 FP16 与 FP32 程序员可见格式。SXM 负责向量置换、旋转、分发和变换。芯片级向量吞吐、物理累加位宽、TruePoint 缩放粒度和非规格数处理仍未找到可靠公开值。

## 存储、互联和软件

MEM 提供扁平的全局片上 SRAM，由编译器显式安排数据搬运。结构化事实只把管理方式规范为 `compiler_managed`，完整厂商表述保留在断言中。220 MiB、55 TiB/s、230 MB 和 80 TB/s 分属首颗实现或后续产品修订，均在 `审计/M2-GHC-ARCH_实现对象待办.csv` 中等待物理对象承接，不能用于计算架构代际存算比。

C2C 通过 send/receive 指令搬运架构向量。链路数量、线路速率和聚合带宽也属于具体实现。ISCA 2022 scale-out 论文的 ACM DOI 当前返回 HTTP 403，Groq 官方地区 PDF 镜像返回 HTTP 522；两个端点已经分开记录，正文未固定前，scale-out 拓扑、有效载荷和集合通信维持 `inaccessible_evidence`。

编译器承担指令排程、数据放置和功能切片编排。已检查的一手材料没有说明专用 MoE routing 或 Top-K 物理模块，两项保持 `not_found`；能够运行同名算子不能反推专用硬件。

## 实现对象待办

首颗 ASIC 和 v1.7 产品修订的 14 nm、25×29 mm、时钟、晶体管、算力、SRAM、C2C、300 W 最大功耗、215 W TDP、185 W 平均功耗、PCIe Gen4×16 控制器和 PCIe CEM 形态都保存在实现待办。每项使用单一 `source_id` 和具体页码；820 TeraOps/s 条目显式带有 1 GHz 条件。

## 事实追溯

| 卡片内容 | fact_id | assertion / source / 定位 |
|---|---|---|
| 第一代 TSP 架构身份 | `FACT-GROQ-LPU1-NAME` | `ASRT-GROQ-LPU1-NAME` → `SRC-GROQ-TSP-ISCA2020`，PDF p.12，Conclusion |
| 静态、编译器编排的空间执行 | `FACT-GROQ-LPU1-EXECUTION` | `ASRT-GROQ-LPU1-EXECUTION` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.1 至 3 |
| 编译器显式安排指令和数据搬运 | `FACT-GROQ-LPU1-SW-MAPPING` | `ASRT-GROQ-LPU1-SW-MAPPING` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.2 至 3、8 |
| SXM 执行向量置换和数据变换 | `FACT-GROQ-LPU1-SXM-FUNCTION` | `ASRT-GROQ-LPU1-SXM-FUNCTION` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.4 至 5、9 |
| VXM 通过 lane 内 ALU mesh 执行向量算术 | `FACT-GROQ-LPU1-VXM-FUNCTION` | `ASRT-GROQ-LPU1-VXM-FUNCTION` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.4、8 |
| MXM 的 INT8 输入与 INT32 累加路径 | `FACT-GROQ-LPU1-MXM-INT8-OPERANDS`、`FACT-GROQ-LPU1-MXM-INT8-ACCUM` | 对应 `ASRT-*` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.5、9 |
| MXM 的 FP16 输入与 FP32 累加路径 | `FACT-GROQ-LPU1-MXM-FP16-OPERANDS`、`FACT-GROQ-LPU1-MXM-FP16-ACCUM` | 对应 `ASRT-*` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.5、9 |
| VXM 的 FP16 与 FP32 程序员可见格式 | `FACT-GROQ-LPU1-VXM-FP16-SUPPORT`、`FACT-GROQ-LPU1-VXM-FP32-SUPPORT` | 对应 `ASRT-*` → `SRC-GROQ-GROQCHIP-BRIEF-V1-7`，PDF p.2，Numerics |
| 扁平 SRAM 由编译器显式管理 | `FACT-GROQ-LPU1-MEM-MANAGEMENT` | `ASRT-GROQ-LPU1-MEM-MANAGEMENT` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.3 至 6 |
| C2C send/receive 搬运 320-byte 架构向量 | `FACT-GROQ-LPU1-C2C-PROTOCOL` | `ASRT-GROQ-LPU1-C2C-PROTOCOL` → `SRC-GROQ-TSP-ISCA2020`，PDF pp.4 至 5 |

上述表覆盖本对象在正式结构化数据中的 13 条事实。名称、组件职责、软件映射和数值路径都保留卡片入口，没有仅存在于 CSV 的孤立事实。

## 完整度、来源与验收

九域完整度为：identity `complete`；physical `not_applicable`；compute、numerics、memory、interconnect、software、evidence 为 `partial`；special_engines 为 `missing_public_data`。结构化记录见 `CC-GROQ-LPU1-ARCH-*`。

最小架构事实链保留 `SRC-GROQ-TSP-ISCA2020` 和 `SRC-GROQ-GROQCHIP-BRIEF-V1-7`。前者支撑代际机制和 MXM 数值路径，后者只补 VXM 程序员可见格式。2019 白皮书与 ISCA 2022 论文正文未取得，不能判为已被其他来源覆盖。

验收：独立复核结论为 `accept`。总控已将本卡对应的结构化数据与来源链写入正式库；正式验证器通过 46,985 项检查，资料池校验核对 107 份 PDF，并保留 1 个既有解析器警告。