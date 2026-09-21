import unittest
from dataclasses import replace

from v7_builder.bootstrap import (
    EXPECTED_UNCHANGED_PATHS,
    BootstrapItem,
    validate_bootstrap_membership,
)
from v7_builder.errors import ContractV7Error


def item(role, source, logical, ordinal, canonical=True):
    return BootstrapItem(
        input_role=role,
        source_path=source,
        logical_target_path=logical,
        preimage_state="present",
        raw_sha256="%064x" % ordinal,
        canonical_domain_tag="rowset-v1" if canonical else None,
        canonical_sha256="%064x" % (ordinal + 1000) if canonical else None,
    )


def valid_membership():
    unchanged = [
        item("managed_unchanged_snapshot", "T/inputs/unchanged/" + path, path, index)
        for index, path in enumerate(EXPECTED_UNCHANGED_PATHS, start=1)
    ]
    base_only = [
        item(
            "managed_base_snapshot",
            "T/inputs/base/table-%02d.%s" % (index, "csv" if index < 9 else "md"),
            "table-%02d.%s" % (index, "csv" if index < 9 else "md"),
            100 + index,
            canonical=index < 9,
        )
        for index in range(20)
    ]
    prerequisite = [
        item("source_pool_prerequisite_manifest", "T/inputs/prerequisites/source-pool-113-prerequisite.json", "T/inputs/prerequisites/source-pool-113-prerequisite.json", 200),
        item("source_pool_prerequisite_approval", "T/inputs/prerequisites/source-pool-113-prerequisite-approval.json", "T/inputs/prerequisites/source-pool-113-prerequisite-approval.json", 201),
    ]
    changed_post = [
        item(
            "managed_postimage_snapshot",
            "T/inputs/post/table-%02d.%s" % (index, "csv" if index < 11 else "md"),
            "post-table-%02d.%s" % (index, "csv" if index < 11 else "md"),
            300 + index,
            canonical=index < 11,
        )
        for index in range(22)
    ]
    candidates = [
        item("stable_candidate_%02d" % index, "T/inputs/bootstrap/targets/artifact-%02d.json" % index, "审计/合同注册表/artifact-%02d.json" % index, 400 + index)
        for index in range(13)
    ]
    patches = [
        item("managed_patch", "T/inputs/patches/patch-%02d.json" % index, "T/inputs/patches/patch-%02d.json" % index, 500 + index)
        for index in range(12)
    ]
    fixed = (
        ("contract_design", "审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md"),
        ("scope_freeze_archive", "审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv"),
        ("bootstrap_bundle_manifest", "T/inputs/bootstrap/bootstrap-bundle-manifest.json"),
        ("bootstrap_bundle_approval", "T/inputs/bootstrap/bootstrap-bundle-approval.json"),
    )
    sort_key = lambda value: (
        value.input_role.encode("utf-8"),
        value.source_path.encode("utf-8"),
        value.logical_target_path.encode("utf-8"),
    )
    return (
        sorted(unchanged + base_only + prerequisite, key=sort_key),
        sorted(unchanged + changed_post + candidates, key=sort_key),
        sorted(patches, key=sort_key),
        fixed,
    )


class BootstrapTests(unittest.TestCase):
    def assert_code(self, code, callback):
        with self.assertRaises(ContractV7Error) as captured:
            callback()
        self.assertEqual(captured.exception.code, code)

    def test_45_58_12_intersection_92_projection_96_inputs(self):
        base, post, patch, fixed = valid_membership()
        result = validate_bootstrap_membership(base, post, patch, fixed)
        self.assertEqual(
            (
                result.base_count,
                result.post_count,
                result.patch_count,
                result.unchanged_intersection_count,
                result.unique_identity_count,
                result.contract_file_input_count,
            ),
            (45, 58, 12, 23, 92, 96),
        )

    def test_duplicate_identity_inside_array_is_rejected(self):
        base, post, patch, fixed = valid_membership()
        base[1] = base[0]
        base.sort(key=lambda value: (value.input_role.encode("utf-8"), value.source_path.encode("utf-8"), value.logical_target_path.encode("utf-8")))
        self.assert_code(
            "E_BOOTSTRAP_ITEM_IDENTITY",
            lambda: validate_bootstrap_membership(base, post, patch, fixed),
        )

    def test_unchanged_intersection_of_22_is_rejected(self):
        base, post, patch, fixed = valid_membership()
        unchanged_index = next(index for index, value in enumerate(post) if value.input_role == "managed_unchanged_snapshot")
        post[unchanged_index] = replace(post[unchanged_index], raw_sha256="f" * 64, canonical_sha256="e" * 64)
        self.assert_code(
            "E_BOOTSTRAP_PHASE_INTERSECTION",
            lambda: validate_bootstrap_membership(base, post, patch, fixed),
        )

    def test_role_source_projection_collision_is_rejected(self):
        base, post, patch, fixed = valid_membership()
        candidate_index = next(index for index, value in enumerate(post) if value.input_role.startswith("stable_candidate_"))
        base_item = next(value for value in base if value.input_role == "managed_base_snapshot")
        post[candidate_index] = replace(
            post[candidate_index],
            input_role=base_item.input_role,
            source_path=base_item.source_path,
        )
        post.sort(key=lambda value: (value.input_role.encode("utf-8"), value.source_path.encode("utf-8"), value.logical_target_path.encode("utf-8")))
        self.assert_code(
            "E_FILE_INPUT_PROJECTION",
            lambda: validate_bootstrap_membership(base, post, patch, fixed),
        )


if __name__ == "__main__":
    unittest.main()
