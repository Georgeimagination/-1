"""Rebuild publication-style comparison figures from the adjacent evidence data.
Requires matplotlib and numpy. All plots use published specs, not measured speedups.
"""
from pathlib import Path
import json, os
os.environ.setdefault('MPLCONFIGDIR','/tmp/chip-mpl-cache')
os.environ.setdefault('XDG_CACHE_HOME','/tmp/chip-font-cache')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import font_manager
from matplotlib.ticker import MaxNLocator,FuncFormatter
from matplotlib.lines import Line2D
R=Path(__file__).resolve().parent; O=R/'图表';O.mkdir(exist_ok=True)
D=json.loads((R/'chart_data.json').read_text())
for p in [Path('/System/Library/Fonts/Supplemental/Arial.ttf'),Path('/Library/Fonts/Arial.ttf')]:
 if p.exists():font_manager.fontManager.addfont(str(p))
plt.rcParams.update({'font.family':'Arial','font.size':9,'axes.labelsize':9,'axes.titlesize':10,'xtick.labelsize':8,'ytick.labelsize':8,'legend.fontsize':8,'axes.linewidth':.7,'lines.linewidth':1.4,'figure.dpi':160,'savefig.dpi':240,'pdf.fonttype':42,'ps.fonttype':42,'svg.fonttype':'none','axes.spines.top':False,'axes.spines.right':False,'axes.axisbelow':True,'hatch.linewidth':.65})
B='#387991'; P='#AB5678'; G='#637D38'; GREY='#929AA2';COL=[B,P,G]
files=[]
def setup(ax,title,y=None):
 ax.set_title(title,loc='left',fontweight='bold',pad=12)
 if y:ax.set_ylabel(y)
 ax.grid(axis='y',color='#d9dee2',linewidth=.5)
 ax.tick_params(direction='out',length=3,width=.7)
def save(fig,name):
 for ext in ['svg','pdf','png']:fig.savefig(O/f'{name}.{ext}',bbox_inches='tight',pad_inches=.09,facecolor='white')
 files.append(name);plt.close(fig)
def bars(ax,labels,series,colors=COL,annot=True,rotation=0):
 x=np.arange(len(labels)); w=.76/len(series)
 for i,(name,vals) in enumerate(series.items()):
  vals=np.array([np.nan if v is None else v for v in vals],dtype=float)
  b=ax.bar(x+(i-(len(series)-1)/2)*w,vals,w*.92,label=name,color=colors[i%len(colors)],edgecolor='#24343d',linewidth=.55,hatch=['','///','..'][i%3])
  if annot:ax.bar_label(b,labels=['' if np.isnan(v) else (f'{v:g}' if v>=10 else f'{v:.3g}') for v in vals],padding=3,fontsize=7.5)
 ax.set_xticks(x,labels,rotation=rotation,ha='right' if rotation else 'center');ax.margins(y=.2)
 if len(series)>1:ax.legend(frameon=False,loc='upper left',bbox_to_anchor=(0,1.02),ncol=min(3,len(series)))
 return x
# 1: same-engine comparison and size normalization.
f,aa=plt.subplots(1,2,figsize=(9.2,3.05),layout='constrained')
a=D['compute']['aws'];setup(aa[0],'(a) Shared NeuronCore-v2','FP32 peak (TFLOPS/core)');bars(aa[0],a['labels'],{k:a[k] for k in ['Trainium1','Inferentia2']});aa[0].set_ylim(0,31)
a=D['compute']['amd'];setup(aa[1],'(b) CDNA 4 product scaling','Ratio to MI350P');bars(aa[1],['CU\ncount','Matrix\ncores','FP16\nmatrix','FP16\nvector'],{'MI350P':np.ones(4),'MI350X':np.array(a['MI350X'])/a['MI350P']});aa[1].set_ylim(0,2.75);aa[1].axhline(1,color='#5a6570',ls='--',lw=.8)
save(f,'01_compute')
# 2: precision gains and sparse headline are separate, no fabricated unknowns.
f,aa=plt.subplots(1,2,figsize=(9.2,3.25),layout='constrained')
a=D['numeric'];setup(aa[0],'(a) Precision-dependent theoretical throughput','Ratio to own FP16/BF16 peak');labels=list(a['rows']);s={a['labels'][j]:[v[j]/v[0] if v[j] is not None else None for v in a['rows'].values()] for j in range(3)};bars(aa[0],labels,s);aa[0].set_ylim(0,5.5);aa[0].text(.255,.16,'N/D',ha='center',transform=aa[0].transData,fontsize=7,color='#555');aa[0].axhline(1,color=GREY,lw=.8,ls='--')
a=D['sparse'];setup(aa[1],'(b) Structured-sparse FP16/BF16 peak','Ratio to own dense peak');bars(aa[1],a['labels'],{'Dense':[1]*3,'2:4 sparse':np.array(a['sparse'])/a['dense']});aa[1].set_ylim(0,2.9);aa[1].axhline(1,color=GREY,lw=.8,ls='--');save(f,'02_numeric')
# 3: three memory scopes deliberately use separate axes and exact source units.
f,aa=plt.subplots(1,3,figsize=(9.2,3.1),layout='constrained')
a=D['onchip']['aws'];setup(aa[0],'(a) AWS local work memories',a['unit']);bars(aa[0],['Trn1','Inf2','Trn2','Trn3'],{k:a[k] for k in ['SBUF','PSUM']});aa[0].set_ylim(0,44)
a=D['onchip']['tpu'];setup(aa[1],'(b) TPU Vmem',a['unit']);bars(aa[1],a['labels'],{'Vmem':a['Vmem']});aa[1].set_ylim(0,490)
a=D['onchip']['amd'];setup(aa[2],'(c) Separate AMD cache levels',a['unit']);bars(aa[2],a['labels'],{'L2 total*':a['L2_total'],'Infinity Cache':a['Infinity_Cache']});aa[2].set_ylim(0,355);f.supxlabel('* L2 total = XCD count x 4 MB; cache levels shown separately.',fontsize=8);save(f,'03_onchip')
# 4: all 36 rows, source alternatives are discrete observations, never error bars.
memfile=R/'memory36.json'
if memfile.exists():
 M=json.loads(memfile.read_text());M=M['products'] if isinstance(M,dict) else M
 f,aa=plt.subplots(1,2,figsize=(9.2,11.3),sharey=True,layout='constrained');ys=np.arange(len(M));labels=[r['label'] for r in M]
 for ax,col,title,color,xlim in zip(aa,['capacity_GB','bandwidth_TBs'],['(a) Local external-DRAM capacity (GB)','(b) Local external-DRAM bandwidth (TB/s)'],[B,P],[(4,700),(.025,40)]):
  setup(ax,title);ax.set_xscale('log');ax.set_xlim(*xlim);ax.set_ylim(len(M)-.3,-.8);ax.grid(False);ax.grid(axis='x',which='major',color='#d9dee2',lw=.5)
  for y,r in enumerate(M):
   vals=r.get(col);vals=[] if vals is None else vals if isinstance(vals,list) else [vals]
   vals=sorted(set(vals))
   if vals:
    for j,v in enumerate(vals):ax.scatter(v,y,s=24,marker='o' if len(vals)==1 else 'D',facecolor=color if len(vals)==1 else 'white',edgecolor=color,zorder=3,linewidth=.9)
    ax.text(xlim[1]*.93,y,' / '.join(f'{v:.4g}' for v in vals),ha='right',va='center',fontsize=6.5,color='#3e4850',bbox={'facecolor':'white','edgecolor':'none','pad':.25})
   else:ax.text(.02,y,'N/A (SRAM-based)' if r['kind']=='none' else 'N/D',transform=ax.get_yaxis_transform(),va='center',fontsize=7,color='#727b83')
   if y and r['vendor']!=M[y-1]['vendor']:ax.axhline(y-.5,color='#aab3ba',lw=.8)
  ax.set_yticks(ys,labels);ax.tick_params(axis='y',length=0,labelsize=8);ax.set_xlabel('Log scale; decimal units after conversion')
 aa[1].tick_params(labelleft=False)
 f.legend(handles=[Line2D([0],[0],marker='o',color='none',markerfacecolor=B,markeredgecolor=B,label='Single listed value'),Line2D([0],[0],marker='D',color='none',markerfacecolor='white',markeredgecolor=B,label='Multiple source/configuration values')],loc='outside lower center',ncol=2,frameon=False)
 save(f,'04_dram_36')
# Resource balance within the matched eighth-generation TPU family.
a=D['balance'];f,ax=plt.subplots(figsize=(9.2,2.65),layout='constrained')
setup(ax,'TPU 8i resource allocation relative to TPU 8t','Ratio to TPU 8t')
bars(ax,a['labels'],{'TPU 8t':np.ones(4),'TPU 8i':np.array(a['TPU 8i'])/a['TPU 8t']})
ax.axhline(1,color=GREY,lw=.8,ls='--');ax.set_ylim(0,3.85);f.supxlabel('* Conditional on the technical article FP4 table; the 8i launch graphic labels FP8.',fontsize=8);save(f,'04b_resource_balance')
# 5: physical die types and external DRAM modules are not added together.
a=D['package'];f,aa=plt.subplots(1,2,figsize=(9.2,3.75),layout='constrained');x=np.arange(len(a['labels']));base=np.zeros(len(x))
setup(aa[0],'(a) Functional logic dies per package','Die count (excluding dummy dies)')
for k,c,label in [('compute',B,'Compute'),('io',GREY,'I/O'),('fcd',P,'Fabric/cache')]:
 aa[0].bar(x,a[k],bottom=base,color=c,edgecolor='#33434c',linewidth=.5,width=.65,label=label);base+=np.array(a[k])
for xx,v in zip(x,base):aa[0].text(xx,v+.2,str(int(v)),ha='center',fontsize=7)
aa[0].set_xticks(x,a['labels'],rotation=55,ha='right');aa[0].set_ylim(0,17);aa[0].legend(frameon=False,ncol=3,loc='upper left');aa[0].yaxis.set_major_locator(MaxNLocator(integer=True))
setup(aa[1],'(b) Co-packaged DRAM modules','HBM stacks / DRAM modules');bars(aa[1],a['labels'],{'DRAM modules':a['dram_modules']},[P],rotation=55);aa[1].text(4,.25,'N/D',ha='center',fontsize=7);aa[1].set_ylim(0,15);aa[1].yaxis.set_major_locator(MaxNLocator(integer=True));save(f,'05_package')
# 6: endpoint direction known; protocols and port-count units kept separate.
f,aa=plt.subplots(1,3,figsize=(9.2,3.5),layout='constrained')
for ax,k,title in zip(aa,['nvidia','amd','aws'],['(a) NVIDIA NVLink endpoint','(b) AMD GPU-link endpoint','(c) Shared NCv2, different links']):
 a=D['interconnect'][k];setup(ax,title,'Link groups/chip' if k=='aws' else 'GB/s, TX + RX');bars(ax,a['labels'],{'Published':a['values']},[B if k!='aws' else P],rotation=55 if k!='aws' else 0);ax.margins(y=.22)
 if k=='aws':ax.yaxis.set_major_locator(MaxNLocator(integer=True))
save(f,'06_interconnect')
# 7: audited support matrix, missing disclosure never encoded as absence.
control=R/'control.json'
if control.exists():
 C=json.loads(control.read_text()); rows=C['products'];cols=C['columns'];f,ax=plt.subplots(figsize=(9.2,3.4),layout='constrained')
 setup(ax,'Published mechanisms (not a score or measured QoS)');ax.grid(False)
 states={'yes':('o',B),'no':('x','#393f44'),'unknown':('$?$',GREY),'conflict':('D',P)}
 for i,r in enumerate(rows):
  for j,c in enumerate(cols):
   v=r['states'][c];v=v['state'] if isinstance(v,dict) else v;m,color=states[v];ax.scatter(j,i,marker=m,s=65,color=color,linewidths=1.1)
 ax.set_xticks(range(len(cols)),['Hardware\npartitioning*','SR-IOV','Main-memory\nECC','Failed page/row\nhandling','Link/datapath\nerror protection']);ax.set_yticks(range(len(rows)),[r['label'] for r in rows]);ax.set_xlim(-.5,len(cols)-.5);ax.set_ylim(len(rows)-.5,-.5);ax.tick_params(length=0);ax.spines[['left','bottom']].set_visible(False)
 for i in np.arange(-.5,len(rows),1):ax.axhline(i,color='#e4e7e9',lw=.5)
 ax.legend(handles=[Line2D([0],[0],marker=m,color='none',markeredgecolor=c,markerfacecolor=c,markersize=6,label=l)for (s,(m,c)),l in zip(states.items(),['Documented','Explicitly unsupported','Not established','Source disagreement'])],loc='upper center',bbox_to_anchor=(.5,-.17),ncol=4,frameon=False);f.supxlabel('* L4/L40S: MIG unsupported. GroqChip ECC protects SRAM; other rows cover HBM/GDDR.',fontsize=8);save(f,'07_control')
# 8: power semantics use separate subplots; no peak/W efficiency ranking.
f,aa=plt.subplots(2,2,figsize=(9.2,5.8),layout='constrained')
for ax,k,title in zip(aa.flat,['nvidia','amd','tpu','groq'],['(a) NVIDIA PCIe: maximum board power','(b) AMD: published peak/maximum TBP','(c) TPU: fleet mean, host excluded','(d) GroqChip: three different power definitions']):
 a=D['power'][k];setup(ax,title,'Power (W)');bars(ax,a['labels'],{'Published':a['values']},[B if k in ['nvidia','amd'] else P],rotation=20 if k in ['nvidia','amd'] else 0);ax.margins(y=.28)
f.supxlabel('* Groq average-power workload is unspecified. Panels use different measurement boundaries.',fontsize=8);save(f,'08_power')
(R/'figures.json').write_text(json.dumps(files,ensure_ascii=False,indent=2));print('Generated',len(files),'figures, SVG/PDF/PNG each')
