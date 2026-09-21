import tempfile
import unittest
from pathlib import Path

from v7_builder_v2.canonical import raw_sha256
from v7_builder_v2.errors import ContractV7Error
from v7_builder_v2.guard import atomic_guarded_snapshot
from v7_builder_v2.preflight import (
    DigestBinding,
    ReadyReport,
    _READY_SEAL,
    _binding_set_digest,
    inspect_live_prerequisites,
    require_live_prerequisites,
    revalidate_ready_report,
)

from .support import MAINLINE_ROOT, error_code


class LiveNegativeGateTests(unittest.TestCase):
    transaction_id = "TX-R19-LIVE-PREFLIGHT"

    def test_live_preflight_is_expected_blocked(self):
        report = inspect_live_prerequisites(MAINLINE_ROOT, self.transaction_id)
        self.assertEqual((report.status, report.error_code, report.snapshot_candidate_creation_authorized), ("BLOCKED", "E_UPSTREAM_PREREQUISITE", False))

    def test_validator_hash_is_first_check(self):
        report = inspect_live_prerequisites(MAINLINE_ROOT, self.transaction_id)
        self.assertEqual(report.checks[0].check_id, "formal_post_113_validator_hash")
        self.assertNotEqual(report.checks[0].status, "satisfied")

    def test_controlled_directory_is_not_satisfied(self):
        report = inspect_live_prerequisites(MAINLINE_ROOT, self.transaction_id)
        check = next(item for item in report.checks if item.check_id == "controlled_input_directory")
        self.assertNotEqual(check.status, "satisfied")

    def test_live_gate_creates_no_transaction_or_candidate(self):
        transaction = MAINLINE_ROOT / "审计/事务" / self.transaction_id
        self.assertFalse(transaction.exists())
        before = {path.name for path in MAINLINE_ROOT.glob("*candidate*")}
        inspect_live_prerequisites(MAINLINE_ROOT, self.transaction_id)
        after = {path.name for path in MAINLINE_ROOT.glob("*candidate*")}
        self.assertFalse(transaction.exists())
        self.assertEqual(before, after)

    def test_require_live_raises_upstream_code(self):
        with self.assertRaises(ContractV7Error) as caught:
            require_live_prerequisites(MAINLINE_ROOT, self.transaction_id)
        self.assertEqual(error_code(caught), "E_UPSTREAM_PREREQUISITE")

    def test_nonexistent_root_has_stable_code_and_no_write(self):
        root = Path("/private/tmp/r19-root-does-not-exist")
        report = inspect_live_prerequisites(root, self.transaction_id)
        self.assertEqual((report.status, report.error_code), ("BLOCKED", "E_ROOT_NOT_FOUND"))
        self.assertFalse(root.exists())


class AtomicGuardTests(unittest.TestCase):
    def _ready(self, root: Path, logical: str = "precondition.bin") -> ReadyReport:
        raw = (root / logical).read_bytes()
        binding = DigestBinding("test_precondition", "file", logical, raw_sha256(raw))
        return ReadyReport("READY", None, True, str(root.resolve()), _binding_set_digest((binding,)), (binding,), (), _READY_SEAL)

    def test_exclusive_atomic_snapshot(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            (root / "precondition.bin").write_bytes(b"stable")
            report = self._ready(root)
            destination = root / "audit-snapshot.bin"
            result = atomic_guarded_snapshot(report, root, destination, b"snapshot")
            self.assertEqual(result.read_bytes(), b"snapshot")
            self.assertEqual(list(root.glob(".audit-snapshot.bin.tmp.*")), [])

    def test_drift_before_first_write_leaves_zero_snapshot(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            precondition = root / "precondition.bin"
            precondition.write_bytes(b"stable")
            report = self._ready(root)
            precondition.write_bytes(b"drift")
            destination = root / "audit-snapshot.bin"
            with self.assertRaises(ContractV7Error) as caught:
                atomic_guarded_snapshot(report, root, destination, b"snapshot")
            self.assertEqual(error_code(caught), "E_PRECONDITION_DRIFT")
            self.assertFalse(destination.exists())
            self.assertEqual(list(root.glob(".audit-snapshot.bin.tmp.*")), [])

    def test_ready_is_revalidated_each_use(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            precondition = root / "precondition.bin"
            precondition.write_bytes(b"stable")
            report = self._ready(root)
            revalidate_ready_report(report, root)
            precondition.write_bytes(b"changed-after-first-check")
            with self.assertRaises(ContractV7Error) as caught:
                revalidate_ready_report(report, root)
            self.assertEqual(error_code(caught), "E_PRECONDITION_DRIFT")

    def test_forged_unsealed_ready_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            (root / "precondition.bin").write_bytes(b"stable")
            valid = self._ready(root)
            forged = ReadyReport(valid.status, valid.error_code, valid.snapshot_candidate_creation_authorized, valid.root_resolved, valid.precondition_digest, valid.bindings, valid.checks)
            destination = root / "forged.bin"
            with self.assertRaises(ContractV7Error) as caught:
                atomic_guarded_snapshot(forged, root, destination, b"forged")
            self.assertEqual(error_code(caught), "E_UPSTREAM_PREREQUISITE")
            self.assertFalse(destination.exists())

    def test_existing_destination_rejected(self):
        with tempfile.TemporaryDirectory(dir="/private/tmp") as temp_text:
            root = Path(temp_text)
            (root / "precondition.bin").write_bytes(b"stable")
            destination = root / "existing.bin"
            destination.write_bytes(b"old")
            with self.assertRaises(ContractV7Error) as caught:
                atomic_guarded_snapshot(self._ready(root), root, destination, b"new")
            self.assertEqual(error_code(caught), "E_OUTPUT_EXISTS")
            self.assertEqual(destination.read_bytes(), b"old")


if __name__ == "__main__":
    unittest.main()

