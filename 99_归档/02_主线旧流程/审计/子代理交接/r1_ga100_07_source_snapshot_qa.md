# GA100 来源快照文件级 QA

状态：`pass`。逐文件内容、字节数、SHA-256、格式、来源身份和两个固定集合 manifest 均通过；没有资料缺失或下载失败。  
日期：2026-08-21  
范围：`NVIDIA GA100 die` 的 RAS、CUDA、PTX 与 MIG staged downloads。此 QA 只新增本报告，未改动正式 CSV、来源快照、资料卡、进度或总控文件。

## 裁决

盘点到 19 个文件，共 13,015,382 bytes，组成 4 个 PDF、6 份 R595 RAS HTML、8 份 MIG HTML 与 1 份 MIG JSON。预期清单恰为这一组文件，没有零字节文件、同 SHA-256 内容重复、未登记文件、截断 PDF 或错误 HTML/JSON。每个文件的 SHA-256 都与 `r1_ga100_06_source_registration_plan.md`、`r1_ga100_06_mig_official_docs_reading.md` 或 `r1_ga100_06_source_registration_candidates.csv` 中的逐文件指纹相符。

MIG 的八页 HTML 均与精读报告列出的 2026-08-21 原始 HTML 指纹相同；`versions1.json` 的 SHA-256 为 `367b813259e27664930dbdd1a3b95334256cd65ac0f6ebc0381ffa0756757c7e`，可解析为单个记录，`name=610`、`version=610`、`preferred=true`。因此版本选择器的 `610` 身份通过。MIG bundle 字节数为 270,937，与当前来源登记计划相符。

此前的 `needs_fix` 已关闭。总控新增了两个固定 manifest：R595 文件为 `manifests/ras-r595-manifest.tsv`，SHA-256 为 `40a8e5b6617b2f70c85947e1134d60f3766d705509f9344bc77d797767053d4c`；MIG 文件为 `manifests/mig-user-guide-610-manifest.tsv`，SHA-256 为 `db5c3ac2017d7e40d4f4fa9e82e484166e3a7ee64f1ddd904a7c6b4b696fc91b`。两文件均为 UTF-8 的无表头 TSV，每行是 `relative_path<TAB>payload_sha256<LF>`，按 C locale 排序，末字节均为 LF。独立重算确认 R595 6 行和 MIG 9 行均格式正确、排序正确、逐行 payload SHA-256 相符，且相应 RAS 或 MIG 分组内没有遗漏或额外文件。旧报告中未能复算的 MIG `b9d382...` 只是旧的未固定集合值，已由可审计的固定 manifest 取代，不再构成 provenance 缺口。

## 完整文件清单

下表的 SHA-256 可由 `shasum -a 256 <path>` 直接复算。PDF signature 为 `%PDF-1.4`，HTML signature 为开头的 `<!DOCTYPE`，JSON signature 为 `[`。所有 HTML 均有预期 `title`、`article` 与目标 section；错误页关键字检查没有发现 `404`、`Access Denied`、`Not Found` 或 Cloudflare 错误页。`getting-started-with-mig.html` 中的 `40448MiB` 是文档示例的显存容量，人工查看上下文后确认不是 HTTP 404。

| 相对 downloads 路径 | bytes | SHA-256 | MIME / signature | 身份与内容裁决 |
|---|---:|---|---|---|
| `cuda-c-programming-guide-11.0.pdf` | 4,252,150 | `af4235e08e4ebb0f7651896db7ed05344f5e4ae6e9ce5da3cba3bc5ec6c69174` | `application/pdf` / `%PDF-1.4` | PDF 405 页，未加密；*CUDA C++ Programming Guide*，`PG-02829-001_v11.0`，August 2020。通过。 |
| `nvidia-gpu-mem-error-mgmt-DA-09826-002_v001.pdf` | 352,370 | `5d484fe6ce3b577cfbdd378ebf6b3cf3eb18cedc0ec99ec557832bad424306d4` | `application/pdf` / `%PDF-1.4` | PDF 16 页，未加密；*NVIDIA GPU Memory Error Management*，`DA-09826-002_v001`，June 2023。通过。 |
| `ptx-isa-7.0.pdf` | 4,107,461 | `a79f4e074eb8f03314025c690ec51fbb79231e35bde612a60d50f4f8ec31f924` | `application/pdf` / `%PDF-1.4` | PDF 414 页，未加密；*Parallel Thread Execution ISA*，v7.0，August 2020。通过。 |
| `ptx-isa-7.2.pdf` | 3,931,305 | `9a89c6817d1fd0d3b6357aaf71fbf3c29d08d9c4e12b5eaa6c851297b7d18b97` | `application/pdf` / `%PDF-1.4` | PDF 433 页，未加密；*Parallel Thread Execution ISA*，v7.2，February 2021。通过。 |
| `ras-r595-contained-uce-response.html` | 17,041 | `cab5cfc6c98e76b24e5320cb0d323e7e103b97776a04e442ae8eeaf622bc9704` | `text/html` / `<!DOCTYPE` | *Response to Uncorrectable Contained ECC Errors*, NVIDIA GPU Memory Error Management；目标 section 存在。通过。 |
| `ras-r595-dynamic-page-offlining.html` | 16,144 | `39e16e20f234e40f666a4d79a8acc2bd28eae06a8fc577cbe523c06bcff2d4e3` | `text/html` / `<!DOCTYPE` | *Dynamic Page Offlining*, NVIDIA GPU Memory Error Management；目标 section 存在。通过。 |
| `ras-r595-error-containment.html` | 16,326 | `d50618920ae48febbf894af8aa4455d6af541e794a8068996ca6d44980bbfbd5` | `text/html` / `<!DOCTYPE` | *Error Containment*, NVIDIA GPU Memory Error Management；目标 section 存在。通过。 |
| `ras-r595-gpu-memory-repair.html` | 17,169 | `9a44db8d6ab692c7fd1833e05cc42ee45a8012d75c3479a4d8917955cef03389` | `text/html` / `<!DOCTYPE` | *RAS Repair*, NVIDIA GPU Memory Error Management；为 GA100 排除边界，不是正向 repair 证据。通过。 |
| `ras-r595-row-remapping.html` | 17,904 | `7473e17f6c97e8d9d616faf72efdf41cc142e47216a7d5278fa8651b93fbd7f6` | `text/html` / `<!DOCTYPE` | *Row Remapping*, NVIDIA GPU Memory Error Management；目标 section 存在。通过。 |
| `ras-r595-supported-gpus.html` | 16,575 | `4813fafec19b1508358bc0aedfcbd212e0f4695770a39fa0b3b75f1e8fc7c44f` | `text/html` / `<!DOCTYPE` | *Supported GPUs*, NVIDIA GPU Memory Error Management；目标 section 存在。通过。 |
| `mig-user-guide-610/concepts.html` | 33,203 | `4413498cd49a04ef015dc0fd5bc96ac2c909dc35302b7a3625505ce30e4e9057` | `text/html` / `<!DOCTYPE` | *Concepts*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/deployment-considerations.html` | 21,560 | `fd8e343f987aada7902d700a083f8b3e0682ee483153d45ddf0de70431219870` | `text/html` / `<!DOCTYPE` | *Deployment Considerations*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/getting-started-with-mig.html` | 91,548 | `c7b6645eaa02601739adc78470e0963a02422f64ae46e2b1c470fac0cd95c9d2` | `text/html` / `<!DOCTYPE` | *Getting Started with MIG*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/introduction.html` | 18,232 | `970cf62e3a98556a48a8298401a45a3b12e22c072676bc8b587186cb87e9f3e0` | `text/html` / `<!DOCTYPE` | *Introduction*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/supported-configurations.html` | 15,605 | `6842dbd29461b60e346cfabe269e00adce7c9ea1c1088491d1fcdfa9d86b7624` | `text/html` / `<!DOCTYPE` | *Supported Configurations*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/supported-gpus.html` | 20,324 | `dbb01db2b63712d275812034d115b58deda6d45d01ec2a50617d92b663a3550f` | `text/html` / `<!DOCTYPE` | *Supported GPUs*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/supported-mig-profiles.html` | 54,090 | `9db72a775752aca20c2f0974945d902752df1cbccb619d191815548cc62dea6f` | `text/html` / `<!DOCTYPE` | *Supported MIG Profiles*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |
| `mig-user-guide-610/versions1.json` | 146 | `367b813259e27664930dbdd1a3b95334256cd65ac0f6ebc0381ffa0756757c7e` | `application/json` / `[` | 有效 JSON，唯一 preferred 记录为 version 610。通过。 |
| `mig-user-guide-610/virtualization.html` | 16,229 | `9918d361afd314aa5833e9d79ea98679133204970274ecaa6a25b5658e750bb9` | `text/html` / `<!DOCTYPE` | *Virtualization*, NVIDIA Multi-Instance GPU User Guide；目标 section 存在。通过。 |

## 核验方法与边界

PDF 使用文件签名、`pdfinfo` 的 title、author、cover version/date、页数及未加密状态复核。`pdfinfo` 对四份 PDF 都成功返回页数与元数据，足以排除 HTML 错页被误存为 PDF。运行环境没有 `qpdf`，因此没有额外执行 `qpdf --check`；这是工具缺失造成的验证能力边界，不是 PDF 校验失败，也不影响上述可读元数据和页数裁决。

R595 的 6 个 HTML 逐项与来源登记计划第 62 至 68 行的字节数和 SHA-256 相同。CUDA、PTX 及 June 2023 RAS PDF 逐项与第 76 至 78 行和候选 CSV 一致。MIG 的 8 页逐项与 MIG 精读报告第 23 至 30 行相同，JSON 同时与候选 CSV 的 `CAND-GA100-MIG-610-VERSION-METADATA` 一致。R595、CUDA、PTX 与 MIG 都没有发现额外 staged 文件，所以未出现来源身份不一致或未登记 payload。

历史访问事件已区分但不计为证据缺口。RAS 精读阶段的命令行 NVIDIA 请求曾因 sandbox DNS 限制被拒绝，报告中已说明后续通过网页读取工具取得正文；本次 staging 中的文件已经可读、已固定并逐文件核验。一次错误 URL 的 404 随后已被正确 URL 下载所替代。两者都是已解决的访问过程，不代表当前本地来源缺失或内容失效。

集合 provenance 的修复已完成，不需要重下这 19 个已通过的文件。R595 六页和 MIG 九个文件仍各自属于一个来源版本的 endpoint 集合，不能据此拆成多个独立来源家族。

## 工具与操作记录

本 QA 没有外部下载、没有审批请求、没有 sandbox denial、没有远程服务错误。两次本地只读命令曾因操作者构造错误而未执行目标检查：一次 `sed` 地址缺少 `p`，一次 shell 引号不配对；两次都属于模型或操作错误，未写入任何文件，随后以正确的只读命令完成复核。PDF 结构检查中 `qpdf` 不在运行环境，属于工具或运行时缺失，已由 `pdfinfo`、文件签名和文本首页读取替代。HTML 的初步错误页扫描命中 `40448MiB` 后，经人工上下文复读判定为正文示例数据，不是错误页。

## 自然化复读

机器扫描已对本文件执行。人工逆向复读覆盖标题、首段、表格引导、集合 hash 说明和结尾。报告保留必要的哈希、路径和受控状态，未发现模板化开场、无依据的收束或把已解决访问事件写成来源缺口。此前集合 manifest 的生成方法未记录，现已由固定 TSV 合同关闭；没有剩余文件级 QA 问题。
