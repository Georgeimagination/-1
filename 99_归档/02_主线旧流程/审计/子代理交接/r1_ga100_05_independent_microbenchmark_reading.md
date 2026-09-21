# GA100 独立微基准来源精读

## 任务状态

状态：completed_read_only

输入来源：

- 论文/NVIDIA_GPU/02_独立逆向与微基准/2022_Demystifying_NVIDIA_Ampere_Architecture.pdf
- 论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf
- 论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf
- 清单/论文PDF清单.csv
- 数据/fields.csv、condition-sets.csv、components.csv、precision-paths.csv、facts.csv
- 资料卡/模板.md、资料卡/字段字典.md

写入范围：

- 本报告
- 审计/子代理交接/r1_ga100_05_independent_microbenchmark_reading_assets/ 下的 PDF 页面渲染

正式 CSV、资料卡和进度文件均未修改。

## 审读结论

这篇论文有三类独有内容：PTX 到 SASS 的实际映射及周期数、L1/L2/shared memory 的指针追踪延迟、dense WMMA 指令的 Tile、SASS 展开和周期数。它们能补足 NVIDIA 白皮书和 ISSCC 没有公开的指令级信息，因此有进入 GA100 最小来源集的条件。

当前还不能整篇直接入库。论文没有报告 A100 的 40 GB 或 80 GB 容量、SXM 或 PCIe 形态，也没有给出 CUDA、driver、compiler、GPU 时钟或锁频方式。正文两处把测试 GPU 写成 “AI100”，Table V 又写成 “Amepere A100”，只能确认测试对象属于 A100 产品族，不能恢复具体 SKU。Table III 的吞吐列使用 GB/s，却列出与官方 A100 312 TFLOPS、156 TFLOPS、19.5 TFLOPS、624 TOPS 和 1,248 TOPS 相同的数值。这个单位问题不能静默改成 FLOP/s 或 OP/s。

按对象边界处理后，PTX/SASS 映射、片上指令周期、L1/L2/shared memory 周期和 dense WMMA Tile 可以作为 “A100 产品配置上测得、候选归属于 GA100 die 的条件化微架构证据”。global memory 290 cycles 覆盖 GA100、HBM、A100 产品形态和运行时条件，不能写成 GA100 die 固有延迟。Table III 的聚合吞吐还依赖 A100 启用的 108 个 SM 和产品时钟，也不能写成 full GA100 128 SM 设计值。

## 来源身份和本地版本

| 项目 | 核验结果 | 证据 |
|---|---|---|
| 标题与作者 | Hamdy Abdelkhalik、Yehia Arafa、Nandakishore Santhi、Abdel-Hameed A. Badawy | PDF p.1 |
| 正式发表身份 | HPEC 2022，pp.1-8，DOI 10.1109/HPEC55821.2022.9926299 | LANL 机构成果页；IEEE Xplore 文献号 9926299 |
| 本地文件内容版本 | arXiv:2208.11174v1 作者预印本，2022-08-23 提交 | PDF p.1 左侧 arXiv 标记；arXiv submission history 只有 v1 |
| 本地哈希 | 86013d806532a281e7878415cc1a55aa426f8fbd8ae0e9dc02285882fbdd8227 | 本地 SHA-256 与清单一致 |
| 与清单是否一致 | 标题、作者、页数、哈希和 arXiv 下载入口一致；清单的 venue 和 DOI 描述发表身份，但本地文件本身不是已核实的 IEEE 最终排版版 | 清单/论文PDF清单.csv 第 54 行 |
| 最终版等同性 | 未确认。IEEE 页面可确认文献身份，当前环境没有取得可逐页比较的 publisher PDF | IEEE Xplore 页面受交互验证限制；不影响本地预印本精读，但留下版本风险 |

外部核验入口：

- https://arxiv.org/abs/2208.11174
- https://ieeexplore.ieee.org/document/9926299
- https://laro.lanl.gov/esploro/outputs/conferenceProceeding/Demystifying-the-Nvidia-Ampere-Architecture-through/9916458355903761

## 测试对象和方法条件

| 条件维度 | 论文披露 | 入库含义 |
|---|---|---|
| GPU | “Nvidia Tesla AI100 GPU”，Table V 写 “Ampere A100” | 视为 A100 产品族。AI100 是明显拼写问题，不能另建对象 |
| 容量与形态 | 未给 40/80 GB、SXM/PCIe | A100 SKU unresolved |
| GPU 数量 | 结果段写单数 GPU；没有完整设备枚举 | accelerator_count 候选为 1，但设备型号仍不完整 |
| 软件 | 使用 PTX、SASS、CUDA WMMA 和 PPT-GPU tracing tool | 只证明方法；实际 CUDA、driver、compiler 与 tracing tool commit 未报告 |
| ISA 版本 | 参考文献列出 PTX ISA 7.7 | 引用版本不能当成实测环境版本 |
| 时钟 | 用 clock/clock64 读周期，测得连续读时钟开销 2 cycles | 没有 GPU 频率、锁频或 power mode，不能把 cycle 换算为秒 |
| 标量指令 | 一线程每 block；比较 dependent 与 independent 序列；动态核对 SASS | 条件必须保存依赖链、初始化方式、重复次数与 SASS 结果 |
| memory | pointer chasing 强制串行；cv 绕过缓存，cg 只缓存 L2，ca 覆盖 L1/L2；shared memory 用依赖指令防止重排 | 每种 PTX cache operator 和数组相对 L2 大小需要独立条件集 |
| Tensor Core | WMMA API；同一循环放入 4 条 TC 指令；按 2-cycle 时钟开销修正 | 每种数据类型、Tile、layout、累加格式与 SASS 展开需要独立条件集 |
| 统计口径 | 表中给点值或范围，没有重复次数、方差或置信区间 | statistic_basis 只能按 point 或 range；不可写 mean |

## 对象层级裁决

| 论文内容 | 合理主体 | 能否用于 GA100 die | 说明 |
|---|---|---|---|
| PTX 到 GA100 SASS 映射和指令周期 | GA100 上的执行组件或 precision path | 条件化接收 | 实测发生在 A100 产品上，但路径位于 GA100 die；必须保留软件和测试对象缺失 |
| L1、L2、shared memory 周期 | GA100 片上 memory component | 条件化接收 | 不能推广到全部 Ampere 实现，也不能写成无条件绝对延迟 |
| global memory 290 cycles | A100 产品测试路径 | 不作为 GA100 die 固有值 | 路径包含 HBM、memory controller、产品时钟和形态 |
| Table III 聚合吞吐 | A100 产品或 SKU | 拒绝写入 GA100 die | 数字与 108-SM A100 产品峰值相同；full GA100 是 128-SM 设计，且论文没有披露频率和 SKU，不能据此反推测量配置 |
| 4 Tensor Cores/SM、支持格式 | Ampere/A100 SM 架构 | 可作旁证，不作独有事实 | NVIDIA 白皮书和 ISSCC 更强 |
| 124 SM | 无可接收主体 | 拒绝 | 与官方 full GA100 128 SM、A100 108 SM 冲突 |
| L2 residency control | Ampere/A100 架构机制 | 不从本文接收 | 本文只在 background 中复述，官方来源更强 |
| 稀疏支持 | Tensor Core precision path/capability | 不从本文接收 | 没有 sparse MMA 微基准、Tile、周期或吞吐测量 |
| TLB、页表和地址翻译 | 无证据 | 不接收 | 正文没有覆盖 translation |

## 可接收候选事实

### SIMT、SM 和通用指令

| 候选内容 | 定位 | field_id | 证据层级 | 裁决 |
|---|---|---|---|---|
| 一线程每 block 的 PTX latency microbenchmark，并用动态 SASS trace 排除编译器插入项 | p.3 Fig.1、p.4 Fig.4、IV-A | 现有字段没有 “每指令周期延迟”；不应塞入 FIELD-BENCH-LATENCY | third_party_measured | 保留来源候选，先解决字段合同 |
| add.u32 由 1、2、3、4 条序列得到 5、3、2、2 CPI | p.3 Table I | 同上；也可作为 FIELD-COMP-UTILIZATION-LIMIT 的方法旁证，但不宜当长期芯片属性 | third_party_measured | 保存为方法验证，不单独建正式事实 |
| dependent/independent CPI：add.f16 3/2、add.u32 4/2、add.f64 5/4、mul.lo.u32 3/2、mad.rn.f32 4/2 | p.5 Table II | 候选新增 FIELD-COMP-INSTRUCTION-LATENCY-CYCLES | third_party_measured | 可用于 GA100 执行路径，需分 instruction 和 dependency condition |
| Table V 的 PTX-SASS 映射与周期 | p.7 Table V | 映射可候选 FIELD-COMP-INSTRUCTION-TILE 或新增 ISA mapping 字段；周期需新增 instruction latency 字段 | third_party_measured，部分值为作者解释 | 有独有价值；逐行条件化，不升级成 RTL |
| 两条 add 与两条 mad 共约 4 cycles，作者据此推断浮点与整数路径可并行 | p.5 V-A item 1 | FIELD-COMP-CONCURRENCY | measured_result 加 author_inference | 只能记录 “该微基准观察与作者推断”；不能写成已确认物理 pipeline 拓扑 |

Table V 覆盖 add/sub、mul、mad、sad、div/rem、abs、brev、copysign、逻辑、lop3、cnot、bfe、min/max、neg、FMA、sqrt/rsqrt/rcp、popc、clz、bfind、testp、MUFU 特殊函数、bar、convert、setp、bfi、dp4a 和 dp2a。全表的视觉原件保存在 assets/page-7.png。部分值是范围、状态相关值或 “changes”，不能压成单点延迟。作者还说明初始化方式会改变 PTX-SASS 映射，Table V 的 neg.f32 就有 FADD 与 IMAD.MOV.U32 两种结果；正式记录必须保留 initialization condition。

### Tensor Core

| 输入和累加 | WMMA Tile | SASS 展开 | 周期 | 原始 throughput 列 | 定位 | field_id 与裁决 |
|---|---|---|---:|---:|---|---|
| FP16 -> FP16 | m16n16k16、m8n32k16、m32n8k16 | 2 x HMMA.16816.F16，每条 8 cycles | 16 | 311-312 GB/s | p.6 Table III | Tile 可进 FIELD-COMP-INSTRUCTION-TILE；周期待 instruction latency 字段；吞吐拒绝规范化 |
| FP16 -> FP32 | 同上 | 2 x HMMA.16816.F32，每条 8 cycles | 16 | 310-312 GB/s | p.6 Table III | 同上 |
| BF16 -> FP32 | 同上 | 2 x HMMA.16816.F32.BF16，每条 8 cycles | 16 | 310-312 GB/s | p.6 Table III | 同上 |
| TF32 -> FP32 | m16n16k8 | 4 x HMMA.1684.F32.TF32，每条 4 cycles | 16 | 132-156 GB/s | p.6 Table III | 同上 |
| FP64 -> FP64 | m8n8k4 | 1 x DMMA.884 | 16 | 19-19.5 GB/s | p.6 Table III | 同上 |
| U8 -> U32 | m16n16k16、m32n8k16、m8n32k16 | 2 x IMMA.16816.U8.U8，每条 4 cycles | 8 | 594-624 GB/s | p.6 Table III | 同上 |
| U4 -> U32 | m8n8k32 | 1 x IMMA.8832.U4.U4 | 4 | 1229-1248 GB/s | p.6 Table III | 同上 |

论文把上述 WMMA 结果称为 dense 测试，没有给 sparse MMA 结果。作者写明同一数据类型的不同 PTX shape 没有改变测得 latency，同时指出 PTX Tile 可拆成多个更小的 SASS Tile。论文另引参考文献 [21] 声称 physical TC implementation 是 8 x 4 x 8；这是二手转述，不能填 FIELD-COMP-ARRAY-SHAPE。

layout 也会改变 MOVM 指令。row-major A 与 row-major B 会对 B 插入转置；两个输入都为 column-major 时，对 A、C 插入 MOVM；A row-major、B column-major 时，trace 中没有 MOVM。该观察同时依赖编译器版本和矩阵 layout，而论文没有报告编译器版本。它适合作为 instruction mapping 的候选断言，不适合作为固定物理数据流结论。

### Memory

| 路径 | 原始值 | 方法条件 | 定位 | field_id | 裁决 |
|---|---:|---|---|---|---|
| global memory | 290 cycles | pointer chasing；ld.global.cv.u64；数组大于 L2；绕过缓存 | p.4 IV-B、p.5 V-B、p.6 Table IV | FIELD-MEM-LATENCY | 只保留 A100 产品测试路径；不归入 GA100 die |
| L2 cache | 200 cycles | pointer chasing；ld.global.cg.u64；数组小于 L2 | 同上 | FIELD-MEM-LATENCY | GA100 L2 条件化候选 |
| L1 cache | 33 cycles | pointer chasing；ld.global.ca.u64 | 同上 | FIELD-MEM-LATENCY | GA100 L1 条件化候选 |
| shared memory load | 23 cycles | ld.shared.u64；增加依赖指令防止 clock 读提前 | p.3 Fig.3、p.4 IV-B、p.6 Table IV | FIELD-MEM-LATENCY | GA100 shared memory 条件化候选 |
| shared memory store | 19 cycles | st.shared.u64；增加依赖指令防止 clock 读提前 | 同上 | FIELD-MEM-LATENCY | GA100 shared memory 条件化候选 |

FIELD-MEM-LATENCY 当前注册的 canonical_unit 是 s，定义却允许 “周期或时间”。论文没有提供可用频率，不能把 cycles 换算成秒。正式合并前需要主会话裁决：允许该字段保存 cycle，或新增 cycle 专用字段。不能借用 FIELD-MEM-READ-TRANSFER-PER-CYCLE，因为它表示 byte/cycle，不表示访问延迟。

这篇论文没有给 RF、L1、L2 的容量和带宽。RF 只用作计时寄存器，不能从代码中推断物理容量。L2 测试只说数组小于或大于 L2，没有披露具体数组字节数。相关字段仍由官方白皮书、ISSCC 或其他合格微基准承担。

## condition-set 要求

以下名称只是 staging 建议，主会话可以按最终 ID 规则调整。

| 候选条件集 | 必填或必须保留的条件 |
|---|---|
| COND-R1-GA100-HPEC22-INSTR-<PTX>-DEP/INDEP | operation_type 按 scalar_alu、scalar_fma 或 special_function；performance_basis=third_party_measured；support_level=hardware_instruction；measurement_scope=test_path；workload_operator 保存 PTX 与实际 SASS；notes 保存 dependent/independent、初始化方式、至少 3 条重复、1 thread/block、clock64 和 2-cycle overhead；software_version、frequency、power_mode 标 not reported |
| COND-R1-GA100-HPEC22-MEM-GLOBAL-CV | data_move；third_party_measured；test_path；pointer chasing；ld.global.cv.u64；array larger than L2；GPU SKU、frequency 和 software not reported |
| COND-R1-GA100-HPEC22-MEM-L2-CG | 同上，改为 ld.global.cg.u64、array smaller than L2 |
| COND-R1-GA100-HPEC22-MEM-L1-CA | 同上，改为 ld.global.ca.u64；数组工作集具体字节数 not reported |
| COND-R1-GA100-HPEC22-SMEM-LD/ST | data_move；third_party_measured；per_component 或 test_path；ld.shared.u64/st.shared.u64；dependent instruction prevents reordering；statistic_basis=point |
| COND-R1-GA100-HPEC22-WMMA-<FORMAT>-<ACC>-<TILE>-<LAYOUT> | precision_path_id 对应 FP16、BF16、TF32、FP64 或整数路径；sparsity_mode=dense；operation_type=matrix_mma；performance_basis=third_party_measured；support_level=hardware_instruction；workload_operator 保存完整 WMMA 与 SASS；notes 保存 4 条独立 TC 指令、layout、2-cycle overhead、软件与频率缺失；throughput 的 operation_count_rule 保持 not_specified |

同一表中 shape、layout、输入格式、累加格式或 SASS 展开不同，都应使用不同 condition_set_id。论文没有报告训练、prefill 或 decode 阶段，workload_stage 和 workload_phase 应填 not_specified；不要把这组指令测试包装成模型 benchmark。

## 与白皮书和 ISSCC 的交叉核对

| 主题 | 微基准论文 | NVIDIA 白皮书 | ISSCC | 裁决 |
|---|---|---|---|---|
| full GA100 与 A100 启用规模 | background 写 Ampere 124 SM，没有可靠对象边界 | p.20 Fig.6 明确 full GA100 128 SM、A100 108 SM | p.1 和 p.2 Fig.3.2.1 明确 A100 108 SM | 微基准的 124 SM 拒绝 |
| Tensor Core 数量 | 4/SM | p.20、p.22 明确 4/SM | 通过 A100 SM 与产品总量说明 | 一致，但官方来源足够 |
| 数据格式 | FP16、BF16、TF32、FP64、U8、U4，另提 binary | p.26-27 明确 FP16/BF16/TF32/FP64/INT8/INT4/Binary | p.1-2 一致 | 一致；微基准独有的是 dense WMMA/SASS Tile 和 cycles |
| Tensor Core dense 聚合峰值 | Table III 数字接近 312、156、19.5、624、1248，原始单位写 GB/s | p.23、p.27 使用 TFLOPS/TOPS | p.1-2 使用 TFLOPS/TOPS | 数字一致、单位冲突；不替作者纠正 |
| 稀疏 | 只作背景提及，没有 sparse microbenchmark | p.31-32 给 2:4、压缩、selector 和 2x | p.1-2 给 fine-grained sparsity 与 sparse peak | 本文不增加稀疏证据 |
| L1/shared | 33 cycles；shared ld/st 23/19 cycles | p.22、p.33 给 192 KB/SM 和结构 | ISSCC p.1-2 讲异步搬运和 shared load 减少 | 测量独有，可条件化保留 |
| L2 | 200 cycles | p.35 给 40 MB A100、两分区、40 slices/partition、5120 B/clk | ISSCC p.1 给 40 MB、层级 crossbar 和局部化 | 测量独有；容量和带宽仍取官方 |
| RF | 没有容量或带宽测量 | p.22 Fig.7 给 4 x 16,384 x 32-bit register file 分区 | ISSCC p.1-2 只讨论绕过 RF 的 async copy | 本文无独有 RF 事实 |
| 地址翻译 | 未覆盖 | 本轮对照页没有给 TLB 定值 | 未覆盖 | 保持缺失，不从 cache latency 推断 |

## 最小来源反向移除

建议使用受控筛选状态 selected，角色为 independent_validation 和 architecture_mechanism；对象范围限制写入 rationale 或 notes，不另造筛选枚举。入选贡献只包括：

1. GA100/A100 上的 PTX-SASS 映射、dependent/independent instruction cycles；
2. dense WMMA Tile、SASS 展开与指令周期；
3. L1、L2、shared memory 的第三方周期测量。

反向移除判断如下：如果最终事实集保留任一上述可接收事实，移除本来源会丢失白皮书和 ISSCC 没有的 instruction-level 或 measured latency 证据，因此不能移除。如果主会话决定当前 0.3 合同不扩展 instruction-cycle 字段，同时也不允许 FIELD-MEM-LATENCY 保存 cycle，唯一仍可合法落入现有字段的是 WMMA instruction Tile。只要保留这些 Tile，本来源仍有独有贡献；如果 Tile 也因对象层级或软件版本缺失被拒绝，本来源应降为 lead_only，不能仅因已经精读就强行进入最小集。

不作为入选理由的内容包括 A100 身份、4 Tensor Cores/SM、格式支持、L2 residency、稀疏机制和产品峰值。它们已经由 NVIDIA 白皮书或 ISSCC 更直接地覆盖。

## 待主会话裁决

1. 是否为 instruction-level cycles 新增专用事实字段，或把这批值只保存在 source assertion 和阅读卡中。
2. FIELD-MEM-LATENCY 的 canonical_unit 是否允许 cycle。没有字段合同变更时，不应导入 Table IV。
3. 是否取得 IEEE 最终版 PDF 并与 arXiv v1 做内容比对。当前可以使用预印本，但 source_id 应明确标记 ARXIV-V1，不能写成已核实 publisher version。
4. 是否为 GA100 建立只适用于该 die 的 precision path，避免把 A100 实测 SASS Tile 自动推广到所有 Ampere GPU。
5. Table III 吞吐应保持 conflicting_unresolved 或 rejected_for_normalization；没有更强证据证明作者单位笔误前，不应替换成 TFLOPS/TOPS。

## 视觉核验和运行情况

本地论文 8 页全部渲染并逐页检查。Fig.1 至 Fig.6、Table I 至 Table V、Table III 的单位、Table IV 的 memory type 和 cycles、Table V 的范围与 “changes” 项都按页面视觉复核；正文提到的作者脚注和参考文献版本也已检查。对照材料另渲染 NVIDIA 白皮书 p.20、22-27、31-35 和 ISSCC 全 3 页。页面 PNG 位于同名 assets 目录。

渲染过程中 Poppler 报告 fontconfig cache 不可写，但 23 张 PNG 均成功生成，文字、表格、脚注和图示可读。这属于运行环境警告，没有造成页面缺失或视觉错误。

## report-humanizer 复核

文档类型按研究审计记录处理。机器扫描结果为 `No machine-detectable AI tells found`。人工逆向复读已覆盖标题、每节首段、表格引导句、结尾裁决和重复句式，并修正中英文粘连与一个未注册的筛选状态写法。复读没有发现需要删改的模板化套话；技术限定和证据不确定性均保留。项目没有提供同类报告的人工写作样本，因此本轮只能按既有项目文风和术语合同复核，不能做样本对照。
