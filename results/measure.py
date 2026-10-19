"""Auditable physical line and syntactic proof-step counts; no inferred successes."""
import hashlib, json, pathlib, re, statistics
ROOT=pathlib.Path(__file__).resolve().parent.parent
OUT=ROOT/'results/rework'
PROGRAMS=['p1_abs','p2_swap','p3_sum','p4_binary_search','p5_reverse']
TACTICS=['pose proof','assert_PROP','start_function','forward_while','forward_if','forward',
         'make_compspecs','mk_varspecs','with_library','entailer','Exists','Intros',
         'intros','intro','induction','destruct','assert','rewrite','autorewrite','change',
         'unfold','fold','subst','split','apply','eapply','exfalso','reflexivity','lia',
         'rep_lia','simpl','auto','tauto','contradiction','discriminate','congruence',
         'cancel','have','symmetry','inversion','revert','solve_goal','done']
TOKEN=re.compile(r'(?<![\w.])(?:'+'|'.join(map(re.escape,TACTICS))+r')(?![\w])')
def read(p): return (ROOT/p).read_text()
def strip_comments(s):
    return re.sub(r'\(\*[\s\S]*?\*\)',lambda m:'\n'*m[0].count('\n'),s)
def steps(path,kind):
    s=strip_comments(read(path))
    if kind=='c':
        matches=[]
        for attr in re.finditer(r'\[\[rc::tactics\("(.*?)"\)\]\]',s,re.S):
            for m in TOKEN.finditer(attr[1]):
                matches.append(dict(file=path,line=s[:attr.start(1)+m.start()].count('\n')+1,step=m[0]))
        return matches
    rx=TOKEN if kind=='coq' else re.compile(r'\b(?:apply|by)\b|\bproof\s*\(')
    return [dict(file=path,line=s[:m.start()].count('\n')+1,step=m[0]) for m in rx.finditer(s)]
def line_entries(path,classes):
    return [dict(file=path,line=i,text=line,category=classes[i])
            for i,line in enumerate(read(path).splitlines(),1) if i in classes and line.strip()]
def acsl(path):
    s=read(path); classes={}
    for m in re.finditer(r'/\*@([\s\S]*?)\*/',s):
        kind='annotation' if re.search(r'\b(loop|assert)\b',m[1]) else 'spec'
        start=s[:m.start()].count('\n')+1
        for off,line in enumerate(m[0].splitlines()):
            if line.replace('/*@','').replace('*/','').strip(): classes[start+off]=kind
    return line_entries(path,classes)
def rc(path):
    s=read(path); classes={}
    for i,line in enumerate(s.splitlines(),1):
        if '//@rc::' in line: classes[i]='annotation'
    body=re.search(r'\b(?:int|void|struct node\s*\*)\s*\w+\([^;{}]*\)\s*\{',s).start()
    for m in re.finditer(r'\[\[rc::(\w+)\(([\s\S]*?)\)\]\]',s):
        kind='annotation' if m.start()>body or m[1] in ('tactics','lemmas') else 'spec'
        start=s[:m.start()].count('\n')+1
        for off,line in enumerate(m[0].splitlines()):
            if line.strip(): classes[start+off]=kind
    return line_entries(path,classes)
def coq(path):
    s=strip_comments(read(path)); lines=s.splitlines(); classes={}; mode=None; inv=False
    for i,line in enumerate(lines,1):
        t=line.strip()
        if not t or t.startswith('Print Assumptions'): continue
        if re.match(r'(Definition \w+_spec\b|Definition (sumZ|tnode)\b|Fixpoint listrep\b)',t): mode='spec'
        if t=='forward_while':
            classes[i]='proof'; inv=True; continue
        classes[i]='spec' if inv else mode or 'proof'
        if inv and t.endswith(')).'): inv=False
        if mode and t.endswith('.'): mode=None
    return line_entries(path,classes)
def isabelle(path):
    lines=strip_comments(read(path)).splitlines(); classes={}; mode=None; ml=False; inv=False
    for i,line in enumerate(lines,1):
        t=line.strip()
        if t.startswith('ML '): ml=True
        if ml:
            if '\\<close>' in t: ml=False
            continue
        if not t or t.startswith('thm '): continue
        if t.startswith(('definition ','primrec ')): mode='definition'
        if re.match(r'lemma (abs_val|swap|sum_array|binary_search|reverse)_correct:',t): mode='contract'
        if mode=='contract' and t.startswith(('proof','unfolding','apply','by')): mode=None
        if mode=='definition' and t.startswith(('lemma','lemmas','ML','end')): mode=None
        if 'supply runs_to_whileLoop' in t: inv=True
        classes[i]='spec' if mode or inv else 'proof'
        if inv and 'runs_to_vcg]' in t: inv=False
    return line_entries(path,classes)
rows=[]
for tool,prefix in [('WP','wp'),('VST','vst'),('RefinedC','refinedc'),('AutoCorres2','autocorres')]:
    checked=json.loads((OUT/f'{prefix}-checks.json').read_text())
    for n,program in enumerate(PROGRAMS,1):
        r=next(r for r in checked if r['program']==program)
        assert r['source_sha256']==hashlib.sha256((ROOT/r['source']).read_bytes()).hexdigest(),r['source']
        files=[r['source']]; entries=[]; manual=[]; generated=[]; timing=r['median_seconds']; memory_runs=list(r['runs'])
        if tool=='WP': entries=acsl(files[0])
        if tool=='VST': entries=coq(files[0]); manual=steps(files[0],'coq')
        if tool=='AutoCorres2': entries=isabelle(files[0]); manual=steps(files[0],'isabelle')
        if tool=='RefinedC':
            if n==2:
                files.append('refinedc/p2_swap_alias.c')
                alias=next(x for x in checked if x['program']=='p2_swap_alias')
                assert alias['source_sha256']==hashlib.sha256((ROOT/alias['source']).read_bytes()).hexdigest()
                memory_runs+=alias['runs']
                assert alias['passed']; timing=statistics.median(a['wall_seconds']+b['wall_seconds'] for a,b in zip(r['runs'],alias['runs']))
            for p in files: entries+=rc(p); manual+=steps(p,'c')
            if n==3:
                p='refinedc/proofs/p3_sum/sum_extra.v'; files.append(p)
                entries+=coq(p); manual+=steps(p,'coq')
            for stem in [program]+(['p2_swap_alias'] if n==2 else []):
                generated.extend(str(p.relative_to(ROOT)) for p in (ROOT/f'refinedc/proofs/{stem}').glob('generated_proof_*.v'))
        counts={k:sum(e['category']==k for e in entries) for k in ['spec','annotation','proof']}
        row=dict(tool=tool,program=program,status='verified' if r['passed'] else 'partial',
                 sources=files,spec_lines=counts['spec'],annotation_lines=counts['annotation'],
                 proof_script_lines=counts['proof'],manual_proof_steps=len(manual),
                 generated_proof_files=generated,generated_proof_lines=sum(sum(bool(x.strip()) for x in read(p).splitlines()) for p in generated),
                 median_seconds=timing,peak_rss_kb=max(x['peak_rss_kb'] or 0 for x in memory_runs),
                 deterministic=r['deterministic'],runs=r['runs'],line_audit=entries,step_audit=manual,
                 automation='manual proof' if manual else 'annotations only' if n>=3 else 'fully automatic')
        rows.append(row)
result=dict(method='Nonblank physical lines. Specs include predicates, contracts and external loop assertions; annotations are in-C attributes/comments. Proof lines include separate scaffolding and helper lemmas. See line_audit for every counted line. Manual steps are syntactic tactic occurrences (Rocq) or apply/by/proof(method) invocations (Isabelle); control combinators are not expanded. Embedded RefinedC tactics count as manual. Generated proofs are separately reported. Timing includes front-end and checking, excludes installation and cache cleanup; libraries/AFP parent heaps stay built. Three runs, tools run sequentially. Peak RSS is max child-process RSS reported by GNU time, not sum of concurrent processes.',
            rows=rows)
(OUT/'metrics.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps([{k:r[k] for k in ['tool','program','status','spec_lines','annotation_lines','proof_script_lines','manual_proof_steps','median_seconds']} for r in rows],indent=2))
