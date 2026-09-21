# Huawei Atlas 300I A2 32GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：调研中（用户指南独有字段待重新核对）  
> 资料截止日：2026-09-16
> 本轮复核范围：产品页、官方彩页与虚拟化附录已核对；用户指南 [5] 的在线正文被远端站点阻断，依赖它的单芯片数量/型号、TaiShan 命名、PCI IDs、PCIe x16、300W 可配置档及重量仍待重新核对，不能视为本轮已确认。

本卡以一块配备 32GB HBM 的 Huawei Atlas 300I A2 inference card 为正式比较对象。它是双槽、全高全长的 PCIe 加速卡，面向服务器内 AI inference。64GB HBM 配置是同一产品名下的另一官方 SKU；Atlas 300I、300I Pro、300I Duo、Atlas 800I A2 server 和 A2 training products 均不与本卡合并。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Huawei（华为） | Atlas inference product | `[1, full page]` `[2, p.1]` |
| 完整 SKU | Huawei Atlas 300I A2 32GB | 当前产品页同时列 32GB 与 64GB，容量是区分本卡的正式配置字段 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 对象形态 | 双槽、全高全长 PCIe card | 安装在 server，不是独立 server、drawer 或 node | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 产品定位 | AI inference card，面向 generative-model inference、content generation、question answering、search/NLP、content moderation、recommendation 与 customer service | workload 列表是厂商定位，不是 benchmark | `[1, opening and features]` `[2, Application Scenarios]` |
| 发布与当前状态 | 当前华为企业产品目录列出并提供项目咨询，昇腾支持文档仍单列该卡；首次发布日未找到 | 可确认当前商用咨询与软件支持状态，不能由网页存在反推首批 shipment 日期 | `[1, full page]` `[3, applicable hardware]` |

本卡包含 32GB HBM、0.8TB/s、AI/CPU 峰值、媒体能力、PCIe 5.0、350W 最大功耗、被动风冷、温度与卡尺寸。

本卡不包含 64GB 配置的 1.6TB/s，也不包含 server drawer 的风扇数量、主机 CPU、系统内存、网络、整机功耗和多卡聚合性能。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 32GB 物理卡报告 20/20 个可用 AI Core；内部执行组织和实际时钟未公开 | 32GB 与 64GB 配置共享 card-level peak headline，但可切分资源表按 SKU 分列 | 不用原始 Ascend 910、910B 的第三方参数反推单 core 结构 | `[4, Appendix: Querying specifications of a single NPU card, Table 2]` |
| accelerator processor | 1×官方统称的“Ascend 910 AI processor”，集成 20 个 AI Core 和 8 个 TaiShan Core | exact submodel、die 数与工艺未公开 | 单芯片数量、通用处理器名称与 TaiShan 命名来自原指南摘录，本轮待重核，不用 910B4 等第三方子型号补写 | `[5, System Block Diagram and Table 3-1]` |
| package / board | 双槽全高全长 PCIe board，板上 HBM | 32GB 与 64GB SKU 共享外形、峰值与最大功耗字段 | 正式比较单位 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 相关系统 | server drawer | 上层 host/cooling environment | 产品页的 5 个 hot-swappable fan modules、4+1 redundancy 属于 drawer，不是卡载风扇 | `[1, Fan and form factor]` |

## 3. Core 微架构

官方虚拟化资源表给 32GB 物理卡列出 20/20 个可用 AI Core，但 exact-SKU 产品页和彩页没有公开 Matrix/Vector/Scalar 组织、L0/L1/L2/Unified Buffer 容量、程序员可见累加格式、物理 accumulator 位宽、结构化稀疏机制或内部 data mover。560TOPS INT8、280TFLOPS FP16 和 75TFLOPS FP32 不能反推出单 core 吞吐或时钟。[1, Technical Specifications] [2, Product Specifications] [4, Appendix Table 2]

未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache management 物理模块的一手证据。厂商把该卡用于 generative AI inference，不等于它具有这些专用单元。[1, opening] [2, Application Scenarios]

## 4. Processor、package 与 board

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| Board form factor | 双槽、全高全长 PCIe card | 不是 low-profile card 或 OAM module | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 尺寸 | 266.7mm×39.04mm×111.15mm | 彩页按长×宽×高列出；产品页表头写高×宽×深但数值顺序相同，因此保留原始三边，不重命名方向 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| Card cooling | 被动风冷 | 卡本身不含主动风扇字段；需要 server airflow | `[1, Technical Specifications]` `[2, Product Specifications]` |
| 工作温度 | 5°C 至 45°C | 产品页写 working ambient temperature；湿度、海拔、气流与降额条件未在彩页给出 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| Processor / die | 1×Ascend 910 AI processor，20 AI Core、8 TaiShan Core | 处理器数量及命名待重核；原指南摘录采用通用 Ascend 910 名称；exact submodel、die/package、工艺、面积和晶体管数未公开 | `[5, System Block Diagram and Table 3-1]` |
| HBM physical organization | 未公开 stack 数、bus width、memory clock 或 package topology | 只记录 card/SKU 的 capacity、bandwidth 与 ECC | `[1, Technical Specifications]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| INT8 峰值 | 560TOPS | 最高 card-level theoretical compute；未说明 dense/sparse、MAC 计数与持续条件 | `[1, Technical Specifications]` `[2, Product Specifications]` |
| FP16 峰值 | 280TFLOPS | 最高 card-level theoretical compute；未说明 accumulator 与 sparsity condition | `[1, Technical Specifications]` `[2, Product Specifications]` |
| FP32 峰值 | 75TFLOPS | 官方彩页列出，当前产品网页规格表未显示该行 | `[2, Product Specifications]` |
| CPU | 8×TaiShan Core，2.0GHz | 8 核/2.0GHz 已由彩页确认；TaiShan 命名依赖原指南，待重核；cache 与是否 all-core sustained 未公开 | `[1, features and Technical Specifications]` `[2, Product Specifications]` `[5, Table 3-1]` |
| 可用加速资源 | 20 AI Core、7 AI CPU、9 VPC、2 VDEC、24 JPEGD、4 JPEGE；VENC 为 0，PNGD 不适用 | 官方 physical-card resource query；7 AI CPU 是可切分资源数，不替代产品页的 8-core physical CPU field | `[4, Appendix: Querying specifications of a single NPU card, Table 2]` |
| HBM | 32GB、800GB/s（产品页写 0.8TB/s）、ECC | 本卡正式 SKU；不采用 64GB SKU 的 1.6TB/s | `[1, Technical Specifications]` `[2, Product Specifications]` |
| Host interface | PCIe 5.0；x16 为原指南摘录，待重核 | payload bandwidth、CXL、P2P 和 SR-IOV 未公开 | `[1, Technical Specifications]` `[5, Table 3-1]` |
| PCI identity | 待重核：Vendor ID 0x19E5、Device ID 0xD802、Subsystem Vendor ID 0x19E5、Subsystem Device ID 0x4000 | 0x4000 是 32GB 配置；64GB 配置为 0x4001 | `[5, Table 3-1]` |
| 功耗 | 最大 350W 已确认；300W 配置为原指南摘录，待重核 | 用户指南未把 300/350W 映射到特定容量，因此不声称 32GB 必然为 300W | `[1, Technical Specifications]` `[2, Product Specifications]` `[5, Table 3-1]` |
| 散热 | 被动风冷 | server 需要提供 airflow；产品页另列 drawer-level 5 个 hot-swappable fan module、4+1 redundancy | `[1, Technical Specifications]` |
| 视频解码 | 1080p 480FPS equivalent | codec、bit depth、profile 与并发 stream 条件未在彩页表格中展开 | `[2, Product Specifications]` |
| JPEG 解码 | 1080p 12,288FPS equivalent；分辨率 32×32 至 16,384×16,384 | 最高等效吞吐，未说明图像质量与持续条件 | `[2, Product Specifications]` |
| JPEG 编码 | 1080p 1,024FPS equivalent；分辨率 32×32 至 8,192×8,192 | 最高等效吞吐 | `[2, Product Specifications]` |
| 硬切分 | 32GB SKU 已验证 1-to-2 与 1-to-4 inference partition | 代表模板包括 10 AI Core/16GB 和 5 AI Core/8GB；不同模板分配的 AI CPU 与媒体资源不同 | `[4, Section 1.3 and Appendix Table 2]` |
| 重量 | 1.32kg（原指南摘录，待重核） | 单卡，不含 server packaging | `[5, Table 3-1]` |

## 6. 系统级互联上下文

Atlas 300I A2 是 host-attached PCIe card。当前 DMI 文档说明该卡只支持查询 PCIe signal quality；HCCS 和 RoCE 是其他 A2 server/product 的链路类型，不应写成本卡互联端点。[3, eye-diagram parameters]

产品页把“每个 drawer 集成 5 个 hot-swappable fan module，支持 4+1 redundancy”列在同一技术规格区，但卡的 cooling 字段明确为 passive air cooling。因此风扇数量是 server drawer 的冷却上下文，不是单卡上的 5 个风扇。[1, Fan and Cooling]

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| 32GB 与 64GB | 同一产品名下的两个 official configuration | 32GB 为 0.8TB/s；64GB 为 1.6TB/s，其他 card-level headline 在同一表中共用 | 本卡只采用 32GB/0.8TB/s，64GB 另建 SKU 卡 |
| FP32 峰值 | 官方页面披露粒度不同 | 彩页列 75TFLOPS；当前网页规格表只列 INT8/FP16 | 保留彩页的 75TFLOPS，并注明来源差异 |
| PCIe | 代际已复核，lane width 待重核 | 产品页和彩页明确 PCIe 5.0；主字段 x16 引自用户指南 [5]，本轮未取得正文 | 保留原引用及待核状态，不再与第 5 节矛盾地写成 lane width 未公开 |
| Cooling | card 与 drawer 层级并列 | card 为 passive air cooling；5-fan 4+1 redundancy 是 drawer | 不把 system fan count 写成 card fan |
| Accelerator processor | 单芯片和 core 数已公开，exact submodel/package 未公开 | 用户指南写 1×Ascend 910、20 AI Core、8 TaiShan Core | 不用 910B4 software/reporting name 或第三方拆解补写工艺和 die 细节 |
| 数值格式与稀疏 | 仅峰值可确认 | INT8、FP16、FP32 headline | dense/sparse、BF16/FP8/INT4、累加格式、舍入和物理 accumulator 保持未公开 |
| 存储层级 | card memory 可确认，internal hierarchy 未公开 | HBM capacity/bandwidth/ECC；无 cache/scratchpad 数据 | 不由 HBM 值反推 stack、bus width 或 processor package |
| 虚拟化、RAS 与安全 | 硬切分模板已公开，其他项未公开 | 32GB SKU 支持 1-to-2/1-to-4 inference hard partition；HBM ECC 可确认 | 不把硬切分解释成 SR-IOV；secure boot、page retirement、ECC 粒度等保持未公开 |
| 发布日期与首批出货 | 未找到 | 当前产品页、彩页和支持文档 | 只记录当前官方列出的 product configuration |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Huawei，*Atlas 300I A2* | 当前官方产品页 | 身份、两种容量、峰值、HBM、PCIe、功耗、散热、温度、尺寸与 drawer 风扇边界 | <https://e.huawei.com/cn/products/computing/ascend/atlas-300i-a2> |
| `[2]` | Huawei，*Atlas 300I A2 推理卡产品彩页* | 官方固定 PDF | FP32、媒体、32/64GB 规格、PCIe、功耗、散热、温度和尺寸 | <https://e.huawei.com/marketingcloud/pep/asset/20000001/Material/799a9236e96a48b7aa126b10f3d7be97/M3T1A590N1195067466974908517/%E6%98%87%E8%85%BEAtlas%20300I%20A2%20%E6%8E%A8%E7%90%86%E5%8D%A1%E4%BA%A7%E5%93%81%E5%BD%A9%E9%A1%B5.pdf> |
| `[3]` | Huawei Ascend Community，*眼图测试*，MindCluster 7.2.RC1 | 官方维护文档 | Atlas 300I A2 只支持 PCIe signal-quality query，排除 HCCS/RoCE 下放 | <https://www.hiascend.com/document/detail/zh/mindcluster/72rc1/toolbox/toolboxug/toolboxug_0021.html> |
| `[4]` | Huawei Ascend Community，*NPU 卡虚拟化硬切分参考实践* | 官方技术文章 | 32GB 卡的 20 AI Core、媒体/AI CPU 资源与 1-to-2/1-to-4 partition templates | <https://www.hiascend.com/zh/developer/techArticles/20251212-1> |
| `[5]` | Huawei，*Atlas 300I A2 推理卡用户指南 01* | 官方用户指南 | 1×processor、20 AI Core、8 TaiShan Core、PCIe x16、PCI IDs、功耗配置、重量与环境条件 | <https://support.huawei.com/enterprise/zh/doc/EDOC1100503150/b9547447?idPath=23710424%7C251366513%7C254884019%7C261408774%7C260323393> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] processor、package、board、SKU 和 server drawer 事实没有混用
- [x] 32GB 与 64GB 配置已经分开
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] card HBM 与内部 cache/scratchpad 没有混写
- [x] Host PCIe 与其他 A2 products 的 HCCS/RoCE 已经分开
- [x] 系统级互联和冷却上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [ ] 用户指南独有字段已在本轮重新取得可读原文并核实
- [x] 文末只列正文实际使用的资料

复核结论：Huawei Atlas 300I A2 32GB 的正式主语是一块双槽、全高全长、被动风冷的 PCIe inference card。32GB HBM、800GB/s、ECC、560TOPS INT8、280TFLOPS FP16、75TFLOPS FP32、1 个官方统称的 Ascend 910 processor、20 个 AI Core、8 个 2.0GHz TaiShan Core、PCIe 5.0 x16、300W/350W 功耗配置、最大 350W、5°C 至 45°C、卡尺寸及 32GB 专属硬切分模板分别引自华为一手资料；其中仅由用户指南 [5] 支持的字段，本轮未能重新打开原文，仍待复核。64GB/1.6TB/s 配置没有下放；drawer 风扇也没有写成 card component。exact chip submodel、工艺、die/package、单 core 结构、内部 cache/scratchpad、数值与稀疏语义、其他 RAS、安全和专用 LLM 单元保持未公开。
