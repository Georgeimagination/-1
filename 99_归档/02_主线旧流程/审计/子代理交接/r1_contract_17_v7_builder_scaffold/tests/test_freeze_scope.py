import tempfile
import unittest
from collections import Counter
from pathlib import Path

from v7_builder.errors import ContractV7Error
from v7_builder.freeze_scope import (
    ACTIVE_SCOPE_RELATIVE_PATH,
    FREEZE_RELATIVE_PATH,
    build_initial_mapping_projections,
    construct_49_scopes,
    parse_active_scope_markdown,
    parse_raw_freeze_archive,
)

from .support import DATA_DIR, MAINLINE_ROOT


class FreezeScopeTests(unittest.TestCase):
    def setUp(self):
        self.freeze_path = MAINLINE_ROOT / FREEZE_RELATIVE_PATH
        self.active_path = MAINLINE_ROOT / ACTIVE_SCOPE_RELATIVE_PATH

    def test_raw_archive_and_49_scope_constructor(self):
        freeze = parse_raw_freeze_archive(self.freeze_path)
        active = parse_active_scope_markdown(self.active_path)
        scopes = construct_49_scopes(freeze, active)
        self.assertEqual((freeze.byte_length, freeze.crlf_count, freeze.lf_only_count, freeze.bare_cr_count), (55224, 64, 14, 0))
        self.assertEqual(len(scopes), 49)
        self.assertEqual([scope.scope_id for scope in scopes], ["SCOPE-%04d" % value for value in range(1, 50)])
        self.assertEqual((scopes[0].freeze_row_id, scopes[0].scope_id), ("FREEZE-NV-001", "SCOPE-0001"))
        self.assertTrue(all(len(scope.active_list_row_canonical_sha256) == 64 for scope in scopes))

    def test_raw_hash_is_checked_before_parse(self):
        raw = self.freeze_path.read_bytes()
        with tempfile.TemporaryDirectory() as directory:
            changed = Path(directory) / "freeze.csv"
            changed.write_bytes(raw[:-1] + bytes((raw[-1] ^ 1,)))
            with self.assertRaises(ContractV7Error) as captured:
                parse_raw_freeze_archive(changed)
        self.assertEqual(captured.exception.code, "E_FREEZE_ARCHIVE_RAW_DRIFT")

    def test_initial_mapping_projection_is_9_1_1_38(self):
        freeze = parse_raw_freeze_archive(self.freeze_path)
        scopes = construct_49_scopes(freeze, parse_active_scope_markdown(self.active_path))
        mapping = build_initial_mapping_projections(
            scopes,
            DATA_DIR / "objects.csv",
            DATA_DIR / "card-completeness.csv",
        )
        self.assertEqual(
            Counter(item.mapping_status for item in mapping),
            Counter({"mapped": 9, "pending_identity_review": 1, "pending_formal_object_create": 1, "unmapped": 38}),
        )
        ga100 = next(item for item in mapping if item.freeze_row_id == "FREEZE-NV-001")
        self.assertEqual(
            (ga100.scope_id, ga100.mapping_event_seq, ga100.proposed_formal_object_id, ga100.mapping_status),
            ("SCOPE-0001", 1, "OBJ-NVIDIA-GA100-DIE", "pending_formal_object_create"),
        )


if __name__ == "__main__":
    unittest.main()

