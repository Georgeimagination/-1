"""Assemble the human-readable two-layer report from reviewed plot records.

This uses existing product articles as citation namespaces. It is a report
builder, not a replacement for the product cards or their original sources.
"""
from pathlib import Path
import json, re, html
R=Path(__file__).resolve().parent
D=json.loads((R/'panorama36.json').read_text());M=D['products']
S=json.loads((R/'panorama-stats.json').read_text())
from collections import Counter
FC={f:Counter(r['formats'][f]['state'] for r in M) for f in ('BF16','FP8','FP4')}
pos={'training':'偏训练','inference':'偏推理','both':'训推兼顾','unclear':'未明确'}
support_pos={'training':'训练有资料','inference':'推理有资料','both':'训推均有资料','unclear':'未明确'}
from comparison_analysis import supplemental_report, robustness_report
state={'yes':'支持','conditional':'有条件执行','unknown':'未确认','conflict':'有分歧','no':'无原生支持'}
power_scope={'board_max':'板卡上限','module_max':'模组上限','chip_tdp':'芯片 TDP','unknown':'口径未确定'}
basis_text={'dense':'原文明确 dense','derived_dense':'依据明确条件换算 dense','condition_unspecified':'条件尚未完全对齐','excluded':'不纳入配比图'}
scope_text={'matrix':'矩阵路径','chip':'整芯片宣传口径'}
def src(r,s):
    if not s:return '未找到可定位来源'
    return re.sub(r'\[(\d+),\s*([^\]]+)\]',lambda m:f"[参考 {m[1]}，{m[2]}](../产品详解/{r['card']}#ref-{m[1]})",str(s))
def cell(s):return str(s).replace('|',' / ').replace('\n','<br>')
def val(v,unit=''):
    return f'{v:g}{unit}' if isinstance(v,(int,float)) else '未确认'
def p_link(r):return f"[{r['order']:02d} {r['label']}](#panorama-{r['id']})"
def article(r):return f"[产品详解](../产品详解/{r['card']})"
def fact(r,s,citation):
    s=s.replace('null是不适用，不是0。','该项不适用。').replace('max_w字段在此按scope表示芯片TDP额定值','图中按芯片 TDP 额定值展示')
    return cell(s+' '+src(r,citation))
def memkind(r):return {'none':'不设外部 DRAM','unknown':'未确认'}.get(r['memory']['kind'],r['memory']['kind'])
def form(r):
    if r['vendor'] in ['Google-TPU','AWS']:return '官方单芯片配置（云端）'
    if r['id']=='groq_gen1':return '单处理器'
    if r['id']=='mlu590':return '芯片级对象；板卡配置未固定'
    return re.split('[；。]',r['deployment']['form'])[0]
def alternatives(r,items):
    if isinstance(items,str):return src(r,items)
    if not isinstance(items,list):return cell(str(items))
    lines=[]
    basis={'source_dense':'原表 dense 值','derived_from_sparse':'由稀疏值换算的候选','source_dense_other_spec_context':'另一容量配置的 dense 值'}
    for item in items:
        bits=[]
        for k,u in [('value_tflops',' TFLOP/s'),('capacity_gb',' GB'),('bandwidth_tb_s',' TB/s')]:
            if item.get(k) is not None:bits.append(val(item[k],u))
        if item.get('basis'):bits.append(basis.get(item['basis'],item['basis']))
        if item.get('note'):bits.append(item['note'])
        lines.append('；'.join(bits)+' '+src(r,item.get('source')))
    return '<br>'.join(lines)
parts=[]
def add(s):parts.append(s.strip()+'\n')

add(f'''# 训练与推理芯片：全产品分布与家族内比较

两层比较 · 7 家厂商、36 个产品、12 个产品组 · 2026 年 9 月 23 日

这份报告比较现有清单中产品的数值格式、计算规模、存储供给、设备互联与部署条件。产品按照具体 SKU（硬件配置明确的型号）或官方单芯片配置计数；服务器、机架和集群只用于解释接口与部署边界。范围限于现有 36 个对象，尚不能代表整个市场。

全部产品进入格式矩阵、产品总表和逐项证据；每张定量图使用条件足够明确的子集。当前有 {S['dram_capacity']} 个产品可列外部主存容量、{S['dram_bandwidth']} 个可列带宽，{S['paired16']} 个能将 16 位峰值与主存配置配对。其中 {S['strict_matrix_dense']} 个采用明确的矩阵 dense 值或有依据的换算，另 {S['conditional_pairs']} 个仍有计算路径或稠密条件未完全对齐。dense 指未利用结构化稀疏跳过运算。

现有数据尚不支持用单一存算比区分训练与推理产品。数值格式和主存类型在不同定位的产品之间广泛交叉；相近计算规模的产品，其容量、带宽与互联供给也不总是同比增加。第一层呈现资源分布，第二层结合 12 个产品组的官方资料说明哪些差异来自共同核心下的配置调整，哪些涉及机制改变。规格差异仍需结合负载和实测，才能解释实际性能或能效差异。

## 1. 产品范围与读图方法

颜色表示官方主要设计目标：偏训练、偏推理或训推兼顾。官方支持用途在另一列保留，支持另一用途不自动改变主要取向。这是依据官方产品目标的研究分类，不表示用途排他性或厂商投入比例。TPU v5e、Trillium、Ironwood、Trainium2/3、H100 PCIe、H200 NVL 的表述存在交叉，正文另检查采用其他有来源分类时的结果；分类依据保存在文末，不根据带宽、功耗或名称推断。

算力和配比图中的实心点采用明确矩阵 dense 口径，空心点表示整芯片值或条件未展开的厂商值。实心点也没有统一所有累加格式和时钟，它们适合比较公开资源配置，不构成相同精度质量下的性能测试。依据稀疏倍率或核数换算的值在证据中注明计算过程。产品编号在图表与证据条目间保持一致，点击图中数据点可回查证据。

“未确认”表示资料不足；“不适用”表示该层资源并不存在于当前比较对象中；“配置未配对”表示已有数值无法组合为同一产品配置。三者都没有按零处理。重复使用同一底层架构的多个 SKU 是多个产品观察，不能算作多个独立架构证据。
''')
add('| 编号与产品 | 主要设计取向 | 官方资料覆盖用途 | 外部主存 | 产品形态 |\n|---|---|---|---|---|')
for r in M:
    add(f"| {p_link(r)} | {pos[r['orientation']['group']]} | {support_pos[r['position']['group']]} | {cell(memkind(r))} | {cell(form(r))} |")
add('PCIe 是主机与加速器之间常用的连接接口；SXM、OAM、EAM 是不同的加速器模组形态；SoC 指集成多个功能单元的系统芯片。表中只概括产品形态，封装组成与冷却条件见第 10 节。')

add(f'''## 2. 数值格式与计算规模

FP64、FP32、FP16、FP8、FP4 分别使用相应位数的浮点表示；BF16 是另一种 16 位浮点格式，TF32 是具有特定尾数和指数范围的矩阵输入模式。INT8、INT4 表示整数格式。相同位数不保证相同数值范围、舍入、缩放或累加行为，FP8/FP4 家族中的不同编码在图中合并展示可用性，具体变体仍见逐产品证据。

![36个产品的数值格式支持](图表/全景01_数值格式.png)

图 1。圆点表示有对应运算路径，不保证是矩阵路径，也不保证高速执行。方块表示经转换等条件后执行；叉号仅用于来源明确排除的原生支持，问号表示未确认，菱形保留来源分歧。仅能存储某格式或做独立类型转换，不计作该格式的计算支持。每个格子的执行范围和来源可在第 10 节展开。

格式支持矩阵没有形成训练与推理之间的单一精度界线。FP16/BF16 等路径在多类定位中出现，低位输入也不能单凭位宽判断是“推理专用”。例如 Trainium3 的 MXFP4 输入先映射到 MXFP8 后进入 TensorEngine（AWS 的矩阵计算引擎），故保留为条件支持；AMD CDNA 4 架构的 TF32 软件模拟也与原生 TF32 路径区分。MXFP4/MXFP8 属于带共享缩放因子的低位浮点格式；这些执行条件不能相加为“支持格式总分”。[Trainium3](../产品详解/AWS/AWS_Trainium3_one_chip_产品详解.md) [MI350X](../产品详解/AMD/MI350X.md)

36 个产品中，{FC['BF16']['yes']} 个有 BF16 运算路径记录，另 {FC['BF16']['conditional']} 个保留条件支持；FP8 家族为 {FC['FP8']['yes']} 个、另 {FC['FP8']['conditional']} 个条件支持，FP4 家族为 {FC['FP4']['yes']} 个、另 {FC['FP4']['conditional']} 个条件支持。这说明低位浮点已出现在多种产品中，但尚不是本清单所有产品共有的能力。其余格子主要是当前资料未确认，不能据此断言硬件不支持。

![16位公开计算峰值](图表/全景02_16位峰值.png)

图 2。TFLOP/s 表示每秒万亿次浮点运算。选取可以固定到本产品的 FP16 或 BF16 峰值；矩阵、向量和标量不相加成总算力，稀疏峰值也不与 dense 值直接并列。没有可靠 16 位数值的产品仍占一行；Groq 的片上主存路线不妨碍其出现在计算规模图中。

NVIDIA 的部分型号依据明确的结构化稀疏倍率折算 dense 值；AWS 的部分型号采用已披露单核 TensorEngine 峰值乘核数，保留整芯片宣传值作为另一个来源口径。图 2 中的值和后续存算比始终使用同一条记录。L40S 的原表矛盾、B300 的容量版本对应问题、TPU 8 的软件性能模型以及 Ascend 950 的多档配置分别说明，不用最大值拼成一个点。
''')

add('''## 3. 存储组织与外部主存

DRAM 在这里指设备用于保存权重和运行状态的外部主存；HBM 是采用堆叠封装的高带宽 DRAM，GDDR 是常见于图形与加速卡的显存，DDR/LPDDR 是其他主存接口形式。“外部”相对计算裸片而言，HBM 即使位于同一封装内仍归入这一层。SRAM 则用于片上缓存或工作存储；cache 的硬件管理方式与程序显式管理的工作存储分别记录。

下表按已有实现组织产品。这里比较存储层的用途和管理方式，没有把不同层级的 SRAM 加成“等效 L2”，也没有要求每个产品必须具有 L2。
''')
groups=[
 ('NVIDIA：A100、H100/H200 各型、L4/L40S、B200/B300','a100_sxm4','寄存器、硬件管理的 L1/L2 与程序显式使用的 shared memory 并存。部分产品还有专用矩阵工作存储或跨核心访问机制。','同一层的共享范围和各 SKU 实际容量分别确认，cache 与工作存储不重复相加。'),
 ('AMD：MI300X、MI325X、MI350P/X、MI355X','mi350x','计算侧局部存储和 L2，与内存侧 Infinity Cache 分层组织。','各计算裸片的 L2 总量不等同于一个统一共享 L2；显式工作存储与 cache 分开。'),
 ('AMD：MI455X','mi455x','本地 SRAM 在工作存储与 vector cache 间分配，全局 L2 位于 fabric/cache 裸片。','共享本地 SRAM 的不同配置不能重复求和；全局 L2 与本地层保持区别。'),
 ('Google：TPU v4、v5e、v5p、v6e、TPU7x','tpu_v4','片上工作存储服务矩阵与向量路径，外部 HBM 保存更大的数据集。','按各代 TensorCore 与工作存储的作用域记录，不以名称推断等效 GPU cache。'),
 ('Google：TPU 8t、8i','tpu8t','公开 Vmem 与 HBM 配置。','产品表 MB 与开发接口 MiB 分开；每核局部空间不能视作统一共享 cache。'),
 ('AWS：Inferentia1/2、Trainium1/2/3','trainium3','片上工作存储、部分和缓冲与数据搬运路径分工；各代按实际公开内容展开。','显式搬运与缓冲的容量、端口和服务引擎分别解释，不把它们标成 L2。'),
 ('昇腾：Ascend 310、910','ascend310','核内工作缓冲与芯片共享存储、CPU cache 分属不同层级。','Ascend 310 的外部内存配置未固定；不能借用具体板卡填单芯片容量。'),
 ('昇腾：Atlas 300I A2 两容量版本','atlas300ia2_32','新用户指南确认 Cache 和 HBM。','本卡的 cache 层级和容量未展开，不迁移其他 910 子型号细节。'),
 ('昇腾：950PR、950DT','ascend950pr','核内显式缓冲、全局 L2 与同封装 DRAM 分层组织。','主推内存组合可单独比较，计算档位尚未与它们配成唯一 SKU。'),
 ('Groq：第一代 GroqChip','groq_gen1','以片上 SRAM 保存工作数据，由执行计划组织数据流动。','没有本报告所比较的外部 DRAM 层；SRAM 容量、片内带宽不放入 DRAM 图。'),
 ('寒武纪：MLU590','mlu590','可取得的软件资源描述与已确认芯片事实分开记录。','缺少可固定到该芯片的主存规格时，保留未确认。')]
byid={r['id']:r for r in M}
add('| 产品范围 | 已确认的组织特点 | 比较时保留的边界 |\n|---|---|---|')
for name,rid,a,b in groups:
    r=byid[rid];add(f'| {name} | {a} {article(r)} | {b} |')
add('''各组文字只概括共同组织，组内每款的确切容量、管理语义和来源分别保存在第 10 节，不从一个型号的规格推断同组所有型号。

![36个产品的外部DRAM容量与带宽](图表/全景02_DRAM.png)

图 3。左右面板分别表示容量和带宽，使用十进制 GB、TB/s；原文 GiB 按二进制字节数换算，原始单位保存在证据中。对数坐标用于同时显示不同规模产品。采用的值是规格或明确标注的配置值，不是持续测得带宽。

外部容量与带宽是两个独立的资源条件：容量决定能同时容纳多少数据，带宽约束搬运速度。HBM 出现在训练、推理和训推兼顾的多种定位中，采用 HBM 本身不足以分类用途。Groq 的空缺属于架构不适用，Ascend 310 和 MLU590 的空缺属于当前配置或证据不足，这两种情况不作相同解释。

本清单有 30 个产品采用 HBM，L4 和 L40S 采用 GDDR6，Inferentia1 使用 DDR4。Ascend 310 已确认 LPDDR4X 接口但未固定外存配置，Groq 采用片上主存，MLU590 的主存规格尚未确认。因此，“外部 DRAM”能够覆盖大部分产品，仍需为片上主存路线保留独立位置。

图 3 为每个产品选择可定位的展示值，离散候选没有画成连续误差区间。H100 SXM 采用现行简报的 3.35 TB/s，白皮书的 3.352 TB/s 带未定版注记，MI455X 的 23.3/19.6 TB/s 则保留各自来源上下文。Ascend 910 的容量来自具体官方测试配置，950PR/DT 的内存来自主推组合；这些记录不自动保证其他字段已与它们完整配对。

容量除以带宽 C/B 可以补充描述存储本身：按标称带宽顺序流过一遍完整容量，理想情况下需要多长时间。33 个可配对主存记录的结果约为 18.5 至 160 ms；它不需要计算峰值，因此 B300、TPU 8 和 Ascend 950 的已确认主存组合也能参与。这个数值不包含访问启动、随机访问、利用率或其他流量，不能当成内存访问延迟。各产品结果列在第 5 节的补充配比表。
''')

add(f'''## 4. DRAM 与计算资源的配比

令 P 表示所选 16 位峰值，C 表示同配置 DRAM 容量，B 表示其带宽。B/P 的单位是 byte/FLOP，描述每单位峰值计算对应多少外存供数；C/P 使用 GB/(TFLOP/s)，描述计算规模对应多少存储空间。它们是配置指标，不能直接给出模型容量、延迟或利用率。

本节使用 {S['paired16']} 个可配对产品，实心 {S['strict_matrix_dense']} 个、空心 {S['conditional_pairs']} 个。明确没有外部 DRAM 的对象、缺数值或配置未固定的对象不进入散点，但在图 6 和证据表中保留。图中的斜线是等配比参考线；两款产品即使落在同一条线上，绝对资源规模也可能相差很大。

![DRAM带宽与16位算力的散点](图表/全景03_带宽与算力.png)

图 4。横轴为 16 位计算峰值，纵轴为 DRAM 带宽。相同峰值下，点越靠上代表标称外存供给越多；保持相同比值的资源同比增长沿等比线移动。空心点的计算口径尚未完全对齐，不用它们与实心点直接构造用途组均值。

![DRAM容量与16位算力的散点](图表/全景04_容量与算力.png)

图 5。横轴与图 4 相同，纵轴改为容量。两张图分别回答数据“放得下多少”和“搬得动多快”，并不重复。模型权重、训练状态、激活和 KV Cache（推理中保存的注意力键值状态）如何占用容量，还需要具体负载条件。

![全部产品的存算配比与缺失原因](图表/全景05_存算配比.png)

图 6。将两个比值展开到全体产品行，并列出未形成比值的原因。没有将 L40S 的冲突值取平均，没有用 TPU 8 的软件成本模型充当硬件峰值，也没有把 B300、Ascend 950 的最大算力与最大内存跨配置拼接。

只看 19 个采用明确矩阵 dense 值或有依据换算的产品，所选峰值从 121 到 5,033 TFLOP/s，相差约 41.6 倍；B/P 则落在约 0.00248 至 0.00775 byte/FLOP，跨度约 3.13 倍。绝对带宽随计算规模有较大的变化，但每单位峰值对应的外存供给仍有明显差异。这一范围描述本次选值；若替换为各来源的候选值，边界也可能改变。

同一子集中，C/P 约为 0.0800 至 0.256 GB/(TFLOP/s)，跨度约 3.21 倍。容量配比和带宽配比也不必同步：例如 L4 的 B/P 约 0.00248，而 C/P 约 0.198；B200 的对应值约为 0.00342 和 0.0800。两种排序反映不同资源供给，不能合并成一个“存算更均衡”的分数。[L4 取值](#panorama-l4) [B200 取值](#panorama-b200_sxm6)

在这组样本中，容量与带宽没有被计算峰值唯一决定：相同或相近计算规模附近仍存在不同的主存配置。图中相同用途颜色也分布在多个配比位置。当前证据支持讨论资源配置的范围，不支持给“训练组”或“推理组”规定一个统一存算比；产品代际、形态和共用底层架构仍是其他解释。
''')

add(f'''## 5. 设备互联端点

本节采用单设备专用互联端点的 TX + RX（发送与接收合计）标称带宽，NVLink、Infinity Fabric、ICI 等协议名称在证据中保留。只有方向和统计边界明确的 {S['endpoint_known']} 个产品进入左图；主机 PCIe、封装内裸片间带宽和服务器聚合带宽单独处理。右图仅在 16 位峰值也可固定时计算配比。

![设备互联端点及其与计算峰值的配比](图表/全景06_设备互联.png)

图 7。左侧是端点带宽，右侧是端点带宽/16 位峰值。协议编码、交换结构、链路复用和流量模式没有统一；Ascend 950 的数值包含原始链路速率口径。图中比值只表示接口预算，不能换算成跨设备归约、all-to-all（所有设备互相交换数据）或模型扩展效率。

主机接口与专用设备互联承担不同连接关系。未公开专用接口不表示没有任何多设备通信方式；公开很高的端点合计值，也不保证一条任务数据路径可以独占全部链路。H100 PCIe 的 600/900 GB/s 来源冲突，以及 AWS 部分型号方向或聚合方式不明的值，都保留在逐项证据中，不静默选成无条件单点。

还可以把设备端点带宽 D 与 DRAM 带宽 B 相除。21 个产品可以形成这一比值，所选值约为 0.134 至 1.26。D 使用收发合计，B 使用主存规格带宽，所以 D/B 表示两种接口的标称资源关系，不能直接读成“有多少比例的 HBM 数据可发给另一芯片”。Ascend 950PR 的原始端点合计与链路复用条件尤其需要保留。
''')
add('<details><summary>展开 36 个产品的补充配比：容量 / 带宽、设备互联 / DRAM</summary>')
add('| 产品 | C/B：标称容量流过时间（ms） | D/B：互联收发合计 / DRAM 带宽 |\n|---|---|---|')
for r in M:
    mem=r['memory'];e=r['endpoint'];b=mem.get('bandwidth_tb_s');c=mem.get('capacity_gb')
    cb=f'{c/b:.3g}' if c and b else ('不适用：无外部 DRAM' if mem['kind']=='none' else '未确认')
    db=f"{e['bidir_gb_s']/1000/b:.3g}" if b and e['state']=='known' and e.get('bidir_gb_s') and not e['protocol'].lower().startswith('pcie') else ('不适用：无外部 DRAM' if mem['kind']=='none' else '未配对')
    add(f'| {p_link(r)} | {cb} | {db} |')
add('取值与来源见对应产品证据。C 采用 GB、B 采用 TB/s 时，C/B 的数值恰为 ms；计算 D/B 前先将 D 的 GB/s 换成 TB/s。')
add('</details>')

add(f'''## 6. 功率规格与部署条件

功率先按板卡、模组和芯片边界分类。TDP 是热设计功耗，TBP 是整板功率；额定或最大值与某负载的平均耗电不是同一指标。所用功率规格还可能随线缆、供电、散热或软件档位改变。

![按统计边界区分的功率规格](图表/全景07_功率边界.png)

图 8。{S['power_plotted']} 个有明确数值和边界的产品分面呈现，不合并为能效排名。TPU 的机群平均功率、Groq 的平均值与最高功耗、Ascend 310 的未定边界原报值均在证据中保留；图中的 Groq 与 Ascend 910 仅取明确的芯片 TDP。B300 的功率没有与本研究容量配置绑定，MI455X、Ascend 950 等缺少对应单设备值时保持缺失。

PCIe 插卡、SXM/OAM/EAM 模组和云内芯片处于不同供电及部署约束。第一层可以展示这些预算的范围，不能用峰值除上限功率得到实测训练或推理能效，也不能从模组功率反推计算裸片功耗。所有产品的形态与冷却条件见第 1 节及逐项证据。

## 8. 全产品数值、条件与来源

每个条目保留本报告采用的值、候选或冲突以及引用位置。参考编号属于相应产品详解，点击即可定位到该篇的原始资料入口；同号不表示跨产品共用同一资料。格式矩阵中的每个状态也在这里逐格解释。

原始单位、完整候选和来源另存于[全产品绘图数据](panorama36.json)与[家族资源及来源记录](family-comparison-data.json)。图表由[全产品图表脚本](生成全产品图表.py)及[配比计算与家族绘图模块](comparison_analysis.py)生成；现有产品详解和原始资料仍是事实追溯入口。
''')
for r in M:
    c=r['compute16'];m=r['memory'];e=r['endpoint'];p=r['power'];o=r['organization'];d=r['deployment']
    add(f"<details id=\"panorama-{r['id']}\"><summary>{r['order']:02d} {html.escape(r['label'])} · {pos[r['orientation']['group']]}</summary>\n\n{article(r)}")
    add('| 项目 | 本报告采用的内容与来源 |\n|---|---|')
    add(f"| 主要设计取向 | {pos[r['orientation']['group']]}；{fact(r,r['orientation']['text'],r['orientation']['source'])} |")
    add(f"| 官方支持用途 | {fact(r,r['position']['text'],r['position']['source'])} |")
    add(f"| 16 位峰值 | {fact(r,val(c.get('value_tflops'),' TFLOP/s')+'；'+c['format']+'；'+scope_text[c['scope']]+'；'+basis_text[c['basis']]+'。'+c['note'],c['source'])} |")
    for fmt,lp in r.get('low_precision',{}).items():add(f"| {fmt} 家族峰值 | {fact(r,val(lp['value_tflops'],' TFLOP/s')+'；'+lp['format']+'。'+lp['note'],lp['source'])} |")
    if c.get('alternatives'):add(f"| 峰值候选 | {cell(alternatives(r,c['alternatives']))} |")
    memory_numbers='容量与带宽不适用' if m['kind']=='none' else val(m.get('capacity_gb'),' GB')+'；'+val(m.get('bandwidth_tb_s'),' TB/s')
    add(f"| DRAM | {fact(r,memkind(r)+'；'+memory_numbers+'。'+m['note'],m['source'])} |")
    if m.get('alternatives'):add(f"| 主存候选 / 原始单位 | {cell(alternatives(r,m['alternatives']))} |")
    add(f"| 本地组织 | {fact(r,o['onchip']+' '+o['main_memory']+' '+o['sharing'],o['source'])} |")
    add(f"| 设备端点 | {fact(r,e['protocol']+'；'+val(e.get('bidir_gb_s'),' GB/s，收发合计')+'。'+e['note'],e['source'])} |")
    add(f"| 功率 | {fact(r,val(p.get('max_w'),' W')+'；'+power_scope[p['scope']]+'。'+str(p['range_or_other'])+' '+p['note'],p['source'])} |")
    add(f"| 部署 | {fact(r,d['form']+' '+d['cooling'],d['source'])} |")
    add(f"| 存算图 | {cell(r['ratio_status'])} |")
    add('数值格式的执行范围：')
    add('| 格式 | 状态 | 执行范围、条件与来源 |\n|---|---|---|')
    for fmt,x in r['formats'].items():add(f"| {fmt} | {state[x['state']]} | {fact(r,x['detail'],x['source'])} |")
    add('</details>')

add('''本版依据当前 36 篇产品详解整理；对算力口径、容量配置、带宽方向和功率边界回查了相应规格页及关键原文，核对范围限于本报告使用的事实与条件。

旧版的局部产品对照与图表保存在[改写前版本](../../99_归档/02_主线旧流程/历史比较分析/第一层改写前-20260920/训练与推理架构比较.md)。本版第二层已整合至第 9 节，来源为相邻的《第二层产品组比较》；图与数值取自同一套记录。
''')
report='\n'.join(parts)
end=report.index('## 8. 全产品数值、条件与来源')
family_path=R/'第二层产品组比较.md'
family_text=family_path.read_text()
family_text=re.sub(r'^# [^\n]+\n', '', family_text)
report=report[:end]+supplemental_report(D)+'\n'+robustness_report(D)+'\n## 9. 家族内定位、资源与机制\n\n'+family_text+'\n'+report[end:]
report=report.replace('## 8. 全产品数值、条件与来源','## 10. 全产品数值、条件与来源')

report=re.sub(r'(?m)^(\|[^\n]*\|)\n\n(?=\|)',r'\1\n',report)
report=report.replace('–','-').replace('—','至')
(R/'训练与推理架构比较.md').write_text(report)
print('Wrote two-layer report with',len(M),'source entries')
