"""Stable error taxonomy and structured command boundaries."""

import csv
import json
from dataclasses import dataclass
from typing import Any, Callable, Dict, Mapping, NoReturn, Optional, TypeVar


@dataclass
class ContractV7Error(Exception):
    code: str
    message: str
    detail: Optional[Mapping[str, Any]] = None

    def __post_init__(self) -> None:
        Exception.__init__(self, "%s: %s" % (self.code, self.message))

    def to_dict(self) -> Dict[str, Any]:
        return {
            "status": "ERROR",
            "error_code": self.code,
            "message": self.message,
            "detail": dict(self.detail or {}),
            "writes_performed": False,
        }


class UpstreamPrerequisiteError(ContractV7Error):
    def __init__(self, message: str, detail: Optional[Mapping[str, Any]] = None) -> None:
        super().__init__("E_UPSTREAM_PREREQUISITE", message, detail)


def require(condition: bool, code: str, message: str, detail: Optional[Mapping[str, Any]] = None) -> None:
    if not condition:
        raise ContractV7Error(code, message, detail)


def raise_stable_external(error: BaseException, operation: str) -> NoReturn:
    """Map library/OS exceptions to the public fail-closed error vocabulary."""

    if isinstance(error, ContractV7Error):
        raise error
    if isinstance(error, FileNotFoundError):
        code = "E_IO_NOT_FOUND"
    elif isinstance(error, PermissionError):
        code = "E_IO_PERMISSION"
    elif isinstance(error, (UnicodeDecodeError, UnicodeEncodeError)):
        code = "E_UTF8"
    elif isinstance(error, csv.Error):
        code = "E_CSV_PARSE"
    elif isinstance(error, (ValueError, TypeError, OverflowError)):
        code = "E_VALUE_PARSE"
    elif isinstance(error, OSError):
        code = "E_IO"
    else:
        code = "E_INTERNAL"
    raise ContractV7Error(code, "%s failed" % operation, {"exception_type": type(error).__name__})


T = TypeVar("T")


def structured_call(operation: str, function: Callable[[], T]) -> Dict[str, Any]:
    """Never leak an unstable exception shape across a CLI/library boundary."""

    try:
        value = function()
        if hasattr(value, "to_dict"):
            return value.to_dict()  # type: ignore[no-any-return]
        if isinstance(value, dict):
            return value
        return {"status": "OK", "result": value, "writes_performed": False}
    except BaseException as error:
        try:
            raise_stable_external(error, operation)
        except ContractV7Error as stable:
            return stable.to_dict()


def emit_json(document: Mapping[str, Any]) -> str:
    return json.dumps(document, ensure_ascii=False, sort_keys=True, separators=(",", ":"))

