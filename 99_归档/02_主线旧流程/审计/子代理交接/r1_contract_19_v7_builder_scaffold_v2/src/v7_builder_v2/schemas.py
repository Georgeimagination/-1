"""Restricted Draft 2020-12 evaluator for the four shipped JSON Schemas."""

import re
from pathlib import Path
from typing import Any, Callable, Dict, Mapping, Sequence, Tuple

from .canonical import parse_strict_json_bytes, require_exact_keys
from .errors import ContractV7Error, require, raise_stable_external
from .pathing import validate_logical_path
from .principals import validate_principal_id


SUPPORTED_KEYWORDS = {
    "$schema", "$id", "$defs", "$ref", "title", "description", "type",
    "additionalProperties", "required", "properties", "const", "enum", "pattern",
    "minLength", "minimum", "maximum", "minItems", "maxItems", "items", "oneOf",
}
ANNOTATIONS = {"$schema", "$id", "title", "description"}


def _walk_schema(schema: Any, root: Mapping[str, Any], pointer: str = "#") -> None:
    require(isinstance(schema, Mapping), "E_SCHEMA_TYPE", "schema node is not an object", {"pointer": pointer})
    unknown = set(schema) - SUPPORTED_KEYWORDS
    require(not unknown, "E_SCHEMA_KEYWORD", "unknown JSON Schema keyword", {"pointer": pointer, "unknown": sorted(unknown)})
    if "$ref" in schema:
        require(isinstance(schema["$ref"], str) and schema["$ref"].startswith("#/$defs/"), "E_SCHEMA_REF", "only local $defs refs are supported")
        name = schema["$ref"].split("/")[-1]
        require(isinstance(root.get("$defs"), Mapping) and name in root["$defs"], "E_SCHEMA_REF", "local schema ref is unresolved", {"ref": schema["$ref"]})
        require(not (set(schema) - ANNOTATIONS - {"$ref"}), "E_SCHEMA_REF", "$ref siblings with validation semantics are forbidden")
    if "$defs" in schema:
        require(isinstance(schema["$defs"], Mapping), "E_SCHEMA_TYPE", "$defs is not an object")
        for name, child in schema["$defs"].items():
            _walk_schema(child, root, pointer + "/$defs/" + str(name))
    if "properties" in schema:
        require(isinstance(schema["properties"], Mapping), "E_SCHEMA_TYPE", "properties is not an object")
        for name, child in schema["properties"].items():
            _walk_schema(child, root, pointer + "/properties/" + str(name))
    if "items" in schema:
        _walk_schema(schema["items"], root, pointer + "/items")
    if "oneOf" in schema:
        require(isinstance(schema["oneOf"], list) and schema["oneOf"], "E_SCHEMA_TYPE", "oneOf is not a nonempty array")
        for ordinal, child in enumerate(schema["oneOf"]):
            _walk_schema(child, root, pointer + "/oneOf/%d" % ordinal)


def load_schema(path: Path) -> Mapping[str, Any]:
    try:
        raw = path.read_bytes()
    except BaseException as error:
        raise_stable_external(error, "read JSON Schema")
    document = parse_strict_json_bytes(raw.rstrip(b"\r\n"))
    require(isinstance(document, Mapping), "E_SCHEMA_TYPE", "JSON Schema root is not an object")
    require(document.get("$schema") == "https://json-schema.org/draft/2020-12/schema", "E_SCHEMA_VERSION", "schema is not Draft 2020-12")
    _walk_schema(document, document)
    return document


def _type_matches(instance: Any, expected: str) -> bool:
    if expected == "null":
        return instance is None
    if expected == "boolean":
        return isinstance(instance, bool)
    if expected == "integer":
        return isinstance(instance, int) and not isinstance(instance, bool)
    if expected == "number":
        return (isinstance(instance, (int, float)) and not isinstance(instance, bool))
    if expected == "string":
        return isinstance(instance, str)
    if expected == "array":
        return isinstance(instance, list)
    if expected == "object":
        return isinstance(instance, Mapping)
    raise ContractV7Error("E_SCHEMA_TYPE", "unknown JSON Schema type", {"type": expected})


def _resolve_ref(root: Mapping[str, Any], ref: str) -> Mapping[str, Any]:
    name = ref.split("/")[-1]
    defs = root.get("$defs")
    require(isinstance(defs, Mapping) and isinstance(defs.get(name), Mapping), "E_SCHEMA_REF", "local schema ref is unresolved", {"ref": ref})
    return defs[name]


def _validate(schema: Mapping[str, Any], instance: Any, root: Mapping[str, Any], pointer: str) -> None:
    if "$ref" in schema:
        _validate(_resolve_ref(root, schema["$ref"]), instance, root, pointer)
        return
    if "oneOf" in schema:
        accepted = 0
        for choice in schema["oneOf"]:
            try:
                _validate(choice, instance, root, pointer)
                accepted += 1
            except ContractV7Error:
                pass
        require(accepted == 1, "E_SCHEMA_INSTANCE", "oneOf must match exactly once", {"pointer": pointer, "matches": accepted})
    if "type" in schema:
        expected = schema["type"]
        types = [expected] if isinstance(expected, str) else expected
        require(isinstance(types, list) and all(isinstance(item, str) for item in types), "E_SCHEMA_TYPE", "schema type declaration is invalid")
        require(any(_type_matches(instance, item) for item in types), "E_SCHEMA_INSTANCE", "instance type differs", {"pointer": pointer, "expected": types})
    if "const" in schema:
        require(instance == schema["const"], "E_SCHEMA_INSTANCE", "instance differs from const", {"pointer": pointer})
    if "enum" in schema:
        require(isinstance(schema["enum"], list) and instance in schema["enum"], "E_SCHEMA_INSTANCE", "instance is outside enum", {"pointer": pointer})
    if isinstance(instance, str):
        if "minLength" in schema:
            require(len(instance) >= schema["minLength"], "E_SCHEMA_INSTANCE", "string is shorter than minLength", {"pointer": pointer})
        if "pattern" in schema:
            try:
                matched = re.search(schema["pattern"], instance) is not None
            except (re.error, TypeError):
                raise ContractV7Error("E_SCHEMA_TYPE", "schema pattern is invalid", {"pointer": pointer})
            require(matched, "E_SCHEMA_INSTANCE", "string does not match pattern", {"pointer": pointer})
    if isinstance(instance, int) and not isinstance(instance, bool):
        if "minimum" in schema:
            require(instance >= schema["minimum"], "E_SCHEMA_INSTANCE", "integer is below minimum", {"pointer": pointer})
        if "maximum" in schema:
            require(instance <= schema["maximum"], "E_SCHEMA_INSTANCE", "integer is above maximum", {"pointer": pointer})
    if isinstance(instance, list):
        if "minItems" in schema:
            require(len(instance) >= schema["minItems"], "E_SCHEMA_INSTANCE", "array is shorter than minItems", {"pointer": pointer})
        if "maxItems" in schema:
            require(len(instance) <= schema["maxItems"], "E_SCHEMA_INSTANCE", "array is longer than maxItems", {"pointer": pointer})
        if "items" in schema:
            for ordinal, item in enumerate(instance):
                _validate(schema["items"], item, root, pointer + "/%d" % ordinal)
    if isinstance(instance, Mapping):
        required = schema.get("required", [])
        require(isinstance(required, list) and all(isinstance(item, str) for item in required), "E_SCHEMA_TYPE", "required is invalid")
        missing = [key for key in required if key not in instance]
        require(not missing, "E_SCHEMA_INSTANCE", "required object property is absent", {"pointer": pointer, "missing": missing})
        properties = schema.get("properties", {})
        require(isinstance(properties, Mapping), "E_SCHEMA_TYPE", "properties is invalid")
        if schema.get("additionalProperties") is False:
            extra = set(instance) - set(properties)
            require(not extra, "E_SCHEMA_INSTANCE", "additional object property is forbidden", {"pointer": pointer, "extra": sorted(extra)})
        elif "additionalProperties" in schema:
            require(schema["additionalProperties"] is True, "E_SCHEMA_TYPE", "restricted evaluator supports boolean additionalProperties only")
        for key, child_schema in properties.items():
            if key in instance:
                _validate(child_schema, instance[key], root, pointer + "/" + key)


def validate_instance(schema: Mapping[str, Any], instance: Any) -> None:
    _walk_schema(schema, schema)
    _validate(schema, instance, schema, "#")


def manual_bootstrap_item(instance: Mapping[str, Any]) -> None:
    keys = ("input_role", "source_path", "logical_target_path", "preimage_state", "raw_sha256", "canonical_domain_tag", "canonical_sha256")
    require_exact_keys(instance, keys)
    require(isinstance(instance["input_role"], str) and bool(instance["input_role"]), "E_JSON_TYPE", "bootstrap role is empty")
    validate_logical_path(instance["source_path"])
    validate_logical_path(instance["logical_target_path"])
    require(instance["preimage_state"] in ("present", "absent"), "E_JSON_TYPE", "bootstrap state differs")
    require(isinstance(instance["raw_sha256"], str) and bool(re.fullmatch(r"[0-9a-f]{64}", instance["raw_sha256"])), "E_SHA256", "bootstrap raw hash differs")
    null = instance["canonical_domain_tag"] is None and instance["canonical_sha256"] is None
    present = isinstance(instance["canonical_domain_tag"], str) and bool(instance["canonical_domain_tag"]) and isinstance(instance["canonical_sha256"], str) and bool(re.fullmatch(r"[0-9a-f]{64}", instance["canonical_sha256"]))
    require(null or present, "E_CANONICAL_NULL", "canonical domain/hash must be jointly null/present")


def manual_prerequisite(instance: Mapping[str, Any]) -> None:
    from .preflight import _validate_prerequisite
    _validate_prerequisite(instance)


def manual_approval(instance: Mapping[str, Any]) -> None:
    keys = ("approval_contract_version", "approval_id", "artifact_kind", "artifact_id", "artifact_canonical_sha256", "approved_by", "approved_date", "approval_status", "notes")
    require_exact_keys(instance, keys)
    require(instance["approval_contract_version"] == "ARTIFACT-APPROVAL-V1", "E_APPROVAL_BINDING", "approval version differs")
    for field in ("approval_id", "artifact_kind", "artifact_id"):
        require(isinstance(instance[field], str) and bool(instance[field]), "E_JSON_TYPE", "%s is empty" % field)
    require(isinstance(instance["artifact_canonical_sha256"], str) and bool(re.fullmatch(r"[0-9a-f]{64}", instance["artifact_canonical_sha256"])), "E_SHA256", "approval artifact hash differs")
    validate_principal_id(instance["approved_by"], "approved_by")
    require(isinstance(instance["approved_date"], str) and bool(re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", instance["approved_date"])), "E_DATE", "approval date shape differs")
    from datetime import date
    try:
        parsed_date = date.fromisoformat(instance["approved_date"])
    except ValueError:
        raise ContractV7Error("E_DATE", "approval date is not real")
    require(parsed_date.isoformat() == instance["approved_date"], "E_DATE", "approval date is not canonical")
    require(instance["approval_status"] == "approved" and (instance["notes"] is None or isinstance(instance["notes"], str)), "E_APPROVAL_BINDING", "approval status/notes differs")


def manual_validation_report(instance: Mapping[str, Any]) -> None:
    keys = ("report_contract_version", "generated_by", "scope", "status", "unit_tests", "live_preflight", "artifacts", "failure_classification")
    require_exact_keys(instance, keys)
    require(instance["report_contract_version"] == "R19-VALIDATION-REPORT-V1", "E_REQUIRED_SET", "validation report version differs")
    require(instance["status"] in ("PASS_WITH_EXPECTED_LIVE_BLOCK", "FAIL"), "E_REQUIRED_SET", "validation report status differs")
    require(isinstance(instance["unit_tests"], Mapping) and isinstance(instance["live_preflight"], Mapping), "E_JSON_TYPE", "validation report result objects are absent")
    require(isinstance(instance["artifacts"], list) and isinstance(instance["failure_classification"], list), "E_JSON_TYPE", "validation report arrays are absent")


def cross_check(schema: Mapping[str, Any], instance: Any, manual: Callable[[Mapping[str, Any]], None]) -> bool:
    schema_error = None
    manual_error = None
    try:
        validate_instance(schema, instance)
    except ContractV7Error as error:
        schema_error = error
    try:
        require(isinstance(instance, Mapping), "E_JSON_TYPE", "manual semantic validator expects an object")
        manual(instance)
    except ContractV7Error as error:
        manual_error = error
    require((schema_error is None) == (manual_error is None), "E_SCHEMA_CROSSCHECK", "schema and manual semantic validator disagree", {"schema_error": None if schema_error is None else schema_error.code, "manual_error": None if manual_error is None else manual_error.code})
    if schema_error is not None:
        raise schema_error
    return True
