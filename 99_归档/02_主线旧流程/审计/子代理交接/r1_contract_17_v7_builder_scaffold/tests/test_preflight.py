import tempfile
import unittest
from pathlib import Path

from v7_builder.errors import UpstreamPrerequisiteError
from v7_builder.guard import initialize_audit_workspace
from v7_builder.preflight import inspect_live_prerequisites, require_live_prerequisites

from .support import MAINLINE_ROOT, SCAFFOLD_ROOT


class LivePreflightTests(unittest.TestCase):
    def test_current_live_state_is_blocked_with_expected_error(self):
        report = inspect_live_prerequisites(MAINLINE_ROOT)
        self.assertEqual(report.status, "BLOCKED")
        self.assertEqual(report.error_code, "E_UPSTREAM_PREREQUISITE")
        self.assertFalse(report.snapshot_candidate_creation_authorized)
        by_id = {check.check_id: check for check in report.checks}
        self.assertEqual(by_id["formal_post_113_validator_hash"].status, "mismatch")
        self.assertEqual(by_id["controlled_input_directory"].status, "missing")
        self.assertEqual(by_id["promotion_record_raw"].status, "missing")
        self.assertEqual(by_id["independent_prerequisite_manifest"].status, "missing")
        self.assertEqual(by_id["independent_prerequisite_approval"].status, "missing")
        for gate_id in ("source_pool", "chip_scope", "research_data_subject_contract"):
            self.assertEqual(by_id["windows_transcript:" + gate_id].status, "not_checkable")

    def test_fail_closed_exception_is_upstream_prerequisite(self):
        with self.assertRaises(UpstreamPrerequisiteError) as captured:
            require_live_prerequisites(MAINLINE_ROOT)
        self.assertEqual(captured.exception.code, "E_UPSTREAM_PREREQUISITE")
        self.assertIn("formal_post_113_validator_hash", captured.exception.context["failed_checks"])

    def test_blocked_gate_creates_no_workspace_snapshot_or_candidate(self):
        output = SCAFFOLD_ROOT / "_unit_test_blocked_workspace_should_not_exist"
        self.assertFalse(output.exists())
        with self.assertRaises(UpstreamPrerequisiteError):
            initialize_audit_workspace(MAINLINE_ROOT, output)
        self.assertFalse(output.exists())
        self.assertFalse((output / "snapshot").exists())
        self.assertFalse((output / "candidate").exists())


if __name__ == "__main__":
    unittest.main()
