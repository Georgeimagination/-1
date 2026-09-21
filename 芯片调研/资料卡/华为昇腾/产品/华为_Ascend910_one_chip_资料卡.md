# Huawei Ascend 910 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡以一颗 2019 年正式发布的 Huawei Ascend 910 AI training processor 为比较对象。该产品采用 Da Vinci Ascend-Max 架构，是由 compute die、I/O die、4 个 HBM stack 和 2 个 dummy die 共同集成的多 die package。Atlas training card、8-chip server、Atlas 900 cluster，以及后续 Ascend 910A、910B、910C 都不是本卡主语。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Huawei（华为） | Ascend AI processor | `[1, pp.25 and 33]` `[4, p.34]` |
| 完整产品名 | Huawei Ascend 910 | 单颗 AI training processor | `[1, p.33]` `[4, p.34]` |
| 架构配置 | Da Vinci Ascend-Max | 32 个 Ascend-Max AI Core | `[1, pp.25 and 33]` `[2, pp.6-7]` |
| 首次预告 | 2018 年 Ascend 系列发布时公布设计目标 | 2018 发布稿是系列层信息；正式芯片在 2019 年发布 | `[5, Huawei's full-stack, all-scenario AI portfolio]` `[6, opening]` |
| 正式发布 | 2019-08-23 | 与 MindSpore 同日正式发布；华为 2019 年报和 2025 年主题演讲再次确认 2019 release year | `[6, opening]` `[4, p.34 and p.63]` `[7, Chips are the building blocks]` |
| 厂商定位 | 面向 AI model training，并提供片上视频预处理能力 | 训练定位不表示只支持训练或所有模型性能相同 | `[1, pp.25 and 33]` `[4, p.34]` |
| 当前状态 | 已发布并通过 Atlas 部件、系统和云服务部署；原始 910 的当前销售与 EOL 状态未公开 | 华为 2019 年计算战略说明处理器不直接对外销售，而以云服务和部件承载；当前文档仍把 910 与 910B 分开列为软件包目标 | `[4, pp.49 and 63]` `[9, Four measures]` `[8, software list]` |

本卡包含单 package 的 32 个 AI Core、16 个 Armv8 CPU core、compute/I/O die、4 个 HBM stack、32MB on-chip buffer、NoC、理论峰值、HBM 带宽、视频解码、工艺、die 面积与功耗。

本卡不包含 8-chip server、Atlas training card、Atlas 900 cluster 或 cloud service 的聚合算力、内存、互联、主机 CPU、网络、供电和散热，也不使用 910A/B/C 的参数补齐原始 910。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Da Vinci Ascend-Max AI Core | 与同代 Da Vinci 系列共享 scalar/vector/cube/MTE 基本组织 | 复用 [Da Vinci 初代架构卡](../架构/Da_Vinci_初代架构.md)，本卡记录 32-core 实现 | `[1, pp.9-10, 25 and 33]` `[2, pp.3-7]` |
| compute die | Vitruvian，456mm²，7+nm EUV | Ascend 910 的计算 chiplet | 集成 32 个 Ascend-Max core、16 个 Armv8 CPU core、AI/CPU LLC 与 DVPP | `[1, pp.25 and 37]` `[2, pp.6-7 and Table 7]` |
| I/O die | Nimbus V3，168mm²，16nm | Ascend 910 的 I/O chiplet | 连接 network、PCIe、CCIX、扩展板接口与 compute die；公开资料未给各端点单芯片带宽 | `[1, pp.25 and 37]` `[2, Table 7]` |
| package | Vitruvian、Nimbus、4 个 HBM die 与 2 个 dummy die，共 8 die integrated | 单个 Ascend 910 package | 6 个功能 die 加 2 个机械均衡 dummy die；不把 4 个 HBM 当作 4 颗产品 | `[1, p.37]` `[2, pp.6-7]` |
| 上层产品 | training card、8-chip server、Atlas 900 与 cloud service | 多芯片系统 | 只用于互联边界，不下放系统聚合值 | `[1, pp.35-36]` `[2, PDF p.8 / proceedings p.796]` `[4, p.49]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| AI Core 数量 | compute die 集成 32 个 Ascend-Max core | 单颗 Ascend 910；4 组各 8 core | `[1, p.25]` `[2, pp.6-7]` |
| 执行组织 | 每个 Da Vinci core 分为 scalar、vector、cube 与 MTE（Memory Transfer Engine，内存搬运引擎）路径，独立队列可并行工作 | 属于共享架构机制 | `[1, pp.9 and 12]` `[2, pp.3-4]` |
| Cube | 16×16×16 cube，4,096 个 FP16 multiplier 与 4,096 个 accumulator；INT8 可扩展为 16×32×16 | 是 Ascend-Max 配置；程序员可见 FP16 source 与 FP32 destination 不等于已公开物理 accumulator 位宽 | `[1, p.9]` `[2, p.3 Figure 2 and Table 4]` |
| Vector | 2,048-bit INT8/FP16/FP32 vector，支持 activation、NMS、ROI 与 sort | 不从 vector width 推导单独 TOPS | `[1, p.9]` |
| 数值路径 | FP16 cube 的两个 source 为 FP16、destination 为 FP32；vector 支持 INT32、FP16、INT8 conversion | 舍入、饱和与物理累加语义未公开 | `[2, pp.3-4]` |
| MTE | 管理 L1、L0A/L0B/L0C 与 Unified Buffer 间显式搬运，支持 zero decompression、img2col 和 transpose | software-managed 数据搬运，不是 hardware cache | `[1, p.9]` `[2, pp.3-4]` |
| Core 本地存储 | Ascend-Max 图示给 L1 1MB、L0A 64KB、L0B 64KB、L0C 256KB、Unified Buffer 256KB、instruction cache 32KB | 每 core 配置；单位按来源 KB/MB 保留 | `[1, p.9]` `[2, p.2 Figure 1]` |
| Ascend-Max 设计点 | 1GHz、8,192 FLOPS/cycle cube、256B vector width；L1 A/B/UB 带宽为 4/2/2TB/s；Ascend 910 LLC bandwidth 为 94GB/s per core | architecture design point；不另行重算总峰值 | `[2, Table 5]` |
| 专用 LLM 单元缺口 | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache 管理模块 | 相关工作可由通用路径与软件执行，但不能据此宣称专用硬件 | `[1, pp.9-10 and 25]` `[2, pp.3-7]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| Compute die | Vitruvian，456mm²，7+nm EUV | 32 个 AI Core、16 个 custom Armv8 CPU core、AI LLC、CPU LLC、DVPP 与 mesh NoC | `[1, pp.25 and 37]` `[2, pp.6-7 and Table 7]` |
| I/O die | Nimbus V3，168mm²，16nm | network、PCIe、CCIX、IMU、HAC 与 extended Da Vinci board interface | `[1, pp.25 and 37]` `[2, Table 7]` |
| HBM | 4 个 HBM 2.0 stack/die，每个 HBM 区域标注 96mm² | 相邻段落分别使用 die 和 stack；4 个合计 1.2TB/s，容量未在两篇架构来源中给定 | `[1, pp.25 and 37]` `[2, pp.6-7]` |
| Dummy die | 2 个，每个 110mm² | 用于 mechanical uniformity，没有计算、存储或 I/O 功能 | `[1, p.37]` |
| 集成面积口径 | 456 + 168 + 4×96 + 2×110 = 1,228mm² | 是 8 个集成 die 的面积求和，不是 package footprint、interposer 面积或单一裸片面积 | `[1, p.37]` |
| 片上共享存储 | 32MB on-chip buffer；compute die 含 AI LLC 与 CPU LLC | p.25 未进一步给 bank、相联度和延迟 | `[1, p.25]` `[2, p.6]` |
| NoC | 4×6 2D mesh；相邻节点为 2GHz、1,024-bit，给出 256GB/s；全芯片到 L2 和 HBM throughput 分别为 4TB/s 与 1.2TB/s | bufferless NoC；256GB/s 是相邻节点 link 的计算口径，不是芯片外带宽 | `[2, pp.6-7]` |
| 封装缺口 | package 类型、外形尺寸、interposer/基板和晶体管数未公开；两篇架构来源未列 HBM 容量，32GB 另有 ModelZoo 配置证据 | 不由 1,228mm² die-area sum 反推 package 面积 | `[1, p.37]` `[2, pp.6-7]` |

## 5. 单芯片配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| FP16 峰值 | 256TFLOPS | 单芯片 peak；未说明 MAC 的 FLOP 计数与持续条件 | `[1, p.33]` `[4, p.34]` |
| INT8 峰值 | 512TOPS | 单芯片 peak；不等于模型实测 | `[1, p.33]` `[4, p.34]` |
| AI Core | 32×Ascend-Max | 单 compute die | `[1, p.25]` `[2, pp.6-7]` |
| CPU | 16×custom Armv8 core | compute die 内 CPU cluster；不计入 AI peak | `[1, p.25]` `[2, p.6]` |
| HBM | 4×HBM stack，1.2TB/s aggregate bandwidth；官方 ModelZoo 的 8-NPU 环境写 Ascend 910 32GB×8 | 32GB 是华为官方运行环境的 per-NPU 配置佐证，架构论文只直接确认 4 stack 与带宽；Hot Chips 框图明确标注 HBM 2.0；ECC 和持续带宽未公开 | `[1, p.25]` `[2, pp.6-7 and Table 7]` `[10, Before You Start: Test Notes]` |
| Cache / buffer | 32MB on-chip buffer；LLC 94GB/s per AI Core；全芯片 to-L2 throughput 4TB/s | 32MB 产品级容量与 per-core/local buffer 分开；94GB/s 与 4TB/s 的定义层级不同 | `[1, p.25]` `[2, Table 5 and p.7]` |
| NoC | 4×6 mesh；2GHz、1,024-bit adjacent link | 公开 256GB/s link 口径；不写成外部 HCCS 带宽 | `[2, pp.6-7]` |
| I/O | network、PCIe、CCIX 与 extended Da Vinci board interface | 单芯片端点存在；lane 数、版本、带宽和同时启用方式未公开 | `[1, p.25]` |
| 视频 | 128-channel full-HD H.264/H.265 decoder | 分辨率、帧率与 codec profile 未在 headline 中展开 | `[1, p.33]` `[2, p.7]` |
| 功耗 | 最大功耗 310W | 华为 2019 年报的产品口径；Hot Chips 写 350W，HPCA 论文写 rated TDP 300W，差异单列于第 7 节 | `[4, p.34]` `[1, p.33]` `[2, p.7 and Table 7]` |
| 工艺 | compute die 7+nm EUV；I/O die 16nm | 不把 compute 节点写成全 package 单一工艺 | `[2, Table 7]` `[1, pp.33 and 37]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 8-chip server | 每台 server 含 8 个 Ascend 910，分成两组，每组 4 颗 | 不是一颗芯片；2PFLOPS、系统内存、主机 CPU 与 6,000W 都是 server 值 | `[1, p.35]` `[2, PDF p.8 / proceedings p.796]` |
| Intra-group | 4-chip group 采用 HCCS（Huawei Cache Coherence System） | 论文给 30GB/s，但未说明是否 per-link、per-chip 或 group aggregate，不能下放为芯片端点铭牌 | `[2, PDF p.8 / proceedings p.796]` |
| Inter-group | 两个 4-chip group 通过 PCIe 通信 | 论文给 32GB/s，属于 server inter-group 连接 | `[2, PDF p.8 / proceedings p.796]` |
| Cluster | Atlas 900 由数千颗 Ascend processor 组成，华为云也提供 Ascend cluster service | cluster aggregate 与 ResNet-50 训练时间不进入 SKU 卡 | `[4, p.49]` `[9, Atlas 900 section]` |

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| 原始 910 与 910A/B/C | 型号边界明确 | 当前 software download 将 910 与 910B 分列；2025 主题演讲把 910C 单独命名 | 只记录 2019 原始 Ascend 910，不用后续型号或 Atlas A2/A3 产品规格补齐 |
| 功耗 | 官方一手资料存在三种口径 | 2019 年报写 maximum 310W；2019 Hot Chips 写 350W；2021 HPCA 写 rated TDP 300W | 主字段采用年度报告的 maximum 310W，同时完整保留技术资料差异，不把三者当作同一测试条件 |
| 功能 die 与总 die 数 | 统计范围不同 | HPCA 说 training SoC 有 6 个功能 die；Hot Chips package 页说 8 die integrated | 记录 6 个功能 die，再单列 2 个 mechanical dummy die，二者不冲突 |
| HBM 容量 | 间接官方配置证据为 32GB | ModelZoo 运行环境直接写 Ascend 910 32GB×8；架构论文未在芯片规格段列容量 | 记录 32GB，并明确它来自 per-NPU server environment，而不是独立 datasheet |
| 外部互联 | 端点类别部分公开 | 芯片框图列 network/PCIe/CCIX/extension；server 论文给 HCCS/PCIe group connection | 不把 server bandwidth 当作单芯片端点铭牌 |
| 物理实现 | 部分公开 | compute/I/O/HBM/dummy die 数量、面积与工艺可确认 | package footprint、interposer、基板、晶体管数保持未公开；32GB 限定为 ModelZoo 环境配置证据 |
| 数值与稀疏 | 部分公开 | FP16/INT8 peak、FP16 source/FP32 destination 可确认 | BF16/FP32/INT4 product peak、structured-sparsity peak、物理 accumulator 位宽与舍入保持未公开 |
| 专用 LLM 单元 | 未找到 | 两篇架构论文与官方产品材料 | attention、MoE router、top-k、sampling 和 KV Cache 管理保持未公开 |
| 当前销售状态 | 未找到 | 2019 年报、当前 software list 与 2025 路线图演讲 | 只确认已发布、曾部署与软件目标仍可识别，不宣称当前在售或 EOL |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Huawei，*DaVinci: A Scalable Architecture for Neural Network Computing*，Hot Chips 31，2019 | 华为官方架构演讲稿 | AI training SoC、32 core、package/die、算力、视频、功耗和服务器边界 | [本地 PDF](../../../原始资料/论文/华为昇腾_DaVinci/01_厂商直接架构论文/2019_DaVinci_Scalable_Architecture_HotChips31.pdf) |
| `[2]` | Heng Liao et al.，*Ascend: A Scalable and Unified Architecture for Ubiquitous Deep Neural Network Computing*，HPCA 2021 | 华为作者架构论文 | Core、SoC/package、NoC、HBM/cache、工艺、面积、功耗和 server topology | [本地 PDF](../../../原始资料/论文/华为昇腾_DaVinci/01_厂商直接架构论文/2021_Ascend_Scalable_Unified_Architecture_HPCA.pdf) |
| `[3]` | Huawei Cloud，*HCIA-AI V3.0 Training Material* | 华为官方培训材料 | 256TFLOPS FP16、512TOPS INT8、310W 与 training 定位复核 | <https://res-static.hc-cdn.cn/cloudbu-site/intl/en-us/HCEDU/Certification%20Materials/HCIA-AIV3.0TrainingMaterial.pdf> |
| `[4]` | 华为投资控股有限公司，*华为 2019 年年度报告* | 官方年度报告 | 训练定位、峰值、maximum 310W、发布与 Atlas 900/云服务部署 | <https://www-file.huawei.com/-/media/corporate/pdf/annual-report/annual_report_2019_cn.pdf?la=zh> |
| `[5]` | Huawei，*Huawei Releases AI Strategy*，2018-10-10 | 官方发布稿 | Ascend 系列预告与全栈定位 | <https://e.huawei.com/cn/news/ebg/201810101135> |
| `[6]` | Huawei，*Huawei launches Ascend 910 and MindSpore*，2019-08-23 | 华为区域新闻稿镜像 | Ascend 910 正式发布日期 | <https://kommunikasjon.ntb.no/pressemelding/17869431/huawei-launches-ascend-910-the-worlds-most-powerful-ai-processor-and-mindspore-an-all-scenario-ai-computing-framework?publisherId=17847024> |
| `[7]` | Huawei，*Groundbreaking SuperPoD Interconnect: Leading a New Paradigm for AI Infrastructure*，2025 | 官方主题演讲 | 回顾 Ascend 910 于 2019 年发布，并区分 910C | <https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech> |
| `[8]` | Huawei Support，*Series Ascend Computing Patch Software Download* | 官方支持页面 | 910 与 910B 独立 software target | <https://support.huawei.com/enterprise/zh/ascend-computing/computing-pid-23710424/software/261964445> |
| `[9]` | Huawei，*Huawei announces computing strategy and releases Atlas 900*，2019-09-18 | 官方发布稿 | Atlas 900 cluster 与单芯片边界 | <https://www.huawei.com/en/news/2019/9/huawei-computing-strategy-atlas-900-ai-training-cluster> |
| `[10]` | Huawei Ascend ModelZoo，*YOLOv3* | 官方运行环境资料 | Atlas 800 的 8 个 Ascend 910 分别配置 32GB memory | <https://www.hiascend.com/en/software/modelzoo/models/detail/2/7b5f73072a24453389602051affe9b31> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、compute/I/O die、package、产品和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、HBM 与管理语义没有混写
- [x] 片上 NoC、芯片 I/O、设备互联和系统聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：Huawei Ascend 910 的正式比较对象是一颗 2019 年发布的 Da Vinci Ascend-Max training processor。单 package 的 32 个 AI Core、16 个 Armv8 CPU core、456mm² 7+nm compute die、168mm² 16nm I/O die、4 个 HBM stack、2 个 dummy die、256TFLOPS FP16、512TOPS INT8、1.2TB/s HBM bandwidth、32MB on-chip buffer、mesh NoC 与视频解码均有华为一手资料支持。华为官方运行环境另给出每颗 Ascend 910 32GB 的配置证据。功耗资料分别出现 maximum 310W、rated TDP 300W 和 350W，主字段采用年度报告的 310W 并保留差异。8-chip server 与 Atlas 900 的聚合值没有下放。package footprint、晶体管数、端点级外部互联带宽、更多数值格式和专用 LLM 单元保持未公开。
