"""Audit-only construction guard; upstream validation always runs first."""

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from .errors import ContractV7Error, require
from .preflight import PreflightReport, require_live_prerequisites


AUDIT_SCAFFOLD_RELATIVE_ROOT = "审计/子代理交接/r1_contract_17_v7_builder_scaffold"


@dataclass(frozen=True)
class AuditWorkspacePermit:
    output_path: Path
    prerequisite_report: PreflightReport


def initialize_audit_workspace(
    mainline_root: Path,
    output_path: Path,
    prerequisite_manifest_path: Optional[Path] = None,
    prerequisite_approval_path: Optional[Path] = None,
) -> AuditWorkspacePermit:
    """Create an empty audit workspace only after the live gate is READY.

    No snapshot/candidate child is created here.  More importantly, the
    prerequisite call is deliberately the first operation, so a blocked live
    state cannot create even the empty workspace directory.
    """

    report = require_live_prerequisites(
        mainline_root,
        prerequisite_manifest_path,
        prerequisite_approval_path,
    )
    root = mainline_root.resolve(strict=True)
    allowed_root = (root / AUDIT_SCAFFOLD_RELATIVE_ROOT).resolve(strict=True)
    resolved_output = output_path.resolve(strict=False)
    require(
        os.path.commonpath((str(allowed_root), str(resolved_output))) == str(allowed_root)
        and resolved_output != allowed_root,
        "E_PATH",
        "builder output must stay below the audit-only scaffold directory",
    )
    require(not resolved_output.exists(), "E_REQUIRED_SET", "audit workspace output already exists")
    try:
        resolved_output.mkdir(parents=False, exist_ok=False)
    except OSError as error:
        raise ContractV7Error("E_RUNTIME_IO", "could not create audit workspace", {"reason": str(error)})
    return AuditWorkspacePermit(resolved_output, report)

