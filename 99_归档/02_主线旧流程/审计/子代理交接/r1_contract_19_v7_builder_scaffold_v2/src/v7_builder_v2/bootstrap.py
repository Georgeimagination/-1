"""Frozen v7 bootstrap role/path/domain constructors and byte recomputation."""

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, Mapping, Optional, Sequence, Set, Tuple

from .canonical import canonical_hash_for, file_sha256, raw_sha256
from .errors import ContractV7Error, UpstreamPrerequisiteError, require, raise_stable_external
from .pathing import resolve_contained, validate_logical_path, validate_path_set


MANAGED_BASE_TARGETS: Tuple[str, ...] = (
    "数据/schema-columns.csv", "数据/enums.csv", "数据/fields.csv", "数据/objects.csv",
    "数据/card-completeness.csv", "最小参考资料库/search-log.csv", "最小参考资料库/search-results.csv",
    "最小参考资料库/requirement-evidence.csv", "最小参考资料库/fact-assertions.csv",
    "清单/训练与推理芯片名单.md", "scripts/validation/Validate-ResearchData.ps1",
    "scripts/validation/Test-ChipScope.ps1", "scripts/validation/Test-SourcePool.ps1",
    "scripts/validation/verify_recovery_paths.py", "资料卡/模板.md", "资料卡/字段字典.md",
    "README.md", "AGENTS.md", "研究计划.md", "进度/当前状态.md",
)

MANAGED_POST_TARGETS: Tuple[str, ...] = MANAGED_BASE_TARGETS + (
    "数据/factor-requirements.csv", "数据/factor-target-bindings.csv",
)

UNCHANGED_TARGETS: Tuple[str, ...] = (
    "数据/components.csv", "数据/condition-sets.csv", "数据/derived-inputs.csv",
    "数据/derived-metrics.csv", "数据/facts.csv", "数据/field-requirements.csv",
    "数据/links.csv", "数据/memory-levels.csv", "数据/object-relations.csv",
    "数据/precision-paths.csv", "数据/special-capabilities.csv", "数据/topologies.csv",
    "数据/vendors.csv", "最小参考资料库/conflict-groups.csv", "最小参考资料库/conflict-members.csv",
    "最小参考资料库/selection-members.csv", "最小参考资料库/selection-runs.csv",
    "最小参考资料库/source-coverage.csv", "最小参考资料库/source-endpoints.csv",
    "最小参考资料库/source-families.csv", "最小参考资料库/sources.csv",
    "最小参考资料库/source-screening.csv", "最小参考资料库/source-selected-roles.csv",
)

STABLE_TARGETS: Tuple[Tuple[str, str, str], ...] = (
    ("coverage_policy", "审计/合同注册表/coverage-policy-v5.0.json", "json-policy-v1"),
    ("coverage_policy_approval", "审计/合同注册表/coverage-policy-v5.0-approval.json", "json-approval-v1"),
    ("source_date_policy", "审计/合同注册表/source-date-policy-v3.0.csv", "rowset-v1"),
    ("source_date_policy_approval", "审计/合同注册表/source-date-policy-approval.json", "json-approval-v1"),
    ("legacy_requirement_registry", "审计/合同注册表/legacy-requirement-disposition.csv", "rowset-v1"),
    ("legacy_requirement_registry_approval", "审计/合同注册表/legacy-requirement-disposition-approval.json", "json-approval-v1"),
    ("legacy_reconciliation_registry", "审计/合同注册表/legacy-requirement-reconciliation-events.csv", "rowset-v1"),
    ("scope_allocation_registry", "审计/合同注册表/scope-id-registry.csv", "rowset-v1"),
    ("scope_mapping_registry", "审计/合同注册表/scope-object-mapping.csv", "rowset-v1"),
    ("formula_evaluator_spec", "审计/合同注册表/formula-evaluator-v1.json", "formula-evaluator-spec-v1"),
    ("canonical_fixture_manifest", "审计/合同注册表/canonical-fixture-manifest.json", "json-manifest-v1"),
    ("canonical_fixtures", "审计/合同注册表/canonical-fixtures.csv", "rowset-v1"),
    ("canonical_runtime_results", "审计/合同注册表/canonical-runtime-results.csv", "rowset-v1"),
)

PATCH_NAMES: Tuple[str, ...] = (
    "active-scope-list.patch.json", "formula-evaluator-spec.patch.json",
    "validate-research-data.patch.json", "test-chip-scope.patch.json",
    "test-source-pool.patch.json", "verify-recovery-paths.patch.json",
    "card-template.patch.json", "field-dictionary.patch.json", "project-readme.patch.json",
    "project-agents.patch.json", "research-plan.patch.json", "current-status.patch.json",
)

CONTROLLED_BASE_TARGETS = frozenset(MANAGED_BASE_TARGETS[:9])
CONTROLLED_POST_TARGETS = frozenset(MANAGED_POST_TARGETS[:9] + MANAGED_POST_TARGETS[-2:])


@dataclass(frozen=True)
class BootstrapSpecItem:
    input_role: str
    source_path: str
    logical_target_path: str
    preimage_state: str
    canonical_domain_tag: Optional[str]

    @property
    def identity5(self) -> Tuple[object, ...]:
        return (self.input_role, self.source_path, self.logical_target_path, self.preimage_state, self.canonical_domain_tag)


@dataclass(frozen=True)
class BootstrapItem(BootstrapSpecItem):
    raw_sha256: str
    canonical_sha256: Optional[str]

    @property
    def identity7(self) -> Tuple[object, ...]:
        return self.identity5[:4] + (self.raw_sha256, self.canonical_domain_tag, self.canonical_sha256)

    def to_dict(self) -> Dict[str, object]:
        return {
            "input_role": self.input_role,
            "source_path": self.source_path,
            "logical_target_path": self.logical_target_path,
            "preimage_state": self.preimage_state,
            "raw_sha256": self.raw_sha256,
            "canonical_domain_tag": self.canonical_domain_tag,
            "canonical_sha256": self.canonical_sha256,
        }


@dataclass(frozen=True)
class BootstrapSpec:
    transaction_id: str
    base: Tuple[BootstrapSpecItem, ...]
    post: Tuple[BootstrapSpecItem, ...]
    patch: Tuple[BootstrapSpecItem, ...]
    fixed: Tuple[BootstrapSpecItem, ...]


@dataclass(frozen=True)
class BootstrapBuild:
    spec: BootstrapSpec
    base: Tuple[BootstrapItem, ...]
    post: Tuple[BootstrapItem, ...]
    patch: Tuple[BootstrapItem, ...]
    fixed: Tuple[BootstrapItem, ...]
    contract_file_inputs: Tuple[Tuple[str, str], ...]


def _transaction_prefix(transaction_id: str) -> str:
    require(isinstance(transaction_id, str) and bool(transaction_id), "E_TRANSACTION_ID", "transaction ID is empty")
    require("/" not in transaction_id and "\\" not in transaction_id and transaction_id not in (".", ".."), "E_TRANSACTION_ID", "transaction ID is unsafe")
    return "审计/事务/%s" % transaction_id


def _sorted(items: Iterable[BootstrapSpecItem]) -> Tuple[BootstrapSpecItem, ...]:
    return tuple(sorted(items, key=lambda item: (item.input_role.encode("utf-8"), item.source_path.encode("utf-8"), item.logical_target_path.encode("utf-8"))))


def build_bootstrap_spec(transaction_id: str) -> BootstrapSpec:
    """Build the exact v7 role/path/state/domain universe; no caller paths enter."""

    prefix = _transaction_prefix(transaction_id)
    base = []
    for target in MANAGED_BASE_TARGETS:
        base.append(BootstrapSpecItem("managed_base_snapshot", "%s/inputs/base/%s" % (prefix, target), target, "present", "rowset-v1" if target in CONTROLLED_BASE_TARGETS else None))
    unchanged = [BootstrapSpecItem("managed_unchanged_snapshot", "%s/inputs/unchanged/%s" % (prefix, target), target, "present", "rowset-v1") for target in UNCHANGED_TARGETS]
    base.extend(unchanged)
    base.extend((
        BootstrapSpecItem("source_pool_prerequisite_manifest", "%s/inputs/prerequisites/source-pool-113-prerequisite.json" % prefix, "%s/inputs/prerequisites/source-pool-113-prerequisite.json" % prefix, "present", "source-pool-113-prerequisite-v1"),
        BootstrapSpecItem("source_pool_prerequisite_approval", "%s/inputs/prerequisites/source-pool-113-prerequisite-approval.json" % prefix, "%s/inputs/prerequisites/source-pool-113-prerequisite-approval.json" % prefix, "present", "json-approval-v1"),
    ))
    post = []
    for target in MANAGED_POST_TARGETS:
        post.append(BootstrapSpecItem("managed_postimage_snapshot", "%s/inputs/post/%s" % (prefix, target), target, "present", "rowset-v1" if target in CONTROLLED_POST_TARGETS else None))
    post.extend(unchanged)
    post.extend(BootstrapSpecItem(role, "%s/inputs/bootstrap/targets/%s" % (prefix, target), target, "present", domain) for role, target, domain in STABLE_TARGETS)
    patch = [BootstrapSpecItem("managed_patch", "%s/inputs/patches/%s" % (prefix, name), "%s/inputs/patches/%s" % (prefix, name), "present", "managed-patch-v1") for name in PATCH_NAMES]
    fixed = (
        BootstrapSpecItem("contract_design", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md", "present", None),
        BootstrapSpecItem("scope_freeze_archive", "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv", "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv", "present", None),
        BootstrapSpecItem("bootstrap_bundle_manifest", "%s/inputs/bootstrap/bootstrap-bundle-manifest.json" % prefix, "%s/inputs/bootstrap/bootstrap-bundle-manifest.json" % prefix, "present", "contract-bootstrap-manifest-v2"),
        BootstrapSpecItem("bootstrap_bundle_approval", "%s/inputs/bootstrap/bootstrap-bundle-approval.json" % prefix, "%s/inputs/bootstrap/bootstrap-bundle-approval.json" % prefix, "present", "json-approval-v1"),
    )
    spec = BootstrapSpec(transaction_id, _sorted(base), _sorted(post), _sorted(patch), _sorted(fixed))
    validate_spec_sets(spec)
    return spec


def validate_spec_sets(spec: BootstrapSpec) -> None:
    require((len(spec.base), len(spec.post), len(spec.patch), len(spec.fixed)) == (45, 58, 12, 4), "E_BOOTSTRAP_PHASE_INTERSECTION", "bootstrap counts must be 45/58/12 plus four fixed inputs")
    all_items = spec.base + spec.post + spec.patch + spec.fixed
    for item in all_items:
        require(all(isinstance(value, str) and bool(value) for value in (item.input_role, item.source_path, item.logical_target_path, item.preimage_state)), "E_JSON_TYPE", "bootstrap spec string field is empty or non-string")
        require(item.canonical_domain_tag is None or isinstance(item.canonical_domain_tag, str), "E_JSON_TYPE", "bootstrap domain is not string/null")
    validate_path_set(sorted({item.source_path for item in all_items}, key=lambda value: value.encode("utf-8")))
    validate_path_set(sorted({item.logical_target_path for item in all_items}, key=lambda value: value.encode("utf-8")))
    for items, label in ((spec.base, "base"), (spec.post, "post"), (spec.patch, "patch"), (spec.fixed, "fixed")):
        identities = [item.identity5 for item in items]
        require(len(identities) == len(set(identities)), "E_BOOTSTRAP_ITEM_IDENTITY", "%s contains duplicate identity" % label)
        locators = [(item.input_role, item.source_path, item.logical_target_path) for item in items]
        require(len(locators) == len(set(locators)), "E_BOOTSTRAP_ITEM_IDENTITY", "%s contains duplicate locator" % label)
    base_set, post_set, patch_set = set(item.identity5 for item in spec.base), set(item.identity5 for item in spec.post), set(item.identity5 for item in spec.patch)
    prefix = _transaction_prefix(spec.transaction_id)
    expected_base = {
        BootstrapSpecItem("managed_base_snapshot", "%s/inputs/base/%s" % (prefix, target), target, "present", "rowset-v1" if target in CONTROLLED_BASE_TARGETS else None).identity5
        for target in MANAGED_BASE_TARGETS
    }
    expected_u23 = {
        BootstrapSpecItem("managed_unchanged_snapshot", "%s/inputs/unchanged/%s" % (prefix, target), target, "present", "rowset-v1").identity5
        for target in UNCHANGED_TARGETS
    }
    expected_base.update(expected_u23)
    expected_base.update((
        BootstrapSpecItem("source_pool_prerequisite_manifest", "%s/inputs/prerequisites/source-pool-113-prerequisite.json" % prefix, "%s/inputs/prerequisites/source-pool-113-prerequisite.json" % prefix, "present", "source-pool-113-prerequisite-v1").identity5,
        BootstrapSpecItem("source_pool_prerequisite_approval", "%s/inputs/prerequisites/source-pool-113-prerequisite-approval.json" % prefix, "%s/inputs/prerequisites/source-pool-113-prerequisite-approval.json" % prefix, "present", "json-approval-v1").identity5,
    ))
    expected_post = {
        BootstrapSpecItem("managed_postimage_snapshot", "%s/inputs/post/%s" % (prefix, target), target, "present", "rowset-v1" if target in CONTROLLED_POST_TARGETS else None).identity5
        for target in MANAGED_POST_TARGETS
    }
    expected_post.update(expected_u23)
    expected_post.update(
        BootstrapSpecItem(role, "%s/inputs/bootstrap/targets/%s" % (prefix, target), target, "present", domain).identity5
        for role, target, domain in STABLE_TARGETS
    )
    expected_patch = {
        BootstrapSpecItem("managed_patch", "%s/inputs/patches/%s" % (prefix, name), "%s/inputs/patches/%s" % (prefix, name), "present", "managed-patch-v1").identity5
        for name in PATCH_NAMES
    }
    expected_fixed = {
        BootstrapSpecItem("contract_design", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md", "present", None).identity5,
        BootstrapSpecItem("scope_freeze_archive", "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv", "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv", "present", None).identity5,
        BootstrapSpecItem("bootstrap_bundle_manifest", "%s/inputs/bootstrap/bootstrap-bundle-manifest.json" % prefix, "%s/inputs/bootstrap/bootstrap-bundle-manifest.json" % prefix, "present", "contract-bootstrap-manifest-v2").identity5,
        BootstrapSpecItem("bootstrap_bundle_approval", "%s/inputs/bootstrap/bootstrap-bundle-approval.json" % prefix, "%s/inputs/bootstrap/bootstrap-bundle-approval.json" % prefix, "present", "json-approval-v1").identity5,
    }
    require(base_set == expected_base and post_set == expected_post and patch_set == expected_patch and {item.identity5 for item in spec.fixed} == expected_fixed, "E_REQUIRED_SET", "bootstrap role/source/logical/state/domain sets differ from frozen v7 spec")
    require(len(expected_u23) == 23 and base_set.intersection(post_set) == expected_u23, "E_BOOTSTRAP_PHASE_INTERSECTION", "base/post intersection is not exact U23")
    require(not base_set.intersection(patch_set) and not post_set.intersection(patch_set), "E_BOOTSTRAP_PHASE_INTERSECTION", "patch intersects a snapshot phase")
    union = base_set.union(post_set, patch_set)
    require(len(union) == 92, "E_BOOTSTRAP_PHASE_INTERSECTION", "bootstrap unique identity count must be 92")
    pairs = {(item.input_role, item.source_path) for item in spec.base + spec.post + spec.patch}
    require(len(pairs) == 92, "E_FILE_INPUT_PROJECTION", "bootstrap projection must contain 92 pairs")
    fixed_pairs = {(item.input_role, item.source_path) for item in spec.fixed}
    require(len(pairs.union(fixed_pairs)) == 96, "E_FILE_INPUT_PROJECTION", "contract projection must contain 96 pairs")
    require(("contract_design", "审计/子代理交接/r1_ga100_36_contract_repair_design_v6.md") not in fixed_pairs, "E_REQUIRED_SET", "v6 cannot remain the active contract design")


def _materialize_one(mainline_root: Path, item: BootstrapSpecItem) -> BootstrapItem:
    path = resolve_contained(mainline_root, item.source_path, must_exist=True)
    require(path.is_file(), "E_IO_NOT_FOUND", "bootstrap input is not a regular file", {"path": item.source_path})
    try:
        raw = path.read_bytes()
    except BaseException as error:
        raise_stable_external(error, "read bootstrap input")
    canonical = canonical_hash_for(raw, item.logical_target_path, item.canonical_domain_tag)
    return BootstrapItem(item.input_role, item.source_path, item.logical_target_path, item.preimage_state, item.canonical_domain_tag, raw_sha256(raw), canonical)


def materialize_bootstrap(mainline_root: Path, transaction_id: str, ready_report: Any) -> BootstrapBuild:
    """Read every exact input only after a successful, freshly revalidated preflight."""

    from .preflight import revalidate_ready_report

    if ready_report is None or getattr(ready_report, "status", None) != "READY":
        raise UpstreamPrerequisiteError("bootstrap bytes cannot be read before source-pool-113 prerequisites are READY")
    revalidate_ready_report(ready_report, mainline_root)
    spec = build_bootstrap_spec(transaction_id)
    base = tuple(_materialize_one(mainline_root, item) for item in spec.base)
    post = tuple(_materialize_one(mainline_root, item) for item in spec.post)
    patch = tuple(_materialize_one(mainline_root, item) for item in spec.patch)
    fixed = tuple(_materialize_one(mainline_root, item) for item in spec.fixed)
    validate_materialized_sets(spec, base, post, patch, fixed)
    pairs = {(item.input_role, item.source_path) for item in base + post + patch + fixed}
    return BootstrapBuild(spec, base, post, patch, fixed, tuple(sorted(pairs, key=lambda pair: (pair[0].encode("utf-8"), pair[1].encode("utf-8")))))


def validate_materialized_sets(spec: BootstrapSpec, base: Sequence[BootstrapItem], post: Sequence[BootstrapItem], patch: Sequence[BootstrapItem], fixed: Sequence[BootstrapItem]) -> None:
    for expected, actual, label in ((spec.base, base, "base"), (spec.post, post, "post"), (spec.patch, patch, "patch"), (spec.fixed, fixed, "fixed")):
        require(len(expected) == len(actual), "E_REQUIRED_SET", "%s materialized count differs" % label)
        require(set(item.identity5 for item in actual) == set(item.identity5 for item in expected), "E_REQUIRED_SET", "%s role/source/logical/state/domain set differs" % label)
        for item in actual:
            require(len(item.raw_sha256) == 64, "E_SHA256", "raw hash was not recomputed")
            require((item.canonical_domain_tag is None) == (item.canonical_sha256 is None), "E_CANONICAL_NULL", "canonical domain/hash nullability differs")
    base7, post7, patch7 = set(item.identity7 for item in base), set(item.identity7 for item in post), set(item.identity7 for item in patch)
    u23 = set(item.identity7 for item in base if item.input_role == "managed_unchanged_snapshot")
    require(len(u23) == 23 and base7.intersection(post7) == u23, "E_BOOTSTRAP_PHASE_INTERSECTION", "materialized base/post intersection is not byte-identical U23")
    require(not base7.intersection(patch7) and not post7.intersection(patch7), "E_BOOTSTRAP_PHASE_INTERSECTION", "materialized patch intersection is non-empty")
    require(len(base7.union(post7, patch7)) == 92, "E_BOOTSTRAP_PHASE_INTERSECTION", "materialized unique seven-key set is not 92")
    pairs = {(item.input_role, item.source_path) for item in tuple(base) + tuple(post) + tuple(patch)}
    require(len(pairs) == 92 and len(pairs.union((item.input_role, item.source_path) for item in fixed)) == 96, "E_FILE_INPUT_PROJECTION", "materialized 92/96 projection differs")


def validate_bootstrap_manifest_arrays(document: Mapping[str, Any], build: BootstrapBuild) -> None:
    """Reject count-preserving substitutions in a caller-supplied bundle manifest."""

    mapping = {
        "base_snapshot_items": build.base,
        "postimage_candidate_items": build.post,
        "patch_items": build.patch,
    }
    for key, expected in mapping.items():
        actual = document.get(key)
        require(isinstance(actual, list), "E_JSON_TYPE", "%s is not an array" % key)
        require(all(isinstance(item, dict) for item in actual), "E_JSON_TYPE", "%s contains a non-object" % key)
        actual7 = set()
        for item in actual:
            exact = (item.get("input_role"), item.get("source_path"), item.get("logical_target_path"), item.get("preimage_state"), item.get("raw_sha256"), item.get("canonical_domain_tag"), item.get("canonical_sha256"))
            actual7.add(exact)
        require(len(actual7) == len(actual), "E_BOOTSTRAP_ITEM_IDENTITY", "%s contains a duplicate" % key)
        require(actual7 == set(item.identity7 for item in expected), "E_REQUIRED_SET", "%s is not set-equal to the frozen builder" % key)


def validate_contract_file_inputs(actual_pairs: Iterable[Tuple[str, str]], build: BootstrapBuild) -> None:
    actual = tuple(actual_pairs)
    require(all(isinstance(pair, tuple) and len(pair) == 2 and all(isinstance(value, str) and value for value in pair) for pair in actual), "E_FILE_INPUT_PROJECTION", "file-input role/path pair is malformed")
    require(len(actual) == len(set(actual)), "E_FILE_INPUT_PROJECTION", "file-input role/path pair is duplicated")
    require(set(actual) == set(build.contract_file_inputs) and len(actual) == 96, "E_FILE_INPUT_PROJECTION", "transaction file inputs are not bidirectionally set-equal to the 96-row projection", {"missing": sorted(set(build.contract_file_inputs) - set(actual)), "extra": sorted(set(actual) - set(build.contract_file_inputs))})
