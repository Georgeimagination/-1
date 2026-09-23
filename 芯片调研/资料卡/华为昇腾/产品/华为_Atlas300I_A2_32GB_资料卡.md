# Huawei Atlas 300I A2 32GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：调研中（保留原状态；指南独有字段已补核）  
> 资料截止日：2026-09-23
> 复核范围：产品页、官方彩页、虚拟化附录与已保存的用户指南 03 原文已交叉核对；处理器数量、TaiShan 命名、PCI IDs、PCIe x16、功耗档位及重量已有直接原文支持。准确处理器子型号、die/package 组织及内部存储规格仍未公开。

本卡以一块配备 32GB HBM 的 Huawei Atlas 300I A2 inference card 为正式比较对象。它是双槽、全高全长的 PCIe 加速卡，面向服务器内 AI inference。64GB HBM 配置是同一产品名下的另一官方 SKU；Atlas 300I、300I Pro、300I Duo、Atlas 800I A2 server 和 A2 training products 均不与本卡合并。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Huawei（华为） | Atlas inference product | `[1, full page]` `[2, p.1]` |
| 完整 SKU | Huawei Atlas 300I A2 32GB | 当前产品页同时列 32GB 与 64GB，容量是区分本卡的正式配置字段 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 对象形态 | 双槽、全高全长 PCIe card | 安装在 server，不是独立 server、drawer 或 node | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 产品定位 | AI inference card，面向生成式模型推理、推荐、搜索与内容审核；用户指南明确只支持 AI 推理任务，不支持训练任务 | 产品用途范围，不是 benchmark | `[1, opening and features]` `[2, Application Scenarios]` `[5, 概述]` |
| 发布与当前状态 | 当前华为企业产品目录列出并提供项目咨询，昇腾支持文档仍单列该卡；首次发布日未找到 | 可确认当前商用咨询与软件支持状态，不能由网页存在反推首批 shipment 日期 | `[1, full page]` `[3, applicable hardware]` |

本卡包含 32GB HBM、0.8TB/s、AI/CPU 峰值、媒体能力、PCIe 5.0、350W 最大功耗、被动风冷、温度与卡尺寸。

本卡不包含 64GB 配置的 1.6TB/s，也不包含 server drawer 的风扇数量、主机 CPU、系统内存、网络、整机功耗和多卡聚合性能。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 32GB 物理卡报告 20/20 个可用 AI Core；内部执行组织和实际时钟未公开 | 32GB 与 64GB 配置共享 card-level peak headline，但可切分资源表按 SKU 分列 | 不用原始 Ascend 910、910B 的第三方参数反推单 core 结构 | `[4, Appendix: Querying specifications of a single NPU card, Table 2]` |
| accelerator processor | 1×官方统称的“910 AI 处理器”，集成 20 个 AI Core 和 8 个 TaiShan Core | exact submodel、die 数与工艺未公开 | 用户指南 03 已确认处理器数量与核心数量；不借用相邻 910 子型号参数 | `[5, 系统框图、表3-1]` |
| package / board | 双槽全高全长 PCIe board，板上 HBM | 32GB 与 64GB SKU 共享外形、峰值与最大功耗字段 | 正式比较单位 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 相关系统 | server drawer | 上层 host/cooling environment | 产品页的 5 个 hot-swappable fan modules、4+1 redundancy 属于 drawer，不是卡载风扇 | `[1, Fan and form factor]` |

## 3. Core 微架构

官方虚拟化资源表给 32GB 物理卡列出 20/20 个可用 AI Core，但 exact-SKU 产品页和彩页没有公开 Matrix/Vector/Scalar 组织、L0/L1/L2/Unified Buffer 容量、程序员可见累加格式、物理 accumulator 位宽、结构化稀疏机制或内部 data mover。560TOPS INT8、280TFLOPS FP16 和 75TFLOPS FP32 不能反推出单 core 吞吐或时钟。[1, Technical Specifications] [2, Product Specifications] [4, Appendix Table 2] 用户指南系统框图明确说明处理器提供 Cache、图形/视频加速器与 I/O 资源，但没有给出 Cache 的层级、容量、带宽或延迟。[5, 系统框图]

未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache management 物理模块的一手证据。厂商把该卡用于 generative AI inference，不等于它具有这些专用单元。[1, opening] [2, Application Scenarios]

## 4. Processor、package 与 board

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| Board form factor | 双槽、全高全长 PCIe card | 不是 low-profile card 或 OAM module | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 尺寸 | 长 266.7mm×宽 39.04mm×高 111.15mm | 用户指南与彩页明确长×宽×高；产品页表头的方向命名存在差异，以指南为准 | `[2, Product Specifications]` `[5, 表3-1]` |
| Card cooling | 被动风冷 | 卡本身不含主动风扇字段；需要 server airflow | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 工作温度 | 5°C 至 45°C | 海拔降额、湿度、气流和器件温度条件见第 4.1 节 | `[5, 表3-2、表3-3、表3-4、表3-5]` |
| Processor / die | 1×910 AI 处理器，20 AI Core、8 TaiShan Core | 用户指南给出的通用处理器名称；exact submodel、die/package、工艺、面积和晶体管数未公开 | `[5, 系统框图、表3-1]` |
| HBM physical organization | 未公开 stack 数、bus width、memory clock 或 package topology | 只记录 card/SKU 的 capacity、bandwidth 与 ECC | `[1, Technical Specifications]` |

### 4.1 供电、散热与管理条件

两种容量配置均适用 300W/350W 最大功耗档位，档位由 12V HPWR 感知线确定。S4 接地时为 350W，悬空时为 300W；S3 的两种状态不改变该结果。主板未连接 S1 至 S4 时，默认最大 300W。PCIe 槽位要求提供 5.5A@12V 和 0.5A@3.3V，辅助连接器要求提供 27A@12V。这些是供电条件，不是任务实测功耗，也不能把两档分别绑定到两种 HBM 容量。[5, 电源管理]

卡支持双向进出风，需由服务器主动送风；只要卡处于上电状态，就需要至少 5.0CFM 气流。CFM 表示每分钟立方英尺。表中工作点为建议最低风量及其压降，仍须在实际服务器中验证。[5, 散热要求、表3-3、表3-4]

| 进风口平均温度 | 300W 风量 / 压降 | 350W 风量 / 压降 |
|---|---|---|
| 25°C | 13.1CFM / 64Pa | 17.5CFM / 98Pa |
| 30°C | 14.4CFM / 73Pa | 20.6CFM / 126Pa |
| 35°C | 17.2CFM / 95Pa | 25.3CFM / 177Pa |
| 40°C | 21.5CFM / 136Pa | 31.7CFM / 259Pa |
| 45°C | 27.4CFM / 202Pa | 39.7CFM / 383Pa |

AI 芯片与存储芯片的降频温度均为 105°C，长期工作温度均须不高于 105°C；下电温度分别为 115°C 和 110°C。工作湿度为非冷凝 8%RH 至 90%RH，工作海拔不高于 3050m；高于 900m 后，ASHRAE A1/A2、A3、A4 配置的最高工作温度分别按海拔每升高 300m、175m、125m 降低 1°C。[5, 表3-2、表3-5]

服务器 iBMC（智能基板管理控制器）可通过板上 MCU（微控制器）读取 PCB/BOM 版本、温度、功耗和电源电压；指南支持带内在线升级及带内、带外状态与资产查询。卡不支持通知式或暴力热插拔。产品概述确认支持安全启动，但没有披露本卡信任根、密钥和验证链细节。[5, 系统框图、可维护性特点、热插拔、概述]

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| INT8 峰值 | 560TOPS | 最高 card-level theoretical compute；未说明 dense/sparse、MAC 计数与持续条件 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| FP16 峰值 | 280TFLOPS | 最高 card-level theoretical compute；未说明 accumulator 与 sparsity condition | `[1, Technical Specifications]` `[2, Product Specifications]` |
| FP32 峰值 | 75TFLOPS | 官方彩页列出，当前产品网页规格表未显示该行 | `[2, Product Specifications]` |
| CPU | 8×TaiShan Core，2.0GHz | TaiShan 命名和数量来自指南，频率来自彩页；不是 AI Core 频率，CPU cache 与持续频率条件未公开 | `[2, Product Specifications]` `[5, 表3-1]` |
| 可用加速资源 | 20 AI Core、7 AI CPU、9 VPC、2 VDEC、24 JPEGD、4 JPEGE；VENC 为 0，PNGD 不适用 | 官方 physical-card resource query；7 AI CPU 是可切分资源数，不替代产品页的 8-core physical CPU field | `[4, Appendix: Querying specifications of a single NPU card, Table 2]` |
| HBM | 32GB、800GB/s（产品页写 0.8TB/s）、ECC | 本卡正式 SKU；不采用 64GB SKU 的 1.6TB/s | `[1, Technical Specifications]` `[2, Product Specifications]` |
| Host interface | PCIe 5.0 x16 | 用户指南已确认代际与 lane 数；持续 payload 带宽、CXL、P2P 和 SR-IOV 未公开 | `[5, 表3-1]` |
| PCI identity | Vendor ID 0x19E5、Device ID 0xD802、Subsystem Vendor ID 0x19E5、Subsystem Device ID 0x4000 | 0x4000 对应 32GB，0x4001 对应 64GB；不能据此反推芯片子型号 | `[5, 表3-1]` |
| 功耗 | 300W/350W 可配置最大功耗，最高 350W | 由 12V HPWR 感知线选择，不按容量分档；供电和散热条件见第 4.1 节 | `[1, Technical Specifications]` `[2, Product Specifications]` `[5, 表3-1、电源管理]` |
| 散热 | 被动风冷 | server 需要提供 airflow；产品页另列 drawer-level 5 个 hot-swappable fan module、4+1 redundancy | `[1, Technical Specifications]` |
| 视频解码 | 1080p 480FPS equivalent | codec、bit depth、profile 与并发 stream 条件未在彩页表格中展开 | `[2, Product Specifications]` |
| JPEG 解码 | 1080p 12,288FPS equivalent；分辨率 32×32 至 16,384×16,384 | 最高等效吞吐，未说明图像质量与持续条件 | `[2, Product Specifications]` |
| JPEG 编码 | 1080p 1,024FPS equivalent；分辨率 32×32 至 8,192×8,192 | 最高等效吞吐 | `[2, Product Specifications]` |
| 硬切分 | 32GB SKU 已验证 1-to-2 与 1-to-4 inference partition | 代表模板包括 10 AI Core/16GB 和 5 AI Core/8GB；不同模板分配的 AI CPU 与媒体资源不同 | `[4, Section 1.3 and Appendix Table 2]` |
| 重量 | 1.32kg | 单卡，不含服务器包装 | `[5, 表3-1]` |

### 5.1 虚拟化资源分配

vNPU 是从物理 NPU 硬切分出的虚拟实例。下表为本容量 SKU 的官方模板，资源数属于软件可分配额度；VPC 是图像预处理、VDEC 是视频解码，JPEGD/JPEGE 是 JPEG 解码/编码。所有模板的 PNGD 和 VENC 均为 0。[4, 附录“查询切分模板”表2]

| 单个 vNPU 模板 | AI Core | 内存 / GB | AI CPU | VPC | VDEC | JPEGD | JPEGE |
|---|---:|---:|---:|---:|---:|---:|---:|
| `vir10_3c_16g` | 10 | 16 | 3 | 4 | 1 | 12 | 2 |
| `vir10_4c_16g_m` | 10 | 16 | 4 | 9 | 2 | 24 | 4 |
| `vir10_3c_16g_nm` | 10 | 16 | 3 | 0 | 0 | 0 | 0 |
| `vir05_1c_8g` | 5 | 8 | 1 | 2 | 0 | 6 | 1 |

`vir10_4c_16g_m` 取得整卡全部可分配的媒体资源，而 `vir10_3c_16g_nm` 不分配媒体资源；两者仍都是 10 AI Core、16GB。不能把半卡模板理解成每种资源都减半。[4, 附录“查询切分模板”表2]

该实践的配套版本为 HDK 25.5.0 与 CANN 9.0.0-beta.1，硬切分仅支持推理场景。一个推理服务只能绑定一张 vNPU，同一模型不能混用物理 NPU 和 vNPU；切分后不能再把整张物理卡挂载到容器，也不支持不同规格标卡混插进行该虚拟化。这些条件限定多模型部署方式，不能据此确认 SR-IOV。[4, §1.3、§2.1、§2.2]

## 6. 系统级互联上下文

Atlas 300I A2 是 host-attached PCIe card。当前 DMI 文档说明该卡只支持查询 PCIe signal quality；HCCS 和 RoCE 是其他 A2 server/product 的链路类型，不应写成本卡互联端点。[3, eye-diagram parameters]

产品页把“每个 drawer 集成 5 个 hot-swappable fan module，支持 4+1 redundancy”列在同一技术规格区，但卡的 cooling 字段明确为 passive air cooling。因此风扇数量是 server drawer 的冷却上下文，不是单卡上的 5 个风扇。[1, Fan and Cooling]

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| 32GB 与 64GB | 同一产品名下的两个 official configuration | 32GB 为 0.8TB/s；64GB 为 1.6TB/s，其他 card-level headline 在同一表中共用 | 本卡只采用 32GB/0.8TB/s，64GB 另建 SKU 卡 |
| FP32 峰值 | 官方页面披露粒度不同 | 彩页列 75TFLOPS；当前网页规格表只列 INT8/FP16 | 保留彩页的 75TFLOPS，并注明来源差异 |
| PCIe | 代际和 lane width 均有直接原文 | 用户指南 03 表3-1写 PCIe x16 Gen5.0 | 采用 PCIe 5.0 x16，不将接口线速当作持续 DMA 吞吐 |
| Cooling | card 与 drawer 层级并列 | card 为 passive air cooling；5-fan 4+1 redundancy 是 drawer | 不把 system fan count 写成 card fan |
| Accelerator processor | 单芯片和 core 数已公开，exact submodel/package 未公开 | 用户指南写 1×Ascend 910、20 AI Core、8 TaiShan Core | 不用 910B4 software/reporting name 或第三方拆解补写工艺和 die 细节 |
| 数值格式与稀疏 | 仅峰值可确认 | INT8、FP16、FP32 headline | dense/sparse、BF16/FP8/INT4、累加格式、舍入和物理 accumulator 保持未公开 |
| 存储层级 | HBM 和 Cache 的存在均可确认；内部层级规格未公开 | 用户指南系统框图说明处理器提供 Cache，表3-1给 HBM 容量/带宽/ECC | 不由 HBM 值反推 stack、bus width、cache 容量或 processor package |
| 虚拟化、RAS 与安全 | 硬切分模板、HBM ECC 与安全启动已确认 | 32GB SKU 模板见第 5.1 节；安全启动来自用户指南“概述” | 不将硬切分等同于 SR-IOV；ECC 粒度、page retirement、信任根和安全验证链仍未公开 |
| 发布日期与首批出货 | 未找到 | 当前产品页、彩页和支持文档 | 只记录当前官方列出的 product configuration |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Huawei，*Atlas 300I A2* | 当前官方产品页 | 身份、两种容量、峰值、HBM、PCIe、功耗、散热、温度、尺寸与 drawer 风扇边界 | <https://e.huawei.com/cn/products/computing/ascend/atlas-300i-a2> |
| `[2]` | Huawei，*Atlas 300I A2 推理卡产品彩页* | 官方固定 PDF | FP32、媒体、32/64GB 规格、PCIe、功耗、散热、温度和尺寸 | <https://e.huawei.com/marketingcloud/pep/asset/20000001/Material/799a9236e96a48b7aa126b10f3d7be97/M3T1A590N1195067466974908517/%E6%98%87%E8%85%BEAtlas%20300I%20A2%20%E6%8E%A8%E7%90%86%E5%8D%A1%E4%BA%A7%E5%93%81%E5%BD%A9%E9%A1%B5.pdf> |
| `[3]` | Huawei Ascend Community，*眼图测试*，MindCluster 7.2.RC1 | 官方维护文档 | Atlas 300I A2 只支持 PCIe signal-quality query，排除 HCCS/RoCE 下放 | <https://www.hiascend.com/document/detail/zh/mindcluster/72rc1/toolbox/toolboxug/toolboxug_0021.html> |
| `[4]` | Huawei Ascend Community，*NPU 卡虚拟化硬切分参考实践* | 官方技术文章 | 32GB 卡的 20 AI Core、媒体/AI CPU 资源与 1-to-2/1-to-4 partition templates | <https://www.hiascend.com/zh/developer/techArticles/20251212-1> |
| `[5]` | Huawei，*A300I A2 推理卡 用户指南 03*，EDOC1100503150，2026-06-01 更新 | 官方用户指南及本地原文 | 产品用途、处理器、PCIe x16、PCI IDs、功耗配置、重量、管理与环境条件 | [基本规格表3-1](https://support.huawei.com/enterprise/zh/doc/EDOC1100503150/e95402c0)；[系统框图](https://support.huawei.com/enterprise/zh/doc/EDOC1100503150/af5a256f)；[电源管理](https://support.huawei.com/enterprise/zh/doc/EDOC1100503150/492ce033)；[概述原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-intro.html)；[基本规格原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-basic.html)；[框图原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-block.html)；[电源管理原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-power.html)；[散热要求原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-thermal-requirement.html)；[器件温度原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-thermal-spec.html)；[环境条件原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-environment.html)；[可维护性原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-maintain.html)；[热插拔原文](../../../原始资料/网页快照/华为/产品详解补充/2026-09-17/atlas-guide-hotplug.html) |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] processor、package、board、SKU 和 server drawer 事实没有混用
- [x] 32GB 与 64GB 配置已经分开
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] card HBM 与内部 cache/scratchpad 没有混写
- [x] Host PCIe 与其他 A2 products 的 HCCS/RoCE 已经分开
- [x] 系统级互联和冷却上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 用户指南独有字段已有本地可读原文并核实
- [x] 文末只列正文实际使用的资料

复核结论：Huawei Atlas 300I A2 32GB 的正式主语是一块双槽、全高全长、被动风冷的 PCIe inference card。32GB HBM、800GB/s、ECC、560TOPS INT8、280TFLOPS FP16、75TFLOPS FP32、1 颗 910 AI 处理器、20 个 AI Core、8 个 2.0GHz TaiShan Core、PCIe 5.0 x16、300W/350W 最大功耗档位、卡尺寸、环境要求及对应硬切分模板均能定位至官方原文。安全启动已在指南中确认，内部验证机制未展开。其他容量配置与服务器抽屉风扇没有下放；准确芯片子型号、die/package、单 core 结构、Cache 层级和容量、数值与稀疏语义、其他 RAS 和专用 LLM 单元仍保留缺口。
