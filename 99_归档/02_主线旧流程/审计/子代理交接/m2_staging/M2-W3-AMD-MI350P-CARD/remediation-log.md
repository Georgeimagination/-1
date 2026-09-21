# MI350P 修正记录

> 工作包：`M2-W3-AMD-MI350P-CARD`  
> 状态：`in_progress`  
> 开始日期：2026-08-13  
> 修正依据：`审计/子代理交接/m2_review_mi350p.md`，SHA-256 `ce4ebf4aee3ce9dccaaf609ce2b7a455d36c9744ad1a481a8b8853a56ea5d77f`

## 起始节点

本次只修改本 staging 包，不改正式 CSV、正式资料卡或全局文档。起始冻结包为 39 条事实、48 条断言和 45 条字段要求；冻结清单 49 行，SHA-256 为 `e7146b709d5a1a9708603aba14c2d3b1bd0361e7ab271bf43aab07f990a7f0b0`，聚合哈希为 `1332e24e5ef9a30ecaf1c62b5d50ef3f46edbaa59148e5d69faad0cd61b16f46`，资料卡 SHA-256 为 `164e650d102482a4a45bbd6658a9edd677dc2c2417dc0437e51c7a6ca046918b`。

修正范围固定为三项：补入 73 Billion 晶体管事实链；把 FP16、FP32、FP64 三条向量峰值断言从产品页改绑固定 brochure；对象最小来源集移除 CDNA4 whitepaper 与 ISA。缺口检索不增加，仍为 12 条 search log 和 56 条 search result。

预期修正后为 40 条事实、49 条断言、46 条字段要求和 3 个对象最小来源成员。完成结构化修改后再同步资料卡、来源说明、计数、验证报告与新清单；最后执行包级校验、当前正式库静态检查和临时正式合并演练。修正执行者不签最终 `accept`。

## 节点记录

- 2026-08-13：修正任务已开始。
- 2026-08-13：三组结构化修正已经写入并由生成脚本复现。`facts.csv`、`fact-assertions.csv`、`field-requirements.csv` 分别为 40、49、46 行，SHA-256 依次为 `9673483ecf9daa6a373f07b1777840adee816f3b5b54ac45e907ea33d53cc872`、`50b3efec4c4f6eca0c646c70cf5f8fd326d5efa495a87cb0e94246e0f838d3f1`、`9e156c482c3c1b0c4e6ddd7342f29520909fbc19ba437c4284cb4a6d573e2f3d`。
- 新增主键为 `FACT-M2W3-AMD-MI350P-TRANSISTORS`、`ASSERT-M2W3-AMD-MI350P-TRANSISTORS-PRODUCT`、`REQ-M2W3-AMD-MI350P-TRANSISTORS`。原三条 `*-VECTOR-PEAK-PRODUCT` 断言已删除，替换为 `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-BROCHURE`、`ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-BROCHURE`、`ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-BROCHURE`；固定简报第 1 页的 `HPC Peak Performance (Estimated)` 表直接承担向量分类。
- CDNA4 whitepaper 与 ISA 的对象级 selected role、coverage 和 selection member 均已删除；两条 screening 保留为 `lead_only`。修正后的选择运行有 3 个成员，缺口检索仍为 12/56。
- 本节点还同步了可重放生成脚本。结构化校验脚本、资料卡、来源审计、交接文档和最终清单尚待更新。
- 2026-08-13：修正生成器已用 Windows PowerShell 5.1 全量重放，包级校验通过 1,082 项；事实主体合同和字段要求目标合同不一致均为 0。f152 正式库在演练前通过 106,160 项检查，临时合并通过 111,343 项，临时目录随后删除；正式库再次通过 106,160 项，32 张 CSV 与基线逐文件哈希一致。
- 执行中一次长命令触发 Windows 命令行长度上限，数次文本锚点或数组写法错误未通过写后检查；另有一次 UTF-8 无 BOM 文件被 Windows PowerShell 5.1 按本地代码页读取。前两类属于命令构造或执行者操作错误，编码问题属于运行时兼容性与写入方式错误；都不是用户拒绝、审批失败、沙箱拒绝或远端服务故障。生成脚本和校验脚本改为可被 Windows PowerShell 正确读取后，所有受影响结果已重建并验证。
- 结构化事实集至此冻结，不再扩查。中文文档已完成 `report-humanizer` 机器扫描和 `shuorenhua` 人工复核；包状态已改为 `ready_for_final_independent_review`。下一步只生成最终 manifest 并只读复核；修正执行者不会自签 `accept`。
