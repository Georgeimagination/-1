"""Exact 35-role chip base and append-only 37/38 scope-mapping transaction plans."""

from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

from .errors import ContractV7Error, require


RolePath = Tuple[str, str]
ACTIVE_V7_DESIGN: RolePath = ("contract_design", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md")
V6_DESIGN: RolePath = ("contract_design", "审计/子代理交接/r1_ga100_36_contract_repair_design_v6.md")
MAPPING_STABLE_PAIR: RolePath = ("scope_mapping_registry", "审计/合同注册表/scope-object-mapping.csv")

_STABLE_BASE_28: Tuple[RolePath, ...] = (
    ACTIVE_V7_DESIGN,
    ("coverage_policy", "审计/合同注册表/coverage-policy-v5.0.json"),
    ("coverage_policy_approval", "审计/合同注册表/coverage-policy-v5.0-approval.json"),
    ("source_date_policy", "审计/合同注册表/source-date-policy-v3.0.csv"),
    ("source_date_policy_approval", "审计/合同注册表/source-date-policy-approval.json"),
    ("legacy_requirement_registry", "审计/合同注册表/legacy-requirement-disposition.csv"),
    ("legacy_requirement_registry_approval", "审计/合同注册表/legacy-requirement-disposition-approval.json"),
    ("legacy_reconciliation_registry", "审计/合同注册表/legacy-requirement-reconciliation-events.csv"),
    ("active_scope_list", "清单/训练与推理芯片名单.md"),
    ("scope_allocation_registry", "审计/合同注册表/scope-id-registry.csv"),
    MAPPING_STABLE_PAIR,
    ("schema_registry", "数据/schema-columns.csv"), ("enum_registry", "数据/enums.csv"),
    ("field_registry", "数据/fields.csv"), ("data_validator", "scripts/validation/Validate-ResearchData.ps1"),
    ("scope_validator", "scripts/validation/Test-ChipScope.ps1"),
    ("source_pool_validator", "scripts/validation/Test-SourcePool.ps1"),
    ("recovery_validator", "scripts/validation/verify_recovery_paths.py"),
    ("card_template", "资料卡/模板.md"), ("field_dictionary", "资料卡/字段字典.md"),
    ("project_readme", "README.md"), ("project_agents", "AGENTS.md"),
    ("research_plan", "研究计划.md"), ("current_status", "进度/当前状态.md"),
    ("canonical_fixture_manifest", "审计/合同注册表/canonical-fixture-manifest.json"),
    ("canonical_fixtures", "审计/合同注册表/canonical-fixtures.csv"),
    ("canonical_runtime_results", "审计/合同注册表/canonical-runtime-results.csv"),
    ("formula_evaluator_spec", "审计/合同注册表/formula-evaluator-v1.json"),
)


def _transaction_prefix(transaction_id: str) -> str:
    require(isinstance(transaction_id, str) and bool(transaction_id) and "/" not in transaction_id and "\\" not in transaction_id, "E_TRANSACTION_ID", "transaction ID is unsafe")
    return "审计/事务/%s" % transaction_id


def _sort(pairs: Iterable[RolePath]) -> Tuple[RolePath, ...]:
    values = tuple(pairs)
    require(all(isinstance(pair, tuple) and len(pair) == 2 and isinstance(pair[0], str) and isinstance(pair[1], str) and pair[0] and pair[1] for pair in values), "E_REQUIRED_SET", "role/path pair is malformed")
    require(len(set(values)) == len(values), "E_REQUIRED_SET", "role/path pair is duplicated")
    return tuple(sorted(values, key=lambda pair: (pair[0].encode("utf-8"), pair[1].encode("utf-8"))))


def build_base_chip_role_path_set_v7(transaction_id: str) -> Tuple[RolePath, ...]:
    prefix = _transaction_prefix(transaction_id)
    coverage = (
        ("coverage_manifest", "%s/coverage/coverage-manifest.json" % prefix),
        ("coverage_approval", "%s/coverage/independent-approval.json" % prefix),
        ("coverage_targets", "%s/coverage/coverage-targets.csv" % prefix),
        ("factor_target_candidates", "%s/coverage/factor-target-candidates.csv" % prefix),
        ("reachable_target_bindings", "%s/coverage/reachable-target-bindings.csv" % prefix),
        ("coverage_fields", "%s/coverage/coverage-fields.csv" % prefix),
        ("coverage_exclusion_reviews", "%s/coverage/coverage-exclusion-review.csv" % prefix),
    )
    result = _sort(_STABLE_BASE_28 + coverage)
    require(len(result) == 35 and ACTIVE_V7_DESIGN in result and V6_DESIGN not in result, "E_REQUIRED_SET", "BaseChipRolePathSetV7 must be the exact v7-replaced 35-pair set")
    require(MAPPING_STABLE_PAIR in result, "E_REQUIRED_SET", "stable scope mapping pair is absent")
    return result


def authorization_pairs(transaction_id: str) -> Tuple[RolePath, ...]:
    prefix = _transaction_prefix(transaction_id)
    return _sort((
        ("chip_operation_authorization", "%s/authorization/chip-operation-payload-authorization.json" % prefix),
        ("chip_operation_authorization_approval", "%s/authorization/chip-operation-payload-authorization-approval.json" % prefix),
    ))


def mapping_snapshot_pairs(transaction_id: str) -> Tuple[RolePath, RolePath]:
    prefix = _transaction_prefix(transaction_id)
    target = "审计/合同注册表/scope-object-mapping.csv"
    return (
        ("managed_base_snapshot", "%s/inputs/base/%s" % (prefix, target)),
        ("managed_postimage_snapshot", "%s/inputs/post/%s" % (prefix, target)),
    )


@dataclass(frozen=True)
class ScopeAllocation:
    scope_allocation_id: str
    freeze_row_id: str
    scope_id: str
    allocation_state: str
    approval_status: str


@dataclass(frozen=True)
class MappingEvent:
    mapping_event_id: str
    freeze_row_id: str
    scope_id: str
    mapping_event_seq: int
    formal_object_id: str
    proposed_formal_object_id: str
    mapping_status: str
    mapping_basis: str
    approval_status: str

    @property
    def immutable_tuple(self) -> Tuple[object, ...]:
        return (self.mapping_event_id, self.freeze_row_id, self.scope_id, self.mapping_event_seq, self.formal_object_id, self.proposed_formal_object_id, self.mapping_status, self.mapping_basis, self.approval_status)


@dataclass(frozen=True)
class MappingBranch:
    name: str
    required_pairs: Tuple[RolePath, ...]
    required_input_count: int
    effective_tip: MappingEvent
    next_seq: Optional[int]


@dataclass(frozen=True)
class ObjectInsertContract:
    transaction_id: str
    object_id: str
    scope_id: str
    object_type: str
    operation_kind: str


@dataclass(frozen=True)
class IdentityCompletenessInsertContract:
    transaction_id: str
    object_id: str
    scope_id: str
    completeness_domain: str
    card_lifecycle: str
    operation_kind: str


@dataclass(frozen=True)
class MappingTransactionPlan:
    transaction_id: str
    branch: MappingBranch
    allocation: ScopeAllocation
    object_insert: ObjectInsertContract
    identity_insert: IdentityCompletenessInsertContract
    mapping_insert: MappingEvent
    authorization_canonical_sha256: str
    base_history: Tuple[MappingEvent, ...]
    post_history: Tuple[MappingEvent, ...]


def validate_scope_allocations(allocations: Sequence[ScopeAllocation]) -> None:
    require(allocations, "E_SCOPE_ALLOCATION", "scope allocation registry is empty")
    allocation_ids = [item.scope_allocation_id for item in allocations]
    scopes = [item.scope_id for item in allocations]
    freezes = [item.freeze_row_id for item in allocations if item.freeze_row_id]
    require(len(allocation_ids) == len(set(allocation_ids)) and len(scopes) == len(set(scopes)) and len(freezes) == len(set(freezes)), "E_SCOPE_ALLOCATION", "allocation identity/scope/freeze is duplicated")


def _allocation_for(allocations: Sequence[ScopeAllocation], freeze_row_id: str, scope_id: str) -> ScopeAllocation:
    validate_scope_allocations(allocations)
    matches = [item for item in allocations if item.freeze_row_id == freeze_row_id and item.scope_id == scope_id and item.allocation_state == "active" and item.approval_status == "approved"]
    require(len(matches) == 1, "E_SCOPE_ALLOCATION", "freeze/scope must have exactly one active approved allocation")
    return matches[0]


def validate_mapping_history(history: Sequence[MappingEvent], allocations: Sequence[ScopeAllocation]) -> None:
    require(history, "E_SCOPE_MAPPING_LIFECYCLE", "mapping history is empty")
    ids = [item.mapping_event_id for item in history]
    identities = [(item.scope_id, item.mapping_event_seq) for item in history]
    require(len(ids) == len(set(ids)) and len(identities) == len(set(identities)), "E_SCOPE_MAPPING_LIFECYCLE", "mapping event ID or scope/seq is duplicated")
    by_scope: Dict[str, List[MappingEvent]] = {}
    for event in history:
        require(isinstance(event.mapping_event_seq, int) and not isinstance(event.mapping_event_seq, bool) and event.mapping_event_seq >= 1, "E_SCOPE_MAPPING_LIFECYCLE", "mapping seq is not positive integer")
        by_scope.setdefault(event.scope_id, []).append(event)
        if event.freeze_row_id:
            _allocation_for(allocations, event.freeze_row_id, event.scope_id)
    for scope_id, rows in by_scope.items():
        observed = sorted(item.mapping_event_seq for item in rows)
        require(observed == list(range(1, max(observed) + 1)), "E_SCOPE_MAPPING_LIFECYCLE", "mapping seq is not continuous from one", {"scope_id": scope_id})


def effective_tip(history: Sequence[MappingEvent], allocations: Sequence[ScopeAllocation], scope_id: str) -> Tuple[MappingEvent, int]:
    validate_mapping_history(history, allocations)
    scoped = [item for item in history if item.scope_id == scope_id]
    require(scoped, "E_SCOPE_MAPPING_LIFECYCLE", "scope has no mapping history")
    effective = [item for item in scoped if item.approval_status != "rejected"]
    require(effective, "E_SCOPE_MAPPING_LIFECYCLE", "scope has no non-rejected event")
    return max(effective, key=lambda item: item.mapping_event_seq), max(item.mapping_event_seq for item in scoped) + 1


def choose_chip_mapping_branch(history: Sequence[MappingEvent], allocations: Sequence[ScopeAllocation], scope_id: str, card_object_id: str, transaction_id: str) -> MappingBranch:
    require(scope_id and card_object_id, "E_SCOPE_MAPPING_TRANSITION", "scope/card object IDs are required")
    base35 = set(build_base_chip_role_path_set_v7(transaction_id))
    common34 = base35 - {MAPPING_STABLE_PAIR}
    require(len(common34) == 34, "E_REQUIRED_SET", "mechanical CommonChipBase34 differs")
    tip, next_seq = effective_tip(history, allocations, scope_id)
    if tip.mapping_status == "mapped" and tip.approval_status == "approved":
        require(tip.formal_object_id == card_object_id and tip.proposed_formal_object_id == "", "E_SCOPE_MAPPING_TRANSITION", "approved mapped tip resolves to another card")
        required = _sort(tuple(common34) + (MAPPING_STABLE_PAIR,) + authorization_pairs(transaction_id))
        require(len(required) == 37, "E_REQUIRED_SET", "no-change role/path set must contain 37 pairs")
        return MappingBranch("NO_MAPPING_CHANGE", required, 37, tip, None)
    if tip.mapping_status in ("pending_formal_object_create", "pending_identity_review"):
        require(tip.formal_object_id == "" and tip.proposed_formal_object_id == card_object_id and tip.approval_status == "needs_resolution", "E_SCOPE_MAPPING_TRANSITION", "pending tip cannot resolve to the requested card")
    elif tip.mapping_status == "unmapped":
        require(tip.formal_object_id == "" and tip.proposed_formal_object_id == "" and tip.approval_status == "approved", "E_SCOPE_MAPPING_TRANSITION", "unmapped tip has invalid shape")
    else:
        raise ContractV7Error("E_SCOPE_MAPPING_TRANSITION", "tip cannot enter the mapping override branch")
    required = _sort(tuple(common34) + mapping_snapshot_pairs(transaction_id) + authorization_pairs(transaction_id))
    require(len(required) == 38 and MAPPING_STABLE_PAIR not in required, "E_REQUIRED_SET", "override role/path set must contain exact 38 pairs")
    return MappingBranch("MAPPING_OVERRIDE", required, 38, tip, next_seq)


def validate_branch_inputs(branch: MappingBranch, actual_pairs: Iterable[RolePath]) -> None:
    actual = _sort(actual_pairs)
    require(actual == branch.required_pairs, "E_REQUIRED_SET", "actual chip inputs are not set-equal to the selected branch", {"expected_count": branch.required_input_count, "actual_count": len(actual)})


def build_mapping_override_transaction(history: Sequence[MappingEvent], allocations: Sequence[ScopeAllocation], scope_id: str, card_object_id: str, transaction_id: str, authorization_grant: object) -> MappingTransactionPlan:
    from .authorization import require_authorization_grant

    grant = require_authorization_grant(authorization_grant, transaction_id, scope_id, card_object_id)
    branch = choose_chip_mapping_branch(history, allocations, scope_id, card_object_id, transaction_id)
    require(branch.name == "MAPPING_OVERRIDE" and branch.next_seq is not None, "E_SCOPE_MAPPING_TRANSITION", "object/mapping insert constructor only applies to override")
    tip = branch.effective_tip
    require(bool(tip.freeze_row_id), "E_SCOPE_ALLOCATION", "override tip must carry freeze_row_id")
    allocation = _allocation_for(allocations, tip.freeze_row_id, scope_id)
    seq = branch.next_seq
    event = MappingEvent("MAPEV-%s-%04d" % (scope_id, seq), tip.freeze_row_id, scope_id, seq, card_object_id, "", "mapped", "chip_identity_mapping_approved_v1", "approved")
    object_insert = ObjectInsertContract(transaction_id, card_object_id, scope_id, "die", "insert")
    identity_insert = IdentityCompletenessInsertContract(transaction_id, card_object_id, scope_id, "identity", "provisional", "insert")
    post = tuple(sorted(tuple(history) + (event,), key=lambda item: (item.scope_id.encode("utf-8"), item.mapping_event_seq, item.mapping_event_id.encode("utf-8"))))
    plan = MappingTransactionPlan(transaction_id, branch, allocation, object_insert, identity_insert, event, grant.canonical_sha256, tuple(history), post)
    validate_mapping_transaction_plan(plan, allocations)
    return plan


def validate_mapping_postimage(base: Sequence[MappingEvent], post: Sequence[MappingEvent]) -> None:
    require(len(post) == len(base) + 1, "E_OLD_ROW_MUTATION", "mapping postimage must append exactly one row")
    post_by_id = {item.mapping_event_id: item for item in post}
    require(len(post_by_id) == len(post), "E_SCOPE_MAPPING_LIFECYCLE", "postimage mapping ID is duplicated")
    for old in base:
        require(old.mapping_event_id in post_by_id and post_by_id[old.mapping_event_id].immutable_tuple == old.immutable_tuple, "E_OLD_ROW_MUTATION", "an old mapping row changed or disappeared", {"mapping_event_id": old.mapping_event_id})
    new_ids = set(post_by_id) - {item.mapping_event_id for item in base}
    require(len(new_ids) == 1, "E_SCOPE_MAPPING_LIFECYCLE", "mapping postimage must contain exactly one new event ID")


def validate_mapping_transaction_plan(plan: MappingTransactionPlan, allocations: Sequence[ScopeAllocation]) -> None:
    validate_mapping_postimage(plan.base_history, plan.post_history)
    validate_mapping_history(plan.post_history, allocations)
    transaction_ids = {plan.transaction_id, plan.object_insert.transaction_id, plan.identity_insert.transaction_id}
    require(len(transaction_ids) == 1, "E_TRANSACTION_CLOSURE", "object/identity/mapping plan does not share one transaction")
    object_ids = {plan.object_insert.object_id, plan.identity_insert.object_id, plan.mapping_insert.formal_object_id}
    scopes = {plan.object_insert.scope_id, plan.identity_insert.scope_id, plan.mapping_insert.scope_id, plan.allocation.scope_id}
    require(len(object_ids) == 1 and len(scopes) == 1, "E_TRANSACTION_CLOSURE", "object/identity/mapping identities do not close in one transaction")
    require(plan.mapping_insert.freeze_row_id == plan.allocation.freeze_row_id, "E_SCOPE_ALLOCATION", "mapping freeze_row_id differs from allocation")
    require(plan.mapping_insert.mapping_event_id == "MAPEV-%s-%04d" % (plan.mapping_insert.scope_id, plan.mapping_insert.mapping_event_seq), "E_SCOPE_MAPPING_LIFECYCLE", "mapping event ID constructor differs")
    require(len(plan.authorization_canonical_sha256) == 64, "E_APPROVAL_BINDING", "mapping plan is not bound to authorization bytes")
