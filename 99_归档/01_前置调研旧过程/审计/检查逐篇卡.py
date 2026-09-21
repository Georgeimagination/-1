from __future__ import annotations

import csv
import re
from pathlib import Path

TOPIC = Path(__file__).resolve().parents[1]
MANIFEST = TOPIC / "审计" / "语料清单.csv"
FULL_DIR = TOPIC / "逐篇分析" / "完整卡"
BRIEF_DIR = TOPIC / "逐篇分析" / "摘要卡"
OUTPUT = TOPIC / "审计" / "逐篇卡机器验收.csv"

with MANIFEST.open("r", encoding="utf-8-sig", newline="") as handle:
    sources = list(csv.DictReader(handle))

required_fragments = [
    "来源身份",
    "实际阅读范围",
    "图表",
    "训练与推理差异",
    "关键数字",
    "适用时代",
    "对最终报告",
]
rows: list[dict[str, str]] = []
for source in sources:
    sid = source["source_id"]
    full_matches = sorted(FULL_DIR.glob(f"{sid}_*.md"))
    brief_matches = sorted(BRIEF_DIR.glob(f"{sid}_*.md"))
    errors: list[str] = []
    full_chars = 0
    brief_chars = 0

    if len(full_matches) != 1:
        errors.append(f"完整卡数量={len(full_matches)}")
    else:
        text = full_matches[0].read_text(encoding="utf-8")
        full_chars = len(text)
        if full_chars < 1500:
            errors.append("完整卡过短")
        for fragment in required_fragments:
            if fragment not in text:
                errors.append(f"缺少章节:{fragment}")
        if "[原文事实]" not in text:
            errors.append("缺少[原文事实]")
        if "[未覆盖]" not in text:
            errors.append("缺少[未覆盖]")
        if not re.search(r"PDF\s*第\s*\d+\s*页|§\s*\d|小节|网页", text):
            errors.append("缺少原文定位")
        if sid in {"S04", "S05", "S13", "S14"} and "视觉核对" not in text:
            errors.append("缺少视觉核对记录")

    if len(brief_matches) != 1:
        errors.append(f"摘要卡数量={len(brief_matches)}")
    else:
        text = brief_matches[0].read_text(encoding="utf-8")
        match = re.search(r"摘要（100\s*(?:[—–-]|至)\s*200\s*字[）)]\s*[:：]?\s*(?:(?:\n+|\s+)(?:#+\s*)?)?(.+)", text, re.S)
        if not match:
            errors.append("摘要标记不合合同")
        else:
            brief = match.group(1).strip()
            brief = re.sub(r"\x60[^\x60]*\x60", "", brief)
            brief = re.sub(r"[A-Za-z0-9_./:+-]+", "", brief)
            brief = re.sub(r"[^\u3400-\u4dbf\u4e00-\u9fff]", "", brief)
            brief_chars = len(brief)
            if not 100 <= brief_chars <= 200:
                errors.append(f"摘要中文字符数={brief_chars}")

    rows.append(
        {
            "source_id": sid,
            "full_card": full_matches[0].relative_to(TOPIC).as_posix() if len(full_matches) == 1 else "",
            "brief_card": brief_matches[0].relative_to(TOPIC).as_posix() if len(brief_matches) == 1 else "",
            "full_chars": str(full_chars),
            "brief_chars": str(brief_chars),
            "status": "pass" if not errors else "fail",
            "errors": "|".join(errors),
        }
    )

with OUTPUT.open("w", encoding="utf-8-sig", newline="") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=["source_id", "full_card", "brief_card", "full_chars", "brief_chars", "status", "errors"],
    )
    writer.writeheader()
    writer.writerows(rows)

print(f"sources={len(rows)}")
print(f"pass={sum(row['status'] == 'pass' for row in rows)}")
print(f"fail={sum(row['status'] == 'fail' for row in rows)}")
for row in rows:
    if row["status"] == "fail":
        print(row["source_id"], row["errors"], sep="\t")
