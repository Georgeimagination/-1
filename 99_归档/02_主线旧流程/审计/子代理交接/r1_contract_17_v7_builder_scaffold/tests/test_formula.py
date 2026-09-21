import csv
import shutil
import tempfile
import unittest
from collections import Counter
from pathlib import Path

from v7_builder.errors import ContractV7Error
from v7_builder.formula import build_formula_use_projections, formula_registry_v7

from .support import DATA_DIR


class FormulaTests(unittest.TestCase):
    def test_current_24_47_projection_and_registry(self):
        projection = build_formula_use_projections(DATA_DIR)
        self.assertEqual(len(projection), 24)
        self.assertEqual(sum(len(item.inputs) for item in projection), 47)
        self.assertEqual(len(formula_registry_v7()), 8)
        self.assertEqual(
            Counter(item.formula_id for item in projection),
            Counter(
                {
                    "FORMULA-COMPUTE-DIV-MEMBW": 7,
                    "FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW": 4,
                    "FORMULA-AWS-TRN2-CORE-X8": 11,
                    "FORMULA-MATRIX-DIV-VECTOR": 1,
                    "FORMULA-STRUCTURAL-PROJECTION": 1,
                }
            ),
        )

    def test_structural_enum_has_distinct_metric_and_fact_unit_rules(self):
        projection = build_formula_use_projections(DATA_DIR)
        structural = next(item for item in projection if item.formula_id == "FORMULA-STRUCTURAL-PROJECTION")
        self.assertEqual(structural.output_fact_value_kind, "text")
        self.assertEqual(structural.output_fact_normalized_unit, "")
        self.assertEqual(structural.metric_output_unit, "enum:pooling_mode")
        self.assertEqual(structural.output_field_id, "FIELD-MEM-POOLING-MODE")
        self.assertEqual(structural.inputs[0].input_normalized_value, "262144")

    def test_structural_fact_enum_unit_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            for filename in ("derived-metrics.csv", "derived-inputs.csv", "facts.csv", "fields.csv"):
                shutil.copyfile(DATA_DIR / filename, temporary / filename)
            facts_path = temporary / "facts.csv"
            with facts_path.open("r", encoding="utf-8-sig", newline="") as handle:
                reader = csv.DictReader(handle)
                fieldnames = reader.fieldnames
                rows = list(reader)
            for row in rows:
                if row["fact_id"] == "FACT-NVIDIA-H100-REG-POOLING-MODE":
                    row["normalized_unit"] = "enum:pooling_mode"
            with facts_path.open("w", encoding="utf-8", newline="") as handle:
                writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
                writer.writeheader()
                writer.writerows(rows)
            with self.assertRaises(ContractV7Error) as captured:
                build_formula_use_projections(temporary)
        self.assertEqual(captured.exception.code, "E_FORMULA_FACT_UNIT")


if __name__ == "__main__":
    unittest.main()

