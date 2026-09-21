#!/usr/bin/env python3
"""Read-only command for the v7 live prerequisite gate."""

import argparse
import json
import sys
from pathlib import Path


SCAFFOLD_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(SCAFFOLD_ROOT / "src"))

from v7_builder.errors import UpstreamPrerequisiteError  # noqa: E402
from v7_builder.preflight import require_live_prerequisites  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description="Fail-closed contract-v7 live prerequisite check")
    parser.add_argument("--mainline-root", type=Path, required=True)
    parser.add_argument("--prerequisite-manifest", type=Path)
    parser.add_argument("--prerequisite-approval", type=Path)
    arguments = parser.parse_args()
    try:
        report = require_live_prerequisites(
            arguments.mainline_root,
            arguments.prerequisite_manifest,
            arguments.prerequisite_approval,
        )
        output = report.to_dict()
        exit_code = 0
    except UpstreamPrerequisiteError as error:
        output = error.context["report"]
        exit_code = 2
    json.dump(output, sys.stdout, ensure_ascii=False, indent=2, sort_keys=False)
    sys.stdout.write("\n")
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())

