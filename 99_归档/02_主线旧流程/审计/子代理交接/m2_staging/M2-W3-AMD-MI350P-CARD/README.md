# M2-W3 AMD MI350P PCIe 卡事实包

> 状态：`ready_for_final_independent_review`  
> 资料截止日：2026-08-13  
> 写入边界：仅限本目录；正式 32 表、正式资料卡、项目根文档和其他 staging 未修改

本包为 `OBJ-AMD-MI350P` 建立单张 PCIe（Peripheral Component Interconnect Express，高速外设互联）加速卡资料卡和同表头结构化片段。对象通过既有关系 `OREL-AMD-MI350P-IMPLEMENTS-CDNA4` 引用 `OBJ-AMD-CDNA4-ARCH`。MI350X、MI355X OAM（OCP Accelerator Module，开放加速器模组）、MI350 Series 八 OAM 平台、服务器最多八卡和机架聚合值迁移量为 0；CDNA 4 的每 CU（Compute Unit，计算单元）机制与指令语义没有复制到产品事实。

## 交付规模

结构化包包含 40 条一手直接事实、49 条逐来源断言、46 条字段要求、12 条缺口检索与 56 条逐来源结果、9 行完整度、5 个组件、2 个存储层级、1 条 PCIe 链路、12 条精度路径和 10 个条件集。新注册候选为 3 个内容版本、6 个访问入口（endpoint）；对象级选择运行 1 次，共 3 个成员。特殊能力、拓扑、派生指标、派生输入和冲突表均为 0 行。

40 条事实没有超过预算上限。修正新增产品页明确给出的 73 Billion 晶体管数；矩阵峰值由 MI350P 精确产品页直接支持，三条向量峰值改由固定简报中标为 `Estimated` 的 vector 行直接支持。产品页的 72、72、36 TFLOP/s 通用行只作数值交叉核对，不保留重复向量断言。基础峰值行不擅自标成 dense，structured-sparsity 行不补 2:4，INT8 保持 OP/s，也不使用每 CU 值相乘。输入精度、累加精度、稀疏和带宽方向合同没有同时闭合，因此不计算存算比或每瓦性能。

## 来源与最小集

新增的三个内容版本是 MI350P 精确产品页、固定简报 `LE-93401-00 05/26`、以及 2026-05-07 官方文章。产品页承担当前对象身份、730 亿晶体管和卡级资源、存储、散热及矩阵峰值；简报独有四个 XCD（Accelerated Compute Die，加速计算裸片）、一个 IOD（I/O Die，输入输出裸片）、完整 FHFL（full-height, full-length，全高全长）CEM（Card Electromechanical，PCIe 卡机电规范）形态、PCIe 128 GB/s 与直接标注的三条向量峰值；文章独有日期化 available 状态。反向移除后，这三个来源各自保留独有作用。CDNA 4 白皮书与 ISA（Instruction Set Architecture，指令集架构）仍用于边界和缺口核对，但状态是 `lead_only`，不属于对象最小集。

D-1 和 D-7 的 2026-08-13 快照继续保留在 `fixed-candidates/` 和身份审计中。精确产品页覆盖 D-1 的对象行，D-7 的系列边界不需要新增产品规格断言，因此二者不占用本包最多 3 个新增内容版本。

## 验证

修正后包内校验通过 1,082 项检查；事实主体合同和字段要求目标合同不一致均为 0；九域完整度恰有九行。以 f152 正式基线做临时正式合并，正式验证器在 `gate` 模式通过 111,343 项检查，注册表为 324 列、488 个枚举值。临时镜像已清理；正式库随后仍通过 106,160 项检查，32 张 CSV 的逐文件哈希与刷新基线一致。

## 主要文件

- `card-draft/AMD_Instinct_MI350P_PCIe_卡资料卡.md`：面向读者的完整草稿；
- `structured/`：26 份与正式表同表头的 CSV 片段；
- `source-and-fact-audit.md`：事实边界、来源重叠、反向移除、差异与缺口；
- `source-identity-preflight.md`：D-1、D-7 身份门与访问异常；
- `source-freeze-register.csv`：七个候选或既有来源的 URL、访问日、字节数和哈希；
- `fixed-candidates/`：四份官方 HTML 与一份固定 PDF；
- `validation/package-validation-result.json`：包内 1,082 项检查结果；
- `validation/temporary-formal-merge-result.json`：111,343 项临时正式合并结果；
- `validation/formal-32-csv-baseline.csv`：总控并发 AWS 合并后的正式基线。

本包没有改变全局任务台账或正式数据。定点修正完成并重新冻结后，由未参与修正的代理终审对象层级、晶体管事实链、矩阵/向量峰值责任来源、累加缺口、带宽方向、available 状态和三来源最小集。