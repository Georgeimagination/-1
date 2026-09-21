#!/usr/bin/env python3
"""Build the deterministic contract-migration payload without touching formal files."""

from __future__ import annotations

import csv
import re
from pathlib import Path


STAGING = Path(__file__).resolve().parents[1]
MAIN = STAGING.parents[2]
PAYLOAD = STAGING / "formal_payload"


def read_csv(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames is None:
            raise ValueError(f"missing CSV header: {path}")
        return list(reader.fieldnames), list(reader)


def write_formal_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            extrasaction="raise",
            quoting=csv.QUOTE_ALL,
            lineterminator="\r\n",
        )
        writer.writeheader()
        writer.writerows(rows)


def write_audit_csv(path: Path, fieldnames: list[str], rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            extrasaction="raise",
            quoting=csv.QUOTE_ALL,
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)


def parse_markdown_table(lines: list[str], heading: str) -> tuple[int, int, list[str], list[list[str]]]:
    heading_index = lines.index(heading)
    header_index = next(i for i in range(heading_index + 1, len(lines)) if lines[i].startswith("|"))

    def split_row(line: str) -> list[str]:
        if not (line.startswith("|") and line.endswith("|")):
            raise ValueError(f"not a Markdown table row: {line!r}")
        cells = line[1:-1].split("|")
        result: list[str] = []
        for cell in cells:
            if cell.startswith(" ") and cell.endswith(" ") and len(cell) >= 2:
                cell = cell[1:-1]
            result.append(cell)
        return result

    header = split_row(lines[header_index])
    separator = split_row(lines[header_index + 1])
    if len(separator) != len(header) or any(not re.fullmatch(r":?-{3,}:?", cell) for cell in separator):
        raise ValueError("invalid Markdown table separator")
    rows: list[list[str]] = []
    end_index = header_index + 2
    while end_index < len(lines) and lines[end_index].startswith("|"):
        row = split_row(lines[end_index])
        if len(row) != len(header):
            raise ValueError("Markdown table width mismatch")
        rows.append(row)
        end_index += 1
    return header_index, end_index, header, rows


def migrate_scope_registry() -> list[dict[str, str]]:
    source_path = MAIN / "清单" / "训练与推理芯片名单.md"
    target_path = PAYLOAD / "清单" / "训练与推理芯片名单.md"
    text = source_path.read_text(encoding="utf-8-sig")
    newline = "\r\n" if "\r\n" in text else "\n"
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    header_index, end_index, header, rows = parse_markdown_table(lines, "## 正式名单")
    expected_header = ["厂商", "芯片对象", "层级", "角色", "共享设计组", "一手身份来源"]
    if header != expected_header or len(rows) != 49:
        raise ValueError(f"unexpected frozen-scope table: header={header!r}; rows={len(rows)}")

    freeze_header, freeze_rows = read_csv(
        MAIN / "审计" / "归档" / "芯片名单冻结_2026-08-17" / "训练推理芯片名单冻结.csv"
    )
    del freeze_header
    included = [row for row in freeze_rows if row["counts_toward_chip_completion"] == "true"]
    if len(included) != 49:
        raise ValueError(f"archive freeze registry has {len(included)} included rows, expected 49")

    object_header, objects = read_csv(MAIN / "数据" / "objects.csv")
    del object_header
    object_by_id = {row["object_id"]: row for row in objects}
    scope_header, scope_rows = read_csv(MAIN / "审计" / "训练推理芯片主线对象范围.csv")
    del scope_header
    scope_by_id = {row["object_id"]: row for row in scope_rows}

    audit_rows: list[dict[str, str]] = []
    new_rows: list[list[str]] = []
    for index, (display, frozen) in enumerate(zip(rows, included), start=1):
        display_vendor, display_name, display_layer, display_role, display_group, _ = display
        if display_vendor != frozen["vendor"] or display_name != frozen["canonical_chip_name"]:
            raise ValueError(
                f"frozen row order mismatch at {index}: markdown={display_vendor}/{display_name}; "
                f"archive={frozen['vendor']}/{frozen['canonical_chip_name']}"
            )
        if display_group.strip("`") != frozen["silicon_design_group"]:
            raise ValueError(f"shared design group mismatch at frozen row {index}")
        expected_layer = {"die": "裸片（die）", "package": "单芯片封装（package）"}[frozen["object_layer"]]
        if display_layer != expected_layer:
            raise ValueError(f"object layer mismatch at frozen row {index}")
        expected_role = {"include_main": "主样本", "include_historical_anchor": "历史锚点"}[frozen["inclusion_status"]]
        if display_role != expected_role:
            raise ValueError(f"role mismatch at frozen row {index}")

        scope_id = f"SCOPE-{index:03d}"
        formal_object_id = frozen["existing_formal_object_id"]
        if formal_object_id:
            obj = object_by_id.get(formal_object_id)
            scope = scope_by_id.get(formal_object_id)
            if obj is None or scope is None:
                raise ValueError(f"explicit mapping target is absent: {formal_object_id}")
            if obj["object_type"] != frozen["object_layer"]:
                raise ValueError(f"explicit mapping object type mismatch: {formal_object_id}")
            if scope["scope_class"] != "chip_primary" or scope["counts_toward_chip_coverage"] != "true":
                raise ValueError(f"explicit mapping is not a chip-primary object: {formal_object_id}")
            mapping_status = "mapped_explicit"
            proof_type = "archived_existing_formal_object_id"
            proof_detail = (
                f"{frozen['freeze_row_id']} explicitly names {formal_object_id}; objects.object_type="
                f"{obj['object_type']}; DEC-031 scope_class=chip_primary."
            )
        else:
            mapping_status = "unmapped_no_explicit_proof"
            proof_type = "no_mapping_written"
            proof_detail = "Archived freeze row has empty existing_formal_object_id; name similarity was not used."

        new_rows.append([scope_id, *display])
        audit_rows.append(
            {
                "scope_id": scope_id,
                "freeze_row_id": frozen["freeze_row_id"],
                "vendor": display_vendor,
                "chip_object": display_name,
                "object_layer": frozen["object_layer"],
                "scope_role": display_role,
                "shared_design_group": frozen["silicon_design_group"],
                "existing_formal_object_id": formal_object_id,
                "mapping_status": mapping_status,
                "proof_type": proof_type,
                "proof_paths": "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv|数据/objects.csv|审计/训练推理芯片主线对象范围.csv",
                "proof_detail": proof_detail,
            }
        )

    def md_row(values: list[str]) -> str:
        return "| " + " | ".join(values) + " |"

    replacement = [
        md_row(["scope_id", *expected_header]),
        md_row(["---"] * 7),
        *(md_row(row) for row in new_rows),
    ]
    lines[header_index:end_index] = replacement
    target_path.parent.mkdir(parents=True, exist_ok=True)
    with target_path.open("w", encoding="utf-8", newline="") as handle:
        handle.write(newline.join(lines))
    write_audit_csv(
        STAGING / "scope_mapping_audit.csv",
        [
            "scope_id",
            "freeze_row_id",
            "vendor",
            "chip_object",
            "object_layer",
            "scope_role",
            "shared_design_group",
            "existing_formal_object_id",
            "mapping_status",
            "proof_type",
            "proof_paths",
            "proof_detail",
        ],
        audit_rows,
    )
    return audit_rows


def migrate_objects(audit_rows: list[dict[str, str]]) -> None:
    header, rows = read_csv(MAIN / "数据" / "objects.csv")
    if header != ["object_id", "vendor_id", "canonical_label", "object_type", "curator_slug", "review_status", "notes"]:
        raise ValueError("objects.csv header drift")
    scope_by_object = {
        row["existing_formal_object_id"]: row["scope_id"]
        for row in audit_rows
        if row["mapping_status"] == "mapped_explicit"
    }
    for row in rows:
        row["scope_id"] = scope_by_object.get(row["object_id"], "")
    if sum(bool(row["scope_id"]) for row in rows) != 10:
        raise ValueError("objects scope mapping count must be 10")
    write_formal_csv(PAYLOAD / "数据" / "objects.csv", [*header, "scope_id"], rows)


def migrate_card_completeness(audit_rows: list[dict[str, str]]) -> None:
    header, rows = read_csv(MAIN / "数据" / "card-completeness.csv")
    expected = [
        "card_completeness_id",
        "object_id",
        "domain",
        "completeness_status",
        "assessed_date",
        "assessor",
        "review_status",
        "notes",
    ]
    if header != expected or len(rows) != 585:
        raise ValueError("card-completeness.csv baseline drift")
    scope_by_object = {
        row["existing_formal_object_id"]: row["scope_id"]
        for row in audit_rows
        if row["mapping_status"] == "mapped_explicit"
    }
    domains_by_object: dict[str, set[str]] = {}
    for row in rows:
        domains_by_object.setdefault(row["object_id"], set()).add(row["domain"])
        if row["domain"] == "identity":
            row["card_lifecycle"] = "legacy_unreconciled"
            row["data_cutoff_date"] = ""
            row["scope_id"] = scope_by_object.get(row["object_id"], "")
        else:
            row["card_lifecycle"] = ""
            row["data_cutoff_date"] = ""
            row["scope_id"] = ""
    if len(domains_by_object) != 45 or any(len(domains) != 13 or "identity" not in domains for domains in domains_by_object.values()):
        raise ValueError("card-completeness object/domain baseline drift")
    if sum(row["card_lifecycle"] == "legacy_unreconciled" for row in rows) != 45:
        raise ValueError("identity lifecycle migration count must be 45")
    if sum(bool(row["scope_id"]) for row in rows) != 9:
        raise ValueError("identity scope mapping count must be 9")
    write_formal_csv(
        PAYLOAD / "数据" / "card-completeness.csv",
        [*header, "card_lifecycle", "data_cutoff_date", "scope_id"],
        rows,
    )


def migrate_schema() -> None:
    header, rows = read_csv(MAIN / "数据" / "schema-columns.csv")
    if len(rows) != 346:
        raise ValueError("schema-columns.csv baseline drift")
    additions = [
        {
            "schema_column_id": "SCOL-CARD-COMPLETENESS-CSV-009",
            "table_path": "数据/card-completeness.csv",
            "column_name": "card_lifecycle",
            "ordinal": "9",
            "data_type": "text",
            "is_nullable": "true",
            "is_primary_key": "false",
            "foreign_table_path": "",
            "foreign_column_name": "",
            "enum_name": "card_lifecycle",
            "semicolon_forbidden": "false",
            "definition": "仅 identity 行使用的资料卡管理生命周期",
            "review_status": "approved",
            "notes": "资料卡 scope/coverage 合同迁移新增。",
        },
        {
            "schema_column_id": "SCOL-CARD-COMPLETENESS-CSV-010",
            "table_path": "数据/card-completeness.csv",
            "column_name": "data_cutoff_date",
            "ordinal": "10",
            "data_type": "date",
            "is_nullable": "true",
            "is_primary_key": "false",
            "foreign_table_path": "",
            "foreign_column_name": "",
            "enum_name": "",
            "semicolon_forbidden": "false",
            "definition": "仅 identity 行使用的证据纳入截止日期，不等于 assessed_date",
            "review_status": "approved",
            "notes": "资料卡 scope/coverage 合同迁移新增。",
        },
        {
            "schema_column_id": "SCOL-CARD-COMPLETENESS-CSV-011",
            "table_path": "数据/card-completeness.csv",
            "column_name": "scope_id",
            "ordinal": "11",
            "data_type": "text",
            "is_nullable": "true",
            "is_primary_key": "false",
            "foreign_table_path": "",
            "foreign_column_name": "",
            "enum_name": "",
            "semicolon_forbidden": "false",
            "definition": "仅 identity 行复用冻结名单 scope_id，必须与同对象 objects.scope_id 一致",
            "review_status": "approved",
            "notes": "资料卡 scope/coverage 合同迁移新增。",
        },
        {
            "schema_column_id": "SCOL-OBJECTS-CSV-008",
            "table_path": "数据/objects.csv",
            "column_name": "scope_id",
            "ordinal": "8",
            "data_type": "text",
            "is_nullable": "true",
            "is_primary_key": "false",
            "foreign_table_path": "",
            "foreign_column_name": "",
            "enum_name": "",
            "semicolon_forbidden": "false",
            "definition": "经逐行审核与冻结名单唯一映射的 scope_id",
            "review_status": "approved",
            "notes": "可空；禁止按名称相似猜配。",
        },
    ]
    existing_ids = {row["schema_column_id"] for row in rows}
    if any(row["schema_column_id"] in existing_ids for row in additions):
        raise ValueError("new schema column ID already exists")
    rows.extend(additions)
    write_formal_csv(PAYLOAD / "数据" / "schema-columns.csv", header, rows)


def migrate_enums() -> None:
    header, rows = read_csv(MAIN / "数据" / "enums.csv")
    removed = [row for row in rows if row["enum_name"] == "product_status" and row["enum_value"] == "historical_anchor"]
    if len(rows) != 557 or len(removed) != 1:
        raise ValueError("enums.csv baseline drift")
    rows = [row for row in rows if row not in removed]
    definitions = [
        ("legacy_unreconciled", "历史完整度记录已迁表头，尚未补齐卡级元数据"),
        ("draft", "工作包或候选资料卡尚未进入正式发布审查"),
        ("provisional", "范围与截止日可核查，等待正式合并裁决"),
        ("formal", "资料卡已作为正式交付接受"),
        ("superseded", "资料卡已被更晚的正式卡替代"),
        ("archived", "资料卡不再活跃维护，但未必有替代卡"),
    ]
    for index, (value, definition) in enumerate(definitions, start=1):
        rows.append(
            {
                "enum_value_id": f"ENUM-CARD-LIFECYCLE-{index:03d}",
                "enum_name": "card_lifecycle",
                "enum_value": value,
                "sort_order": str(index),
                "definition": definition,
                "review_status": "approved",
                "notes": "资料卡 scope/coverage 合同迁移新增。",
            }
        )
    write_formal_csv(PAYLOAD / "数据" / "enums.csv", header, rows)


def migrate_fields() -> None:
    header, rows = read_csv(MAIN / "数据" / "fields.csv")
    removed = [row for row in rows if row["field_id"] == "FIELD-ID-DATA-CUTOFF"]
    if len(rows) != 141 or len(removed) != 1:
        raise ValueError("fields.csv baseline drift")
    rows = [row for row in rows if row["field_id"] != "FIELD-ID-DATA-CUTOFF"]
    write_formal_csv(PAYLOAD / "数据" / "fields.csv", header, rows)


def main() -> None:
    audit_rows = migrate_scope_registry()
    migrate_objects(audit_rows)
    migrate_card_completeness(audit_rows)
    migrate_schema()
    migrate_enums()
    migrate_fields()
    print("built scope registry and five migrated formal CSV payloads")


if __name__ == "__main__":
    main()
