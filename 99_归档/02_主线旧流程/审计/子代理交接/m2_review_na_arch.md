# M2-NA-ARCH 独立复核最终签字

> 复核对象：`审计/子代理交接/m2_staging/M2-NA-ARCH/`  
> 复核日期：2026-08-13  
> 最终裁决：`accept`  
> 合并许可：允许总控合并。

## 复核边界

本次只复核上一版报告列出的六项阻断，以及修复后必须保持不变的断言、卡片、证据映射、最小来源选择和临时正式合并结果。复核者没有参与修复，也没有修改 staging 或正式库；本报告是唯一保留的写入文件。

## 六项阻断已关闭

四条每周期传输事实已经改用正式字段：

| 事实 | 正式字段 | 规范值 | 作用域保存位置 |
|---|---|---:|---|
| `FACT-M2NA-CDNA3-L2-READ` | `FIELD-MEM-READ-TRANSFER-PER-CYCLE` | `2048 byte/cycle` | `COND-M2NA-CDNA3-L2-XCD` 保留每 XCD 作用域 |
| `FACT-M2NA-CDNA4-LDS-READ` | `FIELD-MEM-READ-TRANSFER-PER-CYCLE` | `256 byte/cycle` | `COND-M2NA-CDNA4-LDS-READ` 保留每 CU 作用域 |
| `FACT-M2NA-CDNA4-L2-READ` | `FIELD-MEM-READ-TRANSFER-PER-CYCLE` | `128 byte/cycle` | `COND-M2NA-CDNA4-L2-READ` 保留每 channel 作用域 |
| `FACT-M2NA-CDNA4-L2-WRITE` | `FIELD-MEM-WRITE-TRANSFER-PER-CYCLE` | `64 byte/cycle` | `COND-M2NA-CDNA4-L2-WRITE` 保留每 channel 作用域 |

正式 `fields.csv` 中两个新字段均为 `value_kind=number`、`canonical_unit=byte/cycle`，允许的目标层级为 component。四条事实的作用域没有混入规范单位，事实、条件集、字段要求和卡片保持一致。

`FACT-M2NA-BLACKWELL-TMEM-LOGICAL-SPACE` 仍使用 `FIELD-MEM-CAPACITY`，规范值已改为 `262144 byte`。换算为：

$$
512 \times 128 \times 32 / 8 = 262144\ \text{byte}
$$

`COND-M2NA-BLACKWELL-TMEM-CC100` 和事实说明均限定为每个 CTA（Cooperative Thread Array，协作线程阵列；对应一个 CUDA thread block）的逻辑地址空间。该值没有被解释为物理 SRAM（Static Random-Access Memory，静态随机存取存储器）容量或 GPU 总容量。

AMD CDNA 产品页的两处最小来源角色也已修正：`SELMEM-M2NA-AMD-CDNA-LANDING` 与 `SROLE-M2NA-AMD-CDNA-LANDING` 均为 `architecture_mechanism`，理由只指向 `FACT-M2NA-CDNA5-IF-PROTOCOL` 的 coherent on-package Infinity Fabric 机制，不再使用通用代际身份作为入选理由。

## 闭环与选择复核

`fact-assertions.csv` 仍有 185 条断言，SHA-256 为 `0a5ef16209e1e63b20fb89191b9bd8361082487fa7514a9080aeeb299274623b`，与修复前登记值相同。185 条事实各有且只有一条断言；`notes/fact-evidence-map.csv` 也有 185 行，各事实恰有一条映射。11 张卡共出现 185 个互不重复的 `fact_id`，与 `facts.csv` 一一对应。五条本轮修正事实在对应卡片中各出现一次，字段、规范值、条件和定位均与结构化表一致。

最小来源集仍有 17 个成员和 17 行入选角色。每个成员至少支撑一条当前断言，断言来源全部位于该选择集中，没有重复成员、零贡献成员或缺少角色的成员。`SELRUN-M2NA-ARCH-20260812` 已记录本次字段与规范单位修正后的复核结果。

## 临时正式合并

复核时重新复制正式 18 张数据表和 14 张最小参考资料表，按正式表头追加 staging 的 23 张结构化片段。23 张表的追加行数全部吻合。临时副本引用 46 个不同的本地 endpoint；文件缺失和 SHA-256 不一致均为 0。

官方校验器结果为：

```text
PASS: 32-table research data model; 75776 checks executed.
Registry: 323 columns, 488 enum values.
```

退出码为 0。临时正式合并副本已删除。

## 裁决

六项阻断均已关闭，断言文件没有漂移，卡片和证据映射保持双向对应，最小来源选择仍成立，官方临时合并校验通过 75,776 项检查。最终裁决为 `accept`，允许总控合并 M2-NA-ARCH。

项目级 README 与 AGENTS 已检查。本次只更新独立复核报告，没有改变正式项目目标、目录结构、数据模型或全局进度；正式合并后的状态更新仍由总控负责，因此两份项目文档无需由本复核者修改。