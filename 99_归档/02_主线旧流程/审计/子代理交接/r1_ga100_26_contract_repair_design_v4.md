# GA100 资料卡合同修复设计 v4

## 状态、输入与适用顺序

本稿是合同设计，不是迁移许可，也不表示 GA100 工作包、三运行时 fixture 或 Windows 数据门已经通过。允许的写入只有本文件。正式表、模板、validator、staging、进度文件以及下列三个冻结输入均保持原字节：

| 冻结输入 | SHA-256 |
|---|---|
| `r1_ga100_19_contract_repair_design_v3.md` | `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8` |
| `r1_contract_08_design_v3_independent_review.md` | `161cfc6142b6b84b823fa65ec4c7d5476bf2601d9073ca4ef9462abf89c27a07` |
| `r1_contract_09_design_v3_additional_redteam.md` | `37bcc1243862d2c7540c05caff323d10d0d1da12246d33a556623707ba553f69` |

v4 以该 SHA 的 v3 为规范基底，完整保留未被 R08、R09 否决的条款。本稿给出替代条款时，以本稿为准；本稿没有触及的 v3 条款继续生效。实现者不得从同名但不同 SHA 的文件继承规则。独立验收先核对三个输入 SHA，再按本稿的 repair crosswalk 逐项运行反例。这样的引用关系是闭合的，验收不依赖聊天记录或实现者口头约定。

正式合同 postimage 固定为 34 张表、376 个 schema column、141 个 field、77 个 enum group 和 564 个 enum row。141 个 field 通过删除未引用的 `FIELD-ID-DATA-CUTOFF` 并增加 `FIELD-COMP-INSTRUCTION-LATENCY` 得到。当前 832 条 assertion 全量迁移到 AFPV2；空 `endpoint_id` 在 fingerprint payload 中编码为 JSON `null`，新卡发布链仍要求 actual endpoint 非空。活动 scope、allocation、mapping、cutoff、immutable legacy reconciliation、精确 reachability、58-key coverage manifest、事务、恢复、三运行时 fixture 和模板迁移均继续执行 v3 的门。

GA100 的 12 个 numerics field 与 9 个 precision path 形成 108 个 mandatory include key。它们不能用 `exclude` 或缺少结构证明的 `not_applicable` 规避；下节六个专用 N/A key仍保持 include并完整关闭。所有 141 个 field 与 reachable real target 的候选全集、全部 factor obligation、全部 kind-allowed factor target pair 和 include binding 仍由独立 builder 构造并做 set-equal。

`FIELD-MEM-LATENCY.canonical_unit` 仍为空，direct fact 的 normalized unit 只允许 `cycle` 或 `s`。没有同一 clock domain 的可靠频率时必须保留 `cycle`；任何 `cycle` 到 `s` 的转换只能形成 derived fact，并关闭频率输入、单位、scope 和派生 DAG。`FIELD-COMP-INSTRUCTION-LATENCY.canonical_unit` 固定为 `cycle`，不得混入 memory latency 或 workload latency。

## rounding enum 与 GA100 mandatory N/A

当前 557 行 enum baseline 的迁移公式改为：

```text
557 - 1 product_status.historical_anchor
    + 5 card_lifecycle
    + 1 selected_role.coverage_obligation_evidence
    + 2 rounding_mode
  = 564 enum rows
```

enum group 没有新增，仍为 77。`rounding_mode` 在现有 ordinal 1 至 5 后追加以下两行，ID 与 ordinal 不得重排：

```text
ENUM-ROUNDING-MODE-006,rounding_mode,rtn,6,枚举 rounding_mode 的受控值 rtn（toward negative infinity）,approved,
ENUM-ROUNDING-MODE-007,rounding_mode,rtp,7,枚举 rounding_mode 的受控值 rtp（toward positive infinity）,approved,
```

PTX modifier 的规范映射固定为 `.rn→rne`、`.rz→rtz`、`.rm→rtn`、`.rp→rtp`。对 exact FP64 matrix MMA path，来源同时给出默认 `.rn` 和可选 `.rz/.rm/.rp` 时，`FIELD-NUM-ROUNDING` 的同一 mandatory requirement 必须由四条 condition-distinguished accepted fact 关闭，不能只保存默认 `rne`。每条 fact 仍绑定同一 actual source family 的独立 AFPV2 assertion 与 locator；同 family 多条事实不增加来源独立数。

这些 rounding fact 的 condition-set.notes 使用 exact-key JSON：

```text
condition_contract_version,instruction_or_opcode,modifier,mode_role,source_condition_text
```

version 固定 `ROUNDING-MODE-CONDITION-V1`；modifier 只允许 `.rn,.rz,.rm,.rp`；mode_role 只允许 `default,supported_option`；`.rn` 必须是 default，其余三个必须是 supported_option。source_condition_text 非空。source 只列出部分 modifier 时，结构化集合必须与 locator 中实际列出的集合相等；不能补推，也不能漏掉已明示模式。该规则描述 PTX virtual ISA contract，不外推 native SASS、RTL 或物理 datapath。

GA100 108 个 mandatory key 的含义修订为“candidate 一律 include 并完成裁决”，不再把 requirement status `not_applicable` 全面禁止。每个 key 仍必须 `decision=include,reason_code=mandatory_include`，不得 exclude，且精确引用一条 same-field/same-precision-path requirement。requirement status 可为 `not_applicable`，但只允许 policy 中以下六个 exact key：

```text
(FIELD-NUM-ROUNDING,PPATH-M2NA-AMPERE-TENSOR-INT8,integer_matrix_no_rounding_stage)
(FIELD-NUM-SUBNORMAL,PPATH-M2NA-AMPERE-TENSOR-INT8,integer_datatype_has_no_subnormal)
(FIELD-NUM-ROUNDING,PPATH-R1-GA100-AMPERE-TENSOR-INT4,integer_matrix_no_rounding_stage)
(FIELD-NUM-SUBNORMAL,PPATH-R1-GA100-AMPERE-TENSOR-INT4,integer_datatype_has_no_subnormal)
(FIELD-NUM-ROUNDING,PPATH-R1-GA100-AMPERE-TENSOR-BINARY,logical_matrix_no_rounding_stage)
(FIELD-NUM-SUBNORMAL,PPATH-R1-GA100-AMPERE-TENSOR-BINARY,logical_datatype_has_no_subnormal)
```

`ga100_mandatory_policy` 的 key 顺序改为 `scope_id,card_object_id,field_ids,precision_path_ids,mandatory_structural_na_rules,expected_cell_count,expected_key_set_canonical_sha256`。新增 array 的每项 exact keys 为 `field_id,precision_path_id,reason_code,structural_na_predicate_id`，并与上述六行 set-equal。structural predicate 必须从 exact datatype/instruction semantics 独立复算为 true。requirement 的 `applicability_reason` 使用 exact-key JSON `reason_contract_version,reason_code,instruction_or_opcode,datatype_semantics,proof_requirement_evidence_id`，version 固定 `MANDATORY-NA-V1`；最后一项必须解析到 `supports_not_applicable` evidence，该 evidence有同源 actual endpoint与 canonical locator，reviewer非空且逐字不等于 coverage manifest.prepared_by。缺 predicate、缺 proof、错 reason code 或 floating path 写 N/A 均失败。

这六格仍计入 108 include 与 coverage closed count。N/A 不生成伪 value fact，也不得把 `not_applicable`、`not_specified` 或任意 enum token当成普通 normalized rounding/subnormal value。其他 102 格继续禁止 N/A，除非未来经新 policy version 显式扩展 mandatory structural N/A set。

## canonical bytes 的共同规则

### 标量、JSON 和 framing

v3 的 UTF-8、BOM、Unicode scalar、JSON key 顺序、最短整数、CSV 全 cell 引号、LF、末尾单 LF 和 Markdown 活动表解析规则继续生效。v4 增加的 synthetic set 与 schema payload 使用同一 strict JSON writer。禁止未知 key、重复 key、乱序 key、schema 外类型和实现端 normalization。

本稿中的 canonical hash 一律按下式计算，其中长度是 payload 的 UTF-8 byte 数，不含 domain 和 framing：

```text
framed_bytes = UTF8(domain_tag) || 0x00 || UINT64_BE(len(payload_bytes)) || payload_bytes
canonical_sha256 = SHA256(framed_bytes)
```

JSON `null` 只用于下文明确允许 nullable 的 key。synthetic item 的非空 string 不能用 `""`、字符串 `"null"` 或省 key 代替。array 的顺序由各自合同定义；hash 前发现重复 logical key 必须报错，不能按 set 去重后继续。

### schema payload 的唯一 envelope

三个 schema hash 都使用下列 exact-key object。顶层 key 顺序固定为 `schema_contract_version,artifact_path,logical_primary_key,sort_key,columns`；`schema_contract_version` 固定 `CANONICAL-SCHEMA-V1`。`logical_primary_key` 与 `sort_key` 都是非空 string array。`columns` 按 ordinal 数值升序，每项 key 顺序固定为 `ordinal,name,scalar_type,nullable,enum_domain`。ordinal 是从 1 连续递增的 JSON integer；前三个文本 key 非空；nullable 是 bool；非 enum 列的 `enum_domain` 必须为 JSON `null`，enum 列必须写本节给出的非空 string。

```json
{"schema_contract_version":"CANONICAL-SCHEMA-V1","artifact_path":"...","logical_primary_key":["..."],"sort_key":["..."],"columns":[{"ordinal":1,"name":"...","scalar_type":"...","nullable":false,"enum_domain":null}]}
```

`legacy_reconciliation_schema_canonical_sha256` 的 domain 固定 `legacy-reconciliation-schema-v1`，artifact path 固定 `审计/合同注册表/legacy-requirement-reconciliation-events.csv`，logical primary key 固定 `["reconciliation_event_id"]`，sort key 固定 `["legacy_requirement_id","reconciliation_event_seq","reconciliation_event_id"]`。完整 columns 如下：

| ordinal | name | scalar_type | nullable | enum_domain |
|---:|---|---|---|---|
| 1 | `reconciliation_event_id` | `id` | false | null |
| 2 | `reconciliation_event_seq` | `uint` | false | null |
| 3 | `legacy_requirement_id` | `text` | false | null |
| 4 | `legacy_baseline_canonical_row_sha256` | `sha256` | false | null |
| 5 | `successor_requirement_id` | `text` | true | null |
| 6 | `successor_canonical_row_sha256` | `sha256` | true | null |
| 7 | `field_id` | `text` | false | null |
| 8 | `object_id` | `text` | true | null |
| 9 | `component_id` | `text` | true | null |
| 10 | `link_id` | `text` | true | null |
| 11 | `object_relation_id` | `text` | true | null |
| 12 | `precision_path_id` | `text` | true | null |
| 13 | `capability_id` | `text` | true | null |
| 14 | `topology_id` | `text` | true | null |
| 15 | `event_type` | `enum` | false | `reconciliation_event_type` |
| 16 | `reconciliation_basis` | `text` | false | null |
| 17 | `reviewed_by` | `text` | false | null |
| 18 | `reviewed_date` | `date` | false | null |
| 19 | `approved_by` | `text` | true | null |
| 20 | `approved_date` | `date` | true | null |
| 21 | `approval_status` | `enum` | false | `reconciliation_approval_status` |
| 22 | `notes` | `text` | true | null |

`active_scope_list_schema_canonical_sha256` 的 domain 固定 `active-scope-list-schema-v1`，artifact path 固定 `清单/训练与推理芯片名单.md`，logical primary key 和 sort key 都固定为 `["scope_id"]`。columns 依次为 `scope_id:scope_id:false:null`、`厂商:text:false:null`、`芯片对象:text:false:null`、`层级:text:false:null`、`角色:text:false:null`、`共享设计组:text:false:null`、`一手身份来源:text:false:null`，ordinal 为 1 至 7。这里的 schema hash 只绑定 `## 正式名单` 下第一张表的结构；活动行 hash 仍使用 `active-scope-markdown-row-v1` envelope。

`journal_schema_canonical_sha256` 的 domain 固定 `transaction-journal-schema-v1`，artifact path 固定为包含字面占位符的 `审计/事务/<transaction_id>/control/transaction-journal.csv`。占位符不得替换为实际 transaction ID 后再计算 schema hash。logical primary key 固定 `["journal_event_id"]`，sort key 固定 `["event_seq","journal_event_id"]`。完整 columns 如下：

| ordinal | name | scalar_type | nullable | enum_domain |
|---:|---|---|---|---|
| 1 | `journal_event_id` | `id` | false | null |
| 2 | `transaction_id` | `id` | false | null |
| 3 | `event_seq` | `uint` | false | null |
| 4 | `manifest_canonical_sha256` | `sha256` | false | null |
| 5 | `previous_event_canonical_sha256` | `sha256` | true | null |
| 6 | `event_type` | `enum` | false | `transaction_journal_event_type` |
| 7 | `event_time_utc` | `rfc3339_utc_second` | false | null |
| 8 | `executor` | `text` | false | null |
| 9 | `observed_state_canonical_set_sha256` | `sha256` | false | null |
| 10 | `event_canonical_sha256` | `sha256` | false | null |
| 11 | `status` | `enum` | false | `transaction_journal_status` |
| 12 | `notes` | `text` | true | null |

### 四类 synthetic key set

每类 payload 都是 JSON array。target kind 必须来自 policy 固定顺序 `object,component,link,object_relation,precision_path,capability,topology`。下表的 item key 按书写顺序序列化，全部非空且不可为 null。

| manifest key | domain | item exact keys | logical key 与排序 |
|---|---|---|---|
| `expected_field_target_pairs_canonical_set_sha256` | `expected-field-target-pairs-v1` | `field_id,target_kind,target_id` | field_id bytes、target kind ordinal、target_id bytes |
| `expected_factor_obligations_canonical_set_sha256` | `expected-factor-obligations-v1` | `card_object_id,policy_id,factor_id` | 三个值的 UTF-8 bytes tuple |
| `expected_factor_target_pairs_canonical_set_sha256` | `expected-factor-target-pairs-v1` | `card_object_id,policy_id,factor_id,target_kind,target_id` | 前三值 bytes、target kind ordinal、target_id bytes |
| `ga100_mandatory_keys_canonical_set_sha256` | `ga100-mandatory-keys-v1` | `field_id,target_kind,target_id` | field_id bytes、target_id bytes；target_kind 必须逐项等于 `precision_path` |

expected factor pair 不含实现者生成的 `factor_requirement_id`。builder 先生成 obligation triple，再与 reachable target 组合。这样更换任意合法 ID 不会改变 expected set；正式 factor requirement、candidate 和 binding 必须通过 obligation triple 投影与该集合逐键 exactly one。

空 synthetic set 的 payload 只能是 `[]`。GA100 mandatory set 不允许为空，必须恰有 108 项，并与 policy 中 12×9 的笛卡尔积逐项相等。

### 58-key coverage manifest 的 hash 账本

coverage manifest 保持 v3 的 58 个 key 和顺序，contract version 改为 `COVERAGE-CONTRACT-V4`。independent approval保持 v3 key顺序，contract version改为 `COVERAGE-APPROVAL-V4`。下表覆盖 manifest 中全部 raw 或 canonical hash 输入。没有列出的 scalar、date、ID、count 和 notes 仍按 v3 exact-key schema 校验。

| manifest key | 独立重算输入与 domain |
|---|---|
| `policy_canonical_sha256` | strict coverage policy JSON，`json-policy-v1` |
| `policy_approval_canonical_sha256` | strict policy approval JSON，`json-approval-v1` |
| `source_date_policy_raw_file_sha256` | date-policy CSV 磁盘原字节，不 framing |
| `source_date_policy_canonical_set_sha256` | date-policy 正式 row envelope 全集，`rowset-v1` |
| `source_date_policy_approval_canonical_sha256` | strict approval JSON，`json-approval-v1` |
| `legacy_registry_raw_file_sha256` | immutable disposition CSV 原字节 |
| `legacy_registry_canonical_set_sha256` | 1,059 行 disposition rowset，`rowset-v1` |
| `legacy_registry_approval_canonical_sha256` | strict approval JSON，`json-approval-v1` |
| `legacy_reconciliation_schema_canonical_sha256` | 本稿冻结的 22-column schema object，`legacy-reconciliation-schema-v1` |
| `relevant_legacy_reconciliations_canonical_set_sha256` | 当前 package 所有相关 key 的完整 event chain rowset，`closure-rowset-v1` |
| `card_object_canonical_row_sha256` | card object 完整正式 row envelope，`row-v1` |
| `card_identity_completeness_canonical_row_sha256` | identity completeness row envelope，`row-v1` |
| `card_completeness_canonical_set_sha256` | 同 card 恰好 13 行 completeness，`rowset-v1` |
| `active_scope_list_schema_canonical_sha256` | 本稿冻结的 7-column schema object，`active-scope-list-schema-v1` |
| `active_scope_list_row_canonical_sha256` | 当前 scope 的 Markdown row envelope，`row-v1` |
| `scope_allocation_canonical_row_sha256` | allocation 完整 row envelope，`row-v1` |
| `mapping_event_canonical_row_sha256` | latest approved unblocked mapping row envelope，`row-v1` |
| `expected_projection_relations_canonical_set_sha256` | 独立 builder 命中的正式 object-relations rowset，`rowset-v1` |
| `fields_contract_canonical_set_sha256` | 完整 141 行 fields rowset，`rowset-v1` |
| `coverage_schema_canonical_set_sha256` | 完整 376 行 schema-columns rowset，`rowset-v1` |
| `coverage_enums_canonical_set_sha256` | 完整 564 行 enums rowset，`rowset-v1` |
| `reachable_inventory_canonical_set_sha256` | v3 reachable envelope 全集，`closure-rowset-v1` |
| `expected_field_target_pairs_canonical_set_sha256` | 本稿 synthetic set，`expected-field-target-pairs-v1` |
| `expected_factor_obligations_canonical_set_sha256` | 本稿 synthetic set，`expected-factor-obligations-v1` |
| `expected_factor_target_pairs_canonical_set_sha256` | 本稿 synthetic set，`expected-factor-target-pairs-v1` |
| `ga100_mandatory_keys_canonical_set_sha256` | 本稿 synthetic set，`ga100-mandatory-keys-v1` |
| `relevant_legacy_dispositions_canonical_set_sha256` | relevant immutable disposition 正式 rowset，`closure-rowset-v1` |
| `closure_canonical_set_sha256` | 全部来源、actual endpoint、locator、cutoff、factor、派生、scope 与 completeness closure，`closure-rowset-v1` |
| 五个 `*_raw_file_sha256` | 对应五张 coverage CSV 的 strict controlled raw bytes，各自直接 SHA-256 |

validator 必须逐键执行下列比较。`Build*` 不能读取 manifest 中的 expected hash 或作者给出的候选 ID 集。

```text
Require(HashCanonicalSchema(LegacyReconciliationSchemaV1) == manifest.legacy_reconciliation_schema_canonical_sha256)
Require(HashCanonicalSchema(ActiveScopeListSchemaV1) == manifest.active_scope_list_schema_canonical_sha256)
Require(HashExpectedFieldTargetPairs(BuildExpectedFieldTargetPairs(fields, inventory)) == manifest.expected_field_target_pairs_canonical_set_sha256)
Require(HashExpectedFactorObligations(BuildExpectedFactorObligations(card, policy)) == manifest.expected_factor_obligations_canonical_set_sha256)
Require(HashExpectedFactorTargetPairs(BuildExpectedFactorTargetPairs(card, policy, inventory)) == manifest.expected_factor_target_pairs_canonical_set_sha256)
Require(HashGa100MandatoryKeys(Cartesian(policy.ga100.field_ids, policy.ga100.precision_path_ids)) == manifest.ga100_mandatory_keys_canonical_set_sha256)
Require(HashCanonicalSchema(TransactionJournalSchemaV1) == transaction_manifest.journal_schema_canonical_sha256)
```

随后再执行账本中每个正式 row、rowset、JSON 和 raw file 的逐键 `Require(recomputed == declared)`。缺少 builder、读取 manifest 倒推出 expected input、使用未声明 domain、把 raw hash 代替 canonical hash、把 logical duplicate 折叠成 set，均返回 `E_HASH_INPUT_CONTRACT`。

## golden serialization fixtures

下列 fixture 是 v4 必须内置的最小 oracle。`expected_canonical_hex` 是完整 framed bytes 的小写 hex，不只是 JSON payload hex。三个 schema fixture 使用同一 envelope 的一列缩小实例；生产 hash 仍必须使用前节完整 columns。fixture 的 domain、payload、hex 和 hash 四者都要逐字匹配。

| fixture_id | input_kind | domain | exact payload | expected_sha256 |
|---|---|---|---|---|
| `FIX-V4-LEGACY-SCHEMA` | `canonical_schema` | `legacy-reconciliation-schema-v1` | `{"schema_contract_version":"CANONICAL-SCHEMA-V1","artifact_path":"x.csv","logical_primary_key":["id"],"sort_key":["id"],"columns":[{"ordinal":1,"name":"id","scalar_type":"text","nullable":false,"enum_domain":null}]}` | `1132463f16e07cceaac5d8876cc0d8666f5b099a776544078ff126bce572815d` |
| `FIX-V4-ACTIVE-SCOPE-SCHEMA` | `canonical_schema` | `active-scope-list-schema-v1` | `{"schema_contract_version":"CANONICAL-SCHEMA-V1","artifact_path":"x.md","logical_primary_key":["scope_id"],"sort_key":["scope_id"],"columns":[{"ordinal":1,"name":"scope_id","scalar_type":"scope_id","nullable":false,"enum_domain":null}]}` | `a7bd302d5cca32a144a188837b378492e466dab78d01bc3f5eed39e41aec4c1a` |
| `FIX-V4-FIELD-PAIR` | `virtual_field_target_pairs` | `expected-field-target-pairs-v1` | `[{"field_id":"FIELD-A","target_kind":"object","target_id":"OBJ-A"}]` | `a042e11a61d9c1ac288b7a1d65b8bba4a0f6e48b9c41d175a143ef51d58d42ed` |
| `FIX-V4-FACTOR-OBLIGATION` | `virtual_factor_obligations` | `expected-factor-obligations-v1` | `[{"card_object_id":"OBJ-A","policy_id":"POLICY-A","factor_id":"FACTOR-A"}]` | `8df2bf10b2f34955b0edf1cdd1301caf83bfa6229fb98820fe7ecff5364f3210` |
| `FIX-V4-FACTOR-PAIR` | `virtual_factor_target_pairs` | `expected-factor-target-pairs-v1` | `[{"card_object_id":"OBJ-A","policy_id":"POLICY-A","factor_id":"FACTOR-A","target_kind":"component","target_id":"COMP-A"}]` | `b53f50f0de8609b187818d070b0849b9751606a7cf3eacb0d9944199fcc31b5f` |
| `FIX-V4-MANDATORY-KEY` | `virtual_ga100_mandatory_keys` | `ga100-mandatory-keys-v1` | `[{"field_id":"FIELD-A","target_kind":"precision_path","target_id":"PPATH-A"}]` | `61e7f5b8452a31d29a46cd0730f4cbe22b3e079eb462ec2b321b9204105492ed` |
| `FIX-V4-JOURNAL-SCHEMA` | `canonical_schema` | `transaction-journal-schema-v1` | `{"schema_contract_version":"CANONICAL-SCHEMA-V1","artifact_path":"journal.csv","logical_primary_key":["journal_event_id"],"sort_key":["event_seq","journal_event_id"],"columns":[{"ordinal":1,"name":"journal_event_id","scalar_type":"id","nullable":false,"enum_domain":null}]}` | `721ac5e607cce9b5bac57980cdf4d29cdb10e98b3a6a8499a9505ccef2d02894` |

对应 expected canonical hex 固定为：

```text
FIX-V4-LEGACY-SCHEMA=6c65676163792d7265636f6e63696c696174696f6e2d736368656d612d76310000000000000000d77b22736368656d615f636f6e74726163745f76657273696f6e223a2243414e4f4e4943414c2d534348454d412d5631222c2261727469666163745f70617468223a22782e637376222c226c6f676963616c5f7072696d6172795f6b6579223a5b226964225d2c22736f72745f6b6579223a5b226964225d2c22636f6c756d6e73223a5b7b226f7264696e616c223a312c226e616d65223a226964222c227363616c61725f74797065223a2274657874222c226e756c6c61626c65223a66616c73652c22656e756d5f646f6d61696e223a6e756c6c7d5d7d
FIX-V4-ACTIVE-SCOPE-SCHEMA=6163746976652d73636f70652d6c6973742d736368656d612d76310000000000000000ec7b22736368656d615f636f6e74726163745f76657273696f6e223a2243414e4f4e4943414c2d534348454d412d5631222c2261727469666163745f70617468223a22782e6d64222c226c6f676963616c5f7072696d6172795f6b6579223a5b2273636f70655f6964225d2c22736f72745f6b6579223a5b2273636f70655f6964225d2c22636f6c756d6e73223a5b7b226f7264696e616c223a312c226e616d65223a2273636f70655f6964222c227363616c61725f74797065223a2273636f70655f6964222c226e756c6c61626c65223a66616c73652c22656e756d5f646f6d61696e223a6e756c6c7d5d7d
FIX-V4-FIELD-PAIR=65787065637465642d6669656c642d7461726765742d70616972732d76310000000000000000435b7b226669656c645f6964223a224649454c442d41222c227461726765745f6b696e64223a226f626a656374222c227461726765745f6964223a224f424a2d41227d5d
FIX-V4-FACTOR-OBLIGATION=65787065637465642d666163746f722d6f626c69676174696f6e732d763100000000000000004a5b7b22636172645f6f626a6563745f6964223a224f424a2d41222c22706f6c6963795f6964223a22504f4c4943592d41222c22666163746f725f6964223a22464143544f522d41227d5d
FIX-V4-FACTOR-PAIR=65787065637465642d666163746f722d7461726765742d70616972732d76310000000000000000795b7b22636172645f6f626a6563745f6964223a224f424a2d41222c22706f6c6963795f6964223a22504f4c4943592d41222c22666163746f725f6964223a22464143544f522d41222c227461726765745f6b696e64223a22636f6d706f6e656e74222c227461726765745f6964223a22434f4d502d41227d5d
FIX-V4-MANDATORY-KEY=67613130302d6d616e6461746f72792d6b6579732d763100000000000000004d5b7b226669656c645f6964223a224649454c442d41222c227461726765745f6b696e64223a22707265636973696f6e5f70617468222c227461726765745f6964223a2250504154482d41227d5d
FIX-V4-JOURNAL-SCHEMA=7472616e73616374696f6e2d6a6f75726e616c2d736368656d612d76310000000000000001117b22736368656d615f636f6e74726163745f76657273696f6e223a2243414e4f4e4943414c2d534348454d412d5631222c2261727469666163745f70617468223a226a6f75726e616c2e637376222c226c6f676963616c5f7072696d6172795f6b6579223a5b226a6f75726e616c5f6576656e745f6964225d2c22736f72745f6b6579223a5b226576656e745f736571222c226a6f75726e616c5f6576656e745f6964225d2c22636f6c756d6e73223a5b7b226f7264696e616c223a312c226e616d65223a226a6f75726e616c5f6576656e745f6964222c227363616c61725f74797065223a226964222c226e756c6c61626c65223a66616c73652c22656e756d5f646f6d61696e223a6e756c6c7d5d7d
```

每项必须由 PowerShell 5.1、PowerShell 7 和 Python 3 分别产生相同 hex/hash。fixture 文件缺失、只给 hash 未给 hex，或实现端把 schema 小样替换成生产 schema，都失败。

## transaction 输入 enum、路径和全集

### 封闭 enum

`transaction-file-inputs.csv.input_role` 只允许以下 36 个 token，大小写敏感：

```text
contract_design
coverage_policy
coverage_policy_approval
source_date_policy
source_date_policy_approval
legacy_requirement_registry
legacy_requirement_registry_approval
legacy_reconciliation_registry
active_scope_list
scope_allocation_registry
scope_mapping_registry
schema_registry
enum_registry
field_registry
formula_evaluator_spec
data_validator
scope_validator
source_pool_validator
recovery_validator
card_template
field_dictionary
project_readme
project_agents
research_plan
current_status
canonical_fixture_manifest
canonical_fixtures
canonical_runtime_results
coverage_manifest
coverage_approval
coverage_targets
factor_target_candidates
reachable_target_bindings
coverage_fields
coverage_exclusion_reviews
managed_patch
```

`canonical-fixtures.csv.input_kind` 只允许以下 token：

```text
canonical_json
controlled_csv
active_scope_markdown
canonical_schema
virtual_field_target_pairs
virtual_factor_obligations
virtual_factor_target_pairs
virtual_ga100_mandatory_keys
managed_state
assertion_fingerprint
condition_mapping
safe_path
transaction_role_universe
transaction_table_image
coverage_semantics
source_closure
migration_recovery
```

fixture error code 在 v3 列表上追加 `E_ENUM,E_PATH,E_REQUIRED_SET,E_TABLE_STATE,E_PACKAGE_OWNERSHIP,E_LOGICAL_KEY_DUPLICATE,E_MANAGED_TARGET_OVERLAP,E_CANONICAL_NULL,E_CONDITION_MAPPING,E_SOURCE_MINIMUM,E_SELECTOR_CARDINALITY,E_MIGRATION_STATE,E_HASH_INPUT_CONTRACT`。未知 input kind、input role 或 error code 都在解析阶段失败，不能归入 `other`。

### 安全项目相对路径

所有 path 列统一调用 `ValidateSafeProjectRelativePathV1`。该函数适用于：

```text
operations.table_path
operations.input_payload_path
operations.rollback_payload_path
transaction-table-images.table_path
transaction-table-images.rollback_preimage_path
transaction-payload-inventory.source_path
transaction-payload-inventory.target_path
transaction-payload-inventory.rollback_payload_path
transaction-file-inputs.relative_path
rollback-file-inventory.target_path
rollback-file-inventory.rollback_payload_path
canonical-fixtures.input_file
reachable-target-bindings.resolved_table_path
canonical-schema.artifact_path
```

nullable matrix要求为空的 path 不调用该函数；其余空值失败。journal schema 的字面占位符先按 path-template grammar验证，其余 artifact path直接按 path grammar验证。合法路径必须是项目根下的相对 Unicode scalar string，分隔符只能为 `/`。路径不能以 `/` 开头或结尾，不能匹配 Windows drive prefix、UNC、URI scheme，不能含 `\\`、NUL、ASCII control、空 segment、`.` 或 `..` segment。解析已有 ancestor 的 symlink 后仍必须位于同一项目根；目标尚不存在时解析最近的已有 ancestor。固定合同路径按 UTF-8 scalar 逐字比较，不 case-fold、不做 Unicode normalization。两个不同字符串若在当前文件系统解析到同一 file identity，也按 collision 拒绝。

`<transaction_id>` 只在下文路径模板中出现。实例化时必须替换为已经通过 `id` 规则的 transaction ID，替换后再次运行安全路径检查。任何 `%2e`、环境变量、glob、shell expansion 或 home shortcut 都只作为普通字符，不能参与路径解析；合同列出的模板没有这些字符，因此额外路径仍会被全集门拒绝。

### 两种 transaction kind 的 role-path 全集

令 `T = 审计/事务/<transaction_id>`。validator 在不读取 `transaction-file-inputs.csv` 的情况下，根据 transaction kind 和 manifest transaction ID 构造 required set 与 allowed set。v4 的两种 kind 都规定 `required_set == allowed_set`，所以每行 `is_required` 必须为 `true`，CSV 的 `(input_role,relative_path)` 投影与下列集合 set-equal，且每个 pair 恰一行。少一项、多一项、同 path 换 role、额外 role 或重复 ID 均失败。

两种 transaction kind 共享以下固定 pair：

```text
(contract_design,审计/子代理交接/r1_ga100_26_contract_repair_design_v4.md)
(coverage_policy,审计/合同注册表/coverage-policy-v4.0.json)
(coverage_policy_approval,审计/合同注册表/coverage-policy-v4.0-approval.json)
(source_date_policy,审计/合同注册表/source-date-policy-v3.0.csv)
(source_date_policy_approval,审计/合同注册表/source-date-policy-approval.json)
(legacy_requirement_registry,审计/合同注册表/legacy-requirement-disposition.csv)
(legacy_requirement_registry_approval,审计/合同注册表/legacy-requirement-disposition-approval.json)
(legacy_reconciliation_registry,审计/合同注册表/legacy-requirement-reconciliation-events.csv)
(active_scope_list,清单/训练与推理芯片名单.md)
(scope_allocation_registry,审计/合同注册表/scope-id-registry.csv)
(scope_mapping_registry,审计/合同注册表/scope-object-mapping.csv)
(schema_registry,数据/schema-columns.csv)
(enum_registry,数据/enums.csv)
(field_registry,数据/fields.csv)
(data_validator,scripts/validation/Validate-ResearchData.ps1)
(scope_validator,scripts/validation/Test-ChipScope.ps1)
(source_pool_validator,scripts/validation/Test-SourcePool.ps1)
(recovery_validator,scripts/validation/verify_recovery_paths.py)
(card_template,资料卡/模板.md)
(field_dictionary,资料卡/字段字典.md)
(project_readme,README.md)
(project_agents,AGENTS.md)
(research_plan,研究计划.md)
(current_status,进度/当前状态.md)
(canonical_fixture_manifest,审计/合同注册表/canonical-fixture-manifest.json)
(canonical_fixtures,审计/合同注册表/canonical-fixtures.csv)
(canonical_runtime_results,审计/合同注册表/canonical-runtime-results.csv)
```

`contract_migration` 在共享集合上精确增加以下 pair。patch file 是 exact-key canonical JSON，记录 target path、preimage raw hash、postimage raw hash 和操作类型；它是输入证据，实际目标仍由 payload inventory 管理。

```text
(managed_patch,T/inputs/patches/formula-evaluator-spec.patch.json)
(managed_patch,T/inputs/patches/validate-research-data.patch.json)
(managed_patch,T/inputs/patches/test-chip-scope.patch.json)
(managed_patch,T/inputs/patches/test-source-pool.patch.json)
(managed_patch,T/inputs/patches/verify-recovery-paths.patch.json)
(managed_patch,T/inputs/patches/card-template.patch.json)
(managed_patch,T/inputs/patches/field-dictionary.patch.json)
(managed_patch,T/inputs/patches/project-readme.patch.json)
(managed_patch,T/inputs/patches/project-agents.patch.json)
(managed_patch,T/inputs/patches/research-plan.patch.json)
(managed_patch,T/inputs/patches/current-status.patch.json)
```

`formula_evaluator_spec` 不在 contract migration 的 base input 中，因为该文件由迁移事务创建；其 create payload 必须把 target 固定为 `审计/合同注册表/formula-evaluator-v1.json`。迁移 postimage gate 要求它存在并已通过 strict JSON validation。

`chip_work_package` 在共享集合上增加下列 pair，并额外要求 `(formula_evaluator_spec,审计/合同注册表/formula-evaluator-v1.json)`。coverage 文件只能位于当前 transaction 的 coverage 子目录，不接受 staging 中的同名文件。

```text
(formula_evaluator_spec,审计/合同注册表/formula-evaluator-v1.json)
(coverage_manifest,T/coverage/coverage-manifest.json)
(coverage_approval,T/coverage/independent-approval.json)
(coverage_targets,T/coverage/coverage-targets.csv)
(factor_target_candidates,T/coverage/factor-target-candidates.csv)
(reachable_target_bindings,T/coverage/reachable-target-bindings.csv)
(coverage_fields,T/coverage/coverage-fields.csv)
(coverage_exclusion_reviews,T/coverage/coverage-exclusion-review.csv)
```

file input 的 raw hash 始终必填。canonical domain 与 canonical hash 必须同时空或同时非空；policy、approval、registry、controlled CSV、strict JSON 和 fixture 输入必须填写本合同对应 domain 与 canonical hash，Markdown 文档和普通源代码固定两列为空。raw-only 不代表文件可以省略，只表示该输入没有独立 canonical contract。

## table image、payload 和 managed state

### transaction-table-images.csv v2

v4 用下列 15 列替代 v3 的 12 列定义。该辅助表不属于 376 个正式 schema column。

```text
table_image_id,transaction_id,table_path,primary_key_columns_canonical_json,preimage_state,preimage_raw_file_sha256,preimage_canonical_set_sha256,postimage_state,expected_postimage_raw_file_sha256,expected_postimage_canonical_set_sha256,row_count_before,row_count_after,rollback_action,rollback_preimage_path,rollback_preimage_raw_sha256
```

`preimage_state/postimage_state` 只允许 `present,absent`。`rollback_action` 只允许 `restore,delete_created`。正式 table 或 registry 在 transaction postimage 中不得 absent，因此只允许两种状态矩阵：

`table_image_id,transaction_id` 为 `id!`；两个 path和 PK JSON为 `text!`；state/action为 `enum!`；六个 hash与两个 row count按下表 conditional nullable。logical PK是 table_image_id，transaction内 table_path唯一。table image CSV自身的 canonical set使用完整 row envelope与 `rowset-v1`；其中声明的 raw file hash均为直接 SHA-256，声明的 table canonical set hash均为该 target完整 `research-csv-row-v1` envelope array在 `rowset-v1` 下的 framed hash。

| transition | preimage raw/canonical | postimage raw/canonical | row_count_before | row_count_after | rollback_action | rollback path/raw |
|---|---|---|---|---|---|---|
| `present→present` | 两者必填 | 两者必填 | uint 必填 | uint 必填 | `restore` | 两者必填，保存 preimage 原字节 |
| `absent→present` | 两者为空 | 两者必填 | 空 | uint 必填 | `delete_created` | 两者为空 |

state 为 absent 时，两个 hash 和对应 row count 都必须为空。present table 的 raw hash绑定含 header 的完整文件原字节，canonical set hash 绑定完整 data row envelope array；只有 header 的新空表 canonical payload 是 `[]`，仍有非空 canonical hash。`primary_key_columns_canonical_json` 始终必填，并按 schema 顺序列出全部 PK column，即使 preimage absent 也不为空。

合同迁移必须为 `数据/factor-requirements.csv` 和 `数据/factor-target-bindings.csv` 各生成恰一条 `absent→present,delete_created` table image。preflight 如果发现任一 preimage 已存在，事务立即失败，不能把现有文件冒充 absent。rollback 只有在当前 raw 和 canonical hash 都等于该 table image 的 expected postimage 时才删除新表；任一 hash 漂移都保留现场并失败。

### transaction-payload-inventory.csv v2

非 table target 使用以下 20 列：

```text
payload_id,transaction_id,payload_operation_kind,payload_kind,source_path,target_path,target_canonical_domain_tag,input_payload_domain_tag,preimage_state,preimage_raw_sha256,preimage_canonical_sha256,input_raw_sha256,input_canonical_sha256,postimage_state,expected_postimage_raw_sha256,expected_postimage_canonical_sha256,rollback_action,rollback_payload_path,rollback_payload_raw_sha256,notes
```

`payload_operation_kind` 只允许 `create,update,delete`；`payload_kind` 只允许 `raw_only,canonical_json,controlled_csv`；state 只允许 `present,absent`；rollback action 只允许 `restore,delete_created`。每个 target path 恰一行。三种操作固定为：

`payload_id,transaction_id`为 `id!`；kind/state/action为 `enum!`；source/target path为 `text!`；notes为 `text?`；domain、hash和 rollback path按状态矩阵 conditional nullable。logical PK是 payload_id。payload inventory自身使用 row envelope与 `rowset-v1`；target canonical hash使用 `target_canonical_domain_tag`声明的 domain，input canonical hash使用 `input_payload_domain_tag`声明的 domain。

| operation | transition | rollback | source/input |
|---|---|---|---|
| `create` | absent→present | `delete_created`，rollback path/hash 空 | source 是完整 postimage bytes |
| `update` | present→present | `restore`，rollback path/hash 必填 | source 是完整 postimage bytes |
| `delete` | present→absent | `restore`，rollback path/hash 必填 | source 是 strict delete intent JSON |

delete intent 的 exact keys 为 `payload_contract_version,target_path,operation_kind`，version 固定 `PAYLOAD-DELETE-INTENT-V1`，operation kind 固定 `delete`，domain 固定 `payload-delete-intent-v1`。create/update 的 input raw hash必须等于 source file raw hash；delete 的 input raw/canonical hash绑定 intent。create/update 的 source 不能指向 target 自身。

`raw_only` target 的 `target_canonical_domain_tag`、preimage canonical hash 和 postimage canonical hash固定为空。`canonical_json` 与 `controlled_csv` target 的 domain 非空且必须来自相应 artifact 合同；state present 时 canonical hash必填，state absent 时为空。`input_payload_domain_tag` 与 `input_canonical_sha256` 同空同非空。create/update canonical target 的 input canonical hash必须等于 expected postimage canonical hash；raw-only create/update 的这两列固定为空。Markdown、PowerShell、Python 和普通说明文件使用 `raw_only`，不能把 raw SHA-256复制到 canonical 列。

### rollback-file-inventory.csv v2

rollback inventory 改为以下 14 列：

```text
rollback_file_id,transaction_id,target_path,target_kind,target_canonical_domain_tag,preimage_state,preimage_raw_sha256,preimage_canonical_sha256,transaction_postimage_state,transaction_postimage_raw_sha256,transaction_postimage_canonical_sha256,rollback_action,rollback_payload_path,rollback_payload_raw_sha256
```

`target_kind` 只允许 `table_or_registry,raw_payload,canonical_payload`。table image path 必须投影为 `table_or_registry`；payload kind raw_only 投影为 `raw_payload`；其余 payload 投影为 `canonical_payload`。raw payload 的 canonical domain/hash 固定为空；table 或 canonical payload 在 state present 时 domain 和 canonical hash必填；任何 target 在 state absent 时 raw/canonical hash均为空。

table image 的 table path 集与 payload inventory 的 target path 集必须显式 disjoint。二者并集必须与 rollback inventory target path 集 set-equal，每个 path 恰一行。重复 path、两个上游声明不同 postimage、target kind 不一致或 hash 冲突，都在生成 rollback manifest 前返回 `E_MANAGED_TARGET_OVERLAP`。

### managed-state-rowset-v2

journal observed state、rollback manifest 的 base preimage 和 transaction postimage 都改用 exact-key item array：

```text
target_path(string),target_kind(string),state(string),raw_sha256(string|null),canonical_sha256(string|null)
```

item 按 `target_path` UTF-8 bytes 排序，path 唯一，domain 固定 `managed-state-rowset-v2`。nullable matrix 为：

| target_kind / state | raw_sha256 | canonical_sha256 |
|---|---|---|
| 任意 / absent | null | null |
| table_or_registry / present | string | string |
| raw_payload / present | string | null |
| canonical_payload / present | string | string |

canonical hash 的 domain 从 table schema或 payload inventory 的 `target_canonical_domain_tag` 唯一取得。observed state 不允许实现者自行选择 null、raw hash 或解析器 hash。target path 集必须先通过 disjoint-union 门，再构造 managed-state。最小 positive oracle 如下：

```text
payload=[{"target_path":"x.md","target_kind":"raw_payload","state":"present","raw_sha256":"0000000000000000000000000000000000000000000000000000000000000000","canonical_sha256":null}]
expected_canonical_hex=6d616e616765642d73746174652d726f777365742d76320000000000000000ae5b7b227461726765745f70617468223a22782e6d64222c227461726765745f6b696e64223a227261775f7061796c6f6164222c227374617465223a2270726573656e74222c227261775f736861323536223a2230303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030222c2263616e6f6e6963616c5f736861323536223a6e756c6c7d5d
expected_sha256=21511e5bb126fb4cd5f3e7abdd98eb63aeb21e47d8a661de79cf36b07333d497
```

两张 factor table 还必须各有一条完整 golden transaction fixture：`FIX-TX-CREATE-FACTOR-REQUIREMENTS` 与 `FIX-TX-CREATE-FACTOR-TARGET-BINDINGS`。每条 fixture 都提供 table image、rollback row、preimage managed state、postimage managed state、apply journal 和 rollback journal 的 expected canonical hex/hash，并由三个运行时验证。negative 变体至少覆盖伪造空文件 preimage、absent 却填 hash、delete_created 却填 rollback path、created table 漂移后仍删除。

## coverage 与 factor 的 exactly-one 语义

### logical key 和 package ownership

`数据/factor-requirements.csv` 除 `factor_requirement_id` PK 外，新增全表 logical unique key `(card_object_id,policy_id,factor_id)`。validator 从 policy 独立得到 expected obligation triple 后，要求每个 triple 恰好映射一条 factor requirement；两个不同 requirement ID 指向同一 triple 立即返回 `E_LOGICAL_KEY_DUPLICATE`。

`factor-target-candidates.csv` 的 logical key 固定为 `(factor_requirement_id,target_kind,target_id)`，每键恰一行。把 requirement join 回 obligation 后，投影 key `(card_object_id,policy_id,factor_id,target_kind,target_id)` 也必须每键恰一行，并与 synthetic expected factor pair set-equal。不同 candidate ID、相同 logical key 的 include/exclude 双行不能通过。

`factor-target-bindings.csv` 继续要求 `(factor_requirement_id,target_kind,target_id)` 唯一，其投影 key与 include factor candidate 投影 key set-equal且 exactly one。field coverage candidate、reachable binding 和 exclusion review 保留 v3 的 exactly-one 门。`coverage-fields.csv` 以 `(work_package_id,field_id)` 唯一，并与 141 个 field set-equal。

五张工作包 CSV 的每一行都必须满足 `row.work_package_id == coverage_manifest.work_package_id`：

```text
coverage-targets.csv
factor-target-candidates.csv
reachable-target-bindings.csv
coverage-fields.csv
coverage-exclusion-review.csv
```

coverage target、factor candidate、reachable binding 与 exclusion review 的全部跨文件 ID 引用必须在同一 work package 内解析。引用全局同名 ID、foreign package ID，或 manifest 为 `WP-A` 而 cell 为 `WP-B`，都返回 `E_PACKAGE_OWNERSHIP`。文件位于 coverage 子目录不构成 ownership 证明。

### 普通 field 的 selector 状态机

coverage policy 的固定路径改为 `审计/合同注册表/coverage-policy-v4.0.json`，approval 固定为 `审计/合同注册表/coverage-policy-v4.0-approval.json`，contract version 固定 `COVERAGE-POLICY-V4`。顶层 key与 v3 相同；本稿新增的 selector、source match mode和 mandatory structural N/A 都是既有 nested object 的受控扩展。旧 v3 policy不能作为 v4 transaction input，也不能只改文件名沿用旧 canonical hash。

普通 field 指 GA100 108 mandatory key 以外的 expected field-target pair。field rule 的 key 顺序改为 `field_id,card_selector_predicate_id,mandatory_target_selector_predicate_ids,exclude_selector_rules,allow_structural_na,structural_na_predicate_id,allowed_exclude_reason_codes,review_status,notes`。新增 array按 `exclude_rule_id` canonical bytes排序，每项 exact keys为 `exclude_rule_id,reason_code,predicate_id`。reason code必须属于该 field的 allowed exclude code，predicate scope必须为 target。`mandatory_target_selector_predicate_ids`中的 predicate也必须是 target scope，数组非空并去重。

对每个普通 pair 按下列顺序执行，任何一步都不读取作者的 decision：

1. 先计算 card selector。false 时必须且只能有一条 reason 为 `explicit_card_scope_exclusion` 的 exclude rule 命中；candidate 写 `exclude`，requirement ID 为空。
2. card selector 为 true 时，计算全部 mandatory target selector。恰一条命中则 candidate 必须 `include`。target kind为 `object`且 target ID等于 manifest card object时 reason固定为 `card_scope_requirement`；其他 normal include reason固定 `selector_match`。
3. mandatory selector 命中数为零时，必须且只能有一条 exclude selector 命中；candidate 写该 rule 的 reason code并保持 requirement ID 为空。
4. mandatory selector或 exclude selector 命中数大于一、两类同时命中、两类都不命中，都返回 `E_SELECTOR_CARDINALITY`。policy review 阶段用全部 reachable fixture 检查互斥性，package 阶段再按真实 inventory 复算。
5. 每条 include candidate 必须精确引用一条 same-field、same-seven-target requirement。该 requirement 必须属于当前允许的 canonical reusable legacy row 或 ActiveSuccessor，或是不与 legacy/current key 冲突的新 current row。第二条同键可发布 requirement、空引用、错 target、错 field 或引用 inactive successor 均失败。

GA100 mandatory 108 在这套 normal 状态机之前强制 `include,mandatory_include`，再执行同样的 exact-one requirement、endpoint closure 和 lifecycle 门。mandatory N/A 只走前述六键专用规则；normal structural N/A 则需 field rule 允许、structural predicate 唯一命中并有非空理由，两条路径不能互相代用。

### factor minimum source 的 all/any

factor rule 的 key 顺序改为 `factor_id,factor_label,card_selector_predicate_id,allowed_target_kinds,target_subtype_predicate_id,min_targets_if_available,allow_not_applicable,structural_na_predicate_id,minimum_source_types,minimum_source_types_match_mode,minimum_source_authorities,minimum_source_authorities_match_mode,identity_field_ids,explains_field_ids,review_status,notes`。两个 mode只允许 `none,all,any`。array为空时 mode必须 `none`；array非空时 mode必须为 `all`或`any`。

validator 先构造 `QualifyingSourceFamilies(factor)`：来源必须进入当前 selection run，具有 closed factor assertion/result/evidence、actual endpoint、有效 locator、通过 cutoff/date policy，并按 `source_family_id` 去重。同一 source 的多个 endpoint、镜像 source version 和同 family 的重复来源只算一个 family。

对 source type 维度，`all` 表示 array 中每个 token 至少由一个 qualifying family 的实际 source_type 命中；`any` 表示至少一个 token被命中。authority 维度同理，使用 source family 的正式 authority。两个维度各自计算后做逻辑 AND；不要求同一 family 同时满足 type 和 authority，也不构造隐含笛卡尔积。若确需同源 pair，必须在后续 policy 版本新增显式 pair contract，v4 不接受备注文本表达。array 中重复 token、空 token 或 policy enum 外 token失败。

`not_found`、`not_public`、`inaccessible_evidence` 和 `value_available` 都按相同 qualifying family 算法执行最低来源门。`minimum_*_mode=none` 才表示该维度没有最低要求，空数组不能被解释成 all 的真空真。

## latency condition 的可执行 mapping

### instruction latency

`FIELD-COMP-INSTRUCTION-LATENCY` 的 condition-set.notes 改用以下 exact-key JSON，key 顺序固定：

```text
condition_contract_version
instruction_or_opcode
operation_type_enum
dependency_pattern
instruction_mapping
toolchain_or_disassembler
software_version_text
operation_count_rule_enum
operation_count_rule_source_text
clock_domain
clock_frequency_known
source_condition_text
```

version 固定 `INSTRUCTION-LATENCY-CONDITION-V1`。`instruction_or_opcode,dependency_pattern,instruction_mapping,toolchain_or_disassembler,clock_domain` 是非空 string，未知值写字面 `unknown`。`operation_type_enum,software_version_text,operation_count_rule_enum,operation_count_rule_source_text,source_condition_text` 是 string|null。clock known 是 bool。

condition-sets.csv 的列映射固定为：

| column | JSON key | nullable 与 equality |
|---|---|---|
| `operation_type` | `operation_type_enum` | JSON null 对应空 cell；非 null 必须来自 operation_type enum，cell 逐字相等 |
| `operation_count_rule` | `operation_count_rule_enum` | JSON null 对应空 cell；非 null 必须来自 operation_count_rule enum，cell 逐字相等 |
| `software_version` | `software_version_text` | JSON null 对应空 cell；非 null 时逐字相等 |
| `frequency_value/frequency_unit` | `clock_frequency_known` | false 时两列都空；true 时两列都非空并通过正式 number/unit 门 |

instruction latency 的 `measurement_scope` 与 workload、batch、sequence、context、traffic、statistic 等列固定为空，除非后续 condition contract 明确增加对应 key。`dependency_pattern` 只描述 dependency chain，绝不映射成 operation count rule。

`operation_count_rule_enum` 的默认值是 JSON null和 CSV 空 cell。只有 actual source 在当前 locator 明示 operation accounting convention 时才能填写；此时 `operation_count_rule_source_text` 必须为非空原文片段，并由独立 reviewer 核对。没有说明时不能强填 `not_specified`、`vendor_label`、`fma_2_ops` 或 `mac_2_ops`。`not_specified` 也只有来源明确把该 convention 标为 unspecified 时才可用。source text 非空而 enum 空，或 enum 非空而 source text 为空，都返回 `E_CONDITION_MAPPING`。

### memory latency

`FIELD-MEM-LATENCY` 的 condition-set.notes 使用以下 exact-key JSON：

```text
condition_contract_version
memory_level_or_path
access_operation
operation_type_enum
dependency_pattern
operation_count_rule_enum
operation_count_rule_source_text
working_set_or_measurement_scope
measurement_scope_enum
clock_domain
clock_frequency_known
software_or_product_condition
software_version_text
source_condition_text
```

version 固定 `MEMORY-LATENCY-CONDITION-V1`。memory/path、access、dependency、working-set/scope、clock domain、software/product condition 是非空 string，未知值写 `unknown`。三个 `*_enum`、software version、operation-count source text与 source condition text是 string|null。column mapping 为：

| column | JSON key | nullable 与 equality |
|---|---|---|
| `operation_type` | `operation_type_enum` | null 对应空 cell；非 null 为正式 enum 且逐字相等 |
| `operation_count_rule` | `operation_count_rule_enum` | null 对应空 cell；非 null 为正式 enum 且逐字相等 |
| `measurement_scope` | `measurement_scope_enum` | null 对应空 cell；非 null 为正式 enum 且逐字相等 |
| `software_version` | `software_version_text` | null 对应空 cell；非 null 逐字相等 |
| `frequency_value/frequency_unit` | `clock_frequency_known` | false 时均空；true 时均非空 |

memory latency 的 operation count 同样只在来源明示时填写，并要求非空 `operation_count_rule_source_text` 与 actual locator。`working_set_or_measurement_scope` 是保留原始实验条件的描述，不能据此猜测 measurement_scope enum；`software_or_product_condition` 也不能自动复制到 software_version。normalized unit 为 `cycle` 时 clock_domain 仍必填明确值或 `unknown`，clock known 可以为 false。clock unknown 时保留 cycle，禁止从相邻 A100 产品频率、boost clock 或不同 clock domain 补值。

两个 condition contract 的 positive/negative fixture 必须覆盖 operation count 空值、来源明示四种 enum、dependency pattern 被误填为 `not_specified`、software/product condition 被误当 software version、clock known true/false 和 memory cycle 无频率。三运行时只验证结构和 mapping；“来源是否确实明示”的判断由独立 reviewer 对 actual endpoint 与 locator 签字，不能由字符串猜测器代替。

## actual endpoint、locator、source family 和 cutoff

v4 继续要求所有新 closure assertion、search result 和 requirement evidence 使用 actual endpoint。`endpoint.source_id` 必须逐字等于行内 source ID；preferred endpoint、同源其他 endpoint 和浏览器当前 URL 都不能替代。live mutable endpoint 不能进入发布 closure，必须绑定同 source 的 fixed version 或 snapshot endpoint。

新 closure 的 `source_locator` 与 `checked_locator_or_scope` 统一写 exact-key canonical JSON text，contract version 固定 `SOURCE-LOCATOR-V1`，key 顺序为：

```text
locator_contract_version
locator_kind
page_start
page_end
locator_text
```

`locator_kind` 只允许 `pdf_page,html_fragment,section,table,api_field,whole_document`。pdf_page 要求 page_start/page_end 为正 uint、start 不大于 end、locator_text 可 null；若 endpoint 连接已登记本地 PDF，end 不得超过登记页数。其他 kind 的两个 page key 都为 null且 locator_text 非空。whole_document 只允许登记页数为1的 PDF，或 strict text extraction不超过4,096个 Unicode scalar的固定文本、JSON、HTML endpoint；locator_text必须等于登记标题。超过机械上限就必须改用页码、section或fragment。locator JSON 缺 key、用空 string 代 null、页码倒置、endpoint 类型与 locator kind 不相容均失败。

source-date rule 继续以 `(source_type,actual endpoint_type)` 唯一命中。有效日期只读取 actual source version 的 publication date和 actual endpoint 的 snapshot/access date。assertion/result/evidence 的 actual endpoint date、search date、card identity cutoff 和 selection-run cutoff 必须满足 v3 的不晚于 cutoff 与相等关系。

所有来源数量、minimum type/authority 和 reverse-removal 独立性均以 `source_family_id` 去重。同一 family 的不同版本、镜像、HTML/PDF endpoint 或 publisher repost 不增加 independent count。NVIDIA 作者的论文与 NVIDIA 官方文档可以是不同 source family，但若 policy 要求外部独立 authority，二者都不能冒充该 authority。独立门完全由 approved authority enum 与 factor match mode判定，不从 URL host 或 source title猜测。

closure 必须收入每条 actual endpoint、对应 source version、source family、canonical locator、date-policy row 和 selection member。任何 accepted fact 缺 endpoint/locator，任何 factor search 只登记 family 未登记实际 source/endpoint，或 reverse-removal 移除来源后仍沿用其 locator，都失败。

## migration transaction、恢复和幂等

### operation、file image 与 payload 的闭合关系

operations.csv 的 13 列和 row-level insert/update/delete 语义沿用 v3。每条 operation 都要有独立 input payload，不能从 staging 隐式取 postimage。三种 operation 的状态固定为 absent→present、present→present、present→absent；present 一侧的 canonical row hash必填，absent 一侧为空。update/delete 的 rollback payload保存 preimage row envelope，insert 的 rollback payload为空。

每张受 row operation 影响的 table 必须有恰一张 table image。validator 先将全部 operation 按 `(table_path,pk_canonical_json)` exactly one 应用到 table preimage，再 strict write 整个 table，重算 row count、raw hash与 canonical set hash，并与 table image postimage逐字相等。table image 声明的行数差必须等于该表 insert 数减 delete 数；update 不改变行数。operation、table image、rollback inventory 任一方缺 path 都失败。

非 table update/create/delete 全部走 payload inventory v2。每项都有 source input、preimage、postimage和 rollback action。managed patch 只证明变更内容，不能替代 payload row。transaction-file-inputs、operations、table images、payload inventory 和 rollback inventory 都先完成 raw/canonical 自校验，再允许生成 rollback manifest。

contract migration 的 formal/data action universe 必须与 v3精确迁移项加上下列 v4修订 set-equal。额外语义变更、额外 target或漏项都失败：

1. 精确修改 schema 到 34 表、376 列；创建两张 factor table 的 absent→present image。
2. 删除 `FIELD-ID-DATA-CUTOFF`，插入 `FIELD-COMP-INSTRUCTION-LATENCY`，修改 `FIELD-MEM-LATENCY` 单位合同；postimage 仍为 141 个 field。
3. 删除 `product_status.historical_anchor`，增加五个 lifecycle、`coverage_obligation_evidence`、`rounding_mode=rtn/rtp`；postimage 为 77 个 group、564 行。
4. 扩列 v3 指定的 objects、card-completeness、search-log、search-results、requirement-evidence 和 fact-assertions。
5. 对当前 832 条 assertion 每条执行一项 present→present update。input/postimage 含 `endpoint_id` 空 cell，AFPV2 payload中的 endpoint 为 JSON null；row-level operation count与 832 行 set-equal。
6. 写入 45 条 identity lifecycle、9 条已批准 scope，保持 585 条 completeness；GH100 pending mapping 不补造 completeness。
7. 创建 formula evaluator spec，并更新四个 validator/恢复脚本、模板、字段字典、README、AGENTS、研究计划和当前状态。11个 non-table target与 managed patch集合逐项对应。已批准 policy、fixture、scope和 immutable legacy registry只作 file input，禁止出现在 managed target中。

删除旧 field/enum row、插入新 field/enum row、扩列 update、832 assertion update和 document payload都必须出现在 transaction preimage/input/postimage 中。只在设计说明列出、未进入 operation 或 payload inventory 的变更视为遗漏。

### apply 状态机

执行顺序固定为 `strict parse → role/path universe → raw/canonical recompute → isolated mirror → all gates → journal applying → deterministic replace → postimage gate → journal applied`。target replace 按 target path UTF-8 bytes 升序；每次写入使用同文件系统 temp、flush/fsync 和 atomic rename。创建文件也先写 temp再 rename。

fresh apply 只允许 observed managed-state 等于完整 base preimage，且 journal 没有冲突 manifest。已等于完整 postimage并存在同 manifest `applied+succeeded` 时返回 `SUCCESS_NOOP`，不重写文件。pre/post 混合状态只有在最新 journal 是同 manifest `applying+started` 时允许 roll-forward；每个 target 必须恰好等于自身 preimage 或 postimage。执行器复核尚未写入的 input bytes，把 preimage target推进到 postimage，已经到 postimage的 target保持不动。未知 hash、state 与文件存在性不符、target path缺失、manifest hash不同或没有 applying event的 mixed state全部失败并保留现场。

row delete、payload delete 和 created table 的 absent postimage按 state比较，不能用空文件代替 absent。roll-forward 完成后必须重新运行 34/376/141/77/564、832 AFPV2、scope、legacy、coverage、fixture、recovery与三道 Windows gate，才追加 `applied+succeeded`。

### rollback 状态机

rollback 只从完整 applied postimage开始，先追加同 manifest `rollback_applying+started`。`restore` target从受控 rollback payload恢复原字节；`delete_created` target只有在当前 raw/canonical state仍等于 expected transaction postimage时删除。两张新 factor table遵守同一 delete-created门。删除后 observed state必须为 absent，不能留下 header-only文件。

rollback 中断只在最新 event为同 manifest `rollback_applying+started` 且每个 target恰为 transaction postimage或 base preimage时续跑。恢复完成后重算完整 base managed state并追加 `rolled_back+succeeded`。已经处于完整 base state且存在同 manifest rolled-back成功事件时返回 `ROLLBACK_NOOP`。apply mixed state不能直接rollback，必须先确定性 roll-forward；任何后来修改或不同 manifest写入造成的未知 state都拒绝覆盖。

transaction journal 的每个 observed state 使用 `managed-state-rowset-v2`，event hash链、event seq和允许的 event/status pair沿用 v3。journal schema hash使用本稿唯一 schema object。控制面不进入自身 managed target；coverage manifest/approval、rollback manifest、transaction manifest和transaction approval仍按 v3单向批准顺序生成，不形成 hash cycle。

### 事务 validator 伪代码

```text
ValidateTransactionV4(root, tx_dir):
    tx = LoadExactTransactionManifestV1(tx_dir)
    Require(tx.transaction_kind in {contract_migration, chip_work_package})
    ValidateSafePathOnEveryDeclaredPathColumn(tx_dir)
    expected_inputs = BuildRolePathUniverse(tx.transaction_kind, tx.transaction_id)
    actual_inputs = LoadStrictFileInputs(tx_dir)
    Require(EachLogicalKeyExactlyOnce(actual_inputs))
    Require(ProjectRolePath(actual_inputs) == expected_inputs)
    Require(All(actual_inputs.is_required == true))

    operations = LoadStrictOperations(tx_dir)
    images = LoadStrictTableImagesV2(tx_dir)
    payloads = LoadStrictPayloadInventoryV2(tx_dir)
    rollback_rows = LoadStrictRollbackInventoryV2(tx_dir)
    Require(Set(images.table_path) disjoint Set(payloads.target_path))
    Require(Set(rollback_rows.target_path) ==
            Set(images.table_path) union Set(payloads.target_path))
    ValidateStateNullabilityDomainsAndActions(images, payloads, rollback_rows)
    ValidateEveryOperationHasOneImageAndExactPreInputPostimage(operations, images)
    ValidateEveryPayloadHasExactPreInputPostimage(payloads)
    if tx.transaction_kind == contract_migration:
        Require(Set(payloads.target_path) == BuildElevenMigrationPayloadTargetsV4())
        Require(ProjectOperationKeys(operations) == BuildContractMigrationOperationSetV4(base))
    Require(ExactlyOneAbsentToPresentDeleteCreatedImage(images,
            "数据/factor-requirements.csv"))
    Require(ExactlyOneAbsentToPresentDeleteCreatedImage(images,
            "数据/factor-target-bindings.csv"))

    Require(HashCanonicalSchema(TransactionJournalSchemaV1) ==
            tx.journal_schema_canonical_sha256)
    RecomputeAndRequireEveryTransactionManifestHash(tx)
    preimage = BuildManagedStateV2(images.preimage, payloads.preimage)
    postimage = BuildManagedStateV2(images.postimage, payloads.postimage)
    Require(Hash(preimage) == rollback.expected_base_preimage_canonical_set_sha256)
    Require(Hash(postimage) == rollback.expected_transaction_postimage_canonical_set_sha256)
    ValidateApprovalDirectionAndNoHashCycle(tx)
```

```text
ResumeOrApplyV4(root, tx):
    observed = ObserveManagedStateV2(root, tx.targets)
    if observed == tx.postimage and JournalHasAppliedSameManifest(tx):
        return SUCCESS_NOOP
    if JournalLatestIsApplyingSameManifest(tx):
        Require(EachTargetIsOwnPreimageOrPostimage(observed, tx))
        RollForwardRemainingTargetsInPathOrder(tx)
        RunCompletePostimageGates()
        AppendJournal(applied, succeeded)
        return SUCCESS_RESUMED
    Require(observed == tx.preimage and JournalAllowsFreshApply(tx))
    mirror = BuildAndVerifyIsolatedPostimage(tx)
    AppendJournal(applying, started)
    ReplaceTargetsInPathOrder(mirror)
    RunCompletePostimageGates()
    AppendJournal(applied, succeeded)
    return SUCCESS_APPLIED
```

## coverage validator 的新增硬门

下列代码补入 v3 `ValidateCoveragePackage`，调用顺序在作者 decision/status 派生之前：

```text
Require(manifest.field_count == 141)
Require(Count(schema_columns) == 376)
Require(Count(fields) == 141)
Require(Count(enum_groups) == 77)
Require(Count(enums) == 564)
ValidateRoundingEnumRowsAndPtxMapping()

Require(AllWorkPackageRowsOwnedByManifest(package, manifest.work_package_id))
Require(EachFieldCandidateLogicalKeyExactlyOnce())
Require(EachReachableBindingLogicalKeyExactlyOnce())
Require(EachFactorObligationTripleExactlyOnce())
Require(EachFactorCandidateLogicalKeyAndProjectedPairExactlyOnce())
Require(EachFactorBindingLogicalKeyAndProjectedPairExactlyOnce())

expected_field_pairs = BuildExpectedFieldTargetPairs(fields, inventory)
expected_factor_obligations = BuildExpectedFactorObligations(card, policy)
expected_factor_pairs = BuildExpectedFactorTargetPairs(card, policy, inventory)
Require(Project(field_candidates) == expected_field_pairs)
Require(Project(factor_requirements) == expected_factor_obligations)
Require(Project(factor_candidates) == expected_factor_pairs)

ValidateNormalFieldSelectorStateMachine()
ValidateMandatory108AlwaysIncludeAndExactlyOneRequirement()
ValidateMandatoryStructuralNaOnlyForSixPolicyKeysWithProof()
ValidatePtxFp64RoundingAdvertisedModeClosure()
ValidateFactorMinimumSourceModesOverUniqueFamilies()
ValidateActualEndpointLocatorFamilyAndCutoffClosure()
ValidateInstructionAndMemoryConditionColumnMapping()
RecomputeAndRequireAllCoverageManifestHashes()
```

N/A requirement在 `ValidateMandatory108AlwaysInclude` 中仍算 include与已裁决 obligation；只有六键专用 proof gate通过才算 closed。validator 不得为了满足 108 把 N/A 改写成 `value_available`，也不得为了保留 mandatory include把它误记成 `not_found`。

## fixture 上线门

`canonical-fixtures.csv` 与 `canonical-runtime-results.csv` 的列继续使用 v3 定义，input_kind 和 error code改用本稿封闭 enum。每个 positive fixture 的 expected canonical hex/hash必填，error code为空；每个 negative fixture只填 expected error code。每个 fixture恰有 `powershell_5_1,powershell_7,python_3` 三行 runtime result，positive 的 observed hex/hash逐字相等，negative 的 error code逐字相等。

除 v3 已列的 UTF-8、JSON、CSV、Markdown、date、AFPV2、reconciliation、latency和 domain fixture 外，v4 至少增加以下 fixture family：

| fixture family | 必备 positive | 必备 negative |
|---|---|---|
| synthetic/schema | 前述 7 个 golden oracle | item key乱序、nullable错误、sort错误、重复 logical key、错误 domain、缺 hex |
| enum | `rtn` ordinal 6、`rtp` ordinal 7、总计564 | `.rm→rtp`、`.rp→rtn`、只保留 `.rn`却关闭完整 FP64 mode set、仍期望562 |
| file input | 两种 transaction kind 的 exact required set | omitted validator、omitted template patch、extra role、未知 enum、role/path互换、is_required=false |
| safe path | 合法中文项目相对路径 | absolute、drive、UNC、`.`、`..`、空 segment、反斜杠、symlink越界、case alias collision |
| table image | 两张 factor table各自 absent→present→rollback delete | absent填假空文件hash、created table rollback未删、漂移后强删、state/hash nullable错误 |
| managed state | raw payload canonical null、canonical payload non-null | table/payload同 path、raw payload填 canonical、canonical payload写 null、并集与rollback不等 |
| coverage key | factor obligation、candidate、binding各键唯一 | 同 obligation 双 ID、同 candidate key include/exclude双行、foreign work package、同 field pair双 requirement |
| selector | normal pair恰一 include selector或恰一 exclude selector | selector零命中、双命中、include缺 requirement、exclude带 requirement |
| mandatory N/A | 六个允许 key include+not_applicable+proof | mandatory exclude、无 proof N/A、floating path N/A、把N/A enum写成 value、integer N/A误写not_found |
| condition | operation count空值、来源明示后逐字映射 | dependency映射 count、默认强填not_specified、software/product误映射、clock false却填频率 |
| source minimum | all/any/none在独立 family上各一例 | 同 family多 endpoint冒充多个、空 array+all、漏 actual endpoint、locator页码越界 |
| migration | update/create/delete各自 pre/input/post、apply no-op、rollback no-op | 无 applying 的 mixed state、不同 manifest mixed、unknown hash、delete-created target漂移 |

fixture manifest 只有在全部 mandatory fixture存在、三个运行时结果齐全、runtime implementation作者互相独立且 review_status=approved 时才能 approved。contract migration 和 chip transaction 都把 fixture manifest、fixtures和 runtime results作为 required file inputs；只运行 Python 或只运行当前平台可用 runtime不能替代上线门。

## 实现顺序与文档迁移

第一步冻结当前 32 表、活动名单、三个 validator、恢复脚本、模板、字段字典和项目文档的 raw/canonical preimage。随后独立生成并批准 1,059 行 legacy disposition、scope allocation/mapping、coverage policy、source-date policy、formula evaluator spec 与 fixture expected。policy 需要纳入 v4 的 exclude selector、factor minimum match mode、mandatory structural N/A六键、rounding mode condition和两项 latency condition mapping。

第二步由三个运行时分别实现 strict canonical contract。先执行前述 golden serialization oracle，再执行所有 positive/negative semantic fixture。任一 runtime缺失或结果不同，合同事务停在 preflight。

第三步构造 contract migration transaction。全部正式 row变化进入 operations，全部正式 table/registry进入 table images，全部非 table变化进入 payload inventory。两张 factor table使用 absent→present；832 assertion逐行 update；enum postimage使用564行。validator、formula evaluator、模板、字段字典、README、AGENTS、研究计划和当前状态都通过 exact managed patch与 payload target关联。旧审计快照、归档冻结文件、v3及R08/R09保持原字节。

第四步在隔离根复算 34/376/141/77/564、78 objects、585 completeness、832 AFPV2、49 active allocation、legacy baseline与空 reconciliation registry，并运行 source pool、scope、recovery和 Windows数据门。完整 postimage通过独立 transaction approval 后才能 apply。这个阶段不写 GA100 facts。

第五步从合同 postimage重新生成 GA100 package。先构造 expected projection与 reachable inventory，再构造 141-field pair、factor obligation和factor pair全集。108 key全 include；六个 integer/logical rounding/subnormal key可以按专用 proof写 N/A，其余 key依真实证据写 value、not_found、not_public或 inaccessible。FP64 PTX rounding要完整记录 default `rne`和选项 `rtz/rtn/rtp`，不能只落默认值。

第六步绑定每条 assertion/result/evidence的 actual endpoint与 canonical locator，按 source family去重执行factor最低来源、closure和reverse removal。derived fact递归收入 input/source；MIG、HPEC和random-access来源只按实际不可替代职责决定 selection role，不预设数量。

第七步先批准 coverage manifest，再生成 rollback manifest、transaction manifest与 approval。apply前运行三运行时 fixture和全部 Windows gate；apply后再次复算，并从正式 fact、field requirement、factor requirement和 source closure生成资料卡。

模板与字段字典迁移继续执行 v3 的 HBM stacks/interface width拆分、card cutoff metadata、field/factor requirement ID、actual endpoint和 `coverage_obligation_evidence`。另补四项显示规则：instruction latency与memory latency保留原始 cycle/s及完整 condition；rounding enum解释加入 `rtn/rtp`与 PTX modifier映射；同一 rounding mandatory cell允许展示多个 condition-distinguished mode；mandatory structural N/A明确展示 reason code和 evidence ID，不能显示成 value或 not_found。

## R08 与 R09 repair crosswalk

| review item | v4 repair | 拒绝反例与 fixture |
|---|---|---|
| R08 blocker 1：virtual/schema hash无唯一 bytes | 冻结三个 schema envelope、四类 synthetic set的 domain、key顺序、nullable、排序、payload和 framing；58-key hash账本逐键指定输入；七条显式 recompute Require；提供 hex/hash oracle | 不同 object/array编码、错误 domain、set去重、缺 manifest compare；`synthetic/schema` family |
| R08 blocker 2：input_role/input_kind与 file universe不闭合 | 两个 enum封闭；两种 transaction kind各自 required=allowed role/path set；所有 path列统一 safe-path；缺项和额外项都失败 | omitted validator/template、extra role、unknown enum、absolute/`..`；`file input`与`safe path` family |
| R09 A：新 factor table无法表示 absent preimage | table image v2增加 pre/post state和 rollback action；absent hash/count/path矩阵；两张表各一条 absent→present golden transaction；rollback delete-created并检查漂移 | 假空表 preimage、header冒充 absent、rollback残留或强删；`table image` family |
| R09 B1：factor candidate同键双 ID | candidate logical key及 obligation-projected key均 exactly one，与 expected pair set-equal | include/exclude双行；`coverage key` family |
| R09 B2：factor requirement同 obligation双 ID | `(card_object_id,policy_id,factor_id)` 全表唯一；每个 expected triple精确一行；expected pair不含任意 requirement ID | 双 requirement ID与传播的双 target set；`coverage key` family |
| R09 B3：work_package ownership未闭合 | 五张工作包CSV逐行等于 manifest ID，所有跨文件引用只在同 package解析 | manifest `WP-A`、row `WP-B`；`coverage key` family |
| R09 C：managed non-table canonical与 target并集不唯一 | payload kind/domain/null矩阵；managed-state v2加入 target kind；raw-only canonical固定null；table/payload path显式 disjoint；并集与rollback set-equal | 同 path双声明、raw hash冒充 canonical、canonical payload写null；`managed state` family |
| R09 D：latency column到JSON mapping不可执行 | 两项 condition JSON改为含 enum/text nullable key的 exact schema；逐列 exact-equal；operation count默认空且仅来源明示时填写 | dependency或scope被猜成 count、默认强填not_specified、软件字段误映射；`condition` family |

## 新增裁决 crosswalk

| 裁决 | 合同变化 | 计数与 hash影响 |
|---|---|---|
| PTX FP64 `.rm/.rp`不得丢失 | 增加 `rounding_mode=rtn/rtp`，固定 `.rn/.rz/.rm/.rp`映射；完整 advertised mode closure | enum group仍77，enum row由562增到564；coverage enums hash、policy hash、fixture hash、transaction postimage全部重算 |
| 108 mandatory不能用 exclude逃逸，也不能把真实N/A写成not_found | candidate仍全 include且每键exact-one requirement；六个明确 integer/logical rounding/subnormal key允许经 structural predicate、reason code和 actual-endpoint proof写 not_applicable | mandatory key set和108计数不变；policy hash、closure hash、fixture与 coverage manifest重算 |
| source synthesis中的正式 field count笔误 | v4只接受正式基线复算的141 field，不把报告笔误写入合同 | field count与fields hash继续按141行全量复算 |

## 验收边界

独立设计验收应先确认本文件只新增设计，没有正式写入，再逐项运行 crosswalk 的反例。设计通过只表示可以进入审计区实现；它不等于 contract migration通过，不等于 GA100卡完成，也不等于 PowerShell 5.1、PowerShell 7、Python 3或 Windows gate已经运行。

本文件已单独通过 `report-humanizer` machine scan，未检出 hard tell。人工从末节向前复读标题、首段、表格引导、hash hex、计数、nullable matrix、状态机和 crosswalk，修正了 input role计数、coverage policy v4路径、active-scope schema path、mandatory N/A首段表述与 normal selector reason。剩余风险属于实现与三运行时验收，不是文案自然度；machine scan不能替代 canonical hex复算、行数核对或独立红队。
