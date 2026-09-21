"""TOCTOU-safe audit snapshot guard; no formal apply implementation."""

import os
import secrets
from pathlib import Path
from typing import Union

from .errors import ContractV7Error, require, raise_stable_external
from .preflight import ReadyReport, revalidate_ready_report


PACKAGE_RELATIVE_ROOT = "审计/子代理交接/r1_contract_19_v7_builder_scaffold_v2"


def _allowed_destination(mainline_root: Path, destination: Path) -> Path:
    try:
        root = mainline_root.resolve(strict=True)
        resolved_parent = destination.parent.resolve(strict=True)
    except BaseException as error:
        raise_stable_external(error, "resolve audit snapshot destination")
    candidate = resolved_parent / destination.name
    package_root = (root / PACKAGE_RELATIVE_ROOT).resolve(strict=False)
    private_tmp = Path("/private/tmp").resolve(strict=True)
    try:
        in_package = os.path.commonpath((str(package_root), str(candidate))) == str(package_root)
        in_private_tmp = os.path.commonpath((str(private_tmp), str(candidate))) == str(private_tmp)
    except ValueError:
        in_package = in_private_tmp = False
    require(in_package or in_private_tmp, "E_OUTPUT_BOUNDARY", "snapshot destination is outside r19 and /private/tmp")
    require(not destination.exists(), "E_OUTPUT_EXISTS", "audit snapshot destination already exists")
    return candidate


def atomic_guarded_snapshot(report: ReadyReport, mainline_root: Path, destination: Path, payload: Union[bytes, bytearray]) -> Path:
    """Revalidate READY immediately before the first filesystem write."""

    require(isinstance(payload, (bytes, bytearray)), "E_WRITE_PROTOCOL", "snapshot payload must be bytes")
    destination = _allowed_destination(mainline_root, destination)
    # No mkdir, temp file, snapshot, or candidate exists before this call.
    revalidate_ready_report(report, mainline_root)
    temporary = destination.parent / (".%s.tmp.%s" % (destination.name, secrets.token_hex(8)))
    descriptor = None
    try:
        descriptor = os.open(str(temporary), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
        require(os.fstat(descriptor).st_dev == os.stat(destination.parent).st_dev, "E_WRITE_PROTOCOL", "temp and destination are not on the same volume")
        view = memoryview(bytes(payload))
        offset = 0
        while offset < len(view):
            written = os.write(descriptor, view[offset:])
            require(written > 0, "E_IO", "snapshot write made no progress")
            offset += written
        os.fsync(descriptor)
        os.close(descriptor)
        descriptor = None
        require(not destination.exists(), "E_OUTPUT_EXISTS", "destination appeared before atomic rename")
        os.replace(str(temporary), str(destination))
        parent_fd = os.open(str(destination.parent), os.O_RDONLY)
        try:
            os.fsync(parent_fd)
        finally:
            os.close(parent_fd)
        return destination
    except BaseException as error:
        if descriptor is not None:
            os.close(descriptor)
        try:
            if temporary.exists():
                temporary.unlink()
        except OSError:
            pass
        if isinstance(error, ContractV7Error):
            raise
        raise_stable_external(error, "exclusive atomic audit snapshot")

