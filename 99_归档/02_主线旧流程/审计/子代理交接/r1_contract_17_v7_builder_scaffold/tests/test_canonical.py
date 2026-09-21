import json
import unittest
from collections import OrderedDict

from v7_builder.canonical import (
    SEMANTIC_PATH_EXPECTED,
    frame,
    framed_sha256,
    parse_strict_json_bytes,
    strict_json_bytes,
    validate_fields_semantic_path_oracles,
)
from v7_builder.errors import ContractV7Error

from .support import DATA_DIR, SCAFFOLD_ROOT


class CanonicalTests(unittest.TestCase):
    def assert_code(self, code, callback):
        with self.assertRaises(ContractV7Error) as captured:
            callback()
        self.assertEqual(captured.exception.code, code)

    def test_control_characters_use_lowercase_unicode_escape(self):
        value = OrderedDict((("control", "\n\t\x00"), ("unicode", "芯片")))
        self.assertEqual(
            strict_json_bytes(value),
            b'{"control":"\\u000a\\u0009\\u0000","unicode":"\xe8\x8a\xaf\xe7\x89\x87"}',
        )

    def test_float_duplicate_and_noncanonical_bytes_fail_closed(self):
        self.assert_code("E_JSON_NUMBER", lambda: strict_json_bytes({"value": 1.5}))
        self.assert_code("E_JSON_KEY", lambda: parse_strict_json_bytes(b'{"x":1,"x":2}'))
        self.assert_code("E_JSON_ORDER", lambda: parse_strict_json_bytes(b'{"x": 1}'))
        self.assert_code("E_JSON_ORDER", lambda: parse_strict_json_bytes(b'{"x":"\\n"}'))

    def test_domain_framing_uses_nul_and_uint64_big_endian(self):
        payload = b"abc"
        self.assertEqual(frame("row-v1", payload), b"row-v1\x00\x00\x00\x00\x00\x00\x00\x00\x03abc")
        self.assertEqual(
            framed_sha256("row-v1", payload),
            "82ef5c4b39008f71fb39e786e689e588fad4f3151662c452a74b416090cac2bd",
        )
        self.assert_code("E_HASH_FRAME", lambda: frame("row\x00v1", payload))
        self.assert_code("E_HASH_FRAME", lambda: frame("ROW-V1", payload))

    def test_three_semantic_path_row_and_rowset_oracles(self):
        observed = validate_fields_semantic_path_oracles(DATA_DIR / "fields.csv")
        self.assertEqual(tuple(observed), SEMANTIC_PATH_EXPECTED)
        self.assertEqual([item.envelope_payload_bytes for item in observed], [859, 893, 893])
        self.assertEqual([item.singleton_payload_bytes for item in observed], [861, 895, 895])
        self.assertTrue(all(item.row_v1_sha256 != item.rowset_v1_sha256 for item in observed))

    def test_oracle_fixture_matches_code_constants(self):
        fixture = json.loads((SCAFFOLD_ROOT / "fixtures/semantic-path-oracles.json").read_text(encoding="utf-8"))
        projected = [
            {
                "semantic_path": item.semantic_path,
                "envelope_payload_bytes": item.envelope_payload_bytes,
                "singleton_payload_bytes": item.singleton_payload_bytes,
                "row_v1_sha256": item.row_v1_sha256,
                "rowset_v1_sha256": item.rowset_v1_sha256,
            }
            for item in SEMANTIC_PATH_EXPECTED
        ]
        for fixture_item, expected in zip(fixture["oracles"], projected):
            self.assertEqual({key: fixture_item[key] for key in expected}, expected)


if __name__ == "__main__":
    unittest.main()
