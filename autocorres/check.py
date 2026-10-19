"""Fresh session checks, retaining the already-built AFP parent heap."""
import hashlib, json, pathlib, re, statistics, sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'results'))
from capture import capture, ROOT
isabelle='/home/isabelle/Isabelle/bin/isabelle'
base=[isabelle,'build','-c','-o','threads=2','-d','/home/isabelle/afp-2026-10-16/thys','-d','autocorres']
rows=[]
for n,name in [(1,'abs'),(2,'swap'),(3,'sum'),(4,'binary_search'),(5,'reverse')]:
    runs=[]
    for run in range(1,4):
        record=capture(f'autocorres-p{n}_{name}-{run}',
                       ['/usr/bin/time','-f','PEAK_RSS_KB=%M',*base,f'C_ITP_P{n}'])
        good=record['exit_code']==0 and f'Finished C_ITP_P{n}' in record['output']
        peak=re.search(r'PEAK_RSS_KB=(\d+)',record['output'])
        runs.append(dict(passed=good,exit_code=record['exit_code'],wall_seconds=record['wall_seconds'],
                         peak_rss_kb=int(peak[1]) if peak else None))
    source=ROOT/f'autocorres/p{n}/P{n}.thy'
    rows.append(dict(tool='AutoCorres2',program=f'p{n}_{name}',source=str(source.relative_to(ROOT)),
                     source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),runs=runs,
                     passed=all(r['passed'] for r in runs),
                     median_seconds=statistics.median(r['wall_seconds'] for r in runs),
                     deterministic=all(r['passed']==runs[0]['passed'] for r in runs)))
negative=capture('autocorres-p3-broken-final',[*base,'C_ITP_P3_Broken'])
(ROOT/'results/rework/autocorres-checks.json').write_text(json.dumps(rows,indent=2)+'\n')
sys.exit(0 if all(r['passed'] for r in rows) and negative['exit_code']!=0 else 2)
