# Huawei Ascend 310 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡以一颗 2018 年发布的 Huawei Ascend 310 AI processor 为正式比较对象。Ascend 310 是采用 Da Vinci 架构的异构 inference SoC（System on Chip，片上系统），面向 device 与 edge 场景。Atlas 200 module、Atlas 300I inference card、edge station 和 appliance 是采用该芯片的上层产品，不是本卡主语；Ascend 310P、310B、310C 也不与原始 Ascend 310 合并。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Huawei（华为） | Ascend AI processor | `[1, p.33]` `[3, lines 431-433]` |
| 完整产品名 | Huawei Ascend 310 | 一颗 AI inference SoC，不是 Atlas 板卡 | `[1, pp.24 and 33]` `[4, Huawei's All-Scenario AI Chipset and Intelligent Computing Platform]` |
| 产品系列 | Ascend 310，内部配置名 Ascend-Mini | Da Vinci scalable architecture 的 edge-inference 实现 | `[1, p.33]` `[2, Table 1 and Table 5]` |
| 发布与状态 | 2018 年发布；Ascend 系列于 2018-10-10 的 Huawei Connect 2018 公布 | 2025 年华为再次确认 Ascend 310 于 2018 年发布；2019 年报记录基于该芯片的 Atlas 产品已在多行业部署。系列发布稿本身没有在当前正文中单列型号，因此不把 10 月 10 日写成已证实的 exact-SKU 日期 | `[3, lines 390-395 and 431-433]` `[5, opening]` `[2, Table 10]` `[8, p.34]` |
| 厂商定位 | 高能效 inference SoC，面向 terminal/device 与 edge 部署 | 产品定位不是具体 workload 实测 | `[1, p.33]` `[4, Huawei's All-Scenario AI Chipset and Intelligent Computing Platform]` |

本卡包含单芯片的 2 个 Da Vinci AI Core、8 个 Arm Cortex-A55 CPU core、片上存储、LPDDR4/LPDDR4X controller、PCIe/Gigabit Ethernet/USB、媒体编解码、12nm 工艺、8TFLOPS FP16、16TOPS INT8 与 8W 功耗。

本卡不包含 Atlas module/card/server 的板级显存容量、板卡功耗、外形、接口数量与多芯片聚合算力，也不把 Ascend 910、310P、310B、310C 的规格回填给 Ascend 310。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Da Vinci Ascend-Mini AI Core | 与同代 Da Vinci 系列共享 scalar/vector/cube/MTE 基本组织 | 复用 [Da Vinci 初代架构卡](../架构/Da_Vinci_初代架构.md)，本卡记录 Ascend 310 的 2-core 实现 | `[1, pp.9-10, 24 and 33]` `[2, pp.3-6]` |
| die / SoC | Ascend 310 heterogeneous inference SoC | 单一产品芯片 | 正式比较单位；die shot 标注 9.8mm×10.65mm，晶体管数未公开 | `[1, pp.24 and 40]` `[4, Huawei's All-Scenario AI Chipset and Intelligent Computing Platform]` |
| package | 未找到单芯片封装形式、尺寸或 pin 定义 | 上层 Atlas 产品采用不同 module/card 形态 | 不用 Atlas 200/300I 的外形代替芯片封装 | `[4, same section and Figure 2]` |
| 上层产品 | accelerator module、card、AI edge station 与 appliance | 多种部署形态可采用 Ascend 310 | 仅用于对象边界；不下放板级规格 | `[4, Figure 2 discussion]` `[7, p.12]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| AI Core 数量 | SoC 框图明确画出 2 个 Da Vinci AI Core | 单颗 Ascend 310 | `[1, p.24 AI Inference SoC]` |
| 执行组织 | AI Core 分为 scalar、vector、cube 与 MTE（Memory Transfer Engine，内存搬运引擎）路径；cube、vector 与 MTE 可通过独立队列并行 | 属于 Da Vinci Core 机制；不把路径名称解释为独立芯片 | `[1, pp.9 and 12]` `[2, pp.3-4]` |
| Cube | Da Vinci 架构示例采用 16×16×16 cube，图示为 4,096 个 FP16 MAC 与 8,192 个 INT8 MAC | HPCA 将该图明确为 Ascend-Max configuration，不能当作 Ascend 310 两个 core 的产品级物理单元数 | `[1, p.9]` `[2, p.2 Figure 1]` |
| Vector | 同一架构示例采用 2,048-bit INT8/FP16/FP32 vector，支持 activation、NMS、ROI 与 sort | 是架构路径证据，不是 Ascend 310 的独立 vector TOPS 或 SKU 配置 | `[1, p.9]` `[2, p.2 Figure 1]` |
| 数值路径 | FP16 cube 的两个源操作数为 FP16，destination 为 FP32；vector 支持 INT32、FP16、INT8 conversion | destination 类型不等于物理 accumulator 位宽 | `[2, pp.3-4]` |
| Core 本地存储 | Da Vinci 架构定义 L1、L0A、L0B、L0C、Unified Buffer 与 instruction cache | p.9 的 1MB、64KB、64KB、256KB、256KB 和 32KB 属于 Ascend-Max 图示配置，不能下放为 Ascend 310 的每-core 容量 | `[1, p.9]` `[2, p.2 Figure 1]` |
| MTE | 管理显式存储层次，承担 L1 与 L0/Unified Buffer 间搬运，并支持 zero decompression、img2col 与 transpose | software-managed 数据搬运，不是 hardware cache | `[1, p.9]` `[2, pp.3-4]` |
| Ascend-Mini 配置线索 | Table 5 把 Ascend-Mini 设计点列为 1GHz、8,192 FLOPS/cycle cube、256B vector width，L1 A/B/UB 带宽为 4/2/2TB/s；Ascend 310 LLC 为 96GB/s per core | 该设计点与双 AI Core、8TFLOPS 产品 headline 直接相乘会出现口径张力，因此不能据此确认 SKU 实际时钟或 per-core 峰值 | `[2, Table 5]` |
| 专用 LLM 单元缺口 | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache 管理模块 | 2018 年芯片面向 CNN 等 edge inference；不能把软件可实现等同于专用硬件 | `[1, pp.9-10 and 24]` `[2, pp.3-6]` |

## 4. Die、SoC 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 工艺 | 12nm | 单颗 Ascend 310；foundry、晶体管类型与具体 12nm 变体未公开 | `[1, p.33]` |
| Die 尺寸 | 9.8mm×10.65mm | die shot 直接标注；约 104.37mm² 是可复算面积，但不替代原始边长 | `[1, p.40]` |
| CPU 子系统 | 8 个 Arm Cortex-A55 CPU core、DSU，以及一个 A55 task scheduler | SoC 内控制/通用处理资源，不计入 AI peak | `[1, p.24]` |
| 片上互联 | 512-bit CHIE interconnect | 连接 AI Core、CPU、片上存储、DMA 与 I/O；拓扑、频率和持续带宽未公开 | `[1, p.24]` |
| SoC 共享存储 | 8MB on-chip buffer、3MB last-level cache | 与每 AI Core 的 L0/L1/Unified Buffer 分开 | `[1, p.24]` |
| 外部内存接口 | 2 个 LPDDR4X 64-bit controller，图示连接 2 颗 LPDDR4 chip | 单芯片内存容量、速率和总带宽取决于外接 memory，未在该页给定 | `[1, p.24]` |
| I/O | PCIe 3.0 RC/EP、1 至 4 lane；Gigabit Ethernet；USB 3.0 device；SPI flash 与 UART/I2C/SPI/GPIO | 单 SoC 端点；payload、持续带宽和同时启用方式未公开 | `[1, p.24]` |
| DMA 与低功耗控制 | 2 个 DMA engine、一个 low-power M3 | 不把 M3 算入 8 个 A55 CPU core | `[1, p.24]` |
| 封装缺口 | 未公开 package 类型、package 尺寸、重量和晶体管数 | die 边长已经公开，但不能从 die shot 反推 package | `[1, pp.24, 33 and 40]` |

## 5. 单芯片配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| FP16 峰值 | 8 TeraFLOPS | 单芯片厂商 headline；未说明 MAC 的 FLOP 计数和持续条件 | `[1, p.33]` |
| INT8 峰值 | 16 TeraOPS | 单芯片厂商 headline；不等于模型实测 | `[1, p.33]` `[4, same section]` |
| AI Core | 2 | SoC 框图直接计数 | `[1, p.24]` |
| CPU | 8×Arm Cortex-A55 | SoC 内 CPU cluster | `[1, p.24]` |
| 共享片上存储 | 8MB on-chip buffer、3MB LLC | 容量口径与 per-core L0/L1/UB 分开 | `[1, p.24]` |
| 外部内存 | 2×64-bit LPDDR4X controller | 容量、data rate、带宽和 ECC 未公开 | `[1, p.24]` |
| Host / network I/O | PCIe 3.0 RC/EP 1 至 4 lane；1GbE；USB 3.0 device | 没有公开 chip-to-chip AI scale-up fabric | `[1, p.24]` |
| 视频 | 16-channel H.264/H.265 decode；1-channel H.264/H.265 encode | 官方 headline；分辨率、帧率、bit depth 与 codec profile 未在 p.33 给定 | `[1, p.33]` |
| 其他媒体 | FHD video、JPEG/PNG codec | SoC 框图未给实例数和吞吐 | `[1, p.24]` |
| 功耗 | 8W；另一官方说明写 less than 8W | Hot Chips 规格页给 8W；ICT Insights 的文字使用“less than 8 watts”，测试电压、频率和 workload 未公开 | `[1, p.33]` `[4, same section]` |
| AI Core 实际时钟 | 未公开 | HPCA Table 5 的 1GHz 是 Ascend-Mini architecture design point，与产品 headline 存在未解释的计数张力，不作为 SKU clock | `[2, Table 5]` `[1, pp.24 and 33]` |

## 6. 系统级互联上下文

Ascend 310 的公开 SoC 框图只给 PCIe 3.0、Gigabit Ethernet、USB 和外部 LPDDR4/LPDDR4X 接口，没有给出类似 HCCS 的多芯片 scale-up 端点、domain size、拓扑或集合通信卸载。Atlas 200 module、Atlas 300I card、edge station 与 appliance 可以在产品层组合 Ascend 310，但这些形态的板级内存、I/O、功耗与多芯片数量不属于单芯片事实。[1, p.24] [4, Figure 2 discussion]

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| Ascend 310 与 310P/310B/310C | 型号边界明确 | CANN 文档分别列 Ascend 310、310P；后续产品名不是原始 310 的无条件同义词 | 只记录原始 2018 Ascend 310，不下放后续型号规格 |
| 功耗表述 | 官方资料有 8W 与 less than 8W 两种口径 | 2019 Hot Chips 与 Huawei ICT Insights | 主字段保留两个原始表述，不把它解释为固定 TDP 或实测平均功耗 |
| 产品峰值与 per-core 参数 | 计数口径存在直接张力 | 产品页给双 AI Core 和 8TFLOPS FP16/16TOPS INT8；HPCA Table 5 给 Ascend-Mini 1GHz、8,192 FLOPS/cycle design point | 采用产品级 headline；不据 Table 5 反推 SKU 时钟、per-core 峰值或芯片总峰值 |
| 外部内存 | 接口公开、配置未公开 | Hot Chips SoC 框图 | 不用 Atlas module/card 的容量和带宽代填单芯片 |
| 物理实现 | 部分公开 | 确认 12nm 与 9.8mm×10.65mm die | foundry、晶体管数、package 和 I/O 电气参数保持未公开 |
| 互联与一致性 | 部分公开 | PCIe/Gigabit Ethernet/CHIE 可见；多芯片 scale-up 与 cache-coherence 语义未给 | 不建立芯片间 AI fabric 或共享内存事实 |
| 专用 LLM 单元 | 未找到 | 两篇架构论文与官方产品材料 | attention、MoE router、top-k、sampling 和 KV Cache 管理保持未公开 |
| 当前销售状态 | 未找到 | 2018 发布稿、2021 论文、当前 CANN/支持文档与 2025 回顾 | 只确认发布和后续软件支持线索，不宣称仍在售或已停产 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Huawei，*DaVinci: A Scalable Architecture for Neural Network Computing*，Hot Chips 31，2019 | 华为官方架构演讲稿 | AI Core、SoC 框图、2-core 配置、存储/I/O、峰值、视频、功耗与工艺 | [本地 PDF](../../../原始资料/论文/华为昇腾_DaVinci/01_厂商直接架构论文/2019_DaVinci_Scalable_Architecture_HotChips31.pdf) |
| `[2]` | Heng Liao et al.，*Ascend: A Scalable and Unified Architecture for Ubiquitous Deep Neural Network Computing*，HPCA 2021 | 华为作者架构论文 | Ascend-Mini 设计点、执行/数值/存储机制、per-core 带宽和 2018 release year | [本地 PDF](../../../原始资料/论文/华为昇腾_DaVinci/01_厂商直接架构论文/2021_Ascend_Scalable_Unified_Architecture_HPCA.pdf) |
| `[3]` | Huawei，*Huawei Releases AI Strategy*，2018-10-10 | 官方发布稿 | Ascend 系列发布日与全栈定位 | <https://e.huawei.com/es/news/ebg/201810101135> |
| `[4]` | Huawei，*Huawei's All-Scenario AI Chipset and Intelligent Computing Platform*，ICT Insights | 官方企业刊物 | Ascend 310 的 SoC、单芯片 16TOPS INT8、低于 8W、device/edge 定位与上层产品边界 | <https://e-file.huawei.com/-/media/EBG/Download_Files/Publications/en/ICT25-en.pdf> |
| `[5]` | Huawei，*Groundbreaking SuperPoD Interconnect: Leading a New Paradigm for AI Infrastructure*，2025 | 官方主题演讲 | 回顾 Ascend 310 于 2018 年发布 | <https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech> |
| `[6]` | Huawei Ascend Community，*aclgrphBuildInitialize Supported Configuration Parameters*，CANN 6.0.1 | 官方开发文档 | 当前文档将 Ascend 310、Ascend 310P 与 Ascend 910 分开列为 SoC target | <https://www.hiascend.com/document/detail/zh/canncommercial/601/inferapplicationdev/graphdevg/graphdevg_geapi_0101.html> |
| `[7]` | Huawei，*AI系统的安全治理实践白皮书* | 官方回顾资料 | 2018 年发布 Ascend 310 及 module/card/edge-station 推理产品边界 | <https://www-file.huawei.com/-/media/corp2020/pdf/trust-center/a_look_at_effective_ways_for_ai_system_security_and_privacy_cn.pdf> |
| `[8]` | 华为投资控股有限公司，*华为 2019 年年度报告* | 官方年度报告 | Ascend 310 的 inference-chip 定位及基于它的 Atlas 产品商用部署 | <https://www-file.huawei.com/-/media/corporate/pdf/annual-report/annual_report_2019_cn.pdf?la=zh> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/SoC、package、产品和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、外部内存和管理语义没有混写
- [x] 片上互联、Host I/O、设备互联和上层产品边界已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：Huawei Ascend 310 的正式比较对象是一颗 2018 年发布、采用 12nm 工艺的 Da Vinci Ascend-Mini inference SoC。芯片级 8TFLOPS FP16、16TOPS INT8、8W、2 个 Da Vinci AI Core、8 个 Cortex-A55 CPU core、8MB on-chip buffer、3MB LLC、双 64-bit LPDDR4X controller、PCIe 3.0、Gigabit Ethernet 与视频编解码均有华为一手资料支持。产品 headline 与 per-core design point 的运算计数口径没有被强行合并；Atlas 上层产品和后续 Ascend 310 系列型号的规格也没有下放。外部内存配置、封装、晶体管数、多芯片互联、当前销售状态和专用 LLM 单元保持未公开。
