"""Fail-closed live preflight for the post-source-pool-113 contract base."""

import csv
import os
import re
from dataclasses import dataclass
from datetime import date
from pathlib import Path, PurePosixPath
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from .canonical import file_sha256, framed_sha256, parse_strict_json_bytes, require_exact_keys
from .errors import ContractV7Error, UpstreamPrerequisiteError, require


EXPECTED_FORMAL_POST_HASHES: Tuple[Tuple[str, str], ...] = (
    (
        "scripts/validation/Test-SourcePool.ps1",
        "c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0",
    ),
    (
        "清单/论文PDF清单.csv",
        "4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab",
    ),
    (
        "清单/汇总统计.json",
        "994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e",
    ),
    (
        "scripts/collect_references.py",
        "2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb",
    ),
    (
        "清单/资料池受控输入/source-pool-input-ledger.json",
        "08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812",
    ),
    (
        "清单/资料池受控输入/frozen-legacy-pdf-manifest.csv",
        "c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27",
    ),
)
CONTROLLED_INPUT_DIRECTORY = "清单/资料池受控输入"
SOURCE_POOL_REVIEW_PATH = "审计/子代理交接/r1_source_pool_113_v4_independent_review.md"
SOURCE_POOL_REVIEW_SHA256 = "6980a2d109e6bf17de2ce47829b1c2063dcefe1a1e323413a818992dc02c5b11"
SOURCE_POOL_OPERATIONS_PATH = "审计/子代理交接/r1_source_pool_113_staging/operations.csv"
SOURCE_POOL_OPERATIONS_SHA256 = "e8bf4895f0d376d355ad0cae507664f9911b23d5ada653ef5626440f07bbc9ea"
PREREQUISITE_DOMAIN = "source-pool-113-prerequisite-v1"

PREREQUISITE_KEYS: Tuple[str, ...] = (
    "prerequisite_contract_version",
    "prerequisite_id",
    "source_pool_contract_review_path",
    "source_pool_contract_review_raw_sha256",
    "source_pool_operations_path",
    "source_pool_operations_raw_sha256",
    "promotion_id",
    "promotion_record_path",
    "promotion_record_raw_sha256",
    "promotion_status",
    "formal_manifest_path",
    "formal_manifest_raw_sha256",
    "formal_manifest_rows",
    "formal_summary_path",
    "formal_summary_raw_sha256",
    "collector_path",
    "collector_raw_sha256",
    "validator_path",
    "validator_raw_sha256",
    "controlled_ledger_path",
    "controlled_ledger_raw_sha256",
    "controlled_frozen_manifest_path",
    "controlled_frozen_manifest_raw_sha256",
    "gate_results",
    "prepared_by",
    "prepared_date",
    "reviewed_by",
    "reviewed_date",
    "review_status",
    "notes",
)
GATE_RESULT_KEYS: Tuple[str, ...] = (
    "gate_seq",
    "gate_id",
    "transcript_path",
    "transcript_raw_sha256",
    "result",
)
APPROVAL_KEYS: Tuple[str, ...] = (
    "approval_contract_version",
    "approval_id",
    "artifact_kind",
    "artifact_id",
    "artifact_canonical_sha256",
    "approved_by",
    "approved_date",
    "approval_status",
    "notes",
)
EXPECTED_GATE_IDS: Tuple[str, ...] = (
    "source_pool",
    "chip_scope",
    "research_data_subject_contract",
)
SHA256_RE = re.compile(r"[0-9a-f]{64}\Z")
ID_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*\Z")


@dataclass(frozen=True)
class PreflightCheck:
    check_id: str
    status: str
    detail: str
    expected: Optional[str] = None
    actual: Optional[str] = None

    def to_dict(self) -> Dict[str, Optional[str]]:
        return {
            "check_id": self.check_id,
            "status": self.status,
            "detail": self.detail,
            "expected": self.expected,
            "actual": self.actual,
        }


@dataclass(frozen=True)
class PreflightReport:
    status: str
    error_code: Optional[str]
    snapshot_candidate_creation_authorized: bool
    checks: Tuple[PreflightCheck, ...]

    def to_dict(self) -> Dict[str, object]:
        return {
            "status": self.status,
            "error_code": self.error_code,
            "snapshot_candidate_creation_authorized": self.snapshot_candidate_creation_authorized,
            "checks": [check.to_dict() for check in self.checks],
        }


def _parse_date(value: Any, field: str) -> date:
    require(isinstance(value, str), "E_DATE", "%s must be an ISO date" % field)
    try:
        parsed = date.fromisoformat(value)
    except ValueError:
        raise ContractV7Error("E_DATE", "%s must be an ISO date" % field)
    require(parsed.isoformat() == value, "E_DATE", "%s is not canonical YYYY-MM-DD" % field)
    return parsed


def _safe_project_path(value: Any, field: str) -> str:
    require(isinstance(value, str) and bool(value), "E_PATH", "%s must be a non-empty path" % field)
    require("\\" not in value and "\x00" not in value, "E_PATH", "%s is not a POSIX project path" % field)
    path = PurePosixPath(value)
    require(not path.is_absolute(), "E_PATH", "%s must be project-relative" % field)
    require(all(part not in ("", ".", "..") for part in path.parts), "E_PATH", "%s is unsafe" % field)
    return value


def _safe_resolve(root: Path, project_path: str) -> Path:
    root_resolved = root.resolve(strict=True)
    candidate = (root_resolved / project_path).resolve(strict=False)
    require(
        os.path.commonpath((str(root_resolved), str(candidate))) == str(root_resolved),
        "E_PATH",
        "project path resolves outside the mainline root",
        {"path": project_path},
    )
    return candidate


def _sha256(value: Any, field: str) -> str:
    require(isinstance(value, str) and bool(SHA256_RE.fullmatch(value)), "E_SHA256", "%s is not lowercase SHA-256" % field)
    return value


def _identifier(value: Any, field: str) -> str:
    require(isinstance(value, str) and bool(ID_RE.fullmatch(value)), "E_JSON_TYPE", "%s is not a valid ID" % field)
    return value


def _record_hash_check(
    checks: List[PreflightCheck],
    root: Path,
    check_id: str,
    project_path: str,
    expected_hash: str,
) -> bool:
    path = _safe_resolve(root, project_path)
    if not path.is_file():
        checks.append(PreflightCheck(check_id, "missing", "required live file is absent", expected_hash, None))
        return False
    actual_hash = file_sha256(path)
    if actual_hash != expected_hash:
        checks.append(PreflightCheck(check_id, "mismatch", "live raw SHA-256 differs", expected_hash, actual_hash))
        return False
    checks.append(PreflightCheck(check_id, "satisfied", "live raw SHA-256 matches", expected_hash, actual_hash))
    return True


def _validate_prerequisite_document(document: Mapping[str, Any]) -> None:
    require_exact_keys(document, PREREQUISITE_KEYS)
    require(document["prerequisite_contract_version"] == "SOURCE-POOL-113-PREREQUISITE-V1", "E_JSON_TYPE", "prerequisite version drifted")
    prerequisite_id = _identifier(document["prerequisite_id"], "prerequisite_id")
    promotion_id = _identifier(document["promotion_id"], "promotion_id")
    require(document["source_pool_contract_review_path"] == SOURCE_POOL_REVIEW_PATH, "E_REQUIRED_SET", "source-pool review path drifted")
    require(document["source_pool_contract_review_raw_sha256"] == SOURCE_POOL_REVIEW_SHA256, "E_REQUIRED_SET", "source-pool review hash drifted")
    require(document["source_pool_operations_path"] == SOURCE_POOL_OPERATIONS_PATH, "E_REQUIRED_SET", "source-pool operations path drifted")
    require(document["source_pool_operations_raw_sha256"] == SOURCE_POOL_OPERATIONS_SHA256, "E_REQUIRED_SET", "source-pool operations hash drifted")
    expected_promotion_path = "审计/子代理交接/r1_source_pool_113_staging/promotion-records/%s/promotion-record.json" % promotion_id
    require(document["promotion_record_path"] == expected_promotion_path, "E_PATH", "promotion record path does not bind promotion_id")
    _sha256(document["promotion_record_raw_sha256"], "promotion_record_raw_sha256")
    require(document["promotion_status"] == "succeeded", "E_GATE_RESULT", "independent prerequisite has not adjudicated promotion succeeded")
    fixed_document_fields = {
        "formal_manifest_path": ("清单/论文PDF清单.csv", EXPECTED_FORMAL_POST_HASHES[1][1]),
        "formal_summary_path": ("清单/汇总统计.json", EXPECTED_FORMAL_POST_HASHES[2][1]),
        "collector_path": ("scripts/collect_references.py", EXPECTED_FORMAL_POST_HASHES[3][1]),
        "validator_path": ("scripts/validation/Test-SourcePool.ps1", EXPECTED_FORMAL_POST_HASHES[0][1]),
        "controlled_ledger_path": ("清单/资料池受控输入/source-pool-input-ledger.json", EXPECTED_FORMAL_POST_HASHES[4][1]),
        "controlled_frozen_manifest_path": ("清单/资料池受控输入/frozen-legacy-pdf-manifest.csv", EXPECTED_FORMAL_POST_HASHES[5][1]),
    }
    for path_field, (expected_path, expected_hash) in fixed_document_fields.items():
        hash_field = path_field.replace("_path", "_raw_sha256")
        require(document[path_field] == expected_path, "E_REQUIRED_SET", "%s drifted" % path_field)
        require(document[hash_field] == expected_hash, "E_REQUIRED_SET", "%s drifted" % hash_field)
    require(document["formal_manifest_rows"] == 113, "E_REQUIRED_SET", "formal source manifest row count must be 113")
    gates = document["gate_results"]
    require(isinstance(gates, list) and len(gates) == 3, "E_REQUIRED_SET", "exactly three gate results are required")
    transcript_paths = []
    for index, gate in enumerate(gates, start=1):
        require(isinstance(gate, dict), "E_JSON_TYPE", "gate result must be an object")
        require_exact_keys(gate, GATE_RESULT_KEYS)
        require(gate["gate_seq"] == index, "E_GATE_RESULT", "gate sequence must be 1,2,3")
        require(gate["gate_id"] == EXPECTED_GATE_IDS[index - 1], "E_GATE_RESULT", "gate ID/order drifted")
        transcript_paths.append(_safe_project_path(gate["transcript_path"], "transcript_path"))
        _sha256(gate["transcript_raw_sha256"], "transcript_raw_sha256")
        require(gate["result"] == "passed", "E_GATE_RESULT", "Windows gate result is not passed")
    require(len(set(transcript_paths)) == 3, "E_REQUIRED_SET", "gate transcript paths must be unique")
    prepared_by = document["prepared_by"]
    reviewed_by = document["reviewed_by"]
    require(isinstance(prepared_by, str) and prepared_by, "E_JSON_TYPE", "prepared_by is empty")
    require(isinstance(reviewed_by, str) and reviewed_by, "E_JSON_TYPE", "reviewed_by is empty")
    require(prepared_by != reviewed_by, "E_APPROVAL_BINDING", "prerequisite preparer and reviewer must differ")
    prepared_date = _parse_date(document["prepared_date"], "prepared_date")
    reviewed_date = _parse_date(document["reviewed_date"], "reviewed_date")
    require(reviewed_date >= prepared_date, "E_DATE", "reviewed_date precedes prepared_date")
    require(document["review_status"] == "reviewed", "E_APPROVAL_BINDING", "prerequisite is not independently reviewed")
    require(document["notes"] is None or isinstance(document["notes"], str), "E_JSON_TYPE", "notes must be string or null")


def _validate_approval_document(
    approval: Mapping[str, Any],
    prerequisite: Mapping[str, Any],
    prerequisite_hash: str,
) -> None:
    require_exact_keys(approval, APPROVAL_KEYS)
    require(approval["approval_contract_version"] == "ARTIFACT-APPROVAL-V1", "E_APPROVAL_BINDING", "approval version drifted")
    _identifier(approval["approval_id"], "approval_id")
    require(approval["artifact_kind"] == "source_pool_113_prerequisite", "E_APPROVAL_BINDING", "approval artifact kind drifted")
    require(approval["artifact_id"] == prerequisite["prerequisite_id"], "E_APPROVAL_BINDING", "approval artifact ID mismatch")
    require(approval["artifact_canonical_sha256"] == prerequisite_hash, "E_APPROVAL_BINDING", "approval artifact hash mismatch")
    approved_by = approval["approved_by"]
    require(isinstance(approved_by, str) and approved_by, "E_JSON_TYPE", "approved_by is empty")
    require(
        approved_by not in (prerequisite["prepared_by"], prerequisite["reviewed_by"]),
        "E_APPROVAL_BINDING",
        "approver must differ from prerequisite preparer and reviewer",
    )
    approved_date = _parse_date(approval["approved_date"], "approved_date")
    reviewed_date = _parse_date(prerequisite["reviewed_date"], "reviewed_date")
    require(approved_date >= reviewed_date, "E_DATE", "approved_date precedes reviewed_date")
    require(approval["approval_status"] == "approved", "E_APPROVAL_BINDING", "prerequisite approval is not approved")
    require(approval["notes"] is None or isinstance(approval["notes"], str), "E_JSON_TYPE", "approval notes must be string or null")


def _manifest_data_rows(path: Path) -> int:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, strict=True)
        try:
            next(reader)
        except StopIteration:
            return 0
        return sum(1 for _ in reader)


def inspect_live_prerequisites(
    mainline_root: Path,
    prerequisite_manifest_path: Optional[Path] = None,
    prerequisite_approval_path: Optional[Path] = None,
) -> PreflightReport:
    """Inspect live state without creating a transaction, snapshot, or candidate."""

    root = mainline_root.resolve(strict=True)
    checks: List[PreflightCheck] = []

    # The post-113 validator is deliberately the first byte check.
    validator_path, validator_hash = EXPECTED_FORMAL_POST_HASHES[0]
    _record_hash_check(checks, root, "formal_post_113_validator_hash", validator_path, validator_hash)

    controlled = _safe_resolve(root, CONTROLLED_INPUT_DIRECTORY)
    if controlled.is_dir():
        checks.append(PreflightCheck("controlled_input_directory", "satisfied", "controlled input directory exists"))
    else:
        checks.append(PreflightCheck("controlled_input_directory", "missing", "controlled input directory is absent"))

    for project_path, expected_hash in EXPECTED_FORMAL_POST_HASHES[1:]:
        check_id = "formal_post_hash:" + project_path
        _record_hash_check(checks, root, check_id, project_path, expected_hash)
    _record_hash_check(checks, root, "source_pool_independent_review_hash", SOURCE_POOL_REVIEW_PATH, SOURCE_POOL_REVIEW_SHA256)
    _record_hash_check(checks, root, "source_pool_operations_hash", SOURCE_POOL_OPERATIONS_PATH, SOURCE_POOL_OPERATIONS_SHA256)

    prerequisite: Optional[Mapping[str, Any]] = None
    prerequisite_hash: Optional[str] = None
    if prerequisite_manifest_path is None:
        checks.append(PreflightCheck("independent_prerequisite_manifest", "missing", "no independently reviewed prerequisite manifest was supplied"))
    elif not prerequisite_manifest_path.is_file():
        checks.append(PreflightCheck("independent_prerequisite_manifest", "missing", "supplied prerequisite manifest is absent"))
    else:
        try:
            prerequisite_raw = prerequisite_manifest_path.read_bytes()
            parsed = parse_strict_json_bytes(prerequisite_raw)
            require(isinstance(parsed, dict), "E_JSON_TYPE", "prerequisite must be a JSON object")
            _validate_prerequisite_document(parsed)
            prerequisite = parsed
            prerequisite_hash = framed_sha256(PREREQUISITE_DOMAIN, prerequisite_raw)
            checks.append(PreflightCheck("independent_prerequisite_manifest", "satisfied", "canonical prerequisite schema and independent review fields are valid", actual=prerequisite_hash))
        except (ContractV7Error, OSError) as error:
            detail = error.code + ": " + error.message if isinstance(error, ContractV7Error) else "tool/runtime failure: " + str(error)
            checks.append(PreflightCheck("independent_prerequisite_manifest", "invalid", detail))

    if prerequisite is None:
        promotion_root = _safe_resolve(
            root,
            "审计/子代理交接/r1_source_pool_113_staging/promotion-records",
        )
        discovered_records = (
            tuple(promotion_root.glob("*/promotion-record.json"))
            if promotion_root.is_dir()
            else ()
        )
        if not discovered_records:
            checks.append(PreflightCheck("promotion_record_raw", "missing", "no promotion record exists; prerequisite path/hash is unavailable"))
        else:
            checks.append(PreflightCheck("promotion_record_raw", "not_checkable", "promotion record candidates exist but no prerequisite binds one path/hash"))
        for gate_id in EXPECTED_GATE_IDS:
            checks.append(PreflightCheck("windows_transcript:" + gate_id, "not_checkable", "prerequisite manifest is unavailable; transcript path/hash/result cannot be trusted"))
    else:
        promotion_relative = prerequisite["promotion_record_path"]
        expected_promotion_hash = prerequisite["promotion_record_raw_sha256"]
        _record_hash_check(checks, root, "promotion_record_raw", promotion_relative, expected_promotion_hash)
        for gate in prerequisite["gate_results"]:
            _record_hash_check(
                checks,
                root,
                "windows_transcript:" + gate["gate_id"],
                gate["transcript_path"],
                gate["transcript_raw_sha256"],
            )
        formal_manifest = _safe_resolve(root, prerequisite["formal_manifest_path"])
        if formal_manifest.is_file():
            actual_rows = _manifest_data_rows(formal_manifest)
            if actual_rows == 113:
                checks.append(PreflightCheck("formal_manifest_rows", "satisfied", "formal manifest has 113 data rows", "113", str(actual_rows)))
            else:
                checks.append(PreflightCheck("formal_manifest_rows", "mismatch", "formal manifest row count differs", "113", str(actual_rows)))

    if prerequisite_approval_path is None:
        checks.append(PreflightCheck("independent_prerequisite_approval", "missing", "no independent prerequisite approval was supplied"))
    elif not prerequisite_approval_path.is_file():
        checks.append(PreflightCheck("independent_prerequisite_approval", "missing", "supplied prerequisite approval is absent"))
    elif prerequisite is None or prerequisite_hash is None:
        checks.append(PreflightCheck("independent_prerequisite_approval", "not_checkable", "approval cannot be bound without a valid prerequisite manifest"))
    else:
        try:
            approval_raw = prerequisite_approval_path.read_bytes()
            parsed_approval = parse_strict_json_bytes(approval_raw)
            require(isinstance(parsed_approval, dict), "E_JSON_TYPE", "approval must be a JSON object")
            _validate_approval_document(parsed_approval, prerequisite, prerequisite_hash)
            checks.append(PreflightCheck("independent_prerequisite_approval", "satisfied", "approval binds the prerequisite canonical hash"))
        except (ContractV7Error, OSError) as error:
            detail = error.code + ": " + error.message if isinstance(error, ContractV7Error) else "tool/runtime failure: " + str(error)
            checks.append(PreflightCheck("independent_prerequisite_approval", "invalid", detail))

    failed = [check for check in checks if check.status != "satisfied"]
    return PreflightReport(
        status="READY" if not failed else "BLOCKED",
        error_code=None if not failed else "E_UPSTREAM_PREREQUISITE",
        snapshot_candidate_creation_authorized=not failed,
        checks=tuple(checks),
    )


def require_live_prerequisites(
    mainline_root: Path,
    prerequisite_manifest_path: Optional[Path] = None,
    prerequisite_approval_path: Optional[Path] = None,
) -> PreflightReport:
    report = inspect_live_prerequisites(
        mainline_root,
        prerequisite_manifest_path,
        prerequisite_approval_path,
    )
    if not report.snapshot_candidate_creation_authorized:
        raise UpstreamPrerequisiteError(
            "post-source-pool-113 prerequisites are incomplete; no snapshot or candidate may be created",
            {
                "failed_checks": [
                    check.check_id for check in report.checks if check.status != "satisfied"
                ],
                "report": report.to_dict(),
            },
        )
    return report
