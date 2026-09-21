# 113 份资料池候选复算、v3 重放与 v4 操作合同记录

状态：`v4_operations_contract_candidate_ready_windows_gate_pending`

本记录的写入范围是 `审计/子代理交接/r1_source_pool_113_staging/` 和临时测试根 `/private/tmp/source_pool_113_*`。正式主线没有被本任务写入。最后一次直接哈希确认，正式 `清单/论文PDF清单.csv`、`清单/汇总统计.json`、`清单/网页与在线资料.csv`、`清单/待补论文清单.csv` 仍分别为 `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27`、`eee940c5b1fdaa871fe0f2ea734216136471db28a68f43ff10cfdc2602b41db7`、`f19991c731fcdca8e0dee65601a2637a5568bc1fde46b357757d19292aa1395f`、`b5a5993c0a29364c5be3c2d6d35321e3150b5599913e3fafe887bff3a02307bd`。正式 `scripts/collect_references.py` 与 `scripts/validation/Test-SourcePool.ps1` 仍分别为 `4946da30c5fd9540f51298fd5aac839d9573c96cba78ac2b3309096a21a7b06f` 与 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`；三张正式来源表也仍是 ledger 创建时记录的整表观察哈希。

## 输入模型与正式落点

正式稳定输入位于下列两个目标，staging 根目录只供审阅。`formal_payload/` 中保存它们的逐字节镜像，正式推广必须先复制 frozen CSV，再复制 ledger；ledger 只以同目录的相对路径 `frozen-legacy-pdf-manifest.csv` 寻找 baseline。

| 正式目标 | SHA-256 | 复算合同 |
|---|---|---|
| `清单/资料池受控输入/frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` | 111 行、112 次 `源文件` 出现、111 个唯一 SHA-256、1 个重复、313,921,821 字节、2,210 页。 |
| `清单/资料池受控输入/source-pool-input-ledger.json` | `08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812` | 只允许生成两份 PDF/summary 输出，固定两条 M2 supplement 和 112/101 的历史 inventory 快照。 |

这个模型不把 113 行候选输出当成唯一输入，因此不存在用目标反向生成目标的循环。旧 111 行从 hash-bound frozen manifest 重放；两条 supplement 从 fixed candidate、正式本地 PDF 和来源账本的交叉验证重放。历史扫描目录当前只剩 103 份 PDF、102 个唯一内容，`.tmp/paper_inventory_final.json` 为 111 条记录、100 条 downloaded，二者都不参与生成。

来源表的整表哈希仅记录 ledger 创建时的观察值。运行时读取 `sources.csv`、`source-endpoints.csv` 与 `selection-members.csv`，但仅按 ID 校验两条 AMD 所需记录的必要字段：source 的题名、组织、类型、版本、authority、fingerprint 和 review；local/remote endpoint 的路径或 URL、SHA-256、页数、MIME、优选状态、可访问性与 review；selection member 的 source、角色和 review。这样既不会漏掉这两条资料的来源断言，也不会因无关 GA100 行的合法追加而把重放锁死。

| 资料 | source / local endpoint / remote endpoint | SHA-256、字节、页数 | 类别 |
|---|---|---|---|
| AMD Instinct™ MI455X GPU | `SRC-M2W3-AMD-MI455X-BROCHURE-202607` / `END-M2W3-AMD-MI455X-BROCHURE-LOCAL` / `END-M2W3-AMD-MI455X-BROCHURE-REMOTE` | `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208`，659,374，2 | `AMD Instinct / 厂商产品资料` |
| AMD Instinct™ MI350P PCIe® Card | `SRC-M2W3-AMD-MI350P-BROCHURE-202605` / `END-M2W3-AMD-MI350P-BROCHURE-LOCAL` / `END-M2W3-AMD-MI350P-BROCHURE-REMOTE` | `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29`，782,486，2 | `AMD Instinct / 厂商产品资料` |

## 113 行候选复算

候选 manifest 的 16 列表头与正式 CSV 合同一致。机器逐行读取 113 行，对每个 `汇总后文件` 检查它位于正式 `论文/`、文件存在、字节数与 SHA-256 匹配，并用 `pdfinfo` 核验页数。路径集合等于磁盘 113 份 PDF；113 个 manifest SHA-256 没有空值或重复。候选输出哈希固定为 manifest `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` 和 summary `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e`。

| 指标 | 候选值 | 从 manifest 复算 |
|---|---:|---:|
| 行数、磁盘 PDF 数 | 113 | 113、113 |
| `源文件` 出现次数 | 114 | 114 |
| 唯一 SHA-256 | 113 | 113 |
| `duplicates_removed` | 1 | 114 - 113 = 1 |
| 总字节、总页数 | 315,363,681、2,214 | 315,363,681、2,214 |
| AMD Instinct 平台数 | 6 | 6 |
| AMD Instinct / 官方白皮书与技术资料 | 4 | 4 |
| AMD Instinct / 厂商产品资料 | 2 | 2 |
| `paper_inventory_records`、`paper_inventory_downloaded` | 112、101 | ledger 冻结快照，不从 M2 brochure 或可变 `.tmp` 重算。 |

所有平台计数和所有类别计数分别合计 113。网页和待补清单仍保持最小边界：914 行网页、893 个区分大小写 URL、892 个忽略大小写 URL、11 条待补资料；本修复不生成或写入它们。

这里有两层不同的约束。collector 的 ledger 将网页和待补文件的哈希当作创建时审计观察，不把它们作为运行前置条件；它的 write scope 也没有这两张表。候选 `Test-SourcePool.ps1` 则继续把两张表的当前 SHA-256 和 914/893/892/11 计数作为这次资料池 baseline 的 Windows hard gate。未来若扩充网页或待补清单，应通过一次显式 baseline 升级修改 validator；不能借本次 PDF 修复静默改变它们。相反，三张会随逐芯片工作正常追加的正式 registry 表没有整表 runtime hash，临时 mirror 的无关 GA100 source row 已证明这一点。

## 可重放、幂等和隔离测试

临时 formal mirror 安装了 staging 的 `formal_payload/清单/资料池受控输入/` 和 collector 副本，PDF 仅以硬链接提供验证路径，没有复制或改写 113 个 PDF。mirror 初始 manifest/summary 使用正式 legacy 哈希。下面是已执行的关键命令；`cmp` 均返回 0。

```sh
python3 /private/tmp/source_pool_113_formal_mirror_v3/scripts/collect_references.py \
  --mainline-root /private/tmp/source_pool_113_formal_mirror_v3 \
  --output-root /private/tmp/source_pool_113_mirror_preview_legacy_v3
cmp /private/tmp/source_pool_113_mirror_preview_legacy_v3/清单/论文PDF清单.csv \
  02_主线调研-49款芯片资料库/审计/子代理交接/r1_source_pool_113_staging/论文PDF清单.csv
cmp /private/tmp/source_pool_113_mirror_preview_legacy_v3/清单/汇总统计.json \
  02_主线调研-49款芯片资料库/审计/子代理交接/r1_source_pool_113_staging/汇总统计.json

python3 /private/tmp/source_pool_113_formal_mirror_v3/scripts/collect_references.py \
  --mainline-root /private/tmp/source_pool_113_formal_mirror_v3 \
  --apply --confirm-ledger-sha256 08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812
```

首次 preview 从 legacy prestate 成功生成候选而不写 mirror；首次 apply 后两份 mirror 输出的哈希分别为 `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` 和 `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e`。随后在 mirror 的 `sources.csv` 追加一条不参与本事务的 `SRC-V3-UNRELATED-GA100-TEST` 行，运行 post-apply preview 与第二次相同 confirmation 的 apply：二者都成功，输出哈希没有变化。后续独立复核把无关 GA100 行分别追加到三张 registry，并再次得到通过结果。这证明 expected-output prewrite guard 支持幂等 replay，且来源表没有整表 hash runtime gate。

```sh
python3 /private/tmp/source_pool_113_formal_mirror_v3/scripts/collect_references.py \
  --mainline-root /private/tmp/source_pool_113_formal_mirror_v3 \
  --output-root /private/tmp/source_pool_113_mirror_preview_postapply_v3
python3 /private/tmp/source_pool_113_formal_mirror_v3/scripts/collect_references.py \
  --mainline-root /private/tmp/source_pool_113_formal_mirror_v3 \
  --apply --confirm-ledger-sha256 08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812
```

preview output root 的三类负向测试也已执行，均在写入前以退出码 2 失败：主线本身 `/private/tmp/source_pool_113_formal_mirror_v3`、其子目录 `/private/tmp/source_pool_113_formal_mirror_v3/preview-child`，以及包住它的祖先 `/private/tmp`。拒绝信息为“must be fully disjoint”；因此 preview 不会意外覆盖正式目录或在正式目录中留下候选文件。

一次临时 mirror 首跑暴露了 collector 的实现错误：`find_mainline_root()` 被放在 argparse 的默认参数中，即使显式传入 `--mainline-root` 也会过早求值。该实现错误已改为在 `main()` 中仅当参数缺省时再定位根目录；重放随后通过。它不是 sandbox、审批或远端服务问题。

## 正式推广命令与回滚边界

在正式主线根执行时，先依照 `operations.csv` 创建推广记录，再按 frozen CSV、ledger、collector 的顺序复制。`OP-113-V4-000` 在 `审计/子代理交接/r1_source_pool_113_staging/promotion-records/<promotion_id>/` 创建 `backup-manifest.json` 和 `promotion-record.json`。前者对四个既有目标逐项记录原文件与备份文件的绝对路径、项目相对路径和 SHA-256，并记录受控输入目录原先不存在；后者记录实际备份目录、backup manifest 的路径与 SHA-256、以及每步结果。正式旧 validator 的 precondition 为 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`，与旧 manifest、summary、collector 一起构成四项 fail-closed 输入。

以下命令只表达 collector 的动作；文件复制、backup manifest、内容快照和 Windows gate 顺序以 `operations.csv` 为准。`$PREVIEW_ROOT` 与 `$POST_APPLY_PREVIEW_ROOT` 都必须是与主线完全分离的绝对目录。

```sh
python3 scripts/collect_references.py --mainline-root "$PWD" --output-root "$PREVIEW_ROOT"
cmp "$PREVIEW_ROOT/清单/论文PDF清单.csv" \
  审计/子代理交接/r1_source_pool_113_staging/论文PDF清单.csv
cmp "$PREVIEW_ROOT/清单/汇总统计.json" \
  审计/子代理交接/r1_source_pool_113_staging/汇总统计.json
python3 scripts/collect_references.py --mainline-root "$PWD" --apply \
  --confirm-ledger-sha256 08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812
python3 scripts/collect_references.py --mainline-root "$PWD" \
  --output-root "$POST_APPLY_PREVIEW_ROOT"
python3 scripts/collect_references.py --mainline-root "$PWD" --apply \
  --confirm-ledger-sha256 08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812
```

第二次 apply 前后，推广记录要写两张已排序的 noncontrolled content snapshot：每张列出主线中每个常规文件的 SHA-256 和项目相对路径，排除两份受控输出及两张 snapshot 自身。两张 snapshot 必须逐字节相同，表明第二次 apply 没有改变任何非受控文件。collector 候选 `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb` 在首次 preview 前安装并做写后哈希检查；validator 候选 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0` 只在 snapshot 比较通过后安装。两项正式目标哈希都由 `operations.csv` 固定。

如果 preview、apply、snapshot 比较或三道 Windows hard gate 之一失败，停止推进，不要手工改总数。将既有 manifest、summary、collector 和 validator 从 promotion 前备份逐字节恢复；仅当记录证明这次事务新建了 `清单/资料池受控输入/` 时，才移除该目录。

候选 `Test-SourcePool.ps1` 已把 ledger 与 frozen CSV 的存在性和上述两个 hash 纳入基线，同时校验 113 个磁盘 PDF、blank/duplicate SHA-256、114−1=113、112/101 冻结 inventory、平台总和、类别总和、AMD=6、AMD whitepaper=4 与 `厂商产品资料`=2。

## v4 操作合同静态复核

独立复核提出的唯一拒收项是操作记录缺少第四个既有文件的旧哈希、两份候选脚本的 staging/写后哈希，以及正式步骤中的 post-apply 幂等证据。v4 的 `OP-113-V4-000` 已列出四个旧目标的完整 SHA-256，并把旧 validator 固定为 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`。该步骤还定义了可执行的 promotion-record 与 backup-manifest 结构：实际绝对路径和项目相对路径、四个原文件哈希、四个备份文件哈希、受控输入目录原存在性，以及由独立 `promotion-record.json` 保存的 backup manifest 哈希。

`OP-113-V4-003` 与 `OP-113-V4-008` 分别固定 collector 与 validator 的 staging 源和正式写后哈希，值为 `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb` 和 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`。`OP-113-V4-006` 和 `OP-113-V4-007` 将 post-apply preview、第二次 apply、两个输出不变，以及非受控内容 snapshot 0 diff 写入正式顺序。snapshot 排除的只有两份受控输出和两张用于比较的 snapshot 文件本身，避免自引用；promotion record、备份和其余主线常规文件均进入比较。

本次 v4 没有改动 collector、validator、ledger、frozen baseline、formal payload、PDF manifest 或 summary。静态复核确认它们仍为 v3 独立重放所用的 `2a980efd...efcb`、`c2dc1319...fbf0`、`08994b24...8812`、`c8c43df6...8b27`、`4df7c221...c1ab` 和 `994a4950...4785`；formal payload 与 staging 根的 ledger、frozen manifest 仍逐字节相同。因此保留已完成的 legacy→apply→preview→second apply 重放证据，不以文档修订伪装成一次新的生成器重放。

## 尚未关闭的硬门

Windows 正式硬门尚未执行：当前 macOS 没有 `pwsh`、`powershell` 或 `powershell.exe`，所以无法运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 与 `Validate-ResearchData.ps1 -SubjectContractMode gate`。这是 `tool/runtime failure`，不是 sandbox denial、审批失败或远端服务错误。除此之外，legacy→apply→preview→second apply、无关 GA100 registry 追加和三种 preview output-root 负向路径均已在临时 mirror 完成。

`README.md` 与本记录均已通过 `report-humanizer` 机器扫描。人工按标题、首段、表格引导、过渡和结尾逆向复读后，没有明显 AI 腔；剩余取舍仅是工程交接需要保留的命令、哈希和边界细节。
