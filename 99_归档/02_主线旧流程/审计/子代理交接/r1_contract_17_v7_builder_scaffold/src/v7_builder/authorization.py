"""V7 authorization identity comparisons against existing manifest keys."""

from typing import Any, Mapping, Sequence, Tuple

from .errors import require


AUTHORIZATION_IDENTITY_KEYS: Tuple[str, ...] = (
    "transaction_id",
    "work_package_id",
    "scope_id",
    "card_object_id",
)
TRANSACTION_IDENTITY_KEYS: Tuple[str, ...] = ("transaction_id",)
COVERAGE_IDENTITY_KEYS: Tuple[str, ...] = (
    "work_package_id",
    "scope_id",
    "card_object_id",
)


def _require_string_keys(mapping: Mapping[str, Any], keys: Sequence[str], artifact: str) -> None:
    for key in keys:
        require(key in mapping, "E_JSON_KEY", "%s is missing an identity key" % artifact, {"key": key})
        require(
            isinstance(mapping[key], str) and bool(mapping[key]),
            "E_AUTHORIZATION_IDENTITY_BINDING",
            "%s identity value must be a non-empty string" % artifact,
            {"key": key},
        )


def validate_authorization_identity(
    authorization: Mapping[str, Any],
    transaction_manifest: Mapping[str, Any],
    coverage_manifest: Mapping[str, Any],
) -> None:
    """Apply exactly the two v7 identity equalities.

    The function also rejects schema expansion across the manifest boundary:
    coverage has no transaction ID, while transaction manifest has none of the
    coverage triple.  This prevents a caller from making an invalid comparison
    pass by injecting keys that the frozen schemas do not define.
    """

    _require_string_keys(authorization, AUTHORIZATION_IDENTITY_KEYS, "authorization")
    _require_string_keys(transaction_manifest, TRANSACTION_IDENTITY_KEYS, "transaction manifest")
    _require_string_keys(coverage_manifest, COVERAGE_IDENTITY_KEYS, "coverage manifest")
    require(
        "transaction_id" not in coverage_manifest,
        "E_JSON_KEY",
        "coverage manifest must not be extended with transaction_id",
    )
    for key in COVERAGE_IDENTITY_KEYS:
        require(
            key not in transaction_manifest,
            "E_JSON_KEY",
            "transaction manifest must not be extended with coverage identity keys",
            {"key": key},
        )
    require(
        authorization["transaction_id"] == transaction_manifest["transaction_id"],
        "E_AUTHORIZATION_IDENTITY_BINDING",
        "authorization transaction_id does not match transaction manifest",
    )
    auth_coverage = tuple(authorization[key] for key in COVERAGE_IDENTITY_KEYS)
    manifest_coverage = tuple(coverage_manifest[key] for key in COVERAGE_IDENTITY_KEYS)
    require(
        auth_coverage == manifest_coverage,
        "E_AUTHORIZATION_IDENTITY_BINDING",
        "authorization coverage identity triple does not match coverage manifest",
    )

