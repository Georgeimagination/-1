import json
import unittest

from v7_builder.dag import DagEdge, DagNode, dag_from_fixture, validate_explicit_dag
from v7_builder.errors import ContractV7Error

from .support import SCAFFOLD_ROOT


class DagTests(unittest.TestCase):
    def assert_code(self, code, callback):
        with self.assertRaises(ContractV7Error) as captured:
            callback()
        self.assertEqual(captured.exception.code, code)

    def test_contract_and_chip_critical_edges_strictly_rise(self):
        expected = {
            "contract-dag-critical.json": (22, 24, 0, 17),
            "chip-dag-critical.json": (25, 35, 0, 24),
        }
        for filename, oracle in expected.items():
            with self.subTest(filename=filename):
                document = json.loads((SCAFFOLD_ROOT / "fixtures" / filename).read_text(encoding="utf-8"))
                nodes, edges = dag_from_fixture(document)
                result = validate_explicit_dag(nodes, edges)
                self.assertEqual(
                    (result.node_count, result.edge_count, result.minimum_level, result.maximum_level),
                    oracle,
                )

    def test_same_level_dependency_fails(self):
        nodes = (DagNode("candidate", 4), DagNode("patch", 4))
        edges = (DagEdge("candidate", "patch", "hash_reference"),)
        self.assert_code("E_HASH_LEVEL", lambda: validate_explicit_dag(nodes, edges))

    def test_cycle_fails_before_level_claim_can_hide_it(self):
        nodes = (DagNode("a", 0), DagNode("b", 1))
        edges = (
            DagEdge("a", "b", "semantic"),
            DagEdge("b", "a", "hash_reference"),
        )
        self.assert_code("E_HASH_CYCLE", lambda: validate_explicit_dag(nodes, edges))


if __name__ == "__main__":
    unittest.main()

