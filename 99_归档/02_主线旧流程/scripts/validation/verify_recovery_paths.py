#!/usr/bin/env python3
"""Verify that the mainline data and local evidence paths remain recoverable."""

from __future__ import annotations

import argparse
import csv
import hashlib
from pathlib import Path


SCRIPT_ROOT = Path(__file__).resolve().parents[2]


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Check formal tables, local evidence paths, hashes, and selection-run references."
    )
    parser.add_argument("--root", type=Path, default=SCRIPT_ROOT, help="Mainline research root")
    return parser.parse_args()


def main() -> int:
    root = parse_args().root.resolve()
    errors: list[str] = []

    schema_path = root / "数据" / "schema-columns.csv"
    if not schema_path.is_file():
        print(f"FAIL: missing schema registry: {schema_path}")
        return 1

    schema_rows = read_csv(schema_path)
    table_paths = sorted({row["table_path"] for row in schema_rows})
    for relative in table_paths:
        if not (root / relative).is_file():
            errors.append(f"missing formal table: {relative}")

    endpoints = read_csv(root / "最小参考资料库" / "source-endpoints.csv")
    local_rows = [row for row in endpoints if row.get("local_path", "").strip()]
    hash_checks = 0
    for row in local_rows:
        relative = Path(row["local_path"])
        endpoint_id = row.get("endpoint_id", "<unknown>")
        if relative.is_absolute() or ".." in relative.parts:
            errors.append(f"unsafe local_path: {endpoint_id}: {relative}")
            continue
        target = root / relative
        if not target.is_file():
            errors.append(f"missing local evidence: {endpoint_id}: {relative}")
            continue
        expected_hash = row.get("sha256", "").strip().lower()
        if expected_hash:
            hash_checks += 1
            if sha256(target) != expected_hash:
                errors.append(f"local evidence hash mismatch: {endpoint_id}: {relative}")

    runs = read_csv(root / "最小参考资料库" / "selection-runs.csv")
    members = read_csv(root / "最小参考资料库" / "selection-members.csv")
    run_ids = {row["selection_run_id"] for row in runs}
    for row in members:
        if row["selection_run_id"] not in run_ids:
            errors.append(
                f"selection member references unknown run: {row['selection_member_id']}: {row['selection_run_id']}"
            )

    if errors:
        print(f"FAIL: {len(errors)} recovery error(s)")
        for error in errors:
            print(f" - {error}")
        return 1

    print(
        "PASS: "
        f"formal_tables={len(table_paths)}; "
        f"endpoint_rows={len(endpoints)}; "
        f"local_paths={len(local_rows)}; "
        f"hashes_checked={hash_checks}; "
        f"selection_runs={len(runs)}; "
        f"selection_members={len(members)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
