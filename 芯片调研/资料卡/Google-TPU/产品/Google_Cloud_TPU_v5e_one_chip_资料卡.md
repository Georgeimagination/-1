# Google Cloud TPU v5e one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

Google为TPU v5e提供`v5litepod-1`/`1×1`这一官方单芯片配置。本卡以其中一颗TPU v5e chip为正式比较对象。1-chip VM、8-chip host、slice、Pod与Multislice都是更高层对象，其CPU、DRAM、网络和聚合算力不属于本卡主语。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | Cloud TPU v5e | `[1, page title and System architecture]` |
| 产品家族 | Google Cloud TPU v5e | 训练与推理合一的Cloud TPU产品 | `[1, Configurations]` |
| 完整 SKU | Google Cloud TPU v5e one chip | 对应`v5litepod-1`、`1×1` slice与`ct5lp-hightpu-1t`部署配置 | `[1, Configurations and VM types]` |
| 对象形态 | 官方per-chip云配置 | 一颗chip、一个TensorCore；不是完整八芯片host | `[1, System architecture and Configurations]` |
| 架构代际 | TPU v5e | v5e chip实现 | `[1, System architecture]` |
| 发布与可用状态 | 2023-08-29进入Preview，2023-11-08 GA；当前仍提供按chip-hour计价的v5e资源 | 发布阶段和当前云服务状态分开 | `[3, page date and opening]` `[4, page date and opening]` `[5, Regional pricing]` |
| 厂商定位 | 同时面向训练与推理；训练资源侧重吞吐与可用性，serving资源侧重时延 | 不是仅训练或仅推理的芯片 | `[1, Configurations]` |
| 主要设计取向 | Google DeepMind 作者的 JAX 架构教程称 v5e 为 inference-optimized | 设计侧重与 Cloud 支持训练、推理两种用途分开记录 | `[8, What Is a TPU?]` |
| 目标 workload | medium- and large-scale training与inference，包括LLM和generative AI | 厂商发布定位，不等同于单芯片实测覆盖 | `[3, TPU v5e: The performance and cost efficiency sweet spot]` |
| 产品目标 | 在较低成本下兼顾性能、灵活性和扩展；提供1至256芯片配置 | 家族和云平台目标 | `[3, TPU v5e: The performance and cost efficiency sweet spot]` `[1, Configurations]` |

本卡包含：单颗TPU v5e chip的一个TensorCore、四个MXU、vector/scalar路径、BF16与INT8峰值、16GB HBM、四端口ICI和官方per-chip配置。

本卡不包含：1-chip VM的CPU与RAM、八芯片physical host、256-chip Pod及Multislice的聚合资源。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 一个TensorCore，含4个MXU、1个vector unit和1个scalar unit | TPU v5e架构共享 | 复用[TPU v5e架构资料](../架构/Google_TPU_v5e_架构卡.md) | `[1, System architecture]` |
| die | 单颗TPU v5e ASIC | 同代配置共享；工艺和物理规模未公开 | 不从相邻代际补值 | `[2, TPU chip]` |
| package | 未公开 | 未公开HBM stack、interposer和基板组成 | 只保留per-chip HBM与ICI接口事实 | `[1, System architecture]` |
| 产品配置 | Google Cloud TPU v5e one chip | 不适用 | 正式比较单位 | `[1, Configurations]` |
| 相关系统 | 1-chip VM、8-chip host、1至256-chip slice、256-chip Pod及Multislice | 多种部署规模 | 只说明对象边界与ICI拓扑 | `[1, Configurations and VM types]` `[2, TPU Pod, Slice and Multislice versus single slice]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每芯片1个TensorCore；TensorCore含4个128×128 MXU、1个vector unit和1个scalar unit | 每颗v5e chip | `[1, System architecture]` `[2, TPU chip]` |
| 执行模型与调度 | MXU由multiply-accumulator构成systolic array；MXU承担主要矩阵计算 | 当前通用TPU架构文档对v6e以前各代的说明；v5e指令调度细节未公开 | `[2, How a TPU works and TPU chip]` |
| 局部存储与数据搬运 | 单个TensorCore含128MiB VMEM与1MiB SMEM；HBM数据先搬入VMEM再参与计算，VMEM由程序/编译器管理，向量寄存器溢出也使用VMEM | VMEM是scratchpad（软件管理暂存空间），不是透明硬件cache；SMEM是可随机访问的标量控制存储，单指令读写32-bit值 | `[7, TPU_V5E branch]` `[8, What Is a TPU?]` `[9, Array Layouts; Placing operands in SMEM]` |
| 数值与累加路径 | 128×128 MXU每周期执行16K次multiply-accumulate；BF16乘法输入、FP32累加；芯片另有393TOPS INT8峰值 | 前者是v6e以前MXU的通用语义，后者是v5e单芯片铭牌值；INT8累加和输出格式未公开 | `[2, TPU chip]` `[1, System architecture]` |
| 稀疏与专用单元 | vector unit用于activation、softmax等通用计算，scalar unit用于控制流、地址计算和维护；未找到v5e SparseCore配置 | 当前通用架构文档只明确列出v5p、v6e和TPU7x的SparseCore | `[2, TPU chip and SparseCore]` |

### 3.1 低精度输入与局部布局

JAX的`is_matmul_supported`对v5e接受E5M2、E4M3B11FNUZ浮点输入组合，以及INT8/UINT8和INT4/UINT4的同类矩阵输入；这描述编译器接口接受的类型，不单独证明原生FP8执行或其吞吐。v5e分支将FP8峰值写为`0 / Not Available`，应记为未公开，不能填入零算力。典型向量布局按8×128个32-bit元素映射，最后两维的重排、归约和padding会影响执行；程序消耗过多VREG时可溢出到VMEM。[7, is_matmul_supported; TPU_V5E branch] [9, Array Layouts]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 1个TensorCore、4个128×128 MXU、1个vector unit、1个scalar unit | 单颗v5e chip | `[1, System architecture]` `[2, TPU chip]` |
| 片上存储 | 128MiB VMEM、1MiB SMEM；典型32-bit向量寄存器tile为8×128，即4KiB | 单芯片只有一个TensorCore；VREG总数及VMEM绝对读写带宽未找到v5e专属公开值，JAX的CMEM=0也不用于证明物理单元不存在 | `[7, TPU_V5E branch]` `[9, Array Layouts; Placing operands in SMEM]` |
| 片内互联 | 未公开 | 不从TensorCore组成推断NoC或crossbar | `[1, System architecture]` |
| 内存控制器与PHY | 连接16GB HBM并提供4个ICI端口；控制器、HBM PHY和ICI PHY的物理实现未公开 | per-chip端点，不等同于封装结构 | `[1, System architecture]` |
| 工艺与物理规模 | 未公开 | 未找到工艺、die area或晶体管数的一手资料 | `[1, System architecture]` |
| 封装组成 | 未公开 | 16GB HBM是容量规格，不能据此推断stack数量或interposer | `[1, System architecture]` |
| 封装内互联 | 未公开；未确认独立compute chiplet | ICI是芯片间设备互联，不写成封装内D2D | `[1, System architecture]` |
| RAS | 未公开芯片级细节 | 当前通用ICI resiliency说明未列v5e | `[2, Cloud TPU ICI resiliency]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 1个TensorCore、4个128×128 MXU、1个vector unit、1个scalar unit | 单芯片 | `[1, System architecture]` `[2, TPU chip]` |
| 时钟 | 产品保证频率未公开；JAX scaling book以约1.5GHz说明MXU吞吐 | 开发者架构说明的近似工作频率，不能写为额定或boost时钟 | `[1, System architecture]` `[8, What Is a TPU?]` |
| 理论峰值 | Cloud：197TFLOPS BF16、393TOPS INT8；JAX硬件模型：197TFLOPS BF16、394TOPS INT8、788TOPS INT4 | 均为单芯片；393/394保留不同来源，INT4不是FP4；Cloud未说明完整FMA计数、稠密/稀疏和INT8累加语义 | `[1, System architecture]` `[7, TPU_V5E branch]` |
| 内存类型与容量 | 当前Cloud页为16GB HBM；Google作者论文为16GiB HBM2E | 两份一手资料的单位和代际标签不同，按原文并列 | `[1, System architecture]` `[6, p. 2, Table 1]` |
| 内存带宽 | 当前Cloud页为800GiB/s；Google作者论文为819GB/s | per-chip铭牌值；两者不是同一单位，且原文未说明读写方向和有效负载 | `[1, System architecture]` `[6, p. 2, Table 1]` |
| 主机接口 | 通过PCIe连接CPU host；开发者教程用于性能估算的带宽约16GB/s/TPU，接口代际、lane数与保证带宽未公开 | host的DCN（数据中心网络）不能当作TPU集成网口；教程的3.125GB/s/TPU DCN egress是host网络分摊量 | `[8, TPU Networking; TPU specs]` |
| 设备互联端点 | 4个ICI端口，400GB/s双向带宽 | per-chip聚合双向值；单端口速率未公开 | `[1, System architecture]` |
| 内存访问语义 | 未公开 | 未找到统一地址、一致性、远程访问或页迁移的v5e专属说明 | `[1, System architecture]` |
| 跨设备集合通信能力 | 未找到单芯片硬件offload单元；Pod表列51.2TB/s all-reduce带宽 | 后者是256-chip Pod系统值，不下放成芯片属性 | `[1, System architecture]` |
| 功耗 | TDP未公开；Google fleet实测平均66W/TPU（不含host） | 66W是生产fleet的per-TPU平均实测值，不是TDP、峰值或功耗上限；整机平均1,171W不得下放 | `[6, p. 2, Table 1; p. 12, Appendix B.2]` |
| 形态与散热 | 官方per-chip云配置；v5e accelerator tray采用heatsink与forced active cooling | 散热证据作用于tray，不是单芯片thermal specification；`v5litepod-1`为1×1 sub-host slice | `[1, Configurations and VM types]` `[6, p. 12, Appendix B.1]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | v5e Pod采用2D torus，最大256 chips；小slice需检查各轴是否具有wrap-around回环，scaling book以4×4 slice说明未达到16-chip轴长时无该轴回环 | 支持1×1、2×2、2×4直至16×16；单芯片4个ICI端口和400GB/s双向端点带宽不保证小slice中所有端口都可按完整环使用 | `[1, System architecture and Configurations]` `[8, TPU specs / ICI table footnote; Worked Problems, Question 5]` |
| Scale-out | Multislice在slice内使用ICI，跨slice使用数据中心网络 | DCN和多Pod规模不是单芯片集成规格 | `[2, Multislice versus single slice]` |
| 系统可靠性 | 未找到v5e的ICI故障绕行或系统冗余说明 | 不套用v4/v5p/TPU7x的ICI resiliency | `[2, Cloud TPU ICI resiliency]` |
| 相关系统 | full host有8 chips和512GiB DRAM；1-chip VM为`ct5lp-hightpu-1t`、24 vCPU、48GB RAM；full Pod为256 chips | host DRAM、VM RAM、CPU和NIC均不是chip内资源 | `[1, System architecture, Configurations and VM types]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| 工艺、die与package | 未公开 | v5e专页、当前TPU架构页和官方发布文章 | 不从v4、v5p或媒体资料补值 |
| 片上存储与片内互联 | VMEM/SMEM容量和软件管理语义已补充；片内互联未公开 | JAX v5e分支与Pallas文档提供局部存储证据；未公布NoC或crossbar结构 | 保留v5e寄存器总数和VMEM绝对读写带宽缺口，不套用v5p数值 |
| 时钟、主机接口和额定功耗 | 开发估算和PCIe路径已知，额定参数仍未公开 | scaling book给约1.5GHz和PCIe约16GB/s/TPU；生命周期论文给fleet平均功耗 | 不把估算值、VM/host资源或66W fleet平均值代替保证规格和TDP |
| INT8数值语义 | 未公开完整定义 | v5e专页只给393TOPS峰值，通用架构页只明确BF16乘法与FP32累加 | 原样保留厂商单位，不补写累加/输出格式 |
| SparseCore | 未找到v5e配置 | 当前架构页明确列v5p、v6e和TPU7x，但未列v5e | 写“未找到”，不据遗漏断言物理上不存在 |
| HBM容量、代际与带宽口径 | 一手资料冲突 | 当前英文页写16GB HBM、800GiB/s；2025年Google作者论文写16GiB HBM2E、819GB/s | 正文按原始单位并列，不静默换算或挑一个口径覆盖另一个 |
| `GB`与`GiB/s` | 官方混合单位 | 同一v5e规格表写16GB HBM与800GiB/s | 保留原始单位，不换算或统一 |
| per-chip与系统聚合值 | 对象层级不同 | 同一规格表并列chip、host与Pod数据 | 只把明确标为per-chip的算力、HBM和ICI写入SKU字段 |
| 当前服务边界 | 当前仍提供，但API维护方式变化 | v5e页称GKE与Cloud TPU API受支持，后者仅接收bug和security更新；定价页仍列多地区v5e | 写为当前可用，不据API维护状态推断硬件EOL |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Google Cloud，*TPU v5e* | 当前官方产品与架构文档 | TensorCore组成、per-chip规格、host/VM、slice、Pod和当前支持边界 | <https://docs.cloud.google.com/tpu/docs/v5e> |
| `[2]` | Google Cloud，*TPU architecture* | 当前官方通用架构文档 | MXU数值语义、TPU数据流、Pod/slice/Multislice、SparseCore和ICI resiliency边界 | <https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm> |
| `[3]` | Google Cloud，*Expanding our AI-optimized infrastructure portfolio: Introducing Cloud TPU v5e and announcing A3 GA*，2023-08-29 | 官方Preview公告 | Preview日期、训练/推理定位与初始规模 | <https://cloud.google.com/blog/products/compute/announcing-cloud-tpu-v5e-and-a3-gpus-in-ga> |
| `[4]` | Google Cloud，*Announcing Cloud TPU v5e GA for cost-efficient AI model training and inference*，2023-11-08 | 官方GA公告 | GA日期、training/inference合一定位 | <https://cloud.google.com/blog/products/compute/announcing-cloud-tpu-v5e-in-ga> |
| `[5]` | Google Cloud，*Cloud TPU pricing* | 当前官方定价页 | v5e仍按chip-hour在多地区提供 | <https://cloud.google.com/tpu/pricing> |
| `[6]` | Ian Schneider等（Google），*Life-Cycle Emissions of AI Hardware: A Cradle-To-Grave Approach and Generational Trends*，2025 | Google作者一手硬件生命周期论文 | HBM口径、生产部署、fleet实测功耗、TDP边界和tray散热 | [本地PDF](../../../原始资料/论文/Google_TPU/03_系统与性能补充/2025_Life_Cycle_Emissions_AI_Hardware.pdf) |
| `[7]` | The JAX Authors，*TPU hardware information*，2026-09-17快照 | 官方JAX源码 | v5e专属VMEM/SMEM、整数吞吐、输入类型与缺失值含义 | [本地源码](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-info-source.py)，<https://github.com/jax-ml/jax/blob/main/jax/_src/tpu_info.py> |
| `[8]` | Jacob Austin等，*How to Think About TPUs*，2026-09-17快照 | Google DeepMind作者的JAX架构教程 | VMEM、近似时钟、PCIe/DCN估算和ICI回环条件 | [本地原文](../../../原始资料/网页快照/Google/JAX/2026-09-17/scaling-book-tpus.md)，<https://jax-ml.github.io/scaling-book/tpus/> |
| `[9]` | The JAX Authors，*Pallas: TPU Details*，2026-09-17快照 | 官方编程文档 | scratchpad、向量布局、寄存器溢出与SMEM访问 | [本地原文](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-details.rst)，<https://docs.jax.dev/en/latest/pallas/tpu/details.html> |

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

复核结论：Google Cloud TPU v5e单芯片的主语、一个TensorCore、四个128×128 MXU、BF16/INT8峰值、16GB或16GiB HBM的一手口径、四个ICI端口和400GB/s双向带宽已由Google资料固定。66W只作为不含host的fleet实测平均值记录，未冒充TDP；1-chip VM、8-chip host、slice、Pod和Multislice没有下放。JAX补充了128MiB VMEM、1MiB SMEM、整数吞吐和PCIe路径；工艺、package、保证时钟、主机接口代际与lane数、额定功耗、INT8完整数值语义及SparseCore配置仍保留缺口。
