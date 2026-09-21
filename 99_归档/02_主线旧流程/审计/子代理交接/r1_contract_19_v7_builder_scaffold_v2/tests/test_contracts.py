import csv
import dataclasses
import json
import shutil
import tempfile
import unittest
from collections import OrderedDict
from pathlib import Path

from v7_builder_v2.authorization import validate_authorization_binding
from v7_builder_v2.bootstrap import (
    BootstrapSpec,
    BootstrapSpecItem,
    BootstrapBuild,
    BootstrapItem,
    PATCH_NAMES,
    STABLE_TARGETS,
    UNCHANGED_TARGETS,
    build_bootstrap_spec,
    materialize_bootstrap,
    _materialize_one,
    validate_contract_file_inputs,
    validate_spec_sets,
)
from v7_builder_v2.canonical import canonical_json_bytes, framed_sha256
from v7_builder_v2.errors import ContractV7Error
from v7_builder_v2.formula import build_formula_use_projections, formula_registry_v7, validate_formula_registry
from v7_builder_v2.freeze_scope import (
    FREEZE_RELATIVE_PATH,
    FREEZE_SHA256,
    construct_49_scopes,
    parse_active_scope_markdown,
    parse_raw_freeze_archive,
)
from v7_builder_v2.mapping import (
    ACTIVE_V7_DESIGN,
    MAPPING_STABLE_PAIR,
    V6_DESIGN,
    IdentityCompletenessInsertContract,
    MappingEvent,
    ScopeAllocation,
    authorization_pairs,
    build_base_chip_role_path_set_v7,
    build_mapping_override_transaction,
    choose_chip_mapping_branch,
    mapping_snapshot_pairs,
    validate_branch_inputs,
    validate_mapping_postimage,
    validate_mapping_transaction_plan,
)
from v7_builder_v2.schemas import (
    cross_check,
    load_schema,
    manual_approval,
    manual_bootstrap_item,
    manual_prerequisite,
    manual_validation_report,
    validate_instance,
)

from .support import DATA_ROOT, MAINLINE_ROOT, SCHEMA_ROOT, error_code


def synthetic_authorization_grant(transaction_id, scope_id, card_object_id):
    operation = OrderedDict((("operation_id", "OP-1"), ("operation_seq", 1)))
    payload = OrderedDict((("payload_id", "PAYLOAD-1"), ("target_path", "资料卡/NVIDIA-GA100.md")))
    authorization = OrderedDict((
        ("authorization_contract_version", "CHIP-OPERATION-AUTHORIZATION-V1"), ("authorization_id", "AUTH-GA100"),
        ("transaction_id", transaction_id), ("work_package_id", "WP-GA100"),
        ("scope_id", scope_id), ("card_object_id", card_object_id),
        ("table_operation_items", [operation]), ("payload_items", [payload]),
        ("prepared_by", "fixture:prep"), ("prepared_date", "2026-08-20"),
        ("reviewed_by", "fixture:review"), ("reviewed_date", "2026-08-21"),
        ("review_status", "reviewed"), ("notes", "isolated unit fixture; not live approval"),
    ))
    digest = framed_sha256("chip-operation-payload-authorization-v1", canonical_json_bytes(authorization))
    approval = OrderedDict((
        ("approval_contract_version", "ARTIFACT-APPROVAL-V1"), ("approval_id", "APP-AUTH-GA100"),
        ("artifact_kind", "chip_operation_payload_authorization"), ("artifact_id", "AUTH-GA100"),
        ("artifact_canonical_sha256", digest), ("approved_by", "fixture:approve"),
        ("approved_date", "2026-08-21"), ("approval_status", "approved"),
        ("notes", "isolated unit fixture; not live approval"),
    ))
    identity = {"transaction_id": transaction_id, "work_package_id": "WP-GA100", "scope_id": scope_id, "card_object_id": card_object_id}
    return validate_authorization_binding(authorization, approval, identity, identity, [operation], [payload])


class BootstrapTests(unittest.TestCase):
    def test_exact_45_58_12_4_spec(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        self.assertEqual((len(spec.base), len(spec.post), len(spec.patch), len(spec.fixed)), (45, 58, 12, 4))

    def test_exact_u23_intersection(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        base = {item.identity5 for item in spec.base}
        post = {item.identity5 for item in spec.post}
        intersection = base & post
        self.assertEqual(len(intersection), 23)
        self.assertEqual({item.logical_target_path for item in spec.base if item.identity5 in intersection}, set(UNCHANGED_TARGETS))

    def test_exact_union_92_projection_96(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        union = {item.identity5 for item in spec.base + spec.post + spec.patch}
        pairs = {(item.input_role, item.source_path) for item in spec.base + spec.post + spec.patch}
        fixed = {(item.input_role, item.source_path) for item in spec.fixed}
        self.assertEqual((len(union), len(pairs), len(pairs | fixed)), (92, 92, 96))

    def test_no_placeholder_paths(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        text = "\n".join(item.source_path for item in spec.base + spec.post + spec.patch + spec.fixed)
        self.assertNotIn("table-00", text)
        self.assertNotIn("artifact-00", text)

    def test_exact_13_stable_roles_paths_domains(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        candidates = {(item.input_role, item.logical_target_path, item.canonical_domain_tag) for item in spec.post if item.input_role not in ("managed_postimage_snapshot", "managed_unchanged_snapshot")}
        self.assertEqual(candidates, set(STABLE_TARGETS))

    def test_exact_12_patch_names(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        self.assertEqual({Path(item.source_path).name for item in spec.patch}, set(PATCH_NAMES))

    def test_wrong_path_count_preserving_substitution_rejected(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        changed = list(spec.base)
        changed[0] = dataclasses.replace(changed[0], source_path=changed[0].source_path + ".substitute")
        mutated = BootstrapSpec(spec.transaction_id, tuple(changed), spec.post, spec.patch, spec.fixed)
        with self.assertRaises(ContractV7Error) as caught:
            validate_spec_sets(mutated)
        self.assertEqual(error_code(caught), "E_REQUIRED_SET")

    def test_wrong_domain_count_preserving_substitution_rejected(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        changed = list(spec.post)
        changed[0] = dataclasses.replace(changed[0], canonical_domain_tag="json-policy-v1")
        with self.assertRaises(ContractV7Error) as caught:
            validate_spec_sets(BootstrapSpec(spec.transaction_id, spec.base, tuple(changed), spec.patch, spec.fixed))
        self.assertEqual(error_code(caught), "E_REQUIRED_SET")

    def test_live_block_cannot_materialize(self):
        from v7_builder_v2.preflight import inspect_live_prerequisites
        report = inspect_live_prerequisites(MAINLINE_ROOT, "TX-R19-LIVE")
        with self.assertRaises(ContractV7Error) as caught:
            materialize_bootstrap(MAINLINE_ROOT, "TX-R19-LIVE", report)
        self.assertEqual(error_code(caught), "E_UPSTREAM_PREREQUISITE")

    def test_isolated_exact_path_recomputes_raw_and_canonical_hashes(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        item = next(value for value in spec.base if value.logical_target_path == "数据/fields.csv")
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            path = root.joinpath(*Path(item.source_path).parts)
            path.parent.mkdir(parents=True)
            raw = b"field_id,value\nFIELD-EXACT-PATH,1\n"
            path.write_bytes(raw)
            materialized = _materialize_one(root, item)
            self.assertEqual(materialized.raw_sha256, __import__("hashlib").sha256(raw).hexdigest())
            self.assertIsNotNone(materialized.canonical_sha256)
            self.assertNotEqual(materialized.raw_sha256, materialized.canonical_sha256)

    def test_96_file_input_projection_rejects_missing_or_extra(self):
        spec = build_bootstrap_spec("TX-R19-TEST")
        def materialized(item):
            return BootstrapItem(item.input_role, item.source_path, item.logical_target_path, item.preimage_state, item.canonical_domain_tag, "0" * 64, None if item.canonical_domain_tag is None else "1" * 64)
        base = tuple(materialized(item) for item in spec.base)
        post = tuple(materialized(item) for item in spec.post)
        patch = tuple(materialized(item) for item in spec.patch)
        fixed = tuple(materialized(item) for item in spec.fixed)
        pairs = tuple(sorted({(item.input_role, item.source_path) for item in base + post + patch + fixed}))
        build = BootstrapBuild(spec, base, post, patch, fixed, pairs)
        validate_contract_file_inputs(pairs, build)
        with self.assertRaises(ContractV7Error) as caught:
            validate_contract_file_inputs(pairs[:-1], build)
        self.assertEqual(error_code(caught), "E_FILE_INPUT_PROJECTION")


class FreezeAndFormulaTests(unittest.TestCase):
    def test_raw_freeze_contract(self):
        archive = parse_raw_freeze_archive(MAINLINE_ROOT / FREEZE_RELATIVE_PATH)
        self.assertEqual((archive.raw_sha256, archive.byte_length, len(archive.rows), len(archive.counted_rows)), (FREEZE_SHA256, 55224, 77, 49))

    def test_49_scope_constructor_and_ga100(self):
        archive = parse_raw_freeze_archive(MAINLINE_ROOT / FREEZE_RELATIVE_PATH)
        active = parse_active_scope_markdown(MAINLINE_ROOT / "清单/训练与推理芯片名单.md")
        scopes = construct_49_scopes(archive, active)
        self.assertEqual((len(scopes), scopes[0].scope_id, scopes[0].freeze_row_id), (49, "SCOPE-0001", "FREEZE-NV-001"))

    def test_freeze_byte_drift_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            path = Path(temp_text) / "freeze.csv"
            raw = (MAINLINE_ROOT / FREEZE_RELATIVE_PATH).read_bytes()
            path.write_bytes(raw[:-1] + bytes([raw[-1] ^ 1]))
            with self.assertRaises(ContractV7Error) as caught:
                parse_raw_freeze_archive(path)
            self.assertEqual(error_code(caught), "E_FREEZE_ARCHIVE_RAW_DRIFT")

    def test_active_heading_missing_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            path = Path(temp_text) / "scope.md"
            path.write_text("# no formal list\n", encoding="utf-8")
            with self.assertRaises(ContractV7Error) as caught:
                parse_active_scope_markdown(path)
            self.assertEqual(error_code(caught), "E_MARKDOWN_PIPE")

    def test_formula_registry_exact_eight(self):
        registry = formula_registry_v7()
        validate_formula_registry(registry)
        self.assertEqual(len(registry), 8)

    def test_formula_current_24_47(self):
        projections = build_formula_use_projections(DATA_ROOT)
        self.assertEqual((len(projections), sum(len(item.inputs) for item in projections)), (24, 47))

    def test_structural_enum_projection(self):
        projection = next(item for item in build_formula_use_projections(DATA_ROOT) if item.formula_id == "FORMULA-STRUCTURAL-PROJECTION")
        self.assertEqual((projection.output_fact_value_kind, projection.output_fact_normalized_unit, projection.metric_output_unit), ("text", "", "enum:pooling_mode"))

    def test_structural_enum_wrong_metric_token_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            temp = Path(temp_text)
            for name in ("derived-metrics.csv", "derived-inputs.csv", "facts.csv", "fields.csv"):
                shutil.copyfile(DATA_ROOT / name, temp / name)
            text = (temp / "derived-metrics.csv").read_text(encoding="utf-8-sig")
            text = text.replace("enum:pooling_mode", "pooling_mode", 1)
            (temp / "derived-metrics.csv").write_text(text, encoding="utf-8")
            with self.assertRaises(ContractV7Error) as caught:
                build_formula_use_projections(temp)
            self.assertEqual(error_code(caught), "E_FORMULA_OUTPUT_DESCRIPTOR")

    def test_bad_input_order_normalized(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            temp = Path(temp_text)
            for name in ("derived-metrics.csv", "derived-inputs.csv", "facts.csv", "fields.csv"):
                shutil.copyfile(DATA_ROOT / name, temp / name)
            path = temp / "derived-inputs.csv"
            with path.open("r", encoding="utf-8-sig", newline="") as handle:
                rows = list(csv.reader(handle))
            rows[1][2] = "not-int"
            with path.open("w", encoding="utf-8", newline="") as handle:
                csv.writer(handle, lineterminator="\n").writerows(rows)
            with self.assertRaises(ContractV7Error) as caught:
                build_formula_use_projections(temp)
            self.assertEqual(error_code(caught), "E_VALUE_PARSE")


class MappingTests(unittest.TestCase):
    def setUp(self):
        self.tx = "TX-R19-CHIP"
        self.allocation = ScopeAllocation("ALLOC-SCOPE-0001", "FREEZE-NV-001", "SCOPE-0001", "active", "approved")
        self.pending = MappingEvent("MAPEV-SCOPE-0001-0001", "FREEZE-NV-001", "SCOPE-0001", 1, "", "OBJ-NVIDIA-GA100-DIE", "pending_formal_object_create", "initial_scope_import_v1", "needs_resolution")
        self.grant = synthetic_authorization_grant(self.tx, "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE")

    def test_exact_base_chip_role_path_set_35(self):
        pairs = build_base_chip_role_path_set_v7(self.tx)
        self.assertEqual(len(pairs), 35)
        self.assertIn(ACTIVE_V7_DESIGN, pairs)
        self.assertNotIn(V6_DESIGN, pairs)

    def test_ga100_branch_is_exact_38(self):
        branch = choose_chip_mapping_branch((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        self.assertEqual((branch.name, branch.required_input_count, branch.next_seq), ("MAPPING_OVERRIDE", 38, 2))
        self.assertNotIn(MAPPING_STABLE_PAIR, branch.required_pairs)
        self.assertTrue(set(mapping_snapshot_pairs(self.tx)).issubset(branch.required_pairs))

    def test_mapped_same_card_branch_is_exact_37(self):
        mapped = MappingEvent("MAPEV-SCOPE-0001-0001", "FREEZE-NV-001", "SCOPE-0001", 1, "OBJ-NVIDIA-GA100-DIE", "", "mapped", "initial_scope_import_v1", "approved")
        branch = choose_chip_mapping_branch((mapped,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        self.assertEqual((branch.name, branch.required_input_count), ("NO_MAPPING_CHANGE", 37))
        self.assertIn(MAPPING_STABLE_PAIR, branch.required_pairs)

    def test_branch_input_set_is_bidirectional(self):
        branch = choose_chip_mapping_branch((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        validate_branch_inputs(branch, branch.required_pairs)
        with self.assertRaises(ContractV7Error):
            validate_branch_inputs(branch, branch.required_pairs[:-1])

    def test_override_plan_closes_object_identity_mapping(self):
        plan = build_mapping_override_transaction((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx, self.grant)
        self.assertEqual(plan.mapping_insert.mapping_event_id, "MAPEV-SCOPE-0001-0002")
        self.assertEqual(plan.mapping_insert.freeze_row_id, "FREEZE-NV-001")
        self.assertEqual({plan.object_insert.object_id, plan.identity_insert.object_id, plan.mapping_insert.formal_object_id}, {"OBJ-NVIDIA-GA100-DIE"})
        self.assertFalse(hasattr(plan.mapping_insert, "reviewer"))
        self.assertFalse(hasattr(plan.mapping_insert, "review_date"))

    def test_override_plan_without_validated_authorization_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            build_mapping_override_transaction((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx, None)
        self.assertEqual(error_code(caught), "E_APPROVAL_BINDING")

    def test_rejected_event_still_consumes_seq(self):
        rejected = MappingEvent("MAPEV-SCOPE-0001-0002", "FREEZE-NV-001", "SCOPE-0001", 2, "", "OBJ-OTHER", "pending_formal_object_create", "proposal", "rejected")
        branch = choose_chip_mapping_branch((self.pending, rejected), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        self.assertEqual(branch.next_seq, 3)

    def test_sequence_gap_rejected(self):
        gap = dataclasses.replace(self.pending, mapping_event_id="MAPEV-SCOPE-0001-0003", mapping_event_seq=3)
        with self.assertRaises(ContractV7Error) as caught:
            choose_chip_mapping_branch((gap,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        self.assertEqual(error_code(caught), "E_SCOPE_MAPPING_LIFECYCLE")

    def test_allocation_freeze_mismatch_rejected(self):
        wrong = dataclasses.replace(self.allocation, freeze_row_id="FREEZE-NV-999")
        with self.assertRaises(ContractV7Error) as caught:
            choose_chip_mapping_branch((self.pending,), (wrong,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx)
        self.assertEqual(error_code(caught), "E_SCOPE_ALLOCATION")

    def test_old_row_mutation_rejected(self):
        plan = build_mapping_override_transaction((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx, self.grant)
        changed_old = dataclasses.replace(self.pending, mapping_basis="mutated")
        with self.assertRaises(ContractV7Error) as caught:
            validate_mapping_postimage((self.pending,), (changed_old, plan.mapping_insert))
        self.assertEqual(error_code(caught), "E_OLD_ROW_MUTATION")

    def test_transaction_identity_mismatch_rejected(self):
        plan = build_mapping_override_transaction((self.pending,), (self.allocation,), "SCOPE-0001", "OBJ-NVIDIA-GA100-DIE", self.tx, self.grant)
        changed_identity = dataclasses.replace(plan.identity_insert, transaction_id="TX-OTHER")
        changed_plan = dataclasses.replace(plan, identity_insert=changed_identity)
        with self.assertRaises(ContractV7Error) as caught:
            validate_mapping_transaction_plan(changed_plan, (self.allocation,))
        self.assertEqual(error_code(caught), "E_TRANSACTION_CLOSURE")


class SchemaTests(unittest.TestCase):
    def _schemas(self):
        return {name: load_schema(SCHEMA_ROOT / name) for name in ("bootstrap-item.schema.json", "source-pool-prerequisite.schema.json", "artifact-approval.schema.json", "validation-report.schema.json")}

    def _bootstrap_item(self):
        return OrderedDict((
            ("input_role", "managed_base_snapshot"),
            ("source_path", "审计/事务/TX-TEST/inputs/base/数据/fields.csv"),
            ("logical_target_path", "数据/fields.csv"),
            ("preimage_state", "present"),
            ("raw_sha256", "0" * 64),
            ("canonical_domain_tag", "rowset-v1"),
            ("canonical_sha256", "1" * 64),
        ))

    def _approval(self):
        return OrderedDict((
            ("approval_contract_version", "ARTIFACT-APPROVAL-V1"), ("approval_id", "APPROVAL-TEST"),
            ("artifact_kind", "source_pool_113_prerequisite"), ("artifact_id", "PREREQ-TEST"),
            ("artifact_canonical_sha256", "2" * 64), ("approved_by", "principal:approver"),
            ("approved_date", "2026-08-21"), ("approval_status", "approved"), ("notes", None),
        ))

    def _prerequisite(self):
        from v7_builder_v2.preflight import EXPECTED_FORMAL_POST_HASHES, OPERATIONS_PATH, OPERATIONS_SHA256, REVIEW_PATH, REVIEW_SHA256
        gates = []
        for seq, gate in enumerate(("source_pool", "chip_scope", "research_data_subject_contract"), start=1):
            gates.append(OrderedDict((("gate_seq", seq), ("gate_id", gate), ("transcript_path", "审计/事务/TX-TEST/gates/%s.txt" % gate), ("transcript_raw_sha256", str(seq) * 64), ("result", "passed"))))
        return OrderedDict((
            ("prerequisite_contract_version", "SOURCE-POOL-113-PREREQUISITE-V1"), ("prerequisite_id", "PREREQ-TEST"),
            ("source_pool_contract_review_path", REVIEW_PATH), ("source_pool_contract_review_raw_sha256", REVIEW_SHA256),
            ("source_pool_operations_path", OPERATIONS_PATH), ("source_pool_operations_raw_sha256", OPERATIONS_SHA256),
            ("promotion_id", "PROMOTION-TEST"),
            ("promotion_record_path", "审计/子代理交接/r1_source_pool_113_staging/promotion-records/PROMOTION-TEST/promotion-record.json"),
            ("promotion_record_raw_sha256", "a" * 64), ("promotion_status", "succeeded"),
            ("formal_manifest_path", EXPECTED_FORMAL_POST_HASHES[1][0]), ("formal_manifest_raw_sha256", EXPECTED_FORMAL_POST_HASHES[1][1]), ("formal_manifest_rows", 113),
            ("formal_summary_path", EXPECTED_FORMAL_POST_HASHES[2][0]), ("formal_summary_raw_sha256", EXPECTED_FORMAL_POST_HASHES[2][1]),
            ("collector_path", EXPECTED_FORMAL_POST_HASHES[3][0]), ("collector_raw_sha256", EXPECTED_FORMAL_POST_HASHES[3][1]),
            ("validator_path", EXPECTED_FORMAL_POST_HASHES[0][0]), ("validator_raw_sha256", EXPECTED_FORMAL_POST_HASHES[0][1]),
            ("controlled_ledger_path", EXPECTED_FORMAL_POST_HASHES[4][0]), ("controlled_ledger_raw_sha256", EXPECTED_FORMAL_POST_HASHES[4][1]),
            ("controlled_frozen_manifest_path", EXPECTED_FORMAL_POST_HASHES[5][0]), ("controlled_frozen_manifest_raw_sha256", EXPECTED_FORMAL_POST_HASHES[5][1]),
            ("gate_results", gates), ("prepared_by", "principal:prep"), ("prepared_date", "2026-08-20"),
            ("reviewed_by", "principal:review"), ("reviewed_date", "2026-08-21"), ("review_status", "reviewed"), ("notes", None),
        ))

    def _report(self):
        return OrderedDict((
            ("report_contract_version", "R19-VALIDATION-REPORT-V1"), ("generated_by", "python3.9 unittest"),
            ("scope", "audit_only_v7_builder_scaffold_v2"), ("status", "PASS_WITH_EXPECTED_LIVE_BLOCK"),
            ("unit_tests", {"status": "PASS", "count": 1}), ("live_preflight", {"status": "BLOCKED", "error_code": "E_UPSTREAM_PREREQUISITE"}),
            ("artifacts", [{"relative_path": "README.md", "raw_sha256": "f" * 64}]), ("failure_classification", []),
        ))

    def test_all_four_schemas_load(self):
        self.assertEqual(len(self._schemas()), 4)

    def test_bootstrap_schema_crosscheck_positive(self):
        cross_check(self._schemas()["bootstrap-item.schema.json"], self._bootstrap_item(), manual_bootstrap_item)

    def test_bootstrap_schema_crosscheck_negative(self):
        item = self._bootstrap_item(); item["unexpected"] = True
        with self.assertRaises(ContractV7Error):
            cross_check(self._schemas()["bootstrap-item.schema.json"], item, manual_bootstrap_item)

    def test_prerequisite_schema_crosscheck_positive(self):
        cross_check(self._schemas()["source-pool-prerequisite.schema.json"], self._prerequisite(), manual_prerequisite)

    def test_prerequisite_schema_crosscheck_negative(self):
        item = self._prerequisite(); item["formal_manifest_rows"] = 112
        with self.assertRaises(ContractV7Error):
            cross_check(self._schemas()["source-pool-prerequisite.schema.json"], item, manual_prerequisite)

    def test_approval_schema_crosscheck_positive(self):
        cross_check(self._schemas()["artifact-approval.schema.json"], self._approval(), manual_approval)

    def test_approval_schema_crosscheck_negative(self):
        item = self._approval(); item["approved_by"] = " "
        with self.assertRaises(ContractV7Error):
            cross_check(self._schemas()["artifact-approval.schema.json"], item, manual_approval)

    def test_validation_report_schema_crosscheck_positive(self):
        cross_check(self._schemas()["validation-report.schema.json"], self._report(), manual_validation_report)

    def test_validation_report_schema_crosscheck_negative(self):
        item = self._report(); item["status"] = "PASS"
        with self.assertRaises(ContractV7Error):
            cross_check(self._schemas()["validation-report.schema.json"], item, manual_validation_report)

    def test_unknown_schema_keyword_fails_closed(self):
        schema = {"$schema": "https://json-schema.org/draft/2020-12/schema", "type": "string", "inventedKeyword": True}
        with self.assertRaises(ContractV7Error) as caught:
            validate_instance(schema, "x")
        self.assertEqual(error_code(caught), "E_SCHEMA_KEYWORD")

    def test_unresolved_ref_fails_closed(self):
        schema = {"$schema": "https://json-schema.org/draft/2020-12/schema", "$ref": "#/$defs/missing", "$defs": {}}
        with self.assertRaises(ContractV7Error) as caught:
            validate_instance(schema, "x")
        self.assertEqual(error_code(caught), "E_SCHEMA_REF")


class AuthorizationTests(unittest.TestCase):
    def _documents(self):
        identity = {"transaction_id": "TX-CHIP", "work_package_id": "WP-GA100", "scope_id": "SCOPE-0001", "card_object_id": "OBJ-NVIDIA-GA100-DIE"}
        operation = OrderedDict((("operation_id", "OP-1"), ("operation_seq", 1)))
        payload = OrderedDict((("payload_id", "PAYLOAD-1"), ("target_path", "资料卡/NVIDIA-GA100.md")))
        authorization = OrderedDict((
            ("authorization_contract_version", "CHIP-OPERATION-AUTHORIZATION-V1"), ("authorization_id", "AUTH-GA100"),
            ("transaction_id", identity["transaction_id"]), ("work_package_id", identity["work_package_id"]),
            ("scope_id", identity["scope_id"]), ("card_object_id", identity["card_object_id"]),
            ("table_operation_items", [operation]), ("payload_items", [payload]),
            ("prepared_by", "principal:prep"), ("prepared_date", "2026-08-20"),
            ("reviewed_by", "principal:review"), ("reviewed_date", "2026-08-21"),
            ("review_status", "reviewed"), ("notes", None),
        ))
        digest = framed_sha256("chip-operation-payload-authorization-v1", canonical_json_bytes(authorization))
        approval = OrderedDict((
            ("approval_contract_version", "ARTIFACT-APPROVAL-V1"), ("approval_id", "APP-AUTH-GA100"),
            ("artifact_kind", "chip_operation_payload_authorization"), ("artifact_id", "AUTH-GA100"),
            ("artifact_canonical_sha256", digest), ("approved_by", "principal:approve"),
            ("approved_date", "2026-08-21"), ("approval_status", "approved"), ("notes", None),
        ))
        return authorization, approval, dict(identity), dict(identity), [operation], [payload]

    def test_authorization_identity_binding(self):
        documents = self._documents()
        grant = validate_authorization_binding(*documents)
        self.assertEqual(len(grant.canonical_sha256), 64)

    def test_authorization_identity_mismatch_rejected(self):
        authorization, approval, coverage, transaction, operations, payloads = self._documents()
        transaction["scope_id"] = "SCOPE-0002"
        with self.assertRaises(ContractV7Error) as caught:
            validate_authorization_binding(authorization, approval, coverage, transaction, operations, payloads)
        self.assertEqual(error_code(caught), "E_AUTHORIZATION_IDENTITY")

    def test_authorization_casefold_principal_collision_rejected(self):
        authorization, approval, coverage, transaction, operations, payloads = self._documents()
        approval["approved_by"] = "PRINCIPAL:PREP"
        with self.assertRaises(ContractV7Error) as caught:
            validate_authorization_binding(authorization, approval, coverage, transaction, operations, payloads)
        self.assertEqual(error_code(caught), "E_PRINCIPAL_COLLISION")


if __name__ == "__main__":
    unittest.main()
