# M2-W2 AMD Helios 系统包独立复核

## 裁决

裁决为 `accept_with_fixes`。本包没有越过 Helios 机架对象边界，18 条事实也没有用 `72×` 推导或复制 MI455X 模组、CDNA 5 架构定值；但当前版本有 5 项合并前必须修正的问题。修正、重跑包内检查和正式校验器后，方可并入正式 32 表。

本裁决只覆盖 `审计/子代理交接/m2_staging/M2-W2-AMD-HELIOS-SYSTEM/`。复核未改 staging、正式表、资料卡、项目计划、进度、`README.md` 或 `AGENTS.md`。

## 合并前阻断项

### B1：`all-to-all` 被过度归一为 `fully_connected`

`ASSERT-M2W2-AMD-HELIOS-0020` 的原文是 “UALoE multi-plane network with all-to-all GPU connectivity”。它能证明 UALink over Ethernet（UALoE，以太网上的 UALink）多平面网络提供 GPU 全互达，却不能证明各 GPU 之间存在完全图式的直接物理连接。当前 `FACT-M2W2-AMD-HELIOS-SCALEUP-TOPOLOGY`、`TOPO-M2W2-AMD-HELIOS-SCALEUP` 和对应卡片把它归一为 `fully_connected`，语义强于来源；备注中的“没有单跳保证”不能消除这个矛盾。

修正时应把正式枚举改为 `switched_fabric`，同时在原文标签或说明中保留 “all-to-all GPU connectivity”；如果总控认为现有枚举仍不足以表达“交换网络中的全互达”，则保留未决，不能继续使用 `fully_connected`。相关 事实、断言、拓扑、字段要求、卡片和指纹 必须一起更新。

### B2：三个带宽条件的性能口径没有被当前 locator 完整证明

`COND-M2W2-AMD-HELIOS-SCALEUP` 和 `COND-M2W2-AMD-HELIOS-SCALEOUT` 都写成 `performance_basis=theoretical_peak`。对应原文只分别写 “up to 260 TB/s aggregate scale-up bandwidth” 和 “43 TB/s of scale out bandwidth”，没有把这两个数定性为理论峰值；计算性能脚注也不能外推到互联带宽。因此两行应改为 `vendor_label_unresolved`，除非补入能直接证明理论峰值的固定来源。

`COND-M2W2-AMD-HELIOS-HBM4-BW` 的 `theoretical_peak` 可以由 MI400 固定页另一处 “up to 1.7 PB/s Peak Theoretical Memory Bandwidth” 支持，但当前 `ASSERT-M2W2-AMD-HELIOS-0015` 只定位到行 7531 的 1.67 PB/s 数值。应把行 8252 的定性一并写进 定位、引文上下文或备注，明确 1.67 PB/s 与页面对该指标的理论峰值口径如何对应；方向仍应保持 `direction_not_specified`。

### B3：MXFP4、MXFP8 的计算脚注没有进入断言定位

`ASSERT-M2W2-AMD-HELIOS-0012`、`0013`、`0021`、`0022` 已把 2.9 exaFLOPS 和 1.4 exaFLOPS 分别约束到 OCP MXFP4 与 OCP MXFP8，并与 3 AI exaflops 分开，这是正确的。不过，两个固定页的脚注说明这些数是 AMD Performance Labs 于 2026 年 6 月计算的峰值理论性能，系统厂商配置可能不同；当前断言没有定位该脚注。应把 Helios 行 11722 或 MI400 行 13098 的脚注加入相关定位或备注。不得据此把 `FACT-M2W2-AMD-HELIOS-AI-EXAFLOPS-UNSPEC` 与两条 OCP 精度事实合并。

### B4：CES 来源的最小来源角色和反向移除理由漏掉唯一核心事实

`SRC-M2NA-AMD-CES2026-RELEASE` 不只是 2026-01-05 “early look” 状态的日期证据，也是 `FACT-M2W2-AMD-HELIOS-AI-EXAFLOPS-UNSPEC`（3 AI exaflops）的唯一来源。当前 `source-selected-roles.csv` 只给它 `status_version_evidence`，`selection-members.csv` 的 `mandatory_reason` 也只写移除后丢失状态日期，因此反向移除记录不完整。

应为该来源补 `core_spec` 角色，并在成员的不可替代理由中明确写出“移除后同时失去 3 AI exaflops 唯一直接证据和带日期的 early-look 状态证据”。无需新增来源；这是既有三成员最小集的角色修正。

### B5：条件集数量超过已核准预算，必须回到不多于 6 行

`m2_wave2_queue_audit.md` 给本包的上限是 6 个条件集，staging 实际有 8 个；总控已经明确不批准扩包。合并前应把两个 OCP 计算路径共同使用的“理论峰值、矩阵乘法、厂商计数、系统总量、稠密/稀疏未知”条件合为一行，让 MXFP4 与 MXFP8 两条 precision path 继续分开引用同一条件；31 TB HBM4 容量可复用 `COND-M2W2-AMD-HELIOS-OBS-20260812`。这样正好从 8 行减到 6 行，不会丢失数据格式、数值口径或精度路径差异。修改后须同步 条件指纹、事实引用和卡片说明。

## 已确认没有发生的越界

18 条事实均落在 Helios 机架观察对象、该机架的聚合组件、机架互联、机架精度路径、机架拓扑或正式 `physically_contains` 关系上。没有事实以 `OBJ-AMD-MI455X` 或 `OBJ-AMD-CDNA5-ARCH` 为主体，也没有把 M2-NA 的架构事实复制进来。`derived-metrics.csv` 与 `derived-inputs.csv` 为空；72 个 MI455X 来自两个 AMD 固定页的直接陈述，不是对象 ID 或 `72×` 计算。

`FACT-M2W2-AMD-HELIOS-STATUS-EXPECTED-2H26` 仍归一为 `announced`。原文中的 “volume deployments expected in 2H 2026” 没有被上卷成 available、delivered、production ramp 或可销售；`FACT-M2W2-AMD-HELIOS-NOT-FOR-SALE` 也明确保留 “reference design, not a product for sale”。

## 独立复算与闭环证据

我对 24 个 staging CSV 与正式表逐一比较表头，24 个全部逐字匹配。随后执行 383 项只读包内检查，覆盖主键、目标唯一性、字段和条件外键、直接事实类型、数值互斥、事实、断言、字段要求与卡片之间的闭环、证据状态计数、九域完整度、空表、来源成员角色，以及本地访问入口的文件、字节和 SHA-256；结果为 383 项通过、0 项失败。固定 Helios HTML 实算为 282,127 字节、SHA-256 `ed1642ec9ec16f9a5db4a8956b367e9859a3b2f47f9b18fcfe441fc56c34c6b7`，固定 MI400 HTML 实算为 318,594 字节、SHA-256 `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e`，均与 endpoint 记录一致。

18 条事实逐条回查固定原文后，数值换算成立：3、2.9、1.4 exaFLOPS 分别是 $3\times10^{18}$、$2.9\times10^{18}$、$1.4\times10^{18}$ FLOP/s；31 TB、1.67 PB/s、260 TB/s 和 43 TB/s 均按十进制换成 byte 或 byte/s。`ASSERT-M2W2-AMD-HELIOS-0009` 与 `0010` 直接支持 72，`0005` 直接支持 not for sale，`0006` 与 `0007` 只支持预期部署和 early look，`0008` 支持液冷，`0014` 至 `0019` 支持机架聚合存储及互联值。逐条回查中只有 B1 至 B4 所列的归一、条件定性、脚注定位和来源角色需要修正；其余定位均能回到所列固定页位置。

九域状态恰有 9 行：identity、physical、compute、numerics、memory、interconnect、software、evidence 均为 `partial`，special_engines 为 `not_applicable`。这是机架轻量观察卡的合理边界。`derived-inputs.csv`、`derived-metrics.csv`、`requirement-evidence.csv`、`search-log.csv`、`search-results.csv` 与 `special-capabilities.csv` 均为空；未发现需要新增 M2-NA 架构 backlog 的内容。

我把 staging 片段追加到受控临时正式副本后运行官方 `Validate-ResearchData.ps1`，结果为 `PASS`，共执行 93,788 项检查。临时目录随后删除并确认不存在；正式 32 张 CSV 在操作前后逐文件计算 SHA-256，变化数为 0。官方校验通过只能证明结构闭合，不能覆盖本报告列出的 5 项语义与流程阻断。

## 结论与复核入口

本包修正 B1 至 B5 后可以再次送审，不需要重做对象身份门、72 数量核验或来源下载。复审应重点查看上述 ID、更新后的指纹、条件集是否不多于 6 行，以及 CES 来源是否同时承担 `core_spec` 和状态版本角色。

根 `README.md` 与 `AGENTS.md` 已检查但无需修改：本次只新增独立复核记录，没有改变已验收的项目状态、正式结构、运行方式或长期协作约定。