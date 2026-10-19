"""Regenerate and check each RefinedC proof, with three cold local builds."""
import hashlib, json, pathlib, re, statistics, sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'results'))
from capture import capture, ROOT
rows=[]
sources=['p1_abs','p2_swap','p2_swap_alias','p3_sum','p4_binary_search','p5_reverse','p3_sum_broken']
for stem in sources:
    runs=[]
    for run in range(1,4):
        clean=capture(f'refinedc-{stem}-{run}-clean',['opam','exec','--','dune','clean','--root','refinedc'])
        if clean['exit_code']: sys.exit(2)
        record=capture(f'refinedc-{stem}-{run}',
            ['/usr/bin/time','-f','PEAK_RSS_KB=%M','opam','exec','--','refinedc','check',f'refinedc/{stem}.c'])
        proofs=list((ROOT/f'refinedc/_build/default/proofs/{stem}').glob('generated_proof_*.vo'))
        good=record['exit_code']==0 and bool(proofs) and 'successfully checked' in record['output']
        peak=re.search(r'PEAK_RSS_KB=(\d+)',record['output'])
        runs.append(dict(passed=good,exit_code=record['exit_code'],wall_seconds=record['wall_seconds'],
                         peak_rss_kb=int(peak[1]) if peak else None,
                         checked_objects=[str(p.relative_to(ROOT)) for p in proofs]))
    rows.append(dict(tool='RefinedC',program=stem,source=f'refinedc/{stem}.c',
                     source_sha256=hashlib.sha256((ROOT/f'refinedc/{stem}.c').read_bytes()).hexdigest(),
                     runs=runs,passed=all(r['passed'] for r in runs),
                     median_seconds=statistics.median(r['wall_seconds'] for r in runs),
                     deterministic=all(r['passed']==runs[0]['passed'] for r in runs)))
(ROOT/'results/rework/refinedc-checks.json').write_text(json.dumps(rows,indent=2)+'\n')
sys.exit(0 if all(r['passed']==(not r['program'].endswith('_broken')) for r in rows) else 2)
