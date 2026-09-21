#!/usr/bin/env python3
"""Rebuild only the 113-PDF source-pool outputs from a frozen, audited ledger.

This candidate deliberately does not scan sibling projects, read a mutable paper
inventory, copy PDFs, or regenerate the online and pending manifests.  It first
verifies a frozen 111-row baseline plus two controlled M2 PDF inputs, then writes
only 清单/论文PDF清单.csv and 清单/汇总统计.json.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
from collections import OrderedDict
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
FORMAL_LEDGER_RELATIVE_PATH = Path("清单") / "资料池受控输入" / "source-pool-input-ledger.json"


class ValidationError(RuntimeError):
    """Raised when a frozen source-pool input or formal guard does not match."""


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def find_mainline_root() -> Path:
    for candidate in (SCRIPT_DIR, *SCRIPT_DIR.parents):
        if candidate.name == "02_主线调研-49款芯片资料库" and (candidate / "清单").is_dir():
            return candidate
    raise ValidationError("Cannot locate the mainline root from the staging directory.")


def resolve_contained(base: Path, relative: str, label: str) -> Path:
    require(relative and not Path(relative).is_absolute(), f"{label} must be a non-empty relative path.")
    candidate = (base / relative).resolve()
    try:
        candidate.relative_to(base.resolve())
    except ValueError as exc:
        raise ValidationError(f"{label} escapes its allowed root: {relative}") from exc
    return candidate


def read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValidationError(f"Cannot read JSON {path}: {exc}") from exc
    require(isinstance(value, dict), f"JSON root must be an object: {path}")
    return value


def read_csv(path: Path, expected_columns: list[str], label: str) -> list[dict[str, str]]:
    try:
        with path.open(encoding="utf-8-sig", newline="") as handle:
            reader = csv.DictReader(handle)
            require(reader.fieldnames == expected_columns, f"{label} header does not match the frozen contract.")
            rows = list(reader)
    except OSError as exc:
        raise ValidationError(f"Cannot read {label}: {exc}") from exc
    for index, row in enumerate(rows, 2):
        require(None not in row.values(), f"{label} has an over-wide CSV row at line {index}.")
        require(set(row) == set(expected_columns), f"{label} has an unexpected column set at line {index}.")
    return [{column: row[column] for column in expected_columns} for row in rows]


def indexed_rows(rows: list[dict[str, str]], key: str, label: str) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {}
    for row in rows:
        value = row.get(key, "")
        require(value, f"{label} contains a blank {key}.")
        require(value not in result, f"{label} contains duplicate {key}: {value}")
        result[value] = row
    return result


def verify_hash(path: Path, expected: str, label: str) -> None:
    require(path.is_file(), f"Missing {label}: {path}")
    actual = sha256(path)
    require(actual == expected.lower(), f"SHA-256 mismatch for {label}: expected {expected}, got {actual}")


def normalized_sha256(value: object, label: str) -> str:
    result = str(value).lower()
    require(len(result) == 64 and all(character in "0123456789abcdef" for character in result), f"{label} is not a SHA-256 hex digest.")
    return result


def resolve_pdfinfo(requested: str | None) -> str:
    executable = requested or shutil.which("pdfinfo")
    require(bool(executable), "pdfinfo is required for this reproducible PDF/page guard; pass --pdfinfo explicitly if needed.")
    return str(executable)


def page_count(pdfinfo: str, path: Path, cache: dict[Path, int]) -> int:
    if path in cache:
        return cache[path]
    result = subprocess.run([pdfinfo, str(path)], check=False, capture_output=True, text=True)
    require(result.returncode == 0, f"pdfinfo failed for {path}: {result.stderr.strip()}")
    for line in result.stdout.splitlines():
        if line.startswith("Pages:"):
            value = line.split(":", 1)[1].strip()
            try:
                pages = int(value)
            except ValueError as exc:
                raise ValidationError(f"pdfinfo returned a non-integer page count for {path}: {value}") from exc
            cache[path] = pages
            return pages
    raise ValidationError(f"pdfinfo returned no Pages field for {path}")


def require_int(value: str | int, label: str) -> int:
    try:
        return int(value)
    except (TypeError, ValueError) as exc:
        raise ValidationError(f"{label} must be an integer, got {value!r}") from exc


def verify_prewrite_guards(ledger: dict[str, Any], mainline_root: Path) -> None:
    guard_specification = ledger.get("formal_prewrite_guards")
    require(isinstance(guard_specification, dict), "Ledger has no formal_prewrite_guards object.")
    guards = guard_specification.get("runtime_guards")
    require(isinstance(guards, list) and guards, "Ledger has no runtime prewrite guards.")
    expected_outputs = ledger.get("expected_outputs")
    require(isinstance(expected_outputs, dict), "Ledger lacks expected_outputs.")
    expected_by_path = {
        str(expected_outputs.get("manifest_relative_path", "")): normalized_sha256(expected_outputs.get("manifest_sha256", ""), "expected manifest hash"),
        str(expected_outputs.get("summary_relative_path", "")): normalized_sha256(expected_outputs.get("summary_sha256", ""), "expected summary hash"),
    }
    require(all(expected_by_path), "Expected output paths must be non-empty.")
    seen: set[str] = set()
    for guard in guards:
        require(isinstance(guard, dict), "Each formal prewrite guard must be an object.")
        relative_path = str(guard.get("relative_path", ""))
        allowed_values = guard.get("allowed_sha256")
        require(relative_path in expected_by_path, f"Runtime prewrite guard is outside the two write targets: {relative_path}")
        require(relative_path not in seen, f"Duplicate formal prewrite guard: {relative_path}")
        require(isinstance(allowed_values, list) and len(allowed_values) == 2, f"Prewrite guard must have exactly legacy and expected hashes: {relative_path}")
        allowed = {normalized_sha256(value, f"allowed SHA-256 for {relative_path}") for value in allowed_values}
        require(len(allowed) == 2, f"Prewrite guard has duplicate hashes: {relative_path}")
        require(expected_by_path[relative_path] in allowed, f"Prewrite guard does not allow the current expected output: {relative_path}")
        seen.add(relative_path)
        path = resolve_contained(mainline_root, relative_path, "formal prewrite guard")
        require(path.is_file(), f"Missing formal prewrite guard: {path}")
        actual = sha256(path)
        require(actual in allowed, f"Formal prewrite guard rejects {relative_path}: got {actual}, allowed {sorted(allowed)}")
    require(seen == set(expected_by_path), "Runtime prewrite guards must cover exactly the two controlled outputs.")

    observations = guard_specification.get("audit_only_observations")
    require(isinstance(observations, list) and observations, "Ledger lacks audit-only prewrite observations.")
    observed_paths: set[str] = set()
    for observation in observations:
        require(isinstance(observation, dict), "Each audit-only observation must be an object.")
        relative_path = str(observation.get("relative_path", ""))
        require(relative_path and relative_path not in seen and relative_path not in observed_paths, "Audit-only observation path is blank, duplicated, or write-scoped.")
        normalized_sha256(observation.get("sha256_at_ledger_creation", ""), f"audit-only SHA-256 for {relative_path}")
        observed_paths.add(relative_path)


def verify_frozen_legacy(
    ledger: dict[str, Any], ledger_root: Path, mainline_root: Path, pdfinfo: str, page_cache: dict[Path, int]
) -> list[dict[str, str]]:
    specification = ledger.get("frozen_legacy_pdf_manifest")
    require(isinstance(specification, dict), "Ledger lacks frozen_legacy_pdf_manifest.")
    path = resolve_contained(ledger_root, str(specification.get("relative_path", "")), "frozen legacy manifest")
    verify_hash(path, str(specification.get("sha256", "")), "frozen legacy manifest")
    rows = read_csv(path, list(ledger["manifest_columns"]), "frozen legacy manifest")

    require(len(rows) == require_int(specification.get("row_count"), "frozen legacy row_count"), "Frozen legacy row count mismatch.")
    occurrence_count = sum(len([item for item in row["源文件"].split("；") if item]) for row in rows)
    unique_hashes = {row["SHA256"].lower() for row in rows}
    require(occurrence_count == require_int(specification.get("source_pdf_occurrences"), "legacy source_pdf_occurrences"), "Frozen legacy source occurrence mismatch.")
    require(len(unique_hashes) == require_int(specification.get("unique_pdfs"), "legacy unique_pdfs"), "Frozen legacy unique hash mismatch.")
    require(occurrence_count - len(unique_hashes) == require_int(specification.get("duplicates_removed"), "legacy duplicates_removed"), "Frozen legacy duplicate arithmetic mismatch.")
    require(sum(require_int(row["文件大小_字节"], "legacy byte count") for row in rows) == require_int(specification.get("total_bytes"), "legacy total_bytes"), "Frozen legacy byte total mismatch.")
    require(sum(require_int(row["页数"], "legacy page count") for row in rows) == require_int(specification.get("total_pages"), "legacy total_pages"), "Frozen legacy page total mismatch.")

    for row in rows:
        verify_manifest_pdf(row, mainline_root, pdfinfo, page_cache, "frozen legacy row")
    return rows


def verify_source_registry(ledger: dict[str, Any], mainline_root: Path) -> tuple[dict[str, dict[str, str]], dict[str, dict[str, str]], dict[str, dict[str, str]]]:
    registry = ledger.get("formal_source_registry")
    require(isinstance(registry, dict), "Ledger lacks formal_source_registry.")
    require(registry.get("runtime_validation") == "selected_rows_only", "Source registry must use selected_rows_only runtime validation.")
    runtime_inputs = registry.get("runtime_inputs")
    require(isinstance(runtime_inputs, dict), "Ledger lacks formal_source_registry.runtime_inputs.")
    required = {
        "sources_csv": "source_id",
        "source_endpoints_csv": "endpoint_id",
        "selection_members_csv": "selection_member_id",
    }
    outputs: list[dict[str, dict[str, str]]] = []
    for name, primary_key in required.items():
        descriptor = runtime_inputs.get(name)
        require(isinstance(descriptor, dict), f"Ledger lacks {name} descriptor.")
        require(descriptor.get("primary_key") == primary_key, f"{name} has an unexpected primary key contract.")
        path = resolve_contained(mainline_root, str(descriptor.get("relative_path", "")), name)
        require(path.is_file(), f"Missing {name}: {path}")
        with path.open(encoding="utf-8-sig", newline="") as handle:
            reader = csv.DictReader(handle)
            require(reader.fieldnames is not None and primary_key in reader.fieldnames, f"{name} lacks {primary_key}.")
            rows = list(reader)
        outputs.append(indexed_rows(rows, primary_key, name))
    return outputs[0], outputs[1], outputs[2]


def verify_required_fields(row: dict[str, str], contract: object, label: str) -> None:
    require(isinstance(contract, dict) and contract, f"{label} has no required-field contract.")
    for field, expected in contract.items():
        require(field in row, f"{label} lacks required field {field}.")
        require(row[field] == str(expected), f"{label} field {field} differs: expected {expected!r}, got {row[field]!r}")


def verify_manifest_pdf(
    row: dict[str, str], mainline_root: Path, pdfinfo: str, page_cache: dict[Path, int], label: str
) -> Path:
    pdf_path = resolve_contained(mainline_root, row["汇总后文件"], f"{label} local PDF")
    require(pdf_path.suffix.lower() == ".pdf", f"{label} does not target a PDF: {pdf_path}")
    require(pdf_path.is_file(), f"Missing {label} PDF: {pdf_path}")
    require(pdf_path.stat().st_size == require_int(row["文件大小_字节"], f"{label} byte count"), f"Byte mismatch for {label}: {pdf_path}")
    verify_hash(pdf_path, row["SHA256"], label)
    require(page_count(pdfinfo, pdf_path, page_cache) == require_int(row["页数"], f"{label} page count"), f"Page mismatch for {label}: {pdf_path}")
    return pdf_path


def verify_supplemental(
    ledger: dict[str, Any], mainline_root: Path, pdfinfo: str, page_cache: dict[Path, int], source_by_id: dict[str, dict[str, str]], endpoint_by_id: dict[str, dict[str, str]], member_by_id: dict[str, dict[str, str]]
) -> list[dict[str, str]]:
    supplements = ledger.get("supplemental_pdfs")
    require(isinstance(supplements, list) and len(supplements) == 2, "Ledger must contain exactly two supplemental PDFs.")
    columns = list(ledger["manifest_columns"])
    rows: list[dict[str, str]] = []
    source_ids: set[str] = set()
    paths: set[str] = set()
    hashes: set[str] = set()

    for supplemental in supplements:
        require(isinstance(supplemental, dict), "Supplemental PDF must be an object.")
        source_id = str(supplemental.get("source_id", ""))
        require(source_id and source_id not in source_ids, f"Duplicate supplemental source ID: {source_id}")
        source_ids.add(source_id)
        row_value = supplemental.get("manifest_row")
        require(isinstance(row_value, dict), f"Supplemental {source_id} lacks manifest_row.")
        require(list(row_value.keys()) == columns, f"Supplemental {source_id} manifest row order or columns differ from the contract.")
        row = {column: str(row_value[column]) for column in columns}
        require(row["汇总后文件"] not in paths, f"Duplicate supplemental local path: {row['汇总后文件']}")
        require(row["SHA256"].lower() not in hashes, f"Duplicate supplemental SHA-256: {row['SHA256']}")
        paths.add(row["汇总后文件"])
        hashes.add(row["SHA256"].lower())

        registry_contract = supplemental.get("registry_contract")
        require(isinstance(registry_contract, dict), f"Supplemental {source_id} lacks registry_contract.")
        source = source_by_id.get(source_id)
        require(source is not None, f"Missing source registry row: {source_id}")
        verify_required_fields(source, registry_contract.get("source_required_fields"), f"source registry row {source_id}")
        require(source.get("title") == row["论文或资料标题"], f"Source title differs for {source_id}")
        require(source.get("author_or_organization") == row["主要作者"], f"Source organization differs for {source_id}")
        require(source.get("source_type") == "product_brief", f"Source type is not product_brief for {source_id}")
        require(source.get("version_label") == row["发表期刊或会议"], f"Source version differs for {source_id}")
        require(source.get("content_fingerprint") == "sha256:" + row["SHA256"], f"Source fingerprint differs for {source_id}")
        require(source.get("review_status") == "reviewed", f"Source is not reviewed: {source_id}")

        local_id = str(supplemental.get("local_endpoint_id", ""))
        remote_id = str(supplemental.get("remote_endpoint_id", ""))
        local_endpoint = endpoint_by_id.get(local_id)
        remote_endpoint = endpoint_by_id.get(remote_id)
        require(local_endpoint is not None, f"Missing local endpoint: {local_id}")
        require(remote_endpoint is not None, f"Missing remote endpoint: {remote_id}")
        verify_required_fields(local_endpoint, registry_contract.get("local_endpoint_required_fields"), f"local endpoint {local_id}")
        verify_required_fields(remote_endpoint, registry_contract.get("remote_endpoint_required_fields"), f"remote endpoint {remote_id}")
        require(local_endpoint.get("source_id") == source_id and local_endpoint.get("endpoint_type") == "local_pdf", f"Invalid local endpoint binding: {local_id}")
        require(local_endpoint.get("local_path") == row["汇总后文件"], f"Local endpoint path differs: {local_id}")
        require(local_endpoint.get("sha256") == row["SHA256"], f"Local endpoint SHA-256 differs: {local_id}")
        require(local_endpoint.get("page_count") == row["页数"], f"Local endpoint page count differs: {local_id}")
        require(local_endpoint.get("review_status") == "reviewed", f"Local endpoint is not reviewed: {local_id}")
        require(remote_endpoint.get("source_id") == source_id and remote_endpoint.get("endpoint_type") == "pdf_direct", f"Invalid remote endpoint binding: {remote_id}")
        require(remote_endpoint.get("url") == row["来源链接"], f"Remote endpoint URL differs: {remote_id}")
        require(remote_endpoint.get("review_status") == "reviewed", f"Remote endpoint is not reviewed: {remote_id}")

        member_id = str(supplemental.get("selection_member_id", ""))
        member = member_by_id.get(member_id)
        if member is not None:
            verify_required_fields(member, registry_contract.get("selection_member_required_fields"), f"selection member {member_id}")
        require(member is not None and member.get("source_id") == source_id and member.get("review_status") == "reviewed", f"Selection-member binding differs: {member_id}")

        fixed_candidate = resolve_contained(mainline_root, str(supplemental.get("fixed_candidate_path", "")), f"fixed candidate for {source_id}")
        require(row["源文件"] == str(supplemental["fixed_candidate_path"]), f"Source-file provenance differs for {source_id}")
        require(fixed_candidate.is_file(), f"Missing fixed candidate: {fixed_candidate}")
        require(fixed_candidate.stat().st_size == require_int(row["文件大小_字节"], f"fixed candidate bytes for {source_id}"), f"Fixed candidate byte mismatch: {source_id}")
        verify_hash(fixed_candidate, row["SHA256"], f"fixed candidate for {source_id}")
        require(page_count(pdfinfo, fixed_candidate, page_cache) == require_int(row["页数"], f"fixed candidate pages for {source_id}"), f"Fixed candidate page mismatch: {source_id}")
        verify_manifest_pdf(row, mainline_root, pdfinfo, page_cache, f"supplemental {source_id}")
        rows.append(row)
    return rows


def summarize(rows: list[dict[str, str]], ledger: dict[str, Any]) -> OrderedDict[str, Any]:
    expected = ledger["expected_outputs"]
    source_occurrences = sum(len([item for item in row["源文件"].split("；") if item]) for row in rows)
    unique_hashes = {row["SHA256"].lower() for row in rows}
    platform_counts: OrderedDict[str, int] = OrderedDict((key, 0) for key in expected["platform_pdf_counts"])
    category_counts: OrderedDict[str, int] = OrderedDict((key, 0) for key in expected["category_pdf_counts"])
    for row in rows:
        platform = row["平台"]
        category = platform + " / " + row["资料类别"]
        require(platform in platform_counts, f"Unexpected platform in manifest: {platform}")
        require(category in category_counts, f"Unexpected category in manifest: {category}")
        platform_counts[platform] += 1
        category_counts[category] += 1

    total_bytes = sum(require_int(row["文件大小_字节"], "manifest byte count") for row in rows)
    total_pages = sum(require_int(row["页数"], "manifest page count") for row in rows)
    require(len(rows) == require_int(expected["row_count"], "expected row_count"), "Output row count mismatch.")
    require(source_occurrences == require_int(expected["source_pdf_occurrences"], "expected source occurrences"), "Output source occurrence mismatch.")
    require(len(unique_hashes) == require_int(expected["unique_pdfs"], "expected unique PDFs"), "Output unique hash count mismatch.")
    require(source_occurrences - len(unique_hashes) == require_int(expected["duplicates_removed"], "expected duplicates"), "Output duplicate arithmetic mismatch.")
    require(total_bytes == require_int(expected["total_bytes"], "expected total bytes"), "Output byte total mismatch.")
    require(total_pages == require_int(expected["total_pages"], "expected total pages"), "Output page total mismatch.")
    require(dict(platform_counts) == expected["platform_pdf_counts"], "Output platform counts mismatch.")
    require(dict(category_counts) == expected["category_pdf_counts"], "Output category counts mismatch.")

    fixed = ledger["fixed_summary_fields"]
    frozen_inventory = ledger["frozen_paper_inventory_summary"]
    return OrderedDict(
        [
            ("source_pdf_occurrences", source_occurrences),
            ("unique_pdfs", len(unique_hashes)),
            ("duplicates_removed", source_occurrences - len(unique_hashes)),
            ("v4_online_urls", require_int(fixed["v4_online_urls"], "v4_online_urls")),
            ("codex_online_urls", require_int(fixed["codex_online_urls"], "codex_online_urls")),
            ("online_url_overlap", require_int(fixed["online_url_overlap"], "online_url_overlap")),
            ("combined_online_urls", require_int(fixed["combined_online_urls"], "combined_online_urls")),
            ("pending_papers", require_int(fixed["pending_papers"], "pending_papers")),
            ("codex_source_records", require_int(fixed["codex_source_records"], "codex_source_records")),
            ("paper_inventory_records", require_int(frozen_inventory["paper_inventory_records"], "paper_inventory_records")),
            ("paper_inventory_downloaded", require_int(frozen_inventory["paper_inventory_downloaded"], "paper_inventory_downloaded")),
            ("platform_pdf_counts", platform_counts),
            ("category_pdf_counts", category_counts),
        ]
    )


def verify_write_scope(ledger: dict[str, Any]) -> None:
    expected = ledger.get("expected_outputs")
    scope = ledger.get("write_scope")
    require(isinstance(expected, dict) and isinstance(scope, dict), "Ledger lacks expected_outputs or write_scope.")
    expected_paths = [str(expected.get("manifest_relative_path", "")), str(expected.get("summary_relative_path", ""))]
    require(expected_paths == ["清单/论文PDF清单.csv", "清单/汇总统计.json"], "The controlled output paths must remain the PDF manifest and summary only.")
    require(scope.get("outputs") == expected_paths, "write_scope outputs must exactly match the two controlled output paths.")
    require(scope.get("preview_output_root_must_be_fully_disjoint_from_mainline") is True, "Ledger must require a fully disjoint preview output root.")
    require(scope.get("never_copy_or_rewrite_pdf_files") is True, "Ledger must prohibit PDF copies or rewrites.")
    require(scope.get("never_regenerate_online_or_pending_manifests") is True, "Ledger must prohibit online/pending-manifest regeneration.")


def paths_overlap(left: Path, right: Path) -> bool:
    resolved_left = left.resolve()
    resolved_right = right.resolve()
    try:
        resolved_left.relative_to(resolved_right)
        return True
    except ValueError:
        pass
    try:
        resolved_right.relative_to(resolved_left)
        return True
    except ValueError:
        return False


def render_manifest(rows: list[dict[str, str]], columns: list[str]) -> bytes:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=columns, extrasaction="raise", quoting=csv.QUOTE_ALL, lineterminator="\r\n")
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue().encode("utf-8")


def render_summary(summary: OrderedDict[str, Any]) -> bytes:
    return (json.dumps(summary, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def write_atomic(path: Path, content: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(prefix=path.name + ".", suffix=".tmp", dir=path.parent, delete=False) as handle:
        temporary = Path(handle.name)
        handle.write(content)
    try:
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Rebuild the controlled 113-PDF source-pool manifest and summary.")
    parser.add_argument("--mainline-root", type=Path, help="Formal mainline root used for read-only guards and PDF verification. Defaults to the installed collector's containing mainline.")
    parser.add_argument("--ledger", type=Path, help="Optional staging/recovery override. An installed collector defaults to 清单/资料池受控输入/source-pool-input-ledger.json under --mainline-root.")
    parser.add_argument("--output-root", type=Path, help="Preview project root; only its 清单/ PDF manifest and summary will be written.")
    parser.add_argument("--pdfinfo", help="Path or command name for pdfinfo. It is required for page verification.")
    parser.add_argument("--apply", action="store_true", help="Write only the two controlled list outputs to --mainline-root after all guards pass.")
    parser.add_argument("--confirm-ledger-sha256", help="Required with --apply; must equal the current ledger SHA-256.")
    args = parser.parse_args()
    if args.apply and args.output_root is not None:
        parser.error("--apply and --output-root cannot be used together")
    if not args.apply and args.output_root is None:
        parser.error("Preview mode requires --output-root")
    return args


def main() -> int:
    args = parse_args()
    mainline_root = (args.mainline_root or find_mainline_root()).resolve()
    require(mainline_root.is_dir(), f"Missing mainline root: {mainline_root}")
    ledger_path = args.ledger.resolve() if args.ledger is not None else resolve_contained(mainline_root, FORMAL_LEDGER_RELATIVE_PATH.as_posix(), "default controlled ledger")
    require(ledger_path.is_file(), f"Missing ledger: {ledger_path}")
    ledger = read_json(ledger_path)
    require(ledger.get("schema_version") == "source-pool-ledger-v2", "Unsupported source-pool ledger schema.")
    require(ledger.get("formal_stable_input_directory") == FORMAL_LEDGER_RELATIVE_PATH.parent.as_posix(), "Ledger stable-input directory does not match the installed collector contract.")
    require(ledger.get("formal_ledger_relative_path") == FORMAL_LEDGER_RELATIVE_PATH.as_posix(), "Ledger formal path does not match the installed collector contract.")
    verify_write_scope(ledger)
    ledger_hash = sha256(ledger_path)
    if args.apply:
        require(args.confirm_ledger_sha256 == ledger_hash, "--apply requires the exact current --confirm-ledger-sha256 value.")
        output_root = mainline_root
        mode = "formal"
    else:
        output_root = args.output_root.resolve()
        require(not paths_overlap(output_root, mainline_root), "Preview output root must be fully disjoint from the formal mainline root; it cannot be the root itself, any child, or any ancestor containing it.")
        mode = "preview"

    pdfinfo = resolve_pdfinfo(args.pdfinfo)
    page_cache: dict[Path, int] = {}
    verify_prewrite_guards(ledger, mainline_root)
    legacy_rows = verify_frozen_legacy(ledger, ledger_path.parent, mainline_root, pdfinfo, page_cache)
    source_by_id, endpoint_by_id, member_by_id = verify_source_registry(ledger, mainline_root)
    supplemental_rows = verify_supplemental(ledger, mainline_root, pdfinfo, page_cache, source_by_id, endpoint_by_id, member_by_id)
    rows = legacy_rows + supplemental_rows
    require(len({row["汇总后文件"] for row in rows}) == len(rows), "Combined manifest has duplicate PDF paths.")
    require(len({row["SHA256"].lower() for row in rows}) == len(rows), "Combined manifest has duplicate PDF SHA-256 values.")
    for row in rows:
        verify_manifest_pdf(row, mainline_root, pdfinfo, page_cache, "combined manifest row")
    summary = summarize(rows, ledger)
    manifest_content = render_manifest(rows, list(ledger["manifest_columns"]))
    summary_content = render_summary(summary)
    expected = ledger["expected_outputs"]
    require(hashlib.sha256(manifest_content).hexdigest() == expected["manifest_sha256"], "Rendered PDF manifest does not match its expected SHA-256.")
    require(hashlib.sha256(summary_content).hexdigest() == expected["summary_sha256"], "Rendered summary does not match its expected SHA-256.")

    write_atomic(resolve_contained(output_root, str(expected["manifest_relative_path"]), "output manifest"), manifest_content)
    write_atomic(resolve_contained(output_root, str(expected["summary_relative_path"]), "output summary"), summary_content)
    print(json.dumps({"status": "ok", "mode": mode, "ledger_sha256": ledger_hash, "output_root": str(output_root), "pdf_copy_operations": 0, "written_outputs": [expected["manifest_relative_path"], expected["summary_relative_path"]]}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"SOURCE_POOL_LEDGER_VALIDATION_FAILED: {exc}", file=sys.stderr)
        raise SystemExit(2)
