"""Derived comparisons from the reviewed product records; no source fetching."""
from statistics import median
from math import log10
import re

COL = {'training':'#B64945','inference':'#218378','both':'#387991','unclear':'#77838C'}
POS = {'training':'偏训练','inference':'偏推理','both':'训推兼顾','unclear':'未明确'}
MARK = {'training':'^','inference':'v','both':'o','unclear':'s'}

def strict(c):
    return c.get('scope') == 'matrix' and c.get('basis') in ('dense','derived_dense')

def paired(r):
    return bool(r['compute16'].get('value_tflops') and r['compute16']['basis'] != 'excluded'
                and r['memory'].get('bandwidth_tb_s') and r['memory'].get('capacity_gb'))

def family(r):
    i=r['id']
    for prefix,f in [('h100','Hopper'),('h200','Hopper'),('l4','Ada'),('b200','Blackwell'),('b300','Blackwell'),
                     ('mi300','CDNA3'),('mi325','CDNA3'),('mi350','CDNA4'),('mi355','CDNA4'),
                     ('tpu_v5','TPU5'),('tpu8','TPU8'),('atlas','Atlas300IA2'),('ascend950','Ascend950')]:
        if i.startswith(prefix):return r['vendor']+'/'+f
    if i in ('trainium1','inferentia2'):return 'AWS/NCv2'
    return r['vendor']+'/'+i

def analyze(data):
    rows=[r for r in data['products'] if paired(r)]
    scenarios=[]
    for name,subset,alternate,balance in [
        ('全部可配对规格（含条件项）',rows,False,False),
        ('仅明确矩阵 dense 或有依据换算',[r for r in rows if strict(r['compute16'])],False,False),
        ('采用有来源的替代分类',rows,True,False),
        ('先按家族及取向取中位数',rows,False,True)]:
        result={'name':name,'groups':{}}
        for group in POS:
            selected=[r for r in subset if (r['orientation'].get('alternative_group',r['orientation']['group']) if alternate else r['orientation']['group'])==group]
            values={k:[] for k in ('bp','cp')}
            buckets={}
            for r in selected:
                p=r['compute16']['value_tflops'];m=r['memory']
                buckets.setdefault(family(r),[]).append((m['bandwidth_tb_s']/p,m['capacity_gb']/p))
            for k,index in [('bp',0),('cp',1)]:
                values[k]=([median(v[index] for v in b) for b in buckets.values()] if balance else
                           [v[index] for b in buckets.values() for v in b])
            result['groups'][group]={'n':len(selected),'families':len(buckets),
                **{k:median(v) if v else None for k,v in values.items()}}
        scenarios.append(result)
    vendor=[]
    for v in dict.fromkeys(r['vendor'] for r in rows):
        item={'vendor':v}
        for g in POS:
            rr=[r for r in rows if r['vendor']==v and r['orientation']['group']==g]
            item[g]={'n':len(rr),'bp':[r['memory']['bandwidth_tb_s']/r['compute16']['value_tflops'] for r in rr]}
        vendor.append(item)
    return {'scenarios':scenarios,'vendors':vendor}

def draw_extra(data,out):
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter, NullFormatter
    rows=data['products'];figs=[]
    def save(fig,name):
        for ext in ('svg','pdf','png'):fig.savefig(out/f'{name}.{ext}',bbox_inches='tight',pad_inches=.16,facecolor='white')
        plt.close(fig);figs.append(name)
    def link(a,r):a.set_urls(['#panorama-'+r['id']])
    def legend(fig):
        h=[Line2D([],[],marker=MARK[g],color='none',markerfacecolor=COL[g],markeredgecolor=COL[g],label=POS[g]) for g in ('training','inference','both')]
        h.append(Line2D([],[],marker='o',color='none',markerfacecolor='white',markeredgecolor='#64737B',label='空心：执行或规格条件项'))
        fig.legend(handles=h,loc='lower center',ncol=4,frameon=False,bbox_to_anchor=(.5,.008))
    for fmt in ('FP8','FP4'):
        rr=[r for r in rows if r.get('low_precision',{}).get(fmt)]
        if not rr:continue
        fig,axes=plt.subplots(1,2,figsize=(12,max(6,len(rr)*.40+2)),sharey=True)
        fig.subplots_adjust(left=.26,right=.97,top=.88,bottom=.20,wspace=.25)
        for j,ax in enumerate(axes):
            ax.set_xscale('log');ax.grid(axis='x',color='#DFE7EB',lw=.6)
            ax.set_yticks(range(len(rr)),[f"{r['order']:02d} {r['label']}" for r in rr]);ax.set_ylim(len(rr)-.4,-.8)
            ax.tick_params(axis='y',length=0);ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
            ax.xaxis.set_minor_formatter(NullFormatter())
            ax.set_title('公开矩阵峰值' if j==0 else 'DRAM 带宽 / 对应峰值',loc='left',pad=15)
            ax.set_xlabel('TFLOP/s · 对数坐标' if j==0 else 'byte/FLOP · 对数坐标')
            vv=[]
            for i,r in enumerate(rr):
                c=r['low_precision'][fmt];p=c['value_tflops'];b=r['memory'].get('bandwidth_tb_s')
                v=p if j==0 else (b/p if b else None)
                if v is None:continue
                vv.append(v);g=r['orientation']['group']
                is_strict=strict(c) and c.get('execution') not in ('emulated','converted')
                a=ax.scatter(v,i,s=46,marker=MARK[g],facecolor=COL[g] if is_strict else 'white',edgecolor=COL[g],zorder=3);link(a,r)
                tag='*' if not is_strict else ''
                label=(f'{v:,.1f}'.rstrip('0').rstrip('.') if j==0 else f'{v:.4g}')+tag
                ax.annotate(label,(v,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=9)
            if vv:
                lo,hi=min(vv)/1.65,max(vv)*3.5
                ax.set_xlim(lo,hi)
                if j==1:ax.set_xticks([x for x in [.0001,.0002,.0005,.001,.002,.005,.01,.02] if lo<=x<=hi])
        axes[1].tick_params(labelleft=False)
        fig.suptitle(f'{fmt} 家族：{len(rr)} 个可列规格的产品',x=.26,ha='left',fontsize=14)
        note=('FP8 与 MXFP8 分别保留格式；v5p 为模拟条件。软件模型与未绑定配置不进入本图。' if fmt=='FP8' else
              'MXFP4、转换输入与原文 FP4 标签不视为相同数值行为；TPU 8 保留精度来源分歧。')
        fig.text(.26,.09,note,fontsize=9,color='#64737B');legend(fig)
        save(fig,f'全景08_{fmt}峰值与配比')
    rr=[r for r in rows if paired(r)];vendors=list(dict.fromkeys(r['vendor'] for r in rr))
    fig,ax=plt.subplots(figsize=(12,9));fig.subplots_adjust(left=.13,right=.96,top=.89,bottom=.21)
    ax.set_xscale('log');ax.set_xlim(.0005,.012);ax.grid(axis='x',color='#DFE7EB',lw=.6)
    ax.set_yticks([3*i+1 for i in range(len(vendors))],vendors);ax.set_ylim(3*len(vendors)-.1,-1)
    for i in range(len(vendors)-1):ax.axhline(3*i+2.7,color='#DFE7EB',lw=.6)
    ax.set_xlabel('DRAM 带宽 / 16 位峰值（byte/FLOP，对数坐标）')
    ax.set_title('同厂商中观察取向差异：数字为产品编号',loc='left',pad=15)
    ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
    ax.xaxis.set_minor_formatter(NullFormatter())
    ax.set_xticks([.0005,.001,.002,.005,.01])
    offsets={'training':0,'both':1,'inference':2,'unclear':2.4}
    for v in vendors:
        for g in POS:
            group=[r for r in rr if r['vendor']==v and r['orientation']['group']==g]
            ordered=sorted(group,key=lambda x:x['memory']['bandwidth_tb_s']/x['compute16']['value_tflops'])
            xs=[r['memory']['bandwidth_tb_s']/r['compute16']['value_tflops'] for r in ordered]
            for i,r in enumerate(ordered):
                x=xs[i];y=3*vendors.index(v)+offsets[g]
                a=ax.scatter(x,y,s=54,marker=MARK[g],facecolor=COL[g] if strict(r['compute16']) else 'white',edgecolor=COL[g]);link(a,r)
                dx=-10 if i+1<len(xs) and abs(log10(xs[i+1]/x))<.055 else (10 if i and abs(log10(x/xs[i-1]))<.055 else 0)
                ax.annotate(f"{r['order']:02d}",(x,y),xytext=(dx,13),textcoords='offset points',ha='center',fontsize=8,
                            arrowprops={'arrowstyle':'-','color':COL[g],'lw':.55} if dx else None)
    fig.text(.13,.095,'同一家族多个 SKU 仍分别显示；家族等权与分类变化的结果见正文，未进行独立随机样本的显著性检验。',fontsize=9,color='#64737B')
    legend(fig);save(fig,'全景09_同厂商取向与配比')
    return figs

def source(r,s):
    return re.sub(r'\[(\d+),\s*([^\]]+)\]',lambda m:f"[参考 {m[1]}，{m[2]}](../产品详解/{r['card']}#ref-{m[1]})",s or '')

def supplemental_report(data):
    rows=data['products'];lines=[]
    def add(s):lines.append(s)
    add('## 7. 低精度、主机接口与功率配比\n')
    add('低位宽格式另设坐标，不与 16 位峰值拼成算力排名。MX 表示一组元素共享缩放信息的 microscaling 格式；相同位宽不代表相同动态范围、累加行为或执行路径。下图使用同一产品的已确认主存配置，空心点保留原文尚未展开的条件。\n')
    for fmt in ('FP8','FP4'):
        add(f'![{fmt}峰值与主存供给](图表/全景08_{fmt}峰值与配比.png)\n')
    add('FP8 和 FP4 能力跨越多种定位。TPU v5p 的官方规格列 459 TFLOP/s，但 Google 的 Ironwood 发布文将旧代 FP8 描述为 emulated（模拟实现），故不标成原生 FP8；Trainium3 的 MXFP4 输入先映射为 MXFP8 后计算，峰值没有因输入位宽减半而翻倍。TPU 8 的技术文章与发布规格图存在 FP4/FP8 标签分歧，仍保留为条件项。下表逐行给出来源。\n')
    add('<details><summary>低精度选值、与 16 位的比值及执行条件</summary>\n\n| 产品 | FP8 家族 TFLOP/s | FP4 家族 TFLOP/s | 相对 16 位公开峰值 | 条件与来源 |\n|---|---:|---:|---|---|')
    for r in rows:
        lp=r.get('low_precision',{});a=lp.get('FP8');b=lp.get('FP4')
        if not a and not b:continue
        c=r['compute16'];p=c.get('value_tflops');rat=[];notes=[]
        for fmt,v in [('FP8',a),('FP4',b)]:
            if not v:continue
            if p and c['basis']!='excluded' and r['id']!='mi350x':rat.append(f"{fmt}/16位={v['value_tflops']/p:.3g}")
            notes.append(f"{v['format']}：{v['note']} "+source(r,v['source']))
        if r['id']=='mi350x':rat=['16位不同来源有冲突，暂不派生']
        add(f"| [{r['label']}](#panorama-{r['id']}) | {a['value_tflops'] if a else '未确认'} | {b['value_tflops'] if b else '未确认'} | {'；'.join(rat) or '16位未配对'} | {'<br>'.join(notes).replace('|','/')} |")
    add('\n比值是表内规格的算术比较；含模拟、转换或厂商条件项的行不解释为原生矩阵阵列加速倍数，也不比较算法精度质量。\n</details>\n')
    add('<details><summary>配置未配对的规格与软件性能模型</summary>\n\n| 产品 | 保留记录 | 条件与来源 |\n|---|---|---|')
    for r in rows:
        for item in r.get('supplementary_compute',[]):
            value=(f"{item.get('format','')} {item.get('value_tflops','')} TFLOP/s" if 'value_tflops' in item else '；'.join(f'{k}={v}' for k,v in item.items() if k not in ('note','source','eligible_main','basis','scope')))
            add(f"| {r['label']} | {value} | {item['note']} {source(r,item['source'])} |")
    add('\n软件模型是开发工具使用的估计，不作为厂商峰值，也不替代缺失硬件参数。\n</details>\n')
    add('<details><summary>36 个产品的稀疏条件与主机接口</summary>\n\n| 产品 | 稀疏相关事实 | 主机接口 |\n|---|---|---|')
    for r in rows:
        x=r.get('supplements',{})
        add(f"| [{r['label']}](#panorama-{r['id']}) | {x.get('sparse_text','未确认')} {source(r,x.get('sparse_source',''))} | {x.get('host_text','未确认')} {source(r,x.get('host_source',''))} |")
    add('\n未确认不表示不存在。SparseCore 的不规则访问与结构化稀疏矩阵模式分别记录；主机接口的标称值不作为持续测量值。\n</details>\n')
    add('<details><summary>同一 SKU 的 16 位峰值／功率规格</summary>\n\n| 产品 | 功率边界 | TFLOP/s/W | 条件与来源 |\n|---|---|---:|---|')
    scopes={'board_max':'板卡上限','module_max':'模组上限','chip_tdp':'芯片TDP'}
    for r in rows:
        c=r['compute16'];p=r['power']
        if c.get('value_tflops') and c['basis']!='excluded' and p.get('max_w') and p['scope'] in scopes:
            add(f"| {r['label']} | {scopes[p['scope']]} | {c['value_tflops']/p['max_w']:.4g} | {c['format']}；{'明确矩阵口径' if strict(c) else '计算条件项'}。{source(r,c['source'])} {source(r,p['source'])} |")
    add('\n不同功率边界分别读取。这是额定资源预算的比值，峰值计算与功率上限并非同一次负载测量，不能据此宣称实际能效。\n</details>\n')
    return '\n'.join(lines)

def robustness_report(data):
    a=analyze(data);out=['## 8. 取向差异是否跨家族重复\n',
        '![同厂商中的取向与存算配比](图表/全景09_同厂商取向与配比.png)\n',
        '下表只作描述性敏感性检查，不把这批有选择的产品当作随机独立样本。第一、二行检查计算条件的影响；第三行将 TPU v5e、Trillium、Ironwood 和 H200 NVL 改归训推兼顾，将 Trainium2/3 按早期发布表述列偏训练，并将 H100 PCIe 改归偏推理；第四行先在同一家族、同一取向内取中位数，再汇总，降低型号数量不均的影响。\n',
        '| 数据选择 | 偏训练：产品/家族数；B/P；C/P | 偏推理：产品/家族数；B/P；C/P | 训推兼顾：产品/家族数；B/P；C/P |',
        '|---|---|---|---|']
    for s in a['scenarios']:
        vals=[]
        for g in ('training','inference','both'):
            v=s['groups'][g]
            vals.append(f"{v['n']}/{v['families']}；{v['bp']:.4g}；{v['cp']:.4g}" if v['n'] else '无可配对值')
        out.append('| '+s['name']+' | '+' | '.join(vals)+' |')
    out.append('\nB/P 使用 byte/FLOP，C/P 使用 GB/(TFLOP/s)，表内为各方案的中位数。家族归组及派生过程保存在绘图脚本中。只保留明确矩阵口径后，偏训练组仅剩 TPU v4 与 Trainium1 两个家族。改变分类不能补足缺失的同代对照，因此这里不做显著性或因果判断。\n')
    out.append('当前数据不支持“偏推理产品普遍拥有更高 DRAM 带宽／算力”的统一规律。AWS 的 Trainium1 与 Inferentia2 在所选同口径计算和 HBM 配置上重合；同为推理卡的 Atlas 两容量版本则有不同 B/P。NVIDIA、AMD 的多个参照产品同时面向训推，不能把它们全部当成训练组。图中仍能看到局部资源倾斜，但其含义要回到下一节的家族内官方说明。\n')
    out.append('绝对规模也没有给出单一用途分界。偏训练组已确认的 DRAM 带宽跨 0.880 至 6.528 TB/s，偏推理组跨 0.0537 至 8.601 TB/s，范围明显交叉；大规模资源还集中在多款训推兼顾的 GPU。BF16、FP8 和 FP4 均在不同取向中出现，格式可用性与低精度吞吐倍率须分别读取。设备互联方面，AWS 的接口数量对照与 TPU 8 的等端点带宽、异拓扑对照也指向不同的分化方式，尚不能得到跨家族统一的 D/P 阈值。\n')
    out.append('功率与 P/W 的用途比较则主要受证据覆盖限制：偏训练组目前只有 Ascend 910 的芯片 TDP 可以画入，而偏推理组可画的多数是整板功率；兼顾组又以模组为主。云端芯片缺少同边界额定值，不能把这份功率分布解释成训练与推理设计的一般差异。主机接口、稀疏机制和存储组织的补充表用于说明实现条件，公开接口上限或支持状态尚不足以推导实际吞吐。\n')
    out.append('C/P 与 B/P 也不是独立的多份证据：C/P = (C/B) × (B/P)。部分比值升高是分母计算峰值降低，部分来自内存增容，只有同时查看绝对资源与机制，才能区分这些原因。产品分类依据与数值证据在最后一节逐项列出。\n')
    return '\n'.join(out)

def draw_family(data,out,family_path):
    """Use common selected SKU values; supplement only local mechanisms from group evidence."""
    import json
    import matplotlib.pyplot as plt
    from matplotlib.lines import Line2D
    from matplotlib.ticker import FuncFormatter, NullFormatter
    if not family_path.exists():return []
    evidence=json.loads(family_path.read_text());groups={g['group']:g for g in evidence['groups']}
    rows={r['id']:r for r in data['products']};charts=[];figs=[]
    def common(ids):
        metrics=[]
        for name,unit,field,key in [('16 位矩阵峰值','TFLOP/s','compute16','value_tflops'),('HBM 容量','GB','memory','capacity_gb'),('HBM 带宽','TB/s','memory','bandwidth_tb_s'),('功率上限','W','power','max_w')]:
            values={i:rows[i][field].get(key) for i in ids}
            if all(values.values()):metrics.append({'name':name,'unit':unit,'values':values,'sources':{i:rows[i][field]['source'] for i in ids},'condition':'使用 panorama36.json 中同一 SKU 的选定值；功率为各自模组或板卡边界的上限。'})
        return metrics
    if 'A01' in groups:
        charts.append({'group':'A01','name':'家族01_TPU8资源变化','title':'TPU 8i 相对 8t：局部存储增加最明显','baseline':'tpu8t','products':['tpu8i'],
                       'resources':groups['A01']['resources'],
                       'note':'整芯片产品表；Vmem 非统一共享 cache。FP4 保留来源标签冲突；带宽均为标称值。'})
    if 'A06' in groups:
        ids=['mi350x','mi350p','mi355x'];resources=common(ids)
        local=[m for m in groups['A06']['resources'] if m['name'] in ('使能 CU','最高引擎时钟','每 CU LDS')]
        resources=local[:1]+resources[:1]+local[1:]+resources[1:]
        charts.append({'group':'A06','name':'家族02_MI350资源变化','title':'MI350 家族：规模减半与功率档位调整','baseline':'mi350x','products':['mi350p','mi355x'],
                       'resources':resources,'note':'MI350X 选网页 2,300；MI355X 选简报 2,516.6 TFLOP/s。P 为 PCIe 卡，X 为 OAM 模组。'})
    if 'A07' in groups:
        ids=['h200_sxm5','h200_nvl'];resources=common(ids)
        resources.insert(3,{'name':'NVLink 收发合计','unit':'GB/s','values':{i:rows[i]['endpoint']['bidir_gb_s'] for i in ids},'sources':{i:rows[i]['endpoint']['source'] for i in ids},'condition':'相同标称端点预算不表示相同连接域或拓扑。'})
        charts.append({'group':'A07','name':'家族03_H200资源变化','title':'H200 NVL 相对 SXM：内存容量相同，计算峰值较低','baseline':'h200_sxm5','products':['h200_nvl'],
                       'resources':resources,'note':'NVL 4.813 与 SXM 4.8 TB/s 按各简报保留；1.003× 不解读为已测得的带宽优势。'})
    for ch in charts:
        rr=ch['resources'];base=ch['baseline'];targets=ch['products']
        fig,ax=plt.subplots(figsize=(11.5,max(6.5,len(rr)*.70+2)));fig.subplots_adjust(left=.28,right=.97,top=.85,bottom=.25)
        ax.set_xscale('log');ax.set_xlim(.35,4.7 if ch['group']=='A01' else 1.9)
        ax.set_xticks([.5,1,2,3] if ch['group']=='A01' else [.5,.75,1,1.5]);ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}×'));ax.xaxis.set_minor_formatter(NullFormatter())
        ax.set_yticks(range(len(rr)),[f"{r['name']}\n（{'个' if r['unit']=='count' else r['unit']}）" for r in rr]);ax.set_ylim(len(rr)-.4,-.6)
        ax.tick_params(axis='y',length=0);ax.axvline(1,color='#7A8B95',ls='--',lw=1);ax.grid(axis='x',color='#DFE7EB',lw=.6)
        handles=[]
        for j,t in enumerate(targets):
            r=rows[t];c=COL[r['orientation']['group']];marker=['o','s'][j]
            handles.append(Line2D([],[],color=c,marker=marker,lw=1,label=r['label']))
            for k,m in enumerate(rr):
                ratio=m['values'][t]/m['values'][base];y=k+(j-(len(targets)-1)/2)*.28
                ax.plot([1,ratio],[y,y],color=c,lw=1.5)
                a=ax.scatter(ratio,y,s=57,marker=marker,color=c,zorder=3);a.set_urls(['#panorama-'+t])
                ax.annotate(f'{ratio:.3f}×',(ratio,y),xytext=(9,0),textcoords='offset points',va='center',fontsize=10,bbox={'facecolor':'white','edgecolor':'none','pad':1.2,'alpha':.94})
        ax.set_xlabel(f"以 {rows[base]['label']} 的对应资源为 1（对数坐标）",labelpad=12)
        fig.suptitle(ch['title'],x=.28,ha='left',fontsize=14)
        fig.text(.12,.10,ch['note'],fontsize=9,color='#64737B')
        fig.legend(handles=handles,loc='lower center',ncol=len(handles),frameon=False,bbox_to_anchor=(.55,.012))
        for ext in ('svg','pdf','png'):fig.savefig(out/f"{ch['name']}.{ext}",bbox_inches='tight',pad_inches=.16,facecolor='white')
        plt.close(fig);figs.append(ch['name'])
    evidence['charts']=charts
    family_path.write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n')
    return figs
