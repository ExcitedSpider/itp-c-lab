"""Replay repository proof commands in real coqtop and retain every response.

Run inside c-itp-vst or c-itp-refinedc. No synthetic goals or modified proofs.
The small lexer recognizes sentence ends, nested comments, strings and bullets;
Rocq itself parses and checks each resulting command.
"""
import hashlib,json,os,pathlib,re,select,subprocess,sys,time
ROOT=pathlib.Path(__file__).resolve().parent.parent
def commands(source):
    start=0;i=0;comment=0;quoted=False
    while i<len(source):
        if comment:
            if source.startswith('(*',i):comment+=1;i+=2
            elif source.startswith('*)',i):comment-=1;i+=2
            else:i+=1
            continue
        if quoted:
            if source[i]=='"':
                if source[i:i+2]=='""':i+=2;continue
                quoted=False
            i+=1;continue
        if source.startswith('(*',i):comment=1;i+=2;continue
        if source[i]=='"':quoted=True;i+=1;continue
        prefix=re.sub(r'\(\*[\s\S]*?\*\)','',source[start:i]).strip()
        if not prefix and source[i] in '{}':
            yield start,i+1,source[start:i+1];start=i+1;i+=1;continue
        if not prefix and source[i] in '-+*':
            m=re.match(r'([-+*])\1*(?=\s)',source[i:])
            if m:
                end=i+len(m[0]);yield start,end,source[start:end];start=end;i=end;continue
        if source[i]=='.' and (i+1==len(source) or source[i+1].isspace() or source.startswith('(*',i+1)):
            yield start,i+1,source[start:i+1];start=i+1
        i+=1
    assert not re.sub(r'\(\*[\s\S]*?\*\)','',source[start:]).strip(),'Unterminated command'

class Session:
    def __init__(self,argv):
        self.p=subprocess.Popen(argv,cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,bufsize=0)
        self.buffer=b''
    def response(self,timeout=120):
        deadline=time.monotonic()+timeout
        while b'</prompt>' not in self.buffer:
            remaining=deadline-time.monotonic()
            if remaining<=0:raise TimeoutError('coqtop command timed out')
            if not select.select([self.p.stdout],[],[],remaining)[0]:continue
            part=os.read(self.p.stdout.fileno(),65536)
            if not part:raise RuntimeError('coqtop exited before prompt: '+self.buffer.decode(errors='replace'))
            self.buffer+=part
        end=self.buffer.index(b'</prompt>')+len(b'</prompt>')
        raw=self.buffer[:end].decode();self.buffer=self.buffer[end:]
        m=re.search(r'<prompt>([\s\S]*?)</prompt>',raw)
        return raw,raw[:m.start()].strip(),m[1]
    def close(self):
        if self.p.poll() is None:self.p.terminate()
        try:self.p.wait(timeout=5)
        except subprocess.TimeoutExpired:self.p.kill();self.p.wait()

def record(path,tool,flags):
    source=(ROOT/path).read_text();argv=['opam','exec','--','coqtop','-quiet','-emacs',*flags]
    session=Session(argv);steps=[];began=time.monotonic()
    try:
        initial=session.response()[0]
        for start,end,command in commands(source):
            before=time.monotonic();session.p.stdin.write((command+'\n').encode());session.p.stdin.flush()
            raw,output,prompt=session.response()
            if re.search(r'\b(?:Error|Anomaly):',output):raise RuntimeError(path+'\n'+command+'\n'+output)
            query=None;query_raw='';goals=''
            # -quiet suppresses automatic goal printing. Ask explicitly while
            # a proof is open, including solved but not yet Qed proof states.
            if re.search(r'\|[^|]+\|',prompt):
                query='Show.';session.p.stdin.write(b'Show.\n');session.p.stdin.flush()
                query_raw,goals,_=session.response()
                if re.search(r'\b(?:Error|Anomaly):',goals):raise RuntimeError(query_raw)
            steps.append(dict(command=command.strip(),start=start,end=end,
                              line=source[:start].count('\n')+1,output='\n\n'.join(x for x in [output,goals] if x),
                              command_output=output,goal_output=goals,inspection_query=query,
                              inspection_response=query_raw,raw_response=raw,
                              prompt=prompt,seconds=time.monotonic()-before))
        session.p.stdin.close();session.p.wait(timeout=10)
        assert session.p.returncode==0
    finally:session.close()
    assert any('goal' in s['goal_output'] for s in steps),'Missing actual goal displays'
    result=dict(tool=tool,source=path,source_text=source,source_sha256=hashlib.sha256(source.encode()).hexdigest(),
                argv=argv,cwd='/work',initial_response=initial,steps=steps,
                total_seconds=time.monotonic()-began,exit_code=0,
                mode='Recorded actual coqtop responses; not a live browser checker')
    target=ROOT/'results/rework/proof-states'/tool/(pathlib.Path(path).stem+'.json')
    target.parent.mkdir(parents=True,exist_ok=True);target.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(path,len(steps),'commands,',round(result['total_seconds'],2),'seconds',flush=True)

if __name__=='__main__':
    tool=sys.argv[1]
    if tool=='vst':
        for i in range(1,6):record(f'vst/verif_p{i}.v',tool,['-Q','vst/generated','CPrograms'])
    elif tool=='refinedc':
        for name in ['p1_abs','p2_swap','p2_swap_alias','p3_sum','p4_binary_search','p5_reverse']:
            flags=['-Q','refinedc/_build/default/proofs/'+name,'c_itp_refinedc.'+name]
            for path in sorted((ROOT/f'refinedc/proofs/{name}').glob('generated_proof_*.v')):
                record(str(path.relative_to(ROOT)),tool+'-'+name,flags)
        record('refinedc/proofs/p3_sum/sum_extra.v','refinedc-helper',[])
    else:raise ValueError(tool)
