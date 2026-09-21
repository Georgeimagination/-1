"""Read-only source-pool-113 prerequisite gate with digest-bound READY reports."""

import csv
import os
from collections import OrderedDict
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from .canonical import canonical_json_bytes, file_sha256, framed_sha256, parse_strict_json_bytes, require_exact_keys
from .errors import ContractV7Error, UpstreamPrerequisiteError, require, raise_stable_external
from .pathing import resolve_contained, validate_logical_path
from .principals import validate_independent_principals, validate_principal_id


_READY_SEAL = object()


EXPECTED_FORMAL_POST_HASHES: Tuple[Tuple[str, str], ...] = (
    ("scripts/validation/Test-SourcePool.ps1", "c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0"),
    ("清单/论文PDF清单.csv", "4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab"),
    ("清单/汇总统计.json", "994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e"),
    ("scripts/collect_references.py", "2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb"),
    ("清单/资料池受控输入/source-pool-input-ledger.json", "08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812"),
    ("清单/资料池受控输入/frozen-legacy-pdf-manifest.csv", "c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27"),
)
CONTROLLED_DIRECTORY = "清单/资料池受控输入"
CONTROLLED_EXACT_FILES = frozenset(("source-pool-input-ledger.json", "frozen-legacy-pdf-manifest.csv"))
REVIEW_PATH = "审计/子代理交接/r1_source_pool_113_v4_independent_review.md"
REVIEW_SHA256 = "6980a2d109e6bf17de2ce47829b1c2063dcefe1a1e323413a818992dc02c5b11"
OPERATIONS_PATH = "审计/子代理交接/r1_source_pool_113_staging/operations.csv"
OPERATIONS_SHA256 = "e8bf4895f0d376d355ad0cae507664f9911b23d5ada653ef5626440f07bbc9ea"

PREREQUISITE_KEYS: Tuple[str, ...] = (
    "prerequisite_contract_version", "prerequisite_id", "source_pool_contract_review_path",
    "source_pool_contract_review_raw_sha256", "source_pool_operations_path",
    "source_pool_operations_raw_sha256", "promotion_id", "promotion_record_path",
    "promotion_record_raw_sha256", "promotion_status", "formal_manifest_path",
    "formal_manifest_raw_sha256", "formal_manifest_rows", "formal_summary_path",
    "formal_summary_raw_sha256", "collector_path", "collector_raw_sha256", "validator_path",
    "validator_raw_sha256", "controlled_ledger_path", "controlled_ledger_raw_sha256",
    "controlled_frozen_manifest_path", "controlled_frozen_manifest_raw_sha256", "gate_results",
    "prepared_by", "prepared_date", "reviewed_by", "reviewed_date", "review_status", "notes",
)
GATE_KEYS = ("gate_seq", "gate_id", "transcript_path", "transcript_raw_sha256", "result")
APPROVAL_KEYS = (
    "approval_contract_version", "approval_id", "artifact_kind", "artifact_id",
    "artifact_canonical_sha256", "approved_by", "approved_date", "approval_status", "notes",
)
GATE_IDS = ("source_pool", "chip_scope", "research_data_subject_contract")


@dataclass(frozen=True)
class DigestBinding:
    binding_id: str
    kind: str
    logical_path: str
    digest: str

    def to_dict(self) -> Dict[str, str]:
        return {"binding_id": self.binding_id, "kind": self.kind, "logical_path": self.logical_path, "digest": self.digest}


@dataclass(frozen=True)
class PreflightCheck:
    check_id: str
    status: str
    detail: str
    expected: Optional[str] = None
    actual: Optional[str] = None

    def to_dict(self) -> Dict[str, Optional[str]]:
        return {"check_id": self.check_id, "status": self.status, "detail": self.detail, "expected": self.expected, "actual": self.actual}


@dataclass(frozen=True)
class ReadyReport:
    status: str
    error_code: Optional[str]
    snapshot_candidate_creation_authorized: bool
    root_resolved: str
    precondition_digest: Optional[str]
    bindings: Tuple[DigestBinding, ...]
    checks: Tuple[PreflightCheck, ...]
    _seal: object = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "status": self.status,
            "error_code": self.error_code,
            "snapshot_candidate_creation_authorized": self.snapshot_candidate_creation_authorized,
            "root_resolved": self.root_resolved,
            "precondition_digest": self.precondition_digest,
            "bindings": [binding.to_dict() for binding in self.bindings],
            "checks": [check.to_dict() for check in self.checks],
            "writes_performed": False,
        }


def _iso_date(value: Any, field: str) -> date:
    require(isinstance(value, str), "E_DATE", "%s must be YYYY-MM-DD" % field)
    try:
        parsed = date.fromisoformat(value)
    except (TypeError, ValueError):
        raise ContractV7Error("E_DATE", "%s must be YYYY-MM-DD" % field)
    require(parsed.isoformat() == value, "E_DATE", "%s is not canonical" % field)
    return parsed


def _sha(value: Any, field: str) -> str:
    require(isinstance(value, str) and len(value) == 64 and all(character in "0123456789abcdef" for character in value), "E_SHA256", "%s is not lowercase SHA-256" % field)
    return value


def _record_file_check(root: Path, checks: List[PreflightCheck], bindings: List[DigestBinding], check_id: str, logical_path: str, expected: str) -> bool:
    try:
        path = resolve_contained(root, logical_path)
        if not path.is_file():
            checks.append(PreflightCheck(check_id, "missing", "required file is absent", expected, None))
            return False
        actual = file_sha256(path)
    except ContractV7Error as error:
        checks.append(PreflightCheck(check_id, "invalid", "%s: %s" % (error.code, error.message), expected, None))
        return False
    status = "satisfied" if actual == expected else "mismatch"
    checks.append(PreflightCheck(check_id, status, "raw SHA-256 matches" if status == "satisfied" else "raw SHA-256 differs", expected, actual))
    if status == "satisfied":
        bindings.append(DigestBinding(check_id, "file", logical_path, actual))
    return status == "satisfied"


def _directory_digest(root: Path, logical_path: str) -> Tuple[str, frozenset]:
    directory = resolve_contained(root, logical_path)
    require(directory.is_dir(), "E_IO_NOT_FOUND", "controlled input directory is absent")
    entries = []
    names = set()
    for child in sorted(directory.iterdir(), key=lambda item: item.name.encode("utf-8")):
        require(child.is_file() and not child.is_symlink(), "E_REQUIRED_SET", "controlled input directory contains a non-regular entry", {"entry": child.name})
        validate_logical_path("%s/%s" % (logical_path, child.name))
        names.add(child.name)
        entries.append(OrderedDict((("relative_path", child.name), ("raw_sha256", file_sha256(child)))))
    return framed_sha256("directory-set-v1", canonical_json_bytes(entries)), frozenset(names)


def _validate_prerequisite(document: Mapping[str, Any]) -> None:
    require_exact_keys(document, PREREQUISITE_KEYS)
    require(document["prerequisite_contract_version"] == "SOURCE-POOL-113-PREREQUISITE-V1", "E_REQUIRED_SET", "prerequisite version differs")
    require(isinstance(document["prerequisite_id"], str) and bool(document["prerequisite_id"]), "E_JSON_TYPE", "prerequisite ID is empty")
    require(isinstance(document["promotion_id"], str) and bool(document["promotion_id"]), "E_JSON_TYPE", "promotion ID is empty")
    require(document["source_pool_contract_review_path"] == REVIEW_PATH and document["source_pool_contract_review_raw_sha256"] == REVIEW_SHA256, "E_REQUIRED_SET", "source-pool review binding differs")
    require(document["source_pool_operations_path"] == OPERATIONS_PATH and document["source_pool_operations_raw_sha256"] == OPERATIONS_SHA256, "E_REQUIRED_SET", "source-pool operations binding differs")
    expected_promotion = "审计/子代理交接/r1_source_pool_113_staging/promotion-records/%s/promotion-record.json" % document["promotion_id"]
    require(document["promotion_record_path"] == expected_promotion, "E_PATH", "promotion record does not bind promotion_id")
    _sha(document["promotion_record_raw_sha256"], "promotion_record_raw_sha256")
    require(document["promotion_status"] == "succeeded", "E_GATE_RESULT", "promotion status is not succeeded")
    expected_fields = {
        "formal_manifest": EXPECTED_FORMAL_POST_HASHES[1], "formal_summary": EXPECTED_FORMAL_POST_HASHES[2],
        "collector": EXPECTED_FORMAL_POST_HASHES[3], "validator": EXPECTED_FORMAL_POST_HASHES[0],
        "controlled_ledger": EXPECTED_FORMAL_POST_HASHES[4], "controlled_frozen_manifest": EXPECTED_FORMAL_POST_HASHES[5],
    }
    for stem, (path, digest) in expected_fields.items():
        require(document[stem + "_path"] == path and document[stem + "_raw_sha256"] == digest, "E_REQUIRED_SET", "%s binding differs" % stem)
    require(document["formal_manifest_rows"] == 113, "E_REQUIRED_SET", "formal source manifest must have 113 rows")
    gates = document["gate_results"]
    require(isinstance(gates, list) and len(gates) == 3, "E_REQUIRED_SET", "exactly three Windows gate records are required")
    paths = []
    for sequence, gate in enumerate(gates, start=1):
        require(isinstance(gate, Mapping), "E_JSON_TYPE", "gate result must be an object")
        require_exact_keys(gate, GATE_KEYS)
        require(gate["gate_seq"] == sequence and gate["gate_id"] == GATE_IDS[sequence - 1], "E_GATE_RESULT", "gate sequence/ID differs")
        validate_logical_path(gate["transcript_path"])
        paths.append(gate["transcript_path"])
        _sha(gate["transcript_raw_sha256"], "transcript_raw_sha256")
        require(gate["result"] == "passed", "E_GATE_RESULT", "gate is not passed")
    require(len(set(paths)) == 3, "E_REQUIRED_SET", "gate transcript paths are not unique")
    prepared = validate_principal_id(document["prepared_by"], "prepared_by")
    reviewed = validate_principal_id(document["reviewed_by"], "reviewed_by")
    require(prepared.casefold() != reviewed.casefold(), "E_PRINCIPAL_COLLISION", "preparer and reviewer collide")
    require(_iso_date(document["reviewed_date"], "reviewed_date") >= _iso_date(document["prepared_date"], "prepared_date"), "E_DATE", "review date precedes preparation")
    require(document["review_status"] == "reviewed", "E_APPROVAL_BINDING", "prerequisite is not reviewed")
    require(document["notes"] is None or isinstance(document["notes"], str), "E_JSON_TYPE", "notes must be string or null")


def _validate_approval(approval: Mapping[str, Any], prerequisite: Mapping[str, Any], prerequisite_hash: str) -> None:
    require_exact_keys(approval, APPROVAL_KEYS)
    require(approval["approval_contract_version"] == "ARTIFACT-APPROVAL-V1", "E_APPROVAL_BINDING", "approval version differs")
    require(approval["artifact_kind"] == "source_pool_113_prerequisite" and approval["artifact_id"] == prerequisite["prerequisite_id"], "E_APPROVAL_BINDING", "approval artifact binding differs")
    require(approval["artifact_canonical_sha256"] == prerequisite_hash, "E_APPROVAL_BINDING", "approval hash binding differs")
    validate_independent_principals({"prepared_by": prerequisite["prepared_by"], "reviewed_by": prerequisite["reviewed_by"], "approved_by": approval["approved_by"]})
    require(_iso_date(approval["approved_date"], "approved_date") >= _iso_date(prerequisite["reviewed_date"], "reviewed_date"), "E_DATE", "approval predates review")
    require(approval["approval_status"] == "approved", "E_APPROVAL_BINDING", "approval status differs")
    require(approval["notes"] is None or isinstance(approval["notes"], str), "E_JSON_TYPE", "approval notes must be string or null")


def _validate_promotion_record(raw: bytes, promotion_id: str) -> None:
    record = parse_strict_json_bytes(raw)
    require(isinstance(record, Mapping), "E_JSON_TYPE", "promotion record must be an object")
    require(record.get("schema_version") == "source-pool-113-promotion-record-v1", "E_PROMOTION_RECORD", "promotion record schema differs")
    require(record.get("promotion_id") == promotion_id, "E_PROMOTION_RECORD", "promotion record ID differs")
    steps = record.get("step_results")
    require(isinstance(steps, list) and len(steps) == 12, "E_PROMOTION_RECORD", "promotion record must contain 12 step results")
    observed = []
    for item in steps:
        require(isinstance(item, Mapping), "E_PROMOTION_RECORD", "promotion step is not an object")
        sequence = item.get("sequence")
        result = item.get("result")
        require(isinstance(sequence, int) and not isinstance(sequence, bool), "E_PROMOTION_RECORD", "promotion sequence is not an integer")
        require(result in ("succeeded", "passed"), "E_PROMOTION_RECORD", "promotion step did not succeed")
        observed.append(sequence)
    require(observed == list(range(12)), "E_PROMOTION_RECORD", "promotion sequences are not 00 through 11")


def _csv_data_rows(path: Path) -> int:
    try:
        with path.open("r", encoding="utf-8-sig", newline="") as handle:
            reader = csv.reader(handle, strict=True)
            next(reader)
            return sum(1 for _ in reader)
    except StopIteration:
        return 0
    except BaseException as error:
        raise_stable_external(error, "count formal source manifest rows")


def _binding_set_digest(bindings: Sequence[DigestBinding]) -> str:
    ordered = sorted(bindings, key=lambda item: item.binding_id.encode("utf-8"))
    payload = [OrderedDict((("binding_id", item.binding_id), ("kind", item.kind), ("logical_path", item.logical_path), ("digest", item.digest))) for item in ordered]
    return framed_sha256("precondition-set-v1", canonical_json_bytes(payload))


def inspect_live_prerequisites(mainline_root: Path, transaction_id: str) -> ReadyReport:
    """Inspect without creating directories, snapshots, candidate bytes, or approvals."""

    checks: List[PreflightCheck] = []
    bindings: List[DigestBinding] = []
    try:
        root = mainline_root.resolve(strict=True)
        require(root.is_dir(), "E_ROOT_NOT_FOUND", "mainline root is not a directory")
    except BaseException as error:
        code = "E_ROOT_NOT_FOUND" if isinstance(error, FileNotFoundError) else (error.code if isinstance(error, ContractV7Error) else "E_IO")
        checks.append(PreflightCheck("mainline_root", "invalid", code + ": mainline root is unavailable"))
        return ReadyReport("BLOCKED", code, False, str(mainline_root), None, (), tuple(checks))

    # This is intentionally the first live byte check.
    _record_file_check(root, checks, bindings, "formal_post_113_validator_hash", *EXPECTED_FORMAL_POST_HASHES[0])

    try:
        digest, names = _directory_digest(root, CONTROLLED_DIRECTORY)
        if names == CONTROLLED_EXACT_FILES:
            checks.append(PreflightCheck("controlled_input_directory", "satisfied", "controlled directory has the exact two-file membership", actual=digest))
            bindings.append(DigestBinding("controlled_input_directory", "directory_set", CONTROLLED_DIRECTORY, digest))
        else:
            checks.append(PreflightCheck("controlled_input_directory", "mismatch", "controlled directory membership differs", str(sorted(CONTROLLED_EXACT_FILES)), str(sorted(names))))
    except ContractV7Error as error:
        checks.append(PreflightCheck("controlled_input_directory", "missing" if error.code == "E_IO_NOT_FOUND" else "invalid", "%s: %s" % (error.code, error.message)))

    for logical_path, digest in EXPECTED_FORMAL_POST_HASHES[1:]:
        _record_file_check(root, checks, bindings, "formal_post_hash:" + logical_path, logical_path, digest)
    _record_file_check(root, checks, bindings, "source_pool_independent_review_hash", REVIEW_PATH, REVIEW_SHA256)
    _record_file_check(root, checks, bindings, "source_pool_operations_hash", OPERATIONS_PATH, OPERATIONS_SHA256)

    try:
        prefix = "审计/事务/%s/inputs/prerequisites" % transaction_id
        prerequisite_path = "%s/source-pool-113-prerequisite.json" % prefix
        approval_path = "%s/source-pool-113-prerequisite-approval.json" % prefix
        prerequisite_raw = resolve_contained(root, prerequisite_path, must_exist=True).read_bytes()
        prerequisite = parse_strict_json_bytes(prerequisite_raw)
        require(isinstance(prerequisite, Mapping), "E_JSON_TYPE", "prerequisite must be an object")
        _validate_prerequisite(prerequisite)
        prerequisite_hash = framed_sha256("source-pool-113-prerequisite-v1", prerequisite_raw)
        checks.append(PreflightCheck("independent_prerequisite_manifest", "satisfied", "strict prerequisite is valid", actual=prerequisite_hash))
        bindings.append(DigestBinding("independent_prerequisite_manifest", "file", prerequisite_path, file_sha256(resolve_contained(root, prerequisite_path, True))))

        promotion_path = prerequisite["promotion_record_path"]
        promotion_file = resolve_contained(root, promotion_path, must_exist=True)
        promotion_raw = promotion_file.read_bytes()
        _validate_promotion_record(promotion_raw, prerequisite["promotion_id"])
        require(file_sha256(promotion_file) == prerequisite["promotion_record_raw_sha256"], "E_PROMOTION_RECORD", "promotion record raw hash differs")
        checks.append(PreflightCheck("promotion_record_raw", "satisfied", "promotion record bytes and 00-11 results are bound", actual=prerequisite["promotion_record_raw_sha256"]))
        bindings.append(DigestBinding("promotion_record_raw", "file", promotion_path, prerequisite["promotion_record_raw_sha256"]))

        for gate in prerequisite["gate_results"]:
            _record_file_check(root, checks, bindings, "windows_transcript:" + gate["gate_id"], gate["transcript_path"], gate["transcript_raw_sha256"])

        manifest_file = resolve_contained(root, prerequisite["formal_manifest_path"], True)
        rows = _csv_data_rows(manifest_file)
        require(rows == 113, "E_REQUIRED_SET", "formal source manifest row count differs", {"actual": rows})
        checks.append(PreflightCheck("formal_manifest_rows", "satisfied", "formal source manifest has 113 data rows", "113", str(rows)))

        approval_raw = resolve_contained(root, approval_path, must_exist=True).read_bytes()
        approval = parse_strict_json_bytes(approval_raw)
        require(isinstance(approval, Mapping), "E_JSON_TYPE", "prerequisite approval must be an object")
        _validate_approval(approval, prerequisite, prerequisite_hash)
        checks.append(PreflightCheck("independent_prerequisite_approval", "satisfied", "approval binds the prerequisite canonical hash"))
        bindings.append(DigestBinding("independent_prerequisite_approval", "file", approval_path, file_sha256(resolve_contained(root, approval_path, True))))
    except BaseException as error:
        if isinstance(error, ContractV7Error):
            code, message = error.code, error.message
        elif isinstance(error, FileNotFoundError):
            code, message = "E_IO_NOT_FOUND", "required prerequisite file is absent"
        elif isinstance(error, UnicodeDecodeError):
            code, message = "E_UTF8", "prerequisite input is not valid UTF-8"
        elif isinstance(error, OSError):
            code, message = "E_IO", "prerequisite input could not be read"
        else:
            code, message = "E_INTERNAL", "unexpected prerequisite validation failure"
        checks.append(PreflightCheck("independent_prerequisite_chain", "invalid" if code != "E_IO_NOT_FOUND" else "missing", "%s: %s" % (code, message)))

    failed = [check for check in checks if check.status != "satisfied"]
    if failed:
        return ReadyReport("BLOCKED", "E_UPSTREAM_PREREQUISITE", False, str(root), None, tuple(bindings), tuple(checks))
    return ReadyReport("READY", None, True, str(root), _binding_set_digest(bindings), tuple(bindings), tuple(checks), _READY_SEAL)


def _current_binding_digest(root: Path, binding: DigestBinding) -> str:
    if binding.kind == "file":
        path = resolve_contained(root, binding.logical_path, True)
        require(path.is_file(), "E_PRECONDITION_DRIFT", "precondition file is no longer regular")
        return file_sha256(path)
    if binding.kind == "directory_set":
        digest, names = _directory_digest(root, binding.logical_path)
        require(names == CONTROLLED_EXACT_FILES, "E_PRECONDITION_DRIFT", "controlled directory membership drifted")
        return digest
    raise ContractV7Error("E_PRECONDITION_DRIFT", "unknown READY binding kind")


def revalidate_ready_report(report: ReadyReport, mainline_root: Path) -> None:
    require(report.status == "READY" and report.snapshot_candidate_creation_authorized and report.precondition_digest is not None and report._seal is _READY_SEAL, "E_UPSTREAM_PREREQUISITE", "READY report is absent, blocked, or not issued by this preflight process")
    try:
        root = mainline_root.resolve(strict=True)
    except BaseException:
        raise ContractV7Error("E_PRECONDITION_DRIFT", "mainline root disappeared after READY")
    require(str(root) == report.root_resolved, "E_PRECONDITION_DRIFT", "READY report belongs to another root")
    current: List[DigestBinding] = []
    for binding in report.bindings:
        try:
            digest = _current_binding_digest(root, binding)
        except ContractV7Error as error:
            if error.code == "E_PRECONDITION_DRIFT":
                raise
            raise ContractV7Error("E_PRECONDITION_DRIFT", "precondition could not be re-read", {"binding_id": binding.binding_id, "cause": error.code})
        require(digest == binding.digest, "E_PRECONDITION_DRIFT", "precondition bytes changed after READY", {"binding_id": binding.binding_id, "expected": binding.digest, "actual": digest})
        current.append(DigestBinding(binding.binding_id, binding.kind, binding.logical_path, digest))
    require(_binding_set_digest(current) == report.precondition_digest, "E_PRECONDITION_DRIFT", "precondition set digest changed")


def require_live_prerequisites(mainline_root: Path, transaction_id: str) -> ReadyReport:
    report = inspect_live_prerequisites(mainline_root, transaction_id)
    if report.status != "READY":
        raise UpstreamPrerequisiteError("post-source-pool-113 prerequisites are incomplete; no snapshot or candidate may be created", {"failed_checks": [check.check_id for check in report.checks if check.status != "satisfied"], "report": report.to_dict()})
    return report
