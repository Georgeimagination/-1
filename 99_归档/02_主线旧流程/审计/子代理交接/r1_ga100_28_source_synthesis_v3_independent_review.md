# GA100 来源综合 v3 输入独立复核

状态：`reject`

复核日期：2026-08-21。本轮只新增本报告，没有修改 `r1_ga100_25_source_synthesis_v3_input.md`、正式 CSV、合同设计、staging、资料卡或进度文件。

## 裁决

`r1_ga100_25_source_synthesis_v3_input.md`（下文简称 r25）不能作为当前 GA100 重建的权威输入。这一拒收结论针对综合表的完整性和当前适用性，不否定它引用的整批来源。r25 漏了 r16 已明示交接的 15 个 `FIELD-ID`，仍执行已被 v4 取代的 numerics 状态规则，把 staging 实体和 endpoint 写成了当前可用对象，并且没有吸收已独立验收的官方网页/PDF v2 快照状态。在这些问题修复前，不应据此生成 coverage work package、selection run 或 chip transaction。

r25 中仍有可保留的部分：full GA100 die 的研究边界、12 个伪 GAP 实体的删除方向、instruction latency 与 memory latency 分域、HPEC 的 global-memory/throughput 排除、BIST structure 与 telemetry 的拆分，以及“不预设最小来源数量”的 reverse-removal 原则。下文不会把 A100 上的所有实测一概判为投影；测试载体到其物理实现 component 的条件化证据归属，与沿 `implements_architecture` 复制事实是两件事。

## 独立复算的基线

我直接枚举和解析正式表，没有把 r25 或旧复核报告的计数当作结果。

| 检查项 | 独立结果 | 对 r25 的影响 |
|---|---:|---|
| 冻结名单 | GA100 行是 `NVIDIA GA100 die`，层级为“裸片（die）”，共享设计组 `NV-GA100` | r25 把 full die 作为卡主体，这一点通过。 |
| `数据/objects.csv` | 78 行，78 个唯一主键；有 `OBJ-NVIDIA-AMPERE-ARCH`，没有 `OBJ-NVIDIA-GA100-DIE` | GA100 object 仍是后续 chip transaction 候选，不是当前正式对象。 |
| `数据/object-relations.csv` | 27 行，27 个唯一主键；没有 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | 该关系只能在批准并入后参与 reachability。 |
| `数据/fields.csv` | 141 行数据，141 个唯一 `field_id`；文件共 142 个物理行是因为还有 header | r25 L15 的“现有 142-field 数据”是表头计数误用。当前和 v4 postimage 的 field 数都是 141。 |
| `数据/enums.csv` | 557 行、76 个 group | 当前 `rounding_mode` 没有 `rtn/rtp`，`selected_role` 没有 `coverage_obligation_evidence`；v4 目标是 77 group/564 行，不是 r25 L270 沿用的 77/562。 |
| v2 atomic staging | 11 个 GA100 component 均存在，parent chain 与 r25 一致，但它们均为 `draft` | 可作为 v3/v4 重建候选，不应称为当前已可用的正式 target。 |
| 12 个 GAP ID | 11 个 capability 和 1 个 topology 只在 v2 staging 出现，正式 capability/topology 集合均无它们 | r25 L34 至 L38 的删除裁决通过；应删实体及其从属 obligation，不应造替代实体。 |

r25 在 L6 明说使用尚未迁移的 v3 合同，这在它成文时可以理解，但 `r1_ga100_26_contract_repair_design_v4.md` 已明确覆盖 v3 的冲突条款。当前实施输入必须以 v4 为准；不能再把 r25 的 v3 冻结语义当作最终合同。

## 拒收 blocker

| ID | blocker | 精确修复门 |
|---|---|---|
| `R28-B01` | 正式现状、合同 postimage 与 GA100 chip postimage 被混写。r25 L13、L23 至 L28 把尚在 draft staging 的 GA100 object/relation/component 写成“当前 reachability/可用真实 ID”，L15 又把 141 个 field 写成 142。 | 将表头拆成“正式 preimage”、“contract-migration postimage”和“GA100 chip-transaction 拟议 postimage”三层。只有第三层可以列 GA100 实体，并且全部保持 draft 直到独立批准。 |
| `R28-B02` | r16 的 15 个 `FIELD-ID` 在 r25 整文没有出现，导致 coverage 键丢失。 | 按下节修复表恢复 15 个 exact target+field obligation；有值的保留值与条件，输入不闭合的明确保持 pending/N/A，不得因来源综合而消失。 |
| `R28-B03` | r25 的 108-cell 表形状正确，但状态分布为 53 `value` + 55 `not_found`。其中 INT8、INT4、Binary 的 rounding/subnormal 共 6 格是结构不适用，r25 L132、L274、L293 却因旧 v3 禁令强制写 `not_found`。 | 按 v4 保持 108 个 candidate 全部 `include,mandatory_include`，同时把六格改为有 predicate、reason code 和 actual-endpoint proof 的 `not_applicable`。修正后是 53 `value` + 49 `not_found` + 6 `not_applicable`，总数仍为 108。 |
| `R28-B04` | FP64 行只结构化默认 `rne`，把 `.rz/.rm/.rp` 留在 raw text。r25 虽正确识别了 enum gap，但这不再是可以后置的问题。 | v4 要求新增 `rounding_mode=rtn,rtp`，并将 `.rn/.rz/.rm/.rp` 映射为 `rne/rtz/rtn/rtp`。同一 FP64 mandatory requirement 用四条 condition-distinguished accepted fact 闭合，不得遗漏已明示的 mode。 |
| `R28-B05` | r25 对“投影”的口径过宽：L13/L289 说除 `FIELD-ID-ARCH` 外一律不得投影，L276 又要保留 A100-conditioned measurement。若不区分“关系投影”和“测试载体证据归属”，实施者会误删 HPEC 可接收项，或反过来把产品事实下放到 die。 | 保留“只有 `FIELD-ID-ARCH` 能沿 approved relation 特殊投影”；另立测试载体规则，只在载体唯一绑定 GA100 on-die path、指标不依赖 enabled-scale/卡级配置、且条件完整时接受 component measurement。纯 A100/vGPU/card 事实仍不得下放。 |
| `R28-B06` | r25 显式写了 11 个 `END-*`，但只有 Ampere whitepaper endpoint 在正式 `最小参考资料库/source-endpoints.csv`。其余 10 个只在 r14 v2 staging；19 个 staged payload 的 bytes/SHA-256 复算与声明一致，但 19 个 planned stable target 均不存在。 | 把 HPEC、CUDA PG、PTX 7.0/7.2、RAS fixed PDF 和 MIG 五个章节 endpoint 正式注册，完成 stable copy 与 source/version/family 绑定后再称 `actual endpoint`。staging 可读与正式 endpoint 闭合不是同一状态。 |
| `R28-B07` | r25 L48、L242 至 L254、L266、L280 对 r23/r24 网页的“未快照/无本地 hash”判断已过期。官方网页/PDF v2 包已独立 `accept`，但它仍只是 staging。 | 状态改为“快照 staging 已验收，正式 source/version/endpoint/assertion 入库待完成”。`ingestion_pending` 不是当前 `requirement_status` enum，必须作为包/入库生命周期状态，不得写进 requirement status cell。 |
| `R28-B08` | source-family 去重原则大体正确，但 r25 L253 把 cuSPARSELt Guide 与 Release Notes 放在一个“source family/同族版本”单元；L239 只列 MIG 610，没有与新快照中的 r580/latest 统一版本链。 | cuSPARSELt Guide 和 Release Notes 按 r24 拆为两个 work family。MIG r580 PDF、latest/supported HTML 与旧 610 章节纳入同一 `MIG User Guide` family 的版本/endpoint 链，不重复计 distinct family。TensorRT release notes/support matrix/developer guide 继续保持三个 family，这一点 r25 正确。 |

## 漏失的 15 个 field 及修复方向

下表的集合是将 r16 表中的 `FIELD-*` 与 r25 全文取差得到的，共 15 个，没有把近似名称或自然语言提及当作出现。

| 漏失 field | r25 修复时的裁决 |
|---|---|
| `FIELD-COMP-DATAFLOW-RESIDENCY` | 恢复 exact obligation 并拆开 assertion。32-thread warp operand sharing 与减少 SMEM/RF 访问可在 `COMP-M2NA-AMPERE-TENSOR` 上作条件化 value；global-to-shared `cp.async` 是 async-copy/SM 机制，不得因相邻段落并入 Tensor Core 内部 residency policy。 |
| `FIELD-COMP-UTILIZATION-LIMIT` | 恢复 r16 的定性候选，但重新审查 exact target。只有 locator 能把 A100 Tensor Core 的 feed/strong-scaling 限制唯一绑到 GA100 component 时，才能以 A100-enabled 条件接收；否则落 Ampere target 或保持 pending。不得改写成实测利用率。 |
| `FIELD-DER-CAPACITY-COMPUTE` | 恢复 `pending`；full GA100 没有同对象 memory capacity，不能用 A100 HBM 容量除以 full-design compute。 |
| `FIELD-DER-COMPUTE-BW-SPEC` | 恢复 `pending`；需要同对象、同 precision path 的 full-design peak、clock 和 nameplate bandwidth 输入链。 |
| `FIELD-DER-COMPUTE-BW-SUSTAINED` | 恢复 `pending`；现有 1555 GB/s、1.56 TB/s 和 compression upper bound 都不是 full-GA100 sustained input。 |
| `FIELD-DER-INTERCONNECT-COMPUTE` | 恢复 `pending`；NVLink 一侧可关闭，full-design aggregate compute 一侧仍缺 clock/precision-complete input。 |
| `FIELD-DER-MOVE-MATRIX` | 恢复 `pending`；必须同作用域、同方向、同 traffic basis 关闭 movement 和 matrix throughput，不得用示例访问次数替代。 |
| `FIELD-ID-DEPLOYMENT` | 恢复 die target 的 `pending`。DGX A100/NVSwitch 是 system deployment，不是 standalone GA100 die 部署。 |
| `FIELD-ID-DESIGN-OBJECTIVE` | r16 建议沿 architecture relation 投影的方式已不可用。来源直接支持 Ampere objective 时可落 `OBJ-NVIDIA-AMPERE-ARCH`；GA100 die 仍需直接命名该主体的来源。 |
| `FIELD-ID-MARKET-ACCESS-CONSTRAINT` | 恢复 `pending`，需地区、生效日期和具体对象都明确的官方来源；whitepaper/ISSCC 的零命中不足以直接发布 `not_found`。 |
| `FIELD-ID-TARGET-USE-POSITIONING` | 恢复 pending/product-boundary result。cloud/data-center AI、HPC 等原文主体是 A100，不得永久下放到 GA100 die。 |
| `FIELD-ID-VENDOR-POSITIONING` | 与 target-use 分开恢复。现有 vendor wording 属 A100 product；若没有直接 GA100 wording，die target 保持 pending/搜索闭合。 |
| `FIELD-PHY-DIE-COUNT` | 恢复为结构 `not_applicable`。主体就是一颗 die，不能从 die photo 派生 package-level `1`。 |
| `FIELD-SW-COMPILER` | 恢复 r20 的 value 候选：`nvcc compiler driver in CUDA Toolkit 11.0.3`，目标是 `OBJ-NVIDIA-AMPERE-ARCH`，并保留 PTX/cubin/`sm_80` 条件。对应 CUDA PG endpoint 正式入库前不得发布。 |
| `FIELD-SW-RUNTIME` | 恢复 r20 的 value 候选：`CUDA Runtime (cudart), CUDA Toolkit 11.0.3`，同样落 `OBJ-NVIDIA-AMPERE-ARCH`。不把多种链接形式写成多个 runtime。 |

## HPEC、RAS 与 MIG 的主体边界

### HPEC 不应一刀切排除

r05 和 r22 已经对 HPEC arXiv v1 做过测试对象裁决。r25 L146 至 L149 的 instruction cycles、PTX→SASS mapping、L1/L2/shared-memory cycles 可以作为“在 A100 产品族上实测、候选归属到 GA100 on-die component”的条件化 evidence。这种归属不是把 A100 数值沿 object relation 投影到 GA100，也不是将测量升级为无条件硬件规格。

可接收的最低条件是：实际 endpoint 固定为 `arXiv:2208.11174v1`；来源中的 A100 产品族身份由官方身份链唯一绑到 GA100 die；SASS 映射、cache operator 或 pointer-chasing path 能证明测到的是相应 on-die component；原始单位保持 `cycle`；opcode、dependent/independent pattern、initialization、working set、cache operator 和 SASS mapping 逐条记录。v4 condition 中要求非空而来源未披露的字段写字面 `unknown`；`software_version_text`、`operation_count_rule_enum`、`operation_count_rule_source_text` 等 nullable 字段则保持 JSON `null`/CSV 空单元，不得默认填 `not_specified`。没有可靠频率时必须是 `clock_domain=unknown, clock_frequency_known=false`；instruction 的 `measurement_scope` 和 memory 的 `measurement_scope_enum` 也不得从“做了微基准”自行推定。因为源文只确认 A100 产品族，事实只能表示这一测试配置上的 measured result，SKU/form factor、enabled-SM 数、MIG/ECC 等继续作条件缺失记录，不能改写成 full 128-SM GA100 的 configuration-independent constant。

r25 L147 的“related precision path”还需收紧。A100/GA100 上测得的 WMMA cycle 不能直接挂到前文的 `PPATH-M2NA-AMPERE-*` 架构路径，否则会把单一物理实现的测量推广到所有 Ampere 实现。已有 GA100-specific precision path 且 exact datatype/operation 语义匹配时才能挂 path；其他情形先挂 `COMP-R1-GA100-TENSOR`，不为适配测量临时造 path。

按这个口径，r25 将这四类 cycle 保持 `pending`、分开 instruction/memory field、不换算为 second，方向是正确的。合同迁移、actual endpoint 和 condition rows 完成后，它们可以进入条件化事实审批；本报告不以“A100-conditioned”为由拒绝这些 cycle。

HPEC global-memory 290 cycles 跨越 on-die controller、外部 HBM、产品形态和运行时条件，Table III 聚合 throughput 又依赖 108-SM A100 启用规模且有 `GB/s` 单位异常，二者不得归属 GA100 on-die component/full design。背景中的 124 SM 与 full GA100 128 及 A100 enabled 108 都不一致，也应拒绝。r25 L150 至 L152 对这三项的裁决通过。

### RAS/MIG 需按“GA100-aware mechanism”与产品事实分开

| 证据类型 | 可接收边界 |
|---|---|
| GA100-aware RAS | supported-GPU 表或正文直接绑定 GA100 的 containment、DPO、row remapping、driver/service recovery，以及明确局限到 GA100 on-die L2/L1/RF 或 NVLink 的 ECC/detection/replay，可作条件化 value。必须分开 storage、link、driver、service reset 和 telemetry，不得合成“whole-chip protected”；driver/DPO/telemetry 只能表示跨层处置流程，不得声称已知物理 detector/component 结构。 |
| RAS 产品/外部范围 | external HBM ECC、A100 framebuffer inventory、board/service policy 不是 GA100 裸片内建容量或 datapath 事实。它们只能作独立 condition/scope，不得并入 on-die ECC 文本。 |
| GA100-aware MIG | MIG Guide 的 supported-products 表先将 A100/A30 实现绑到 GA100；在此基础上，GI 切分 SM/crossbar/L2/memory path、CI dedicated SM/shared parent memory、GI QoS/fault isolation 可作“支持 MIG 的 GA100 产品实现”的条件化 mechanism fact。mode/geometry lifecycle、create/destroy、monitoring 和 deployment 属软件控制面/生命周期 evidence，可闭合条件化 factor，不得写成物理 component 事实。 |
| MIG/vGPU 产品事实 | up-to-7 profiles、profile geometry/capacity、product driver matrix、A100 vGPU Live Migration、Suspend-Resume 与 time-sliced preemption 不是 full GA100 的无条件事实。没有 reachable A100/vGPU object 时，只做 product condition、negative boundary 或另行工作包的候选。 |

因此，r25 L172 至 L188 不能整段删除。应该做的是拆 assertion 和 locator：只保留直接 GA100-aware/on-die 的部分作正向 value，将 HBM、A100 profile、vGPU delivered behavior 留在产品/软件条件。特别是 r25 L172 不能把 external HBM ECC 与 on-die L2/L1/RF ECC 合成同一条 GA100-die positive fact，必须拆成外部 subsystem condition/related evidence。r25 L189 对 vGPU 三项的排除正确；L183 至 L186 的 GI/CI/QoS/scheduling 候选可以保留，但 normalized text 必须带 supported-GA100-product、MIG mode、guide version 和 software/driver 条件，不能变成裸片在所有模式下的常量。L187 的 lifecycle/monitoring 项必须停在控制面 factor 范围。

## endpoint、快照与 source-family

r25 中的 11 个显式 endpoint ID 只有 `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` 已在正式 endpoint 表。只在 r14 staging 中的 10 个是：HPEC arXiv v1、CUDA Programming Guide 11.0、PTX ISA 7.0/7.2、RAS fixed PDF，以及 MIG 610 Introduction/Concepts/Profiles/Getting Started/Deployment。我重算了 r14 `payload_copies.csv` 对应的 19 个载荷；每个 byte count 和 SHA-256 均与声明相同，但所有 planned stable copy target 仍不存在。这能证明 staging 内容可读，不能证明 formal endpoint closure 已完成。

另一条时间线必须更新：`r1_ga100_source_staging_v3_official_web_v2/` 已经独立验收。复算结果为 29 个 manifest 条目，其中 27 个成功、2 个拒绝且无 payload；27 个 payload 为 22 HTML + 5 PDF，合计 15,817,628 bytes，全部 bytes/SHA-256、HTTP status、Content-Type 和 final URL 匹配。family map 有 19 个唯一 family ID，对 29 个 endpoint 各覆盖一次。这些结果否定了 r25 的“未快照/无本地 hash”，却没有把 staging 自动变成正式来源表。

source-family 去重时，PTX 7.0/7.2、RAS fixed/R595、PyTorch 月版、TensorFlow 月版按同 family revision chain 处理，这些 r25 判断可保留。TensorRT release notes、support matrix 和 developer guide 是三个不同作品家族，r25 也没有错误合并。需要修正的是 cuSPARSELt Guide/Release Notes 和 MIG 版本链，不应因这次快照再造一个 MIG family。

## benchmark、发布与 reverse removal

r25 L216 至 L221 将 workload latency、throughput、power、energy/token、token/J 和 utilization 六个 benchmark field 均留为 `pending`，而 L284 又明确禁止任何 pending 进入 provisional/formal closure。这两处没有事实矛盾：pending 是诚实的当前输入状态，同时也确实阻断发布。不能为了收口将 A100 product/system benchmark 下放到 GA100 die；应继续找 correct-subject source，或按批准的 target/factor policy 记录无可达 target 或搜索闭合。

r25 不预设六源、九源或其他最小数量，这一点通过。但反向移除目前还无法执行：15 个 field 尚未进入综合表，FP64/mandatory N/A 仍用旧合同，10 个 endpoint 未正式注册，六个 benchmark 仍 pending，网页快照又尚未进正式 source pool。只有 field/factor closure、derived DAG、actual endpoint、missing-data evidence 和 product-boundary result 全部稳定后，才能逐 family 删除并重算。

## 修复后的再验收顺序

先把 r25 的合同引用更新到 v4，并拆清正式 preimage、contract postimage 和 GA100 chip postimage；随后恢复 15 个 field，将 mandatory 108 修正为 53/49/6，并用 `rne/rtz/rtn/rtp` 闭合 FP64 选项。再之后，把 HPEC 测试载体归属与 architecture projection 分开建模，对 RAS/MIG 拆 GA100-aware mechanism 与产品条件，完成 r14 与 official-web v2 的正式 source/version/endpoint/family 入库。最后闭合 benchmark 和其他 pending，再跑 full coverage、derived recomputation、reverse removal、13-domain completeness 与独立批准。

再验收的最小机器条件包括：正式 field 复算始终为 141；GA100 108 个 key 全部 include 且只有指定六格可结构 N/A；FP64 四个 advertised rounding mode 集合相等；每条 accepted assertion/result/evidence 有 actual endpoint 与精确 locator；source-family 去重后运行 reverse removal；所有 publishable requirement 不带 pending/conflict/unfixed endpoint。

## 运行边界与文本复核

本机没有 `pwsh`、`powershell` 或 `powershell.exe`，这属于 tool/runtime limitation，不是 sandbox denial、审批失败、远程服务错误或用户拒绝。本轮没有改正式表，也没有声称 Windows 三道 hard gate 通过。

独立计数的第一个 Python 单行辅助命令有一次 shell quoting `SyntaxError`，分类为 model/operator quoting mistake；改用 `/private/tmp` 中的只读辅助脚本后完成复算。macOS system Ruby 2.6 的 CSV parser 因 `fields.csv` 混合 LF/CRLF 严格解析失败，分类为 tool/runtime parser incompatibility；Python 标准库随后成功解析全部 141 行。伪实体首次检查误写了不存在的 `数据/capabilities.csv`，分类为 model/operator path assumption mistake；按实际表名 `数据/special-capabilities.csv` 重跑后完成正式/staging 集合比较。最后一次文本 token 核对把 Markdown backtick 传给 shell，触发了两条 `command not found`，同样分类为 model/operator escaping mistake；改用字面安全引号后重跑，15 个 field、8 个 blocker 和关键计数均齐全。这些失败都是只读检查且已纠正，没有缩减审计范围；本轮无 user interruption、sandbox denial、approval denial、approval-review connection failure 或 remote service error。

`report-humanizer` 已对本文件执行单文件机器扫描。人工逆向复读从运行边界、再验收顺序、benchmark/reverse removal、endpoint/source-family、HPEC/RAS/MIG 主体边界、15 个漏失 field、8 个 blocker 回到开头裁决，重点核对了 141 与 142 的区别、53/49/6、`.rm/.rp`、11 个 endpoint、29/27/2、22/5、15,817,628 bytes，以及 HPEC 测试载体归属不等于 architecture projection 这一边界。
