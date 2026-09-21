# M0 数据模型审查交接

M0（Milestone 0，里程碑 0）指代表型号试填前需要冻结的数据模型基线。

- 审查版本：0.1
- 审查日期：2026 年 8 月 12 日
- 审查范围：资料卡与最小参考资料库的数据模型，不填具体芯片规格

## 审查结论

研究计划已经覆盖资料卡需要采集的内容，但表结构还不能直接冻结。M0 应采用 `objects.csv + object-relations.csv` 作为统一对象层，并把“规范化事实”与“逐来源原文断言及定位”分开。规范事实只在 `facts.csv` 维护；计算、数值路径、存储、互联和特殊模块等专表用于描述实体或关系，也可由脚本生成面向人工检查的视图，不能再次保存同一规格值。

历史 `codex-v3/data` 说明了这个边界为什么必要。33 条产品行中 31 条把多个 `source_id` 放在一个单元格；计算、数值、存储、互联表分别有 91/139、50/71、21/58、35/57 行采用同样写法。对应的多段 `source_locator` 无法稳定配对到具体来源。旧表适合作为迁移线索，不能直接复制成新库。

## 权威真值层与追溯链

建议固定下面这条链：

`object/component/link → field requirement → normalized fact → source assertion → source edition → access endpoint/artifact`

其中：

- `objects.csv`、组件表和链路表回答“事实属于谁或哪条关系”；
- `field-requirements.csv` 回答“这个对象应不应该有该字段”；
- `facts.csv` 是规范值、状态和条件的唯一权威真值层；
- `fact-assertions.csv` 一行只连接一个事实与一个来源版本，保存该来源自己的原文值、单位和定位；
- `sources.csv` 表示可独立引用的内容版本，`source-endpoints.csv` 表示 DOI（Digital Object Identifier，数字对象标识符）页面、产品页、PDF 直链、本地文件或网页快照；
- Markdown 资料卡、`compute-facts-view.csv`、`memory-facts-view.csv`、`interconnect-facts-view.csv` 等均由上述表生成或只作审阅输出。

同一个来源可以支撑多个事实，同一个事实也可以有多个断言。任何事实表中都不再设置单值 `source_id`，也不允许用分号保存多值外键。

## M0 建议表

下表是试填前应冻结的最小 CSV（Comma-Separated Values，逗号分隔值）结构。SKU（Stock Keeping Unit，具体产品配置）作为产品身份事实记录。`PK` 表示主键，`FK` 表示外键，`UQ` 表示唯一约束。

| 文件 | 建议列与约束 | 用途 |
|---|---|---|
| `vendors.csv` | `vendor_id PK`, `vendor_name UQ`, `country_or_region`, `review_status`, `notes` | 统一厂商名称 |
| `objects.csv` | `object_id PK`, `vendor_id FK`, `canonical_label`, `object_type`, `curator_slug UQ`, `review_status`, `notes` | 只保存对象身份和内部规范标签；官方名称、SKU、代际、地区版本、发布日期、供货状态和有效期均作为事实 |
| `object-relations.csv` | `object_relation_id PK`, `subject_object_id FK`, `relation_type`, `object_object_id FK`, `review_status`, `notes`; `UQ(subject_object_id, relation_type, object_object_id)` | 保存关系实体；数量、有效期和证据状态作为该关系的事实 |
| `fields.csv` | `field_id PK`, `field_domain`, `field_name_zh`, `definition`, `value_kind`, `canonical_unit`, `allowed_subject_kinds`, `condition_schema`, `required_tier`, `notes` | 字段字典；一个字段只表达一种指标语义 |
| `field-requirements.csv` | `requirement_id PK`, 七个互斥目标外键，`field_id FK`, `requirement_status`, `applicability_reason`, `search_status`, `last_searched_date`, `review_status`; `requirement_fingerprint UQ` | 建卡进度和缺失的基准集合；七个目标外键见表后说明 |
| `condition-sets.csv` | `condition_set_id PK`, `condition_fingerprint UQ`, `precision_path_id FK nullable`, `sparsity_mode`, `sparsity_pattern`, `performance_basis`, `power_mode`, `frequency_value`, `frequency_unit`, `software_version`, `workload_stage`, `bandwidth_direction`, `aggregation_scope`, `traffic_basis`, `measurement_scope`, `effective_date`, `notes` | 把会影响事实等价性的条件结构化；无附加条件使用固定的 `COND-NONE` |
| `facts.csv` | `fact_id PK`, 七个互斥目标外键，`field_id FK`, `normalized_value_text`, `normalized_value_number`, `normalized_unit`, `condition_set_id FK`, `fact_kind`, `resolution_state`, `valid_from`, `valid_to`, `confidence`, `confidence_reason`, `review_status`, `fact_fingerprint UQ`, `notes` | 唯一规范事实层；数值和文本恰好填写一种，原始值不写在这里 |
| `fact-assertions.csv` | `assertion_id PK`, `fact_id FK`, `source_id FK`, `claim_role`, `assertion_mode`, `assertion_relation`, `raw_value_text`, `raw_value_number`, `raw_unit`, `source_locator`, `quoted_context`, `extraction_status`, `extractor`, `reviewer`, `review_date`, `notes`; `assertion_fingerprint UQ` | 一份来源对一条规范事实的原文断言与定位 |
| `requirement-evidence.csv` | `requirement_evidence_id PK`, `requirement_id FK`, `source_id FK`, `evidence_relation`, `source_locator`, `quoted_context`, `reviewer`, `review_date`, `notes`; `UQ(requirement_id, source_id, source_locator, evidence_relation)` | 支撑 `not_public`、`not_applicable` 和已知但不可访问等缺失判断 |
| `derived-metrics.csv` | `derived_fact_id PK/FK facts.fact_id`, `formula_id`, `formula_expression`, `output_unit`, `scope_check_status`, `precision_check_status`, `direction_check_status`, `review_status`, `notes` | 标识哪些规范事实是公开推导并保存公式 |
| `derived-inputs.csv` | `derived_fact_id FK`, `input_order`, `input_fact_id FK`, `input_role`; `PK(derived_fact_id, input_order)`, `UQ(derived_fact_id, input_fact_id, input_role)` | 保留派生指标的分子、分母和其他输入 |

事实与字段要求使用同一组目标外键：`object_id`、`component_id`、`link_id`、`object_relation_id`、`precision_path_id`、`capability_id` 和 `topology_id`。每行恰好一个目标外键非空；M0 不采用无法在 CSV 中检查的多态 `subject_id`。`fact_fingerprint` 由目标、`field_id`、`condition_set_id`、规范值、规范单位和有效期生成，既阻止重复行，又允许真正冲突的不同值并列存在。

实体表只维护稳定标识、归属关系和受控分类。任何会因来源、时间、SKU 或运行条件变化的属性，包括数量、频率、格式、管理方式、带宽口径、拓扑规模和产品状态，都写入 `facts.csv`。领域专表若出现规格值，只能是由 `facts.csv` 生成的只读视图，不能由研究人员手工维护。数量字段没有例外：`component.instance_count`、`memory_level.instance_count`、`link.physical_link_count`、`link.lane_count`、`topology.node_count`、`topology.node_degree` 和 `topology.max_scale` 全部从实体表删除，分别以对应实体为目标写入 `facts.csv`。
## 对象、继承和变体

`object_type` 建议采用：

`architecture_generation | die | chiplet | package | module | card | cloud_accelerator | cloud_instance | baseboard | server | rack | pod | cluster | switch`

`relation_type` 至少采用：

`implements_architecture | physically_contains | package_contains_die | sku_variant_of | card_uses_module | exposed_as_cloud_accelerator | instance_contains_accelerator | deployed_in_system | connected_by | supersedes_product | renamed_from`

继承只通过 `implements_architecture` 发生。架构事实不会被复制到每个 SKU；生成资料卡时沿该关系显示继承事实，并标注事实原属的架构对象。以下关系不能当继承处理：系统“包含”八个设备、云实例“暴露”若干加速器、卡“使用”某模组、某 SKU 是另一个容量变体。

需要给关系做闭环检查：`implements_architecture` 和 `sku_variant_of` 不得成环；`physically_contains` 的对象层级必须从大到小；同一子对象可以有多个部署关系，不能因此强制单父节点。

## 组件、计算和数值路径

计算、存储和特殊模块应先建立组件实体，再把规格作为事实挂到组件或对象上。

### `components.csv`

建议列：

`component_id PK, owner_object_id FK, parent_component_id FK nullable, component_domain, component_type, canonical_label, review_status, notes`

`component_domain`：`compute | memory | data_movement | special_function | fixed_function | control`。

`component_type` 不要把厂商名混成跨厂商枚举。建议固定上位类型：

- 计算：`matrix | vector | scalar | control | special_function`；
- 数据搬运：`dma | async_copy | load_store | format_conversion | decompression`；
- 固定功能：`video_encode | video_decode | image_decode | security | network_offload | other_fixed_function`。

厂商名称如 `Tensor Core`、`MXU`、`Cube Core` 和 `TSP core` 填入 `canonical_label`，不作为通用 `component_type`。代际、实例数量、作用域、汇聚方式和程序员可见性属于来源相关事实，不写回组件实体。

### `precision-paths.csv`

建议列：

`precision_path_id PK, component_id FK, canonical_label, operation_class, review_status, notes`

操作数、乘积、中间结果、可见累加格式、物理累加位宽、输出格式、缩放、舍入、饱和、非规格数和稀疏兼容性均作为该数值路径的事实。`support_level` 事实采用 `hardware_peak_published | hardware_instruction | hardware_capability | compiler_type | library_only`，避免把接口支持、编译器类型和有公开峰值的硬件路径混在一起。

吞吐、单元数量、阵列形状、发射宽度、并发能力和资源共享关系继续通过 `facts.csv` 表示。计算维度建议使用以下字段或条件枚举：

- `operation_type`: `matrix_mma | matrix_multiply | vector_fma | vector_alu | scalar_fma | scalar_alu | reduction | special_function | data_move | fixed_function`；
- `performance_basis`: `theoretical_peak | vendor_measured | third_party_measured | public_derived | vendor_label_unresolved`；
- `sparsity_mode`: `dense | structured_sparse | unstructured_sparse | vendor_sparse | not_applicable | not_specified`；
- `operation_count_rule`: 独立字段，至少区分 `fma_2_ops | mac_2_ops | vendor_label | not_specified`。

矩阵、向量、标量和特殊函数不可相加为一个无条件“总算力”。若来源只给 `AI TOPS`，存为独立字段 `compute.vendor_ai_tops`，条件中使用 `vendor_label_unresolved`。

### `special-capabilities.csv`

建议列：

`capability_id PK, owner_object_id FK, component_id FK nullable, capability_type, canonical_label, review_status, notes`

`capability_type`：`top_k | sort | moe_route | moe_dispatch | all_to_all | reduction | softmax | sampling | sparse_skip | compression | decompression | quantize | dequantize | kv_cache_management | attention_data_move | collective_offload | other`。

`implementation_level` 作为事实，枚举为 `dedicated_physical_module | dedicated_instruction | configurable_engine | general_compute_path | network_offload | compiler_optimization | library_implementation`。`not_public` 和 `not_found` 只写入经过检索的 `field-requirements.csv`，不写进能力实体。

## 存储作用域

### `memory-levels.csv`

建议列：

`memory_level_id PK/FK components.component_id, parent_memory_level_id FK nullable, level_class, canonical_label, review_status, notes`

关键枚举：

- `level_class`: `register | accumulator_store | local_scratchpad | shared_scratchpad | l0 | l1 | l2 | llc | onchip_sram | hbm | gddr | ddr | host_memory | remote_memory | logical_memory_view`；
- `management_mode`: `hardware_cache | software_scratchpad | compiler_managed | mixed | fixed_datapath | logical_view | not_specified`；
- `locality_scope`: `thread | lane | warp_wave | matrix_unit | vector_unit | core | compute_cluster | chiplet | die | package | card | server | rack | cluster`；
- `pooling_mode`: `private_per_instance | distributed_not_pooled | logically_shared_distributed | physically_shared | partitioned | logical_view_not_physical | unresolved`；
- `aggregation_validity`: `not_aggregatable | aggregate_capacity_only | aggregate_bandwidth_only | capacity_and_bandwidth | unresolved`；
- `read_write_model`: `separate_read_write | shared_read_write | full_duplex | half_duplex | interface_aggregate | not_specified`。

技术类型、管理方式、一致性、可寻址性、作用域、实例数量、汇聚方式、读写模型、容量、带宽和延迟都作为存储层事实。容量、读带宽、写带宽、聚合带宽和延迟使用不同 `field_id`；带宽条件至少记录 `bandwidth_direction`、`aggregation_scope`、`performance_basis` 和 `traffic_basis`。每实例范围、实例数量和全芯片能否汇聚必须分别记录。

## 互联方向和拓扑

### `links.csv`

建议列：

`link_id PK, owner_object_id FK nullable, endpoint_a_id FK, endpoint_b_id FK, link_level, canonical_label, review_status, notes`

### `topologies.csv`

建议列：

`topology_id PK, owner_object_id FK, canonical_label, review_status, notes`

`link_level` 是链路实体的受控分类：`on_core | on_chip | die_to_die | package_internal | host_device | device_direct | node_internal | rack_scale_up | datacenter_scale_out`。协议、物理链路数、Lane 数、拓扑类型、节点数、维度、节点度数、过订阅、路由和最大规模均作为事实。

互联条件须拆为三个正交维度：

- `bandwidth_direction`: `tx | rx | per_direction_symmetric | bidirectional_aggregate | half_duplex_shared | direction_not_specified`；
- `aggregation_scope`: `per_lane | per_physical_link | per_endpoint | per_device_injection | per_axis | path | switch_fabric | system_total | bisection | not_specified`；
- `traffic_basis`: `raw_line_rate | encoded_line_rate | protocol_payload | application_payload | sustained_measured | vendor_nameplate | relative_only | not_specified`。

旧表中的 `bidirectional_per_axis` 应拆成 `bandwidth_direction=bidirectional_aggregate` 与 `aggregation_scope=per_axis`；`relative_comparison_direction_not_separately_defined` 应使用 `traffic_basis=relative_only`，数值无法规范化时保留原文断言而不生成绝对带宽事实。链路速率、端点注入带宽、系统总带宽和二分带宽必须是不同 `field_id`。

## 来源、来源家族和访问入口

### `source-families.csv`

建议列：

`source_family_id PK, canonical_title, family_kind, publisher_or_organization, persistent_work_id, review_status, notes`

`family_kind`：`document_revision_series | publication_versions | mirrored_content | dynamic_page_history | event_material_set | other`。

### `sources.csv`

一行表示一个可以独立引用、内容已经固定或有核查日期的版本：

`source_id PK, source_family_id FK nullable, title, author_or_organization, source_type, publication_date, version_label, language, source_authority, source_status, content_fingerprint, last_verified_date, review_status, notes`

`source_type`：`datasheet | product_brief | architecture_whitepaper | architecture_paper | developer_documentation | api_or_isa_documentation | product_page | cloud_service_documentation | press_release | benchmark_result | microbenchmark | teardown | conference_talk | interview | media_report | standard | source_code | other`。API（Application Programming Interface，应用程序编程接口）和 ISA（Instruction Set Architecture，指令集架构）在这里都属于可固定版本的技术文档。

`source_authority` 只描述出处性质：`first_party | standards_body | peer_reviewed | independent_measurement | independent_analysis | media | unknown`。它不能取代逐事实判断，也不能自动决定筛选结果。

### `source-endpoints.csv`

建议列：

`endpoint_id PK, source_id FK, endpoint_type, url, local_path, sha256, page_count, mime_type, access_date, http_status, snapshot_date, is_preferred_endpoint, accessibility_status, notes`; 对非空规范化 URL 设置 `UQ(url)`，对非空 `sha256` 建索引但不强制唯一，因为同一文件可以有多个合法入口。

`endpoint_type`：`publisher_page | doi_landing | html_page | pdf_direct | local_pdf | web_snapshot | repository | video | other`。

预印本、会议版和期刊版通常属于一个 `source_family_id` 下的不同 `source_id`；同一 PDF 的 DOI 页、出版页、PDF 直链和本地副本是一个 `source_id` 的多个 endpoint。动态网页若内容发生可见变化，应新建来源版本或快照，不能只覆盖 `last_verified_date`。

## 覆盖、重复筛除和最小集

`fact-assertions.csv` 已经构成事实与来源的覆盖矩阵。另建：

### `source-screening.csv`

`screening_id PK, source_id FK, screening_status, selected_role, rationale, full_text_read_status, screened_by, screened_date, review_status, notes`; 每次筛选决策一行，可保留历史版本。

`screening_status`：`pending | selected | lead_only | redundant_covered | superseded | out_of_scope | inaccessible | rejected_unreliable`。

`selected_role`：`core_spec | architecture_mechanism | independent_validation | conflict_evidence | status_version_evidence | none`。一份来源可以有多种角色，若不采用多值字段，应另建 `source-selected-roles.csv(source_id, selected_role)`。

### `source-coverage.csv`

`coverage_id PK, covered_source_id FK, covering_source_id FK, coverage_scope, equivalence_status, rationale, reviewed_by, review_date`; `UQ(covered_source_id, covering_source_id, coverage_scope)`。

`coverage_scope`：`all_supported_facts | selected_fact_set | source_version | access_endpoint`。`equivalence_status`：`fully_covered | partially_covered | stronger_for_same_claim | same_content | not_equivalent`。

标记 `redundant_covered` 前，必须同时满足：该来源所有已核实断言都被选中来源覆盖；覆盖方对象、条件和版本不弱；被筛来源没有独立测量、采访、冲突或独有脚注；`source-coverage.csv` 至少有一组可复核的 `fully_covered` 关系。未读正文的来源只能是 `pending`、`lead_only` 或 `inaccessible`。

最小集不是一次不可追溯的布尔标记。建议增加 `selection-runs.csv(selection_run_id, scope_kind, scope_id, cutoff_date, algorithm_version, created_date, reviewer, status)` 和 `selection-members.csv(selection_run_id FK, source_id FK, selected_role, mandatory_reason, PK(selection_run_id, source_id, selected_role))`，这样每次试填、复核和资料截止日变化后都能重建结果。

## 矛盾、缺失和派生指标

### 矛盾

`conflict-groups.csv`：

`conflict_group_id PK, subject_kind, subject_id, field_id FK, condition_set_id FK, conflict_type, resolution_status, preferred_fact_id FK nullable, resolution_rationale, reviewer, review_date, notes`

`conflict-members.csv`：

`conflict_group_id FK, fact_id FK, member_role, PK(conflict_group_id, fact_id)`

`conflict_type`：`value_disagreement | unit_disagreement | scope_disagreement | condition_disagreement | version_change | terminology_ambiguity | source_error_suspected`。

`resolution_status`：`unreviewed | conditions_reconciled | version_reconciled | unresolved_true_conflict | source_error_confirmed | preferred_for_card_with_alternatives_retained`。

`conflicting` 不进入 `evidence_state`。只有检查对象、时间、精度、稀疏、功耗、方向和作用域后仍无法调和，才使用 `unresolved_true_conflict`。资料卡如选择展示值，必须能回到 `preferred_fact_id`，其他事实仍保留。

### 缺失

缺失状态写在 `field-requirements.csv`，不要伪造成空值事实：

`requirement_status`: `value_available | not_public | not_found | not_applicable | pending_verification | inaccessible_evidence | conflicting_unresolved`。

规则：

- `not_public` 需要一条来源断言明确说明未公开，或审计记录解释判断依据；
- `not_found` 必须关联 `search-log.csv`，保存检索范围、查询、日期和已查来源类型；
- `not_applicable` 必须写 `applicability_reason`，必要时关联支持该判断的事实；
- `inaccessible_evidence` 指已知来源无法合法取得，来源本身同时标 `inaccessible`；
- 未评估的字段使用 `pending_verification`，不能提前写 `not_found`。

`search-log.csv` 建议列：`search_id PK, object_id FK, field_id FK, searched_date, query_or_path, source_types_checked, result_status, source_ids_found, researcher, notes`。其中 `source_ids_found` 若有多值，应再拆 `search-results.csv(search_id, source_id)`。

### 状态维度

`facts.csv` 至少拆开三类状态：

- `assertion_mode`: `direct_statement | measured | derived | inferred`；本阶段原则上不接受无证据的 `inferred` 进入正式卡；
- `evidence_state`: `single_source | corroborated | third_party_only | source_with_caveat`；
- `resolution_state`: `accepted | provisional | superseded | conflict_member | rejected`。

`review_status` 独立采用：`draft | reviewed | needs_resolution | approved`。置信度使用 `high | medium | low`，并要求 `confidence_reason`，不要让置信度替代证据和复核状态。

### 派生指标

存算配比、容量与算力配比和互联注入带宽与算力比都写入 `facts.csv`，并由 `derived-metrics.csv + derived-inputs.csv` 记录计算关系。规范规则至少包括：

1. 输入事实的对象或组件作用域一致；若通过架构继承或每实例换算配对，必须显式记录换算事实；
2. 精度、稠密性、功耗模式和时间版本一致；
3. 存储带宽必须明确是铭牌还是持续实测，互联带宽必须明确方向和聚合范围；
4. 公式中的单位先规范化为 byte、second、FLOP 或 operation，再生成展示单位；
5. `scope_check_status`、`precision_check_status` 和 `direction_check_status` 全部通过后，派生事实才能标 `approved`。

## 不建议沿用的设计

以下旧式设计会阻碍最小资料库筛选，应在 M0 阶段排除：

- 用 `products.csv` 同时表示架构、封装、卡、服务器和集群，却不给对象间关系；
- 用 `architecture-generations.csv` 与 `products.csv` 各自保存可重叠身份事实；
- 在 `facts.csv` 同时保存规范值和多来源原值；
- 在领域表直接写 `source_id/source_locator`，或在一个 CSV 单元格保存分号列表；
- 让 `compute-units.csv`、`numeric-formats.csv`、`memory-levels.csv`、`interconnects.csv` 再次成为数值真值源；
- 把 `third_party_measured`、`public_derived`、`conflicting`、`not_found` 放入同一个状态枚举；
- 把 `per_axis`、`system_total`、`payload` 等口径混进 `bandwidth_direction`；
- 以整篇来源的 A/B 分数取代逐事实的对象匹配、条件匹配和原文定位；
- 把 `not_found` 当成永久状态，或在没有检索日志时使用；
- 用系统聚合值除以设备数制造设备事实。

## 试填前的冻结条件

M0 可在下列条件满足后开始 H100 SXM5 80 GB、Trainium2 和 MLU590 试填：

1. `objects.csv`、`object-relations.csv`、`fields.csv`、`field-requirements.csv`、`facts.csv`、`condition-sets.csv`、`fact-assertions.csv`、`sources.csv`、`source-endpoints.csv` 的表头与枚举已固定；
2. `components.csv`、`precision-paths.csv`、`memory-levels.csv`、`links.csv` 的身份字段已固定，数值字段仍只存在于 `facts.csv`；
3. 校验脚本能检查主键唯一、外键存在、多态事实主语恰好一个、数值/文本二选一、禁止分号外键、每个已接受事实至少有一条已复核断言；
4. `redundant_covered` 必须有 `source-coverage.csv` 的完整覆盖记录；
5. `not_found` 必须有检索日志，`not_applicable` 必须有理由；
6. 派生指标必须通过对象、精度、方向和单位检查；
7. 试填先验证继承显示而不复制、同一事实多来源、同一来源多事实、真实冲突、动态网页版本和系统聚合值六种情况。

## 审查时发现的历史数据风险

这些结果只用于验证新模型，不作为正式规格数据：

- 历史库有 33 个产品对象、139 条计算记录、71 条数值路径、58 条存储记录、57 条互联记录和 226 份来源；
- 58 条存储记录中 49 条有容量、25 条有带宽、没有延迟值；57 条互联记录中 42 条有聚合带宽、11 条有单链路速率、1 条有延迟；
- 历史 `data/README.md` 第 92 行已经含有字面文本 `…18 tokens truncated…`，属于旧文档损坏，不能作为迁移规则；
- 历史来源表没有来源家族、访问入口拆分、内容哈希和逐事实筛选关系；
- 历史表的工作负载分析和 Qwen 派生表不在当前阶段范围内，不应迁入 M0。

## 未解决项

以下内容不阻塞 0.1 试填，但应在三张样卡后决定：

- `condition-sets.csv` 是否进一步拆成关系型条件键值表，避免未来增加字段时改表头；
- 七个互斥目标外键已经在 0.1 固定。三张样卡后只复查校验脚本能否覆盖全部目标类型，不再退回单一 `subject_id` 或四外键方案；
- 来源快照的合法保存策略和动态网页内容指纹算法；
- 拓扑是否需要图边明细表，还是第一轮只保存结构化摘要；
- `not_public` 的最低证据要求如何统一，尤其厂商只是未提及而没有明确说“未公开”的情况；
- 资料卡完成度的权重。建议先按必填字段数计算，不在试填前引入主观分数。

## 任务记忆

- 任务状态：0.1 审查完成，可供总控冻结 M0；三张样卡后需要复审
- 输入：项目 `AGENTS.md`、`研究计划.md`；只读参考历史 `codex-v3/data/README.md` 及其 12 个 CSV
- 已完成：给出统一对象层、对象关系、唯一规范事实层、逐来源断言、来源家族与入口、覆盖筛选、矛盾、缺失、派生指标、计算/数值/存储/互联结构和冻结条件
- 验证：用 PowerShell 导入历史 CSV，核对表头、行数、枚举、多来源单元格和关键字段非空数量；未修改历史目录
- 未解决：条件集合拆分、七目标外键校验实现、网页指纹、拓扑图明细、`not_public` 最低证据和完成度权重
- 建议下一步：总控按“试填前的冻结条件”建立 M0 表头和校验器，再用三张代表卡验证六种高风险情况
- 写入文件：`审计/子代理交接/schema_review.md`