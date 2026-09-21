import fs from 'node:fs';import path from 'node:path';import {fileURLToPath} from 'node:url';
const {marked}=await import('/Users/gxli/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js');
const root=path.dirname(fileURLToPath(import.meta.url));
const vendors=['NVIDIA','AMD','Google-TPU','AWS','华为昇腾','Groq','寒武纪'];
const esc=s=>s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
const productIds=new Map();
let articles=[],nav='',md='# 训练与推理芯片：产品详解\n\n本版覆盖现有 7 家厂商的 36 个产品，每篇先看架构图，再介绍计算、存储、互联和规格。旧资料卡保留作为事实追溯入口。\n\n[打开图文阅读版](产品详解-阅读版.html)\n\n图是按公开资料重绘的功能与层级示意，不是物理版图。确认过的 DRAM 数量直接画出；数量、布局或容量未确认的部分会明确标注。SVG 为可编辑矢量原图，PNG 用于兼容 Markdown 阅读器。各篇保留精确引用与现有来源分歧。\n\n本版按厂商扩充，再由未参与相应文章编写的独立代理逐项对照原始资料，核验正文、表格和图中的数据及技术描述。官方规格、源码中的软件资源、条件推导和微基准测量分别注明；尚无依据的参数保留缺口，原文冲突并列说明。\n';
const order={NVIDIA:['A100','H100_SXM','H100_PCIe','H100_NVL','L4_','L40S','H200_SXM','H200_NVL','B200','B300'],'Google-TPU':['v4_','v5e_','v5p_','v6e_','TPU7x','8t_','8i_']};
for(const v of vendors){let files=fs.readdirSync(path.join(root,v)).filter(x=>x.endsWith('.md')).sort((a,b)=>{const rank=x=>order[v]?.findIndex(k=>x.includes(k))??-1;return order[v]?rank(a)-rank(b):a.localeCompare(b)});nav+=`<h3>${esc(v)}</h3>`;md+=`\n## ${v}\n\n`;for(const f of files){
 const filename=path.join(root,v,f);let src=fs.readFileSync(filename,'utf8');const title=src.match(/^# (.+)$/m)[1];const id='p'+articles.length;productIds.set(filename,id);
 // References retain their source numbers even when the sequence is not continuous.
 src=src.replace(/^\[(\d+)\] (.+)$/gm,(_,n,t)=>`<span class="refnumber" id="${id}-ref-${n}">[${n}]</span> ${t}`);
 let html=await marked.parse(src,{gfm:true});
 html=html.replace(/<img src="([^"]+)" alt="([^"]*)"\s*\/?\s*>/g,(_,target,alt)=>{
  const svgTarget=target.replace(/\.png$/,'.svg');const svgPath=path.resolve(path.dirname(filename),decodeURI(svgTarget));
  if(!fs.existsSync(svgPath))return `<img src="${esc(v+'/'+target)}" alt="${alt}">`;
  let svg=fs.readFileSync(svgPath,'utf8').replaceAll('id="arrow"',`id="${id}-arrow"`).replaceAll('url(#arrow)',`url(#${id}-arrow)`);
  return `<figure tabindex="0" title="点击放大架构图">${svg}<figcaption>点击放大 · <a href="${esc(v+'/'+path.basename(svgPath))}" download>SVG 原图</a></figcaption></figure>`;
 });
 html=html.replace(/href="([^"#]+)"/g,(_,target)=>{
  target=target.replaceAll('&amp;','&');
  if(/^(https?:|mailto:)/.test(target)||target.startsWith(v+'/'))return `href="${esc(target)}"`;
  const full=path.resolve(path.dirname(filename),decodeURI(target));return `href="${esc(path.relative(root,full))}"`;
 });
 html=html.replace(/<table>/g,'<div class="table-wrap"><table>').replace(/<\/table>/g,'</table></div>');
 articles.push(`<article id="${id}" data-title="${esc(title)}" data-vendor="${esc(v)}" hidden><div class="eyebrow">${esc(v)} · 产品技术详解</div>${html}</article>`);
 nav+=`<a href="#${id}" data-search="${esc(title.toLowerCase())}">${esc(title.replace(/^NVIDIA |^AMD Instinct |^Google Cloud |^Google |^AWS |^Huawei /,''))}</a>`;
 md+=`- [${title}](${v}/${f})\n`;
}}

const comparisonFile=path.join(root,'..','比较分析','训练与推理架构比较.md');
let comparisonHtml='';
let comparisonFigureCount=0;
let comparisonTitle='训练与推理芯片：全产品比较';
let scopeEntry='';
if(fs.existsSync(comparisonFile)){
 let source=fs.readFileSync(comparisonFile,'utf8');
 comparisonTitle=source.match(/^# (.+)$/m)?.[1]||comparisonTitle;
 let html=await marked.parse(source,{gfm:true});let figureIndex=0;
 html=html.replace(/<img src="([^"]+)" alt="([^"]*)"\s*\/?\s*>/g,(_,target,alt)=>{
  const svgPath=path.resolve(path.dirname(comparisonFile),decodeURI(target.replace(/\.png$/,'.svg')));
  let svg=fs.readFileSync(svgPath,'utf8').replace(/<\?xml[^>]*\?>/g,'').replace(/<!DOCTYPE[\s\S]*?>/g,'').replace(/ target="_blank"/g,'');
  const prefix='comparison-f'+(figureIndex++)+'-';
  const ids=[...svg.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]);
  for(const id of ids){svg=svg.replaceAll('id="'+id+'"','id="'+prefix+id+'"').replaceAll('url(#'+id+')','url(#'+prefix+id+')').replaceAll('href="#'+id+'"','href="#'+prefix+id+'"');}
  const base=path.relative(root,svgPath).replace(/\.svg$/,'');
  return `<figure class="experiment" tabindex="0" aria-label="${alt}" title="点击空白处放大；数据点可跳转证据"><div class="chart-viewport">${svg}</div><figcaption>点击放大 · ${['svg','pdf','png'].map(ext=>`<a href="${base}.${ext}" download>${ext.toUpperCase()}</a>`).join(' · ')}</figcaption></figure>`;
 });
 html=html.replace(/<p>(<figure[\s\S]*?<\/figure>)<\/p>/g,'$1');
 html=html.replace(/href="([^"]+)"/g,(_,target)=>{
  target=target.replaceAll('&amp;','&');
  if(target.startsWith('#')||/^(https?:|mailto:)/.test(target)||target.startsWith('../比较分析/'))return `href="${esc(target)}"`;
  const [targetPath, fragment]=target.split('#');
  const full=path.resolve(path.dirname(comparisonFile),decodeURI(targetPath));
  if(productIds.has(full)){const pid=productIds.get(full);return `href="#${pid}${fragment?.startsWith('ref-')?'-'+fragment:''}"`;}
  return `href="${esc(path.relative(root,full))}${fragment?'#'+fragment:''}"`;
 });
 let section=0;html=html.replace(/<h2>/g,()=>`<h2 id="comparison-s${section++}">`);
 comparisonFigureCount=figureIndex;
 html=html.replace(/<table>/g,'<div class="table-wrap"><table>').replace(/<\/table>/g,'</table></div>');
 const toc=[...html.matchAll(/<h2 id="([^"]+)">([\s\S]*?)<\/h2>/g)].map(m=>`<a href="#${m[1]}">${m[2]}</a>`).join('');
 html=html.replace(/(<h1>[\s\S]*?<\/h1>)/,`$1<div class="report-toc" aria-label="报告目录">${toc}</div>`);
 comparisonHtml=`<article id="comparison" class="comparison" data-title="${esc(comparisonTitle)}" hidden><div class="eyebrow">第一层 · 36 个产品 · 全景比较</div>${html}</article>`;
 nav=`<h3>横向比较</h3><a href="#comparison" data-search="比较 报告 训练 推理 comparison">全产品比较 · ${comparisonFigureCount} 张图</a>`+nav;
 md=md.replace('[打开图文阅读版](产品详解-阅读版.html)','[打开图文阅读版](产品详解-阅读版.html)\n\n[全产品比较报告](../比较分析/训练与推理架构比较.md)：第一层覆盖 36 个产品，展示数值格式、DRAM、存算配比、设备互联和功率边界。每张图提供 SVG、PDF 和 PNG。');
}
const scopeFile=path.join(root,'..','比较分析','比较维度与数据支持范围.md');
if(fs.existsSync(scopeFile)){
 let html=await marked.parse(fs.readFileSync(scopeFile,'utf8'),{gfm:true});
 html=html.replace(/href="([^"#]+)"/g,(_,target)=>{
  target=target.replaceAll('&amp;','&');
  if(/^(https?:|mailto:)/.test(target))return `href="${esc(target)}"`;
  const full=path.resolve(path.dirname(scopeFile),decodeURI(target));
  if(full===path.join(root,'README.md'))return 'href="#"';
  if(full===comparisonFile)return 'href="#comparison"';
  return productIds.has(full)?`href="#${productIds.get(full)}"`:`href="${esc(path.relative(root,full))}"`;
 });
 let section=0;html=html.replace(/<h2>/g,()=>`<h2 id="comparison-scope-s${section++}">`);
 html=html.replace(/<table>/g,'<div class="table-wrap"><table>').replace(/<\/table>/g,'</table></div>');
 comparisonHtml+=`<article id="comparison-scope" class="comparison" data-title="比较维度与数据支持范围" hidden><div class="eyebrow">现有资料 · 比较范围评估</div>${html}</article>`;
 const scopeNav='<a href="#comparison-scope" data-search="比较 维度 数据 支持 范围 scope">比较维度与数据支持范围</a>';
 nav=nav.includes('<h3>横向比较</h3>')?nav.replace('<h3>横向比较</h3>','<h3>横向比较</h3>'+scopeNav):'<h3>横向比较</h3>'+scopeNav+nav;
 scopeEntry='<a class="report-entry" href="#comparison-scope"><strong>现有资料能支持多深入的比较？</strong><span>全景分布 → 家族对照 → 负载推导 · 30 项规格或机制比较与 4 类推导分析</span></a>';
 md=md.replace('[打开图文阅读版](产品详解-阅读版.html)','[打开图文阅读版](产品详解-阅读版.html)\n\n[比较维度与数据支持范围](../比较分析/比较维度与数据支持范围.md)：本次核查所得的 30 项规格或机制比较、4 类负载推导、覆盖数量与 11 组重点对照。');
}
const style=`:root{color-scheme:light;--ink:#233742;--muted:#647783;--line:#dce6eb;--accent:#377991}*{box-sizing:border-box}[hidden]{display:none!important}body{margin:0;font:16px/1.85 Arial,'Microsoft YaHei','PingFang SC',sans-serif;color:var(--ink);background:#f5f7f9}aside{position:fixed;left:0;top:0;bottom:0;width:286px;padding:26px 22px;background:#fff;border-right:1px solid var(--line);overflow:auto}aside .brand{font-size:18px;font-weight:700;color:var(--accent);text-decoration:none}aside p{font-size:12px;color:var(--muted);margin:4px 0 15px}input{width:100%;border:1px solid #c9d8df;padding:10px 12px;border-radius:7px;font:inherit;font-size:14px}nav h3{font-size:12px;letter-spacing:.04em;margin:24px 0 7px;color:#718591}nav a{display:block;font-size:13px;line-height:1.5;padding:8px 10px;margin:2px 0;border-radius:6px;text-decoration:none;color:#334b58}nav a:hover,nav a.active{background:#e9f4f8;color:#25677e}main{margin-left:286px;padding:42px 5vw 90px}article,#welcome{max-width:1100px;margin:auto;background:white;padding:42px 48px 60px;border:1px solid var(--line);border-radius:12px;box-shadow:0 6px 28px #243c4b06}.eyebrow{font-size:12px;letter-spacing:.09em;color:var(--accent);margin-bottom:12px}h1{font-size:32px;line-height:1.3;letter-spacing:-.025em;margin:0 0 26px}h2{font-size:23px;line-height:1.4;margin:46px 0 18px;padding-top:12px;border-top:1px solid var(--line)}p{margin:0 0 20px}article>p:first-of-type{font-size:18px;color:#47616d;line-height:1.9}figure{margin:30px -24px 18px;border:1px solid var(--line);border-radius:8px;padding:12px;background:white;cursor:zoom-in}figure svg{width:100%;height:auto;display:block}figcaption{font-size:12px;text-align:right;color:var(--muted);padding:4px 8px}figure:fullscreen{width:100vw;height:100vh;margin:0;padding:28px;overflow:auto;display:grid;align-items:center}figure:fullscreen svg{max-height:90vh}a{color:#2c758f;text-underline-offset:3px;overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;font-size:14px;line-height:1.7}th{text-align:left;background:#eef5f8;border-bottom:2px solid #bed3dd}td,th{padding:12px 14px;border-bottom:1px solid #e1e9ed;vertical-align:top}tbody tr:nth-child(even){background:#fafcfd}.table-wrap{overflow:auto;margin:24px 0 28px}code{font:13px/1.6 monospace;background:#f1f5f7;border-radius:4px;padding:2px 5px;overflow-wrap:anywhere}.refnumber{font-weight:700;color:var(--accent)}article:not(.comparison) h2:last-of-type~p{font-size:13px;color:#536a75}.welcome-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;margin-top:28px}.vendor-box{border:1px solid var(--line);border-radius:9px;padding:18px}.vendor-box h3{margin:0 0 10px;font-size:18px}.vendor-box a{display:block;font-size:14px;margin:6px 0}.quiet{color:var(--muted);font-size:14px}button{border:1px solid #bed3dd;background:#eef5f8;color:#265f74;padding:8px 13px;border-radius:6px;cursor:pointer}#topbar{max-width:1100px;margin:0 auto 18px;display:flex;justify-content:space-between;font-size:13px;color:var(--muted)}@media(max-width:1050px){aside{width:230px;padding:20px 15px}main{margin-left:230px;padding:25px 20px}article,#welcome{padding:28px}figure{margin:20px -10px}}@media(max-width:760px){aside{position:relative;width:auto;max-height:36vh;border-right:0;border-bottom:1px solid var(--line)}main{margin:0;padding:20px 10px}article,#welcome{padding:22px 18px}h1{font-size:26px}nav h3{margin-top:14px}.welcome-grid{grid-template-columns:1fr}}@media print{aside,#topbar,figcaption{display:none}main{margin:0;padding:0}article{border:0;box-shadow:none;padding:0;max-width:none}article[hidden]{display:none}figure{break-inside:avoid;margin:20px 0}h2{break-after:avoid}}`;
const reportStyle=`.comparison figure{border:0;border-radius:0;padding:0;margin:26px -12px 12px}.comparison h2{margin-top:48px}.comparison details{font-size:13px;color:#536a75;border-left:2px solid #dce6eb;padding:8px 14px;margin:14px 0 26px}.comparison summary{cursor:pointer;color:#2c758f}.comparison details p{margin:12px 0}.comparison figcaption{font-size:12px}.report-entry{display:block;margin:28px 0;padding:20px 24px;border:1px solid #bed3dd;border-left:4px solid #387991;border-radius:6px;text-decoration:none;background:#f6fafb}.report-entry strong{display:block;font-size:20px}.report-entry span{font-size:14px;color:#536a75}`;
const panoramaStyle=`.report-toc{display:flex;flex-wrap:wrap;gap:8px 18px;margin:0 0 24px;padding:14px 0;border-bottom:1px solid var(--line);font-size:13px}.report-toc a{text-decoration:none}.chart-viewport{overflow:auto;max-width:100%}.comparison .chart-viewport svg{min-width:660px}.comparison .table-wrap{max-width:100%}.comparison .table-wrap td:first-child{min-width:120px}.comparison details:target{border-left-color:#218378;background:#f7fbfa}.comparison details summary{font-size:15px;padding:3px 0}.comparison figure:fullscreen .chart-viewport{width:100%;max-height:90vh}.comparison figure:fullscreen svg{max-height:none}.comparison h2{scroll-margin-top:20px}@media(max-width:760px){.comparison figure{margin:22px 0 12px}.report-toc{font-size:12px}.comparison .table-wrap table{min-width:640px}.comparison h1{font-size:25px}.comparison details{padding-left:9px}}`;
const homeCards=vendors.map(v=>{const i=articles.map((a,i)=>a.includes(`data-vendor="${esc(v)}"`)?i:-1).filter(i=>i>=0);return `<section class="vendor-box"><h3>${esc(v)}</h3>${i.map(n=>{let title=articles[n].match(/data-title="([^"]+)"/)[1];return `<a href="#p${n}">${title}</a>`}).join('')}</section>`}).join('');
const js=`const nav=document.querySelector('nav');function show(){let id=location.hash.slice(1);let target=document.getElementById(id);let chosen=target?.closest('article');document.querySelectorAll('article').forEach(a=>a.hidden=a!==chosen);document.getElementById('welcome').hidden=!!chosen;nav.querySelectorAll('a').forEach(a=>a.classList.toggle('active',a.hash==='#'+chosen?.id));document.title=chosen?chosen.dataset.title+' · 产品详解':'训练与推理芯片 · 产品详解';if(target&&target!==chosen){let ancestor=target;while(ancestor&&ancestor!==chosen){if(ancestor.tagName==='DETAILS')ancestor.open=true;ancestor=ancestor.parentElement;}target.scrollIntoView();}else window.scrollTo(0,0)}window.addEventListener('hashchange',show);show();document.getElementById('search').addEventListener('input',e=>{let q=e.target.value.toLowerCase().trim();nav.querySelectorAll('a').forEach(a=>a.hidden=!a.dataset.search.includes(q))});document.querySelectorAll('figure').forEach(f=>{f.addEventListener('keydown',e=>{if(e.key==='Enter'&&e.target===f)f.click()});f.addEventListener('click',e=>{if(e.target.closest('a'))return;if(document.fullscreenElement)document.exitFullscreen();else f.requestFullscreen?.()})});document.getElementById('print').onclick=()=>window.print();`;
fs.writeFileSync(path.join(root,'产品详解-阅读版.html'),`<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>训练与推理芯片 · 产品详解</title><style>${style}${reportStyle}${panoramaStyle}</style></head><body><aside><a class="brand" href="#">训练与推理芯片</a><p>先看架构，再读规格 · 36 个产品</p><input id="search" placeholder="搜索产品名称" aria-label="搜索产品名称"><nav>${nav}</nav></aside><main><div id="topbar"><span><a href="#">全部产品</a> · <a href="#comparison">比较报告</a></span><button id="print">打印当前页面</button></div><section id="welcome"><div class="eyebrow">ARCHITECTURE → PRODUCT</div><h1>从架构认识一款芯片</h1><p>每篇从一张架构示意图开始，介绍矩阵、向量等计算路径，以及寄存器、片上存储、DRAM 和互联。容量、算力、分层带宽与延迟都放在对应部件旁，并说明来源和适用条件。</p><p class="quiet">覆盖 NVIDIA、AMD、Google、AWS、华为昇腾、Groq 和寒武纪。图为功能与层级示意，已知数量明确标出；未公开、存在冲突的配置保留说明。旧资料卡和原始参考资料继续保留。</p>${scopeEntry}<a class="report-entry" href="#comparison"><strong>第一层：全产品比较</strong><span>36 个产品 · ${comparisonFigureCount} 张比较图 · 精度、DRAM、存算配比、设备互联与功率边界</span></a><div class="welcome-grid">${homeCards}</div></section>${articles.join('')}${comparisonHtml}</main><script>${js}</script></body></html>`);
fs.writeFileSync(path.join(root,'README.md'),md+'\n## 阅读与引用\n\n每篇文末保留本篇实际使用的参考资料，编号与正文一致。架构图中的位置用于说明归属与访问关系，不能据此推断真实版图、缓存必经路径或未公开的 die-to-die 拓扑。理论峰值、稀疏条件、带宽方向及来源冲突随正文保留；没有把旧卡标为已完成理解成所有字段都已有公开答案。\n');
console.log('Built',articles.length,'articles into reading edition and README');
