"""Group-oriented views of the existing 36-product evidence, without new facts.

Individual SKUs remain visible. Boxes describe comparable SKU values, not CIs.
Same-family signs are counted once per family for an exploratory exact test.
"""
from pathlib import Path
import os,json,math,re,itertools,xml.etree.ElementTree as ET
from statistics import median
from collections import Counter,defaultdict
os.environ.setdefault('MPLCONFIGDIR','/private/tmp/chip-mpl-cache')
from comparison_analysis import family,strict,COL,analyze
from comparison_supplement import selected_memory,mb
R=Path(__file__).resolve().parent
GROUPS=['training','inference','both']
NAMES={'training':'偏训练','inference':'偏推理','both':'训推兼顾'}
D=json.loads((R/'panorama36.json').read_text());P=D['products']
S=json.loads((R/'supplement36.json').read_text())['products']
TOTAL=Counter(r['orientation']['group'] for r in P)
META={
 'compute':('16 位矩阵计算峰值','TFLOP/s'), 'capacity':('外部主存容量','GB'),
 'bandwidth':('外部主存带宽','TB/s'),'year':('首次型号公开年份','年'),
 'bp':('主存带宽 / 16 位算力','byte/FLOP'),'cp':('主存容量 / 16 位算力','GB/(TFLOP/s)'),
 'shared_cache':('全芯片共享 cache','MB'), 'shared_work':('全芯片共享工作存储','MB'),
 'local_total':('主要局部工作区的容量合计','MB；各核心容量之和'),
 'local_per_core':('每核主要局部工作区','MB / 核'),
 'endpoint':('单设备互联收发合计','GB/s'), 'domain':('物理高速互联域','芯片数'),
 'endpoint_per_compute':('互联端点带宽 / 16 位算力','byte/FLOP'),
 'slice':('单任务可调度配置','芯片数'),
 'power_chip':('芯片 TDP','W'), 'power_board':('整卡功率上限','W'), 'power_module':('模组功率上限','W'),
 'fp8':('FP8 / MXFP8 矩阵峰值','TFLOP/s'),'fp4':('FP4 / MXFP4 矩阵峰值','TFLOP/s'),
 'int8':('INT8 峰值','TOPS'),'int4':('INT4 峰值','TOPS')}
for fmt in ('fp8','fp4'):
 META[fmt+'_bp']=(f'主存带宽 / {fmt.upper()} 算力','byte/FLOP')
 META[fmt+'_cp']=(f'主存容量 / {fmt.upper()} 算力','GB/(TFLOP/s)')
FIGS=[]

def integer(r,fmt):
 model={('tpu_v5p','INT8'),('tpu8t','INT8'),('tpu_v5e','INT4'),('tpu_v5p','INT4'),('tpu_v6e','INT4'),('tpu8t','INT4')}
 if (r['id'],fmt) in model:return None
 a=[x for x in S[r['id']]['integer']['records'] if x['format']==fmt and x.get('value_tops') and x.get('sku_bound',True) and x.get('comparison_eligible',True) and x['path'] in ('matrix','matrix/Cube','chip','card')]
 dense=[x for x in a if x['density']=='dense'];a=dense or a
 # Keep uncertain multi-configuration values as a range instead of picking a maximum.
 if not a:return None
 vals=[x['value_tops'] for x in a]
 solid=all(x['density']=='dense' and x['path']=='matrix' for x in a)
 return median(vals),solid,'; '.join(x['source'] for x in a),(min(vals),max(vals))

def observations(key):
 rows=[]
 for r in P:
  v=None;solid=True;source='';span=None;m=r['memory'];c=r['compute16'];s=S[r['id']]
  if key in ('capacity','bandwidth'):
   v=m.get('capacity_gb' if key=='capacity' else 'bandwidth_tb_s');source=m['source']
  elif key=='compute':
   if c['basis']!='excluded':v=c.get('value_tflops')
   solid=strict(c);source=c['source']
  elif key in ('bp','cp'):
   a=m.get('bandwidth_tb_s' if key=='bp' else 'capacity_gb');p=c.get('value_tflops')
   if a and p and c['basis']!='excluded':v=a/p
   solid=strict(c);source=m['source']+'; '+c['source']
  elif key=='year':v=s['release'].get('year');source=s['release']['source']
  elif key in ('shared_cache','shared_work'):
   kind='cache' if key=='shared_cache' else 'shared_work'
   a=[x for x in s['onchip']['records'] if x.get('shared') and x['kind']==kind]
   if a:
    x=max(a,key=mb);v=mb(x);source=x['source'];solid=x.get('management')!='unspecified'
  elif key in ('local_total','local_per_core'):
   x=selected_memory(s['onchip'],'local')
   if x and (key=='local_per_core' or x.get('instances')):
    v=mb(x)*(x['instances'] if key=='local_total' else 1);source=x['source']+'; '+x.get('instance_source','');solid=x.get('management')!='unspecified'
  elif key in ('endpoint','endpoint_per_compute'):
   e=r['endpoint']
   if e['state']=='known' and not e['protocol'].lower().startswith('pcie'):v=e.get('bidir_gb_s')
   source=e['source']
   # Ascend 950 reports raw link rate, unlike normal interface-throughput specifications.
   solid=r['id'] not in ('ascend950pr','ascend950dt')
   if key=='endpoint_per_compute':
    v=v/(c['value_tflops']*1000) if v and c.get('value_tflops') and c['basis']!='excluded' else None
    solid=solid and strict(c);source+='; '+c['source']
  elif key in ('domain','slice'):
   kind='physical_domain' if key=='domain' else 'schedulable_slice'
   a=[x for x in s['scaleup']['records'] if x['kind']==kind]
   if a:
    x=max(a,key=lambda z:z['chips']);v=x['chips'];source=x['source'];solid=s['scaleup'].get('status')!='qualified'
  elif key.startswith('power_'):
   scope={'power_chip':'chip_tdp','power_board':'board_max','power_module':'module_max'}[key]
   if r['power']['scope']==scope:v=r['power'].get('max_w')
   source=r['power']['source']
  elif key.startswith(('fp8','fp4')):
   a=r.get('low_precision',{}).get(key[:3].upper())
   if a:
    v=a.get('value_tflops');solid=strict(a) and a.get('execution') not in ('emulated','converted');source=a['source']
    if '_' in key:
     field='bandwidth_tb_s' if key.endswith('_bp') else 'capacity_gb'
     v=m[field]/v if v and m.get(field) else None;source+='; '+m['source']
  elif key in ('int8','int4'):
   a=integer(r,key.upper())
   if a:v,solid,source,span=a
  if isinstance(v,(int,float)) and v>0:
   rows.append({'id':r['id'],'label':r['short_label'],'group':r['orientation']['group'],'family':family(r),'vendor':r['vendor'],
                'value':v,'comparable':solid,'source':source,'article':r['card'],'range':span})
 return rows
OBS={k:observations(k) for k in META}

def summary(rows):
 out={}
 for g in GROUPS:
  allr=[r for r in rows if r['group']==g];a=[r for r in allr if r['comparable']];values=[r['value'] for r in a]
  buckets=defaultdict(list)
  for r in a:buckets[r['family']].append(r['value'])
  out[g]={'n':len(a),'conditional':len(allr)-len(a),'total':TOTAL[g],'families':len(buckets),'ids':[r['id'] for r in a],
          'median':median(values) if values else None,'min':min(values) if values else None,'max':max(values) if values else None,
          'family_balanced_median':median([median(x) for x in buckets.values()]) if buckets else None}
 return out

def sign_test(ratios):
 nonzero=[x for x in ratios if not math.isclose(x,1,rel_tol=1e-10)]
 n=len(nonzero);k=sum(x>1 for x in nonzero)
 p=min(1,2*sum(math.comb(n,j) for j in range(min(k,n-k)+1))/2**n) if n else None
 return {'n_non_ties':n,'above_one':k,'ties':len(ratios)-n,'p_two_sided':p}

def matched(key,conditionals=False):
 rows=[r for r in OBS[key] if conditionals or r['comparable']];bucket=defaultdict(lambda:defaultdict(list))
 for r in rows:bucket[r['family']][r['group']].append(r)
 result=[]
 for left,right in [('inference','training'),('inference','both'),('both','training')]:
  pairs=[]
  for f,groups in bucket.items():
   if groups.get(left) and groups.get(right):
    a=groups[left];b=groups[right]
    pairs.append({'family':f,'ratio':median(x['value'] for x in a)/median(x['value'] for x in b),
       'left_ids':[x['id'] for x in a],'right_ids':[x['id'] for x in b],
       'comparable':all(x['comparable'] for x in a+b)})
  result.append({'numerator':left,'denominator':right,'pairs':pairs,'test':sign_test([x['ratio'] for x in pairs])})
 return result

def build_stats():
 tests={k:matched(k) for k in ('capacity','bandwidth','bp','cp','compute','endpoint','local_total')}
 # Holm family-wise correction across all actually testable comparisons, without selecting small p-values.
 refs=[x['test'] for lst in tests.values() for x in lst if x['test']['p_two_sided'] is not None]
 ordered=sorted(refs,key=lambda x:x['p_two_sided']);last=0
 for i,x in enumerate(ordered):
  last=max(last,min(1,(len(ordered)-i)*x['p_two_sided']));x['p_holm']=last
 return {'scope':'Existing 36 products; purposive sample, observational comparisons.',
         'counts':dict(TOTAL),'metrics':{k:{'title':META[k][0],'unit':META[k][1],'groups':summary(v),'records':v} for k,v in OBS.items()},
         'matched_tests':tests,'test_family_size':len(refs),'method':{'boxes':'median and central 50% of comparable SKU observations; whiskers=min/max; no box if n<3; NOT confidence intervals',
         'families':'comparison_analysis.family; within each family and orientation take median; families with both orientations contribute once',
         'test':'two-sided exact sign test of matched-family ratio relative to 1; ties omitted; exploratory independence/equal-sign-probability assumptions, not causal or market-population inference',
         'multiplicity':'Holm correction across all nonempty sign tests for the 7 listed metrics and 3 orientation pairs',
         'local_total':'maximum-capacity local_work layer per product times its documented physical instance count; NOT total SRAM or shared capacity'},
         'bp_sensitivity':analyze(D)['scenarios']}

def pretty(x):
 if x is None:return '无'
 if x>=1000:return f'{x:,.0f}'
 if x>=10:return f'{x:.1f}'.rstrip('0').rstrip('.')
 if x>=1:return f'{x:.2f}'.rstrip('0').rstrip('.')
 return f'{x:.3g}'

def draw_all():
 import matplotlib
 matplotlib.use('Agg')
 import matplotlib.pyplot as plt
 from matplotlib import font_manager
 from matplotlib.ticker import FuncFormatter,NullFormatter,MaxNLocator,LogLocator
 from matplotlib.lines import Line2D
 from matplotlib.patches import Patch
 import numpy as np
 for f in ['/System/Library/Fonts/Supplemental/Arial.ttf','/System/Library/Fonts/STHeiti Medium.ttc']:font_manager.fontManager.addfont(f)
 cjk=font_manager.FontProperties(fname='/System/Library/Fonts/STHeiti Medium.ttc').get_name()
 plt.rcParams.update({'font.family':['Arial',cjk],'font.size':11,'axes.titlesize':13,'axes.labelsize':11,'axes.spines.top':False,'axes.spines.right':False,'axes.linewidth':.7,'svg.fonttype':'none','pdf.fonttype':42,'savefig.dpi':200,'axes.unicode_minus':False})
 out=R/'图表';out.mkdir(exist_ok=True)
 def save(fig,name):
  for ext in ('svg','pdf','png'):fig.savefig(out/f'{name}.{ext}',bbox_inches='tight',pad_inches=.18,facecolor='white')
  # Plain SVG title provides inspectable product/value context in standalone exports and HTML.
  p=out/f'{name}.svg';s=p.read_text()
  for key,rows in OBS.items():
   for r in rows:
    gid=f'point-{key}-{r["id"]}'
    tip=f'{r["label"]} | {NAMES[r["group"]]} | {pretty(r["value"])} {META[key][1]}'
    s=s.replace(f'<g id="{gid}">',f'<g id="{gid}"><title>{tip}</title>')
  p.write_text(re.sub(r'[ \t]+$','',s,flags=re.M));plt.close(fig);FIGS.append(name)
 def panel(ax,key,labels=True,boxes=True):
  rows=OBS[key];st=summary(rows);ax.set_title(META[key][0],loc='left',pad=15);ax.set_ylabel(META[key][1])
  vals=[r['value'] for r in rows]
  if key!='year':
   ax.set_yscale('log');ax.yaxis.set_major_formatter(FuncFormatter(lambda v,_:pretty(v)));ax.yaxis.set_minor_formatter(NullFormatter())
   if vals:ax.set_ylim(min(vals)/1.8,max(vals)*2.5)
   if key.startswith('power_'):ax.yaxis.set_major_locator(LogLocator(base=10,subs=(1,2,5)))
  else:ax.set_ylim(2017.5,2027);ax.yaxis.set_major_locator(MaxNLocator(integer=True,nbins=5))
  ax.grid(axis='y',color='#E2E8EB',lw=.7,zorder=0);ax.set_axisbelow(True);ax.set_xlim(-.55,2.55)
  ticks=[]
  for i,g in enumerate(GROUPS):
   a=sorted([r for r in rows if r['group']==g],key=lambda r:r['value']);v=[r['value'] for r in a if r['comparable']]
   q=st[g];ticks.append(f'{NAMES[g]}\n{q["n"]}/{q["total"]}'+(f'，另{q["conditional"]}' if q['conditional'] else ''))
   if boxes and v:
    if len(v)>=3:
     q1,med,q3=np.quantile(v,[.25,.5,.75]);ax.bxp([{'q1':q1,'med':med,'q3':q3,'whislo':min(v),'whishi':max(v),'fliers':[]}],positions=[i],widths=.48,showfliers=False,patch_artist=True,manage_ticks=False,boxprops={'facecolor':COL[g]+'20','edgecolor':COL[g]},medianprops={'color':COL[g],'lw':2},whiskerprops={'color':COL[g],'lw':1},capprops={'color':COL[g],'lw':1})
    else:ax.plot([i-.22,i+.22],[median(v)]*2,color=COL[g],lw=2)
    # Median values above the plot, never on top of product marks.
    ax.text(i,1.01,(f'{median(v):g}' if key=='year' else pretty(median(v))),transform=ax.get_xaxis_transform(),ha='center',fontsize=9,color=COL[g])
   if not a:ax.text(i,.4,'暂无可用值',transform=ax.get_xaxis_transform(),ha='center',color='#88949C',fontsize=10)
   offsets=[0] if len(a)==1 else [(-.22+j*.44/(len(a)-1)) for j in range(len(a))]
   # Reorder offsets, so horizontal placement does not look like an additional quantitative scale.
   offsets=sorted(offsets,key=lambda z:(abs(z),z))
   for j,r in enumerate(a):
    x=i+offsets[j];v=r['value'];color=COL[g]
    if r['range'] and r['range'][0]!=r['range'][1]:ax.plot([x,x],r['range'],color=color,alpha=.5,lw=1)
    p=ax.scatter(x,v,s=39,marker={'training':'^','inference':'v','both':'o'}[g],facecolor=color if r['comparable'] else 'white',edgecolor=color,lw=1.15,zorder=4,gid=f'point-{key}-{r["id"]}')
    p.set_urls([(R.parent/'产品详解'/r['article']).as_uri()])
  ax.set_xticks(range(3),ticks);ax.tick_params(axis='x',length=0,labelsize=10)
 def value_legend(fig,x=.53,y=.01):
  fig.legend(handles=[Line2D([],[],marker='o',linestyle='none',color='#62727B',label='可比值'),Line2D([],[],marker='o',linestyle='none',color='#62727B',markerfacecolor='white',label='参考值')],loc='lower center',bbox_to_anchor=(x,y),ncol=2,frameon=False,fontsize=9)
 def numeric(name,keys,title,ncols=2):
  nr=math.ceil(len(keys)/ncols);fig,aa=plt.subplots(nr,ncols,figsize=(6*ncols,5.2 if nr==1 else 9.2),squeeze=False)
  fig.subplots_adjust(left=.085,right=.98,top=(.90 if len(keys)==1 else .85) if nr==1 else .90,bottom=.18 if nr==1 else .11,hspace=.5,wspace=.35)
  for ax,key in zip(aa.flat,keys):panel(ax,key)
  for ax in list(aa.flat)[len(keys):]:ax.axis('off')
  if len(keys)>1:fig.suptitle(title,x=.085,ha='left',fontsize=16,y=.99)
  value_legend(fig)
  save(fig,name)
 numeric('分组01_计算主存与年份',['compute','capacity','bandwidth','year'],'计算、主存与发布年份')
 numeric('分组02_存算配比',['bp','cp'],'存算比')
 numeric('分组03_片上存储',['shared_cache','shared_work','local_per_core','local_total'],'片上存储容量')
 numeric('分组04_互联',['endpoint','domain','slice'],'互联带宽与规模',3)
 numeric('分组05_功率',['power_chip','power_board','power_module'],'功率规格',3)
 numeric('分组06_低精度峰值',['fp8','fp4','int8','int4'],'低精度计算峰值')
 # Section-specific views preserve the report's original two-layer narrative.
 numeric('分组09_16位计算峰值',['compute'],'16 位计算峰值',1)
 numeric('分组10_外部主存',['capacity','bandwidth'],'外部主存')
 numeric('分组11_整数峰值',['int8','int4'],'整数计算峰值')
 numeric('分组12_FP8峰值与配比',['fp8','fp8_bp','fp8_cp'],'FP8 计算峰值与存算比',3)
 numeric('分组13_FP4峰值与配比',['fp4','fp4_bp','fp4_cp'],'FP4 计算峰值与存算比',3)
 numeric('分组14_设备互联',['endpoint','endpoint_per_compute'],'设备互联')
 numeric('分组15_scale-up规模',['domain','slice'],'高速互联规模')
 # Denominator is the entire orientation group; unknown support stays visible, never recoded to no.
 fig,aa=plt.subplots(2,3,figsize=(15,8.2));fig.subplots_adjust(left=.07,right=.985,top=.9,bottom=.12,wspace=.25,hspace=.43)
 for ax,fmt in zip(aa.flat,['BF16','FP8','FP4','INT8','INT4','TF32']):
  ax.set_title(fmt,loc='left');ax.set_ylim(0,112);ax.set_yticks([0,50,100],['0%','50%','100%']);ax.grid(axis='y',color='#E2E8EB',lw=.6);ax.set_axisbelow(True)
  for i,g in enumerate(GROUPS):
   cs=Counter(r['formats'][fmt]['state'] for r in P if r['orientation']['group']==g);n=TOTAL[g];base=0
   for state in ['yes','conditional','no','conflict','unknown']:
    val=100*cs[state]/n
    if not val:continue
    ax.bar(i,val,bottom=base,width=.56,color=COL[g] if state=='yes' else ('white' if state=='conditional' else '#E9EEF0'),edgecolor=COL[g] if state in ('yes','conditional') else '#A5B0B6',hatch={'conditional':'///','no':'xx','conflict':'..'}.get(state),lw=.6)
    base+=val
   ax.text(i,104,f'{cs["yes"]}/{n}',ha='center',color=COL[g],fontsize=11)
  ax.set_xticks(range(3),[NAMES[g] for g in GROUPS]);ax.tick_params(axis='x',length=0,labelsize=10)
 fig.suptitle('数值格式支持',x=.07,ha='left',fontsize=16)
 fig.legend(handles=[Patch(facecolor='#62727B',label='已确认支持'),Patch(facecolor='white',edgecolor='#62727B',hatch='///',label='有执行限制'),Patch(facecolor='#E9EEF0',edgecolor='#A5B0B6',label='未确认'),Patch(facecolor='#E9EEF0',edgecolor='#A5B0B6',hatch='xx',label='无原生支持'),Patch(facecolor='#E9EEF0',edgecolor='#A5B0B6',hatch='..',label='来源有分歧')],loc='lower center',ncol=5,frameon=False,bbox_to_anchor=(.53,.01),fontsize=10)
 save(fig,'分组07_数值格式')
 # Matched-family effects: family appears once, shared family is not treated as independent SKUs.
 keys=['capacity','bandwidth','bp'];fam_names={'NVIDIA/Hopper':'Hopper','NVIDIA/Ada':'Ada','AMD/CDNA4':'CDNA 4','Google-TPU/TPU5':'TPU v5','Google-TPU/TPU8':'TPU 8','AWS/NCv2':'NeuronCore-v2','华为昇腾/Ascend950':'Ascend 950'}
 families=[]
 for pair in matched('capacity',True):
  for x in pair['pairs']:families.append((pair['numerator'],pair['denominator'],x['family']))
 fig,aa=plt.subplots(1,3,figsize=(15,6.2),sharey=True);fig.subplots_adjust(left=.20,right=.97,top=.84,bottom=.18,wspace=.25)
 for ax,key in zip(aa,keys):
  vals={(d['numerator'],d['denominator'],x['family']):x for d in matched(key,True) for x in d['pairs']}
  ax.set_xscale('log');ax.set_xlim(.12,3);ax.set_xticks([.125,.25,.5,1,2],['0.125','0.25','0.5','1','2']);ax.xaxis.set_minor_formatter(NullFormatter());ax.axvline(1,color='#7A8790',ls='--',lw=1);ax.grid(axis='x',color='#E2E8EB',lw=.6);ax.set_title(META[key][0],loc='left');ax.set_xlabel('偏推理 / 对照组')
  ax.set_yticks(range(len(families)),[fam_names.get(f,f)+'（推 / '+('训' if b=='training' else '兼')+'）' for a,b,f in families]);ax.set_ylim(len(families)-.3,-.8)
  for i,k in enumerate(families):
   x=vals.get(k)
   if not x:ax.text(.96,i,'无可配对值',transform=ax.get_yaxis_transform(),ha='right',fontsize=9,color='#85929A');continue
   v=x['ratio'];ax.plot([1,v],[i,i],color='#218378',lw=1.3);ax.scatter(v,i,s=48,facecolor='#218378' if x['comparable'] else 'white',edgecolor='#218378',zorder=3)
   ax.annotate(f'{v:.2f}×',(v,i),xytext=(5,8),textcoords='offset points',fontsize=9)
 fig.suptitle('同家族主存资源对比',x=.20,ha='left',fontsize=16)
 value_legend(fig,x=.58)
 save(fig,'分组08_同族对照')
 stats=build_stats();stats['figures']=FIGS
 (R/'grouped-comparison-data.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2)+'\n')
 return stats
if __name__=='__main__':
 st=draw_all()
 for k in META:
  print(k,{g:(v['n'],v['conditional'],v['median']) for g,v in st['metrics'][k]['groups'].items()})
 print('matched tests',json.dumps(st['matched_tests'],ensure_ascii=False))
