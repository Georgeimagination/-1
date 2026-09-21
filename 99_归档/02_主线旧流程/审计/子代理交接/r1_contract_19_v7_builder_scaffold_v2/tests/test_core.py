import copy
import json
import os
import tempfile
import unittest
import unicodedata
from collections import OrderedDict
from pathlib import Path

from v7_builder_v2.canonical import (
    SEMANTIC_PATH_ORACLES,
    canonical_csv_rowset,
    canonical_hash_for,
    canonical_json_bytes,
    frame,
    framed_sha256,
    parse_csv_bytes,
    parse_strict_json_bytes,
    row_envelope,
    verify_semantic_path_oracles,
)
from v7_builder_v2.dag import (
    CHIP_EXPECTED_EDGES,
    CONTRACT_EXPECTED_EDGES,
    collect_manifest_edges,
    validate_manifest_dag,
)
from v7_builder_v2.errors import ContractV7Error, structured_call
from v7_builder_v2.pathing import resolve_contained, validate_logical_path, validate_path_set
from v7_builder_v2.principals import validate_independent_principals, validate_principal_id

from .support import FIXTURE_ROOT, MAINLINE_ROOT, error_code


class CanonicalTests(unittest.TestCase):
    def test_strict_json_canonical(self):
        raw = b'{"a":1,"b":"\\u000a","c":null}'
        value = parse_strict_json_bytes(raw)
        self.assertEqual(canonical_json_bytes(value), raw)

    def test_strict_json_key_order_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            parse_strict_json_bytes(b'{"b":1, "a":2}')
        self.assertEqual(error_code(caught), "E_JSON_ORDER")

    def test_duplicate_json_key_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            parse_strict_json_bytes(b'{"a":1,"a":2}')
        self.assertEqual(error_code(caught), "E_JSON_KEY")

    def test_float_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            parse_strict_json_bytes(b'{"a":1.5}')
        self.assertEqual(error_code(caught), "E_JSON_NUMBER")

    def test_invalid_utf8_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            parse_strict_json_bytes(b'{"a":"\xff"}')
        self.assertEqual(error_code(caught), "E_UTF8")

    def test_domain_framing_length(self):
        self.assertEqual(frame("row-v1", b"abc"), b"row-v1\x00" + (3).to_bytes(8, "big") + b"abc")

    def test_domain_changes_hash(self):
        self.assertNotEqual(framed_sha256("row-v1", b"[]"), framed_sha256("rowset-v1", b"[]"))

    def test_csv_semantic_path_changes_hash(self):
        header, cells = ("field_id", "value"), ("FIELD-X", "1")
        one = framed_sha256("rowset-v1", canonical_json_bytes([row_envelope("数据/fields.csv", header, cells, ("field_id",))]))
        two = framed_sha256("rowset-v1", canonical_json_bytes([row_envelope("审计/事务/TX-TEST/inputs/base/数据/fields.csv", header, cells, ("field_id",))]))
        self.assertNotEqual(one, two)

    def test_csv_duplicate_primary_key_rejected(self):
        raw = b"field_id,value\nFIELD-X,1\nFIELD-X,2\n"
        with self.assertRaises(ContractV7Error) as caught:
            canonical_csv_rowset(raw, "数据/fields.csv")
        self.assertEqual(error_code(caught), "E_DUPLICATE")

    def test_csv_bad_width_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            parse_csv_bytes(b"a,b\n1\n")
        self.assertEqual(error_code(caught), "E_CSV_HEADER")

    def test_raw_only_has_no_canonical_hash(self):
        self.assertIsNone(canonical_hash_for(b"opaque", "README.md", None))

    def test_three_semantic_path_oracles(self):
        observed = verify_semantic_path_oracles(MAINLINE_ROOT / "数据/fields.csv")
        self.assertEqual(observed, SEMANTIC_PATH_ORACLES)


class PathTests(unittest.TestCase):
    def test_valid_chinese_posix_path(self):
        identity = validate_logical_path("数据/fields.csv")
        self.assertEqual(identity.windows_physical_alias, "数据/fields.csv")

    def test_drive_relative_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            validate_logical_path("C:relative.txt")
        self.assertEqual(error_code(caught), "E_PATH_WINDOWS")

    def test_drive_absolute_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("C:/absolute.txt")

    def test_ads_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("data/file.txt:stream")

    def test_unc_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("//server/share")

    def test_reserved_name_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            validate_logical_path("data/CON.txt")
        self.assertEqual(error_code(caught), "E_PATH_WINDOWS")

    def test_trailing_dot_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("data/name.")

    def test_trailing_space_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("data/name ")

    def test_parent_segment_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_logical_path("data/../outside")

    def test_nfc_rejected(self):
        decomposed = "data/" + unicodedata.normalize("NFD", "é") + ".txt"
        with self.assertRaises(ContractV7Error) as caught:
            validate_logical_path(decomposed)
        self.assertEqual(error_code(caught), "E_PATH_NFC")

    def test_casefold_collision_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            validate_path_set(("Data/File.csv", "data/file.csv"))
        self.assertEqual(error_code(caught), "E_PATH_COLLISION")

    def test_symlink_escape_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as root_text, tempfile.TemporaryDirectory(dir="/private/tmp") as outside_text:
            root, outside = Path(root_text), Path(outside_text)
            (outside / "target.txt").write_text("x", encoding="utf-8")
            os.symlink(str(outside), str(root / "escape"))
            with self.assertRaises(ContractV7Error) as caught:
                resolve_contained(root, "escape/target.txt", True)
            self.assertEqual(error_code(caught), "E_PATH_ESCAPE")


class PrincipalTests(unittest.TestCase):
    def test_three_independent_principals(self):
        observed = validate_independent_principals({"prepared_by": "principal:prep", "reviewed_by": "principal:review", "approved_by": "principal:approve"})
        self.assertEqual(len(observed), 3)

    def test_trim_collision_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            validate_principal_id(" principal:a", "prepared_by")
        self.assertEqual(error_code(caught), "E_PRINCIPAL_ID")

    def test_internal_whitespace_rejected(self):
        with self.assertRaises(ContractV7Error):
            validate_principal_id("principal:two words", "reviewed_by")

    def test_casefold_collision_rejected(self):
        with self.assertRaises(ContractV7Error) as caught:
            validate_independent_principals({"prepared_by": "Principal:A", "reviewed_by": "principal:a", "approved_by": "principal:b"})
        self.assertEqual(error_code(caught), "E_PRINCIPAL_COLLISION")

    def test_nfc_principal_rejected(self):
        value = "principal:" + unicodedata.normalize("NFD", "é")
        with self.assertRaises(ContractV7Error):
            validate_principal_id(value, "approved_by")


class DagTests(unittest.TestCase):
    def _load(self, name):
        return json.loads((FIXTURE_ROOT / name).read_text(encoding="utf-8"))

    def test_contract_full_23_edges(self):
        result = validate_manifest_dag(self._load("contract-artifact-dag.json"), "contract")
        self.assertEqual((result.node_count, result.edge_count), (18, 23))
        self.assertEqual(len(CONTRACT_EXPECTED_EDGES), 23)

    def test_chip_full_51_edges(self):
        result = validate_manifest_dag(self._load("chip-artifact-dag.json"), "chip")
        self.assertEqual((result.node_count, result.edge_count), (25, 51))
        self.assertEqual(len(CHIP_EXPECTED_EDGES), 51)

    def test_all_dependency_field_families_collected(self):
        _, edges = collect_manifest_edges(self._load("chip-artifact-dag.json"))
        self.assertEqual({edge.dependency_kind for edge in edges}, {"raw", "canonical", "hash_reference", "source", "approval", "patch", "manifest_set", "semantic_byte"})

    def test_missing_edge_rejected(self):
        document = self._load("contract-artifact-dag.json")
        document["artifacts"][1]["raw_dependencies"] = []
        with self.assertRaises(ContractV7Error) as caught:
            validate_manifest_dag(document, "contract")
        self.assertEqual(error_code(caught), "E_DAG_EDGE_SET")

    def test_extra_edge_rejected(self):
        document = self._load("contract-artifact-dag.json")
        document["artifacts"][2]["raw_dependencies"] = ["C0"]
        with self.assertRaises(ContractV7Error) as caught:
            validate_manifest_dag(document, "contract")
        self.assertEqual(error_code(caught), "E_DAG_EDGE_SET")

    def test_same_level_edge_rejected(self):
        document = self._load("contract-artifact-dag.json")
        document["artifacts"][6]["level"] = 5
        with self.assertRaises(ContractV7Error) as caught:
            validate_manifest_dag(document, "contract")
        self.assertEqual(error_code(caught), "E_HASH_LEVEL")

    def test_cycle_rejected(self):
        document = self._load("contract-artifact-dag.json")
        document["artifacts"][0]["raw_dependencies"] = ["C17"]
        with self.assertRaises(ContractV7Error) as caught:
            validate_manifest_dag(document, "contract")
        self.assertEqual(error_code(caught), "E_HASH_CYCLE")

    def test_unknown_dependency_field_rejected(self):
        document = self._load("contract-artifact-dag.json")
        document["artifacts"][1]["invented_dependencies"] = ["C0"]
        with self.assertRaises(ContractV7Error) as caught:
            validate_manifest_dag(document, "contract")
        self.assertEqual(error_code(caught), "E_DAG_MANIFEST")


class ExternalBoundaryTests(unittest.TestCase):
    def test_structured_value_error(self):
        result = structured_call("parse integer", lambda: int("not-an-int"))
        self.assertEqual(result["error_code"], "E_VALUE_PARSE")
        self.assertFalse(result["writes_performed"])

    def test_structured_missing_file(self):
        result = structured_call("read", lambda: Path("/private/tmp/r19-does-not-exist").read_bytes())
        self.assertEqual(result["error_code"], "E_IO_NOT_FOUND")
        self.assertFalse(result["writes_performed"])


if __name__ == "__main__":
    unittest.main()
