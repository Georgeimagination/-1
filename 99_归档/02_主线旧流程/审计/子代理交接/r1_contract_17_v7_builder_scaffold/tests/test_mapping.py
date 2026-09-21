import unittest

from v7_builder.errors import ContractV7Error
from v7_builder.mapping import (
    MAPPING_BASE_SNAPSHOT_PAIR,
    MAPPING_POST_SNAPSHOT_PAIR,
    MAPPING_STABLE_PAIR,
    MappingEvent,
    choose_chip_mapping_branch,
    validate_branch_input_pairs,
)


def common_base_34():
    return tuple(("common_role_%02d" % index, "stable/common-%02d" % index) for index in range(34))


def event(seq, status, approval, formal="", proposed="OBJ-NVIDIA-GA100-DIE"):
    return MappingEvent(
        freeze_row_id="FREEZE-NV-001",
        scope_id="SCOPE-0001",
        mapping_event_seq=seq,
        formal_object_id=formal,
        proposed_formal_object_id=proposed,
        mapping_status=status,
        approval_status=approval,
    )


class MappingTests(unittest.TestCase):
    def assert_code(self, code, callback):
        with self.assertRaises(ContractV7Error) as captured:
            callback()
        self.assertEqual(captured.exception.code, code)

    def test_ga100_pending_tip_selects_38_override(self):
        branch = choose_chip_mapping_branch(
            [event(1, "pending_formal_object_create", "needs_resolution")],
            "SCOPE-0001",
            "OBJ-NVIDIA-GA100-DIE",
            common_base_34(),
        )
        self.assertEqual((branch.name, branch.required_input_count, branch.next_event_seq), ("MAPPING_OVERRIDE", 38, 2))
        self.assertIn(MAPPING_BASE_SNAPSHOT_PAIR, branch.required_pairs)
        self.assertIn(MAPPING_POST_SNAPSHOT_PAIR, branch.required_pairs)
        self.assertNotIn(MAPPING_STABLE_PAIR, branch.required_pairs)
        self.assertTrue(branch.requires_independent_mapping_authorization)

    def test_mapped_same_card_selects_37_no_change(self):
        branch = choose_chip_mapping_branch(
            [event(1, "mapped", "approved", formal="OBJ-NVIDIA-GA100-DIE", proposed="")],
            "SCOPE-0001",
            "OBJ-NVIDIA-GA100-DIE",
            common_base_34(),
        )
        self.assertEqual((branch.name, branch.required_input_count, branch.next_event_seq), ("NO_MAPPING_CHANGE", 37, None))
        self.assertIn(MAPPING_STABLE_PAIR, branch.required_pairs)
        self.assertNotIn(MAPPING_BASE_SNAPSHOT_PAIR, branch.required_pairs)

    def test_mapped_other_card_and_gapped_history_fail_closed(self):
        self.assert_code(
            "E_SCOPE_MAPPING_TRANSITION",
            lambda: choose_chip_mapping_branch(
                [event(1, "mapped", "approved", formal="OBJ-OTHER", proposed="")],
                "SCOPE-0001",
                "OBJ-NVIDIA-GA100-DIE",
                common_base_34(),
            ),
        )
        self.assert_code(
            "E_SCOPE_MAPPING_LIFECYCLE",
            lambda: choose_chip_mapping_branch(
                [
                    event(1, "pending_formal_object_create", "needs_resolution"),
                    event(3, "pending_formal_object_create", "rejected"),
                ],
                "SCOPE-0001",
                "OBJ-NVIDIA-GA100-DIE",
                common_base_34(),
            ),
        )

    def test_rejected_sequence_is_occupied_and_actual_set_is_exact(self):
        branch = choose_chip_mapping_branch(
            [
                event(1, "pending_formal_object_create", "needs_resolution"),
                event(2, "retired", "rejected", proposed=""),
            ],
            "SCOPE-0001",
            "OBJ-NVIDIA-GA100-DIE",
            common_base_34(),
        )
        self.assertEqual(branch.next_event_seq, 3)
        validate_branch_input_pairs(branch, reversed(branch.required_pairs))
        self.assert_code(
            "E_REQUIRED_SET",
            lambda: validate_branch_input_pairs(branch, branch.required_pairs[:-1]),
        )


if __name__ == "__main__":
    unittest.main()

