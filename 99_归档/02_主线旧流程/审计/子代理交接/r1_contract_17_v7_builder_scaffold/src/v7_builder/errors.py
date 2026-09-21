"""Stable error codes used by the scaffold."""

from typing import Any, Dict, Optional


class ContractV7Error(Exception):
    """A fail-closed contract error with a machine-readable code."""

    def __init__(
        self,
        code: str,
        message: str,
        context: Optional[Dict[str, Any]] = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.context = context or {}

    def to_dict(self) -> Dict[str, Any]:
        return {
            "error_code": self.code,
            "message": self.message,
            "context": self.context,
        }


class UpstreamPrerequisiteError(ContractV7Error):
    """Raised before any transaction snapshot or candidate may be created."""

    def __init__(self, message: str, context: Optional[Dict[str, Any]] = None) -> None:
        super().__init__("E_UPSTREAM_PREREQUISITE", message, context)


def require(
    condition: bool,
    code: str,
    message: str,
    context: Optional[Dict[str, Any]] = None,
) -> None:
    if not condition:
        raise ContractV7Error(code, message, context)

