"""Pure scope-mapping branch selection for the v7 37/38 contracts."""

from dataclasses import dataclass
from typing import Iterable, Mapping, Optional, Sequence, Tuple

from .errors import ContractV7Error, require


RolePath = Tuple[str, str]

MAPPING_STABLE_PAIR: RolePath = (
    "scope_mapping_registry",
    "审计/合同注册表/scope-object-mapping.csv",
)
MAPPING_BASE_SNAPSHOT_PAIR: RolePath = (
    "managed_base_snapshot",
    "T/inputs/base/审计/合同注册表/scope-object-mapping.csv",
)
MAPPING_POST_SNAPSHOT_PAIR: RolePath = (
    "managed_postimage_snapshot",
    "T/inputs/post/审计/合同注册表/scope-object-mapping.csv",
)
AUTHORIZATION_PAIRS: Tuple[RolePath, ...] = (
    (
        "chip_operation_authorization",
        "T/authorization/chip-operation-payload-authorization.json",
    ),
    (
        "chip_operation_authorization_approval",
        "T/authorization/chip-operation-payload-authorization-approval.json",
    ),
)


@dataclass(frozen=True)
class MappingEvent:
    """Only the immutable semantic fields needed to select a branch.

    Reviewer and date are intentionally absent.  This scaffold never invents
    an approval identity or an audit date; a later authorized materializer must
    bind those fields from an independently approved authorization artifact.
    """

    freeze_row_id: str
    scope_id: str
    mapping_event_seq: int
    formal_object_id: str
    proposed_formal_object_id: str
    mapping_status: str
    approval_status: str


@dataclass(frozen=True)
class MappingBranch:
    name: str
    required_pairs: Tuple[RolePath, ...]
    required_input_count: int
    next_event_seq: Optional[int]
    target_formal_object_id: str
    requires_independent_mapping_authorization: bool


def _pair_sort_key(pair: RolePath) -> Tuple[bytes, bytes]:
    return pair[0].encode("utf-8"), pair[1].encode("utf-8")


def _normalize_pairs(pairs: Iterable[RolePath]) -> Tuple[RolePath, ...]:
    values = tuple(pairs)
    require(
        all(len(pair) == 2 and pair[0] and pair[1] for pair in values),
        "E_REQUIRED_SET",
        "role/path pairs must contain two non-empty strings",
    )
    require(len(set(values)) == len(values), "E_REQUIRED_SET", "role/path pair is duplicated")
    return tuple(sorted(values, key=_pair_sort_key))


def effective_tip(
    history: Sequence[MappingEvent],
    scope_id: str,
) -> Tuple[MappingEvent, int]:
    """Return the highest non-rejected event and the append-only next seq."""

    scoped = [event for event in history if event.scope_id == scope_id]
    require(scoped, "E_SCOPE_MAPPING_LIFECYCLE", "scope mapping history is empty")
    sequences = [event.mapping_event_seq for event in scoped]
    require(
        all(isinstance(value, int) and not isinstance(value, bool) and value >= 1 for value in sequences),
        "E_SCOPE_MAPPING_LIFECYCLE",
        "mapping sequence must be a positive integer",
    )
    require(
        len(sequences) == len(set(sequences)),
        "E_SCOPE_MAPPING_LIFECYCLE",
        "mapping sequence is duplicated",
    )
    require(
        sorted(sequences) == list(range(1, max(sequences) + 1)),
        "E_SCOPE_MAPPING_LIFECYCLE",
        "mapping sequence must be continuous from one",
    )
    non_rejected = [event for event in scoped if event.approval_status != "rejected"]
    require(non_rejected, "E_SCOPE_MAPPING_LIFECYCLE", "scope has no effective non-rejected event")
    tip = max(non_rejected, key=lambda event: event.mapping_event_seq)
    return tip, max(sequences) + 1


def choose_chip_mapping_branch(
    history: Sequence[MappingEvent],
    scope_id: str,
    card_object_id: str,
    common_chip_base_34: Iterable[RolePath],
) -> MappingBranch:
    """Mechanically select the immutable 37- or 38-input branch.

    ``common_chip_base_34`` must already be the approved v7 base set with the
    stable mapping pair removed.  The result contains no operation row and no
    approval metadata; it is a branch and required-input projection only.
    """

    require(scope_id and card_object_id, "E_SCOPE_MAPPING_TRANSITION", "scope/card IDs are required")
    common = _normalize_pairs(common_chip_base_34)
    require(len(common) == 34, "E_REQUIRED_SET", "common chip base must contain 34 pairs")
    forbidden = {
        MAPPING_STABLE_PAIR,
        MAPPING_BASE_SNAPSHOT_PAIR,
        MAPPING_POST_SNAPSHOT_PAIR,
        *AUTHORIZATION_PAIRS,
    }
    require(
        not set(common).intersection(forbidden),
        "E_REQUIRED_SET",
        "common chip base contains a branch-specific pair",
    )
    tip, next_seq = effective_tip(history, scope_id)
    if tip.mapping_status == "mapped" and tip.approval_status == "approved":
        require(
            tip.formal_object_id == card_object_id and tip.proposed_formal_object_id == "",
            "E_SCOPE_MAPPING_TRANSITION",
            "mapped scope does not resolve to the requested card",
        )
        required = _normalize_pairs((*common, MAPPING_STABLE_PAIR, *AUTHORIZATION_PAIRS))
        require(len(required) == 37, "E_REQUIRED_SET", "no-change branch must contain 37 inputs")
        return MappingBranch(
            name="NO_MAPPING_CHANGE",
            required_pairs=required,
            required_input_count=37,
            next_event_seq=None,
            target_formal_object_id=card_object_id,
            requires_independent_mapping_authorization=False,
        )

    if tip.mapping_status in ("pending_formal_object_create", "pending_identity_review"):
        require(
            tip.formal_object_id == ""
            and tip.proposed_formal_object_id == card_object_id
            and tip.approval_status == "needs_resolution",
            "E_SCOPE_MAPPING_TRANSITION",
            "pending mapping cannot be resolved to the requested card",
        )
    elif tip.mapping_status == "unmapped":
        require(
            tip.formal_object_id == ""
            and tip.proposed_formal_object_id == ""
            and tip.approval_status == "approved",
            "E_SCOPE_MAPPING_TRANSITION",
            "unmapped tip has an invalid semantic shape",
        )
    else:
        raise ContractV7Error(
            "E_SCOPE_MAPPING_TRANSITION",
            "effective mapping tip cannot enter the v7 override branch",
            {
                "mapping_status": tip.mapping_status,
                "approval_status": tip.approval_status,
            },
        )

    required = _normalize_pairs(
        (*common, MAPPING_BASE_SNAPSHOT_PAIR, MAPPING_POST_SNAPSHOT_PAIR, *AUTHORIZATION_PAIRS)
    )
    require(len(required) == 38, "E_REQUIRED_SET", "mapping override branch must contain 38 inputs")
    return MappingBranch(
        name="MAPPING_OVERRIDE",
        required_pairs=required,
        required_input_count=38,
        next_event_seq=next_seq,
        target_formal_object_id=card_object_id,
        requires_independent_mapping_authorization=True,
    )


def validate_branch_input_pairs(branch: MappingBranch, actual_pairs: Iterable[RolePath]) -> None:
    actual = _normalize_pairs(actual_pairs)
    require(
        actual == branch.required_pairs,
        "E_REQUIRED_SET",
        "actual chip file inputs do not equal the selected immutable branch",
        {"expected_count": branch.required_input_count, "actual_count": len(actual)},
    )

