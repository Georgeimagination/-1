"""Shared read-only formal paths and synthetic constructors."""

from pathlib import Path


SCAFFOLD_ROOT = Path(__file__).resolve().parents[1]
MAINLINE_ROOT = SCAFFOLD_ROOT.parents[2]
DATA_DIR = MAINLINE_ROOT / "数据"

