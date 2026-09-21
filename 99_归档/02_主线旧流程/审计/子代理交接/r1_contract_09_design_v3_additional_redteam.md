# R1 冻结合同 v3 补充红队复核

## 裁决

补充反例 A、B、C 均成立；instruction/memory condition 的 mapping 反例也成立。四组问题都会造成无合法表示、遗漏/重复仍可能通过，或不同运行时对同一输入给出不同结论，因此应追加为 v3 的设计 blocker。原 `r1_contract_08_design_v3_independent_review.md` 保持冻结，整体结论仍是 `reject`。

## A：新正式表无法用 table image 表示 absent preimage

`数据/factor-requirements.csv` 和 `数据/factor-target-bindings.csv` 当前均不存在，v3 却要求 contract migration 新建这两张正式表。`transaction-table-images.csv` 对每张受影响正式表要求恰一行，但 `preimage_raw_file_sha256`、`preimage_canonical_set_sha256`、`rollback_preimage_path` 和 `rollback_preimage_raw_sha256` 全部 non-null；该表没有 `preimage_state`，也没有 `rollback_action=delete_created`。这与 operations 中允许 insert 的 `absent→present` 不是同一层合同：row operation 能表示新行，file-level table image 仍不能表示目标文件原先不存在。

反例可以直接复现。若两张新表的 preimage hash/path 留空，strict type 失败；若填空文件、仅 header 文件或任意 synthetic bytes 的 hash，声明的 preimage 就是 present，与磁盘上的 absent target 不等；若 apply 后 rollback，table image 又只允许恢复“原始 bytes”，不能删除原先不存在的文件。第 743 行只明确删除事务创建的 payload，没有把新建正式 table target 纳入删除语义。于是 contract migration 无法同时满足 table-image、managed-state preimage 和 rollback 三组约束。

最小修复是给 table image 增加明确的 preimage/postimage state 与 nullable matrix，并为 preimage absent 固定 `rollback_action=delete_created`、rollback path/hash 为空；rollback 执行规则也要明确删除本事务新建且 hash 未漂移的正式表/registry。两张 factor 表必须各有一条 absent→present 的 golden transaction fixture。

## B：factor 重复键和 work-package 归属没有闭合

### B1 factor-target-candidates 重复可通过

`factor-target-candidates.csv` 只把 `factor_target_candidate_id` 声明为 logical PK。设计虽定义 candidate key 为 `(factor_requirement_id,target_kind,target_id)`，却没有声明该键唯一。伪代码只执行 `KeySet(factor_candidates) == expected_factor_pairs`；与 field candidate 路径不同，它没有 `EachKeyExactlyOnce`。因此可放入两行不同 candidate ID、相同 candidate key 的记录，令一行 include、另一行 exclude，集合投影仍等于 expected set。后续 exclusion、binding 和 status gate面对哪一行生效没有唯一答案。

### B2 factor-requirements 重复 obligation 可通过或产生实现分歧

`factor-requirements.csv` 只以 `factor_requirement_id` 为 PK，没有声明 `(card_object_id,policy_id,factor_id)` 唯一。两条不同 requirement ID、相同 card/policy/factor 且相同 fingerprint 的 row 都符合逐列和 PK 规则。若 `KeySet(factors)` 按独立 builder 能生成的 obligation triple 取键，两行会折叠成同一键并通过；若把 requirement ID 纳入 key，独立 policy builder 又没有冻结 ID 生成规则。后续 `BuildExpectedFactorTargetPairs(factors,...)` 还可能把两个 requirement ID 都扩张为各自完整 target set，使重复 obligation 被一路传播，而不是被拒绝。

### B3 各工作包 CSV 没有强制归属 manifest

五张工作包 CSV 都带 `work_package_id`，但冻结文本和伪代码没有要求每一行逐字等于 `coverage-manifest.json.work_package_id`。文件位于某个 transaction 的 `coverage/` 子目录并不能约束 cell。把 manifest 写成 `WP-A`、所有 CSV 行写成 `WP-B`，再按实际文件重算 raw/canonical hash 和 count，现有显式门没有一项比较这两个 ID。类似地，cross-file 引用虽然有 ID 字段，仍缺少统一的 package ownership gate。

这组三项的最小修复是：明确 factor obligation logical key `(card_object_id,policy_id,factor_id)` 全局唯一；明确 factor candidate logical key `(factor_requirement_id,target_kind,target_id)` 唯一并执行 `EachKeyExactlyOnce`；对 coverage targets、factor candidates、reachable bindings、coverage fields 和 exclusion reviews 全部执行 `row.work_package_id == manifest.work_package_id`，再验证所有跨文件 ID 引用属于同一 package。fixture 要包含同键双 ID、include/exclude 冲突和 foreign work-package ID。

## C：managed-state 的非表 canonical 值与 target 并集不唯一

managed-state row 固定有 `target_path,state,raw_sha256,canonical_sha256` 四个 key，只写明 absent 时两个 hash 为 null。table image 对 present table 同时提供 raw 与 canonical set hash，但 payload inventory 和普通 managed doc 只冻结 raw bytes，没有给 `canonical_sha256` 的 domain、payload 或 nullable 规则。于是同一 present Markdown/Python/JSON payload，运行时可以把 canonical 写 null、raw SHA-256，或按各自解析器生成 canonical hash；三种选择都没有被现有文字明确排除，`expected_transaction_postimage_canonical_set_sha256` 因而不可跨实现复算。

此外，table-images 内只保证一张表一路，payload inventory 内只保证 `target_path` 唯一，设计没有声明两者的 target path 集互斥。把同一路径同时登记为 table image 和 payload target 后，“table-images 加 payload inventory”的 managed target 集可以按集合去重，也可以保留两条状态；两处又能声明不同 raw postimage。rollback inventory 对 target path 只允许一行，无法消除两份上游声明的优先级。mixed-state 判断、roll-forward 和 rollback 因此没有唯一状态机输入。

最小修复是给 managed-state 增加 target kind 或固定 type matrix：absent 的两个 hash 均为 null；present table/registry 的 raw 与 canonical 均必填；present raw-only payload 的 raw 必填而 canonical 固定 null，除非该 payload role 另有冻结 canonical contract。table-image path 集与 payload target path 集必须 disjoint，其并集再与 rollback inventory target set set-equal；重复 path 和冲突 hash 必须在生成 manifest 前失败。

## D：latency condition 的列到 JSON mapping 不可执行

instruction condition 段要求 `operation_type`、`operation_count_rule`、`software_version` 与 JSON 中的 instruction/dependency/toolchain “按 validator 映射一致”，但没有给映射表或 nullable 规则。现有 `condition-sets.csv` 中三列都 nullable；`operation_type` 只有十个抽象 operation enum，`operation_count_rule` 只有 `fma_2_ops,mac_2_ops,vendor_label,not_specified`，而 JSON 的 `instruction_or_opcode` 与 `dependency_pattern` 是任意非空 string。把 dependency pattern 映射为 `not_specified`、令 operation_count_rule 为空，或者误映射成 `vendor_label`，冻结文本无法判定哪一个有效。

memory condition 也有同一问题：它要求 operation type/count rule/measurement scope/software version 与 `access_operation`、`dependency_pattern`、`working_set_or_measurement_scope`、`software_or_product_condition` 对应，却没有逐列规定 exact-equal、enum 映射、固定值或允许为空。两个独立 validator 因而能对同一合法 JSON 给出相反结果，属于机器分歧，不只是文案欠清楚。

最小修复是分别为两个 condition contract 给出完整 column↔JSON-key 映射和每列 nullable/固定值/enum translation 表。若 operation count 与 latency 条件无关，应明确固定为空或 `not_specified`，不能继续写成对 dependency pattern 的未定义“映射一致”；每个映射分支都要进入三运行时正负 fixture。

## 边界与失败记录

本次只新增这份补充报告，没有改动原独立报告、v3 设计、正式表、模板、validator、staging 或进度。机器检查确认两张 factor 正式表当前均 absent，并核对了 factor PK/KeySet、transaction table image、managed-state 和 condition enum 的真实文本。没有发生用户中断、sandbox denial、approval failure、remote service error、tool/runtime failure 或操作者错误。Windows gate 不属于这次补充的执行范围。
