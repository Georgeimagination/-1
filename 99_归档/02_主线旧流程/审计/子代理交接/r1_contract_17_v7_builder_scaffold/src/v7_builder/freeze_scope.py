"""Raw-only freeze import and the unique 49-scope constructor."""

import csv
import hashlib
import io
import re
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple

from .canonical import canonical_row_envelope, row_oracle
from .errors import ContractV7Error, require


FREEZE_RELATIVE_PATH = "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv"
ACTIVE_SCOPE_RELATIVE_PATH = "清单/训练与推理芯片名单.md"
FREEZE_BYTE_LENGTH = 55224
FREEZE_SHA256 = "df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea"
FREEZE_HEADER: Tuple[str, ...] = (
    "freeze_row_id",
    "early_candidate_id",
    "existing_formal_object_id",
    "vendor",
    "canonical_chip_name",
    "object_layer",
    "time_bucket",
    "time_boundary",
    "availability_at_identity_cutoff",
    "training_inference_relevance",
    "inclusion_status",
    "counts_toward_chip_completion",
    "silicon_design_group",
    "counting_method",
    "related_nonchip_products",
    "exclusion_reason",
    "official_source_title",
    "official_source_url",
    "official_source_locator",
    "identity_checked_date",
    "author_review_status",
    "independent_review_status",
    "freeze_state",
    "notes",
)
ACTIVE_HEADER: Tuple[str, ...] = (
    "厂商",
    "芯片对象",
    "层级",
    "角色",
    "共享设计组",
    "一手身份来源",
)
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
        return tuple(
            row for row in self.rows if row["counts_toward_chip_completion"] == "true"
        )


@dataclass(frozen=True)
class ScopeRow:
    scope_id: str
    freeze_row_id: str
    active_cells: Tuple[str, ...]
    active_list_row_canonical_sha256: str
    freeze_row: Dict[str, str]


@dataclass(frozen=True)
class MappingProjection:
    freeze_row_id: str
    scope_id: str
    mapping_event_seq: int
    formal_object_id: str
    proposed_formal_object_id: str
    mapping_status: str
    approval_status: str


def parse_raw_freeze_archive(path: Path) -> FreezeArchive:
    raw = path.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    require(
        len(raw) == FREEZE_BYTE_LENGTH and digest == FREEZE_SHA256,
        "E_FREEZE_ARCHIVE_RAW_DRIFT",
        "freeze archive raw bytes do not match the v7 contract",
        {
            "expected_byte_length": FREEZE_BYTE_LENGTH,
            "actual_byte_length": len(raw),
            "expected_sha256": FREEZE_SHA256,
            "actual_sha256": digest,
        },
    )
    require(raw.startswith(b"\xef\xbb\xbf"), "E_BOM", "freeze archive requires one BOM")
    body = raw[3:]
    require(b"\xef\xbb\xbf" not in body, "E_BOM", "freeze archive contains a second BOM")
    crlf_count = body.count(b"\r\n")
    lf_only_count = body.count(b"\n") - crlf_count
    bare_cr_count = body.count(b"\r") - crlf_count
    require(
        (crlf_count, lf_only_count, bare_cr_count) == (64, 14, 0),
        "E_FREEZE_ARCHIVE_RAW_DRIFT",
        "freeze archive record separators drifted",
        {
            "expected": [64, 14, 0],
            "actual": [crlf_count, lf_only_count, bare_cr_count],
        },
    )
    try:
        text = body.decode("utf-8", errors="strict")
    except UnicodeDecodeError as error:
        raise ContractV7Error("E_UTF8", "freeze archive is not valid UTF-8", {"reason": str(error)})
    reader = csv.reader(io.StringIO(text, newline=""), strict=True)
    try:
        header = tuple(next(reader))
    except StopIteration:
        raise ContractV7Error("E_CSV_HEADER", "freeze archive is empty")
    require(header == FREEZE_HEADER, "E_CSV_HEADER", "freeze archive header drifted")
    rows: List[Dict[str, str]] = []
    for ordinal, cells in enumerate(reader, start=1):
        require(len(cells) == len(FREEZE_HEADER), "E_CSV_HEADER", "freeze row width mismatch")
        require(
            all("\r" not in cell and "\n" not in cell for cell in cells),
            "E_CSV_NEWLINE",
            "freeze archive contains a multiline cell",
            {"data_row": ordinal},
        )
        rows.append(dict(zip(FREEZE_HEADER, cells)))
    require(len(rows) == 77, "E_REQUIRED_SET", "freeze archive must have 77 data rows")
    freeze_ids = [row["freeze_row_id"] for row in rows]
    require(all(freeze_ids), "E_REQUIRED_SET", "freeze_row_id must be non-empty")
    require(len(set(freeze_ids)) == 77, "E_DUPLICATE", "freeze_row_id must be unique")
    for row in rows:
        require(
            row["counts_toward_chip_completion"] in ("true", "false"),
            "E_JSON_TYPE",
            "freeze boolean must be lowercase true/false",
            {"freeze_row_id": row["freeze_row_id"]},
        )
    require(
        sum(row["counts_toward_chip_completion"] == "true" for row in rows) == 49,
        "E_REQUIRED_SET",
        "freeze archive must contain exactly 49 counted rows",
    )
    return FreezeArchive(
        rows=tuple(rows),
        raw_sha256=digest,
        byte_length=len(raw),
        crlf_count=crlf_count,
        lf_only_count=lf_only_count,
        bare_cr_count=bare_cr_count,
    )


def _split_markdown_row(line: str) -> List[str]:
    require(line.startswith("|") and line.endswith("|"), "E_MARKDOWN_PIPE", "row needs edge pipes")
    cells: List[str] = []
    current: List[str] = []
    index = 1
    while index < len(line) - 1:
        character = line[index]
        if character == "\\" and index + 1 < len(line) - 1 and line[index + 1] == "|":
            current.extend(("\\", "|"))
            index += 2
            continue
        if character == "|":
            cell = "".join(current)
            if cell.startswith(" "):
                cell = cell[1:]
            if cell.endswith(" "):
                cell = cell[:-1]
            cells.append(cell)
            current = []
        else:
            current.append(character)
        index += 1
    cell = "".join(current)
    if cell.startswith(" "):
        cell = cell[1:]
    if cell.endswith(" "):
        cell = cell[:-1]
    cells.append(cell)
    return cells


def parse_active_scope_markdown(path: Path) -> Tuple[Tuple[str, ...], ...]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    try:
        heading_index = lines.index("## 正式名单")
    except ValueError:
        raise ContractV7Error("E_MARKDOWN_PIPE", "missing exact 正式名单 heading")
    cursor = heading_index + 1
    while cursor < len(lines) and lines[cursor] == "":
        cursor += 1
    require(cursor + 1 < len(lines), "E_MARKDOWN_PIPE", "active scope table is missing")
    header = tuple(_split_markdown_row(lines[cursor]))
    require(header == ACTIVE_HEADER, "E_CSV_HEADER", "active scope list must remain six columns")
    separator = _split_markdown_row(lines[cursor + 1])
    require(
        len(separator) == len(ACTIVE_HEADER)
        and all(re.fullmatch(r":?-{3,}:?", item) for item in separator),
        "E_MARKDOWN_PIPE",
        "invalid active scope table separator",
    )
    rows: List[Tuple[str, ...]] = []
    cursor += 2
    while cursor < len(lines) and lines[cursor].startswith("|"):
        cells = tuple(_split_markdown_row(lines[cursor]))
        require(len(cells) == len(ACTIVE_HEADER), "E_MARKDOWN_PIPE", "active row width mismatch")
        rows.append(cells)
        cursor += 1
    require(len(rows) == 49, "E_REQUIRED_SET", "active scope list must contain 49 rows")
    require(len(set(rows)) == len(rows), "E_DUPLICATE", "active scope row tuple is duplicated")
    return tuple(rows)


def freeze_active_tuple(row: Mapping[str, str]) -> Tuple[str, ...]:
    layer = {"die": "裸片（die）", "package": "单芯片封装（package）"}.get(
        row["object_layer"]
    )
    role = {
        "include_main": "主样本",
        "include_historical_anchor": "历史锚点",
    }.get(row["inclusion_status"])
    require(layer is not None, "E_REQUIRED_SET", "unsupported counted object layer")
    require(role is not None, "E_REQUIRED_SET", "unsupported counted inclusion status")
    return (
        row["vendor"],
        row["canonical_chip_name"],
        layer,
        role,
        "`" + row["silicon_design_group"] + "`",
        "[" + row["official_source_title"] + "](" + row["official_source_url"] + ")",
    )


def construct_49_scopes(
    freeze: FreezeArchive,
    active_rows: Sequence[Tuple[str, ...]],
) -> Tuple[ScopeRow, ...]:
    counted = freeze.counted_rows
    require(len(counted) == len(active_rows) == 49, "E_REQUIRED_SET", "scope inputs must be 49/49")
    by_tuple: Dict[Tuple[str, ...], Dict[str, str]] = {}
    for row in counted:
        key = freeze_active_tuple(row)
        require(key not in by_tuple, "E_DUPLICATE", "freeze constructor tuple is duplicated")
        by_tuple[key] = row
    require(set(by_tuple) == set(active_rows), "E_REQUIRED_SET", "freeze/active six-tuples differ")
    scopes: List[ScopeRow] = []
    for ordinal, active_cells in enumerate(active_rows, start=1):
        freeze_row = by_tuple[tuple(active_cells)]
        scope_id = "SCOPE-%04d" % ordinal
        post_cells = (scope_id,) + tuple(active_cells)
        envelope = canonical_row_envelope(
            ACTIVE_SCOPE_RELATIVE_PATH,
            POST_ACTIVE_HEADER,
            post_cells,
            ("scope_id",),
            row_domain="active-scope-markdown-row-v1",
        )
        scopes.append(
            ScopeRow(
                scope_id=scope_id,
                freeze_row_id=freeze_row["freeze_row_id"],
                active_cells=tuple(active_cells),
                active_list_row_canonical_sha256=row_oracle(envelope).row_v1_sha256,
                freeze_row=dict(freeze_row),
            )
        )
    require(
        scopes[0].freeze_row_id == "FREEZE-NV-001" and scopes[0].scope_id == "SCOPE-0001",
        "E_REQUIRED_SET",
        "GA100 must map to SCOPE-0001",
    )
    return tuple(scopes)


def _read_csv_dicts(path: Path) -> List[Dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle, strict=True))


def build_initial_mapping_projections(
    scopes: Sequence[ScopeRow],
    objects_csv: Path,
    completeness_csv: Path,
) -> Tuple[MappingProjection, ...]:
    objects = _read_csv_dicts(objects_csv)
    object_counts = Counter(row["object_id"] for row in objects)
    identities = {
        row["object_id"]
        for row in _read_csv_dicts(completeness_csv)
        if row.get("domain") == "identity"
    }
    projections: List[MappingProjection] = []
    for scope in scopes:
        existing = scope.freeze_row["existing_formal_object_id"]
        if existing:
            require(object_counts[existing] == 1, "E_REQUIRED_SET", "formal object join is not exact")
        if existing and existing in identities:
            formal = existing
            proposed = ""
            status = "mapped"
            approval = "approved"
        elif scope.freeze_row_id == "FREEZE-NV-002":
            require(existing == "OBJ-NVIDIA-GH100-DIE", "E_REQUIRED_SET", "GH100 proposed ID drift")
            formal = ""
            proposed = existing
            status = "pending_identity_review"
            approval = "needs_resolution"
        elif scope.freeze_row_id == "FREEZE-NV-001":
            require(existing == "", "E_REQUIRED_SET", "GA100 archive existing ID must be empty")
            formal = ""
            proposed = "OBJ-NVIDIA-GA100-DIE"
            status = "pending_formal_object_create"
            approval = "needs_resolution"
        else:
            require(existing == "", "E_REQUIRED_SET", "unexpected object without identity")
            formal = ""
            proposed = ""
            status = "unmapped"
            approval = "approved"
        projections.append(
            MappingProjection(
                freeze_row_id=scope.freeze_row_id,
                scope_id=scope.scope_id,
                mapping_event_seq=1,
                formal_object_id=formal,
                proposed_formal_object_id=proposed,
                mapping_status=status,
                approval_status=approval,
            )
        )
    require(
        Counter(item.mapping_status for item in projections)
        == Counter({"mapped": 9, "pending_identity_review": 1, "pending_formal_object_create": 1, "unmapped": 38}),
        "E_REQUIRED_SET",
        "initial mapping distribution drifted",
    )
    return tuple(projections)

