"""Collect actual manifest dependencies and close them against full v7 DAGs."""

from dataclasses import dataclass
from typing import Any, Dict, List, Mapping, Sequence, Set, Tuple

from .errors import ContractV7Error, require


DEPENDENCY_FIELDS: Tuple[Tuple[str, str], ...] = (
    ("raw_dependencies", "raw"),
    ("canonical_dependencies", "canonical"),
    ("hash_reference_dependencies", "hash_reference"),
    ("source_dependencies", "source"),
    ("approval_dependencies", "approval"),
    ("patch_dependencies", "patch"),
    ("manifest_set_dependencies", "manifest_set"),
    ("semantic_byte_dependencies", "semantic_byte"),
)
ALLOWED_ARTIFACT_KEYS = {"artifact_id", "level", *(field for field, _ in DEPENDENCY_FIELDS)}

CONTRACT_EXPECTED_EDGES: frozenset = frozenset((
    ("C0", "C1"), ("C1", "C2"), ("C2", "C3"), ("C3", "C4"),
    ("C4", "C5"), ("C4", "C6"), ("C5", "C6"), ("C4", "C7"),
    ("C5", "C7"), ("C6", "C7"), ("C7", "C8"), ("C8", "C9"),
    ("C9", "C10"), ("C3", "C11"), ("C10", "C11"), ("C10", "C12"),
    ("C11", "C12"), ("C12", "C13"), ("C13", "C14"), ("C12", "C15"),
    ("C14", "C15"), ("C15", "C16"), ("C16", "C17"),
))

CHIP_EXPECTED_EDGES: frozenset = frozenset((
    ("H0", "H1"), ("H1", "H2"), ("H1", "H3"), ("H2", "H3"),
    ("H3", "H4"), ("H4", "H5"), ("H5", "H6"), ("H1", "H7"),
    ("H6", "H7"), ("H7", "H8"), ("H7", "H9"), ("H8", "H9"),
    ("H1", "H10"), ("H2", "H10"), ("H6", "H10"), ("H7", "H10"),
    ("H8", "H10"), ("H9", "H10"), ("H0", "H10"), ("H0", "H11"),
    ("H10", "H11"), ("H4", "H12"), ("H5", "H12"), ("H6", "H12"),
    ("H7", "H12"), ("H8", "H12"), ("H9", "H12"), ("H10", "H12"),
    ("H11", "H12"), ("H10", "H13"), ("H12", "H13"), ("H13", "H14"),
    ("H11", "H15"), ("H13", "H15"), ("H14", "H15"), ("H15", "H16"),
    ("H15", "H17"), ("H16", "H17"), ("H0", "H18"), ("H17", "H18"),
    ("H17", "H19"), ("H18", "H19"), ("H17", "H20"), ("H19", "H20"),
    ("H20", "H21"), ("H17", "H22"), ("H19", "H22"), ("H21", "H22"),
    ("H22", "H23"), ("H22", "H24"), ("H23", "H24"),
))


@dataclass(frozen=True)
class CollectedEdge:
    parent: str
    child: str
    dependency_kind: str
    manifest_field: str


@dataclass(frozen=True)
class DagResult:
    graph_kind: str
    node_count: int
    edge_count: int
    minimum_level: int
    maximum_level: int


def collect_manifest_edges(document: Mapping[str, Any]) -> Tuple[Dict[str, int], Tuple[CollectedEdge, ...]]:
    require(set(document.keys()) == {"graph_contract_version", "graph_kind", "artifacts"}, "E_DAG_MANIFEST", "artifact DAG manifest top-level keys differ")
    require(document["graph_contract_version"] == "V7-ARTIFACT-DAG-V1", "E_DAG_MANIFEST", "artifact DAG manifest version differs")
    artifacts = document["artifacts"]
    require(isinstance(artifacts, list) and artifacts, "E_DAG_MANIFEST", "artifacts must be a non-empty array")
    levels: Dict[str, int] = {}
    edges: List[CollectedEdge] = []
    pair_seen = set()
    for artifact in artifacts:
        require(isinstance(artifact, Mapping), "E_DAG_MANIFEST", "artifact entry is not an object")
        unknown = set(artifact) - ALLOWED_ARTIFACT_KEYS
        require(not unknown, "E_DAG_MANIFEST", "artifact contains an unknown dependency field", {"unknown": sorted(unknown)})
        require("artifact_id" in artifact and "level" in artifact, "E_DAG_MANIFEST", "artifact ID/level is absent")
        artifact_id, level = artifact["artifact_id"], artifact["level"]
        require(isinstance(artifact_id, str) and artifact_id and artifact_id not in levels, "E_HASH_LEVEL", "artifact ID is empty or duplicated")
        require(isinstance(level, int) and not isinstance(level, bool) and level >= 0, "E_HASH_LEVEL", "artifact level is not a nonnegative integer")
        levels[artifact_id] = level
        for field, kind in DEPENDENCY_FIELDS:
            parents = artifact.get(field, [])
            require(isinstance(parents, list) and all(isinstance(parent, str) and parent for parent in parents), "E_DAG_MANIFEST", "%s must be an array of artifact IDs" % field)
            require(len(parents) == len(set(parents)), "E_DAG_MANIFEST", "%s contains a duplicate parent" % field)
            for parent in parents:
                pair = (parent, artifact_id)
                require(pair not in pair_seen, "E_DAG_MANIFEST", "one dependency edge is reported through multiple fields", {"parent": parent, "child": artifact_id})
                pair_seen.add(pair)
                edges.append(CollectedEdge(parent, artifact_id, kind, field))
    return levels, tuple(edges)


def _detect_cycle(node_ids: Set[str], edges: Sequence[CollectedEdge]) -> None:
    children: Dict[str, List[str]] = {node_id: [] for node_id in node_ids}
    for edge in edges:
        children[edge.parent].append(edge.child)
    state = {node_id: 0 for node_id in node_ids}

    def visit(node_id: str) -> None:
        if state[node_id] == 1:
            raise ContractV7Error("E_HASH_CYCLE", "artifact dependency graph contains a cycle", {"node_id": node_id})
        if state[node_id] == 2:
            return
        state[node_id] = 1
        for child in children[node_id]:
            visit(child)
        state[node_id] = 2

    for node_id in sorted(node_ids, key=lambda value: value.encode("utf-8")):
        visit(node_id)


def validate_manifest_dag(document: Mapping[str, Any], graph_kind: str) -> DagResult:
    require(graph_kind in ("contract", "chip") and document.get("graph_kind") == graph_kind, "E_DAG_MANIFEST", "graph kind differs")
    levels, edges = collect_manifest_edges(document)
    expected_nodes = {"C%d" % value for value in range(18)} if graph_kind == "contract" else {"H%d" % value for value in range(25)}
    require(set(levels) == expected_nodes, "E_DAG_NODE_SET", "artifact node set is not complete", {"missing": sorted(expected_nodes - set(levels)), "extra": sorted(set(levels) - expected_nodes)})
    for edge in edges:
        require(edge.parent in levels and edge.child in levels, "E_HASH_LEVEL", "dependency endpoint is undeclared")
    _detect_cycle(set(levels), edges)
    for edge in edges:
        require(levels[edge.parent] < levels[edge.child], "E_HASH_LEVEL", "dependency does not strictly rise in level", {"parent": edge.parent, "child": edge.child, "parent_level": levels[edge.parent], "child_level": levels[edge.child], "field": edge.manifest_field})
    actual = {(edge.parent, edge.child) for edge in edges}
    expected = CONTRACT_EXPECTED_EDGES if graph_kind == "contract" else CHIP_EXPECTED_EDGES
    require(actual == expected, "E_DAG_EDGE_SET", "actual dependency edges are not bidirectionally set-equal to v7", {"missing": sorted(expected - actual), "extra": sorted(actual - expected)})
    expected_count = 23 if graph_kind == "contract" else 51
    require(len(edges) == expected_count, "E_DAG_EDGE_SET", "R15 edge recomputation count differs")
    return DagResult(graph_kind, len(levels), len(edges), min(levels.values()), max(levels.values()))

