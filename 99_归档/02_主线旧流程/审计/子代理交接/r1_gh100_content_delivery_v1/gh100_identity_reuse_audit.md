# GH100 裸片对象边界与正式库复用审计

任务状态：完成，待主代理复核。  
审计日期：2026-08-21。  
审计对象：`OBJ-NVIDIA-GH100-DIE`，层级为 `die`。本次只读取活动名单、DEC-036、DEC-037、资料卡 0.3 合同、正式 CSV、既有 H100 与 Hopper 复用卡。未修改正式 CSV、进度、资料卡、来源池或其他代理文件。

## 审计结论

GH100 的正式库已有一个已复核的裸片对象、三条可沿用的裸片物理事实，以及一条已复核的 H100 SXM5 模组包含 GH100 的关系。三条物理事实的 `resolution_state` 都是 `provisional`，内容交付可直接引用其 ID 和来源链，同时应保留该状态，不能表述为已正式接受的完整 GH100 卡。

现有 H100 SXM5 80 GB 试填包含 64 条归属该模组的事实。它们可作为来源定位和对象边界线索，不能复制、改主语或按数量折算后下放到 GH100。Hopper 目前只有架构对象和复用说明，`facts.csv` 中归属 `OBJ-NVIDIA-HOPPER-ARCH` 的事实为零；H100 的实现事实也不能自动上卷为 Hopper 架构事实。

GH100 还没有自身的 `field-requirements`、完整度记录、最小来源选择运行或 H100 之外的实现关系。当前最先需要补齐的是裸片身份来源登记与 GH100 到 Hopper 的独立关系证据；其余字段按裸片对象逐项抽取或登记缺口，不借用 H100 模组、HGX、DGX、Grace Hopper 或负载变量。

## 读取范围与对象边界

活动名单把 “NVIDIA GH100 die” 冻结为主样本，层级为 `die`，共享设计组为 `NV-GH100`。名单同时明确 H100 与 H200 经 GH100 裸片进入范围，卡型、SXM 模组和显存配置不重复计数。DEC-036 规定当前芯片之外的内容只能形成复用线索，不提前写入正式事实；DEC-037 将内容验收和正式入库分开计数。

正式实体和既有关系如下。

| 层级 | 正式 ID | 当前含义 | 本次处理 |
|---|---|---|---|
| 裸片 | `OBJ-NVIDIA-GH100-DIE` | NVIDIA GH100 die，`object_type=die`，`review_status=reviewed` | 本次内容交付的唯一芯片主体。 |
| 模组 | `OBJ-NVIDIA-H100-SXM5-80GB` | NVIDIA H100 SXM5 80 GB，`object_type=module` | 仅作已知实现和来源线索，不替代 GH100 主体。 |
| 架构代际 | `OBJ-NVIDIA-HOPPER-ARCH` | NVIDIA Hopper architecture，`object_type=architecture_generation` | 只承接代际层机制；不承接 GH100 物理值或 H100 模组值。 |
| 已有物理关系 | `OREL-NVIDIA-H100-SXM5-CONTAINS-GH100` | H100 SXM5 模组 `physically_contains` GH100 裸片，`review_status=reviewed` | 可直接在 GH100 卡的外部关系栏引用，关系方向和语义不改。 |
| 已有架构关系 | `OREL-NVIDIA-H100-IMPLEMENTS-HOPPER` | H100 SXM5 模组 `implements_architecture` Hopper，`review_status=reviewed` | 仅证明 H100 模组的关系，不能移作 GH100 的关系。 |

`OBJ-NVIDIA-H100-SXM5-80GB` 的说明已明确排除 H100 PCIe、H800、Grace Hopper 和 DGX 系统。活动 `objects.csv` 也没有登记 Grace Hopper、DGX H100、HGX H100 或 H100 PCIe 为可复用的正式对象。因此这些名称只能出现在边界说明或未来独立对象取证中，不能形成 GH100 的对象别名、组件、拓扑或规格事实。

## 可直接复用的正式记录

以下记录的主体已经是 `OBJ-NVIDIA-GH100-DIE`，可原样引用。三条都由同一份固定版白皮书支持，事实行已复核，逐来源断言状态为 `source_checked`。它们仍保留 `resolution_state=provisional`。

| 事实 ID | 字段 | 规范值 | 逐来源断言 ID 与定位 | 可复用范围 |
|---|---|---|---|---|
| `FACT-NVIDIA-GH100-PROCESS` | `FIELD-PHY-PROCESS` | TSMC 4N | `ASSERT-NVIDIA-GH100-PROCESS-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，p.17；pp.39-40，Table 3 | GH100 裸片制程。 |
| `FACT-NVIDIA-GH100-TRANSISTORS` | `FIELD-PHY-TRANSISTORS` | 80,000,000,000 count | `ASSERT-NVIDIA-GH100-TRANSISTORS-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，p.17；pp.39-40，Table 3 | GH100 裸片晶体管数。 |
| `FACT-NVIDIA-GH100-DIE-AREA` | `FIELD-PHY-DIE-AREA` | 814 mm2 | `ASSERT-NVIDIA-GH100-DIE-AREA-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，pp.39-40，Table 3 | GH100 裸片面积。 |

可直接复用的来源登记链为 `SFAM-NVIDIA-H100-ARCH-WHITEPAPER`、`SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，以及首选本地入口 `END-NVIDIA-H100-ARCH-WP-V1-04-LOCAL`。该入口的 SHA-256 为 `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27`，71 页，`review_status=reviewed`。这些是现有来源对象，可在 GH100 工作包中复用，不能重复创建 source family、source version 或 endpoint。

`OREL-NVIDIA-H100-SXM5-CONTAINS-GH100` 也是可直接复用的关系记录。它只表达 H100 SXM5 对 GH100 的包含关系，不能从中推出 H100 的 HBM、功耗、频率、峰值或接口属于裸片。

## 可复用为重新抽取依据的记录

下表中的内容可减少再次定位原文的工作量。现有事实和实体 ID 的所有者均为 H100 模组，GH100 卡如需要同类结论，必须对同一来源重新建立以 GH100 为主体的断言和事实，或者明确放在 Hopper 架构主体。不得复制现有行或改变其 `object_id`。

| 候选主题 | 现有 H100 实体或事实 ID | 可复用的来源定位 | 进入 GH100 前的条件 |
|---|---|---|---|
| TMA | `CAP-NVIDIA-H100-TMA`；`FACT-NVIDIA-H100-TMA-IMPL-LEVEL`；`FACT-NVIDIA-H100-TMA-DETAIL` | `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` pp.32-35；Tuning Guide pp.9-10 | 白皮书原文须明确指向 GH100 裸片或 Hopper 代际。`configurable_engine` 目前为 `needs_resolution`，不能把命名直接解释成独立物理模块。 |
| DSM 与线程块簇 | `CAP-NVIDIA-H100-DSM`；`FACT-NVIDIA-H100-DSM-DETAIL` | 白皮书 pp.29-31；Tuning Guide pp.10-11 | 保留可移植簇大小、H100 非可移植 16-block 选择与设备配置的条件，不能记成未限定的 GH100 固有数量。 |
| DPX | `CAP-NVIDIA-H100-DPX`；`FACT-NVIDIA-H100-DPX-IMPL-LEVEL`；`FACT-NVIDIA-H100-DPX-THROUGHPUT-16` | 白皮书 p.27；Tuning Guide p.11 | 重新确认主体和 128 operations/cycle/SM 的作用域。该值不能由 H100 启用 SM 数量扩展为 GH100 总吞吐。 |
| Transformer Engine | `CAP-NVIDIA-H100-TRANSFORMER-ENGINE`；`FACT-NVIDIA-H100-TRANSFORMER-ENGINE-LEVEL`；`FACT-NVIDIA-H100-TRANSFORMER-ENGINE-DETAIL` | 白皮书 pp.44-46 | 先处理 `configurable_engine` 的现有 `needs_resolution`，再判断证据应归 Hopper 还是 GH100。不可把软件与 Tensor Core 组合称为已证实的独立模块。 |
| Hopper 架构关系 | `OREL-NVIDIA-H100-IMPLEMENTS-HOPPER` | 同一白皮书及活动名单的架构归属线索 | 当前不存在 GH100 为主语的 `implements_architecture` 关系 ID。需要针对 `OBJ-NVIDIA-GH100-DIE` 的直接证据后再建立，不能借用该关系。 |
| 开发文档 | `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3`；`END-NVIDIA-HOPPER-TUNING-GUIDE-LOCAL` | 固定版 CUDA 13.3，22 页，SHA-256 `25c37c679b059681cc95fc5affe5f1797afee86c13c460d9069c8366a6e5d6d4` | 当前 `SCREEN-NVIDIA-HOPPER-TUNING-GUIDE` 为 `redundant_covered`，原因只限当前 H100 事实集。若新 GH100 事实有其独有贡献，再作选择评估。 |

`OBJ-NVIDIA-HOPPER-ARCH` 当前有九域完整度记录，其中 `identity` 为 complete，物理域为 not_applicable，其余计算、数值、存储、互联、特殊能力、软件和证据域仍为 needs_review。`facts.csv` 对该对象的事实数量为零。H100 复用卡虽列出机制和来源 ID，其性质是复用说明，不能当作 Hopper 已有事实。

## 不得下放到 GH100 的 H100 记录

下列 64 条事实都按正式所有权归属 `OBJ-NVIDIA-H100-SXM5-80GB` 的对象、组件、精度路径、链路或能力。分组仅为阅读方便；每个 ID 都保持原主体和原条件。它们不能复制为 GH100 裸片事实。

| H100 模组专属范围 | 不得下放的事实 ID | 排除原因 |
|---|---|---|
| 模组形态、功耗与 MIG 配置 | `FACT-NVIDIA-H100-FORM-FACTOR`<br>`FACT-NVIDIA-H100-MAX-TDP`<br>`FACT-NVIDIA-H100-MIG-PARTITIONING` | SXM5、700 W 和最多 7 个 GPU instance 是 H100 模组或其启用配置的产品属性。 |
| H100 启用计算组织 | `FACT-NVIDIA-H100-GPC-COUNT`<br>`FACT-NVIDIA-H100-TPC-COUNT`<br>`FACT-NVIDIA-H100-SM-COUNT`<br>`FACT-NVIDIA-H100-FP32-CORE-COUNT`<br>`FACT-NVIDIA-H100-FP64-CORE-COUNT`<br>`FACT-NVIDIA-H100-INT32-CORE-COUNT`<br>`FACT-NVIDIA-H100-TENSOR-CORE-COUNT` | 已有断言明确为 H100 SXM5 配置。不能当作完整 GH100 裸片资源数量。 |
| H100 峰值路径 | `FACT-NVIDIA-H100-FP8-DENSE-PEAK`<br>`FACT-NVIDIA-H100-FP8-SPARSE-PEAK`<br>`FACT-NVIDIA-H100-FP16-TENSOR-DENSE-PEAK`<br>`FACT-NVIDIA-H100-FP16-TENSOR-SPARSE-PEAK`<br>`FACT-NVIDIA-H100-BF16-TENSOR-DENSE-PEAK`<br>`FACT-NVIDIA-H100-BF16-TENSOR-SPARSE-PEAK`<br>`FACT-NVIDIA-H100-TF32-DENSE-PEAK`<br>`FACT-NVIDIA-H100-TF32-SPARSE-PEAK`<br>`FACT-NVIDIA-H100-FP64-TENSOR-DENSE-PEAK`<br>`FACT-NVIDIA-H100-INT8-DENSE-PEAK`<br>`FACT-NVIDIA-H100-INT8-SPARSE-PEAK`<br>`FACT-NVIDIA-H100-FP16-CUDA-DENSE-PEAK`<br>`FACT-NVIDIA-H100-BF16-CUDA-DENSE-PEAK`<br>`FACT-NVIDIA-H100-FP32-CUDA-DENSE-PEAK`<br>`FACT-NVIDIA-H100-FP64-CUDA-DENSE-PEAK`<br>`FACT-NVIDIA-H100-INT32-CUDA-DENSE-PEAK` | 所有峰值均连接 `PPATH-NVIDIA-H100-*` 和 `COND-NVIDIA-H100-*`，作用域是 H100 SXM5 的理论峰值。 |
| H100 可见累加格式 | `FACT-NVIDIA-H100-FP8-ACCUM`<br>`FACT-NVIDIA-H100-FP16-TENSOR-ACCUM`<br>`FACT-NVIDIA-H100-BF16-TENSOR-ACCUM` | 记录的是 H100 精度路径的程序员可见格式，不替代 GH100 的独立数值路径。 |
| H100 存储与 HBM 版本 | `FACT-NVIDIA-H100-REG-CAPACITY-PER-SM`<br>`FACT-NVIDIA-H100-L1SMEM-CAPACITY-PER-SM`<br>`FACT-NVIDIA-H100-L1SMEM-SHARED-MAX`<br>`FACT-NVIDIA-H100-L2-CAPACITY`<br>`FACT-NVIDIA-H100-HBM-CAPACITY`<br>`FACT-NVIDIA-H100-HBM-STACKS`<br>`FACT-NVIDIA-H100-HBM-INTERFACE`<br>`FACT-NVIDIA-H100-HBM-BW-CURRENT`<br>`FACT-NVIDIA-H100-HBM-BW-WP104`<br>`FACT-NVIDIA-H100-HBM-BW-LAUNCH` | 片上资源记录的是 H100 配置，HBM 容量、五栈、接口和三条带宽版本属于 SXM5 模组。发布期 3 TB/s、v1.04 的 3,352 GB/s 与当前 3.35 TB/s 是 H100 的版本序列。 |
| H100 互联端点 | `FACT-NVIDIA-H100-NVLINK-PROTOCOL`<br>`FACT-NVIDIA-H100-NVLINK-LINK-COUNT`<br>`FACT-NVIDIA-H100-NVLINK-RATE-PERDIR`<br>`FACT-NVIDIA-H100-NVLINK-RATE-BIDIR-LINK`<br>`FACT-NVIDIA-H100-NVLINK-RATE-BIDIR-DEVICE`<br>`FACT-NVIDIA-H100-PCIE-PROTOCOL`<br>`FACT-NVIDIA-H100-PCIE-RATE-PERDIR`<br>`FACT-NVIDIA-H100-PCIE-RATE-BIDIR` | 现有 `LINK-NVIDIA-H100-NVLINK4` 与 `LINK-NVIDIA-H100-PCIE5X16` 的 owner 是 H100 模组。它们不证明裸片、HGX 或 DGX 的拓扑、交换能力和系统带宽。 |
| H100 固定功能 | `FACT-NVIDIA-H100-NVDEC-COUNT`<br>`FACT-NVIDIA-H100-NVJPG-COUNT` | 现有数值是 H100 SXM5 配置的产品表项。 |
| H100 派生比值 | `FACT-NVIDIA-H100-DER-COMPUTE-BW-FP64-TENSOR`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-TF32`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-FP64-CUDA`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-FP16-TENSOR`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-BF16-TENSOR`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-FP32-CUDA`<br>`FACT-NVIDIA-H100-DER-COMPUTE-BW-FP8`<br>`FACT-NVIDIA-H100-REG-POOLING-MODE` | 计算带宽比以 H100 峰值和 H100 当前 HBM 带宽相除，寄存器池化投影以 H100 的 per-SM 范围为输入。GH100 不能继承输入或结果。 |

表中尚未列入 “重新抽取依据” 的七条机制事实也不允许迁移：`FACT-NVIDIA-H100-TMA-IMPL-LEVEL`、`FACT-NVIDIA-H100-TMA-DETAIL`、`FACT-NVIDIA-H100-DPX-IMPL-LEVEL`、`FACT-NVIDIA-H100-DPX-THROUGHPUT-16`、`FACT-NVIDIA-H100-TRANSFORMER-ENGINE-LEVEL`、`FACT-NVIDIA-H100-TRANSFORMER-ENGINE-DETAIL`、`FACT-NVIDIA-H100-DSM-DETAIL`。它们的区别仅在于可以再次核对来源，现有行仍是 H100 所有。

H100 的 20 条缺口要求同样不能视为 GH100 的字段要求。包括 `REQ-NVIDIA-H100-MOE-ROUTE`、`REQ-NVIDIA-H100-TOPK`、`REQ-NVIDIA-H100-NVLINK-PAYLOAD`、`REQ-NVIDIA-H100-PCIE-PAYLOAD` 和各精度路径的累加、时钟、片上带宽缺口。它们描述 H100 的检索范围和实体目标，GH100 需要独立登记或独立判定不适用。

## 负载变量检查

当前正式库有 31 条 `COND-NVIDIA-H100-*` 条件集，服务于精度、稀疏、理论峰值、带宽版本与派生比值。对 22 个负载条件列的非空单元计数为零；这 31 条记录没有模型、算子、batch、序列长度、上下文长度、并发、设备数、调度、质量约束或服务等级变量。GH100 也没有以 `GH100` 命名的条件集。

因此，本次复用审计没有发现已被误写成芯片属性的负载变量。以后若加入 benchmark，模型名、训练或 prefill/decode 阶段、batch、长度、并发、并行规模、质量或服务约束应只进入对应 `condition_set_id`。它们不能写进 GH100 的物理、计算、存储、互联、特殊能力或产品定位字段，更不能由 DGX、Grace Hopper 或其他系统结果反推出裸片属性。

## 来源复用、筛除与版本边界

| 来源 ID | 现有筛选状态和准确用途 | GH100 工作包处理 |
|---|---|---|
| `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` | `selected`；已有三条 GH100 裸片物理断言，并承载 H100 计算、存储和 Hopper 机制材料。 | 复用为已登记来源；三条既有 GH100 事实无需重复登记。新事实逐项重新抽取并明确主体。 |
| `SRC-NVIDIA-H100-DATASHEET-20240924` | `selected`；H100 SXM5 当前产品级铭牌规格。首选入口为 `END-NVIDIA-H100-DATASHEET-LOCAL`。 | 不作 GH100 裸片规格来源。若只作对象关系线索，也不进入 GH100 最小集。 |
| `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` | `redundant_covered`；当前七条 H100 断言由白皮书覆盖。 | 保留作定向检索入口。只有新增 GH100 或 Hopper 事实具备白皮书没有的独有贡献时才重评选择。 |
| `SRC-NVIDIA-H100-HOTCHIPS34-2022` | `selected`；只承担 H100 发布期 3 TB/s 和未最终确定脚注。 | 不把发布期 H100 HBM 值转为 GH100 裸片事实。 |
| `SRC-NVIDIA-H100-IEEE-MICRO-2023` | `redundant_covered`；`COV-NVIDIA-H100-IEEE-BY-WHITEPAPER` 和 `COV-NVIDIA-H100-IEEE-BY-HOTCHIPS` 的覆盖范围均为 H100 selected fact set。 | 不纳入 GH100 最小集，除非新抽取事实有未被白皮书覆盖的明确贡献。 |
| `SRC-NVIDIA-HOPPER-MICROBENCH-2024` | `out_of_scope`；测试对象为 H800 PCIe。 | 不用于 GH100 或 H100 的数值。 |
| `SRC-NVIDIA-HOPPER-MICROBENCH-2025` | `out_of_scope`；扩展版仍测试 H800。 | 不用于 GH100 或 H100 的数值；未来架构级独立测量另行评估。 |

当前 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813` 是已复核的三张 M1 试填卡选择运行，其 H100 成员为 `SELMEM-M1R2-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`、`SELMEM-M1R2-NVIDIA-H100-DATASHEET-20240924` 与 `SELMEM-M1R2-NVIDIA-H100-HOTCHIPS34-2022`。该运行的范围是 `M1-H100-TRAINIUM2-MLU590`，并非 GH100；不能复用为 GH100 的反向移除记录。当前不存在 `scope_id=OBJ-NVIDIA-GH100-DIE` 的正式 selection run 或 selection member。

已发现一处来源元数据的历史残留：`SCREEN-NVIDIA-H100-DATASHEET` 的 notes 仍写 “Fixed copy registration remains pending”，而 `END-NVIDIA-H100-DATASHEET-LOCAL` 已是 `reviewed` 的首选本地入口，source 行也为 `reviewed`。这是一条筛选说明的时序残留，不改变 H100 数据手册仅服务产品级事实的结论，也不能提升为 GH100 裸片来源。

## GH100 缺失项

当前正式库的缺口如下。表中 “无现有 ID” 是审计结果，表示不应伪造或占用新的 ID。

| 缺失类别 | 当前状态 | 需要的后续证据或动作 |
|---|---|---|
| GH100 身份事实与一手来源链 | 无 GH100 的 `FIELD-ID-*` 事实、断言、source family/version/endpoint 选择记录。冻结名单的 MIG Supported GPUs 链接尚未登记到正式来源表。 | 固定并登记对应官方页面或稳定文档，建立裸片名称、对象类型和状态的原子来源链。 |
| GH100 到 Hopper 的关系 | 无现有 GH100 主语的关系 ID；`OREL-NVIDIA-H100-IMPLEMENTS-HOPPER` 不可移用。 | 从原文确认 GH100 与 Hopper 的主体关系后独立建立关系和断言。 |
| GH100 裸片物理覆盖 | 只有制程、晶体管数、面积三条事实；无 GH100 自身的组件、存储层级、链路、精度路径、特殊能力或拓扑实体。 | 以完整裸片和 H100 启用配置为前提逐项拆分。资料不能区分时登记缺口，不把 H100 行迁入。 |
| 字段要求与检索闭环 | `OBJ-NVIDIA-GH100-DIE` 的 field requirement、requirement evidence 和 search log 均为零。 | 按 0.3 字段合同建立 GH100 目标的值、缺失或不适用闭环。不得套用 `REQ-NVIDIA-H100-*`。 |
| 完整度 | 无 `OBJ-NVIDIA-GH100-DIE` 的 `card-completeness` 记录。 | 内容卡形成时按 13 个资料卡领域评估。H100 的 `COMPLETE-NVIDIA-H100-*` 与 Hopper 的 `CC-M2NA-NVIDIA-HOPPER-ARCH-*` 不适用。 |
| GH100 最小来源集 | 无 GH100 selection run、selected role 或反向移除成员。 | 事实集合冻结后专门运行反向移除；不能继承 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813`。 |
| 条件化实测 | 无 GH100 condition set，也无完整条件的性能、能效或利用率事实。 | 有合格测量后，条件集承载负载变量；没有测量时维持缺口状态。 |

## 交接信息与验证

本次读取了主线 `AGENTS.md`、冻结名单、`DEC-036`、`DEC-037`、资料卡模板与字段字典，活动 `数据/` 的实体、关系、事实、字段要求、条件、完整度表，以及活动 `最小参考资料库/` 的来源、入口、断言、筛选、覆盖和选择表。H100 试填交接与 Hopper 复用卡只作为审计依据，没有当作新的事实来源。

写入文件只有本文件：`审计/子代理交接/r1_gh100_content_delivery_v1/gh100_identity_reuse_audit.md`。未写入正式表、进度、资料卡或其他代理目录。未核实字段和来源矛盾已在上文列出；没有发现把模型、batch、长度、并发或系统聚合值写成 GH100 芯片属性的现有正式记录。

建议下一步由主代理先固定 GH100 身份来源和 GH100 到 Hopper 的独立关系，再以白皮书的现有 GH100 三条物理事实作为内容卡起点，完成每个裸片字段的来源抽取、缺口链和 GH100 专属反向移除。H100 模组、Grace Hopper 与 DGX/HGX 系统材料继续只作边界校对。

## 自然化复核记录

文档类型为工程审计交接。机器扫描后人工按倒序复读了结尾、来源表格引导、负载变量段、不得下放表、可条件化表、直接复用表、对象边界和标题。检查重点包括标题是否模板化、首段是否重复、表格引导是否空泛、转场是否机械，以及结尾是否给出可执行边界。结论为没有明显 AI 腔，剩余问题是内容取舍。

报告完整文件的 SHA-256、行数、机器扫描返回值及失败分类作为本次代理的交付验证结果随交接消息发送；校验对象是本 Markdown 文件。
