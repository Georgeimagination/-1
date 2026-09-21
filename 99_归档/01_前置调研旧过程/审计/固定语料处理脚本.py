from __future__ import annotations

import csv
import re
from pathlib import Path

from lxml import html
from pypdf import PdfReader

TOPIC = Path(__file__).resolve().parents[1]
MANIFEST = TOPIC / "审计" / "语料清单.csv"
LOG = TOPIC / "审计" / "规范化抽取日志.csv"


def normalize_space(value: str) -> str:
    value = value.replace("\u00a0", " ")
    return re.sub(r"[ \t\r\f\v]+", " ", value).strip()


def extract_html(path: Path) -> str:
    raw = path.read_bytes()
    doc = html.fromstring(raw)
    for node in doc.xpath("//script|//style|//noscript|//svg|//template"):
        parent = node.getparent()
        if parent is not None:
            parent.remove(node)
    title = normalize_space(" ".join(doc.xpath("//title//text()")))
    lines: list[str] = []
    if title:
        lines.append(f"# 页面标题：{title}")
    seen: set[tuple[str, str]] = set()
    for node in doc.xpath("//h1|//h2|//h3|//h4|//h5|//h6|//p|//figcaption|//caption|//tr|//li"):
        tag = node.tag.lower()
        text = normalize_space(" ".join(node.itertext()))
        if not text:
            continue
        key = (tag, text)
        if key in seen:
            continue
        seen.add(key)
        if tag.startswith("h") and len(tag) == 2 and tag[1].isdigit():
            level = min(int(tag[1]), 6)
            lines.append(f"{'#' * level} {text}")
        elif tag == "tr":
            cells = [normalize_space(" ".join(cell.itertext())) for cell in node.xpath("./th|./td")]
            cells = [cell for cell in cells if cell]
            if cells:
                lines.append(" | ".join(cells))
        elif tag in {"figcaption", "caption"}:
            lines.append(f"[图表说明] {text}")
        elif tag == "li":
            lines.append(f"- {text}")
        else:
            lines.append(text)
    if not lines:
        text = normalize_space(doc.text_content())
        lines.append(text)
    return "\n".join(lines)


def extract_pdf(path: Path) -> tuple[str, int, list[str]]:
    reader = PdfReader(str(path))
    parts: list[str] = []
    warnings: list[str] = []
    for index, page in enumerate(reader.pages, start=1):
        try:
            page_text = page.extract_text() or ""
        except Exception as exc:
            page_text = ""
            warnings.append(f"p{index}:{type(exc).__name__}")
        normalized = page_text.strip() if "\n" in page_text else normalize_space(page_text)
        parts.append(f"\n=== PDF页 {index} ===\n{normalized}")
    return "\n".join(parts), len(reader.pages), warnings


with MANIFEST.open("r", encoding="utf-8-sig", newline="") as handle:
    rows = list(csv.DictReader(handle))

logs: list[dict[str, str]] = []
for row in rows:
    source_id = row["source_id"]
    planned = [part.strip() for part in row["planned_raw_file"].split("|") if part.strip()]
    output_path = TOPIC / row["planned_text_file"]
    sections: list[str] = [
        f"# {source_id} 规范化文本",
        "",
        f"题名：{row['title']}",
        f"固定版本：{row['version']}",
        f"原始网址：{row['primary_url']}",
        f"全文网址：{row['fulltext_url']}",
        "",
    ]
    found: list[str] = []
    total_pages = 0
    warnings: list[str] = []
    for rel in planned:
        raw_path = TOPIC / Path(rel)
        if not raw_path.exists() or raw_path.stat().st_size == 0:
            warnings.append(f"missing:{rel}")
            continue
        found.append(rel)
        sections.append(f"\n## 本地原文：{rel}\n")
        if raw_path.suffix.lower() == ".pdf":
            text, pages, pdf_warnings = extract_pdf(raw_path)
            total_pages += pages
            warnings.extend(f"{rel}:{warning}" for warning in pdf_warnings)
            sections.append(text)
        elif raw_path.suffix.lower() in {".html", ".htm"}:
            try:
                sections.append(extract_html(raw_path))
            except Exception as exc:
                warnings.append(f"{rel}:{type(exc).__name__}:{exc}")
        elif raw_path.suffix.lower() == ".txt":
            sections.append(raw_path.read_text(encoding="utf-8"))
        else:
            warnings.append(f"unsupported:{rel}")
    output_text = "\n".join(sections).rstrip() + "\n"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(output_text, encoding="utf-8", newline="\n")
    has_missing = any(item.startswith("missing:") for item in warnings)
    status = "ok" if found and not has_missing else ("partial" if found else "blocked")
    logs.append(
        {
            "source_id": source_id,
            "found_raw_files": "|".join(found),
            "pdf_page_count": str(total_pages) if total_pages else "",
            "normalized_path": output_path.relative_to(TOPIC).as_posix(),
            "normalized_chars": str(len(output_text)),
            "status": status,
            "warnings": "|".join(warnings),
        }
    )

with LOG.open("w", encoding="utf-8-sig", newline="") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=[
            "source_id",
            "found_raw_files",
            "pdf_page_count",
            "normalized_path",
            "normalized_chars",
            "status",
            "warnings",
        ],
    )
    writer.writeheader()
    writer.writerows(logs)

print(f"processed={len(logs)}")
for item in logs:
    print(item["source_id"], item["status"], item["pdf_page_count"], item["normalized_chars"], item["warnings"], sep="\t")
