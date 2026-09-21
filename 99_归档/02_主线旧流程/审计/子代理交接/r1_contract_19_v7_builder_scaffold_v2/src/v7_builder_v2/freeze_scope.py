"""Raw-only 77-row freeze parser and deterministic 49-scope constructor."""

import csv
import hashlib
import io
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Mapping, Sequence, Tuple

from .canonical import canonical_json_bytes, framed_sha256, row_envelope
from .errors import ContractV7Error, require, raise_stable_external


FREEZE_RELATIVE_PATH = "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv"
FREEZE_BYTES = 55224
FREEZE_SHA256 = "df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea"
FREEZE_HEADER: Tuple[str, ...] = (
    "freeze_row_id", "early_candidate_id", "existing_formal_object_id", "vendor",
    "canonical_chip_name", "object_layer", "time_bucket", "time_boundary",
    "availability_at_identity_cutoff", "training_inference_relevance", "inclusion_status",
    "counts_toward_chip_completion", "silicon_design_group", "counting_method",
    "related_nonchip_products", "exclusion_reason", "official_source_title", "official_source_url",
    "official_source_locator", "identity_checked_date", "author_review_status",
    "independent_review_status", "freeze_state", "notes",
)
ACTIVE_HEADER: Tuple[str, ...] = ("厂商", "芯片对象", "层级", "角色", "共享设计组", "一手身份来源")
POST_ACTIVE_HEADER: Tuple[str, ...] = ("scope_id",) + ACTIVE_HEADER


@dataclass(frozen=True)
class FreezeArchive:
    rows: Tuple[Dict[str, str], ...]
    raw_sha256: str
    byte_length: int
    crlf_count: int
    lf_only_count: int
    bare_cr_count: int

    @property
    def counted_rows(self) -> Tuple[Dict[str, str], ...]:
        return tuple(row for row in self.rows if row["counts_toward_chip_completion"] == "true")


@dataclass(frozen=True)
class ScopeRow:
    scope_id: str
    freeze_row_id: str
    active_cells: Tuple[str, ...]
    active_list_row_canonical_sha256: str
    freeze_row: Dict[str, str]


def parse_raw_freeze_archive(path: Path) -> FreezeArchive:
    try:
        raw = path.read_bytes()
    except BaseException as error:
        raise_stable_external(error, "read raw freeze archive")
    digest = hashlib.sha256(raw).hexdigest()
    require((len(raw), digest) == (FREEZE_BYTES, FREEZE_SHA256), "E_FREEZE_ARCHIVE_RAW_DRIFT", "freeze archive raw bytes differ", {"expected_bytes": FREEZE_BYTES, "actual_bytes": len(raw), "expected_sha256": FREEZE_SHA256, "actual_sha256": digest})
    require(raw.startswith(b"\xef\xbb\xbf") and b"\xef\xbb\xbf" not in raw[3:], "E_BOM", "freeze archive must contain exactly one leading BOM")
    body = raw[3:]
    crlf = body.count(b"\r\n")
    lf_only = body.count(b"\n") - crlf
    bare_cr = body.count(b"\r") - crlf
    require((crlf, lf_only, bare_cr) == (64, 14, 0), "E_FREEZE_ARCHIVE_RAW_DRIFT", "freeze archive record separators differ", {"actual": [crlf, lf_only, bare_cr]})
    try:
        text = body.decode("utf-8", errors="strict")
        parsed = list(csv.reader(io.StringIO(text, newline=""), strict=True))
    except UnicodeDecodeError as error:
        raise ContractV7Error("E_UTF8", "freeze archive is not UTF-8", {"offset": error.start})
    except csv.Error as error:
        raise ContractV7Error("E_CSV_PARSE", "freeze archive violates RFC 4180", {"reason": str(error)})
    require(bool(parsed) and tuple(parsed[0]) == FREEZE_HEADER, "E_CSV_HEADER", "freeze archive header differs")
    rows: List[Dict[str, str]] = []
    for ordinal, cells in enumerate(parsed[1:], start=1):
        require(len(cells) == 24, "E_CSV_HEADER", "freeze row width differs", {"data_row": ordinal})
        require(all("\r" not in cell and "\n" not in cell for cell in cells), "E_CSV_NEWLINE", "freeze archive has a multiline cell", {"data_row": ordinal})
        rows.append(dict(zip(FREEZE_HEADER, cells)))
    require(len(rows) == 77, "E_REQUIRED_SET", "freeze archive must contain 77 rows")
    ids = [row["freeze_row_id"] for row in rows]
    require(all(ids) and len(set(ids)) == 77, "E_DUPLICATE", "freeze_row_id is empty or duplicated")
    for row in rows:
        require(row["counts_toward_chip_completion"] in ("true", "false"), "E_JSON_TYPE", "freeze bool is not lowercase")
    require(sum(row["counts_toward_chip_completion"] == "true" for row in rows) == 49, "E_REQUIRED_SET", "freeze archive must count exactly 49 scopes")
    return FreezeArchive(tuple(rows), digest, len(raw), crlf, lf_only, bare_cr)


def _markdown_cells(line: str) -> Tuple[str, ...]:
    require(line.startswith("|") and line.endswith("|"), "E_MARKDOWN_PIPE", "Markdown row requires edge pipes")
    output: List[str] = []
    current: List[str] = []
    index = 1
    while index < len(line) - 1:
        if line[index] == "\\" and index + 1 < len(line) - 1 and line[index + 1] == "|":
            current.extend(("\\", "|"))
            index += 2
        elif line[index] == "|":
            cell = "".join(current)
            output.append(cell[1:] if cell.startswith(" ") and not cell.endswith(" ") else cell[1:-1] if cell.startswith(" ") and cell.endswith(" ") else cell[:-1] if cell.endswith(" ") else cell)
            current = []
            index += 1
        else:
            current.append(line[index])
            index += 1
    cell = "".join(current)
    output.append(cell[1:] if cell.startswith(" ") and not cell.endswith(" ") else cell[1:-1] if cell.startswith(" ") and cell.endswith(" ") else cell[:-1] if cell.endswith(" ") else cell)
    return tuple(output)


def parse_active_scope_markdown(path: Path) -> Tuple[Tuple[str, ...], ...]:
    try:
        text = path.read_text(encoding="utf-8", errors="strict")
    except BaseException as error:
        raise_stable_external(error, "read active scope Markdown")
    lines = text.splitlines()
    try:
        cursor = lines.index("## 正式名单") + 1
    except ValueError:
        raise ContractV7Error("E_MARKDOWN_PIPE", "exact 正式名单 heading is absent")
    while cursor < len(lines) and lines[cursor] == "":
        cursor += 1
    require(cursor + 1 < len(lines), "E_MARKDOWN_PIPE", "active scope table is absent")
    require(_markdown_cells(lines[cursor]) == ACTIVE_HEADER, "E_CSV_HEADER", "current active scope table must have six columns")
    separator = _markdown_cells(lines[cursor + 1])
    require(len(separator) == 6 and all(re.fullmatch(r":?-{3,}:?", cell) for cell in separator), "E_MARKDOWN_PIPE", "active scope separator is invalid")
    output = []
    cursor += 2
    while cursor < len(lines) and lines[cursor].startswith("|"):
        cells = _markdown_cells(lines[cursor])
        require(len(cells) == 6, "E_MARKDOWN_PIPE", "active scope row width differs")
        output.append(cells)
        cursor += 1
    require(len(output) == 49 and len(set(output)) == 49, "E_REQUIRED_SET", "active scope list is not 49 unique six-tuples")
    return tuple(output)


def _freeze_active_tuple(row: Mapping[str, str]) -> Tuple[str, ...]:
    layer = {"die": "裸片（die）", "package": "单芯片封装（package）"}.get(row["object_layer"])
    role = {"include_main": "主样本", "include_historical_anchor": "历史锚点"}.get(row["inclusion_status"])
    require(layer is not None and role is not None, "E_REQUIRED_SET", "counted freeze row has unsupported layer/status")
    return (row["vendor"], row["canonical_chip_name"], layer, role, "`%s`" % row["silicon_design_group"], "[%s](%s)" % (row["official_source_title"], row["official_source_url"]))


def construct_49_scopes(freeze: FreezeArchive, active_rows: Sequence[Tuple[str, ...]]) -> Tuple[ScopeRow, ...]:
    require(len(freeze.counted_rows) == len(active_rows) == 49, "E_REQUIRED_SET", "scope constructor needs 49/49 inputs")
    by_tuple: Dict[Tuple[str, ...], Dict[str, str]] = {}
    for row in freeze.counted_rows:
        key = _freeze_active_tuple(row)
        require(key not in by_tuple, "E_DUPLICATE", "freeze six-tuple is duplicated")
        by_tuple[key] = row
    require(set(active_rows) == set(by_tuple), "E_SCOPE_CONSTRUCTOR", "active and frozen six-tuple sets differ")
    output = []
    for ordinal, cells in enumerate(active_rows, start=1):
        scope_id = "SCOPE-%04d" % ordinal
        freeze_row = by_tuple[cells]
        envelope = row_envelope("清单/训练与推理芯片名单.md", POST_ACTIVE_HEADER, (scope_id,) + tuple(cells), ("scope_id",))
        # Markdown rows use a distinct row envelope domain cell.
        envelope["domain"] = "active-scope-markdown-row-v1"
        digest = framed_sha256("row-v1", canonical_json_bytes(envelope))
        output.append(ScopeRow(scope_id, freeze_row["freeze_row_id"], tuple(cells), digest, freeze_row))
    require(next(row for row in output if row.scope_id == "SCOPE-0001").freeze_row_id == "FREEZE-NV-001", "E_SCOPE_CONSTRUCTOR", "GA100 freeze/scope binding differs")
    return tuple(output)

