from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parents[1]
MAINLINE_ROOT = Path(__file__).resolve().parents[4]
SCHEMA_ROOT = PACKAGE_ROOT / "schemas"
FIXTURE_ROOT = PACKAGE_ROOT / "fixtures"
DATA_ROOT = MAINLINE_ROOT / "数据"


def error_code(context):
    caught = context.exception
    return getattr(caught, "code", None)

