from __future__ import annotations

import csv
import hashlib
from pathlib import Path

from pypdf import PdfReader

TOPIC = Path(__file__).resolve().parents[1]
MANIFEST = TOPIC / "审计" / "语料清单.csv"
FIGURES = TOPIC / "审计" / "图表清单.csv"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


with MANIFEST.open("r", encoding="utf-8-sig", newline="") as handle:
    rows = list(csv.DictReader(handle))
fieldnames = list(rows[0].keys())

for row in rows:
    sid = row["source_id"]
    if sid == "S09":
        row["raw_kind"] = "official_webview_text"
        row["planned_raw_file"] = "原文/网页快照/S09_deployment_architecture_survey.webview.txt"
        row["notes"] = "官方正文可见；原始HTML与PDF脚本下载均返回HTTP 403，保存网页读取工具的可见正文快照"
    if sid == "S16":
        row["version"] = "arXiv 2104.02188v1；TACO DOI 10.1145/3484505入口HTTP 403"
        row["fulltext_url"] = "https://arxiv.org/pdf/2104.02188v1"
        row["notes"] = "按计划回退到arXiv v1；未绕过TACO访问控制；HPC与DL分化不等同训练与推理分化"

    planned = [item.strip() for item in row["planned_raw_file"].split("|") if item.strip()]
    existing: list[tuple[str, Path]] = []
    missing: list[str] = []
    page_total = 0
    for rel in planned:
        path = TOPIC / rel
        if path.exists() and path.stat().st_size > 0:
            existing.append((rel, path))
            if path.suffix.lower() == ".pdf":
                page_total += len(PdfReader(str(path)).pages)
        else:
            missing.append(rel)

    row["access_date"] = "2026-08-14"
    if sid == "S09":
        row["access_status"] = "partial_fixed_official_webview;raw_html_and_pdf_http_403"
    elif sid == "S16":
        row["access_status"] = "fixed_arxiv_fallback;taco_http_403"
    elif missing:
        row["access_status"] = "partial_missing:" + "|".join(missing)
    else:
        row["access_status"] = "fixed"
    row["final_url"] = row["fulltext_url"]
    row["local_raw_path"] = "|".join(rel for rel, _ in existing)
    row["local_text_path"] = row["planned_text_file"]
    row["sha256"] = "|".join(f"{rel}={sha256(path)}" for rel, path in existing)
    row["bytes"] = "|".join(f"{rel}={path.stat().st_size}" for rel, path in existing)
    row["page_count"] = str(page_total) if page_total else ""
    row["agent_status"] = "pending"
    if sid == "S09":
        row["license_access_note"] = "CC BY 4.0；原始HTML/PDF自动下载HTTP 403，未绕过访问控制"
    elif sid == "S16":
        row["license_access_note"] = "TACO入口HTTP 403；使用公开arXiv v1，未绕过访问控制"

with MANIFEST.open("w", encoding="utf-8-sig", newline="") as handle:
    writer = csv.DictWriter(handle, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

figure_rows: list[dict[str, str]] = []
figure_root = TOPIC / "原文" / "图表"
for path in sorted(figure_root.rglob("*")):
    if not path.is_file():
        continue
    rel = path.relative_to(TOPIC).as_posix()
    parts = path.relative_to(figure_root).parts
    source_id = parts[0] if parts else ""
    role = "visual_contact_sheet" if "contact" in path.name.lower() else "key_figure"
    figure_rows.append(
        {
            "source_id": source_id,
            "local_path": rel,
            "role": role,
            "bytes": str(path.stat().st_size),
            "sha256": sha256(path),
            "access_date": "2026-08-14",
        }
    )

with FIGURES.open("w", encoding="utf-8-sig", newline="") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=["source_id", "local_path", "role", "bytes", "sha256", "access_date"],
    )
    writer.writeheader()
    writer.writerows(figure_rows)

print(f"manifest_rows={len(rows)}")
print(f"unique_ids={len({row['source_id'] for row in rows})}")
print(f"figure_rows={len(figure_rows)}")
for row in rows:
    print(row["source_id"], row["access_status"], row["page_count"], sep="\t")
