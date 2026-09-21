"""Independent 24/47 formula-use projection and evaluator."""

import csv
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

from .errors import ContractV7Error, require


DECIMAL_RE = re.compile(r"(?:0|-?[1-9][0-9]*(?:\.[0-9]+)?|0\.[0-9]+)\Z")


@dataclass(frozen=True)
class UnitOption:
    unit: str
    scale_to_base_decimal: str


@dataclass(frozen=True)
class InputContract:
    input_order: int
    input_role: str
    allowed_field_ids: Tuple[str, ...]
    unit_options: Tuple[UnitOption, ...]
    required_decimal: Optional[str] = None


@dataclass(frozen=True)
class FormulaSpec:
    formula_id: str
    operation: str
    arity: int
    input_contracts: Tuple[InputContract, ...]
    output_value_kind: str
    output_unit: str
    constant_decimal: Optional[str]
    constant_text: Optional[str]
    decimal_places: Optional[int]
    rounding_mode: str
    required_output_field_id: str


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


def _input(
    order: int,
    role: str,
    field_id: str,
    unit: str,
    scale: str = "1",
    required: Optional[str] = None,
) -> InputContract:
    return InputContract(order, role, (field_id,), (UnitOption(unit, scale),), required)


def formula_registry_v7() -> Dict[str, FormulaSpec]:
    specs = (
        FormulaSpec(
            "FORMULA-COMPUTE-DIV-MEMBW",
            "divide",
            2,
            (
                _input(1, "numerator", "FIELD-COMP-THROUGHPUT", "TFLOP/s", "1000000000000"),
                _input(2, "denominator", "FIELD-MEM-READ-BW", "byte/s"),
            ),
            "number",
            "FLOP/byte",
            None,
            None,
            2,
            "round_half_up",
            "FIELD-DER-COMPUTE-BW-SPEC",
        ),
        FormulaSpec(
            "FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW",
            "divide",
            2,
            (
                _input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/s"),
                _input(2, "denominator", "FIELD-MEM-BIDIR-BW", "byte/s"),
            ),
            "number",
            "FLOP/byte",
            None,
            None,
            1,
            "round_half_up",
            "FIELD-DER-COMPUTE-BW-SPEC",
        ),
        FormulaSpec(
            "FORMULA-AWS-TRN2-CORE-X8",
            "multiply",
            2,
            (
                _input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/s"),
                _input(2, "scale", "FIELD-COMP-UNIT-COUNT", "count", required="8"),
            ),
            "number",
            "FLOP/s",
            None,
            None,
            None,
            "exact",
            "FIELD-COMP-THROUGHPUT",
        ),
        FormulaSpec(
            "FORMULA-MATRIX-DIV-VECTOR",
            "divide",
            2,
            (
                _input(1, "numerator", "FIELD-COMP-THROUGHPUT", "FLOP/cycle/CU"),
                _input(2, "denominator", "FIELD-COMP-THROUGHPUT", "FLOP/cycle/CU"),
            ),
            "number",
            "ratio",
            None,
            None,
            None,
            "exact",
            "FIELD-DER-MATRIX-VECTOR",
        ),
        FormulaSpec(
            "FORMULA-STRUCTURAL-PROJECTION",
            "emit_constant_text",
            1,
            (_input(1, "other", "FIELD-MEM-CAPACITY", "byte", required="262144"),),
            "text",
            "enum:pooling_mode",
            None,
            "distributed_not_pooled",
            None,
            "none",
            "FIELD-MEM-POOLING-MODE",
        ),
        FormulaSpec(
            "FORMULA-GA100-HBM-CONTROLLER-COUNT-X512",
            "multiply_by_constant",
            1,
            (_input(1, "controller_count", "FIELD-COMP-UNIT-COUNT", "count", required="12"),),
            "number",
            "bit",
            "512",
            None,
            None,
            "exact",
            "FIELD-PHY-HBM-INTERFACE",
        ),
        FormulaSpec(
            "FORMULA-GA100-NVLINK-COUNT-X25GBPS",
            "multiply_by_constant",
            1,
            (_input(1, "physical_link_count", "FIELD-INT-PHYSICAL-LINK-COUNT", "count", required="12"),),
            "number",
            "byte/s",
            "25000000000",
            None,
            None,
            "exact",
            "FIELD-INT-INJECTION-BW",
        ),
        FormulaSpec(
            "FORMULA-GA100-BIDIRECTIONAL-X2",
            "multiply_by_constant",
            1,
            (_input(1, "one_direction_bandwidth", "FIELD-INT-INJECTION-BW", "byte/s"),),
            "number",
            "byte/s",
            "2",
            None,
            None,
            "exact",
            "FIELD-INT-AGGREGATE-BW",
        ),
    )
    registry = {spec.formula_id: spec for spec in specs}
    require(len(registry) == 8, "E_DUPLICATE", "formula IDs must be unique")
    return registry


def _read_csv(path: Path) -> List[Dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle, strict=True))


def _unique_by(rows: Sequence[Mapping[str, str]], key: str) -> Dict[str, Mapping[str, str]]:
    result: Dict[str, Mapping[str, str]] = {}
    for row in rows:
        value = row[key]
        require(value not in result, "E_DUPLICATE", "duplicate CSV key", {"column": key, "value": value})
        result[value] = row
    return result


def _decimal(raw: str, error_code: str = "E_FORMULA_VALUE") -> Decimal:
    require(bool(DECIMAL_RE.fullmatch(raw)), error_code, "non-canonical decimal", {"value": raw})
    try:
        return Decimal(raw)
    except InvalidOperation:
        raise ContractV7Error(error_code, "invalid decimal", {"value": raw})


def _format_decimal(value: Decimal, places: Optional[int]) -> str:
    if places is not None:
        quantum = Decimal(1).scaleb(-places)
        return format(value.quantize(quantum, rounding=ROUND_HALF_UP), ".%df" % places)
    text = format(value, "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return "0" if text in ("", "-0") else text


def _evaluate_numeric(spec: FormulaSpec, values: Sequence[Decimal]) -> Decimal:
    if spec.operation == "divide":
        require(len(values) == 2 and values[1] != 0, "E_FORMULA_VALUE", "invalid division")
        value = values[0] / values[1]
    elif spec.operation == "multiply":
        require(len(values) == 2, "E_FORMULA_ARITY", "multiply requires two inputs")
        value = values[0] * values[1]
    elif spec.operation == "multiply_by_constant":
        require(len(values) == 1 and spec.constant_decimal is not None, "E_FORMULA_ARITY", "constant multiply shape mismatch")
        value = values[0] * _decimal(spec.constant_decimal)
    else:
        raise ContractV7Error("E_FORMULA_OUTPUT_DESCRIPTOR", "non-numeric formula in numeric evaluator")
    if spec.rounding_mode == "round_half_up":
        require(spec.decimal_places is not None, "E_FORMULA_OUTPUT_DESCRIPTOR", "rounding places missing")
        return value.quantize(Decimal(1).scaleb(-spec.decimal_places), rounding=ROUND_HALF_UP)
    require(spec.rounding_mode == "exact", "E_FORMULA_OUTPUT_DESCRIPTOR", "numeric rounding mode invalid")
    require(spec.decimal_places is None, "E_FORMULA_OUTPUT_DESCRIPTOR", "exact formula cannot declare places")
    return value


def build_formula_use_projections(data_dir: Path) -> Tuple[FormulaUseProjection, ...]:
    metrics = _read_csv(data_dir / "derived-metrics.csv")
    inputs = _read_csv(data_dir / "derived-inputs.csv")
    facts = _unique_by(_read_csv(data_dir / "facts.csv"), "fact_id")
    fields = _unique_by(_read_csv(data_dir / "fields.csv"), "field_id")
    registry = formula_registry_v7()
    require(len(metrics) == 24, "E_REQUIRED_SET", "current formula usage must have 24 metrics")
    require(len(inputs) == 47, "E_REQUIRED_SET", "current formula usage must have 47 inputs")
    metric_ids = [row["derived_metric_id"] for row in metrics]
    require(len(metric_ids) == len(set(metric_ids)), "E_DUPLICATE", "derived_metric_id duplicated")
    by_derived_fact: Dict[str, List[Mapping[str, str]]] = defaultdict(list)
    for row in inputs:
        by_derived_fact[row["derived_fact_id"]].append(row)
    projections: List[FormulaUseProjection] = []
    for metric in metrics:
        formula_id = metric["formula_id"]
        require(formula_id in registry, "E_UNKNOWN_FORMULA", "unregistered formula", {"formula_id": formula_id})
        spec = registry[formula_id]
        derived_fact_id = metric["derived_fact_id"]
        require(derived_fact_id in facts, "E_FORMULA_VALUE", "derived output fact is missing")
        output_fact = facts[derived_fact_id]
        output_field_id = output_fact["field_id"]
        require(output_field_id in fields, "E_FORMULA_VALUE", "output field is missing")
        output_field = fields[output_field_id]
        require(output_field_id == spec.required_output_field_id, "E_FORMULA_OUTPUT_DESCRIPTOR", "wrong output field")
        ordered_inputs = sorted(by_derived_fact.get(derived_fact_id, []), key=lambda row: int(row["input_order"]))
        require(len(ordered_inputs) == spec.arity, "E_FORMULA_ARITY", "formula input count differs from arity")
        require(
            [int(row["input_order"]) for row in ordered_inputs] == list(range(1, spec.arity + 1)),
            "E_FORMULA_ARITY",
            "formula input_order must be continuous from one",
        )
        input_projections: List[FormulaInputProjection] = []
        scaled_values: List[Decimal] = []
        for row, contract in zip(ordered_inputs, spec.input_contracts):
            require(int(row["input_order"]) == contract.input_order, "E_FORMULA_ARITY", "input order mismatch")
            require(row["input_role"] == contract.input_role, "E_FORMULA_VALUE", "input role mismatch")
            input_fact_id = row["input_fact_id"]
            require(input_fact_id in facts, "E_FORMULA_VALUE", "input fact is missing")
            input_fact = facts[input_fact_id]
            field_id = input_fact["field_id"]
            unit = input_fact["normalized_unit"]
            number = input_fact["normalized_value_number"]
            require(field_id in contract.allowed_field_ids, "E_FORMULA_VALUE", "input field is not allowed")
            options = {option.unit: option for option in contract.unit_options}
            require(unit in options, "E_FORMULA_VALUE", "input unit is not allowed")
            value = _decimal(number)
            if contract.required_decimal is not None:
                require(value == _decimal(contract.required_decimal), "E_FORMULA_VALUE", "required decimal mismatch")
            scaled_values.append(value * _decimal(options[unit].scale_to_base_decimal))
            input_projections.append(
                FormulaInputProjection(
                    input_order=contract.input_order,
                    input_role=contract.input_role,
                    input_field_id=field_id,
                    input_normalized_unit=unit,
                    input_normalized_value=number,
                )
            )
        if spec.output_value_kind == "text":
            require(spec.operation == "emit_constant_text", "E_FORMULA_OUTPUT_DESCRIPTOR", "text operation mismatch")
            require(spec.constant_text is not None and spec.constant_decimal is None, "E_FORMULA_OUTPUT_DESCRIPTOR", "text constant descriptor mismatch")
            require(spec.decimal_places is None and spec.rounding_mode == "none", "E_FORMULA_OUTPUT_DESCRIPTOR", "text rounding descriptor mismatch")
            require(output_field["value_kind"] == "enum" and output_field["value_enum_name"], "E_FORMULA_OUTPUT_DESCRIPTOR", "text output field must be enum")
            enum_token = "enum:" + output_field["value_enum_name"]
            require(spec.output_unit == enum_token and metric["output_unit"] == enum_token, "E_FORMULA_OUTPUT_DESCRIPTOR", "enum output token mismatch")
            require(output_fact["normalized_unit"] == "", "E_FORMULA_FACT_UNIT", "enum fact unit must be empty")
            require(output_fact["normalized_value_number"] == "", "E_FORMULA_VALUE", "enum fact number must be empty")
            require(output_fact["normalized_value_text"] == spec.constant_text, "E_FORMULA_VALUE", "enum constant differs")
            output_kind = "text"
        else:
            require(spec.output_value_kind == "number", "E_FORMULA_OUTPUT_DESCRIPTOR", "unknown output value kind")
            require(metric["output_unit"] == spec.output_unit, "E_FORMULA_OUTPUT_DESCRIPTOR", "metric output unit mismatch")
            require(output_fact["normalized_unit"] == spec.output_unit, "E_FORMULA_FACT_UNIT", "numeric fact unit mismatch")
            if output_field["canonical_unit"]:
                require(output_field["canonical_unit"] == spec.output_unit, "E_FORMULA_OUTPUT_DESCRIPTOR", "field canonical unit mismatch")
            require(output_fact["normalized_value_text"] == "", "E_FORMULA_VALUE", "numeric output text must be empty")
            calculated = _evaluate_numeric(spec, scaled_values)
            expected_text = _format_decimal(calculated, spec.decimal_places)
            require(output_fact["normalized_value_number"] == expected_text, "E_FORMULA_VALUE", "derived value mismatch", {"fact_id": derived_fact_id, "expected": expected_text, "actual": output_fact["normalized_value_number"]})
            output_kind = "number"
        projections.append(
            FormulaUseProjection(
                formula_id=formula_id,
                derived_metric_id=metric["derived_metric_id"],
                derived_fact_id=derived_fact_id,
                output_field_id=output_field_id,
                output_fact_value_kind=output_kind,
                output_fact_normalized_unit=output_fact["normalized_unit"],
                metric_output_unit=metric["output_unit"],
                arity=spec.arity,
                inputs=tuple(input_projections),
            )
        )
    distribution = Counter(item.formula_id for item in projections)
    require(
        distribution
        == Counter(
            {
                "FORMULA-COMPUTE-DIV-MEMBW": 7,
                "FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW": 4,
                "FORMULA-AWS-TRN2-CORE-X8": 11,
                "FORMULA-MATRIX-DIV-VECTOR": 1,
                "FORMULA-STRUCTURAL-PROJECTION": 1,
            }
        ),
        "E_REQUIRED_SET",
        "current formula-use distribution drifted",
    )
    require(
        sum(len(item.inputs) for item in projections) == 47,
        "E_REQUIRED_SET",
        "formula-use projection did not consume all 47 inputs",
    )
    return tuple(projections)

