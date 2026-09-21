# NVIDIA B300 SXM6 AC 288GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：调研中（288GB 与 270GB 规格映射待核）  
> 资料截止日：2026-09-16

本卡以 NVIDIA B300 SXM6 AC 288GB GPU 模组为目标对象。288GB 容量有官方直接证据，但现有精细峰值与 1,100W 来自标注 270GB 的官方表；两组规格的对应关系尚未证实，不能拼接成同一确定 SKU。HGX B300 是八 GPU baseboard，DGX B300 是完整的八 GPU 服务器；GB300 Grace Blackwell Ultra Superchip 则把两个 Blackwell Ultra GPU 与一个 Grace CPU 组合在一起。上述系统或 Superchip 的聚合值不属于本 SKU。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | B300 SXM6 AC 288GB | `[6, Verified GPUs]` |
| 产品家族 | NVIDIA Blackwell Ultra B300 Tensor Core GPU | 非 B200、GB300 Superchip 或 GB300 NVL72 | `[2, Blackwell Ultra GPU Architecture]` `[5, NVIDIA Blackwell Ultra Enables AI Reasoning]` |
| 完整 SKU | `NVIDIA-B300-SXM6-AC`，288GB HBM3e | NIM 的 Verified GPUs 给软件名称，per-GPU VRAM 表给 288GB；与其他官方表的 270GB 仍冲突 | `[6, Verified GPUs and per-GPU VRAM tables]` |
| 对象形态 | SXM6 GPU 模组，AC 配置 | 不是 PCIe add-in card；AC 是当前受支持配置名，不把它扩写成模组独立散热器 | `[6, Verified GPUs]` |
| 架构代际 | Blackwell Ultra，Compute Capability 10.3 | B300 Tensor Core GPU | `[4, Target Architecture]` |
| 发布与可用状态 | 2025-03-18 发布；发布时预计 2025 年下半年由合作伙伴供货；当前 HGX/DGX B300 系统已出货 | 发布日、计划供货和当前系统状态分开 | `[5, page header and Global Technology Leaders Embrace Blackwell Ultra]` `[9, NVIDIA HGX Specifications, note 4]` |
| 厂商定位 | 同时面向 AI training 与 test-time scaling inference，重点覆盖 reasoning、agentic AI 和 physical AI | 厂商平台定位，不转写系统 benchmark | `[5, opening paragraphs and NVIDIA Blackwell Ultra Enables AI Reasoning]` |
| 产品目标 | 在双裸片统一 GPU 上增加 NVFP4、HBM3e 容量与带宽，并提高 attention/softmax 相关路径和 scale-up 能力 | 架构能力与单 SKU 配置分层记录 | `[2, Blackwell Ultra GPU Architecture, Memory and Interconnect]` `[8, Alleviating the softmax bottleneck]` |

本卡包含：B300 SXM6 AC 288GB 的 Blackwell Ultra 双裸片实现、单 GPU 峰值、HBM3e、PCIe/NVLink 端点、MIG、功耗和模组形态。

本卡不包含：HGX/DGX B300 的八卡聚合值、CPU/NIC/NVSwitch，GB300 Superchip 的 Grace CPU、LPDDR5X 和 NVLink-C2C，以及 GB300 NVL72 的 rack-scale 指标。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Blackwell Ultra SM、第五代 Tensor Core、第二代 Transformer Engine，以及提高吞吐的 `MUFU.EX2` 指数路径 | 与 GB300 中的 Blackwell Ultra GPU 共享 | 复用 [Blackwell Ultra 架构增量](../架构/NVIDIA_Blackwell_Ultra_架构_增量.md)，SKU 数值仍以 B300 来源为准 | `[2, Streaming multiprocessors and NVIDIA Tensor Cores]` `[8, Alleviating the softmax bottleneck]` |
| die / chiplet | 两个 reticle-sized GPU die，以 NV-HBI 连成一个 coherent GPU | Blackwell Ultra 双裸片实现 | 两个 die 不是两个独立 GPU | `[2, Dual-reticle design: one GPU]` |
| package | 双 GPU die、NV-HBI 与 288GB HBM3e 的 SXM6 AC 模组 | 与 GB300 Superchip、其他 Ultra 配置不同 | 以 B300 288GB 为目标，保留 270GB 配置关系未知 | `[2, Memory]` `[6, Verified GPUs]` |
| 产品 SKU | NVIDIA B300 SXM6 AC 288GB | 不适用 | 正式比较单位 | `[6, Verified GPUs]` |
| 相关系统 | HGX B300 baseboard 与 DGX B300，均为 8 GPU | 多种系统部署 | 只记录单 GPU 端点和八 GPU NVLink 域的边界 | `[3, Tables 1-2 and NVIDIA HGX B300 Baseboard]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵与数值路径 | Blackwell Ultra 架构支持 NVFP4、FP6、FP8、FP16/BF16、TF32、INT8 和 FP64 等数据类型；第二代 Transformer Engine 管理动态范围和 micro-tensor scaling | 架构数据类型表不能全归入 Tensor Core；B300 的 Tensor/non-Tensor 分项按原表标签记录 | `[1, pp. 8-9, 25-26]` `[2, NVIDIA Tensor Cores]` |
| 执行组织 | 完整 Blackwell Ultra 实现最多 160 SM；每 SM 128 CUDA Core、4 个第五代 Tensor Core | 文章脚注明确资源会随 SKU 改变；未找到 B300 SXM6 AC 实际使能 SM/Core 数 | `[2, Dual-reticle design: one GPU, Streaming multiprocessors and note 1]` |
| 局部存储 | 每 SM 有 256KB Tensor Memory（TMEM）；两个 die 共享 fully coherent L2 | TMEM 是 Tensor Core 数据通路的片上 scratchpad；B300 L2 容量未公开 | `[2, Streaming multiprocessors and Memory]` |
| 特殊函数路径 | Blackwell Ultra 的 `MUFU.EX2` 指数吞吐相对 Blackwell 提高 2 倍，可用于 softmax 指数阶段 | 架构增量；不把软件 kernel 加速比写成单 GPU 固定性能 | `[8, Alleviating the softmax bottleneck and Table 1]` |
| 稀疏与专用引擎 | Tensor Core 峰值同时给 dense/sparse 口径；有专用 Decompression Engine | B300 单 GPU 配置；不据此推断 MoE routing 或 top-k 专用硬件 | `[1, pp. 25-26, Table 3]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 物理组织 | 两个 reticle-sized die 在一个 package 内表现为单一 coherent GPU | 双裸片不是两个产品 SKU | `[2, Dual-reticle design: one GPU]` |
| die-to-die 互联 | NVIDIA High-Bandwidth Interface（NV-HBI）10TB/s（来源未明确方向） | 封装内 D2D，不是 GPU 间 NVLink | `[2, Dual-reticle design: one GPU]` |
| 工艺与晶体管 | custom TSMC 4NP；整个双裸片 GPU 约 208 billion transistors | 不是每个 die 各 208B | `[2, Dual-reticle design: one GPU]` |
| 实际计算资源 | Blackwell Ultra 完整实现上限为 160 SM、20,480 CUDA Core、640 Tensor Core；B300 SXM6 AC 实际使能数未公开 | 20,480 是 160×128 的算术结果，不作为实际启用资源 | `[2, Streaming multiprocessors, NVIDIA Tensor Cores and note 1]` |
| 封装内 HBM | 288GB HBM3e，最高 8TB/s | 当前 B300 per-GPU 配置；HBM stack 数的 NVIDIA 网页曾修订，本卡不固定该数 | `[2, Memory and update note]` `[3, Table 1]` |
| L2 与一致性 | 两个 die 共享 coherent L2；容量未公开 | CUDA Tuning Guide 的 126MB 明确绑定 GB200 GPU，本卡不自动继承 | `[2, Memory]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 未公开；架构 full implementation 最多 160 SM、20,480 CUDA Core、640 Tensor Core | B300 的实际 fuse-enabled 资源未由 per-GPU 表直接确认 | `[2, Streaming multiprocessors, NVIDIA Tensor Cores and note 1]` |
| 时钟 | 未公开 | 不从峰值反推 clock | `[1, pp. 25-26, Table 3]` |
| 270GB 表中的参考峰值 | FP4 Tensor 18 sparse / 14 dense PFLOPS；FP8/FP6 Tensor 9 sparse / 4.5 dense PFLOPS；INT8 Tensor 0.30 sparse / 0.15 dense POPS；FP16/BF16 Tensor 4.5 sparse / 2.2 dense PFLOPS；TF32 Tensor 2.2 sparse / 1.1 dense PFLOPS；FP32 75TFLOPS；官方合并标签“FP64 Tensor Core / FP64”为 1.2TFLOPS | 均来自标注 270GB/7.7TB/s/1,100W 的 HGX B300 per-GPU 表；尚未确认适用于本卡的 288GB 配置，不能进入无条件的同 SKU 比较 | `[1, pp. 25-26, Table 3, Per GPU Specs]` |
| 内存 | 288GB HBM3e，最高 8TB/s | 当前 B300 SXM per-GPU 配置 | `[3, Table 1]` `[6, per-GPU VRAM tables]` |
| 主机接口 | PCIe Gen6 x16，256GB/s bidirectional | Blackwell Ultra GPU endpoint；HGX baseboard 的 CPU-facing Gen5 links 是另一层链路 | `[2, Interconnect]` `[3, Table 2]` |
| 设备互联端点 | 第五代 NVLink，18 links，单 GPU 1.8TB/s bidirectional | 每 link 100GB/s bidirectional；NVSwitch 在模组外 | `[2, Interconnect]` `[3, Table 2]` |
| 内存访问语义 | NV-HBI 将两个 die 统一为 coherent GPU；L2 在两个 die 间 fully coherent | package 内语义，不等同于 GB300 CPU-GPU unified memory | `[2, Dual-reticle design: one GPU and Memory]` |
| 跨设备集合通信 | 单 GPU 未找到独立 collective engine；集合通信由外部 NVLink/NVSwitch 与软件栈完成 | 不把 NVSwitch 下放为 SXM6 模组内单元 | `[3, NVIDIA HGX B300 Baseboard and Table 2]` |
| 功耗 | 288GB 精确配置未确认；270GB 表为 1,100W TDP | 1,100W 不直接下放给 288GB；generic Blackwell Ultra 家族最高 1,400W 也不能替代 | `[1, pp. 25-26, Table 3]` `[2, Table 2]` |
| 形态与散热 | SXM6 AC 配置；具体气流、散热器和整机供电由 HGX/OEM 系统实现 | 不是 PCIe card；不把 DGX 整机功耗写入单 GPU | `[6, Verified GPUs]` |
| MIG | 最多 7 instances；profiles 为 1g.34gb、1g.34gb+me、1g.67gb、2g.67gb、3g.135gb、4g.135gb、7g.269gb | GPU Operator 26.3 明确绑定 HGX B300；profile 名的可见 framebuffer 不等同于 288GB 物理容量 | `[7, Added support for new MIG profiles with NVIDIA HGX B300]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | HGX B300 baseboard 有 8 个 B300 SXM GPU，NVLink aggregate bandwidth 为 14.4TB/s | 本 SKU 只提供 1.8TB/s per-GPU endpoint；14.4TB/s 是八卡合计 | `[3, NVIDIA HGX B300 Baseboard and Table 2]` |
| 内存聚合 | 当前 Enterprise RA 给每 GPU 288GB/最高 8TB/s，节点合计 2.30TB/最高 64TB/s | 本卡只采用前一组 per-GPU 数值 | `[3, Table 1]` |
| 相关系统 | 当前 HGX B300 规格以 8 个 Blackwell Ultra SXM 为一个 baseboard 配置 | 系统峰值、总 GPU memory 和整机功耗不下放 | `[9, NVIDIA HGX Specifications and note 4]` |
| 更高层对象 | GB300 Superchip 为 1 Grace CPU 加 2 Blackwell Ultra GPU；GB300 NVL72 为 36 Grace CPU、72 GPU | CPU memory、NVLink-C2C 与 rack-scale 指标不属于 B300 SXM6 | `[2, NVIDIA Grace Blackwell Ultra Superchip]` `[5, NVIDIA Blackwell Ultra Enables AI Reasoning]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| B300 实际 SM/Core/Tensor Core/L2 | 未找到直接 per-SKU 数值 | Ultra 架构文章给 full implementation 上限，per-GPU 规格表未列实际使能值 | 只记录上限及每 SM 资源，不把 160 SM 当成 B300 实际值 |
| clock | 未公开 | Technical Brief、Ultra 架构文章、Enterprise RA | 不从峰值反推 |
| HBM 容量与配置映射 | 尚未解决的官方冲突 | NIM/Enterprise RA 给 288GB；Technical Brief、Ultra Datasheet 与 R595 GA 支持表仍列 270GB B300 SXM6 AC | 未找到 270→288 的勘误或配置映射，不能断言 270GB 已过时。vGPU framebuffer 与 MIG profile 另属软件可见口径；Ultra Datasheet 的 GB300 列也出现 279GB，不能把所有 279GB 都归为 framebuffer。`[1, Table 3]` `[10, p.5]` `[11, pp.5,7]` |
| HBM 带宽 | 官方文档口径差异 | 当前 Enterprise RA/Ultra 页面为最高8TB/s；Technical Brief per-GPU 表为7.7TB/s | 主规格采用当前配置的最高8TB/s，保留1100W HGX B300 表的7.7TB/s |
| FP4 dense 峰值 | 配置/舍入口径关系未说明 | Technical Brief per-GPU 为14PFLOPS；当前八卡 DGX/HGX 表为108PFLOPS dense，除以8为13.5 | 14 只保留为 270GB 表值；13.5 是系统聚合反算，不确认仅由舍入造成，也不替代 288GB 的直接单 GPU 规格 |
| generic Ultra 峰值与功耗 | 对象范围不同 | Ultra 架构文章给最多15/20PFLOPS NVFP4、最多1,400W；HGX B300 per-GPU 表为14/18PFLOPS、1,100W | 各值限定原配置；270GB 表与 288GB 产品的关系未明，不能选任一值作为确定的 288GB 功耗/峰值 |
| INT8 与 FP64 峰值 | 270GB 配置来源 | Technical Brief Table 3 为0.15/0.30POPS和合并标签1.2TFLOPS | 原样保留 270GB 配置值，不用 B200 或 generic Ultra 数值替代，也不据此填定 288GB |
| INT8 舍入 | 官方数值存在差异 | Technical Brief 为0.30 sparse / 0.15 dense POPS；Blackwell Ultra Datasheet p.5 为307 sparse TOPS、dense为其一半 | 两份表都标 270GB/7.7TB/s/1,100W；保留 300/307TOPS 差异，不认定只是舍入或映射为 288GB 峰值 `[10, p. 5, Technical Specifications]` |
| PCIe 代际 | 链路层级不同 | GPU endpoint 为Gen6 x16；HGX baseboard CPU-facing links 为Gen5 x16 | 分层记录，不合并成单一“系统 PCIe 代际” |
| HBM stack 数 | NVIDIA 网页曾修订 | Ultra 文章正文与更新说明先后出现8和12 stacks | 不填 stack 数；容量、类型和带宽已有直接证据 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA Blackwell Architecture Technical Brief*，v2.1 | 官方架构技术简报 | B300 per-GPU 峰值、270GB/7.7TB/s口径（与288GB关系待核）、NVLink/PCIe、1,100W TDP及双裸片实现 | [本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/NVIDIA_Blackwell_Architecture_Technical_Brief_v2.1.pdf) |
| `[2]` | NVIDIA，*Inside NVIDIA Blackwell Ultra: The Chip Powering the AI Factory Era*，2025-08-22 | 官方技术文章 | 双裸片/NV-HBI、4NP/208B、SM/Core/Tensor上限、TMEM/L2、HBM、PCIe/NVLink及generic Ultra范围 | <https://developer.nvidia.com/blog/inside-nvidia-blackwell-ultra-the-chip-powering-the-ai-factory-era/> |
| `[3]` | NVIDIA，*HGX AI Factory: Components* | 当前官方参考架构 | B300 SXM每GPU 288GB/最高8TB/s，以及八卡节点、NVLink聚合和CPU-facing链路边界 | <https://docs.nvidia.com/enterprise-reference-architectures/hgx-ai-factory/latest/components.html> |
| `[4]` | NVIDIA，*CUTLASS Overview: Target Architecture* | 当前官方开发文档 | B300 Compute Capability 10.3 | <https://docs.nvidia.com/cutlass/4.3.5/overview.html> |
| `[5]` | NVIDIA，*NVIDIA Blackwell Ultra AI Factory Platform Paves Way for Age of AI Reasoning*，2025-03-18 | 官方发布公告 | 发布时间、厂商定位、首发产品与初始供货计划 | <https://nvidianews.nvidia.com/news/nvidia-blackwell-ultra-ai-factory-platform-paves-way-for-age-of-ai-reasoning> |
| `[6]` | NVIDIA，*Support Matrix for NIMs: NVIDIA NIM for Large Language Models* | 当前官方支持文档 | `NVIDIA-B300-SXM6-AC`完整SKU名与288GB per-GPU VRAM | <https://docs.nvidia.com/nim/large-language-models/latest/reference/support-matrix.html> |
| `[7]` | NVIDIA，*GPU Operator 26.3 Release Notes* | 当前官方软件文档 | HGX B300支持的MIG profiles | <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/26.3/release-notes.html> |
| `[8]` | NVIDIA，*Making Softmax More Efficient with NVIDIA Blackwell Ultra*，2026-02-25 | 官方技术文章 | `MUFU.EX2`路径及相对Blackwell的2倍指数吞吐 | <https://developer.nvidia.com/blog/making-softmax-more-efficient-with-nvidia-blackwell-ultra/> |
| `[9]` | NVIDIA，*NVIDIA HGX Platform* | 当前官方产品页 | HGX B300八卡形态、相关系统边界与当前出货状态 | <https://www.nvidia.com/en-us/data-center/hgx/> |
| `[10]` | NVIDIA，*NVIDIA Blackwell Ultra Datasheet*，2025-10-02 | 官方 datasheet | HGX B300的INT8细化值，以及270GB/7.7TB/s/1,100W配置口径交叉核对 | <https://dam-cdn.nvd.orangelogic.com/AssetLink/1k0p832eq8r5ca0u5383ie5o4tp3bst1.pdf>；[本地 PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2025_NVIDIA_Blackwell_Ultra_Datasheet.pdf) |
| `[11]` | NVIDIA，*R595 Trusted Computing Solutions Release Notes* | 官方驱动支持文档 | GA 支持表仍列 B300 SXM6 AC 270GB，不能简单归为早期废弃规格 | <https://docs.nvidia.com/595trd1-trusted-computing-solutions-release-notes.pdf> |

## 9. 完成检查

- [ ] 288GB SKU 与 270GB 峰值/功耗表的配置关系已固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 HBM、设备互联和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：288GB 容量与最高 8TB/s 已有官方直接证据；双裸片架构、PCIe Gen6 和第五代 NVLink 也有来源。精细峰值与 1,100W 则来自仍标注 270GB 的官方表，当前未找到足以把它们全部绑定到 288GB SKU 的说明。本卡因此转回调研中；实际使能 SM/Core、L2 容量及上述配置映射仍待核实。
