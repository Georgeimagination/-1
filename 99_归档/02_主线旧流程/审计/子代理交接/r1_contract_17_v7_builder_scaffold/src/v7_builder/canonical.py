"""Strict canonical JSON and SemanticPath-aware row hashing."""

import csv
import hashlib
import json
import re
from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence, Tuple

from .errors import ContractV7Error, require


def _validate_unicode_scalar(value: str) -> None:
    for character in value:
        scalar = ord(character)
        if 0xD800 <= scalar <= 0xDFFF:
            raise ContractV7Error("E_SURROGATE", "string contains a surrogate scalar")


def _escape_json_string(value: str) -> str:
    _validate_unicode_scalar(value)
    output: List[str] = ['"']
    for character in value:
        scalar = ord(character)
        if character == '"':
            output.append('\\"')
        elif character == "\\":
            output.append("\\\\")
        elif scalar <= 0x1F:
            output.append("\\u%04x" % scalar)
        else:
            output.append(character)
    output.append('"')
    return "".join(output)


def strict_json_text(value: Any) -> str:
    """Serialize without whitespace while preserving mapping insertion order.

    The writer deliberately avoids Python's short control-character escapes so
    U+0000..U+001F are always emitted as lowercase ``\\u00xx`` sequences.
    """

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
        return _escape_json_string(value)
    if isinstance(value, (list, tuple)):
        return "[" + ",".join(strict_json_text(item) for item in value) + "]"
    if isinstance(value, Mapping):
        parts: List[str] = []
        seen = set()
        for key, item in value.items():
            require(isinstance(key, str), "E_JSON_KEY", "JSON keys must be strings")
            require(key not in seen, "E_JSON_KEY", "duplicate JSON key", {"key": key})
            seen.add(key)
            parts.append(_escape_json_string(key) + ":" + strict_json_text(item))
        return "{" + ",".join(parts) + "}"
    raise ContractV7Error(
        "E_JSON_TYPE",
        "unsupported canonical JSON value",
        {"python_type": type(value).__name__},
    )


def strict_json_bytes(value: Any) -> bytes:
    return strict_json_text(value).encode("utf-8")


def _reject_float(token: str) -> Any:
    raise ContractV7Error("E_JSON_NUMBER", "floating-point JSON is forbidden", {"token": token})


def _object_from_pairs(pairs: List[Tuple[str, Any]]) -> OrderedDict:
    result: OrderedDict = OrderedDict()
    for key, value in pairs:
        if key in result:
            raise ContractV7Error("E_JSON_KEY", "duplicate JSON key", {"key": key})
        result[key] = value
    return result


def parse_strict_json_bytes(raw: bytes) -> Any:
    if raw.startswith(b"\xef\xbb\xbf"):
        raise ContractV7Error("E_BOM", "canonical JSON must not contain a UTF-8 BOM")
    try:
        text = raw.decode("utf-8", errors="strict")
    except UnicodeDecodeError as error:
        raise ContractV7Error("E_UTF8", "invalid UTF-8 JSON", {"reason": str(error)})
    try:
        value = json.loads(
            text,
            object_pairs_hook=_object_from_pairs,
            parse_float=_reject_float,
            parse_constant=_reject_float,
        )
    except ContractV7Error:
        raise
    except (json.JSONDecodeError, ValueError) as error:
        raise ContractV7Error("E_JSON_TYPE", "invalid strict JSON", {"reason": str(error)})
    # Canonical inputs must already have the unique writer's exact bytes.
    require(
        strict_json_bytes(value) == raw,
        "E_JSON_ORDER",
        "JSON bytes are not in canonical key/order/escape form",
    )
    return value


def require_exact_keys(mapping: Mapping[str, Any], keys: Sequence[str]) -> None:
    actual = list(mapping.keys())
    require(
        actual == list(keys),
        "E_JSON_KEY" if set(actual) != set(keys) else "E_JSON_ORDER",
        "JSON keys do not match the exact schema",
        {"expected": list(keys), "actual": actual},
    )


def frame(domain_tag: str, payload: bytes) -> bytes:
    require(
        isinstance(domain_tag, str)
        and bool(re.fullmatch(r"[a-z0-9][a-z0-9-]*", domain_tag)),
        "E_HASH_FRAME",
        "domain tag must be a lowercase ASCII contract token",
    )
    require(isinstance(payload, bytes), "E_HASH_FRAME", "framed payload must be bytes")
    _validate_unicode_scalar(domain_tag)
    return domain_tag.encode("utf-8") + b"\x00" + len(payload).to_bytes(8, "big") + payload


def framed_sha256(domain_tag: str, payload: bytes) -> str:
    return hashlib.sha256(frame(domain_tag, payload)).hexdigest()


def raw_sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def file_sha256(path: Path) -> str:
    return raw_sha256(path.read_bytes())


def canonical_row_envelope(
    table_path: str,
    headers: Sequence[str],
    cells: Sequence[str],
    primary_key_names: Sequence[str],
    row_domain: str = "research-csv-row-v1",
) -> OrderedDict:
    require(len(headers) == len(cells), "E_CSV_HEADER", "header/cell length mismatch")
    require(len(set(headers)) == len(headers), "E_CSV_HEADER", "duplicate CSV header")
    values = dict(zip(headers, cells))
    for primary_key_name in primary_key_names:
        require(primary_key_name in values, "E_CSV_HEADER", "primary key is absent from header")
    primary_key = [
        OrderedDict((("name", name), ("value", values[name]))) for name in primary_key_names
    ]
    columns = [
        OrderedDict((("name", name), ("value", value)))
        for name, value in zip(headers, cells)
    ]
    return OrderedDict(
        (
            ("domain", row_domain),
            ("table_path", table_path),
            ("primary_key", primary_key),
            ("columns", columns),
        )
    )


@dataclass(frozen=True)
class RowOracle:
    semantic_path: str
    envelope_payload_bytes: int
    singleton_payload_bytes: int
    row_v1_sha256: str
    rowset_v1_sha256: str


def row_oracle(envelope: Mapping[str, Any]) -> RowOracle:
    envelope_bytes = strict_json_bytes(envelope)
    singleton_bytes = strict_json_bytes([envelope])
    return RowOracle(
        semantic_path=str(envelope["table_path"]),
        envelope_payload_bytes=len(envelope_bytes),
        singleton_payload_bytes=len(singleton_bytes),
        row_v1_sha256=framed_sha256("row-v1", envelope_bytes),
        rowset_v1_sha256=framed_sha256("rowset-v1", singleton_bytes),
    )


def read_first_csv_row(path: Path) -> Tuple[List[str], List[str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle, strict=True)
        try:
            header = next(reader)
            row = next(reader)
        except StopIteration:
            raise ContractV7Error("E_CSV_HEADER", "CSV needs a header and one data row")
    require(len(header) == len(row), "E_CSV_HEADER", "first row has wrong column count")
    return header, row


def build_fields_semantic_path_oracles(fields_csv: Path) -> List[RowOracle]:
    header, row = read_first_csv_row(fields_csv)
    paths = (
        "数据/fields.csv",
        "审计/事务/TX-TEST/inputs/base/数据/fields.csv",
        "审计/事务/TX-TEST/inputs/post/数据/fields.csv",
    )
    return [
        row_oracle(canonical_row_envelope(path, header, row, ("field_id",)))
        for path in paths
    ]


SEMANTIC_PATH_EXPECTED: Tuple[RowOracle, ...] = (
    RowOracle(
        "数据/fields.csv",
        859,
        861,
        "c9332d894c520577a49b7479652139dc9f6de35df8591481bd25e7e1b9a4c10f",
        "33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2",
    ),
    RowOracle(
        "审计/事务/TX-TEST/inputs/base/数据/fields.csv",
        893,
        895,
        "8db42271feef643745b699bb303622c09a2c22038c7415f370dd059fbea7aa2a",
        "b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6",
    ),
    RowOracle(
        "审计/事务/TX-TEST/inputs/post/数据/fields.csv",
        893,
        895,
        "d605741c1806deb881fa6631bc72d401cc1b8a444503db4cbb9557ffaf8bd91d",
        "d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a",
    ),
)


def validate_fields_semantic_path_oracles(fields_csv: Path) -> List[RowOracle]:
    observed = build_fields_semantic_path_oracles(fields_csv)
    require(
        tuple(observed) == SEMANTIC_PATH_EXPECTED,
        "E_HASH_INPUT_CONTRACT",
        "SemanticPath row-v1/rowset-v1 oracle mismatch",
        {
            "expected": [item.__dict__ for item in SEMANTIC_PATH_EXPECTED],
            "observed": [item.__dict__ for item in observed],
        },
    )
    return observed
