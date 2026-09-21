# NVIDIA 逆向论文能补充哪些架构信息

判断日期：2026-09-16。范围为现有 NVIDIA“独立逆向与微基准”目录中的 38 份 PDF，对照当前资料卡模板和训练/推理架构分析。本文是补读价值筛查：检查论文的问题、方法、实验对象、相关结果与限制，重点核对部分原始图表；不表示 38 篇均已逐页精读。页码均为本地 PDF 文件页序。本轮未修改 SKU 资料卡和原有统计。

## 这些论文值得用在哪里

值得补读，而且其中一些内容直接对应现有资料卡的缺口。官方资料已经较好地说明产品规格、指令支持和软件可见资源；独立研究的主要增量是这些资源在具体执行过程中怎样工作。下文的 SM 指 GPU 的流式多处理器，L2 是二级缓存，NoC 是片内互联网络。例如一次矩阵指令如何分解、内部累加怎样舍入、SM 到 cache 的访问怎样共享带宽，以及并发增加后瓶颈怎样变化。

这些信息能使调研从“支持什么、配置多少”深入到“为什么某种数据流能利用这些资源”。但它们通常不能独立证明某个设计就是为训练或推理而设，更不能用 NVIDIA 一家披露较多的内部行为，推导其他厂商没有对应能力。

当前 H100 SXM5 卡第 7 节仍将 Tensor Core 部分累加语义、NoC 与片上带宽登记为缺口；B200 卡对 Tensor Memory 主要记录程序员可见的分配与指令语义；原架构分析的矩阵/非矩阵配比、片上供数、内部互联和数值路径也有证据不足。这些正是逆向论文可能提供增量的地方。反过来，封装材料、流片成本、物理面积分配和设计动机，通常不能从指令微基准中可靠得到。

## 已找到的具体增量

### 精度标签之外的内部累加行为

[Accurate Models of NVIDIA Tensor Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Accurate_Models_NVIDIA_Tensor_Cores.pdf) 是优先级最高的来源之一。文件名带 2025，但本地正文实际为 2026-06-11 的 arXiv v4，引用时应使用正文版本。

论文通过针对性的输入和输出比较建立数值行为模型，并检查指令映射。其 pp.11 至 15、Figure 5、Tables 3、4 表明，相同的输入/输出格式并不足以确定内部运算：H100/H200 的 TF32 在不同指令入口下可以有不同的乘积累加分组；原生 FP8 路径中，H100/H200 与 B200 的乘积对齐精度也不同。Table 3 给出的 H100/H200 FP8 路径为 13 个 fractional bits，B200 对应路径为 25 个；这里是作者模型中的内部对齐精度，不是把 FP32 输出重新命名为 13-bit 或 25-bit 数据类型。该表已回到 PDF 页面核对。

这能补充 A100、H100/H200、L40S、B200 的“数值与累加路径”，并提醒后续比较：两个产品都支持 FP8/FP32，并不代表逐位结果、舍入位置和误差行为相同。表内结论仍是第三方实验支持的行为模型，不能直接写成物理加法器宽度或晶体管实现；也不能据此宣称某模型训练或推理精度已经提高。FP4、FP6 和 INT8 不在这篇工作的主要验证范围内。

[Dissecting Tensor Cores via Microbenchmarks](论文/NVIDIA_GPU/02_独立逆向与微基准/2023_Dissecting_Tensor_Cores_Microbenchmarks.pdf) 则能把数值行为与执行条件接起来：它比较 mma、mma.sp 和 ldmatrix 的延迟、吞吐及并发要求，并研究 FP16、BF16、TF32 的中间运算。对我们有用的是解释“指令支持、稀疏峰值和可达到的执行速率”之间还隔着哪些供数与并发条件，不是把某次 kernel 的速度当作芯片规格。

一个具体例子是 PDF p.10 Table 6：在 A100、FP16 输入/FP32 累加、每 SM 8 个 warp、指令级并行度为 2 的条件下，稀疏指令 m16n8k32 与 m16n8k16 分别报告 1979.1 与 1290.5 FMA/clock/SM。FMA 是融合乘加；这里保留论文的稀疏有效运算计数。两种形状都属于稀疏矩阵指令，却没有相同的有效吞吐。这正是“支持 2:4 稀疏、标称两倍峰值”之外需要补充的执行条件，不能把两者相除作为完整 GEMM 的固定加速比。表头和数据已回原页核对。

### 容量和总带宽之外的片上供数限制

[Uncovering Real GPU NoC Characteristics](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Uncovering_Real_GPU_NoC_Characteristics.pdf) 直接研究 SM 与 L2 slice 之间的可见访问行为。PDF p.7 Figure 12 的 A100 实验中，单个 SM 访问单个 L2 slice，near 与 far 访问的带宽分别约为 39.5 GB/s 和 26 GB/s；增加发起访问的 SM 数后，两类路径又会趋于同一饱和水平。论文 p.8 Figures 13 至 15 进一步讨论不同架构的局部性和共享关系。相关图表已目视核对。

这组结果说明，同一颗 GPU 的同一级 cache，服务不同访问组织时也可能表现不同。一个“L2 总容量/总带宽”单元格无法表达这种供数限制。它有助于分析数据复用、访问位置和并发如何影响矩阵单元利用率；上述带宽必须与单 SM、单 slice 等实验条件一起保留。H100 的实验分布又不同，不能把 A100 的 near/far 差异直接套用过去。争用和延迟实验能够约束共享组织的解释，但不能唯一证明完整物理 NoC 拓扑。

Thread Block Cluster（协作执行的线程块组）、TLB（地址转换缓存）和 MIG（GPU 资源分区机制）相关论文也有价值。它们分别帮助判断跨 SM 显式数据共享的成本、地址转换资源的共享范围，以及资源分区后仍存在哪些性能耦合。这些内容适合补充“共享范围与管理语义”。安全论文中的攻击演示只在它确实揭示共享资源或隔离边界时进入本调研，不扩展为安全攻防研究。

[Thread Block Cluster 论文](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Benchmarking_Thread_Block_Cluster.pdf) 的 H100 PCIe 实验比较了 producer 直接写 consumer 共享内存的 push 路径，以及 consumer 主动拉取的 pull 路径。PDF pp.4 至 5、Figures 3 至 6 显示方向、数据量和 cluster 尺寸都影响效果，较小传输下 pull 甚至可能不如经过 global memory。这能补充“跨 SM 共享为什么有时有益、有时不划算”，比仅写支持分布式共享内存更有解释力。

[TunneLs](论文/NVIDIA_GPU/02_独立逆向与微基准/2023_TunneLs_GPU_TLBs_NVIDIA_MIG.pdf) 的 pp.7 至 9、Figure 5 和 Table 1 则揭示 A30/A100 地址转换缓存的层级与共享范围，末级 TLB 的共享可以跨越 MIG 实例。Table 1 已目视核对。这适合限定资源隔离的范围，不意味着显存内容或所有 cache 都未隔离；作者对部分条目组织的猜测仍须保留为推断。

### 调度与寄存器供数怎样限制计算资源

[Dissecting and Modeling the Architecture of Modern GPU Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Dissecting_Modeling_Modern_GPU_Cores.pdf) 研究了指令控制位、依赖处理、warp 发射策略和寄存器供数，并据此修改性能模拟器。这类论文能防止我们把“每 SM 有多少矩阵/向量/标量单元”直接理解为这些单元可以同时满速运行。

但该文 Table 4 的实测对象主要是 RTX 3080/3090/A6000、RTX 2070 Super/2080 Ti 和 RTX 5070 Ti，并非当前 A100/H100/B200 产品卡。论文对部分取指和流水线结构也保留假设。它适合用作解释机制与审查架构模型的材料，写入某个数据中心 SKU 前还要核对适用性。逆向得到的、能够拟合实验的结构，不自动等于唯一的真实实现。

## 哪些资料需要降级使用

Hopper 2024 论文与 2025 扩展稿主要实验对象为 H800。它们对 WGMMA（warp group 级矩阵乘加）、TMA（Tensor Memory Accelerator，张量数据搬运机制）、Distributed Shared Memory（同一 cluster 内跨 SM 访问共享内存）等机制仍有参考价值；在确认同一指令能力和作用域后，可以条件化引用。H800 的访存、互联和整设备性能数字不能直接填成 H100 SXM5 规格。此前仅因型号不同就完全排除其机制信息，会损失有用内容。

[B200 综合微基准稿](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Microbenchmarking_NVIDIA_Blackwell_B200.pdf) 的主题很贴近缺口，涉及 Tensor Memory、低精度指令与解压引擎；但本地 2026-03-02 v3 暂不适合作为关键数字的直接依据。PDF p.7 Table VI 与 p.8 Table VII 中 FP16 相关吞吐相差四倍，条件关系需要解释；p.8 把 76,900/31,033 描述为 2.69 倍，实际约为 2.48 倍。p.8 页面已目视确认。不能仅因标题包含 B200 就把全部结果纳入资料卡；也不能因为部分问题就反推全文实验均无效。当前可用它定位待核问题，重要结论需与原始代码、配置和独立来源核对。

Volta、Turing/T4、早期能耗及汇编分析论文主要适合提供方法与演进背景。它们揭示的旧代机制有助于解释后续研究为什么采用某种测试，但旧芯片的周期、功耗、cache 参数和调度策略不能迁移成新型号的事实。GB203 与 B200 虽同属 Blackwell 名称，也不能互换数据中心 Tensor Core、TMEM 或封装结论。

## 对当前调研的处理建议

优先补的是数值与累加行为、矩阵指令供数与并发、SM/L2 共享关系，以及 cluster 和地址转换的机制。它们能直接提高现有资料卡的解释能力。更早代的逆向、汇编工具、形式化验证和能耗方法留作按需参考；存在关键条件疑问的来源先不采用数值。

按当前清单，建议先补读下表标记的 8 篇：Accurate Models、Dissecting Tensor Cores、Hopper 扩展稿、FTTN、Uncovering Real GPU NoC、Thread Block Cluster、TunneLs 和 Isolating GPU Architectural Features。Grace-Hopper 的共享内存论文可在需要解释该系统时再读，当前不为它增加产品范围。

可靠的机制观察可以写回对应的 Core、片上存储、调度或访问语义字段，引用时保留实测型号、指令入口和第三方证据属性。延迟/吞吐曲线及 workload 收益用于后续分析，不挤入铭牌规格表。遇到只能确定行为、不能确定物理结构的结果，就按“观察到的行为”记录。

这批论文能实质性补充微架构理解，也能帮助改正过于粗略的比较口径；它们仍不足以单独裁决“训练芯片与推理芯片是否应该采用不同架构”。后一个问题还需要同条件 workload 证据和其他厂商的可比实现。

## 38 份资料的补读顺序

下表优先级针对当前产品清单。所有论文均筛查了摘要及相关正文或实验；“优先补读”表示增量明确，仍需在正式写卡时核对全部有关条件。正文已解释的重点来源不再重复数字。标题沿用本地文件标识，实际年份与版本以PDF首页为准。

| 资料 | 判断 | 可补信息及适用边界 | 本轮正文阅读范围（PDF页） |
|---|---|---|---|
| [2017 Dissecting GPU Memory Hierarchy](论文/NVIDIA_GPU/02_独立逆向与微基准/2017_Dissecting_GPU_Memory_Hierarchy.pdf) | 背景 | 旧代存储层级与微基准方法；不迁移到当前型号 | pp.4、7至11 |
| [2017 Understanding GPU Microarchitecture Bare Metal Performance](论文/NVIDIA_GPU/02_独立逆向与微基准/2017_Understanding_GPU_Microarchitecture_Bare_Metal_Performance.pdf) | 背景 | K20m 的寄存器冲突与发射方法 | pp.4至6 |
| [2018 Dissecting NVIDIA Volta GPU](论文/NVIDIA_GPU/02_独立逆向与微基准/2018_Dissecting_NVIDIA_Volta_GPU.pdf) | 背景 | V100 的 L1、寄存器与矩阵映射；长文仅抽样 | pp.23、33、44 |
| [2018 NVIDIA Tensor Core Programmability Performance Precision](论文/NVIDIA_GPU/02_独立逆向与微基准/2018_NVIDIA_Tensor_Core_Programmability_Performance_Precision.pdf) | 背景 | V100 的早期矩阵接口及数值转换代价 | pp.6、9至11 |
| [2019 Decoding CUDA Binary](论文/NVIDIA_GPU/02_独立逆向与微基准/2019_Decoding_CUDA_Binary.pdf) | 背景 | SASS 二进制和控制码分析工具 | pp.1、3、7 |
| [2019 Dissecting NVIDIA Turing T4 GPU](论文/NVIDIA_GPU/02_独立逆向与微基准/2019_Dissecting_NVIDIA_Turing_T4_GPU.pdf) | 按需 | T4 的 cache、指令与降频；当前清单无 T4 | pp.18、25、39、46 |
| [2019 Experimental Analysis Matrix Multiplication Functional Units](论文/NVIDIA_GPU/02_独立逆向与微基准/2019_Experimental_Analysis_Matrix_Multiplication_Functional_Units.pdf) | 按需 | V100 数值向量测试方法；旧内部模型有后续修订 | 全文4页 |
| [2019 Low Overhead Instruction Latency Characterization](论文/NVIDIA_GPU/02_独立逆向与微基准/2019_Low_Overhead_Instruction_Latency_Characterization.pdf) | 背景 | 指令计时开销与编译展开的核查方法 | pp.5至6 |
| [2020 Demystifying Tensor Cores Half Precision Matmul](论文/NVIDIA_GPU/02_独立逆向与微基准/2020_Demystifying_Tensor_Cores_Half_Precision_Matmul.pdf) | 按需 | T4/RTX2070 的矩阵供数与寄存器布局；当前无对应 SKU | pp.3至9 |
| [2020 GPU Thread Block Scheduler Placement](论文/NVIDIA_GPU/02_独立逆向与微基准/2020_GPU_Thread_Block_Scheduler_Placement.pdf) | 按需 | 旧代 block 放置与并发资源争用 | pp.1至5、8 |
| [2020 Mixed Precision Block FMA Tensor Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2020_Mixed_Precision_Block_FMA_Tensor_Cores.pdf) | 背景 | block FMA 的数值误差分析，不直接证明物理结构 | pp.3至4、8至12、17 |
| [2020 Verified Instruction Level GPU Energy](论文/NVIDIA_GPU/02_独立逆向与微基准/2020_Verified_Instruction_Level_GPU_Energy.pdf) | 背景 | 旧卡能耗采样验证，不提供当前芯片单元能量 | pp.6至7 |
| [2021 GPU NoC Microarchitecture Covert Channel](论文/NVIDIA_GPU/02_独立逆向与微基准/2021_GPU_NoC_Microarchitecture_Covert_Channel.pdf) | 按需 | V100 NoC 分组及争用；当前型号优先读2024后续论文 | pp.3至5、9 |
| [2021 Numerical Behavior NVIDIA Tensor Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2021_Numerical_Behavior_NVIDIA_Tensor_Cores.pdf) | 按需 | V100/T4/A100 舍入与累加的历史对照，优先结合最新模型 | pp.4、6至16 |
| [2022 Demystifying NVIDIA Ampere Architecture](论文/NVIDIA_GPU/02_独立逆向与微基准/2022_Demystifying_NVIDIA_Ampere_Architecture.pdf) | 按需 | A100 指令/存储行为；已有GA100卡采用，部分表单位异常 | pp.2至7 |
| [2022 Isolating GPU Architectural Features](论文/NVIDIA_GPU/02_独立逆向与微基准/2022_Isolating_GPU_Architectural_Features.pdf) | 优先补读 | A100 40GB 的并行压力、调度和吞吐饱和条件 | pp.4、6至10 |
| [2023 Dissecting Tensor Cores Microbenchmarks](论文/NVIDIA_GPU/02_独立逆向与微基准/2023_Dissecting_Tensor_Cores_Microbenchmarks.pdf) | 优先补读 | A100 的 mma/mma.sp/ldmatrix 供数、并发与稀疏形状条件 | pp.5至12；数值/附录筛读 |
| [2023 TunneLs GPU TLBs NVIDIA MIG](论文/NVIDIA_GPU/02_独立逆向与微基准/2023_TunneLs_GPU_TLBs_NVIDIA_MIG.pdf) | 优先补读 | A30/A100 地址转换层级与跨MIG共享范围 | pp.5至11 |
| [2024 A100 Full Speed Random Access Memory](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_A100_Full_Speed_Random_Access_Memory.pdf) | 按需 | A100 SXM4 80GB 随机访存窗口；TLB结构解释仍为推断 | pp.1至5；Fig.6未核图 |
| [2024 Benchmarking Dissecting NVIDIA Hopper](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Benchmarking_Dissecting_NVIDIA_Hopper.pdf) | 按需 | Hopper早期稿，与2025扩展稿重复较多 | p.3、p.6及存储/计算章节 |
| [2024 Benchmarking Thread Block Cluster](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Benchmarking_Thread_Block_Cluster.pdf) | 优先补读 | H100 PCIe 的cluster同步、映射与DSMEM数据路径 | pp.2至6 |
| [2024 Control Flow Management Modern GPUs](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Control_Flow_Management_Modern_GPUs.pdf) | 按需 | Turing 控制流与编译器协作；Hanoi为作者模型 | pp.1至11相关机制与验证 |
| [2024 Demystifying NVIDIA GPU Internals Management](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Demystifying_NVIDIA_GPU_Internals_Management.pdf) | 按需 | GPU stream/channel/runlist与copy engine共享边界 | pp.2至10 |
| [2024 FTTN Numerical Properties Matrix Accelerators](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_FTTN_Numerical_Properties_Matrix_Accelerators.pdf) | 优先补读 | NVIDIA/AMD 数值语义对照；H100部分结果仅为下界 | pp.7至10及方法框架 |
| [2024 First Look Grace Hopper Unified Memory](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_First_Look_Grace_Hopper_Unified_Memory.pdf) | 按需 | Grace-Hopper 96GB版的内存迁移与共享语义；非主清单SKU | pp.3至9 |
| [2024 Uncovering Real GPU NoC Characteristics](论文/NVIDIA_GPU/02_独立逆向与微基准/2024_Uncovering_Real_GPU_NoC_Characteristics.pdf) | 优先补读 | A100/H100 的SM到L2非均匀访问与并发瓶颈 | pp.2至8、10至12 |
| [2025 Accurate Models NVIDIA Tensor Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Accurate_Models_NVIDIA_Tensor_Cores.pdf) | 优先补读 | 多代Tensor Core数值模型，覆盖L40S/H100/H200/B200 | pp.7至16；应用部分筛读 |
| [2025 Dissecting Modeling Modern GPU Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Dissecting_Modeling_Modern_GPU_Cores.pdf) | 按需，机制背景优先 | RTX实测的依赖、调度、寄存器reuse；不能直接写数据中心SKU | pp.1至13相关机制与验证 |
| [2025 Dissecting NVIDIA Blackwell GB203](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Dissecting_NVIDIA_Blackwell_GB203.pdf) | 按需、待核数值 | GB203不能代替B200；含H100 PCIe但部分带宽需核 | pp.1至3、7至8 |
| [2025 Dissecting NVIDIA Hopper Extended](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Dissecting_NVIDIA_Hopper_Extended.pdf) | 优先补读 | H800的WGMMA/TMA/DSM执行条件，可条件化解释Hopper | pp.4至5、8、12至18、20至22 |
| [2025 Generalized Methodology Hardware Matrix Multipliers](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_Generalized_Methodology_Hardware_Matrix_Multipliers.pdf) | 按需 | 参数化数值测试方法，实测消费型号 | pp.3至7 |
| [2025 NVBleed NVIDIA Multi GPU Interconnect](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_NVBleed_NVIDIA_Multi_GPU_Interconnect.pdf) | 按需 | P100/V100多GPU共享链路行为；不替代新代NVLink | pp.2至6、10 |
| [2025 SMT Formalization Three Generations Tensor Cores](论文/NVIDIA_GPU/02_独立逆向与微基准/2025_SMT_Formalization_Three_Generations_Tensor_Cores.pdf) | 按需 | 用形式化模型生成数值反例，不是实物网表验证 | pp.13至15及方法流程 |
| [2026 Behind Bars NVIDIA MIG Cache](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Behind_Bars_NVIDIA_MIG_Cache.pdf) | 按需，隔离主题优先 | H100/H200 MIG下的barrier时序耦合；未测试MIG+CC | pp.4至9、13 |
| [2026 Consistency Coherence Grace Hopper](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Consistency_Coherence_Grace_Hopper.pdf) | 按需，共享内存主题优先 | Grace-Hopper 96GB版一致性和顺序模型；非主清单SKU | pp.5、7至12 |
| [2026 Hawkeye GPU Non Determinism](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Hawkeye_GPU_Non_Determinism.pdf) | 按需 | 累加顺序/舍入与可复现性，需与最新数值模型互证 | pp.4至10 |
| [2026 Microbenchmarking NVIDIA Blackwell B200](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_Microbenchmarking_NVIDIA_Blackwell_B200.pdf) | 待核 | B200的TMEM/解压主题重要，但本稿条件与数值存在疑点 | pp.1至10，重点pp.3至8 |
| [2026 NVLift SASS to LLVM IR](论文/NVIDIA_GPU/02_独立逆向与微基准/2026_NVLift_SASS_to_LLVM_IR.pdf) | 背景 | Turing SASS到LLVM转换工具；不补当前SKU参数 | pp.1、9 |
