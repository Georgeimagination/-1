# Google Cloud TPU v4 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

Google 没有为 TPU v4 公布常规板卡 SKU。本卡采用官方规格表的单颗 TPU v4 chip 作为正式比较对象。四芯片 PCB、四芯片 host、slice、64-chip cube 与 4,096-chip Pod 都是更高层对象，其聚合值不属于本卡主语。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | Cloud TPU v4 | `[2, page title and System architecture]` |
| 产品家族 | Google Cloud TPU v4 | 不按名称数字推断芯片世代序号 | `[4, Google I/O 2021: Pushing the frontier of computing]` |
| 完整 SKU | Google Cloud TPU v4 one chip | 官方 per-chip 配置；不是云端 accelerator type 或四芯片 host | `[2, System architecture, key specifications]` |
| 对象形态 | TPU v4 package/chip 的官方 per-chip 配置 | Google未公开独立销售料号 | `[1, pp. 2-3, Figure 2]` |
| 架构代际 | TPU v4 | 两个TensorCore与四个SparseCore的实现 | `[1, pp. 2, 7, Table 4]` |
| 发布与可用状态 | 2021-05-18在Google I/O宣布；2022-05-12 官方博客宣布 Cloud TPU v4 Pod Preview；2022-10-12 GA 博客公告（部分地区页面显示 10-13）；当前仍受支持，但仅在`us-central2-b`且配额需人工批准 | 芯片宣布、云服务阶段和当前资源约束分开 | `[4, page date and Pushing the frontier of computing]` `[5, opening and Pricing]` `[3, Powering AI/ML workloads]` `[2, page note]` |
| 厂商定位 | 面向大规模机器学习训练、语言模型、推荐系统与计算机视觉 | TPU v4芯片及Pod平台定位；不是排他性指令能力 | `[4, Pushing the frontier of computing]` `[5, Pushing the boundaries of what's possible]` |
| 产品目标 | 提高相对TPU v3的单芯片算力、HBM带宽、SparseCore能力和大规模3D互联扩展性 | 单芯片与系统目标分层记录 | `[1, pp. 1, 7, Table 4]` |

本卡包含：单颗TPU v4的TensorCore/MXU/VPU/scalar路径、SparseCore、CMEM/VMEM/SpMEM、HBM2、PCIe/ICI端点、物理实现和公开的per-chip配置。

本卡不包含：四芯片PCB与host的聚合资源、Cloud accelerator type的资源计数、slice形状、OCS设备、Pod总算力/带宽和数据中心网络。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | TensorCore内的MXU、VPU、scalar unit和存储路径；SparseCore | TPU v4架构共享 | 复用 [TPU v4架构资料](../架构/Google_TPU_v4_架构卡.md) | `[1, pp. 2, 5-6]` `[6, TPU chip]` |
| die | 单个TPU v4 ASIC，7nm、<600mm²、22 billion transistors | TPU v4实现 | 不把四芯片板卡当成一颗die | `[1, p. 7, Table 4]` |
| package | 一个ASIC与四个HBM stack构成液冷package | 四个package装在一块PCB上 | package与board分开 | `[1, pp. 2-3, Figure 2]` |
| 产品配置 | Google Cloud TPU v4 one chip | 不适用 | 正式比较单位 | `[2, System architecture]` |
| 相关系统 | 4 chip/CPU host、slice、cube、4,096-chip Pod | 多种拓扑与规模 | 只保留单芯片端点和必要系统边界 | `[1, pp. 2-4, Table 4]` `[2, Configurations]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| TensorCore组成 | 每芯片2个TensorCore；每个TensorCore有4个128×128 MXU、1个128-lane VPU和1个scalar unit | 单芯片合计8个MXU、2个VPU；当前文档将scalar用于控制流、地址计算和维护 | `[1, p. 2]` `[2, System architecture, TensorCores]` `[6, TPU chip]` |
| MXU数值语义 | 每个128×128 MXU每周期执行16K multiply-accumulate；乘法输入为BF16，累加为FP32；v4另有8-bit mode | 数值语义来自TPU架构说明；INT8输入、乘积和累加的完整语义未公开 | `[6, TPU chip]` `[2, TensorCores]` |
| VPU | 每TensorCore的VPU有128 lanes，每lane 16 ALU | 用于activation、softmax等通用计算；ALU数据类型与持续吞吐未公开 | `[1, p. 2]` `[6, TPU chip]` |
| 执行与控制 | 单指令二维data-processor风格；芯片有2个processor、每core 1 thread | 公开处理器风格，不等同于CPU/GPU线程模型 | `[1, p. 7, Table 4]` |
| TensorCore局部存储 | 每TensorCore有16MiB VMEM；两者共享128MiB CMEM；VMEM是编译器管理的scratchpad，CMEM采用load-store访问 | 单芯片VMEM合计32MiB；CMEM与HBM不是硬件透明cache | `[1, pp. 2, 7, Table 4]` `[2, TensorCores]` |
| SparseCore | 每芯片4个SparseCore；每个SparseCore有16个compute tile与2.5MiB SpMEM，并含跨channel的排序、交换、gather/scatter等单元 | 单芯片SpMEM合计10MiB；面向embedding训练路径 | `[1, pp. 5-7, Figure 7 and Table 4]` |
| 数据搬运 | 改进DMA并原生支持512B粒度的高性能stride；TensorCore、SparseCore可与ICI通信重叠 | HBM到片上存储的显式搬运路径；queue深度和持续带宽未公开 | `[2, Other memory system differences]` `[1, pp. 5-6]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 物理组织 | 单片式TPU v4 ASIC；未公开chiplet | 一个chip/package | `[1, pp. 2-3, Figure 2]` |
| 工艺与规模 | 7nm，die area <600mm²，22 billion transistors | per-chip | `[1, p. 7, Table 4]` |
| 计算与片上存储 | 2 TensorCore、8个128×128 MXU、4 SparseCore；128MiB CMEM、32MiB VMEM、10MiB SpMEM、0.25MiB register file | 单芯片直接值；片上存储类型不能简单相加为同一cache | `[1, pp. 2, 7, Table 4]` |
| 封装组成 | ASIC中央加4个HBM stack，采用液冷package | Figure 2直接图示；HBM stack层数、bus width和interposer协议未公开 | `[1, pp. 2-3, Figure 2]` |
| 封装内D2D | 不适用 | 未披露独立compute chiplet；HBM接口不是chiplet D2D协议 | `[1, Figure 2]` |
| RAS与安全 | 当前文档称有改进security model；ICI resiliency可对一个cube及以上slice绕过光链路/OCS故障 | 芯片安全机制细节未公开；ICI resiliency是slice/系统能力，不下放成die内部单元 | `[2, Other]` `[6, Cloud TPU ICI resiliency]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 2 TensorCore、8个128×128 MXU、2个128-lane VPU、4 SparseCore | 单芯片；scalar unit为每TensorCore 1个 | `[1, pp. 2, 7, Table 4]` `[2, System architecture]` |
| 时钟 | 1,050MHz | per-chip clock rate | `[1, p. 7, Table 4]` |
| 理论峰值 | 275TFLOPS，BF16或INT8 | Google原始单位与标签；没有dense/sparse或FMA计数说明 | `[1, p. 7, Table 4]` `[2, key specifications]` |
| 内存 | 32GiB HBM2，1,200GB/s；全芯片统一HBM地址空间 | 单芯片；不是四芯片host的128GiB聚合 | `[1, p. 7, Table 4]` `[2, key specifications and Other memory system differences]` |
| 片上存储 | 128MiB CMEM、32MiB VMEM、10MiB SpMEM、0.25MiB register file | CMEM由两个TensorCore共享，VMEM为2×16MiB，SpMEM为4×2.5MiB | `[1, pp. 2, 5-7, Table 4]` |
| 主机接口 | PCIe Gen3 x16 direct connect | 单芯片host接口；峰值或有效带宽未公开 | `[2, Other]` |
| 设备互联端点 | 6条ICI link，每条每方向50GB/s | 跨代论文 Table 1 与 p.7 脚注4补充方向口径；有效 payload 未报告 | `[1, p. 7, Table 4]` `[7, Table 1 and p.7 footnote 4]` |
| 内存访问语义 | HBM在两个TensorCore之间为统一32GiB空间；CMEM是共享load-store scratchpad；SparseCore利用HBM与ICI形成系统级全局可寻址embedding memory | 前两项为芯片内，最后一项依赖多芯片系统和软件显式控制 | `[2, Other memory system differences and TensorCores]` `[1, pp. 5-6]` |
| 跨设备集合通信 | ICI支持芯片直接互联；SparseCore通过ICI执行embedding相关all-to-all与scatter/gather | 未公开单芯片独立collective offload吞吐或完整操作集合 | `[1, pp. 5-6]` |
| 功耗 | TDP未公开；当前Cloud文档列实测90/170/192W，原论文将其拆为idle 90W与生产应用min/mean/max 121/170/192W | 192W是测得上限，不是TDP；Google当前页面省略生产应用的121W minimum | `[2, key specifications]` `[1, p. 7, Table 4]` |
| 形态与散热 | 官方per-chip云配置；单package液冷，四个package装在一块PCB上 | 板卡、host和rack散热系统不写成单芯片规格 | `[1, pp. 2-3, Figure 2]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 板卡与host | 一块PCB装4个液冷package，板内4条ICI组成2×2 mesh；每个CPU host连接4颗芯片 | 本卡只保留一颗chip的端点；四芯片资源不聚合进SKU | `[1, pp. 2-3, Figure 2 and Table 4]` |
| Scale-up | TPU v4用3D mesh/torus；64-chip 4×4×4 cube可由OCS重构，最大Pod为4,096 chips | 拓扑、OCS、1.1 exaFLOPS、1.1PB/s all-reduce和24TB/s bisection均是系统值 | `[1, pp. 1-4]` `[2, key specifications and Configurations]` |
| Slice | slice是同一Pod内以ICI连接的一组chips，大小和三维形状由Cloud配置指定 | slice不是SKU；`v4-8`等accelerator type也不等于一颗chip | `[6, Slice and Topology]` `[2, Configurations]` |
| Scale-out | multislice通过数据中心网络连接多个slice，slice内仍走ICI | 数据中心NIC/带宽不在TPU v4 chip内 | `[6, Multislice versus single slice]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| TDP | 未公开 | TPU v4论文Table 4明确`N.A.`，Cloud文档只给测得功耗 | 不把192W测得上限写成TDP |
| 功耗标签 | 官方页面压缩口径 | Cloud文档写“measured min/mean/max 90/170/192W”；论文区分idle 90W与生产应用121/170/192W | 以论文完整表头解释，不把90W误写为生产负载minimum |
| INT8数值语义 | 未公开完整定义 | Cloud TPU v4页、ISCA论文 | 原样记录275TFLOPS（BF16或INT8），不改成未获支持的TOPS或推测累加格式 |
| ICI方向与有效载荷 | 方向已有补充，payload 未公开 | 跨代论文 Table 1 与 p.7 脚注4给每方向带宽 | 6 links、每条50GB/s/方向，不将物理带宽写为持续 payload |
| HBM封装细节 | 未公开 | Figure 2仅确认4个HBM stack | 不猜测stack高度、bus width、PHY或interposer |
| 安全实现 | 只公开“improved security model” | 当前TPU v4产品页 | 不扩写为加密、TEE或confidential computing |
| 当前服务边界 | 当前支持但受限 | v4页面称GKE和Cloud TPU API支持；API仅维护bug/security，`us-central2-b`配额需人工批准 | 写为当前仍可申请，不据API维护状态推断硬件EOL |
| per-chip与Pod数据 | 对象层级不同 | Cloud页面同表并列单芯片与Pod数据 | 仅275TFLOPS、32GiB/1,200GB/s和条件化功耗属于per-chip；其余保持系统主语 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Norman P. Jouppi等，*TPU v4: An Optically Reconfigurable Supercomputer for Machine Learning with Hardware Support for Embeddings*，ISCA 2023 | Google厂商团队原始论文 | package/board、TensorCore/MXU/VPU、SparseCore、存储、工艺、峰值、功耗、ICI和Pod边界 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2023_TPUv4_Optically_Reconfigurable_Supercomputer.pdf) |
| `[2]` | Google Cloud，*TPU v4* | 当前官方产品文档 | per-chip规格、统一HBM、DMA、PCIe、TensorCore增量、当前支持与系统配置 | <https://docs.cloud.google.com/tpu/docs/v4> |
| `[3]` | Google Cloud，*Google Cloud infrastructure enhancements tailored for your workloads*，2022-10-12（地区页面亦显示10-13） | 官方GA公告 | Cloud TPU v4 Pods general availability | <https://cloud.google.com/blog/products/infrastructure-modernization/open-infrastructure-announcements-at-google-cloud-next> |
| `[4]` | Google，*Google I/O 2021: Being helpful in moments that matter*，2021-05-18 | 官方发布文章 | TPU v4首次公开与早期Cloud计划 | <https://blog.google/innovation-and-ai/technology/developers-tools/io21-helpful-google/> |
| `[5]` | Google Cloud，*Google Cloud unveils world's largest publicly available ML hub with Cloud TPU v4*，2022-05-12 | 官方Preview公告 | Cloud TPU v4 Pod Preview、定位和初始访问方式 | <https://cloud.google.com/blog/products/compute/google-unveils-worlds-largest-publicly-available-ml-cluster> |
| `[6]` | Google Cloud，*TPU architecture* | 当前官方系统文档 | chip/TensorCore数值语义、Pod/slice/topology/multislice边界与ICI resiliency | <https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm> |
| `[7]` | Norman P. Jouppi等（Google），*Google's Training Supercomputers from TPU v2 to Ironwood*，2026 | 厂商团队原始论文 | v4 ICI 单链路方向口径 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2026_TPUv2_to_Ironwood_Five_Generations.pdf) |

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

复核结论：Google Cloud TPU v4单芯片的主语、2个TensorCore、8个128×128 MXU、4个SparseCore、片上存储、7nm/22B物理实现、275TFLOPS、32GiB HBM2/1,200GB/s、PCIe Gen3、6条ICI link、条件化功耗和package边界已由Google一手资料固定。四芯片板卡、host、slice、OCS和4,096-chip Pod没有下放；TDP、INT8完整数值语义、HBM封装细节保持缺失；ICI方向已由跨代论文补充。
