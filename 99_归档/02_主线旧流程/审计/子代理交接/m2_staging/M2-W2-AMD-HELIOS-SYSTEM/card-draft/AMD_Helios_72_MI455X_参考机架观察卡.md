# AMD Helios 72-MI455X 参考机架观察卡

- 对象：`OBJ-AMD-HELIOS-72-MI455X`
- 对象层级：`rack`
- 卡片性质：观察卡草稿
- 状态：`announced`
- 资料截止日：2026-08-12

## 先看边界

这张卡记录 AMD Helios 参考机架，不把它当成可直接向 AMD 下单的产品。AMD 原文称其为 rackscale AI reference design，供原始设备制造商（OEM）和原始设计制造商（ODM）构建自有系统；AMD 不直接销售这套参考设计。页面预计 2026 年下半年进行规模部署；截至本卡截止日，只能规范为 `announced`，不能写成已经供货。

Open Rack Wide（ORW）是 Meta 提交给开放计算项目（OCP）的宽机架标准。UALink over Ethernet（UALoE）是页面给出的机架内 scale-up 连接名称。以下数值全部来自 AMD 对完整机架的直接陈述，没有把 MI455X 单模组规格乘以 72。

## 身份与物理形态

| 项目 | 记录值 | 事实 ID | 证据定位 |
|---|---|---|---|
| 正式名称 | AMD Helios Rackscale Solution | `FACT-M2W2-AMD-HELIOS-NAME` | Helios 快照 11208 |
| 对象类型 | rack | `FACT-M2W2-AMD-HELIOS-OBJECT-TYPE` | Helios 快照 11208 |
| 机架形态 | open, double-wide ORW rack | `FACT-M2W2-AMD-HELIOS-FORM-FACTOR` | Helios 快照 11208 |
| 厂商定位 | AMD first rackscale AI reference design | `FACT-M2W2-AMD-HELIOS-REFERENCE-DESIGN` | Helios 快照 11208 |
| 销售边界 | reference design, not a product for sale | `FACT-M2W2-AMD-HELIOS-NOT-FOR-SALE` | Helios 快照 11268 |
| 产品状态 | announced；规模部署预计在 2026 年下半年 | `FACT-M2W2-AMD-HELIOS-STATUS-EXPECTED-2H26` | CES 快照 290；Helios 快照 11288 |
| 散热 | liquid | `FACT-M2W2-AMD-HELIOS-COOLING` | Helios 快照 9088 |
| MI455X 数量 | 72 个 | `FACT-M2W2-AMD-HELIOS-MI455X-QTY` | Helios 快照 11208；MI400 快照 6935 |

`FIELD-REL-QUANTITY` 挂在正式关系 `OREL-AMD-HELIOS-CONTAINS-MI455X` 上。数量由两个固定官方页面直接支持，不来自对象 ID。

## 机架直报算力与内存

| 项目 | 原始口径 | 规范值 | 事实 ID | 主要定位 |
|---|---:|---:|---|---|
| 厂商标注 AI 算力 | up to 3 AI exaflops | 3,000,000,000,000,000,000 FLOP/s | `FACT-M2W2-AMD-HELIOS-AI-EXAFLOPS-UNSPEC` | CES 快照 290 |
| OCP MXFP4 峰值 | 2.9 exaFLOPS | 2,900,000,000,000,000,000 FLOP/s | `FACT-M2W2-AMD-HELIOS-MXFP4-PEAK` | Helios 11238、11722；MI400 7531、13098 |
| OCP MXFP8 峰值 | 1.4 exaFLOPS | 1,400,000,000,000,000,000 FLOP/s | `FACT-M2W2-AMD-HELIOS-MXFP8-PEAK` | Helios 11238、11722；MI400 7531、13098 |
| HBM4 总容量 | 31 TB | 31,000,000,000,000 byte | `FACT-M2W2-AMD-HELIOS-HBM4-CAP` | Helios 快照 11238 |
| 机架内存带宽 | 1.67 PB/s | 1,670,000,000,000,000 byte/s | `FACT-M2W2-AMD-HELIOS-HBM4-BW` | MI400 7531（精确值）、8252（理论峰值定性） |

“AI exaflops”是 CES 新闻稿的厂商标签。该段没有给数据格式和运算计数规则，因此这条事实使用独立精度路径 `PPATH-M2W2-AMD-HELIOS-AI-UNSPEC`，状态为 `needs_resolution`；它不能与 OCP MXFP4 或 MXFP8 峰值合并。MXFP4 和 MXFP8 仍是两条独立 precision path，但共同引用 `COND-M2W2-AMD-HELIOS-OCP-MXFP-PEAK`：两者都是 AMD Performance Labs 于 2026 年 6 月计算的机架理论峰值，系统厂商配置可能不同，页面也没有说明稠密或稀疏条件。1.67 PB/s 是保留的精确原值；同页 8252 行的 “up to 1.7 PB/s Peak Theoretical Memory Bandwidth” 只用于确定理论峰值口径，不用 1.7 替换 1.67。读写方向仍未说明。

## 互联

| 项目 | 记录值 | 事实 ID | 证据定位 |
|---|---|---|---|
| scale-up 聚合带宽 | 260 TB/s；方向未说明，峰值/持续值未定义 | `FACT-M2W2-AMD-HELIOS-SCALEUP-BW` | Helios 快照 9058 |
| scale-out 带宽 | 43 TB/s；方向、有效载荷及峰值/持续值未定义 | `FACT-M2W2-AMD-HELIOS-SCALEOUT-BW` | Helios 快照 9068 |
| scale-up 协议 | UALink over Ethernet（UALoE） | `FACT-M2W2-AMD-HELIOS-SCALEUP-PROTOCOL` | Helios 快照 9058 |
| scale-out 网络 | Ethernet-based AMD Pensando networking | `FACT-M2W2-AMD-HELIOS-SCALEOUT-PROTOCOL` | Helios 快照 9068 |
| GPU 连接拓扑 | switched_fabric；原文为 UALoE multi-plane network with all-to-all GPU connectivity | `FACT-M2W2-AMD-HELIOS-SCALEUP-TOPOLOGY` | Helios 快照 10414 |

原文同时给出 “multi-plane network” 和 “all-to-all GPU connectivity”。卡片据前者规范为 `switched_fabric`，把后者保留为全互达描述；它不证明各 GPU 之间是完全图物理直连，也不补充单跳、无阻塞或有效载荷带宽等来源没有说明的性质。

## 架构复用，不在本卡复制

正式关系链为：Helios 通过 `OREL-AMD-HELIOS-CONTAINS-MI455X` 包含 `OBJ-AMD-MI455X`，MI455X 再通过 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 实现 `OBJ-AMD-CDNA5-ARCH`。CDNA 5 的执行、数据格式、内存层次和互联机制继续以正式架构卡及其事实链为准；本卡不把这些共性改写成 Helios 机架事实。

MI455X 独立产品页本轮没有固定，因为 Helios 的身份、72 数量和日期状态已经由对象匹配的 Helios、MI400 与 CES 来源覆盖。单模组容量、带宽、算力、功耗，以及由它们乘 72 得到的任何结果，都不进入本卡。

## 来源与当前缺口

最小来源草案包含三份材料：固定的 Helios 产品页负责身份、72 数量和大部分机架规格；固定的 MI400 页面保留 1.67 PB/s 机架内存带宽，并交叉核对 72；已有 CES 2026 固定新闻稿提供 2026-01-05 的 early-look 日期锚点和 3 AI exaflops 原词。两份新快照的哈希与本地定位见 `source-freeze-register.csv`。

这是一张轻量观察卡，尚未覆盖机架尺寸、重量、整机功耗、带宽方向与有效载荷、精度累加规则、软件版本或实际部署证据。缺口保持空白或条件说明，不用合作伙伴系统、单模组值或媒体报道补齐。