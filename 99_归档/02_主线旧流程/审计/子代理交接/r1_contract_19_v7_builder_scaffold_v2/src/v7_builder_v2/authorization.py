"""Authorization identity, principal, and one-way approval binding checks."""

from dataclasses import dataclass
from datetime import date
from typing import Any, Mapping, Sequence, Tuple

from .canonical import canonical_json_bytes, framed_sha256, require_exact_keys
from .errors import require
from .principals import validate_independent_principals, validate_principal_id


AUTHORIZATION_KEYS: Tuple[str, ...] = (
    "authorization_contract_version", "authorization_id", "transaction_id", "work_package_id",
    "scope_id", "card_object_id", "table_operation_items", "payload_items", "prepared_by",
    "prepared_date", "reviewed_by", "reviewed_date", "review_status", "notes",
)
APPROVAL_KEYS: Tuple[str, ...] = (
    "approval_contract_version", "approval_id", "artifact_kind", "artifact_id",
    "artifact_canonical_sha256", "approved_by", "approved_date", "approval_status", "notes",
)
IDENTITY_FIELDS = ("transaction_id", "work_package_id", "scope_id", "card_object_id")
_AUTHORIZATION_SEAL = object()


@dataclass(frozen=True)
class AuthorizationGrant:
    transaction_id: str
    work_package_id: str
    scope_id: str
    card_object_id: str
    authorization_id: str
    canonical_sha256: str
    _seal: object = None


def require_authorization_grant(grant: object, transaction_id: str, scope_id: str, card_object_id: str) -> AuthorizationGrant:
    require(isinstance(grant, AuthorizationGrant) and grant._seal is _AUTHORIZATION_SEAL, "E_APPROVAL_BINDING", "mapping plan requires a validated authorization grant")
    assert isinstance(grant, AuthorizationGrant)
    require((grant.transaction_id, grant.scope_id, grant.card_object_id) == (transaction_id, scope_id, card_object_id), "E_AUTHORIZATION_IDENTITY", "authorization grant identity differs from mapping plan")
    return grant


def _date(value: Any, field: str) -> date:
    require(isinstance(value, str), "E_DATE", "%s must be an ISO date" % field)
    try:
        parsed = date.fromisoformat(value)
    except (TypeError, ValueError):
        require(False, "E_DATE", "%s must be an ISO date" % field)
    require(parsed.isoformat() == value, "E_DATE", "%s is not canonical YYYY-MM-DD" % field)
    return parsed


def _require_same_identity(reference: Mapping[str, Any], candidate: Mapping[str, Any], label: str) -> None:
    for field in IDENTITY_FIELDS:
        require(reference.get(field) == candidate.get(field), "E_AUTHORIZATION_IDENTITY", "%s %s differs" % (label, field), {"expected": reference.get(field), "actual": candidate.get(field)})


def validate_authorization_binding(
    authorization: Mapping[str, Any],
    approval: Mapping[str, Any],
    coverage_manifest: Mapping[str, Any],
    transaction_manifest: Mapping[str, Any],
    expected_table_operation_items: Sequence[Mapping[str, Any]],
    expected_payload_items: Sequence[Mapping[str, Any]],
) -> AuthorizationGrant:
    require_exact_keys(authorization, AUTHORIZATION_KEYS)
    require_exact_keys(approval, APPROVAL_KEYS)
    require(authorization["authorization_contract_version"] == "CHIP-OPERATION-AUTHORIZATION-V1", "E_APPROVAL_BINDING", "authorization version differs")
    require(authorization["review_status"] == "reviewed", "E_APPROVAL_BINDING", "authorization is not reviewed")
    for document, label in ((coverage_manifest, "coverage manifest"), (transaction_manifest, "transaction manifest")):
        _require_same_identity(authorization, document, label)
    require(list(authorization["table_operation_items"]) == list(expected_table_operation_items), "E_AUTHORIZATION_ITEM_SET", "authorized operation items differ from transaction operations")
    require(list(authorization["payload_items"]) == list(expected_payload_items), "E_AUTHORIZATION_ITEM_SET", "authorized payload items differ from transaction payloads")
    prepared = validate_principal_id(authorization["prepared_by"], "prepared_by")
    reviewed = validate_principal_id(authorization["reviewed_by"], "reviewed_by")
    require(prepared.casefold() != reviewed.casefold(), "E_PRINCIPAL_COLLISION", "authorization preparer/reviewer collide")
    require(_date(authorization["reviewed_date"], "reviewed_date") >= _date(authorization["prepared_date"], "prepared_date"), "E_DATE", "authorization review predates preparation")
    canonical_hash = framed_sha256("chip-operation-payload-authorization-v1", canonical_json_bytes(authorization))
    require(approval["approval_contract_version"] == "ARTIFACT-APPROVAL-V1" and approval["artifact_kind"] == "chip_operation_payload_authorization", "E_APPROVAL_BINDING", "authorization approval kind/version differs")
    require(approval["artifact_id"] == authorization["authorization_id"] and approval["artifact_canonical_sha256"] == canonical_hash, "E_APPROVAL_BINDING", "authorization approval artifact ID/hash differs")
    validate_independent_principals({"prepared_by": prepared, "reviewed_by": reviewed, "approved_by": approval["approved_by"]})
    require(_date(approval["approved_date"], "approved_date") >= _date(authorization["reviewed_date"], "reviewed_date"), "E_DATE", "authorization approval predates review")
    require(approval["approval_status"] == "approved", "E_APPROVAL_BINDING", "authorization approval status differs")
    return AuthorizationGrant(
        authorization["transaction_id"], authorization["work_package_id"],
        authorization["scope_id"], authorization["card_object_id"],
        authorization["authorization_id"], canonical_hash, _AUTHORIZATION_SEAL,
    )
