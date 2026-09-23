# Google Cloud TPU v6e one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

Trillium在Cloud API、日志和技术文档中统一称为TPU v6e。本卡采用`v6e-1`/`ct6e-standard-1t`对应的一颗TPU v6e chip作为正式比较对象。该单芯片VM主要用于测试；四芯片half-host、八芯片full-host、slice、Pod及Multislice是更高层配置。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | Cloud TPU v6e | `[1, page title and opening]` |
| 产品家族 | Google Cloud TPU v6e（Trillium） | Trillium是发布名称，技术界面使用v6e | `[1, opening]` |
| 完整 SKU | Google Cloud TPU v6e one chip | 对应`v6e-1`、`1×1` slice和`ct6e-standard-1t` | `[1, Supported configurations and VM types]` |
| 对象形态 | 官方per-chip云配置 | 一颗chip、一个TensorCore；不是完整八芯片host | `[1, System architecture and Supported configurations]` |
| 架构代际 | 第六代Cloud TPU，v6e/Trillium | 一个TensorCore、两个256×256 MXU和两个SparseCore的实现 | `[1, opening and System architecture]` `[2, TPU architecture specifications]` |
| 发布与可用状态 | 2024-05-14宣布、计划当年稍晚开放；2024-12-11 发布 GA 博客公告，release notes 于 12-16 记录 GA；当前仍有按chip-hour计价的Trillium资源 | 首次公开、GA和当前云服务状态分开 | `[5, page date and Learn more]` `[6, page date and opening]` `[7, Regional pricing]` `[9, December 16, 2024]` |
| 厂商定位 | 同时面向训练、fine-tuning与serving/inference | 不是仅推理或仅训练的产品 | `[1, opening]` `[6, opening and workload list]` |
| 主要设计取向 | Google 设计团队跨代论文称 Trillium focused on inference | 设计侧重与上一行支持用途分别记录；不据此否定训练支持 | `[10, p.1, footnote 2]` |
| 目标 workload | transformer、text-to-image、CNN、dense/MoE LLM和embedding-intensive模型 | 产品和系统定位，不把模型参数写成芯片属性 | `[1, opening]` `[6, workload list]` |
| 产品目标 | 相对v5e扩大MXU，提高单芯片算力、HBM容量/带宽和ICI带宽，并以第三代SparseCore处理大型embedding | 单芯片增量与系统扩展目标分开 | `[5, opening; 4.7X increase; 2X ICI and HBM]` |

本卡包含：单颗TPU v6e的一个TensorCore、两个256×256 MXU、两个SparseCore、BF16/FP8/INT8峰值、32GB或32GiB HBM、四端口ICI和per-chip功耗证据。

本卡不包含：1-chip VM的CPU与RAM、八芯片host、256-chip Pod、跨Pod Jupiter网络及Multislice聚合资源。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 一个TensorCore，含2个MXU、1个vector unit和1个scalar unit；两个第三代SparseCore | TPU v6e架构共享 | 复用[TPU v6e架构资料](../架构/Google_TPU_v6e_Trillium_架构卡.md)，本卡补配置值 | `[1, System architecture]` `[3, TPU chip and SparseCore]` |
| die | TPU v6e ASIC；工艺、die area、晶体管数和chiplet边界未公开 | TPU v6e代际共享 | 不从相邻代际或系统照片补值 | `[8, p. 2, Table 1 and footnote 1]` |
| package | 未公开 | 未找到HBM stack数量、interposer、基板或封装尺寸 | 只记录per-chip HBM和ICI规格 | `[1, System architecture]` |
| 产品配置 | Google Cloud TPU v6e one chip | 不适用 | 正式比较单位；实际用途以测试为主 | `[1, Supported configurations and VM types]` |
| 相关系统 | 1/4/8-chip VM、8-chip host、1至256-chip slice和256-chip Pod | 多种部署规模 | 只说明对象边界和ICI拓扑 | `[1, Supported configurations and VM types]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每芯片1个TensorCore；TensorCore有2个256×256 MXU、1个vector unit和1个scalar unit | 单颗v6e chip | `[1, System architecture]` `[3, TPU chip]` |
| 执行模型与调度 | MXU是由multiply-accumulator构成的systolic array；vector unit处理activation、softmax等通用计算，scalar unit处理控制流、地址计算和维护 | v6e指令格式、调度宽度和流水级未公开 | `[3, TPU chip]` |
| 局部存储与数据搬运 | TensorCore使用局部VMEM，SparseCore使用局部scratchpad SPMEM并以HBM保存大数据集；公开资料未给v6e VMEM/SPMEM容量、带宽或完整搬运路径 | VMEM只供TensorCore使用；SPMEM由SparseCore使用，二者不是cache | `[4, Memory hierarchy and Overall memory management strategy]` |
| 数值与累加路径 | BF16矩阵乘法采用FP32累加；另有918TFLOPS FP8和1,836TOPS INT8峰值 | BF16说明来自当前TPU通用架构页；FP8/INT8的乘积、累加、输出与舍入语义未公开 | `[3, TPU chip]` `[1, System architecture]` `[2, TPU architecture specifications]` |
| 稀疏与专用单元 | 每芯片2个第三代SparseCore；每个SparseCore有16个compute tile，SIMD宽度为8（F32）或16（BF16），支持动态执行、集中控制和排序/过滤/prefix-sum等跨lane操作 | 面向embedding及其他不规则、稀疏访问；未公开v6e专用MoE router | `[3, SparseCore]` `[4, Specifications at a glance and Introduction]` `[5, opening]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 1个TensorCore、2个256×256 MXU、2个SparseCore | 单颗v6e chip | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 片上存储 | VMEM和SparseCore SPMEM存在，但容量未公开 | 局部scratchpad；不沿用v5e/v5p数值 | `[4, Memory hierarchy and Overall memory management strategy]` |
| 片内互联 | 未公开 | 未找到v6e NoC、crossbar、路由或一致性结构 | `[1, System architecture]` |
| 内存控制器与PHY | 连接32GB或32GiB HBM并提供4个ICI端口；控制器、PHY数量和宽度未公开 | per-chip端点，不等同于封装组成 | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 工艺与物理规模 | 未公开 | Google作者资料将v6e die size和technology标为N.A. | `[8, p. 2, Table 1 and footnote 1]` |
| 封装组成 | 未公开 | HBM类型、stack数量、interposer、基板与package尺寸均未找到 | `[1, System architecture]` `[8, p. 2, Table 1]` |
| 封装内互联 | 未公开；未确认compute chiplet | ICI是芯片间互联，不写成封装内D2D | `[1, System architecture]` |
| RAS | 未公开芯片级ECC、重放或隔离细节 | 当前ICI resiliency列表未包含v6e | `[3, Cloud TPU ICI resiliency]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 1个TensorCore、2个256×256 MXU、2个SparseCore | 单芯片 | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 时钟 | 未公开；发布文章只称提高了clock speed | 不由峰值和阵列规模反推 | `[5, 4.7X increase in compute performance per Trillium chip]` |
| 理论峰值 | 918TFLOPS BF16；918TFLOPS FP8；1,836TOPS INT8 | per-chip；未说明dense/sparse、FMA计数及FP8/INT8完整数值语义 | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 内存类型与容量 | v6e页写32GB HBM；机器规格页和Google作者论文写32GiB HBM，代际未公开 | 三份一手资料单位不同，按原文并列 | `[1, System architecture]` `[2, TPU architecture specifications]` `[8, p. 2, Table 1]` |
| 内存带宽 | 当前Cloud页1,638GB/s；Google作者论文1,640GB/s | per-chip；原文未说明读写方向和有效负载 | `[1, System architecture]` `[8, p. 2, Table 1]` |
| 主机接口 | 未公开 | VM/NUMA关系不等于PCIe等物理接口规格 | `[1, VM types]` |
| 设备互联端点 | 4个ICI端口，800GB/s双向聚合带宽 | per-chip；单端口及单方向速率未公开 | `[1, System architecture]` |
| 内存访问语义 | HBM可由SparseCore、TensorCore和host系统访问；SparseCore将embedding table与共享数据放在HBM，以SPMEM暂存活跃数据 | 文档未给硬件cache coherence、页迁移或远程HBM透明访问语义 | `[4, High bandwidth memory and Overall memory management strategy]` |
| 跨设备集合通信能力 | 未找到v6e单芯片专用collective engine或硬件offload吞吐 | Pod表的102.4TB/s all-reduce是系统聚合值 | `[1, System architecture]` |
| 功耗 | TDP未公开；Google fleet实测平均153W/TPU（不含host） | 153W是生产fleet的per-TPU平均值，不是TDP或峰值；整机平均2,173W不得下放 | `[8, p. 2, Table 1]` |
| 形态与散热 | 官方per-chip云配置；封装和散热形式未公开 | `v6e-1`是1×1 sub-host VM，主要用于测试，不是零售卡 | `[1, Supported configurations and VM types]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | v6e采用2D torus，支持1×1至16×16 slice，完整Pod为256 chips | 单芯片只保留4个ICI端口和800GB/s双向端点；234.9PFLOPS、102.4TB/s all-reduce和3.2TB/s bisection都是Pod值 | `[1, System architecture and Supported configurations]` |
| Scale-out | 机器规格表按chip归一化列100Gbps DCN；Multislice在slice内使用ICI、跨slice使用DCN，发布文章称可扩至数百Pod | 100Gbps是Cloud系统分配口径，不足以证明芯片集成独立NIC；Jupiter网络、Titanium IPU和跨Pod带宽不是芯片属性 | `[2, TPU architecture specifications]` `[3, Multislice versus single slice]` `[5, opening and 2X ICI and HBM]` |
| 系统可靠性 | 未找到v6e的ICI故障绕行说明 | 不套用v4、v5p或TPU7x的ICI resiliency | `[3, Cloud TPU ICI resiliency]` |
| 相关系统 | full host有8 chips和1,536GiB DRAM；1-chip VM有44 vCPU/176GB RAM，4-chip VM为180/720GB，8-chip VM为360/1,440GB | host DRAM、VM RAM、CPU与NIC不是chip内资源；1,536GiB物理host值也不同于1,440GB VM分配值 | `[1, System architecture and VM types]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| HBM容量单位 | 一手资料口径不同 | v6e专页写32GB；机器规格页和Google作者论文写32GiB | 原单位并列，不静默换算 |
| HBM带宽 | 一手资料相差2GB/s | 当前Cloud页写1,638GB/s；2025年Google作者论文写1,640GB/s | 采用当前Cloud页作服务口径，同时保留论文硬件口径 |
| 低精度峰值 | 官方页面字段不同 | v6e专页列BF16与INT8；机器规格页列BF16与FP8 | 三项均按各自精度记录，不把INT8与FP8互相换算 |
| MXU每周期运算数 | 通用文档内部不自洽 | 同一段称v6e为256×256 MXU，又统一写每MXU 16K MAC/cycle | 只采用阵列尺寸和厂商per-chip峰值，不引用16K MAC/cycle |
| 工艺、die、package与HBM代际 | 未公开 | 当前产品页、机器规格页、Google作者论文 | 不从相邻代际或第三方资料补值 |
| VMEM/SPMEM容量和数据搬运 | 未公开完整配置 | OpenXLA页确认存储类型和管理角色，但未给v6e容量与完整DMA结构 | 保留缺失，不把其他TPU代际数值下放 |
| 时钟、主机接口和TDP | 未公开 | 发布文章只说提高时钟，生命周期论文只给fleet实测平均功耗 | 不反推具体时钟、PCIe规格或TDP |
| per-chip与系统聚合值 | 对象层级不同 | v6e同页并列chip、host、VM和Pod数据 | 只有明确per-chip字段进入SKU配置 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Google Cloud，*TPU v6e* | 当前官方产品与系统文档 | 身份、per-chip规格、1/4/8-chip VM、slice和Pod边界 | <https://docs.cloud.google.com/tpu/docs/v6e> |
| `[2]` | Google Cloud，*TPU machines in accelerator-optimized machine family* | 当前官方机器规格页 | FP8、SparseCore、HBM单位和VM配置交叉核对 | <https://docs.cloud.google.com/compute/docs/tpus/tpu-machines> |
| `[3]` | Google Cloud，*TPU architecture* | 当前官方通用架构文档 | MXU形态与数值语义、slice/Multislice和ICI resiliency边界 | <https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm> |
| `[4]` | OpenXLA，*A deep dive into SparseCore for Large Embedding Models (LEM)* | 官方架构与编译文档 | v6e SparseCore数量、tiles、SIMD、动态执行和存储管理 | <https://openxla.org/xla/sparsecore> |
| `[5]` | Google Cloud，*Announcing Trillium, the sixth generation of Google Cloud TPU*，2024-05-14 | 官方发布文章 | 首次公开、架构增量、训练/serving定位和初始可用计划 | <https://cloud.google.com/blog/products/compute/introducing-trillium-6th-gen-tpus> |
| `[6]` | Google Cloud，*Announcing the general availability of Trillium, our sixth-generation TPU*，2024-12-11 | 官方GA公告 | GA日期、训练/inference定位和系统边界 | <https://cloud.google.com/blog/products/compute/trillium-tpu-is-ga> |
| `[7]` | Google Cloud，*Cloud TPU pricing* | 当前官方定价页 | Trillium当前仍按chip-hour提供 | <https://cloud.google.com/tpu/pricing> |
| `[8]` | Ian Schneider等（Google），*Life-Cycle Emissions of AI Hardware: A Cradle-To-Grave Approach and Generational Trends*，2025 | Google作者一手硬件生命周期论文 | HBM硬件口径、die/工艺未披露状态和fleet实测功耗 | [本地PDF](../../../原始资料/论文/Google_TPU/03_系统与性能补充/2025_Life_Cycle_Emissions_AI_Hardware.pdf) |
| `[9]` | Google Cloud，*Cloud TPU release notes* | 官方服务发布记录 | 2024-12-16 的 Trillium GA 记录，与 12-11 博客公告分开 | <https://docs.cloud.google.com/tpu/docs/release-notes> |
| `[10]` | Norman P. Jouppi 等，*Google's Training Supercomputers from TPU v2 to Ironwood*，2026 | Google 设计团队架构论文 | Trillium 的主要设计取向 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2026_TPUv2_to_Ironwood_Five_Generations.pdf) |

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

复核结论：Google Cloud TPU v6e单芯片的主语、一个TensorCore、两个256×256 MXU、两个SparseCore、BF16/FP8/INT8峰值、32GB或32GiB HBM、四个ICI端口和800GB/s双向带宽已由Google一手资料固定。153W只作为不含host的fleet实测平均值记录，1-chip VM、8-chip host、slice、Pod和Multislice没有下放；工艺、die/package、HBM代际、VMEM/SPMEM容量、时钟、主机接口和TDP保持缺失。
