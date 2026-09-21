import unittest

from v7_builder.authorization import validate_authorization_identity
from v7_builder.errors import ContractV7Error


def identity_documents():
    authorization = {
        "transaction_id": "TX-TEST-0001",
        "work_package_id": "WP-TEST-0001",
        "scope_id": "SCOPE-0001",
        "card_object_id": "OBJ-NVIDIA-GA100-DIE",
    }
    transaction = {"transaction_id": "TX-TEST-0001", "transaction_kind": "chip_work_package"}
    coverage = {
        "work_package_id": "WP-TEST-0001",
        "scope_id": "SCOPE-0001",
        "card_object_id": "OBJ-NVIDIA-GA100-DIE",
        "coverage_contract_version": "TEST-VIEW",
    }
    return authorization, transaction, coverage


class AuthorizationIdentityTests(unittest.TestCase):
    def assert_code(self, code, callback):
        with self.assertRaises(ContractV7Error) as captured:
            callback()
        self.assertEqual(captured.exception.code, code)

    def test_only_two_frozen_identity_equalities_are_applied(self):
        authorization, transaction, coverage = identity_documents()
        validate_authorization_identity(authorization, transaction, coverage)

    def test_transaction_and_coverage_drift_are_rejected(self):
        authorization, transaction, coverage = identity_documents()
        transaction["transaction_id"] = "TX-TEST-0002"
        self.assert_code(
            "E_AUTHORIZATION_IDENTITY_BINDING",
            lambda: validate_authorization_identity(authorization, transaction, coverage),
        )
        authorization, transaction, coverage = identity_documents()
        coverage["scope_id"] = "SCOPE-0002"
        self.assert_code(
            "E_AUTHORIZATION_IDENTITY_BINDING",
            lambda: validate_authorization_identity(authorization, transaction, coverage),
        )

    def test_cross_manifest_schema_expansion_is_rejected(self):
        authorization, transaction, coverage = identity_documents()
        coverage["transaction_id"] = authorization["transaction_id"]
        self.assert_code("E_JSON_KEY", lambda: validate_authorization_identity(authorization, transaction, coverage))
        authorization, transaction, coverage = identity_documents()
        transaction["work_package_id"] = authorization["work_package_id"]
        self.assert_code("E_JSON_KEY", lambda: validate_authorization_identity(authorization, transaction, coverage))


if __name__ == "__main__":
    unittest.main()

