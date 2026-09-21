# S07 来源版本与固定入口裁决

`SRC-AWS-TRN2-S07` 是 AWS EC2 Trn2 产品页。2026-08-12 与 2026-08-13 两份 HTML 都是 487,377 bytes；原始 SHA-256 分别为：

- 2026-08-12：`4c315ad5c342d10e1e0a6a8a5ab59b87be94e9fc19911f6ac122964317aa32cf`
- 2026-08-13：`94ceea74234b30d6568127badd6a4df68a46b861d1d989c21463fea3b0690edb`

逐行比较只有两处一次性随机值（nonce）变化。按同一规则归一化后，两份全文的 SHA-256 都是 `3070baef5d94db45396bd210d4f16f1bf8f8aa1b2586d1215530f82e2acf473e`，产品正文没有变化。

因此本包不新建 source version：`source_id=SRC-AWS-TRN2-S07`、`version_label=observed-2026-08-12` 和现有 `content_fingerprint` 均保持不变，只把 `last_verified_date` 更新为 2026-08-13，并在 notes 中保留两份原始哈希和归一化等价结果。

旧入口 `END-AWS-TRN2-S07-SNAPSHOT` 继续保留，`is_preferred_endpoint=false`。新入口 `END-AWS-TRN2-S07-SNAPSHOT-20260813` 指向：

`最小参考资料库/快照/AWS/Trainium2/2026-08-13/S07_ec2_trn2_product_2026-08-13.html`

复制候选位于 `fixed-candidates/S07_ec2_trn2_product_2026-08-13.html`，实测 487,377 bytes，SHA-256 为 `94ceea74234b30d6568127badd6a4df68a46b861d1d989c21463fea3b0690edb`。`file-copy-plan.csv` 给出正式目标和哈希；正式 endpoint 不依赖 staging 路径。