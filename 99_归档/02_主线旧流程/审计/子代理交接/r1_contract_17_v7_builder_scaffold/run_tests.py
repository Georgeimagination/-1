#!/usr/bin/env python3
"""Dependency-free unittest entry point with a machine summary on stdout."""

import argparse
import json
import sys
import unittest
from pathlib import Path


SCAFFOLD_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(SCAFFOLD_ROOT / "src"))
sys.path.insert(0, str(SCAFFOLD_ROOT))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-summary", action="store_true")
    arguments = parser.parse_args()
    suite = unittest.defaultTestLoader.discover(
        str(SCAFFOLD_ROOT / "tests"),
        top_level_dir=str(SCAFFOLD_ROOT),
    )
    result = unittest.TextTestRunner(verbosity=2, stream=sys.stderr).run(suite)
    summary = {
        "status": "PASS" if result.wasSuccessful() else "FAIL",
        "tests_run": result.testsRun,
        "failures": len(result.failures),
        "errors": len(result.errors),
        "skipped": len(result.skipped),
    }
    if arguments.json_summary:
        json.dump(summary, sys.stdout, ensure_ascii=False, sort_keys=False)
        sys.stdout.write("\n")
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())

