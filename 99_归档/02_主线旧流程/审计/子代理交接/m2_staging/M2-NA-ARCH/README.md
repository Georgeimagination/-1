# M2-NA-ARCH：NVIDIA 与 AMD 架构工作包

> 状态：`ready_for_independent_rereview`  
> 资料截止日：2026-08-12  
> 写入边界：本目录是独立 staging。正式资料卡、正式 32 表、根 README、AGENTS、研究计划和进度文件均未修改。

## 交付范围

本包处理 11 个已预留正式 ID 的架构代际对象：NVIDIA Ampere、Hopper、Ada Lovelace、Blackwell、Blackwell Ultra、Rubin，以及 AMD CDNA 2、CDNA 3、CDNA 4、CDNA 5、CDNA 6。Hopper 只有 M1 复用说明，没有新增事实。其余 10 张卡合计 185 条事实；卡片只收架构代际能直接承担的执行组织、数值语义、存储机制、互联协议、特殊能力和软件映射，不把具体裸片、封装、卡、模组或系统数值上卷。

## 修复后的结构

工作包现有 64 个组件、23 个 memory level、50 条精度路径、37 项特殊能力、11 条互联、28 组条件、185 条事实、185 条逐来源断言、369 条字段要求、128 条检索记录和 249 条检索结果。11 张卡仍覆盖九个资料域。每条事实恰有一条断言，也恰在一张对应卡中出现；`notes/fact-evidence-map.csv` 已按修复后的断言重建。

CDNA 4 白皮书 Table 1 的 MI355X FP16 矩阵吞吐为 4096 FLOP/cycle/CU。与同表 256 FLOP/cycle/CU 的 FP16 向量吞吐相除，矩阵/向量比为 16。原 LDS 存算比不符合 `FIELD-DER-COMPUTE-BW-SPEC` 的铭牌带宽定义，相关事实、指标、输入、条件和要求均已删除。白皮书所说的 16 个 L2 channel 和 16-way 组相联也不能当成 bank 数量，因此原 L2 bank 事实已转为待补字段要求。

Blackwell 解压占位组件和能力已经删除；相关产品实现线索只保留在 `notes/implementation-fact-backlog.csv`。Rubin 的双裸片及其中 NV-HBI 线索同样只留实现待办，不再建立架构 link 或 fact。Ada 与 Rubin 的软件事实因选定来源缺少可直接定位的编程模型陈述而删除，对应字段保留 `not_found` 与检索记录。

## 来源与最小集

修复后的反向移除草案仍有 17 个来源成员。每个成员至少独占一条当前事实，因此删除任一成员都会留下无直接证据的事实。Blackwell Tuning Guide 在本事实集合上由更直接的技术简报和 PTX（Parallel Thread Execution，NVIDIA 低层指令集文档）覆盖；Blackwell Datasheet 的独有数字属于产品或系统层级，未进入架构最小集。

四份动态网页已保存为官方 HTML 快照，并登记获取日期、项目内路径和 SHA-256：

| 来源 | 快照大小 | SHA-256 |
|---|---:|---|
| Blackwell Ultra softmax | 273,475 bytes | `1ff2d6a189da948c69e2b578386814b6009c3f688b64d0a41acd7b277161cc3d` |
| Rubin 架构文章 | 344,864 bytes | `6e31747831a9e985becfd3f395414bbf69c1fde9da4a8182b1abda5b20ed9c83` |
| AMD CES 2026 / CDNA 6 | 120,072 bytes | `c2d36db9db2f7d269dc4db51ba4125e4556dd666270c010ac715eed0d9e6009f` |
| AMD CDNA 产品页 | 238,514 bytes | `894598db3beaab36631f476b3a618b53169f0ac59cdb0b6d5d494a4153ed0f71` |

四个来源在 `sources.csv` 中使用正式枚举 `current`；`source-endpoints.csv` 把本地 `web_snapshot` 标为唯一优选入口，远程地址继续作为非优选入口保留。本轮重新计算四个文件的哈希，均与登记值一致。

固定 PDF 也已复核：CDNA 2 为 17 页，CDNA 3 为 28 页，CDNA 4 为 21 页，CDNA 5 为 24 页；四个文件的 SHA-256 均与 endpoint 登记一致。AMD ISA 仍使用官方在线 PDF 入口。尝试下载固定 ISA PDF 时，提升权限申请被自动审批复核因额度耗尽拒绝；这不是用户拒绝、沙箱拒绝或远程服务错误，也没有用伪造快照替代。

## 验证

本包没有保留自制 PowerShell 脚本或图片。将 23 个 staging CSV 追加到正式 32 表的临时副本，并为副本准备 46 个本地 endpoint 后，项目正式校验器结果为：

~~~text
PASS: 32-table research data model; 75776 checks executed.
Registry: 323 columns, 488 enum values.
~~~

额外语义检查也通过：facts 和 requirements 的字段目标类型错误均为 0；断言基数、孤儿断言、证据合同错误、卡片漏追溯、卡片陈旧值、已完成要求缺事实、`not_found` 缺检索记录和派生值复算错误均为 0。完整记录见 `notes/validation-report.md` 和 `remediation-log.md`。

独立语义复核指出的三项遗留问题也已处理：CDNA 5 的 Infinity Fabric 事实补入 coherent 原句和行号；Ampere、Ada 的复合 SM 执行事实改用足以支撑各执行分支的短摘录；13 个只承担结构或精度路径归属的组件已补职责，并写入相应资料卡。计数没有变化，也没有新增规格。

总控登记每周期传输字段后，本包又做了一次局部字段修复。CDNA 3 L2 读、CDNA 4 LDS 读和 L2 读改用 `FIELD-MEM-READ-TRANSFER-PER-CYCLE`，CDNA 4 L2 写改用 `FIELD-MEM-WRITE-TRANSFER-PER-CYCLE`；四条事实的规范单位均为 `byte/cycle`，XCD（AMD 计算芯粒）、CU（Compute Unit，计算单元）或通道（channel）的作用域继续保存在条件集和说明中。Blackwell Tensor Memory（TMEM）每 CTA（Cooperative Thread Array，对应一个 CUDA thread block）逻辑空间按 $512 \times 128 \times 32 / 8$ 规范化为 262144 byte。这是对来源完整尺寸陈述的直接单位换算，不作为派生性能指标，也不代表物理静态随机存取存储器（SRAM）或 GPU 总容量。AMD CDNA 产品页在最小集中的角色同步收紧为 `architecture_mechanism`，只承担 coherent on-package Infinity Fabric 机制证据。

最新临时合并使用正式 `fields.csv`，没有在 staging 复制字段表；正式字段表 SHA-256 为 `7cf5442800a7e453b34bbda4ac335ccf101ce5cac2dde297be657d4f56a02cae`。185 条原文断言未改，文件 SHA-256 仍为 `0a5ef16209e1e63b20fb89191b9bd8361082487fa7514a9080aeeb299274623b`。卡片双向、字段契约、反向移除和正式临时合并检查均通过，结果为上列 75,776 项检查。

## 总控复核重点

总控合并前仍应裁决 Hopper 的正式复用关系、Blackwell Ultra 与 Blackwell 的关系缺位，以及 Ampere/Ada/Blackwell CUDA ALU 在现有 schema 中归 `scalar` 后的可比边界。Rubin 与 CDNA 6 仍是截止日观察卡：前者的 10 条事实依赖同一份已固定官方网页，后者只有架构名称和 announced 状态，不能当作完整微架构资料。

项目级 README 与 AGENTS 已检查。本工作包没有改变正式项目目标、目录结构或全局进度，而且子代理写入边界明确禁止修改它们；是否同步正式状态由总控验收合并后决定。