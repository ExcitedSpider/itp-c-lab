"""Rebuild current positive inputs, then inspect their actual theorem assumptions."""
import json,pathlib,sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'results'))
from capture import capture
names=['p1_abs','p2_swap','p2_swap_alias','p3_sum','p4_binary_search','p5_reverse']
for name in names:
    r=capture('refinedc-audit-build-'+name,['opam','exec','--','refinedc','check','refinedc/'+name+'.c'])
    if r['exit_code']: sys.exit(r['exit_code'])
cmd=['opam','exec','--','coqtop','-quiet','-batch']
for name in names: cmd+=['-Q','refinedc/_build/default/proofs/'+name,'c_itp_refinedc.'+name]
cmd+=['-l','refinedc/audit.v']
r=capture('refinedc-assumptions-final',cmd)
assert r['exit_code']==0 and r['output'].count('Closed under the global context')==6
