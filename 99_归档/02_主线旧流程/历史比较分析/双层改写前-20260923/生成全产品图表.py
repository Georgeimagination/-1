"""Render the first-layer comparison from panorama36.json (Matplotlib + NumPy).

Rebuild this file's SVG/PDF/PNG figures before running 产品详解/生成阅读版.mjs.
Numbers and conditions are preserved in the adjacent, source-backed chart data.
"""
from pathlib import Path
import os, json, math
os.environ.setdefault('MPLCONFIGDIR', '/private/tmp/chip-mpl-cache')
os.environ.setdefault('XDG_CACHE_HOME', '/private/tmp/chip-font-cache')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter, NullFormatter
import numpy as np

R = Path(__file__).resolve().parent
O = R / '图表'; O.mkdir(exist_ok=True)
D = json.loads((R / 'panorama36.json').read_text())
M = D['products']
for font in ['/System/Library/Fonts/Supplemental/Arial.ttf', '/System/Library/Fonts/STHeiti Medium.ttc']:
    if Path(font).exists(): font_manager.fontManager.addfont(font)
cjk = font_manager.FontProperties(fname='/System/Library/Fonts/STHeiti Medium.ttc').get_name()
plt.rcParams.update({'font.family':['Arial', cjk], 'font.size':11, 'axes.labelsize':11,
    'axes.titlesize':13, 'xtick.labelsize':10, 'ytick.labelsize':10, 'legend.fontsize':10,
    'axes.linewidth':.7, 'lines.linewidth':1.1, 'figure.dpi':140, 'savefig.dpi':220,
    'pdf.fonttype':42, 'ps.fonttype':42, 'svg.fonttype':'none', 'axes.unicode_minus':False,
    'axes.spines.top':False, 'axes.spines.right':False, 'axes.axisbelow':True})
COL = {'training':'#B64945', 'inference':'#218378', 'both':'#387991', 'unclear':'#77838C'}
POS = {'training':'训练定位', 'inference':'推理定位', 'both':'训推均有资料', 'unclear':'定位未明确'}
MARK = {'training':'^', 'inference':'v', 'both':'o', 'unclear':'s'}
GRAY='#64737B'; INK='#243A44'
FIGS=[]

def color(r): return COL[r['position']['group']]
def label(r): return f"{r['order']:02d}  {r['label']}"
def save(fig, name):
    for ext in ['svg','pdf','png']:
        fig.savefig(O/f'{name}.{ext}', bbox_inches='tight', pad_inches=.16, facecolor='white')
    FIGS.append(name); plt.close(fig)
def title(ax, text, xlabel=None):
    ax.set_title(text, loc='left', pad=16, color=INK)
    if xlabel: ax.set_xlabel(xlabel, labelpad=10)
    ax.tick_params(length=3, width=.7)
def row_axis(ax, rows=M):
    ax.set_yticks(range(len(rows)), [label(r) for r in rows])
    ax.set_ylim(len(rows)-.45,-.9);ax.tick_params(axis='y',length=0,pad=9)
    for i,r in enumerate(rows):
        if i%2==0: ax.axhspan(i-.5,i+.5,color='#F6F8F9',zorder=0)
        if i and r['vendor']!=rows[i-1]['vendor']:ax.axhline(i-.5,color='#ADBCC4',lw=.8,zorder=1)
    for tick,r in zip(ax.get_yticklabels(),rows):tick.set_color(color(r))
def pos_legend(fig, extra=None):
    handles=[Line2D([],[],marker=MARK[k],color='none',markerfacecolor=v,markeredgecolor=v,
        markersize=7,label=POS[k]) for k,v in COL.items() if any(r['position']['group']==k for r in M)]
    fig.legend(handles=handles+(extra or []),loc='lower center',ncol=3,frameon=False,bbox_to_anchor=(.53,.008))
def evidence_link(artist,r):
    url='#panorama-'+r['id']
    if hasattr(artist,'set_urls'):artist.set_urls([url])
    else:artist.set_url(url)
def numeric(v):return isinstance(v,(int,float)) and v>0
def compatible(r):
    c=r['compute16'];m=r['memory']
    return numeric(c.get('value_tflops')) and c['basis']!='excluded' and numeric(m.get('capacity_gb')) and numeric(m.get('bandwidth_tb_s'))
def strict(r):
    c=r['compute16'];return c['scope']=='matrix' and c['basis'] in ['dense','derived_dense']
Q=[r for r in M if compatible(r)]
J=[r for r in M if r['endpoint']['state']=='known' and numeric(r['endpoint'].get('bidir_gb_s')) and not r['endpoint']['protocol'].lower().startswith('pcie')]

# Numerical formats: a categorical support matrix, not a throughput heat map.
formats=['FP64','FP32','TF32','BF16','FP16','FP8','FP4','INT8','INT4']
state={'yes':('o','#387991','运算路径支持'),'conditional':('s','#637D38','转换等条件下执行'),
       'unknown':('$?$','#9AA5AC','资料未确认'),'conflict':('D','#AB5678','来源或配置有分歧'),'no':('x','#283E48','明确无原生支持')}
f,ax=plt.subplots(figsize=(12,15.7));f.subplots_adjust(left=.28,right=.97,top=.93,bottom=.09)
row_axis(ax);ax.set_xlim(-.6,len(formats)-.4);ax.set_xticks(range(len(formats)),formats);ax.xaxis.tick_top()
ax.tick_params(axis='x',length=0,pad=12);ax.spines[['left','bottom']].set_visible(False)
for j in np.arange(-.5,len(formats),1):ax.axvline(j,color='#E3EAED',lw=.6)
for i,r in enumerate(M):
    for j,fmt in enumerate(formats):
        s=r['formats'][fmt]['state'];marker,c,_=state[s]
        a=ax.scatter(j,i,marker=marker,s=53 if s!='unknown' else 38,c=c,linewidths=1,zorder=3)
        evidence_link(a,r)
ax.set_title('36 个产品的数值格式支持',loc='left',pad=43)
f.legend(handles=[Line2D([],[],marker=v[0],color='none',markerfacecolor=v[1],markeredgecolor=v[1],markersize=7,label=v[2]) for v in state.values()],
    loc='lower center',ncol=3,frameon=False,bbox_to_anchor=(.53,.035))
f.text(.28,.014,'支持表示有运算路径；位宽、累加精度及稀疏条件仍需逐项区分。编号对应正文证据表。',fontsize=9,color=GRAY)
save(f,'全景01_数值格式')

# Absolute compute is separate from DRAM: SRAM-only products remain visible here.
f,ax=plt.subplots(figsize=(12,15.2));f.subplots_adjust(left=.28,right=.93,top=.94,bottom=.09)
row_axis(ax);ax.set_xscale('log');ax.set_xlim(3,18000);ax.grid(axis='x',color='#DAE3E7',lw=.6)
ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
title(ax,'16 位公开计算峰值：保留路径和推导条件','TFLOP/s · 对数坐标')
for i,r in enumerate(M):
    c=r['compute16'];v=c.get('value_tflops')
    if numeric(v) and c['basis']!='excluded':
        a=ax.scatter(v,i,s=42,marker=MARK[r['position']['group']],facecolor=color(r) if strict(r) else 'white',edgecolor=color(r),linewidth=1.1,zorder=4);evidence_link(a,r)
        tag=' · 推导' if c['basis']=='derived_dense' else (' · 条件项' if not strict(r) else '')
        ax.annotate(f"{v:.5g} · {c['format']}{tag}",(v,i),xytext=(8,0),textcoords='offset points',va='center',fontsize=8.7)
    else:ax.text(.015,i,r.get('ratio_status','峰值未确定'),transform=ax.get_yaxis_transform(),va='center',fontsize=9,color=GRAY)
pos_legend(f);save(f,'全景02_16位峰值')

# External DRAM: two measurements from each same-source/product memory record.
f,aa=plt.subplots(1,2,figsize=(12,15.6),sharey=True);f.subplots_adjust(left=.28,right=.98,top=.94,bottom=.09,wspace=.2)
for ax,field,ttl,lim in zip(aa,['capacity_gb','bandwidth_tb_s'],['外部 DRAM 容量','外部 DRAM 带宽'],[(3,700),(.02,40)]):
    row_axis(ax);ax.set_xscale('log');ax.set_xlim(*lim);ax.grid(axis='x',color='#DAE3E7',lw=.6)
    title(ax,ttl,'GB · 对数坐标' if field=='capacity_gb' else 'TB/s · 对数坐标')
    ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
    for i,r in enumerate(M):
        val=r['memory'].get(field)
        if numeric(val):
            a=ax.scatter(val,i,s=39,marker=MARK[r['position']['group']],color=color(r),edgecolor='white',linewidth=.4,zorder=3);evidence_link(a,r)
            ax.annotate(f'{val:.4g}',(val,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=9,color=INK)
        else:ax.text(.025,i,'不适用：片上主存' if r['id']=='groq_gen1' else '未确认',transform=ax.get_yaxis_transform(),va='center',fontsize=9,color=GRAY)
aa[1].tick_params(labelleft=False);pos_legend(f)
save(f,'全景02_DRAM')

def scatter_labels(ax, rows, coords):
    """Greedy label placement in screen space; leaders never alter point values."""
    fig=ax.figure;fig.canvas.draw();renderer=fig.canvas.get_renderer();box=ax.get_window_extent()
    occupied=[];points=[ax.transData.transform(xy) for xy in coords]
    for r,xy,point in zip(rows,coords,points):
        name=r.get('short_label',r['label']); candidates=[]
        # Short, numbered labels link unambiguously to the full 36-product table.
        text=f"{r['order']:02d} {name}"
        probe=ax.text(0,0,text,fontsize=8.5);bb=probe.get_window_extent(renderer);probe.remove();w,h=bb.width+7,bb.height+3
        for radius in [13,26,42,63,88,115]:
            for ang in [0,180,45,135,-45,-135,90,-90]:
                rad=math.radians(ang);dx=radius*math.cos(rad);dy=radius*math.sin(rad)
                x=point[0]+dx-(w if dx<0 else 0);y=point[1]+dy-h/2
                b=(x,y,x+w,y+h)
                outside=max(0,box.x0+3-x)+max(0,b[2]-box.x1+22)+max(0,box.y0+3-y)+max(0,b[3]-box.y1+3)
                overlap=sum(max(0,min(b[2],o[2])-max(b[0],o[0]))*max(0,min(b[3],o[3])-max(b[1],o[1])) for o in occupied)
                touches=sum(200 for pt in points if b[0]-3<pt[0]<b[2]+3 and b[1]-3<pt[1]<b[3]+3)
                candidates.append((outside*10000+overlap*20+touches+radius*.6,b,dx,dy))
        _,b,dx,dy=min(candidates,key=lambda v:v[0]);occupied.append(b)
        t=ax.annotate(text,xy,xytext=(dx*72/fig.dpi,dy*72/fig.dpi),textcoords='offset points',ha='right' if dx<0 else 'left',va='center',fontsize=8.5,
            color=INK,bbox=dict(boxstyle='square,pad=.12',fc='white',ec='none',alpha=.9),arrowprops=dict(arrowstyle='-',lw=.45,color='#AAB7BE',shrinkA=3,shrinkB=5))
        evidence_link(t,r)

def scatter_plot(name, yfield, ylabel, ratio_levels, ratio_unit):
    f,ax=plt.subplots(figsize=(12,8.2));f.subplots_adjust(left=.095,right=.965,top=.9,bottom=.27)
    ax.set_xscale('log');ax.set_yscale('log');ax.set_xlim(40,1e4)
    ys=[r['memory'][yfield] for r in Q];ax.set_ylim(min(ys)/2.0,max(ys)*2.3)
    title(ax,f'16 位计算峰值与{ylabel.split("（")[0]}：{len(Q)} 个可配对产品','公开 16 位峰值（TFLOP/s，对数坐标）')
    ax.set_ylabel(ylabel+'，对数坐标');ax.grid(which='major',color='#E1E8EB',lw=.6)
    ax.xaxis.set_major_formatter(FuncFormatter(lambda v,p:f'{v:g}'));ax.yaxis.set_major_formatter(FuncFormatter(lambda v,p:f'{v:g}'))
    xx=np.logspace(math.log10(ax.get_xlim()[0]),math.log10(ax.get_xlim()[1]),100)
    for ratio in ratio_levels:
        yy=xx*ratio;ax.plot(xx,yy,color='#A5B1B8',lw=.65,ls=(0,(4,4)),zorder=0)
        valid=np.where((yy>ax.get_ylim()[0]*1.13)&(yy<ax.get_ylim()[1]/1.25))[0]
        if len(valid):
            k=valid[-1];ax.text(xx[k]*.99,yy[k],f'{ratio:g} {ratio_unit}',ha='right',va='bottom',fontsize=8,color='#74858E',rotation=0)
    coords=[(r['compute16']['value_tflops'],r['memory'][yfield]) for r in Q]
    for k,(r,xy) in enumerate(zip(Q,coords)):
        # Keep coincident observations at their true coordinates. Nested markers
        # expose both symbols; separate labels retain both source links.
        count=coords.count(xy);rank=coords[:k].count(xy)
        size=150 if count>1 and rank==0 else (31 if count>1 else 65)
        a=ax.scatter(*xy,s=size,marker=MARK[r['position']['group']],facecolor=color(r) if strict(r) else 'white',edgecolor=color(r),linewidth=1.2,zorder=4+rank);evidence_link(a,r)
    scatter_labels(ax,Q,coords)
    pos_legend(f,[Line2D([],[],marker='o',color='none',markerfacecolor='white',markeredgecolor=GRAY,label='空心：路径或稠密条件未完全对齐')])
    f.text(.1,.145,'实心：明确的矩阵 dense 值或有依据的换算；空心保留整芯片值或条件未展开的厂商值。',fontsize=10,color=GRAY)
    f.text(.1,.116,'重合点用嵌套符号表示，坐标未作偏移。颜色表示资料覆盖用途，累加精度尚未统一。',fontsize=10,color=GRAY)
    save(f,name)

scatter_plot('全景03_带宽与算力','bandwidth_tb_s','DRAM 带宽（TB/s）',[.001,.01,.1],'byte/FLOP')
scatter_plot('全景04_容量与算力','capacity_gb','DRAM 容量（GB）',[.01,.1,1,10],'GB/(TFLOP/s)')

# Ratios retain every product row, making missingness and exclusions visible.
f,aa=plt.subplots(1,2,figsize=(12,15.6),sharey=True);f.subplots_adjust(left=.28,right=.98,top=.94,bottom=.09,wspace=.28)
for ax,mode in zip(aa,['bandwidth','capacity']):
    row_axis(ax);ax.set_xscale('log');ax.grid(axis='x',color='#DAE3E7',lw=.6)
    ax.set_xlim((.0005,.017) if mode=='bandwidth' else (.02,.6));ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
    ax.xaxis.set_minor_formatter(NullFormatter())
    ax.set_xticks([.0005,.001,.002,.005,.01] if mode=='bandwidth' else [.02,.05,.1,.2,.5])
    title(ax,'DRAM 带宽 / 16 位峰值' if mode=='bandwidth' else 'DRAM 容量 / 16 位峰值','byte/FLOP' if mode=='bandwidth' else 'GB / (TFLOP/s)')
    for i,r in enumerate(M):
        if compatible(r):
            v=r['memory']['bandwidth_tb_s' if mode=='bandwidth' else 'capacity_gb']/r['compute16']['value_tflops']
            a=ax.scatter(v,i,s=38,marker=MARK[r['position']['group']],facecolor=color(r) if strict(r) else 'white',edgecolor=color(r),linewidth=1);evidence_link(a,r)
            ax.annotate(f'{v:.3g}',(v,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=9)
        else:ax.text(.015,i,r.get('ratio_status','未配对'),transform=ax.get_yaxis_transform(),va='center',fontsize=8.5,color=GRAY)
aa[1].tick_params(labelleft=False);pos_legend(f);save(f,'全景05_存算配比')

# Dedicated endpoint bandwidth: conflicts/unknown directions and host PCIe stay out.
f,ee=plt.subplots(1,2,figsize=(12,15.2),sharey=True);f.subplots_adjust(left=.28,right=.98,top=.94,bottom=.09,wspace=.25)
ax=ee[0];row_axis(ax);ax.set_xscale('log');ax.set_xlim(200,8000);ax.grid(axis='x',color='#DAE3E7',lw=.6)
ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
ax.xaxis.set_minor_formatter(NullFormatter());ax.set_xticks([200,500,1000,2000,5000])
title(ax,'单设备专用互联端点','GB/s，TX + RX · 对数坐标')
for i,r in enumerate(M):
    e=r['endpoint']
    if r in J:
        a=ax.scatter(e['bidir_gb_s'],i,s=42,color=color(r),marker=MARK[r['position']['group']],zorder=4);evidence_link(a,r)
        ax.annotate(f"{e['bidir_gb_s']:g}",(e['bidir_gb_s'],i),xytext=(8,0),textcoords='offset points',va='center',fontsize=9)
    else:
        s='主机 PCIe 单列' if e['protocol'].lower().startswith('pcie') else {'none':'未配置该类端点','conflict':'冲突 / 条件未对齐','unknown':'方向或数值未确认'}.get(e['state'],'不进入此图')
        ax.text(.015,i,s,transform=ax.get_yaxis_transform(),va='center',fontsize=8.5,color=GRAY)
ax=ee[1];row_axis(ax);ax.tick_params(labelleft=False);ax.set_xscale('log');ax.set_xlim(.0002,.007)
ax.grid(axis='x',color='#DAE3E7',lw=.6);ax.xaxis.set_major_formatter(FuncFormatter(lambda x,p:f'{x:g}'))
ax.xaxis.set_minor_formatter(NullFormatter());ax.set_xticks([.0002,.0005,.001,.002,.005])
title(ax,'端点带宽 / 16 位峰值','byte/FLOP · 对数坐标')
for i,r in enumerate(M):
    c=r['compute16']
    if r in J and numeric(c.get('value_tflops')) and c['basis']!='excluded':
        v=r['endpoint']['bidir_gb_s']/c['value_tflops']/1000
        a=ax.scatter(v,i,s=40,marker=MARK[r['position']['group']],facecolor=color(r) if strict(r) else 'white',edgecolor=color(r),linewidth=1);evidence_link(a,r)
        ax.annotate(f'{v:.3g}',(v,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=9)
    else:ax.text(.015,i,'未配对',transform=ax.get_yaxis_transform(),va='center',fontsize=8.5,color=GRAY)
pos_legend(f);save(f,'全景06_设备互联')

# Power is faceted by measurement boundary rather than presented as efficiency.
P=[r for r in M if numeric(r['power'].get('max_w')) and r['power']['scope'] in ['board_max','module_max','chip_tdp']]
f,aa=plt.subplots(1,3,figsize=(12,6.7));f.subplots_adjust(left=.16,right=.97,top=.88,bottom=.17,wspace=.70)
for ax,scope,ttl in zip(aa,['board_max','module_max','chip_tdp'],['板卡上限','模组上限','芯片 TDP']):
    rows=[r for r in P if r['power']['scope']==scope]
    title(ax,ttl,'W');ax.set_xlim(0,1600);ax.grid(axis='x',color='#DAE3E7',lw=.6)
    ax.set_yticks(range(len(rows)),[r.get('short_label',r['label']) for r in rows]);ax.set_ylim(len(rows)-.4,-.8);ax.tick_params(axis='y',length=0,labelsize=9)
    for i,r in enumerate(rows):
        v=r['power']['max_w'];a=ax.scatter(v,i,s=45,color=color(r),marker=MARK[r['position']['group']]);evidence_link(a,r)
        ax.annotate(f'{v:g}',(v,i),xytext=(7,0),textcoords='offset points',va='center',fontsize=9)
f.suptitle('供电与散热预算按统计边界分别读取',fontsize=14,x=.16,ha='left')
f.text(.16,.07,'仅列明确数值。机群平均功率、工作负载实测和边界不明的值留在证据表，不与功率上限混用。',fontsize=9,color=GRAY)
pos_legend(f)
save(f,'全景07_功率边界')

stats={'products':len(M),'paired16':len(Q),'strict_matrix_dense':sum(strict(r) for r in Q),
       'conditional_pairs':sum(not strict(r) for r in Q),'dram_capacity':sum(numeric(r['memory'].get('capacity_gb')) for r in M),
       'dram_bandwidth':sum(numeric(r['memory'].get('bandwidth_tb_s')) for r in M),
       'endpoint_known':len(J),'power_plotted':len(P),'positions':{k:sum(r['position']['group']==k for r in M) for k in COL},
       'paired_ids':[r['id'] for r in Q], 'strict_ids':[r['id'] for r in Q if strict(r)],
       'figures':FIGS}
(R/'panorama-stats.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2))
(R/'figures.json').write_text(json.dumps(FIGS,ensure_ascii=False,indent=2))
print(json.dumps(stats,ensure_ascii=False,indent=2))
