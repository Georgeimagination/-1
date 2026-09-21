"""Independent 24/47 formula-use projection, including structural enum output."""

import csv
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path
from typing import Dict, List, Mapping, Optional, Sequence, Tuple

from .errors import ContractV7Error, require, raise_stable_external


DECIMAL_RE = re.compile(r"(?:0|-?[1-9][0-9]*(?:\.[0-9]+)?|0\.[0-9]+)\Z")


@dataclass(frozen=True)
class UnitOption:
    unit: str
    scale: str


@dataclass(frozen=True)
class InputContract:
    order: int
    role: str
    fields: Tuple[str, ...]
    units: Tuple[UnitOption, ...]
    required: Optional[str] = None


@dataclass(frozen=True)
class FormulaSpec:
    formula_id: str
    operation: str
    arity: int
    inputs: Tuple[InputContract, ...]
    output_kind: str
    output_unit: str
    constant_decimal: Optional[str]
    constant_text: Optional[str]
    decimal_places: Optional[int]
    rounding: str
    output_field: str


@dataclass(frozen=True)
class FormulaInputProjection:
    input_order: int
    input_role: str
    input_field_id: str
    input_normalized_unit: str
    input_normalized_value: str


@dataclass(frozen=True)
class FormulaUseProjection:
    formula_id: str
    derived_metric_id: str
    derived_fact_id: str
    output_field_id: str
    output_fact_value_kind: str
    output_fact_normalized_unit: str
    metric_output_unit: str
    arity: int
    inputs: Tuple[FormulaInputProjection, ...]


def _input(order: int, role: str, field: str, unit: str, scale: str = "1", required: Optional[str] = None) -> InputContract:
    return InputContract(order, role, (field,), (UnitOption(unit, scale),), required)


def formula_registry_v7() -> Dict[str, FormulaSpec]:
    values = (
        FormulaSpec("FORMULA-COMPUTE-DIV-MEMBW", "divide", 2, (_input(1, "numerator", "FIELD-COMP-THROUGHPUT", "TFLOP/s", "1000000000000"), _input(2, "denominator", "FIELD-MEM-READ-BW", "byte/s")), "number", "FLOP/byte", None, None, 2, "round_half_up", "FIELD-DER-COMPUTE-BW-SPEC"),
        FormulaSpec("FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW", "divide", 2, (_input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/s"), _input(2, "denominator", "FIELD-MEM-BIDIR-BW", "byte/s")), "number", "FLOP/byte", None, None, 1, "round_half_up", "FIELD-DER-COMPUTE-BW-SPEC"),
        FormulaSpec("FORMULA-AWS-TRN2-CORE-X8", "multiply", 2, (_input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/s"), _input(2, "scale", "FIELD-COMP-UNIT-COUNT", "count", required="8")), "number", "FLOP/s", None, None, None, "exact", "FIELD-COMP-THROUGHPUT"),
        FormulaSpec("FORMULA-MATRIX-DIV-VECTOR", "divide", 2, (_input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/cycle/CU"), _input(2, "denominator", "FIELD-COMP-THROUGHPUT", "FLOP/cycle/CU")), "number", "ratio", None, None, None, "exact", "FIELD-DER-MATRIX-VECTOR"),
        FormulaSpec("FORMULA-STRUCTURAL-PROJECTION", "emit_constant_text", 1, (_input(1, "other", "FIELD-MEM-CAPACITY", "byte", required="262144"),), "text", "enum:pooling_mode", None, "distributed_not_pooled", None, "none", "FIELD-MEM-POOLING-MODE"),
        FormulaSpec("FORMULA-GA100-HBM-CONTROLLER-COUNT-X512", "multiply_by_constant", 1, (_input(1, "controller_count", "FIELD-COMP-UNIT-COUNT", "count", required="12"),), "number", "bit", "512", None, None, "exact", "FIELD-PHY-HBM-INTERFACE"),
        FormulaSpec("FORMULA-GA100-NVLINK-COUNT-X25GBPS", "multiply_by_constant", 1, (_input(1, "physical_link_count", "FIELD-INT-PHYSICAL-LINK-COUNT", "count", required="12"),), "number", "byte/s", "25000000000", None, None, "exact", "FIELD-INT-INJECTION-BW"),
        FormulaSpec("FORMULA-GA100-BIDIRECTIONAL-X2", "multiply_by_constant", 1, (_input(1, "one_direction_bandwidth", "FIELD-INT-INJECTION-BW", "byte/s"),), "number", "byte/s", "2", None, None, "exact", "FIELD-INT-AGGREGATE-BW"),
    )
    result = {item.formula_id: item for item in values}
    require(len(result) == 8, "E_DUPLICATE", "v7 formula registry IDs are duplicated")
    return result


def validate_formula_registry(specs: Mapping[str, FormulaSpec]) -> None:
    expected = set(formula_registry_v7())
    require(set(specs) == expected, "E_UNKNOWN_FORMULA", "formula ID set differs from five used plus three preregistered")
    for formula_id, spec in specs.items():
        require(spec.formula_id == formula_id and spec.arity > 0, "E_FORMULA_ARITY", "formula key/arity differs")
        require(tuple(item.order for item in spec.inputs) == tuple(range(1, spec.arity + 1)), "E_FORMULA_ARITY", "input order is not continuous")
        require(len(spec.inputs) == spec.arity, "E_FORMULA_ARITY", "input count differs from arity")
        if spec.output_kind == "text":
            require(spec.operation == "emit_constant_text" and spec.constant_text is not None and spec.constant_decimal is None, "E_FORMULA_OUTPUT_DESCRIPTOR", "text formula descriptor differs")
            require(spec.output_unit.startswith("enum:") and spec.rounding == "none" and spec.decimal_places is None, "E_FORMULA_OUTPUT_DESCRIPTOR", "text formula enum/rounding descriptor differs")
        else:
            require(spec.output_kind == "number" and spec.operation in ("divide", "multiply", "multiply_by_constant"), "E_FORMULA_OUTPUT_DESCRIPTOR", "numeric formula descriptor differs")
            require(spec.output_unit and spec.rounding in ("exact", "round_half_up"), "E_FORMULA_OUTPUT_DESCRIPTOR", "numeric unit/rounding descriptor differs")


def _read(path: Path, required_columns: Sequence[str]) -> List[Dict[str, str]]:
    try:
        with path.open("r", encoding="utf-8-sig", newline="") as handle:
            reader = csv.DictReader(handle, strict=True)
            require(reader.fieldnames is not None and len(set(reader.fieldnames)) == len(reader.fieldnames), "E_CSV_HEADER", "formula input CSV header differs")
            require(set(required_columns).issubset(reader.fieldnames), "E_CSV_HEADER", "formula input CSV lacks a required column", {"required": list(required_columns), "actual": reader.fieldnames})
            return list(reader)
    except BaseException as error:
        if isinstance(error, ContractV7Error):
            raise
        raise_stable_external(error, "read formula input CSV")


def _unique(rows: Sequence[Mapping[str, str]], key: str) -> Dict[str, Mapping[str, str]]:
    output: Dict[str, Mapping[str, str]] = {}
    for row in rows:
        require(key in row, "E_CSV_HEADER", "formula input column is absent", {"column": key})
        value = row[key]
        require(value not in output, "E_DUPLICATE", "formula input key is duplicated", {"column": key, "value": value})
        output[value] = row
    return output


def _decimal(value: str) -> Decimal:
    require(isinstance(value, str) and bool(DECIMAL_RE.fullmatch(value)), "E_FORMULA_VALUE", "formula decimal is not canonical", {"value": value})
    try:
        return Decimal(value)
    except InvalidOperation:
        raise ContractV7Error("E_FORMULA_VALUE", "formula decimal is invalid")


def _calculate(spec: FormulaSpec, inputs: Sequence[Decimal]) -> Decimal:
    if spec.operation == "divide":
        require(len(inputs) == 2 and inputs[1] != 0, "E_FORMULA_VALUE", "formula division is invalid")
        result = inputs[0] / inputs[1]
    elif spec.operation == "multiply":
        require(len(inputs) == 2, "E_FORMULA_ARITY", "multiply needs two inputs")
        result = inputs[0] * inputs[1]
    elif spec.operation == "multiply_by_constant":
        require(len(inputs) == 1 and spec.constant_decimal is not None, "E_FORMULA_ARITY", "constant multiplication shape differs")
        result = inputs[0] * _decimal(spec.constant_decimal)
    else:
        raise ContractV7Error("E_FORMULA_OUTPUT_DESCRIPTOR", "text operation reached numeric evaluator")
    if spec.rounding == "round_half_up":
        require(spec.decimal_places is not None, "E_FORMULA_OUTPUT_DESCRIPTOR", "decimal places are absent")
        return result.quantize(Decimal(1).scaleb(-spec.decimal_places), rounding=ROUND_HALF_UP)
    require(spec.rounding == "exact" and spec.decimal_places is None, "E_FORMULA_OUTPUT_DESCRIPTOR", "exact rounding descriptor differs")
    return result


def _format(value: Decimal, places: Optional[int]) -> str:
    if places is not None:
        return format(value, ".%df" % places)
    text = format(value, "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return "0" if text in ("", "-0") else text


def build_formula_use_projections(data_dir: Path) -> Tuple[FormulaUseProjection, ...]:
    metrics = _read(data_dir / "derived-metrics.csv", ("derived_metric_id", "derived_fact_id", "formula_id", "output_unit"))
    inputs = _read(data_dir / "derived-inputs.csv", ("derived_input_id", "derived_fact_id", "input_order", "input_fact_id", "input_role"))
    facts = _unique(_read(data_dir / "facts.csv", ("fact_id", "field_id", "normalized_unit", "normalized_value_number", "normalized_value_text")), "fact_id")
    fields = _unique(_read(data_dir / "fields.csv", ("field_id", "value_kind", "value_enum_name", "canonical_unit")), "field_id")
    registry = formula_registry_v7()
    validate_formula_registry(registry)
    require((len(metrics), len(inputs)) == (24, 47), "E_REQUIRED_SET", "formula base must contain exactly 24 metrics and 47 inputs")
    require(len({row["derived_metric_id"] for row in metrics}) == 24, "E_DUPLICATE", "derived_metric_id is duplicated")
    by_output: Dict[str, List[Mapping[str, str]]] = defaultdict(list)
    for row in inputs:
        by_output[row["derived_fact_id"]].append(row)
    projections = []
    consumed_inputs = set()
    for metric in metrics:
        formula_id = metric["formula_id"]
        require(formula_id in registry, "E_UNKNOWN_FORMULA", "derived metric references an unregistered formula")
        spec = registry[formula_id]
        derived_fact_id = metric["derived_fact_id"]
        require(derived_fact_id in facts, "E_FORMULA_VALUE", "derived output fact is absent")
        fact = facts[derived_fact_id]
        field_id = fact["field_id"]
        require(field_id in fields and field_id == spec.output_field, "E_FORMULA_OUTPUT_DESCRIPTOR", "formula output field differs")
        field = fields[field_id]
        try:
            ordered = sorted(by_output.get(derived_fact_id, ()), key=lambda row: int(row["input_order"]))
        except (ValueError, TypeError):
            raise ContractV7Error("E_VALUE_PARSE", "formula input_order is not an integer")
        require(len(ordered) == spec.arity and [int(row["input_order"]) for row in ordered] == list(range(1, spec.arity + 1)), "E_FORMULA_ARITY", "formula inputs do not cover continuous 1..arity")
        input_projection = []
        scaled = []
        for row, contract in zip(ordered, spec.inputs):
            require(row["derived_input_id"] not in consumed_inputs, "E_DUPLICATE", "derived input is consumed twice")
            consumed_inputs.add(row["derived_input_id"])
            require(row["input_role"] == contract.role, "E_FORMULA_VALUE", "formula input role differs")
            input_fact_id = row["input_fact_id"]
            require(input_fact_id in facts, "E_FORMULA_VALUE", "formula input fact is absent")
            input_fact = facts[input_fact_id]
            input_field, unit, number = input_fact["field_id"], input_fact["normalized_unit"], input_fact["normalized_value_number"]
            require(input_field in contract.fields, "E_FORMULA_VALUE", "formula input field is not allowed")
            options = {option.unit: option for option in contract.units}
            require(unit in options, "E_FORMULA_VALUE", "formula input unit is not allowed")
            value = _decimal(number)
            if contract.required is not None:
                require(value == _decimal(contract.required), "E_FORMULA_VALUE", "formula required decimal differs")
            scaled.append(value * _decimal(options[unit].scale))
            input_projection.append(FormulaInputProjection(contract.order, contract.role, input_field, unit, number))
        if spec.output_kind == "text":
            require(field["value_kind"] == "enum" and field["value_enum_name"], "E_FORMULA_OUTPUT_DESCRIPTOR", "structural text output field is not enum")
            token = "enum:" + field["value_enum_name"]
            require(spec.output_unit == token and metric["output_unit"] == token, "E_FORMULA_OUTPUT_DESCRIPTOR", "structural enum token differs")
            require(fact["normalized_unit"] == "", "E_FORMULA_FACT_UNIT", "structural enum fact unit must be empty")
            require(fact["normalized_value_number"] == "" and fact["normalized_value_text"] == spec.constant_text, "E_FORMULA_VALUE", "structural enum fact value differs")
            output_kind = "text"
        else:
            require(metric["output_unit"] == spec.output_unit, "E_FORMULA_OUTPUT_DESCRIPTOR", "metric output unit differs")
            require(fact["normalized_unit"] == spec.output_unit, "E_FORMULA_FACT_UNIT", "numeric fact unit differs")
            if field["canonical_unit"]:
                require(field["canonical_unit"] == spec.output_unit, "E_FORMULA_OUTPUT_DESCRIPTOR", "field canonical unit differs")
            require(fact["normalized_value_text"] == "", "E_FORMULA_VALUE", "numeric output fact has text")
            expected = _format(_calculate(spec, scaled), spec.decimal_places)
            require(fact["normalized_value_number"] == expected, "E_FORMULA_VALUE", "derived numeric value differs", {"expected": expected, "actual": fact["normalized_value_number"]})
            output_kind = "number"
        projections.append(FormulaUseProjection(formula_id, metric["derived_metric_id"], derived_fact_id, field_id, output_kind, fact["normalized_unit"], metric["output_unit"], spec.arity, tuple(input_projection)))
    expected_distribution = Counter({"FORMULA-COMPUTE-DIV-MEMBW": 7, "FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW": 4, "FORMULA-AWS-TRN2-CORE-X8": 11, "FORMULA-MATRIX-DIV-VECTOR": 1, "FORMULA-STRUCTURAL-PROJECTION": 1})
    require(Counter(item.formula_id for item in projections) == expected_distribution, "E_REQUIRED_SET", "24-row formula usage distribution differs")
    require(len(consumed_inputs) == 47 and sum(len(item.inputs) for item in projections) == 47, "E_REQUIRED_SET", "formula projection did not consume exact 47 inputs")
    return tuple(projections)
