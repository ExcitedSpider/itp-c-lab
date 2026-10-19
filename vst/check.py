import hashlib, json, pathlib, re, statistics, sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'results'))
from capture import capture, ROOT
(ROOT/'vst/generated').mkdir(exist_ok=True)
failed=False
rows=[]
for n,name in [(1,'abs'),(2,'swap'),(3,'sum'),(4,'binary_search'),(5,'reverse')]:
    if len(sys.argv)>1 and str(n)!=sys.argv[1]: continue
    stem=f'p{n}_{name}'
    commands=[['opam','exec','--','clightgen','-normalize','-o',f'vst/generated/{stem}.v',f'programs/{stem}.c'],
              ['opam','exec','--','coqc','-Q','vst/generated','CPrograms',f'vst/generated/{stem}.v'],
              ['opam','exec','--','coqc','-Q','vst/generated','CPrograms',f'vst/verif_p{n}.v']]
    runs=[]
    for run in range(1,4):
        records=[]
        # coqc always rechecks these sources; remove stale objects as an extra guard.
        for file in [ROOT/f'vst/generated/{stem}.vo',ROOT/f'vst/verif_p{n}.vo']:
            file.unlink(missing_ok=True)
        for i,cmd in enumerate(commands):
            record=capture(f'vst-{stem}-{run}-stage{i}', ['/usr/bin/time','-f','PEAK_RSS_KB=%M',*cmd])
            records.append(record)
            if record['exit_code']: break
        passed=len(records)==3 and all(r['exit_code']==0 for r in records) and (ROOT/f'vst/verif_p{n}.vo').exists()
        failed |= not passed
        runs.append(dict(passed=passed,wall_seconds=sum(r['wall_seconds'] for r in records),
                         peak_rss_kb=max([int(m[1]) for r in records for m in [re.search(r'PEAK_RSS_KB=(\d+)',r['output'])] if m],default=0)))
    rows.append(dict(tool='VST',program=stem,source=f'vst/verif_p{n}.v',
                     source_sha256=hashlib.sha256((ROOT/f'vst/verif_p{n}.v').read_bytes()).hexdigest(),
                     runs=runs,passed=all(r['passed'] for r in runs),
                     median_seconds=statistics.median(r['wall_seconds'] for r in runs),
                     deterministic=all(r['passed']==runs[0]['passed'] for r in runs)))
if len(sys.argv)==1:
    negative=capture('vst-p3-broken-final',['opam','exec','--','coqc','-Q','vst/generated','CPrograms','vst/verif_p3_broken.v'])
    failed |= negative['exit_code']==0
    (ROOT/'results/rework/vst-checks.json').write_text(json.dumps(rows,indent=2)+'\n')
sys.exit(2 if failed else 0)
