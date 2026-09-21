#!/usr/bin/env python3
"""Collect reference PDFs and source links from the two sibling research projects."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import shutil
import subprocess
from collections import defaultdict
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit


MAINLINE_ROOT = Path(__file__).resolve().parents[1]
WORKSPACE = MAINLINE_ROOT.parent.parent
PROJECT_V4 = WORKSPACE / "调研-训练推理芯片调研"
PROJECT_CODEX = WORKSPACE / "调研-训练推理芯片调研-codex-v3"
DEST_ROOT = MAINLINE_ROOT
PDF_DEST = DEST_ROOT / "论文"
LIST_DEST = DEST_ROOT / "清单"

PROJECT_NAME_V4 = PROJECT_V4.name
PROJECT_NAME_CODEX = PROJECT_CODEX.name

URL_RE = re.compile(r"https?://[^\s<>\"'`]+", re.IGNORECASE)
MARKDOWN_LINK_RE = re.compile(r"\[([^\]]+)\]\((https?://[^\s)]+)\)", re.IGNORECASE)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def clean_url(raw: str) -> str:
    url = raw.strip().rstrip(".,;；。！？!?、|】]}>*_～~")
    while url.endswith(")") and url.count("(") < url.count(")"):
        url = url[:-1]
    return url


def normalize_url(raw: str) -> str:
    url = clean_url(raw)
    try:
        parts = urlsplit(url)
    except ValueError:
        return url
    scheme = parts.scheme.lower()
    netloc = parts.netloc.lower()
    path = parts.path.rstrip("/") or "/"
    return urlunsplit((scheme, netloc, path, parts.query, ""))


def extract_urls(text: str) -> list[str]:
    return [clean_url(match.group(0)) for match in URL_RE.finditer(text)]


def compact_text(text: str, limit: int = 500) -> str:
    text = re.sub(r"https?://[^\s<>\"'`]+", "", text)
    text = re.sub(r"[`*_>#]", "", text)
    text = re.sub(r"\s+", " ", text).strip(" -–—·|；;：:")
    return text if len(text) <= limit else text[: limit - 1] + "…"


def classify_url(url: str, hinted: str = "") -> str:
    lower = url.lower()
    if "doi.org/" in lower:
        return "DOI/出版入口"
    if lower.endswith(".pdf") or "/pdf/" in lower or "arxiv.org/pdf/" in lower:
        return "在线PDF"
    if any(token in hinted for token in ("conference", "journal", "preprint", "paper")):
        return "论文页面"
    if any(token in hinted for token in ("datasheet", "whitepaper", "technical_report")):
        return "技术资料页面"
    return "网页"


def project_for_path(path: Path) -> str:
    if path.is_relative_to(PROJECT_V4):
        return PROJECT_NAME_V4
    if path.is_relative_to(PROJECT_CODEX):
        return PROJECT_NAME_CODEX
    raise ValueError(f"Unexpected source path: {path}")


def relative_source(path: Path) -> str:
    if path.is_relative_to(PROJECT_V4):
        return str(path.relative_to(PROJECT_V4))
    if path.is_relative_to(PROJECT_CODEX):
        return str(path.relative_to(PROJECT_CODEX))
    return str(path)


def pdf_destination_for(source: Path) -> Path:
    organized = PROJECT_CODEX / "论文"
    if source.is_relative_to(organized):
        return PDF_DEST / source.relative_to(organized)
    if source == PROJECT_CODEX / "tmp/pdfs/nvidia-blackwell-datasheet-3384703.pdf":
        return PDF_DEST / "NVIDIA_GPU/90_官方白皮书与技术资料/2025_NVIDIA_Blackwell_Datasheet_4204213_OCT25.pdf"
    return PDF_DEST / "其他" / source.name


def choose_canonical(paths: list[Path]) -> Path:
    def rank(path: Path) -> tuple[int, str]:
        if path.is_relative_to(PROJECT_CODEX / "论文"):
            return (0, str(path))
        if path.is_relative_to(PROJECT_CODEX):
            return (1, str(path))
        return (2, str(path))

    return sorted(paths, key=rank)[0]


def pdf_info(path: Path) -> tuple[int | str, str]:
    result = subprocess.run(
        ["pdfinfo", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return "", "失败"
    match = re.search(r"^Pages:\s+(\d+)", result.stdout, re.MULTILINE)
    return (int(match.group(1)) if match else "", "通过")


def load_paper_inventory() -> tuple[dict[str, dict[str, object]], list[dict[str, object]]]:
    path = PROJECT_CODEX / ".tmp/paper_inventory_final.json"
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    downloaded: dict[str, dict[str, object]] = {}
    pending: list[dict[str, object]] = []
    for item in data:
        rel = str(item.get("本地文件或建议路径", "")).replace("\\", "/")
        if item.get("下载状态") == "已下载":
            downloaded[rel] = item
        else:
            pending.append(item)
    return downloaded, pending


def load_codex_sources() -> tuple[list[dict[str, str]], dict[str, dict[str, str]]]:
    path = PROJECT_CODEX / "data/sources.csv"
    with path.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    return rows, {row["source_id"]: row for row in rows}


def collect_pdf_rows() -> tuple[list[dict[str, object]], list[dict[str, object]], dict[str, int]]:
    downloaded_meta, pending = load_paper_inventory()
    source_rows, source_by_id = load_codex_sources()

    all_pdfs = sorted(
        path
        for root in (PROJECT_V4, PROJECT_CODEX)
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() == ".pdf" and ".git" not in path.parts
    )
    by_hash: dict[str, list[Path]] = defaultdict(list)
    for path in all_pdfs:
        by_hash[sha256(path)].append(path)

    rows: list[dict[str, object]] = []
    for digest, occurrences in sorted(by_hash.items(), key=lambda item: str(choose_canonical(item[1]))):
        canonical = choose_canonical(occurrences)
        destination = pdf_destination_for(canonical)
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            if sha256(destination) != digest:
                raise RuntimeError(f"Destination collision: {destination}")
        else:
            shutil.copy2(canonical, destination)

        metadata: dict[str, object] = {}
        if canonical.is_relative_to(PROJECT_CODEX / "论文"):
            rel = str(canonical.relative_to(PROJECT_CODEX / "论文"))
            metadata = downloaded_meta.get(rel, {})

        if canonical.name == "nvidia-blackwell-datasheet-3384703.pdf":
            source = source_by_id.get("SRC-2025-NVIDIA-BLACKWELL-DATASHEET-OCT25", {})
            metadata = {
                "平台": "NVIDIA GPU",
                "年份": 2025,
                "资料类别": "官方白皮书与技术资料",
                "论文或资料标题": source.get("title", "Datasheet for NVIDIA Blackwell Architecture"),
                "发表期刊或会议": source.get("document_version", "4204213 OCT25"),
                "主要作者": source.get("author_or_organization", "NVIDIA"),
                "作者单位": source.get("author_or_organization", "NVIDIA"),
                "DOI": source.get("persistent_id", ""),
                "来源链接": source.get("url", ""),
            }
        elif canonical.name == "2021_IEEE_Micro_41_2_full_issue_source.pdf":
            metadata = {
                "平台": "NVIDIA GPU",
                "年份": 2021,
                "资料类别": "官方白皮书与技术资料",
                "论文或资料标题": "IEEE Micro 2021, Volume 41, Issue 2（整期复核原件）",
                "发表期刊或会议": "IEEE Micro 41(2)",
                "主要作者": "IEEE",
                "作者单位": "IEEE",
                "DOI": "",
                "来源链接": "",
            }

        pages, validation = pdf_info(destination)
        projects = sorted({project_for_path(path) for path in occurrences})
        source_paths = sorted(f"{project_for_path(path)}/{relative_source(path)}" for path in occurrences)
        rows.append(
            {
                "平台": metadata.get("平台", "未分类"),
                "年份": metadata.get("年份", ""),
                "资料类别": metadata.get("资料类别", "未分类"),
                "论文或资料标题": metadata.get("论文或资料标题", canonical.stem),
                "发表期刊或会议": metadata.get("发表期刊或会议", ""),
                "主要作者": metadata.get("主要作者", ""),
                "作者单位": metadata.get("作者单位", ""),
                "DOI": metadata.get("DOI", ""),
                "来源链接": metadata.get("来源链接", ""),
                "来源项目": "；".join(projects),
                "源文件": "；".join(source_paths),
                "汇总后文件": str(destination.relative_to(DEST_ROOT)),
                "页数": pages,
                "文件大小_字节": destination.stat().st_size,
                "SHA256": digest,
                "PDF解析": validation,
            }
        )

    counts = {
        "source_pdf_occurrences": len(all_pdfs),
        "unique_pdfs": len(rows),
        "duplicates_removed": len(all_pdfs) - len(rows),
    }
    return rows, pending, counts


def add_url_record(
    store: dict[tuple[str, str], dict[str, object]],
    *,
    project: str,
    url: str,
    record_id: str,
    title: str,
    organization: str,
    source_type: str,
    evidence_grade: str,
    publish_date: str,
    status: str,
    source_file: str,
    notes: str = "",
) -> None:
    url = clean_url(url)
    if not url:
        return
    key = (project, normalize_url(url))
    if key not in store:
        store[key] = {
            "来源项目": project,
            "来源记录": set(),
            "标题或条目说明": title,
            "作者或机构": organization,
            "资料类型": source_type or classify_url(url),
            "证据等级": evidence_grade,
            "发布日期": publish_date,
            "记录状态": status,
            "URL": url,
            "来源文件": set(),
            "备注": notes,
        }
    item = store[key]
    if record_id:
        item["来源记录"].add(record_id)
    if source_file:
        item["来源文件"].add(source_file)
    if not item["标题或条目说明"] and title:
        item["标题或条目说明"] = title
    if not item["作者或机构"] and organization:
        item["作者或机构"] = organization
    if notes and notes not in str(item["备注"]):
        item["备注"] = "；".join(filter(None, (str(item["备注"]), notes)))


def collect_online_sources() -> tuple[list[dict[str, object]], dict[str, int]]:
    store: dict[tuple[str, str], dict[str, object]] = {}

    v4_root = PROJECT_V4 / "调研v4"
    for path in sorted(v4_root.rglob("*.md")):
        for line_no, line in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
            urls = extract_urls(line)
            if not urls:
                continue
            rel = str(path.relative_to(PROJECT_V4))
            item_match = re.match(r"^\s*([A-Z](?:-[A-Za-z]+)?\d+|\d+)\.\s*(.*)$", line)
            record_id = item_match.group(1) if item_match else f"{rel}:{line_no}"
            context = item_match.group(2) if item_match else line
            title = compact_text(context)
            if "📄" in line:
                source_type = "论文/会议"
            elif "📘" in line:
                source_type = "厂商或官方资料"
            elif "📊" in line:
                source_type = "第三方分析"
            else:
                source_type = ""
            for url in urls:
                add_url_record(
                    store,
                    project=PROJECT_NAME_V4,
                    url=url,
                    record_id=record_id,
                    title=title,
                    organization="",
                    source_type=source_type or classify_url(url),
                    evidence_grade="",
                    publish_date="",
                    status="v4 当前引用",
                    source_file=rel,
                )

    codex_sources, _ = load_codex_sources()
    sources_rel = "data/sources.csv"
    for row in codex_sources:
        primary_url = row.get("url", "")
        urls: list[str] = []
        for field, value in row.items():
            if value:
                for url in extract_urls(value):
                    if url not in urls:
                        urls.append(url)
        for url in urls:
            note = "主来源链接" if normalize_url(url) == normalize_url(primary_url) else "同一来源记录中的补充链接"
            add_url_record(
                store,
                project=PROJECT_NAME_CODEX,
                url=url,
                record_id=row.get("source_id", ""),
                title=row.get("title", ""),
                organization=row.get("author_or_organization", ""),
                source_type=classify_url(url, row.get("source_type", "")),
                evidence_grade=row.get("evidence_grade", ""),
                publish_date=row.get("publish_date", ""),
                status=row.get("source_status", ""),
                source_file=sources_rel,
                notes=note,
            )

    bibliography = PROJECT_CODEX / "references/bibliography.md"
    for line_no, line in enumerate(bibliography.read_text(encoding="utf-8-sig").splitlines(), 1):
        urls = extract_urls(line)
        if not urls:
            continue
        match = re.match(r"^\s*-\s+([A-Za-z0-9-]+)\.\s*(.*)$", line)
        record_id = match.group(1) if match else f"bibliography:{line_no}"
        title = compact_text(match.group(2) if match else line)
        for url in urls:
            add_url_record(
                store,
                project=PROJECT_NAME_CODEX,
                url=url,
                record_id=record_id,
                title=title,
                organization="",
                source_type=classify_url(url),
                evidence_grade="",
                publish_date="",
                status="书目引用",
                source_file="references/bibliography.md",
            )

    inventory_path = PROJECT_CODEX / ".tmp/paper_inventory_final.json"
    paper_inventory = json.loads(inventory_path.read_text(encoding="utf-8-sig"))
    for item in paper_inventory:
        url = str(item.get("来源链接", ""))
        if not url:
            continue
        add_url_record(
            store,
            project=PROJECT_NAME_CODEX,
            url=url,
            record_id=str(item.get("论文或资料标题", "")),
            title=str(item.get("论文或资料标题", "")),
            organization=str(item.get("作者单位", "")),
            source_type=classify_url(url, "paper"),
            evidence_grade="",
            publish_date=str(item.get("年份", "")),
            status=str(item.get("下载状态", "")),
            source_file=".tmp/paper_inventory_final.json",
            notes=str(item.get("未下载原因", "")),
        )

    rows: list[dict[str, object]] = []
    for item in store.values():
        item["来源记录"] = "；".join(sorted(item["来源记录"]))
        item["来源文件"] = "；".join(sorted(item["来源文件"]))
        rows.append(item)
    rows.sort(key=lambda row: (str(row["来源项目"]), str(row["资料类型"]), str(row["标题或条目说明"]), str(row["URL"])))

    project_urls: dict[str, set[str]] = defaultdict(set)
    for row in rows:
        project_urls[str(row["来源项目"])].add(normalize_url(str(row["URL"])))
    overlap = project_urls[PROJECT_NAME_V4] & project_urls[PROJECT_NAME_CODEX]
    counts = {
        "v4_online_urls": len(project_urls[PROJECT_NAME_V4]),
        "codex_online_urls": len(project_urls[PROJECT_NAME_CODEX]),
        "online_url_overlap": len(overlap),
        "combined_online_urls": len(project_urls[PROJECT_NAME_V4] | project_urls[PROJECT_NAME_CODEX]),
    }
    return rows, counts


def write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def write_outputs() -> None:
    pdf_rows, pending, pdf_counts = collect_pdf_rows()
    online_rows, online_counts = collect_online_sources()

    write_csv(
        LIST_DEST / "论文PDF清单.csv",
        pdf_rows,
        [
            "平台",
            "年份",
            "资料类别",
            "论文或资料标题",
            "发表期刊或会议",
            "主要作者",
            "作者单位",
            "DOI",
            "来源链接",
            "来源项目",
            "源文件",
            "汇总后文件",
            "页数",
            "文件大小_字节",
            "SHA256",
            "PDF解析",
        ],
    )

    pending_rows = [
        {
            "平台": item.get("平台", ""),
            "年份": item.get("年份", ""),
            "资料类别": item.get("资料类别", ""),
            "论文或资料标题": item.get("论文或资料标题", ""),
            "发表期刊或会议": item.get("发表期刊或会议", ""),
            "主要作者": item.get("主要作者", ""),
            "作者单位": item.get("作者单位", ""),
            "DOI": item.get("DOI", ""),
            "来源链接": item.get("来源链接", ""),
            "建议路径": str(item.get("本地文件或建议路径", "")).replace("\\", "/"),
            "未下载原因": item.get("未下载原因", ""),
            "调研使用层级": item.get("调研使用层级", ""),
        }
        for item in pending
    ]
    write_csv(
        LIST_DEST / "待补论文清单.csv",
        pending_rows,
        [
            "平台",
            "年份",
            "资料类别",
            "论文或资料标题",
            "发表期刊或会议",
            "主要作者",
            "作者单位",
            "DOI",
            "来源链接",
            "建议路径",
            "未下载原因",
            "调研使用层级",
        ],
    )

    write_csv(
        LIST_DEST / "网页与在线资料.csv",
        online_rows,
        [
            "来源项目",
            "来源记录",
            "标题或条目说明",
            "作者或机构",
            "资料类型",
            "证据等级",
            "发布日期",
            "记录状态",
            "URL",
            "来源文件",
            "备注",
        ],
    )

    platform_counts: dict[str, int] = defaultdict(int)
    category_counts: dict[str, int] = defaultdict(int)
    for row in pdf_rows:
        platform_counts[str(row["平台"])] += 1
        category_counts[f"{row['平台']} / {row['资料类别']}"] += 1

    summary = {
        **pdf_counts,
        **online_counts,
        "pending_papers": len(pending_rows),
        "codex_source_records": len(load_codex_sources()[0]),
        "paper_inventory_records": len(load_paper_inventory()[0]) + len(pending),
        "paper_inventory_downloaded": len(load_paper_inventory()[0]),
        "platform_pdf_counts": dict(sorted(platform_counts.items())),
        "category_pdf_counts": dict(sorted(category_counts.items())),
    }
    (LIST_DEST / "汇总统计.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def configure_destination(root: Path) -> None:
    global DEST_ROOT, PDF_DEST, LIST_DEST
    DEST_ROOT = root.resolve()
    PDF_DEST = DEST_ROOT / "论文"
    LIST_DEST = DEST_ROOT / "清单"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect and deduplicate reference material from the two historical sibling projects."
    )
    parser.add_argument(
        "--output-root",
        type=Path,
        help="Write a preview to this directory instead of the formal mainline root.",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write to the formal mainline 论文/ and 清单/ directories. Use only after reviewing a preview.",
    )
    args = parser.parse_args()
    if args.apply and args.output_root is not None:
        parser.error("--apply and --output-root cannot be used together")
    return args


if __name__ == "__main__":
    arguments = parse_args()
    destination = (
        MAINLINE_ROOT
        if arguments.apply
        else arguments.output_root or MAINLINE_ROOT / "tmp" / "reference-collection-preview"
    )
    configure_destination(destination)
    write_outputs()
    print(f"output_root={DEST_ROOT}")
    print("mode=formal" if arguments.apply else "mode=preview")
