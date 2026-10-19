"""Run normal WP; an open goal is failure even if Frama-C exits 0."""
import hashlib, json, pathlib, re, statistics, sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'results'))
from capture import capture, ROOT

rows=[]
for source in [*sorted((ROOT/'programs').glob('p*.c')), ROOT/'wp/broken/p3_sum.c']:
    label=('broken-' if 'broken' in source.parts else '')+source.stem
    runs=[]
    for run in range(1,4):
        report=ROOT/'results/rework'/f'wp-{label}-{run}-goals.json'
        report.unlink(missing_ok=True)
        command=['/usr/bin/time','-f','PEAK_RSS_KB=%M','opam','exec','--','frama-c',
                 '-machdep','x86_64','-wp','-wp-rte','-wp-prover','alt-ergo',
                 '-wp-timeout','3' if source.stem=='p5_reverse' else '10',
                 '-wp-par','1','-wp-report-json',str(report),str(source)]
        record=capture(f'wp-{label}-{run}',command)
        goals=json.loads(re.sub(r'(\d)\.(?=\s*[,}])',r'\1.0',report.read_text())) if report.exists() else []
        good=record['exit_code']==0 and len(goals)>0 and all(g['passed'] for g in goals)
        peak=re.search(r'PEAK_RSS_KB=(\d+)',record['output'])
        runs.append(dict(passed=good,goals=len(goals),closed=sum(g['passed'] for g in goals),
                         outcomes={g['goal']:g['verdict'] for g in goals},
                         wall_seconds=record['wall_seconds'],peak_rss_kb=int(peak[1]) if peak else None))
    rows.append(dict(tool='WP',program=label,source=str(source.relative_to(ROOT)),
                     source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),runs=runs,
                     passed=all(r['passed'] for r in runs),
                     median_seconds=statistics.median(r['wall_seconds'] for r in runs),
                     deterministic=all(r['outcomes']==runs[0]['outcomes'] for r in runs)))
(ROOT/'results/rework/wp-checks.json').write_text(json.dumps(rows,indent=2)+'\n')
print(json.dumps([{k:v for k,v in r.items() if k!='runs'} for r in rows],indent=2))
sys.exit(0 if all(r['passed']==(not r['program'].startswith('broken-')) for r in rows) else 2)
