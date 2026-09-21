# NVIDIA A100 SXM4 80GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡的主语是一个 NVIDIA A100 SXM4 80GB GPU 模组。A100 SXM4 40GB、A100 PCIe 80GB、HGX A100 baseboard 和 DGX A100 系统均为其他对象，不能用它们的内存、功耗、形态或系统聚合值补写本 SKU。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | NVIDIA | A100 SXM4 80GB | `[1, p. 1, specifications]` `[3, Supported GPUs, Table 1]` |
| 产品家族 | NVIDIA A100 Tensor Core GPU | 80GB SXM 配置 | `[1, pp. 1-3]` |
| 完整 SKU | NVIDIA A100 SXM4 80GB；当前软件设备名 `NVIDIA-A100-SXM4-80GB` | 单 GPU 模组 | `[3, Supported GPUs, Table 1]` `[7, Support Matrix for Certified NIMs, Verified GPUs]` |
| 对象形态 | SXM4 模组，通过 HGX A100 server board 部署 | 不是 PCIe add-in card | `[1, p. 1, Form Factor, Interconnect and note 2]` `[3, Supported GPUs, Table 1]` |
| 架构代际 | NVIDIA Ampere，GA100，Compute Capability 8.0 | A100-SXM4 | `[2, pp. 19, 43, Tables 4-5]` `[3, Supported GPUs, Table 1]` |
| 发布与可用状态 | 2020-11-16 发布；同季随 DGX A100/DGX Station A100 系统供货，HGX 合作伙伴系统计划于 2021 年上半年提供；截至资料截止日仍在 NVIDIA 支持文档中 | 发布、系统供货和当前硬件销售状态分开；当前在产/现货未由 NVIDIA 统一公开 | `[4, page header, opening and availability paragraphs]` `[3, Supported GPUs, Table 1]` |
| 厂商定位 | 同时面向 AI training、AI inference、data analytics 与 HPC/scientific computing | 数据中心通用加速器，不缩写为单一训练或推理产品 | `[1, pp. 1-3]` `[4, Fueling Data-Hungry Workloads]` |
| 产品目标 | 在 A100 40GB 基础上以 HBM2e 将容量增至 80GB、带宽提高到 2TB/s 以上，同时保留 Tensor Core、MIG 和 NVLink 能力 | 80GB 版本的直接定位 | `[4, opening and Key Features of A100 80GB]` |

本卡包含：A100 SXM4 80GB 的 GA100/Ampere 实现、单 GPU 峰值、HBM2e、PCIe/NVLink 端点、MIG、功耗和模组形态。

本卡不包含：A100 40GB 或 PCIe 80GB 的容量、带宽、功耗和 bridge 拓扑，也不包含 HGX/DGX 的 GPU 数、NVSwitch 拓扑、总显存、整机功耗和系统峰值。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | Ampere SM、第三代 Tensor Core、MIG、Compute Data Compression | 与其他 GA100 产品共享 | 复用 [Ampere 架构资料](../架构/NVIDIA_Ampere_架构.md)，峰值按本 SKU 核对 | `[2, pp. 19-34, 41, 44-52]` |
| die | GA100 单片式 GPU die；完整设计128 SM，A100产品实际启用108 SM | A100 SXM/PCIe与A30共享不同使能配置 | 复用 [GA100 die 资料](../裸片/NVIDIA_GA100_die_综合资料卡.md)；不把full GA100的128 SM写入产品值 | `[2, pp. 19-20, Figure 6]` |
| package / module | 一个A100 GA100实现与80GB HBM2e构成SXM4模组 | 40GB SXM与80GB PCIe配置不同 | 精确HBM stack层数未由80GB datasheet重述 | `[1, p. 1]` |
| 产品 SKU | NVIDIA A100 SXM4 80GB | 不适用 | 正式比较单位 | `[3, Supported GPUs, Table 1]` |
| 相关系统 | HGX A100 partner systems可使用4、8或16个SXM GPU；DGX A100为8 GPU系统 | 多种系统配置 | 只记录单GPU端点和系统边界 | `[1, p. 1, Server Options]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 标量与向量路径 | 每SM有64个FP32 CUDA Core和64个INT32 Core；FP32与INT32路径可并发执行 | A100启用108 SM，共6,912个FP32 CUDA Core | `[2, pp. 19, 22, 33-34, Table 4]` |
| 矩阵与数值路径 | 每SM有4个第三代Tensor Core；支持TF32、FP16、BF16、FP64、INT8、INT4和Binary等路径 | A100共432个Tensor Core；分精度峰值另列 | `[2, pp. 19, 22-32, Table 3]` |
| 执行组织 | 32 threads/warp；每SM最多64 concurrent warps、2,048 threads和32 thread blocks | Compute Capability 8.0程序员可见上限 | `[2, p. 43, Table 5]` |
| 局部存储 | 每SM有256KB register file；统一L1/shared memory物理容量为192KB，软件可配置shared memory最高164KB/SM | 物理combined capacity与软件可见shared上限分开 | `[2, pp. 21-22, 37, 43, Tables 4-5]` |
| 异步搬运与压缩 | Ampere支持global-to-shared异步copy、split arrive/wait barrier和Compute Data Compression | compression对可压缩数据可提高有效带宽/容量，不乘入基础HBM或L2规格 | `[2, pp. 37-41]` |
| 结构化稀疏 | Tensor Core支持fine-grained structured sparsity，官方峰值表将稀疏effective throughput列为dense的2倍 | 需要经过剪枝、压缩和metadata编码的结构化输入 | `[2, pp. 30-32, Figure 12]` `[1, p. 1, note 1]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 物理组织 | 单片式GA100；完整设计128 SM，A100实现启用108 SM | 本SKU是一个GPU，不存在封装内GPU die-to-die互联 | `[2, pp. 19-20, Figure 6]` |
| 工艺与晶体管 | TSMC 7nm N7，826mm²，54.2 billion transistors | GA100 die，不是SXM PCB或整机 | `[2, p. 14, architecture text; p. 15, Table 1]` |
| A100实际资源 | 7 GPC、54 TPC、108 SM、6,912 FP32 CUDA Core、3,456非Tensor FP64 Core、6,912 INT32 Core、432第三代Tensor Core | NVIDIA对A100 enabled implementation的直接值；80GB SXM测试指南再次确认108 SM | `[2, pp. 19, 36, Table 4]` `[6, §4.3, Figure 4]` |
| L2 | A100实现为40MB L2；L2 read bandwidth为5,120 bytes/clock | 总容量归A100 enabled implementation；未找到80GB版本改变L2的官方说明 | `[2, pp. 35-36, Table 4]` |
| HBM接口 | A100实现启用10个512-bit memory controller，即5,120-bit接口；80GB SKU使用HBM2e | 80GB datasheet没有重述stack数和controller数；不把40GB的单stack组织直接复制为80GB HBM2e堆叠细节 | `[2, pp. 19, 36, Table 4]` `[1, p. 1]` |
| RAS | HBM、L2、L1与register file使用SECDED ECC；NVLink支持link-level error detection、packet replay和remote-fault attribution | A100/GA100实现；不等同于系统冗余 | `[2, pp. 35, 52-54]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 7 GPC、54 TPC、108 SM、6,912 FP32 CUDA Core、432 Tensor Core、40MB L2 | A100 enabled implementation，并由A100-SXM4-80GB测试环境确认108 SM | `[2, pp. 19, 36, Table 4]` `[6, §4.3, Figure 4]` |
| 时钟 | A100实现GPU Boost Clock 1,410MHz；80GB datasheet未单独重述 | 同峰值的A100 enabled implementation值；不作为固定运行频率 | `[2, p. 36, Table 4]` |
| 理论峰值 | FP64 9.7TFLOPS；FP64 Tensor 19.5TFLOPS；FP32 19.5TFLOPS；非Tensor FP16 78TFLOPS、BF16 39TFLOPS；TF32 156 dense / 312 sparse TFLOPS；BF16 Tensor 312/624；FP16 Tensor 312/624；INT8 Tensor 624/1,248 TOPS；INT4 Tensor 1,248/2,496 TOPS | 竖线/成对值后的第二项为structured-sparsity effective throughput；不与实测混写 | `[1, p. 1, specifications and note 1]` `[2, pp. 15, 36, Tables 1 and 4]` |
| 内存 | 80GB HBM2e，2,039GB/s | 单GPU/单SXM4模组 | `[1, p. 1]` |
| 主机接口 | PCIe Gen4 x16，约64GB/s bidirectional；理论每方向31.5GB/s | datasheet用64GB/s聚合口径，白皮书给每方向理论值 | `[1, p. 1, Interconnect]` `[2, p. 53, PCIe Gen 4 with SR-IOV]` |
| 设备互联端点 | 第三代NVLink，12 links，单GPU合计600GB/s | 单link每方向25GB/s；白皮书将总量表述为entire A100的600GB/s | `[2, pp. 16, 52, Third-Generation NVLink]` `[1, p. 1]` |
| 内存访问语义 | NVLink是lossless shared-memory interconnect，可访问peer GPU memory；remote GPU page fault可回传source GPU | GPU间语义；需外部NVSwitch/board完成系统拓扑 | `[2, pp. 52-54]` |
| 跨设备集合通信 | 单模组未找到独立collective engine；NVSwitch与通信软件位于系统层 | 不把NVSwitch下放到SXM4 | `[2, pp. 52, Appendix A]` |
| 功耗 | 标准配置最大TDP 400W；HGX A100 80GB CTS SKU最高500W | 500W只适用于Custom Thermal Solution变体，不是所有80GB SXM4的默认值 | `[1, p. 1, TDP and note 3]` |
| 形态与散热 | SXM4模组；通过HGX A100 server board部署 | 风冷、液冷和具体散热器由CTS/HGX/OEM系统配置决定 | `[1, p. 1, Form Factor and note 2]` `[3, Supported GPUs, Table 1]` |
| MIG | 最多7 instances；80GB profiles为1g.10gb、1g.10gb+me、1g.20gb、2g.20gb、3g.40gb、4g.40gb、7g.80gb | 各实例在硬件层隔离HBM、cache和compute资源；不同profile可用数量见官方表 | `[3, A100 MIG Profiles, Figure 17 and Table 12]` `[1, pp. 1-2]` |
| 媒体与专用单元 | full MIG profile显示5 NVDEC、1 JPEG、1 OFA和7 copy engines | MIG表对A100全GPU资源分配的程序员可见口径 | `[3, A100 MIG Profiles, Table 12]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | SXM4经HGX A100 server board接入NVLink/NVSwitch；官方列出4、8或16 GPU partner systems，DGX A100为8 GPU | 本SKU只提供600GB/s NVLink endpoint；GPU数和fabric聚合值属于系统 | `[1, p. 1, note 2 and Server Options]` |
| Scale-out | DGX/HGX系统可搭配InfiniBand或Ethernet连接多节点 | NIC、switch和网络带宽不在SXM4模组内 | `[2, p. 52 and Appendix A]` |
| 相邻产品 | A100 PCIe 80GB为300W、1,935GB/s的PCIe card，经NVLink Bridge最多连接2卡 | 不用PCIe卡的功耗、带宽、散热和bridge拓扑补写SXM4 | `[1, p. 1, specifications and note 2]` |
| 早期40GB配置 | A100 SXM4 40GB为HBM2、1,555GB/s，MIG最小profile为5GB | 2020-05首发A100/DGX的320GB系统是40GB时代资料，不用于80GB SKU发布或容量 | `[2, pp. 34-36]` `[4, opening paragraphs]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| 当前硬件销售状态 | 未公开统一结论 | NVIDIA当前产品页、MIG/NIM支持表、vGPU生命周期页 | 只确认软件仍支持；生产、现货和OEM可用性不作推断 `[5, Relationship Between Hardware and Software Support]` |
| 80GB HBM2e stack组织 | 未找到SKU直接文本 | 80GB datasheet、A100白皮书；白皮书的五stack/每stack八die描述绑定40GB HBM2 | 只记录80GB HBM2e、A100实现的10个controller和5,120-bit接口，不复制40GB单stack组织 |
| GPU Boost Clock | 直接值的版本边界 | 白皮书Table 4给A100 1,410MHz，80GB datasheet不列clock | 作为A100实现值保留，并注明不是固定运行频率或80GB专属重述 |
| PCIe/NVLink带宽方向 | 来源使用不同表示 | datasheet给64GB/s和600GB/s；白皮书给PCIe每方向31.5GB/s、NVLink每link每方向25GB/s | 按白皮书解释聚合方向，但不把系统fabric带宽混入单GPU端点 |
| 400W与500W | 配置差异 | 标准80GB SXM对HGX A100 80GB CTS | 主规格为400W；500W仅作为CTS上限 |
| 产品页系统名称 | 当前区域页存在错写 | 部分区域A100页面Server Options误写HGX/DGX H100；A100 datasheet写HGX/DGX A100 | 系统边界采用datasheet，不沿用明显错写 |
| 108 SM与full GA100 128 SM | 对象层级差异 | 白皮书Figure 6 | 产品值采用108；128只描述full die设计，不计入SKU资源 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | NVIDIA，*NVIDIA A100 Tensor Core GPU Datasheet*，2188504，2022-05 | 官方datasheet | 80GB SXM峰值、HBM2e/带宽、PCIe/NVLink、MIG、功耗、形态和系统边界 | [本地PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/NVIDIA_A100_Tensor_Core_GPU_Datasheet_2188504.pdf) |
| `[2]` | NVIDIA，*NVIDIA A100 Tensor Core GPU Architecture In-Depth*，2020 | 官方架构白皮书 | GA100/A100资源、SM与存储、数值路径、稀疏、L2、NVLink、MIG和RAS | [本地PDF](../../../原始资料/论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf) |
| `[3]` | NVIDIA，*MIG User Guide: Supported GPUs and A100 MIG Profiles* | 当前官方开发文档 | A100-SXM4 80GB身份、CC8.0、最大实例数和80GB profiles | <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html>；<https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-mig-profiles.html> |
| `[4]` | NVIDIA，*NVIDIA Doubles Down: Announces A100 80GB GPU, Supercharging World's Most Powerful GPU for AI Supercomputing*，2020-11-16 | 官方发布公告 | 80GB版本发布日期、HBM2e定位、初始系统供货和40GB边界 | <https://nvidianews.nvidia.com/news/nvidia-doubles-down-announces-a100-80gb-gpu-supercharging-worlds-most-powerful-gpu-for-ai-supercomputing> |
| `[5]` | NVIDIA，*vGPU Software Lifecycle on Supported GPUs*，2026-08-03 | 当前官方生命周期文档 | 软件支持与OEM硬件市场可用性的边界 | <https://docs.nvidia.com/vgpu/news/vgpu-software-lifecycle-on-supported-gpus/index.html> |
| `[6]` | NVIDIA，*Convolutional Layers User's Guide* | 当前官方性能指南 | A100-SXM4-80GB测试环境的108 SM直接确认 | <https://docs.nvidia.com/deeplearning/performance/dl-performance-convolutional/index.html> |
| `[7]` | NVIDIA，*Support Matrix for NVIDIA NIM for Large Language Models* | 当前官方支持文档 | 精确设备名`NVIDIA-A100-SXM4-80GB`与当前软件支持 | <https://docs.nvidia.com/nim/large-language-models/latest/support-matrix.html> |

## 9. 完成检查

- [x] SKU身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内D2D互联与HBM、设备互联和系统聚合带宽已经分开
- [x] SKU互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：NVIDIA A100 SXM4 80GB的单模组主语、A100实际108 SM/6,912 CUDA Core/432 Tensor Core、分精度峰值、80GB HBM2e、2,039GB/s、PCIe Gen4、第三代NVLink、MIG、400W标准TDP和SXM4形态已由NVIDIA一手资料固定。full GA100的128 SM、A100 40GB、A100 PCIe 80GB以及HGX/DGX系统值没有下放到本SKU；当前硬件销售状态和80GB HBM2e stack组织保持缺失。
