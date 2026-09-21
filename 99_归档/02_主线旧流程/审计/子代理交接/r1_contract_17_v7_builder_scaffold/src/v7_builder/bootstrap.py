"""Bootstrap membership schema and v7 set/projection validation."""

import re
from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

from .errors import ContractV7Error, require


EXPECTED_UNCHANGED_PATHS: Tuple[str, ...] = (
    "数据/components.csv",
    "数据/condition-sets.csv",
    "数据/derived-inputs.csv",
    "数据/derived-metrics.csv",
    "数据/facts.csv",
    "数据/field-requirements.csv",
    "数据/links.csv",
    "数据/memory-levels.csv",
    "数据/object-relations.csv",
    "数据/precision-paths.csv",
    "数据/special-capabilities.csv",
    "数据/topologies.csv",
    "数据/vendors.csv",
    "最小参考资料库/conflict-groups.csv",
    "最小参考资料库/conflict-members.csv",
    "最小参考资料库/selection-members.csv",
    "最小参考资料库/selection-runs.csv",
    "最小参考资料库/source-coverage.csv",
    "最小参考资料库/source-endpoints.csv",
    "最小参考资料库/source-families.csv",
    "最小参考资料库/sources.csv",
    "最小参考资料库/source-screening.csv",
    "最小参考资料库/source-selected-roles.csv",
)


@dataclass(frozen=True)
class BootstrapItem:
    input_role: str
    source_path: str
    logical_target_path: str
    preimage_state: str
    raw_sha256: str
    canonical_domain_tag: Optional[str]
    canonical_sha256: Optional[str]

    @property
    def identity7(self) -> Tuple[object, ...]:
        return (
            self.input_role,
            self.source_path,
            self.logical_target_path,
            self.preimage_state,
            self.raw_sha256,
            self.canonical_domain_tag,
            self.canonical_sha256,
        )

    @property
    def locator3(self) -> Tuple[str, str, str]:
        return self.input_role, self.source_path, self.logical_target_path

    @property
    def role_source2(self) -> Tuple[str, str]:
        return self.input_role, self.source_path


@dataclass(frozen=True)
class BootstrapProjection:
    base_count: int
    post_count: int
    patch_count: int
    unchanged_intersection_count: int
    unique_identity_count: int
    projected_bootstrap_input_count: int
    contract_file_input_count: int
    contract_file_inputs: Tuple[Tuple[str, str], ...]


SHA256_RE = re.compile(r"[0-9a-f]{64}\Z")


def _safe_path(value: str) -> bool:
    if not isinstance(value, str) or not value or "\\" in value or "\x00" in value:
        return False
    path = PurePosixPath(value)
    return not path.is_absolute() and all(part not in ("", ".", "..") for part in path.parts)


def _item_sort_key(item: BootstrapItem) -> Tuple[bytes, bytes, bytes]:
    return (
        item.input_role.encode("utf-8"),
        item.source_path.encode("utf-8"),
        item.logical_target_path.encode("utf-8"),
    )


def _validate_item_schema(item: BootstrapItem, array_name: str) -> None:
    require(isinstance(item.input_role, str) and bool(item.input_role), "E_JSON_TYPE", "bootstrap input_role is empty")
    require(_safe_path(item.source_path) and _safe_path(item.logical_target_path), "E_PATH", "bootstrap item path is unsafe")
    require(item.preimage_state in ("present", "absent"), "E_JSON_TYPE", "bootstrap preimage_state is invalid")
    require(bool(SHA256_RE.fullmatch(item.raw_sha256)), "E_SHA256", "bootstrap raw SHA-256 is invalid")
    canonical_null = item.canonical_domain_tag is None and item.canonical_sha256 is None
    canonical_present = (
        isinstance(item.canonical_domain_tag, str)
        and bool(item.canonical_domain_tag)
        and isinstance(item.canonical_sha256, str)
        and bool(SHA256_RE.fullmatch(item.canonical_sha256))
    )
    require(canonical_null or canonical_present, "E_CANONICAL_NULL", "canonical domain/hash must both be null or both be present")
    controlled = PurePosixPath(item.logical_target_path).suffix.lower() in (".csv", ".json")
    require(
        canonical_present if controlled else canonical_null,
        "E_CANONICAL_NULL",
        "controlled CSV/JSON needs canonical values; raw-only item needs null canonical values",
        {"array": array_name, "logical_target_path": item.logical_target_path},
    )


def _validate_array(items: Sequence[BootstrapItem], array_name: str) -> None:
    for item in items:
        _validate_item_schema(item, array_name)
    require(
        list(items) == sorted(items, key=_item_sort_key),
        "E_JSON_ORDER",
        "bootstrap array is not sorted by role/source/logical UTF-8 bytes",
        {"array": array_name},
    )
    identities = [item.identity7 for item in items]
    locators = [item.locator3 for item in items]
    require(
        len(identities) == len(set(identities)),
        "E_BOOTSTRAP_ITEM_IDENTITY",
        "duplicate seven-key identity inside bootstrap array",
        {"array": array_name},
    )
    require(
        len(locators) == len(set(locators)),
        "E_BOOTSTRAP_ITEM_IDENTITY",
        "same locator reports multiple identities inside bootstrap array",
        {"array": array_name},
    )


def validate_bootstrap_membership(
    base_items: Sequence[BootstrapItem],
    post_items: Sequence[BootstrapItem],
    patch_items: Sequence[BootstrapItem],
    fixed_inputs: Sequence[Tuple[str, str]],
) -> BootstrapProjection:
    require(
        (len(base_items), len(post_items), len(patch_items)) == (45, 58, 12),
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "bootstrap membership counts must be 45/58/12",
    )
    _validate_array(base_items, "base_snapshot_items")
    _validate_array(post_items, "postimage_candidate_items")
    _validate_array(patch_items, "patch_items")
    base = {item.identity7: item for item in base_items}
    post = {item.identity7: item for item in post_items}
    patch = {item.identity7: item for item in patch_items}
    base_post = set(base).intersection(post)
    require(
        len(base_post) == 23,
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "base/post intersection must contain exactly U23",
        {"actual_count": len(base_post)},
    )
    intersection_items = [base[identity] for identity in base_post]
    require(
        {item.input_role for item in intersection_items} == {"managed_unchanged_snapshot"}
        and {item.logical_target_path for item in intersection_items}
        == set(EXPECTED_UNCHANGED_PATHS),
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "base/post intersection is not the exact unchanged-table set",
    )
    require(
        not set(base).intersection(patch) and not set(post).intersection(patch),
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "patch membership intersects base or post membership",
    )
    base_only = [item for identity, item in base.items() if identity not in base_post]
    post_only = [item for identity, item in post.items() if identity not in base_post]
    require(
        sum(item.input_role == "managed_base_snapshot" for item in base_only) == 20
        and sum(item.input_role.startswith("source_pool_prerequisite_") for item in base_only) == 2,
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "base-only membership is not 20 managed base plus two prerequisites",
    )
    require(
        sum(item.input_role == "managed_postimage_snapshot" for item in post_only) == 22
        and len(post_only) == 35,
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "post-only membership is not 22 managed post plus 13 candidates",
    )
    require(
        all(item.input_role == "managed_patch" for item in patch_items),
        "E_BOOTSTRAP_PHASE_INTERSECTION",
        "patch array must contain exactly managed_patch items",
    )
    identity_union: Dict[Tuple[object, ...], BootstrapItem] = {}
    for item in list(base_items) + list(post_items) + list(patch_items):
        identity_union[item.identity7] = item
    require(len(identity_union) == 92, "E_BOOTSTRAP_PHASE_INTERSECTION", "unique identity count must be 92")
    projected: Dict[Tuple[str, str], Tuple[object, ...]] = {}
    for identity, item in identity_union.items():
        pair = item.role_source2
        if pair in projected and projected[pair] != identity:
            raise ContractV7Error(
                "E_FILE_INPUT_PROJECTION",
                "different identities project to the same role/source pair",
                {"input_role": pair[0], "source_path": pair[1]},
            )
        projected[pair] = identity
    require(len(projected) == 92, "E_FILE_INPUT_PROJECTION", "bootstrap projection must have 92 rows")
    require(len(fixed_inputs) == 4 and len(set(fixed_inputs)) == 4, "E_REQUIRED_SET", "four fixed inputs required")
    required_fixed_roles = {
        "contract_design",
        "scope_freeze_archive",
        "bootstrap_bundle_manifest",
        "bootstrap_bundle_approval",
    }
    require(
        {role for role, _ in fixed_inputs} == required_fixed_roles,
        "E_REQUIRED_SET",
        "fixed bootstrap input roles drifted",
    )
    contract_inputs = set(projected).union(fixed_inputs)
    require(len(contract_inputs) == 96, "E_FILE_INPUT_PROJECTION", "contract file-input count must be 96")
    return BootstrapProjection(
        base_count=len(base_items),
        post_count=len(post_items),
        patch_count=len(patch_items),
        unchanged_intersection_count=len(base_post),
        unique_identity_count=len(identity_union),
        projected_bootstrap_input_count=len(projected),
        contract_file_input_count=len(contract_inputs),
        contract_file_inputs=tuple(sorted(contract_inputs, key=lambda item: (item[0].encode("utf-8"), item[1].encode("utf-8")))),
    )
