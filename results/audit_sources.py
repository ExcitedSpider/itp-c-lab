"""Check executable function-token equality and scan project proof admissions."""
import hashlib,json,pathlib,re
root=pathlib.Path(__file__).resolve().parent.parent
programs=['p1_abs','p2_swap','p3_sum','p4_binary_search','p5_reverse']
functions=['abs_val','swap','sum_array','binary_search','reverse']
def body(path,fn):
    s=path.read_text()
    s=re.sub(r'/\*[\s\S]*?\*/|//[^\n]*','',s)
    s=re.sub(r'\[\[rc::[\s\S]*?\]\]','',s)
    m=re.search(r'\b'+fn+r'\([^;{}]*\)\s*\{',s)
    assert m,path
    # Each input ends with its single function. Compare body tokens, not comments/header/type aliases.
    return re.findall(r'\w+|[^\s]',s[m.end()-1:])
report=[]
for i,(p,fn) in enumerate(zip(programs,functions),1):
    common=root/f'programs/{p}.c'; targets=[root/f'refinedc/{p}.c']
    if i==2: targets.append(root/'refinedc/p2_swap_alias.c')
    if i in (1,3): targets.append(root/f'autocorres/p{i}/{p}.c')
    for target in targets:
        assert body(common,fn)==body(target,fn),target
        report.append({'common':str(common.relative_to(root)),'adapted':str(target.relative_to(root)),'function_tokens_equal':True})
proofs=list((root/'vst').glob('verif_p*.v'))+list((root/'refinedc/proofs').rglob('*.v'))+list((root/'autocorres').rglob('*.thy'))
for p in proofs:
    text=re.sub(r'\(\*[\s\S]*?\*\)','',p.read_text())
    assert not re.search(r'\b(Admitted|admit|sorry|oops)\b',text),p
result={'function_body_checks':report,'proof_files_scanned':len(proofs),'admission_tokens':0,
        'sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in proofs}}
(root/'results/rework/source-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'function_body_checks':len(report),'proof_files_scanned':len(proofs),'admission_tokens':0}))
