"""Stable, non-confusable principal identity contract."""

import re
import unicodedata
from typing import Mapping, Tuple

from .errors import require


_PRINCIPAL_RE = re.compile(r"[\w.@:+-]+\Z", re.UNICODE)


def validate_principal_id(value: object, field: str) -> str:
    require(isinstance(value, str) and bool(value), "E_PRINCIPAL_ID", "%s is empty" % field)
    assert isinstance(value, str)
    require(value == value.strip(), "E_PRINCIPAL_ID", "%s has leading or trailing whitespace" % field)
    require(not any(character.isspace() for character in value), "E_PRINCIPAL_ID", "%s contains whitespace" % field)
    require(value == unicodedata.normalize("NFC", value), "E_PRINCIPAL_ID", "%s is not NFC" % field)
    require(bool(_PRINCIPAL_RE.fullmatch(value)), "E_PRINCIPAL_ID", "%s contains a forbidden scalar" % field)
    return value


def validate_independent_principals(values: Mapping[str, object]) -> Tuple[str, ...]:
    required = ("prepared_by", "reviewed_by", "approved_by")
    require(set(values) == set(required), "E_PRINCIPAL_ID", "principal role set must be exact")
    principals = tuple(validate_principal_id(values[field], field) for field in required)
    aliases = tuple(unicodedata.normalize("NFC", value).casefold() for value in principals)
    require(len(set(aliases)) == len(aliases), "E_PRINCIPAL_COLLISION", "principal IDs collide after NFC/casefold")
    return principals

