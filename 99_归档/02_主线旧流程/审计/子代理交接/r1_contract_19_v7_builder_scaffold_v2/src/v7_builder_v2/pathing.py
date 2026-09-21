"""Logical POSIX identity and Windows physical-alias safety rules."""

import os
import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Dict, Iterable, Tuple

from .errors import ContractV7Error, require, raise_stable_external


_DRIVE_RE = re.compile(r"^[A-Za-z]:")
_RESERVED = {"CON", "PRN", "AUX", "NUL"}
_RESERVED.update("COM%d" % value for value in range(1, 10))
_RESERVED.update("LPT%d" % value for value in range(1, 10))


@dataclass(frozen=True)
class PathIdentity:
    logical_posix: str
    windows_physical_alias: str


def _is_control(character: str) -> bool:
    return unicodedata.category(character) in ("Cc", "Cf")


def validate_logical_path(value: object) -> PathIdentity:
    require(isinstance(value, str) and bool(value), "E_PATH", "path must be a non-empty string")
    assert isinstance(value, str)
    require(value == unicodedata.normalize("NFC", value), "E_PATH_NFC", "path must already be NFC")
    require(not any(_is_control(character) for character in value), "E_PATH", "path contains control characters")
    require("\\" not in value, "E_PATH", "logical paths use POSIX separators only")
    require(not value.startswith("//"), "E_PATH_WINDOWS", "UNC paths are forbidden")
    require(not _DRIVE_RE.match(value), "E_PATH_WINDOWS", "drive-relative and drive-absolute paths are forbidden")
    require(":" not in value, "E_PATH_WINDOWS", "alternate data streams and colon paths are forbidden")
    logical = PurePosixPath(value)
    require(not logical.is_absolute(), "E_PATH", "logical path must be project-relative")
    parts = logical.parts
    require(parts and all(part not in ("", ".", "..") for part in parts), "E_PATH", "unsafe path segment")
    for part in parts:
        require(not part.endswith((".", " ")), "E_PATH_WINDOWS", "Windows strips a trailing dot or space")
        stem = part.split(".", 1)[0].upper()
        require(stem not in _RESERVED, "E_PATH_WINDOWS", "Windows reserved device name", {"segment": part})
    alias = "/".join(part.casefold() for part in parts)
    return PathIdentity(value, alias)


def validate_path_set(paths: Iterable[str]) -> Tuple[PathIdentity, ...]:
    identities = tuple(validate_logical_path(value) for value in paths)
    seen_logical: Dict[str, str] = {}
    seen_alias: Dict[str, str] = {}
    for identity in identities:
        normalized = unicodedata.normalize("NFC", identity.logical_posix)
        previous = seen_logical.get(normalized)
        require(previous is None, "E_PATH_COLLISION", "NFC path collision", {"first": previous, "second": identity.logical_posix})
        seen_logical[normalized] = identity.logical_posix
        previous = seen_alias.get(identity.windows_physical_alias)
        require(previous is None, "E_PATH_COLLISION", "Windows casefold alias collision", {"first": previous, "second": identity.logical_posix})
        seen_alias[identity.windows_physical_alias] = identity.logical_posix
    return identities


def resolve_contained(root: Path, logical_path: str, must_exist: bool = False) -> Path:
    """Resolve symlinks in every existing ancestor and enforce root containment."""

    validate_logical_path(logical_path)
    try:
        root_resolved = root.resolve(strict=True)
    except BaseException as error:
        if isinstance(error, FileNotFoundError):
            raise ContractV7Error("E_ROOT_NOT_FOUND", "mainline root does not exist", {"root": str(root)})
        raise_stable_external(error, "resolve mainline root")
    candidate = root_resolved.joinpath(*PurePosixPath(logical_path).parts)
    current = root_resolved
    for part in PurePosixPath(logical_path).parts:
        next_path = current / part
        if next_path.exists() or next_path.is_symlink():
            try:
                current = next_path.resolve(strict=True)
            except BaseException as error:
                raise_stable_external(error, "resolve project path")
            try:
                inside = os.path.commonpath((str(root_resolved), str(current))) == str(root_resolved)
            except ValueError:
                inside = False
            require(inside, "E_PATH_ESCAPE", "symlink or ancestor escapes the mainline root", {"path": logical_path})
        else:
            current = next_path
    if must_exist:
        require(current.exists(), "E_IO_NOT_FOUND", "required project path is absent", {"path": logical_path})
    return current

