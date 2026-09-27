"""Source-preserving additions to the existing comparison and figure pipeline."""
from pathlib import Path
import json
import re
from comparison_analysis import COL, POS, MARK, paired, strict

ROOT = Path(__file__).resolve().parent
DATA = ROOT / 'supplement36.json'
FIGURES = ['全景10_scale-up规模与拓扑', '全景11_片上SRAM', '全景12_发布年份与存算比']


def load():
    return json.loads(DATA.read_text())


def source(product, text):
    return re.sub(r'\[(\d+),\s*([^\]]+)\]',
                  lambda m: f"[参考 {m[1]}，{m[2]}](../产品详解/{product['card']}#ref-{m[1]})", text or '')


def clean(text):
    return str(text).replace('|', ' / ').replace('\n', '<br>')


def product_link(r):
    return f"[{r['order']:02d} {r['label']}](#panorama-{r['id']})"


def mb(record):
    """Convert explicitly recorded units; never silently interpret MB as MiB."""
    return record['value'] * {'KB': 1e3, 'KiB': 2**10, 'MB': 1e6, 'MiB': 2**20}[record['unit']] / 1e6


def selected_memory(item, panel):
    records = item.get('records', [])
    if panel == 'shared':
        candidates = [x for x in records if x.get('shared') and x['kind'] in ('cache', 'shared_work')]
    else:
        candidates = [x for x in records if x['kind'] == 'local_work']
    return max(candidates, key=mb) if candidates else None


def date_rows(data, supplement):
    return [r for r in data['products'] if paired(r) and supplement['products'][r['id']]['release'].get('year')]


def counts(data, supplement):
    items = supplement['products']
    return {
        'scaleup_products': sum(bool(items[r['id']]['scaleup'].get('records')) for r in data['products']),
        'onchip_products': sum(bool(items[r['id']]['onchip'].get('records')) for r in data['products']),
        'shared_plotted': sum(selected_memory(items[r['id']]['onchip'], 'shared') is not None for r in data['products']),
        'local_plotted': sum(selected_memory(items[r['id']]['onchip'], 'local') is not None for r in data['products']),
        'dated_products': sum(bool(items[r['id']]['release'].get('year')) for r in data['products']),
        'dated_paired': len(date_rows(data, supplement)),
        'integer_numeric': sum(any(isinstance(x.get('value_tops'), (int, float)) and x.get('sku_bound', True) for x in items[r['id']]['integer'].get('records', [])) for r in data['products']),
    }


def draw(data, out, scatter_labels):
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter, NullFormatter
    s = load(); rows = data['products']; items = s['products']; figures = []

    def save(fig, name):
        for ext in ('svg', 'pdf', 'png'):
            fig.savefig(out / f'{name}.{ext}', bbox_inches='tight', pad_inches=.16, facecolor='white')
        svg=out / f'{name}.svg'
        svg.write_text(re.sub(r'[ \t]+$', '', svg.read_text(), flags=re.M))
        plt.close(fig); figures.append(name)

    def row_axes(axes):
        for ax in axes:
            ax.set_yticks(range(len(rows)), [f"{r['order']:02d} {r['short_label']}" for r in rows])
            ax.set_ylim(len(rows)-.4, -.9); ax.tick_params(axis='y', length=0)
            ax.set_xscale('log'); ax.grid(axis='x', color='#DAE3E7', linewidth=.6)
            ax.xaxis.set_major_formatter(FuncFormatter(lambda v, _: f'{v:g}'))
            ax.xaxis.set_minor_formatter(NullFormatter())
            for i, r in enumerate(rows):
                if i % 2 == 0: ax.axhspan(i-.5, i+.5, color='#F6F8F9', zorder=0)
                if i and r['vendor'] != rows[i-1]['vendor']: ax.axhline(i-.5, color='#ADBCC4', lw=.8)
            for tick, r in zip(ax.get_yticklabels(), rows): tick.set_color(COL[r['orientation']['group']])
        axes[1].tick_params(labelleft=False)

    def legend(fig, extra=()):
        handles = [Line2D([], [], marker=MARK[g], color='none', markerfacecolor=COL[g],
                          markeredgecolor=COL[g], label=POS[g]) for g in ('training', 'inference', 'both')]
        fig.legend(handles=handles+list(extra), loc='lower center', ncol=3, frameon=False, bbox_to_anchor=(.52,.003))

    fig, axes = plt.subplots(1, 2, figsize=(13.5, 16), sharey=True)
    fig.subplots_adjust(left=.22, right=.97, top=.92, bottom=.13, wspace=.22); row_axes(axes)
    for ax, kind, heading in zip(axes, ['physical_domain', 'schedulable_slice'],
                                  ['已记录的物理高速互联域', '已记录的单任务可调度上限']):
        ax.set_title(heading, loc='left', pad=18); ax.set_xlim(1.3, 60000)
        ax.set_xlabel('芯片数量 · 对数坐标')
        for i, r in enumerate(rows):
            records = [x for x in items[r['id']]['scaleup']['records'] if x['kind'] == kind]
            if not records:
                ax.text(.018, i, '未确认', transform=ax.get_yaxis_transform(), va='center', color='#74828A', fontsize=8.5)
                continue
            # All confirmed alternatives remain in the table; the chart selects
            # the largest recorded configuration, not a hardware-wide maximum.
            x = max(records, key=lambda x: x['chips']); g = r['orientation']['group']
            qualified=items[r['id']]['scaleup'].get('status')=='qualified'
            a = ax.scatter(x['chips'], i, facecolor='white' if qualified else COL[g], edgecolor=COL[g], marker=MARK[g], s=42, zorder=3)
            a.set_urls(['#supp-scaleup-'+r['id']])
            topology=x['topology']
            tag=next((t for t in ['Boardfly','3D torus','2D torus','NVSwitch','NeuronSwitch','UALoE','HCCS','全连接','桥接','未公开'] if t.lower() in topology.lower()),'')
            if 'bridge' in topology: tag='NVLink 桥接'
            elif 'Infinity Fabric' in topology: tag='IF 全互联'
            elif '3D mesh/torus' in topology: tag='3D torus + OCS'
            elif '3D ICI' in topology: tag='3D ICI'
            elif 'torus' in topology and 'ring' in topology: tag='torus + ring'
            elif '未给精确拓扑' in topology: tag='拓扑未公开'
            annotation=f"{x['chips']:,}"+(' *' if qualified else '')+(f' · {tag}' if kind=='physical_domain' and tag else '')
            ax.annotate(annotation, (x['chips'], i), xytext=(7,0), textcoords='offset points', va='center', fontsize=8)
    fig.suptitle('扩展规模与端点带宽是不同资源', x=.22, ha='left', fontsize=15)
    fig.text(.22,.082,'图中取各类最大已记录配置；系统名称及其他配置见产品详解。', fontsize=10, color='#64737B')
    fig.text(.22,.06,'* TPU 8i：1,152 连接位置与 1,024 active 的关系未明。950DT 的 8,192 规划值未画入。', fontsize=10, color='#64737B')
    legend(fig); save(fig, FIGURES[0])

    fig, axes = plt.subplots(1, 2, figsize=(15, 16), sharey=True)
    fig.subplots_adjust(left=.21,right=.975,top=.92,bottom=.14,wspace=.22); row_axes(axes)
    for ax, panel, heading in zip(axes, ['shared','local'], ['可确认全芯片共享的一层存储', '局部显式工作存储的一项容量']):
        ax.set_title(heading,loc='left',pad=18); ax.set_xlim(.015, 3000)
        ax.set_xlabel('容量（十进制 MB，对数坐标）')
        for i,r in enumerate(rows):
            x=selected_memory(items[r['id']]['onchip'], panel)
            if x is None:
                ax.text(.018,i,'未确认',transform=ax.get_yaxis_transform(),va='center',fontsize=8.5,color='#74828A');continue
            value=mb(x);g=r['orientation']['group']
            a=ax.scatter(value,i,marker=MARK[g],s=43,edgecolor=COL[g],
                         facecolor=COL[g] if x['kind']=='cache' else 'white',linewidth=1.2,zorder=3)
            a.set_urls(['#supp-onchip-'+r['id']])
            scope=x['scope'].replace('每','').replace('全芯片','chip').replace('全 GPU','GPU')
            scope = scope.split('（')[0]
            alt=[z for z in x.get('alternatives',[]) if z.get('scope') == 'chip' and x.get('shared')]
            for z in alt:
                a2=ax.scatter(mb(z),i,marker=MARK[g],s=80,facecolor='white',edgecolor=COL[g],linewidth=1.2,zorder=2)
                a2.set_urls(['#supp-onchip-'+r['id']])
            values='/'.join([f"{z['value']:g}" for z in alt]+[f"{x['value']:g}"])
            label=f"{values} {x['unit']}"
            if any(z['unit']!=x['unit'] for z in alt):
                label=' / '.join(f"{z['value']:g} {z['unit']}" for z in [x]+alt)
            text=label+f' / {scope}'+(' *' if x.get('management')=='unspecified' else '')
            left_label=panel=='shared' and len(text)>28
            ax.annotate(text,(value,i),xytext=(-7 if left_label else 7,0),ha='right' if left_label else 'left',textcoords='offset points',va='center',fontsize=8)
    fig.suptitle('片上 SRAM：保留管理方式与共享范围',x=.21,ha='left',fontsize=15)
    fig.text(.21,.093,'每侧取对应类别中最大的已确认项；不同层级的容量不相加。',fontsize=10,color='#64737B')
    fig.text(.21,.071,'实心为 cache，空心为工作存储。右侧 core、SM、CU、cluster 等作用域不等价。',fontsize=10,color='#64737B')
    fig.text(.21,.049,'标签保留原始单位；MiB 按 2^20 字节换算。* Ascend 310 buffer 的管理方式未确认。',fontsize=10,color='#64737B')
    legend(fig);save(fig,FIGURES[1])

    rr=date_rows(data,s);fig,ax=plt.subplots(figsize=(13,7.6))
    fig.subplots_adjust(left=.10,right=.96,top=.9,bottom=.15)
    coords=[(items[r['id']]['release']['year'],r['memory']['bandwidth_tb_s']/r['compute16']['value_tflops']) for r in rr]
    ax.set_xlim(min(x for x,y in coords)-.65,max(x for x,y in coords)+.65)
    ax.set_ylim(min(y for x,y in coords)/1.6,max(y for x,y in coords)*1.65);ax.set_yscale('log')
    ax.set_xticks(range(min(x for x,y in coords),max(x for x,y in coords)+1));ax.grid(color='#DAE3E7',lw=.6)
    ax.yaxis.set_major_formatter(FuncFormatter(lambda v,_:f'{v:g}'));ax.yaxis.set_minor_formatter(NullFormatter())
    for r,xy in zip(rr,coords):
        g=r['orientation']['group'];rank=coords[:rr.index(r)].count(xy);size=140 if coords.count(xy)>1 and rank==0 else 45
        a=ax.scatter(*xy,s=size,marker=MARK[g],facecolor=COL[g] if strict(r['compute16']) else 'white',edgecolor=COL[g],lw=1.2,zorder=4+rank)
        a.set_urls(['#supp-release-'+r['id']])
    scatter_labels(ax,rr,coords)
    for label in ax.texts:
        if (label.get_url() or '').startswith('#panorama-'):
            label.set_url(label.get_url().replace('#panorama-', '#supp-release-'))
    ax.set_title('发布年份与存算比',loc='left',pad=17)
    ax.set_xlabel('首次型号公开年份');ax.set_ylabel('DRAM 带宽 / 16 位峰值（byte/FLOP）')
    legend(fig,[Line2D([],[],marker='o',color='none',markerfacecolor='white',markeredgecolor='#64737B',label='参考值')]);save(fig,FIGURES[2])
    draw_integer(data, out)
    return figures


def reports(data):
    s=load();items=s['products'];n=counts(data,s);out={}
    text=['### 2.1 INT8 / INT4 峰值与执行条件',
          'INT8、INT4 分别表示 8 位和 4 位整数。TOPS 为每秒万亿次运算；矩阵、向量与厂商整芯片口径分别列出。支持某格式不保证已公开该格式峰值。下表保留原值、稀疏条件及推导说明，不从位宽或浮点峰值反推缺失项。',
          f"36 个产品均有记录，其中 {n['integer_numeric']} 个有可列出的 TOPS 数值；这些记录仍可能带配置或执行限制，不能视为同条件排名。",
          '| 产品 | INT8 峰值及路径 | INT4 峰值及路径 | 执行、输入与累加条件；来源 |','|---|---|---|---|']
    for r in data['products']:
        item=items[r['id']]['integer'];cells=[];conditions=[]
        for fmt in ['INT8','INT4']:
            entries=[x for x in item.get('records',[]) if x['format']==fmt];v=[]
            for x in entries:
                value=x.get('value_tops')
                path={'matrix':'矩阵','matrix/Cube':'矩阵 / Cube','vector':'向量','vector/scalar':'向量 / 标量','chip':'整芯片','chip/Cube+Vector':'整芯片 / Cube+Vector','card':'板卡','unknown':'路径未确认'}.get(x.get('path'),x.get('path','未确认'))
                density={'dense':'稠密','sparse':'稀疏','unspecified':'稠密条件未明'}.get(x.get('density'),x.get('density','未说明'))
                prefix='其他配置参考：' if x.get('sku_bound') is False else ('有条件记录：' if x.get('comparison_eligible') is False and value is not None else '')
                v.append(prefix+(f'{value:g} TOPS' if isinstance(value,(int,float)) else '峰值未确认')+'；'+path+'；'+density)
                detail='；'.join(str(x.get(k,'')) for k in ['execution','input','accumulation','basis','derivation','condition'] if x.get(k))
                detail=detail.replace('native','原生').replace('converted','转换执行').replace('unknown','未确认').replace('source','原文值').replace('derived','推导值')
                conditions.append(fmt+'：'+detail+' '+source(r,x.get('source','')))
            cells.append('<br>'.join(v) or '未确认')
        if item.get('note'):conditions.append(item['note'])
        if item.get('source'):conditions.append(source(r,item['source']))
        text.append(f"| <span id=\"supp-integer-{r['id']}\"></span>{product_link(r)} | {clean(cells[0])} | {clean(cells[1])} | {clean('<br>'.join(conditions))} |")
    out['integer']='\n\n'.join(text[:3])+'\n\n'+'\n'.join(text[3:])+'\n'

    text=['### 3.1 片上 SRAM 的容量、管理方式与共享范围',
          f"{n['onchip_products']} 个产品有至少一层可引用的片上存储容量；图中左、右面板分别呈现 {n['shared_plotted']}、{n['local_plotted']} 个产品。左侧只取确认可在全芯片范围共同访问的一层存储，右侧取一项局部显式工作存储。各自选最大的已记录项用于阅读，完整层次和候选在表中保留；分布式物理 bank 并不因此成为单块 SRAM。",
          f'![片上 SRAM 容量与组织](图表/{FIGURES[1]}.png)',
          '图 3b。坐标统一为十进制 MB，原文 MiB 按字节数换算，数据标签保留原单位。各 core、SM、CU、cluster 的服务范围不同，容量只能连同层级和管理方式读取。没有确认共享容量的产品不以局部 SRAM 求和补点；没有数值也不表示没有该层硬件。',
          'TPU 8t/8i 的技术文章 MB 与开发接口 MiB 是两个来源视图；图按已确认记录展示，表保留两端。AMD 的每 XCD L2 与全 GPU Infinity Cache 分开，不能把多个 XCD 的 L2 合计改名为统一共享 L2。Ascend 310 的 buffer 与 LLC 也分别保留，buffer 名称本身不足以证明软件显式管理。',
          '<details><summary>展开 36 个产品的片上存储层次、原始单位与来源</summary>','',
          '| 产品 | 原始容量与作用域 | 管理、共享与合计条件；来源 |','|---|---|---|']
    for r in data['products']:
        item=items[r['id']]['onchip'];a=[];b=[]
        for x in item['records']:
            a.append(f"{x['name']}：{x['value']:g} {x['unit']} / {x['scope']}")
            total=''
            if x.get('instances') and x['instances']>1:
                total=f"；{x['instances']} 份名义合计 {x['value']*x['instances']:g} {x['unit']}，不改变单份可访问容量"
            role={'cache':'硬件管理 cache','shared_work':'共享工作存储','local_work':'核内或局部显式工作存储','partial_sum':'部分和存储'}[x['kind']]
            if x.get('management')=='unspecified':role='buffer，管理方式未确认'
            sharing='全芯片共享' if x.get('shared') else '仅在所列局部范围访问'
            b.append(x['name']+'：'+role+'；'+sharing+'；'+x.get('condition','')+total+' '+source(r,x.get('source',''))+' '+source(r,x.get('instance_source','')))
            for alt in x.get('alternatives',[]):
                b.append(f"同资源另一来源/档位：{alt['value']:g} {alt['unit']} / {alt['scope']}；{alt.get('note','')} {source(r,alt['source'])}")
        if item.get('note'):b.append(item['note'])
        if item.get('source'):b.append(source(r,item['source']))
        text.append(f"| <span id=\"supp-onchip-{r['id']}\"></span>{product_link(r)} | {clean('<br>'.join(a) or '未确认')} | {clean('<br>'.join(b))} |")
    text.append('\n</details>');out['onchip']='\n\n'.join(text[:5])+'\n\n'+'\n'.join(text[5:])+'\n'

    text=['### 5.1 scale-up 域规模与系统拓扑',
          f"scale-up 指设备间专用高速互联。{n['scaleup_products']} 个产品有可记录的域规模或任务配置，但两种数量对应不同边界：物理域描述连通的硬件组织，可调度上限描述服务允许单个任务申请的配置。图中分别取各类最大已记录值，不解释为芯片的绝对扩展上限。",
          f'![scale-up 规模与拓扑](图表/{FIGURES[0]}.png)',
          '图 7b。服务器装卡数、Pod 物理总数、任务 slice 和跨域集群不能互换。缺项不补一，也不将 PCIe 主机连接当专用高速域。域内拓扑及其他已确认配置见下表；规模不能替代消息时延、二分带宽或通信效率。',
          '<details><summary>展开 36 个产品的域规模、系统配置、拓扑与来源</summary>','',
          '| 产品 | 物理高速域 | 单任务配置 | 拓扑、系统与边界；来源 |','|---|---|---|---|']
    for r in data['products']:
        item=items[r['id']]['scaleup'];cells=[];notes=[]
        for kind in ['physical_domain','schedulable_slice']:
            cells.append('；'.join(f"{x['chips']:,}（{x['system']}）" for x in item['records'] if x['kind']==kind) or '未确认')
        for x in item['records']:
            notes.append(f"{x['system']}，{x['topology']}；{x['condition']} {source(r,x['source'])}")
        for x in item.get('planned_records',[]):
            notes.append(f"规划配置（不入图）：{x['chips']:,}，{x['system']}，{x['topology']}；{x['condition']} {source(r,x['source'])}")
        if item.get('note'):notes.append(item['note'])
        if item.get('source'):notes.append(source(r,item['source']))
        text.append(f"| <span id=\"supp-scaleup-{r['id']}\"></span>{product_link(r)} | {clean(cells[0])} | {clean(cells[1])} | {clean('<br>'.join(notes))} |")
    text.append('\n</details>');out['scaleup']='\n\n'.join(text[:4])+'\n\n'+'\n'.join(text[4:])+'\n'

    rr=date_rows(data,s)
    text=['### 8.1 发布年份与代际混杂',
          f"{n['dated_products']} 个产品有可定位的型号公开年份，其中 {len(rr)} 个还能与现有 16 位峰值、主存配置配对。首次公开、正式发布与 GA（正式可用）分别记录；数据表或论文的印刷日期不自动视为产品发布日。",
          f'![发布年份与存算比](图表/{FIGURES[2]}.png)',
          '图 12。横轴采用已查官方资料中的首次型号公开年，纵轴沿用本报告统一的 16 位峰值和主存规格。因此，点表示一个型号后来可确认的配置，不代表其预告当年即可取得这些规格。若早期预告属于另一容量版本，按本次具体配置确认的日期选值，并保留预告差异。',
          '这张图提供时间背景，不能替代同代、同厂商的产品对照。年份相同不意味着制程、发布时间、部署约束或数值路径相同；不同年份的存算比变化，也可能来自计算分母、外存升级或型号构成变化。当前样本不适合拟合行业年度趋势或据此作训练/推理因果判断。',
          '<details><summary>展开 36 个产品的首次公开、正式发布与可用时间</summary>','',
          '| 产品 | 采用的首次公开日期 | 正式发布／可用时间 | 日期边界与来源 |','|---|---|---|---|']
    for r in data['products']:
        x=items[r['id']]['release']
        text.append(f"| <span id=\"supp-release-{r['id']}\"></span>{product_link(r)} | {x.get('date') or '未确认'} | {x.get('availability') or '未确认'} | {clean(x['note']+' '+source(r,x['source']))} |")
    text.append('\n</details>');out['release']='\n\n'.join(text[:5])+'\n\n'+'\n'.join(text[5:])+'\n'
    return out


def draw_integer(data, out):
    """A readable summary, while keeping all source records in supplement36.json.

    Prefer explicitly dense matrix values. Keep published whole-chip/card and
    unspecified-density figures visibly conditional. Software-model figures,
    unit conflicts and other-SKU figures are never substituted for product peaks.
    """
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter, NullFormatter
    rows=data['products']; items=load()['products']
    model_only={('tpu_v5p','INT8'),('tpu8t','INT8'),('tpu_v5e','INT4'),
                ('tpu_v5p','INT4'),('tpu_v6e','INT4'),('tpu8t','INT4')}
    label_missing={('h200_sxm5','INT8'):'原文单位有疑问',('h200_nvl','INT8'):'原文单位有疑问',
                   ('tpu_v4','INT8'):'原文单位有疑问',('b300_sxm6','INT8'):'288GB 配置未确认',
                   ('l40s','INT4'):'来源数值有疑问',('trainium2','INT8'):'转为 FP32 执行',
                   ('trainium3','INT8'):'转为 FP32 执行'}
    def pick(product, fmt):
        if (product['id'],fmt) in model_only:return []
        candidates=[x for x in items[product['id']]['integer']['records']
                    if x['format']==fmt and x.get('sku_bound',True)
                    and x.get('comparison_eligible',True) and x.get('value_tops') is not None
                    and x['path'] not in ('vector','vector/scalar','chip/Cube+Vector')]
        dense=[x for x in candidates if x['density']=='dense']
        return dense or candidates
    fig,axes=plt.subplots(1,2,figsize=(15,16),sharey=True)
    fig.subplots_adjust(left=.19,right=.97,top=.92,bottom=.145,wspace=.18)
    plotted={}
    for ax,fmt in zip(axes,['INT8','INT4']):
        ax.set_yticks(range(36),[f"{r['order']:02d} {r['short_label']}" for r in rows])
        ax.set_ylim(35.6,-.8);ax.tick_params(axis='y',length=0)
        ax.set_xscale('log');ax.set_xlim(10,25000);ax.set_xticks([10,100,1000,10000])
        ax.xaxis.set_major_formatter(FuncFormatter(lambda v,_:f'{v:,.0f}'))
        ax.xaxis.set_minor_formatter(NullFormatter());ax.grid(axis='x',color='#DAE3E7',lw=.6)
        ax.set_title(fmt+' 公开峰值',loc='left',pad=16);ax.set_xlabel('TOPS（每秒万亿次整数运算，对数坐标）')
        plotted[fmt]=0
        for i,r in enumerate(rows):
            if i%2==0:ax.axhspan(i-.5,i+.5,color='#F6F8F9',zorder=0)
            if i and r['vendor']!=rows[i-1]['vendor']:ax.axhline(i-.5,color='#ADBCC4',lw=.8)
            selected=pick(r,fmt);g=r['orientation']['group']
            if not selected:
                msg='仅有软件估算值' if (r['id'],fmt) in model_only else label_missing.get((r['id'],fmt),'未确认峰值')
                ax.text(.018,i,msg,transform=ax.get_yaxis_transform(),va='center',fontsize=8,color='#74828A');continue
            plotted[fmt]+=1
            selected=sorted(selected,key=lambda x:x['value_tops'])
            for x in selected:
                sparse=x['density']=='sparse'
                solid=x['density']=='dense' and x['path']=='matrix'
                a=ax.scatter(x['value_tops'],i,s=44,marker='^' if sparse else 'o',
                    facecolor=COL[g] if solid or sparse else 'white',edgecolor=COL[g],linewidth=1.2,zorder=3)
                a.set_urls(['../../产品详解/'+r['card']])
            x=selected[-1];value=x['value_tops']
            scope={'matrix':'矩阵','matrix/Cube':'矩阵','chip':'整芯片','card':'整卡'}[x['path']]
            vals=' / '.join(f"{z['value_tops']:,.5g}" for z in selected)
            tag='稀疏' if x['density']=='sparse' else scope
            if len(selected)>1:tag+=f'，{len(selected)} 档'
            ax.annotate(vals+' · '+tag,(value,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=8)
        for tick,r in zip(ax.get_yticklabels(),rows):tick.set_color(COL[r['orientation']['group']])
    axes[1].tick_params(labelleft=False)
    fig.suptitle('整数峰值：INT8 与 INT4 分开看',x=.19,ha='left',fontsize=15)
    fig.text(.19,.10,'有稠密值时采用稠密值；稀疏值、整芯片值与未说明稀疏条件的值另作标记。',fontsize=10,color='#64737B')
    fig.text(.19,.078,'空缺表示未找到可采用的产品峰值。软件开发模型中的数值不代替产品规格。',fontsize=10,color='#64737B')
    fig.text(.19,.056,'950 的多个点对应不同 Cube 档位；未将 Vector 吞吐相加，也未与内存档位绑定。',fontsize=10,color='#64737B')
    handles=[Line2D([],[],marker='o',color='none',markerfacecolor='#387991',markeredgecolor='#387991',label='明确稠密矩阵'),
             Line2D([],[],marker='o',color='none',markerfacecolor='white',markeredgecolor='#387991',label='未说明稠密条件或整芯片 / 整卡'),
             Line2D([],[],marker='^',color='none',markerfacecolor='#387991',markeredgecolor='#387991',label='原文仅列稀疏值')]
    fig.legend(handles=handles,loc='lower center',ncol=3,frameon=False,bbox_to_anchor=(.55,.005))
    name='全景13_整数峰值'
    for ext in ('svg','pdf','png'):fig.savefig(out/f'{name}.{ext}',bbox_inches='tight',pad_inches=.16,facecolor='white')
    svg=out/f'{name}.svg';svg.write_text(re.sub(r'[ \t]+$','',svg.read_text(),flags=re.M))
    plt.close(fig)
    return plotted


if __name__ == '__main__':
    import os
    os.environ.setdefault('MPLCONFIGDIR','/private/tmp/chip-mpl-cache')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib import font_manager
    for font in ['/System/Library/Fonts/Supplemental/Arial.ttf','/System/Library/Fonts/STHeiti Medium.ttc']:
        if Path(font).exists():font_manager.fontManager.addfont(font)
    cjk=font_manager.FontProperties(fname='/System/Library/Fonts/STHeiti Medium.ttc').get_name()
    plt.rcParams.update({'font.family':['Arial',cjk],'font.size':10,'axes.titlesize':13,
                        'figure.dpi':140,'savefig.dpi':220,'pdf.fonttype':42,
                        'svg.fonttype':'none','axes.spines.top':False,'axes.spines.right':False})
    print(draw_integer(json.loads((ROOT/'panorama36.json').read_text()),ROOT/'图表'))
