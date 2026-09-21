# Google Cloud TPU7x one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡采用Google官方per-chip口径的一颗TPU7x（Ironwood）chip作为正式比较对象。一颗物理chip/package包含两个独立compute chiplet，并在JAX等框架中暴露为两个device；单个device/chiplet不是完整芯片。Google Cloud最小部署单元是`2×2×1`、4 chips、1个full-host VM，不存在one-chip TPU7x Cloud slice。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | Cloud TPU7x | `[1, page title and opening]` |
| 产品家族 | Google Cloud TPU7x（Ironwood） | Ironwood是第七代TPU家族，TPU7x是其首个Cloud release | `[1, opening]` `[6, November 24, 2025]` |
| 完整 SKU | Google Cloud TPU7x one chip | 官方per-chip规格与定价口径，不是可单独申请的VM | `[1, System architecture and TPU7x VM]` `[8, Chips vs Cores vs VMs]` |
| 对象形态 | 双compute-chiplet的单颗chip/package | 一颗chip含2个chiplet，并暴露为2个framework devices | `[1, Dual-chiplet architecture and Programming model]` `[4, pp. 14-15]` |
| 架构代际 | 第七代Cloud TPU，Ironwood | 第一代dual-compute-die TPU、第四代SparseCore | `[4, pp. 11 and 14]` |
| 发布与可用状态 | 2025-04-09首次宣布；2025-11-24 Preview；2026-03-31 GA，当前仍为GA | 2025-11-06博客只预告数周后可用，正式GA日期采用release notes | `[6, November 24, 2025 and March 31, 2026]` `[7, page date and opening]` |
| 厂商定位 | 首发强调inference；当前覆盖大规模training与inference | 当前包括pre-training、sampling和decode-heavy inference | `[1, opening]` `[7, Ironwood section]` |
| 目标 workload | 大型dense/MoE模型、pre-training、reinforcement learning、sampling、低延迟serving与decode-heavy inference | workload定位，不把模型规模或KV Cache写成芯片属性 | `[1, opening]` `[4, pp. 2, 11 and 14]` |
| 产品目标 | 提升reasoning model训练与serving的性能、perf/W和大规模scale-up能力 | 相对代际表述，不下放Pod聚合成绩 | `[4, pp. 2 and 14]` |

本卡包含：完整TPU7x package的两个compute chiplet、一个SerDes chiplet、两个TensorCore、四个physical MXU、四个SparseCore、128MiB VMEM、192GiB HBM3E、六条ICI link、PCIe Gen5×16 host I/O，以及per-chip峰值。

本卡不包含：单chiplet/device的资源、四芯片VM/tray、cube、9,216-chip Pod、Multislice以及跨Pod网络的聚合资源。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 每个compute chiplet有1个TensorCore、2个SparseCore；每个TensorCore有2个MXU、VPU/VMEM和TCS | TPU7x架构共享 | 复用[TPU7x架构资料](../架构/Google_TPU7x_Ironwood_架构卡.md)，本卡固定完整chip配置 | `[4, p. 15]` `[5, p. 2, Table 1]` |
| die/chiplet | 2个compute chiplet和1个独立SerDes chiplet | TPU7x代际共享 | dual-compute-die不等于package内只有两个die | `[4, pp. 14-15]` |
| package | 2个compute chiplet、1个SerDes chiplet和8个HBM3E stack | TPU7x代际共享 | 正式物理对象；工艺、尺寸和interposer细节未公开 | `[4, pp. 14-15]` |
| 产品配置 | Google Cloud TPU7x one chip | 不适用 | 正式比较单位，但不是可租用的一芯片VM | `[1, System architecture and TPU7x VM]` |
| 相关系统 | 4-chip VM/tray、64-chip cube、最高9,216-chip Pod及Multislice | 多种部署规模 | 只用于划定host、ICI和DCN边界 | `[1, TPU7x VM and Supported configurations]` `[5, p. 2, Table 1]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量与控制路径 | 完整chip有2个TensorCore、4个physical MXU；同一组MXU在BF16模式为4个256×256 array，在FP8模式为4个512×512 array；每个TensorCore另有VPU/VMEM、TCS和2个XLU | FP8与BF16阵列描述不是两组独立physical MXU | `[4, p. 15]` `[5, pp. 2 and 6]` |
| 执行模型与调度 | MXU采用systolic array；VPU每vector lane有4个general-purpose ALU，vector register组织为16×256 | 指令格式、发射宽度、时钟与pipeline depth未公开 | `[5, pp. 3-6]` |
| 局部存储与数据搬运 | 完整chip的VMEM总计128MiB；每个software-visible TensorCore/device view为64MiB；HBM与VMEM之间使用asynchronous DMA | VMEM是compiler-managed local memory，不是package级共享cache | `[5, pp. 2-4, Table 1 and Figure 2]` `[3, Scoped VMEM tuning]` |
| 数值与累加路径 | BF16 multiply采用FP32 accumulation；完整chip峰值为2,307TFLOPS BF16和4,614TFLOPS FP8 | 官方性能指南讨论 E4M3/E5M2；其 RNE 是编程建议，完整硬件累加/输出、舍入与稀疏条件仍未完整披露 | `[5, pp. 2 and 4]` `[1, System architecture]` `[3, Low-precision training with FP8]` |
| 稀疏与专用单元 | 完整chip有4个第四代SparseCore，每个有SCS和16个tiles；可处理embedding、排序/过滤等不规则工作，并卸载pretraining和RL fine-tuning中的collective | 第四代SparseCore为第三代的2.4× FLOPS是相对值；未找到独立MoE router | `[4, p. 11]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 2个compute chiplet；每个含1个TensorCore、2个MXU和2个SparseCore | 完整chip合计2 TensorCore、4 MXU和4 SparseCore | `[4, pp. 14-15]` `[5, p. 2, Table 1]` |
| 片上存储 | 完整chip共128MiB VMEM，两个TensorCore/device view各64MiB；SparseCore有TileSpmem但容量未公开 | 两个compute chiplet具有各自的memory/DMA interconnect和专用memory space | `[1, Dual-chiplet architecture]` `[3, Scoped VMEM tuning]` `[4, pp. 11 and 15]` |
| 片内与封装内互联 | 两个compute chiplet的memory/DMA interconnect经D2D连接；D2D带宽被描述为一条1D ICI link的6倍，并由collective operation管理 | 官方只给相对量，不反推绝对D2D带宽或一致性语义 | `[1, Dual-chiplet architecture]` `[4, p. 15]` |
| 内存控制器与PHY | 每个compute chiplet连接4个HBM3E controller/stack；完整package为8个8-hi HBM3E stack | 总容量192GiB | `[4, pp. 14-15]` `[5, p. 6, Figure 3]` |
| 工艺与物理规模 | 未公开 | 未找到process node、compute/SerDes die area、晶体管数或package尺寸 | `[4, pp. 14-15]` |
| 封装组成 | 2个compute chiplet、1个独立SerDes chiplet和8个HBM3E stack | SerDes chiplet含ICI router、6-link stack和6×112G SerDes octals+PCS | `[4, p. 15]` |
| RAS与安全 | iROT、functional BIST、silent data corruption mitigation、logic repair、secure boot和secure test/debug；支持PCIe DOE/CMA | 芯片/package能力，不与Pod级OCS绕障混写 | `[4, pp. 14 and 21]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 2个TensorCore、4个MXU、4个SparseCore | 完整双compute-chiplet chip/package | `[1, System architecture]` `[4, p. 15]` |
| 时钟 | 未公开；支持dynamic voltage/frequency scaling | 不由峰值和阵列规模反推 | `[4, p. 14]` |
| 理论峰值 | 2,307TFLOPS BF16；4,614TFLOPS FP8 | per-chip；未说明structured-sparse条件或FMA计数规则 | `[1, System architecture]` `[5, p. 2, Table 1]` |
| 内存类型与容量 | 8个8-hi HBM3E stack，192GiB/chip | 当前产品页其他段落写192GB和96GB/chiplet，主值采用规格表与固定论文的GiB口径 | `[1, System architecture and Dual-chiplet architecture]` `[4, pp. 14-15]` |
| 内存带宽 | 当前Cloud页7,380GB/s；Hot Chips与固定论文为约7.3TB/s或7,300GB/s | per-chip peak；官方未解释舍入或版本差异 | `[1, System architecture]` `[4, p. 14]` `[5, p. 2, Table 1]` |
| 主机接口 | PCIe Gen5×16 per TPU；另有PCIe Gen2×1 management path | Gen5×16是host I/O；Gen2×1连接管理路径，不是第二条host data接口 | `[4, pp. 15 and 22]` |
| 设备互联端点 | 6条ICI links，每条100GB/s per direction；单芯片双向物理聚合1,200GB/s | 对外scale-up接口；不与封装内D2D混用 | `[5, pp. 2 and 7]` `[1, System architecture]` |
| DCN分配 | 100Gbps/chip | Cloud系统按chip归一化口径，不足以证明芯片集成独立NIC | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 内存访问语义 | 两个compute chiplet有各自96GB或96GiB HBM空间，不形成统一MegaCore内存；跨chiplet数据移动使用collective | framework把每个chiplet暴露为独立device | `[1, Dual-chiplet architecture and Programming model]` |
| 跨设备集合通信能力 | SparseCore可卸载collective并与TensorCore并行；绝对吞吐未公开 | 4-chip VM或Pod的collective性能不下放 | `[4, p. 11]` |
| 功耗 | TDP、平均与峰值功耗均未公开 | 约2×前代perf/W和相对Pod TDP不能换算成per-chip瓦数 | `[4, p. 2]` `[5, p. 2, Table 1]` |
| 形态与散热 | cold-plate液冷；4个TPU组成一块液冷tray | tray采用芯片和voltage regulator并行水路；流量和热阻未公开 | `[4, pp. 14 and 22]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | TPU7x采用3D mesh/torus；最小`2×2×1`为4 chips/1 VM，`4×4×4`为64-chip cube，最高可扩到9,216-chip Pod | 单芯片只保留6条ICI link和1,200GB/s双向端点；Pod的42.5 FP8 ExaFLOPS、1.77PB HBM等均为聚合值 | `[1, Supported configurations]` `[5, p. 2, Table 1]` |
| Scale-out | 每chip的Cloud DCN口径为100Gbps；Multislice在slice内使用ICI、slice间经host/DCN通信 | 多Pod扩展和Jupiter网络不是芯片属性 | `[1, System architecture]` `[2, TPU architecture specifications]` |
| 系统可靠性 | 芯片/package提供BIST、SDC mitigation与logic repair；Pod通过OCS和ICI resiliency处理更高层故障 | 芯片级和Pod级机制分开 | `[4, pp. 2 and 14]` |
| 相关系统 | 每个`tpu7x-standard-4t` full-host VM固定4 chips、224 vCPU、960GB RAM、2 NUMA nodes；tray也有4 chips | 4-chip VM合计768GiB HBM；CPU、RAM、NIC与tray connector不是chip内资源 | `[1, TPU7x VM]` `[2, TPU7x machine types]` `[4, p. 22]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| one chip与device | 官方对象层级不同 | 一个物理chip含2个compute chiplet，并暴露为2个framework devices；最小Cloud VM含4 chips | 资料卡主语固定为完整chip/package，不把device或VM误计成芯片 |
| HBM容量单位 | 当前产品页内部不一致 | 规格表与机器页写192GiB，叙述段写192GB、每chiplet 96GB | 主规格采用192GiB，保留原文单位差异 |
| HBM带宽 | 一手资料相差80GB/s | 当前Cloud页7,380GB/s；Hot Chips/固定论文约7.3TB/s或7,300GB/s | 采用当前Cloud配置作主值，同时保留固定资料口径 |
| D2D带宽 | 只有相对描述 | 当前产品页写一条1D ICI link的6倍；未说明方向、协议和有效负载 | 不从ICI聚合值推算D2D绝对带宽 |
| ICI每轴口径 | 当前文档措辞不充分 | 规格表给1,200GB/s双向per-chip；拓扑段另写200GB/s双向per axis | 分别保留原文，不用轴数自行推算 |
| MXU与FP8阵列 | 容易重复计数 | 论文将同一组physical MXU按BF16写256×256、按FP8写512×512 | 记为4个physical MXU的两种精度模式，不写成8个MXU |
| 工艺、物理规模与功耗 | 未公开 | 当前Cloud文档、Hot Chips和Google作者论文 | process、die/package尺寸、晶体管数、clock和TDP保持缺失 |
| 当前部署上限 | 硬件与服务入口不同 | 产品页最高9,216-chip Pod；当前GKE Autopilot常见shape表最高2,048 chips | 9,216作为Pod上限，2,048仅是当前服务入口配置边界 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Google Cloud，*TPU7x (Ironwood)* | 当前官方产品与系统文档 | 身份、per-chip规格、dual-chiplet、VM、slice和Pod边界 | <https://docs.cloud.google.com/tpu/docs/tpu7x> |
| `[2]` | Google Cloud，*TPU machines in accelerator-optimized machine family* | 当前官方机器规格页 | per-chip规格、4-chip VM和DCN交叉核对 | <https://docs.cloud.google.com/compute/docs/tpus/tpu-machines> |
| `[3]` | Google Cloud，*TPU7x (Ironwood) performance optimizations* | 当前官方性能与编程文档 | 64MiB per TensorCore 的 VMEM，以及 E4M3/E5M2 编程说明 | <https://docs.cloud.google.com/tpu/docs/ironwood-performance> |
| `[4]` | Norman P. Jouppi、Sridhar Lakshmanamurthy，*Ironwood: Delivering Best-in-Class Perf, Perf/TCO, and Perf/Watt for Reasoning Model Training and Serving*，Hot Chips 37，2025 | Google官方演讲 | package组成、TensorCore/SparseCore、HBM、ICI、PCIe、散热、RAS与安全 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2025_Ironwood_HotChips37.pdf) |
| `[5]` | Norman P. Jouppi等（Google），*Google's Training Supercomputers from TPU v2 to Ironwood*，2026 | Google作者一手跨代论文 | MXU/VPU、VMEM、HBM、ICI和Pod固定硬件口径 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2026_TPUv2_to_Ironwood_Five_Generations.pdf) |
| `[6]` | Google Cloud，*Cloud TPU release notes* | 官方状态记录 | 2025-11-24 Preview和2026-03-31 GA | <https://docs.cloud.google.com/tpu/docs/release-notes> |
| `[7]` | Google Cloud，*Introducing Ironwood TPUs and new innovations in AI Hypercomputer*，2025-04-09；*Announcing Ironwood TPUs General Availability*，2025-11-06 | 官方发布文章 | 首次公开、最初inference定位与后续training/serving定位 | <https://cloud.google.com/blog/products/compute/whats-new-with-ai-hypercomputer>；<https://cloud.google.com/blog/products/compute/ironwood-tpus-and-new-axion-based-vms-for-your-ai-workloads> |
| `[8]` | Google Cloud，*Cloud TPU pricing* | 当前官方定价页 | Ironwood仍按chip-hour定价，以及chip与VM计费边界 | <https://cloud.google.com/tpu/pricing> |

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

复核结论：Google Cloud TPU7x单芯片的主语已经固定为完整dual-compute-chiplet package，而不是单个framework device或四芯片VM。两个TensorCore、四个physical MXU、四个SparseCore、128MiB VMEM、192GiB HBM3E、2,307/4,614TFLOPS、六条ICI link、1,200GB/s双向ICI和PCIe Gen5×16均有Google一手资料支持；process、物理尺寸、clock、绝对D2D带宽和TDP保持缺失，4-chip VM、cube、Pod与Multislice资源没有下放。
