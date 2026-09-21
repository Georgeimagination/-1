import json
import hashlib
import unittest

from .support import SCAFFOLD_ROOT


class ArtifactTests(unittest.TestCase):
    def test_all_schemas_and_fixtures_are_valid_json_objects(self):
        paths = sorted((SCAFFOLD_ROOT / "schemas").glob("*.json")) + sorted(
            (SCAFFOLD_ROOT / "fixtures").glob("*.json")
        )
        self.assertEqual(len(paths), 7)
        for path in paths:
            with self.subTest(path=path.name):
                document = json.loads(path.read_text(encoding="utf-8"))
                self.assertIsInstance(document, dict)

    def test_fixtures_contain_no_reviewer_date_or_approval_artifact(self):
        forbidden_keys = {
            "approved_by",
            "approved_date",
            "approval_id",
            "prepared_by",
            "prepared_date",
            "reviewed_by",
            "reviewed_date",
            "transcript_raw_sha256",
        }

        def walk(value):
            if isinstance(value, dict):
                self.assertFalse(forbidden_keys.intersection(value))
                for child in value.values():
                    walk(child)
            elif isinstance(value, list):
                for child in value:
                    walk(child)

        for path in sorted((SCAFFOLD_ROOT / "fixtures").glob("*.json")):
            with self.subTest(path=path.name):
                walk(json.loads(path.read_text(encoding="utf-8")))

    def test_validation_report_binds_every_other_scaffold_file(self):
        report_path = SCAFFOLD_ROOT / "validation-report.json"
        report = json.loads(report_path.read_text(encoding="utf-8"))
        recorded = dict(report["artifact_hashes"])
        recorded_set_hash = recorded.pop("@content-set-excluding-validation-report")
        actual = {
            path.relative_to(SCAFFOLD_ROOT).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in SCAFFOLD_ROOT.rglob("*")
            if path.is_file() and path != report_path
        }
        self.assertEqual(recorded, actual)
        inventory = "".join(
            actual[path] + "  " + path + "\n"
            for path in sorted(actual, key=lambda value: value.encode("utf-8"))
        ).encode("utf-8")
        self.assertEqual(recorded_set_hash, hashlib.sha256(inventory).hexdigest())
        self.assertEqual(report["unit_tests"]["status"], "PASS")
        self.assertEqual(report["live_prerequisite_preflight"]["status"], "BLOCKED")


if __name__ == "__main__":
    unittest.main()
