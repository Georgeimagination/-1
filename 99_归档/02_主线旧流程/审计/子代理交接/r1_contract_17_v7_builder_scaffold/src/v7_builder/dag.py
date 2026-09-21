"""Explicit dependency-edge validation for the contract and chip hash DAGs."""

from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Sequence, Set, Tuple

from .errors import ContractV7Error, require


@dataclass(frozen=True)
class DagNode:
    node_id: str
    level: int


@dataclass(frozen=True)
class DagEdge:
    parent: str
    child: str
    edge_kind: str


@dataclass(frozen=True)
class DagValidation:
    node_count: int
    edge_count: int
    minimum_level: int
    maximum_level: int


def _detect_cycle(node_ids: Set[str], edges: Sequence[DagEdge]) -> None:
    children: Dict[str, List[str]] = {node_id: [] for node_id in node_ids}
    for edge in edges:
        children[edge.parent].append(edge.child)
    state: Dict[str, int] = {node_id: 0 for node_id in node_ids}

    def visit(node_id: str) -> None:
        if state[node_id] == 1:
            raise ContractV7Error("E_HASH_CYCLE", "dependency graph contains a cycle", {"node_id": node_id})
        if state[node_id] == 2:
            return
        state[node_id] = 1
        for child in children[node_id]:
            visit(child)
        state[node_id] = 2

    for node_id in sorted(node_ids, key=lambda value: value.encode("utf-8")):
        visit(node_id)


def validate_explicit_dag(
    nodes: Sequence[DagNode],
    edges: Sequence[DagEdge],
) -> DagValidation:
    """Require every actual explicit/semantic edge to rise to a higher level."""

    node_by_id: Dict[str, DagNode] = {}
    for node in nodes:
        require(node.node_id and isinstance(node.level, int), "E_HASH_LEVEL", "DAG node is invalid")
        require(node.node_id not in node_by_id, "E_HASH_LEVEL", "DAG node ID is duplicated")
        node_by_id[node.node_id] = node
    require(node_by_id, "E_HASH_LEVEL", "DAG must contain at least one node")
    edge_keys = [(edge.parent, edge.child, edge.edge_kind) for edge in edges]
    require(len(edge_keys) == len(set(edge_keys)), "E_HASH_LEVEL", "DAG edge is duplicated")
    for edge in edges:
        require(edge.edge_kind in ("hash_reference", "semantic"), "E_HASH_LEVEL", "edge kind is invalid")
        require(
            edge.parent in node_by_id and edge.child in node_by_id,
            "E_HASH_LEVEL",
            "DAG edge endpoint is undeclared",
            {"parent": edge.parent, "child": edge.child},
        )
    _detect_cycle(set(node_by_id), edges)
    for edge in edges:
        parent_level = node_by_id[edge.parent].level
        child_level = node_by_id[edge.child].level
        require(
            parent_level < child_level,
            "E_HASH_LEVEL",
            "dependency edge does not strictly increase level",
            {
                "parent": edge.parent,
                "parent_level": parent_level,
                "child": edge.child,
                "child_level": child_level,
                "edge_kind": edge.edge_kind,
            },
        )
    levels = [node.level for node in nodes]
    return DagValidation(len(nodes), len(edges), min(levels), max(levels))


def dag_from_fixture(document: Mapping[str, object]) -> Tuple[Tuple[DagNode, ...], Tuple[DagEdge, ...]]:
    raw_nodes = document.get("nodes")
    raw_edges = document.get("edges")
    require(isinstance(raw_nodes, list) and isinstance(raw_edges, list), "E_JSON_TYPE", "DAG fixture needs arrays")
    nodes: List[DagNode] = []
    for item in raw_nodes:
        require(isinstance(item, dict) and set(item) == {"node_id", "level"}, "E_JSON_KEY", "invalid DAG node keys")
        nodes.append(DagNode(str(item["node_id"]), item["level"]))
    edges: List[DagEdge] = []
    for item in raw_edges:
        require(
            isinstance(item, dict) and set(item) == {"parent", "child", "edge_kind"},
            "E_JSON_KEY",
            "invalid DAG edge keys",
        )
        edges.append(DagEdge(str(item["parent"]), str(item["child"]), str(item["edge_kind"])))
    return tuple(nodes), tuple(edges)

