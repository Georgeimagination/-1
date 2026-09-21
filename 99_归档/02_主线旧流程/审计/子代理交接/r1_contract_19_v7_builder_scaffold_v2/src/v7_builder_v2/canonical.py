"""Canonical JSON, domain framing, and SemanticPath-aware CSV hashes."""

import csv
import hashlib
import io
import json
import re
from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Mapping, Optional, Sequence, Tuple

from .errors import ContractV7Error, require, raise_stable_external


def _unicode_scalar_string(value: str) -> None:
    for character in value:
        require(not 0xD800 <= ord(character) <= 0xDFFF, "E_SURROGATE", "string contains a surrogate scalar")


def _json_string(value: str) -> str:
    _unicode_scalar_string(value)
    result: List[str] = ['"']
    for character in value:
        scalar = ord(character)
        if character == '"':
            result.append('\\"')
        elif character == "\\":
            result.append("\\\\")
        elif scalar <= 0x1F:
            result.append("\\u%04x" % scalar)
        else:
            result.append(character)
    result.append('"')
    return "".join(result)


def canonical_json_text(value: Any) -> str:
    if value is None:
        return "null"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, int) and not isinstance(value, bool):
        return str(value)
    if isinstance(value, float):
        raise ContractV7Error("E_JSON_NUMBER", "floating-point JSON is forbidden")
    if isinstance(value, str):
        return _json_string(value)
    if isinstance(value, (list, tuple)):
        return "[" + ",".join(canonical_json_text(item) for item in value) + "]"
    if isinstance(value, Mapping):
        output: List[str] = []
        seen = set()
        for key, item in value.items():
            require(isinstance(key, str), "E_JSON_KEY", "JSON object keys must be strings")
            require(key not in seen, "E_JSON_KEY", "duplicate JSON key", {"key": key})
            seen.add(key)
            output.append(_json_string(key) + ":" + canonical_json_text(item))
        return "{" + ",".join(output) + "}"
    raise ContractV7Error("E_JSON_TYPE", "unsupported canonical JSON value", {"python_type": type(value).__name__})


def canonical_json_bytes(value: Any) -> bytes:
    try:
        return canonical_json_text(value).encode("utf-8", errors="strict")
    except BaseException as error:
        if isinstance(error, ContractV7Error):
            raise
        raise_stable_external(error, "encode canonical JSON")


def _reject_number(token: str) -> Any:
    raise ContractV7Error("E_JSON_NUMBER", "floating-point/non-finite JSON is forbidden", {"token": token})


def _pairs(pairs: List[Tuple[str, Any]]) -> OrderedDict:
    output: OrderedDict = OrderedDict()
    for key, value in pairs:
        require(key not in output, "E_JSON_KEY", "duplicate JSON key", {"key": key})
        output[key] = value
    return output


def parse_strict_json_bytes(raw: bytes) -> Any:
    require(not raw.startswith(b"\xef\xbb\xbf"), "E_BOM", "strict JSON forbids a UTF-8 BOM")
    try:
        text = raw.decode("utf-8", errors="strict")
        value = json.loads(
            text,
            object_pairs_hook=_pairs,
            parse_float=_reject_number,
            parse_constant=_reject_number,
        )
    except ContractV7Error:
        raise
    except UnicodeDecodeError as error:
        raise ContractV7Error("E_UTF8", "JSON is not valid UTF-8", {"offset": error.start})
    except (json.JSONDecodeError, ValueError, TypeError) as error:
        raise ContractV7Error("E_JSON_TYPE", "invalid strict JSON", {"exception_type": type(error).__name__})
    require(canonical_json_bytes(value) == raw, "E_JSON_ORDER", "JSON bytes are not in the unique canonical form")
    return value


def require_exact_keys(value: Mapping[str, Any], keys: Sequence[str]) -> None:
    actual = list(value.keys())
    require(actual == list(keys), "E_JSON_KEY" if set(actual) != set(keys) else "E_JSON_ORDER", "JSON keys differ from the exact contract", {"expected": list(keys), "actual": actual})


def frame(domain_tag: str, payload: bytes) -> bytes:
    require(isinstance(domain_tag, str) and bool(re.fullmatch(r"[a-z0-9][a-z0-9-]*", domain_tag)), "E_HASH_FRAME", "invalid domain tag")
    require(isinstance(payload, bytes), "E_HASH_FRAME", "framed payload must be bytes")
    return domain_tag.encode("ascii") + b"\x00" + len(payload).to_bytes(8, "big") + payload


def framed_sha256(domain_tag: str, payload: bytes) -> str:
    return hashlib.sha256(frame(domain_tag, payload)).hexdigest()


def raw_sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def file_sha256(path: Path) -> str:
    try:
        return raw_sha256(path.read_bytes())
    except BaseException as error:
        raise_stable_external(error, "read file for SHA-256")


PRIMARY_KEYS: Dict[str, Tuple[str, ...]] = {
    "数据/card-completeness.csv": ("card_completeness_id",),
    "数据/components.csv": ("component_id",),
    "数据/condition-sets.csv": ("condition_set_id",),
    "数据/derived-inputs.csv": ("derived_input_id",),
    "数据/derived-metrics.csv": ("derived_metric_id",),
    "数据/enums.csv": ("enum_value_id",),
    "数据/facts.csv": ("fact_id",),
    "数据/factor-requirements.csv": ("factor_requirement_id",),
    "数据/factor-target-bindings.csv": ("factor_target_binding_id",),
    "数据/field-requirements.csv": ("requirement_id",),
    "数据/fields.csv": ("field_id",),
    "数据/links.csv": ("link_id",),
    "数据/memory-levels.csv": ("memory_level_id",),
    "数据/object-relations.csv": ("object_relation_id",),
    "数据/objects.csv": ("object_id",),
    "数据/precision-paths.csv": ("precision_path_id",),
    "数据/schema-columns.csv": ("schema_column_id",),
    "数据/special-capabilities.csv": ("capability_id",),
    "数据/topologies.csv": ("topology_id",),
    "数据/vendors.csv": ("vendor_id",),
    "最小参考资料库/conflict-groups.csv": ("conflict_group_id",),
    "最小参考资料库/conflict-members.csv": ("conflict_member_id",),
    "最小参考资料库/fact-assertions.csv": ("assertion_id",),
    "最小参考资料库/requirement-evidence.csv": ("requirement_evidence_id",),
    "最小参考资料库/search-log.csv": ("search_id",),
    "最小参考资料库/search-results.csv": ("search_result_id",),
    "最小参考资料库/selection-members.csv": ("selection_member_id",),
    "最小参考资料库/selection-runs.csv": ("selection_run_id",),
    "最小参考资料库/source-coverage.csv": ("coverage_id",),
    "最小参考资料库/source-endpoints.csv": ("endpoint_id",),
    "最小参考资料库/source-families.csv": ("source_family_id",),
    "最小参考资料库/source-screening.csv": ("screening_id",),
    "最小参考资料库/source-selected-roles.csv": ("source_selected_role_id",),
    "最小参考资料库/sources.csv": ("source_id",),
    "审计/合同注册表/source-date-policy-v3.0.csv": ("source_date_rule_id",),
    "审计/合同注册表/legacy-requirement-disposition.csv": ("requirement_id",),
    "审计/合同注册表/legacy-requirement-reconciliation-events.csv": ("reconciliation_event_id",),
    "审计/合同注册表/scope-id-registry.csv": ("scope_allocation_id",),
    "审计/合同注册表/scope-object-mapping.csv": ("mapping_event_id",),
    "审计/合同注册表/canonical-fixtures.csv": ("fixture_id",),
    "审计/合同注册表/canonical-runtime-results.csv": ("runtime_result_id",),
}


def row_envelope(logical_path: str, header: Sequence[str], cells: Sequence[str], primary_keys: Sequence[str]) -> OrderedDict:
    require(len(header) == len(cells), "E_CSV_HEADER", "CSV row width differs from header")
    require(len(set(header)) == len(header), "E_CSV_HEADER", "CSV header has duplicate columns")
    values = dict(zip(header, cells))
    require(all(key in values for key in primary_keys), "E_CSV_HEADER", "logical primary key is absent")
    return OrderedDict((
        ("domain", "research-csv-row-v1"),
        ("table_path", logical_path),
        ("primary_key", [OrderedDict((("name", key), ("value", values[key]))) for key in primary_keys]),
        ("columns", [OrderedDict((("name", name), ("value", value))) for name, value in zip(header, cells)]),
    ))


def parse_csv_bytes(raw: bytes) -> Tuple[Tuple[str, ...], Tuple[Tuple[str, ...], ...]]:
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    try:
        text = raw.decode("utf-8", errors="strict")
        reader = csv.reader(io.StringIO(text, newline=""), strict=True)
        rows = list(reader)
    except UnicodeDecodeError as error:
        raise ContractV7Error("E_UTF8", "CSV is not valid UTF-8", {"offset": error.start})
    except csv.Error as error:
        raise ContractV7Error("E_CSV_PARSE", "CSV parser rejected the file", {"reason": str(error)})
    require(bool(rows), "E_CSV_HEADER", "CSV is empty")
    header = tuple(rows[0])
    require(bool(header) and all(header), "E_CSV_HEADER", "CSV header contains an empty column")
    require(len(set(header)) == len(header), "E_CSV_HEADER", "CSV header contains duplicate columns")
    data: List[Tuple[str, ...]] = []
    for ordinal, row in enumerate(rows[1:], start=1):
        require(len(row) == len(header), "E_CSV_HEADER", "CSV row width differs", {"data_row": ordinal})
        require(all("\r" not in cell and "\n" not in cell for cell in row), "E_CSV_NEWLINE", "multiline CSV cell is forbidden", {"data_row": ordinal})
        data.append(tuple(row))
    return header, tuple(data)


def canonical_csv_rowset(raw: bytes, semantic_path: str) -> bytes:
    require(semantic_path in PRIMARY_KEYS, "E_HASH_INPUT_CONTRACT", "SemanticPath has no frozen logical primary key", {"path": semantic_path})
    header, rows = parse_csv_bytes(raw)
    primary_keys = PRIMARY_KEYS[semantic_path]
    positions = []
    for key in primary_keys:
        require(key in header, "E_CSV_HEADER", "logical primary key is absent", {"key": key})
        positions.append(header.index(key))
    keyed: List[Tuple[Tuple[bytes, ...], OrderedDict]] = []
    seen = set()
    for row in rows:
        key = tuple(row[index] for index in positions)
        require(key not in seen, "E_DUPLICATE", "CSV logical primary key is duplicated", {"key": list(key)})
        seen.add(key)
        keyed.append((tuple(value.encode("utf-8") for value in key), row_envelope(semantic_path, header, row, primary_keys)))
    keyed.sort(key=lambda item: item[0])
    return canonical_json_bytes([envelope for _, envelope in keyed])


def canonical_hash_for(raw: bytes, semantic_path: str, domain_tag: Optional[str]) -> Optional[str]:
    if domain_tag is None:
        return None
    if domain_tag == "rowset-v1":
        payload = canonical_csv_rowset(raw, semantic_path)
    else:
        parsed = parse_strict_json_bytes(raw)
        payload = canonical_json_bytes(parsed)
    return framed_sha256(domain_tag, payload)


@dataclass(frozen=True)
class SemanticOracle:
    semantic_path: str
    envelope_bytes: int
    singleton_bytes: int
    row_v1_sha256: str
    rowset_v1_sha256: str


SEMANTIC_PATH_ORACLES: Tuple[SemanticOracle, ...] = (
    SemanticOracle("数据/fields.csv", 859, 861, "c9332d894c520577a49b7479652139dc9f6de35df8591481bd25e7e1b9a4c10f", "33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2"),
    SemanticOracle("审计/事务/TX-TEST/inputs/base/数据/fields.csv", 893, 895, "8db42271feef643745b699bb303622c09a2c22038c7415f370dd059fbea7aa2a", "b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6"),
    SemanticOracle("审计/事务/TX-TEST/inputs/post/数据/fields.csv", 893, 895, "d605741c1806deb881fa6631bc72d401cc1b8a444503db4cbb9557ffaf8bd91d", "d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a"),
)


def verify_semantic_path_oracles(fields_csv: Path) -> Tuple[SemanticOracle, ...]:
    try:
        raw = fields_csv.read_bytes()
    except BaseException as error:
        raise_stable_external(error, "read fields oracle CSV")
    header, rows = parse_csv_bytes(raw)
    require(bool(rows), "E_CSV_HEADER", "fields oracle needs a data row")
    observed: List[SemanticOracle] = []
    for expected in SEMANTIC_PATH_ORACLES:
        envelope = canonical_json_bytes(row_envelope(expected.semantic_path, header, rows[0], ("field_id",)))
        singleton = canonical_json_bytes([parse_strict_json_bytes(envelope)])
        observed.append(SemanticOracle(expected.semantic_path, len(envelope), len(singleton), framed_sha256("row-v1", envelope), framed_sha256("rowset-v1", singleton)))
    require(tuple(observed) == SEMANTIC_PATH_ORACLES, "E_HASH_INPUT_CONTRACT", "SemanticPath oracle mismatch")
    return tuple(observed)

