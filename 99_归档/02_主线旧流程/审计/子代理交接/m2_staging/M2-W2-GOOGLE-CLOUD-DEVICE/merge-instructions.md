# 临时正式副本合并说明

本说明只供独立复核和总控验收使用。当前包没有与正式 32 表逐列对齐的 facts 或资料卡片段，不得直接批量追加。

## 合并顺序

先在正式数据的临时副本中执行范围合并。由总控把 `object-scope-candidates.csv` 的三枚对象转换成 `objects.csv` 正式列，把状态保持为 `needs_resolution`；再把 `relationship-candidates.csv` 的三条关系转换成 `object-relations.csv`。三个架构端点已存在且为 `reviewed`，但这不能替代三枚新对象的范围补验收。

随后处理来源。`source-candidates.csv` 中以下三个 ID 已由总控预留为 staging 候选：

- `SFAM-M2-W2-G-TPU-MACHINES`
- `SRC-M2-W2-G-TPU-MACHINES-20260813`
- `END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813`

建议的远端入口 ID `END-M2-W2-G-TPU-MACHINES-PRIMARY` 尚未得到正式预留，独立复核后由总控决定。远端入口应使用 `html_page`；本地内容提取使用 `other`，`is_preferred_endpoint=false`，notes 必须逐字保留 `renderer-extracted text wrapped as HTML / not upstream response body`。内容提取不能标为 `web_snapshot`，不能替换远端入口，也不能被描述为上游响应体。

六份本地文件应先复制到 `source-candidates.csv` 的 `proposed_formal_path`，再在临时副本中重算字节数和 SHA-256。只有结果与候选表一致时，才能把相应 endpoint 行加入临时来源表。现有 G05、G08、G09、G10、G15 的 source 记录继续复用，不新建重复 source；只增加 2026-08-13 extract endpoint 候选。

## 不在本包合并的内容

`deferred-dispositions.csv` 是审计处置，不是正式 facts 表。总控应先决定把两个 GV5P-03 子项持久化到哪张正式审计表，再分别交给云端器件事实包和物理 package 身份包。本包不允许把父待办标成“处理一半”，也不允许生成 1 GiB 预留量。

`configuration-row-dispositions.csv` 同样不直接转成 facts。CT6E 家族到 v6e 器件的关系候选只能作为后续配置范围输入，本包不合并关系数量。命名机器类型尚无独立正式对象，slice/Pod 也没有完成身份门；这些配置值不能暂挂到三枚器件对象或用关系 notes 代替结构化事实。

`source-selection-candidates.csv` 不是可直接追加的正式片段。G05 的组合覆盖束需按正式 `source-coverage.csv` 的单一 `covering_source_id` 约束拆分；四源选择运行要在事实包冻结后重跑并由不同代理签字。G09 在新器件范围的 screening 必须单独登记，不能修改或复用架构范围的旧结论。

## 验证

独立复核先运行包内校验器：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\审计\子代理交接\m2_staging\M2-W2-GOOGLE-CLOUD-DEVICE\Validate-Package.ps1'
```

总控若决定合并，应在受控临时正式副本里追加对象、关系与获准来源记录，再运行 `scripts/validation/Validate-ResearchData.ps1`。正式目录在总控验收前必须保持逐文件哈希不变。临时校验通过也不能把 staging 的 `draft` 自动改成 `reviewed`；状态迁移仍须显式主键清单和独立签字。

原始响应体尚未取得只影响 endpoint 冻结完整性，不阻断三对象范围候选。正式交付中必须继续把它写成 `upstream_body_pending`，直到后续真的保存并核验上游响应体。