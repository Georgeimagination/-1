#!/usr/bin/env python3
"""Run the stdlib-only synthetic/read-only test suite."""

import sys
import unittest
from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(PACKAGE_ROOT / "src"))


def main() -> int:
    suite = unittest.defaultTestLoader.discover(str(PACKAGE_ROOT / "tests"), top_level_dir=str(PACKAGE_ROOT))
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())

