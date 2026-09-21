#!/usr/bin/env python3
"""Run the read-only live prerequisite gate and emit one structured JSON value."""

import argparse
import sys
from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(PACKAGE_ROOT / "src"))

from v7_builder_v2.errors import emit_json, structured_call
from v7_builder_v2.preflight import inspect_live_prerequisites


def main() -> int:
    parser = argparse.ArgumentParser(description="contract v7 read-only source-pool prerequisite gate")
    parser.add_argument("--root", type=Path, default=PACKAGE_ROOT.parents[2])
    parser.add_argument("--transaction-id", default="TX-CONTRACT-V7-NOT-CREATED")
    arguments = parser.parse_args()
    document = structured_call("live prerequisite preflight", lambda: inspect_live_prerequisites(arguments.root, arguments.transaction_id))
    print(emit_json(document))
    return 0 if document.get("status") == "READY" else 3


if __name__ == "__main__":
    raise SystemExit(main())
