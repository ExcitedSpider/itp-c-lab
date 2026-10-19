"""Exercise the offline lab in bundled Chromium; no extra Python packages."""
import json,pathlib,subprocess,tempfile
root=pathlib.Path('/work')
source=(root/'presentation/index.html').read_text()
assert '<script src=' not in source and '<link ' not in source
chrome='/ms-playwright/chromium_headless_shell-1200/chrome-headless-shell-linux64/chrome-headless-shell'
test=r'''
<script>
window.addEventListener('load',()=>{try {
const check=(b,m)=>{if(!b)throw Error(m)};
check(document.querySelectorAll('.program-case').length===5,'program cases');
check(document.querySelectorAll('[data-program-choice]').length===5,'program list');
check(document.querySelectorAll('[data-prover-choice]').length===4,'prover list');
check(!document.querySelector('.slide,#previous,#next,#jump,footer'),'no slide navigation');
check(!document.querySelector('.proof-command,.proof-jump'),'no redundant command panel or jump selector');
for(const pane of document.querySelectorAll('.pane[data-tool=VST],.pane[data-tool=RefinedC],.pane[data-tool=AutoCorres2]')){
 check(pane.firstElementChild.classList.contains('replay'),'replay is first under case title');
}
check(document.querySelectorAll('.work-split').length===20,'authorship labels');
check(document.querySelectorAll('.proof-player').length===17,'recorded proof players');
const records=JSON.parse(document.querySelector('#proof-recordings').textContent);
const samples=[
 ['rocq','(* outer (* nested *) still comment *)\nLemma demo : forall x : Z, x = x. Proof. intros; reflexivity. Qed.'],
 ['c','/* ordinary requires */\n/*@ requires x > 0; ensures \\result == x; */\nint f(int x) { return x; }'],
 ['c','[[rc::tactics("all: try by lia.")]]\nint f(void) { return 0; }'],
 ['isabelle','lemma demo: "\\<forall>x::int. x = x" by simp'],
 ['rocq','Definition text := "<img src=x onerror=alert(1)>".']
];
for(const [lang,text] of samples){
 const tokens=LabSyntax.scan(text,lang),element=document.createElement('pre');
 LabSyntax.render(element,text,lang);
 check(tokens.map(t=>t.text).join('')===text&&element.textContent===LabSyntax.display(text,lang),'source-preserving highlighting '+lang);
 check(!element.querySelector('img,script'),'source remains inert');
}
check(LabSyntax.scan(samples[0][1],'rocq')[0].text==='(* outer (* nested *) still comment *)','nested proof comments');
check(LabSyntax.scan(samples[1][1],'c').some(t=>t.text==='requires'&&t.kind==='annotation'),'ACSL is code, not comment');
check(LabSyntax.scan(samples[2][1],'c').some(t=>t.text==='lia'&&t.kind==='tactic'),'embedded RefinedC tactics');
check(LabSyntax.scan(samples[3][1],'isabelle').some(t=>t.text==='\\<forall>'&&t.kind==='operator'),'Isabelle logical notation');
for(const rec of Object.values(records)){
 const element=[...document.querySelectorAll('.proof-player')].find(p=>p.dataset.recording===rec.source);
 check(element.querySelector('.proof-context').textContent===LabSyntax.display(rec.source_text,rec.language),'highlighted proof text with Isabelle Unicode rendering: '+rec.source);
}
for(const rec of Object.values(records)){
 check(rec.exit_code===0,'successful recording');
 check(rec.steps.some(s=>s.goal_output&&s.goal_output.includes('goal')),'actual goals');
 check(rec.language==='isabelle'?rec.steps.some(s=>s.command_name==='ML'&&s.command.includes('Thm_Deps.all_oracles'))&&!rec.steps.at(-1).proof_open:rec.steps.some(s=>s.command==='Qed.'),'completed proof');
}
const current=()=>document.querySelector('.program-case:not([hidden])');
const visible=()=>[...current().querySelectorAll('.pane')].filter(p=>getComputedStyle(p).display!=='none');
const program=p=>document.querySelector('[data-program-choice="'+p+'"]').click();
const prover=t=>document.querySelector('[data-prover-choice="'+t+'"]').click();
const expect=(p,t)=>{
 check(current().dataset.program===p,'program '+p);
 check(visible().length===1&&visible()[0].dataset.tool===t,'prover '+t);
 check(document.querySelectorAll('[data-program-choice][aria-pressed=true]').length===1,'one selected program');
 check(document.querySelectorAll('[data-prover-choice][aria-pressed=true]').length===1,'one selected prover');
 check(document.documentElement.scrollWidth<=innerWidth,'horizontal overflow');
 if(innerWidth===1920&&innerHeight===1080&&['VST','RefinedC','AutoCorres2'].includes(t)){
  const replay=visible()[0].querySelector('.replay'),box=replay.getBoundingClientRect();
  check(box.bottom+scrollY<=innerHeight,'whole replay fits 1080px viewport: '+p+'/'+t);
  check(box.bottom+scrollY>=innerHeight-40,'replay uses available height: '+p+'/'+t);
  for(const pre of replay.querySelectorAll('.proof-context,.proof-output')){
   check(pre.getBoundingClientRect().height>450,'expanded proof panes: '+p+'/'+t);
  }
 }
};
expect('p1_abs','VST');
const player=current().querySelector('.pane.active .proof-player');
check(player.querySelector('.proof-output').textContent.includes('goal'),'displayed proof goal');
const initial=player.querySelector('.proof-position').textContent;
player.querySelector('[data-proof=next]').click();
const advanced=player.querySelector('.proof-position').textContent;
check(initial!==advanced,'next proof command');
document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowLeft',bubbles:true,cancelable:true}));
check(player.querySelector('.proof-position').textContent===initial,'left arrow proof step');
document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true,cancelable:true}));
check(player.querySelector('.proof-position').textContent===advanced,'right arrow proof step');
prover('WP');program('p3_sum');expect('p3_sum','WP');
program('p1_abs');prover('VST');expect('p1_abs','VST');
check(player.querySelector('.proof-position').textContent===advanced,'preserved proof position');
player.querySelector('[data-proof=previous]').click();
check(player.querySelector('.proof-position').textContent===initial,'previous proof command');
player.querySelector('[data-proof=reset]').click();
check(player.querySelector('.proof-context mark').textContent.trim().startsWith('Require Import'),'from imports');
player.querySelector('[data-proof=proof]').click();
check(player.querySelector('.proof-context mark').textContent.trim()==='Proof.','first proof');
for(const p of ['p1_abs','p2_swap','p3_sum','p4_binary_search','p5_reverse']){
 program(p);
 for(const t of ['VST','RefinedC','WP','AutoCorres2']){prover(t);expect(p,t);}
}
program('p1_abs');prover('AutoCorres2');
const isa=visible()[0].querySelector('.proof-player');
isa.querySelector('[data-proof=proof]').click();
check(isa.querySelector('.proof-context mark').textContent.startsWith('lemma'),'Isabelle first proof');
for(let i=0;i<2;i++)document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true,cancelable:true}));
check(isa.querySelector('.proof-output').textContent.includes('2 subgoals'),'Isabelle real VCG state');
check(isa.querySelector('.proof-output').textContent.includes('⟹'),'Isabelle implication rendered');
check(!isa.querySelector('.proof-output').textContent.includes('\\<Longrightarrow>'),'no raw implication escape');
program('p5_reverse');prover('WP');
check(visible()[0].textContent.includes('7/15'),'partial proof remains explicit');
check(document.querySelector('[data-prover-choice=WP] .case-status').textContent==='Partial','partial selection badge');
history.replaceState(null,'','#program=p2_swap&prover=RefinedC');
window.dispatchEvent(new HashChangeEvent('hashchange'));expect('p2_swap','RefinedC');
const aliasPlayer=visible()[0].querySelectorAll('.proof-player')[1];
const aliasBefore=aliasPlayer.querySelector('.proof-position').textContent;
aliasPlayer.dispatchEvent(new Event('pointerdown',{bubbles:true}));
document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true,cancelable:true}));
check(aliasPlayer.querySelector('.proof-position').textContent!==aliasBefore,'arrows target last selected replay');
const reference=document.querySelector('.reference-section');
reference.querySelector('summary').click();check(reference.open,'expand reference');
reference.querySelector('summary').click();check(!reference.open,'collapse reference');
check(document.querySelectorAll('.reference-section').length===9,'reference material retained');
program('p1_abs');prover('VST');
document.body.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true}));
expect('p1_abs','VST');
document.querySelector('#theme').click();check(document.body.classList.contains('light'),'theme');
player.querySelector('[data-proof=proof]').click();
player.querySelector('[data-proof=next]').click();
player.querySelector('[data-proof=next]').click();
check(player.querySelector('.proof-output').textContent.includes('2 goals'),'branch goals');
check(player.querySelector('.proof-output .tok-goal').textContent.includes('2 goals'),'highlighted goal header');
check(player.querySelector('.proof-context mark .tok-tactic').textContent==='forward_if','current command retains syntax colors');
check(getComputedStyle(player.querySelector('.proof-context mark .tok-tactic')).color!==getComputedStyle(player.querySelector('.proof-context mark')).color,'visible syntax colors');
window.scrollTo(0,0);
const out=document.createElement('output');out.id='qa-result';out.textContent='PASS';out.hidden=true;document.body.append(out);
}catch(e){const out=document.createElement('output');out.id='qa-result';out.textContent='FAIL: '+e;document.body.append(out);}});
</script>'''
results=[]
with tempfile.TemporaryDirectory() as tmp:
    html=pathlib.Path(tmp)/'test.html';html.write_text(source.replace('</body>',test+'</body>'))
    for name,size in [('desktop','1920,1080'),('laptop','1440,1100'),('mobile','390,844')]:
        cmd=[chrome,'--headless','--no-sandbox','--disable-dev-shm-usage',
             '--no-first-run','--hide-scrollbars','--window-size='+size,
             '--virtual-time-budget=1000','--dump-dom',
             '--screenshot=/work/results/rework/'+name+'.png',html.as_uri()]
        r=subprocess.run(cmd,text=True,capture_output=True,timeout=60)
        (root/f'results/rework/browser-{name}.txt').write_text(json.dumps(cmd)+'\n'+r.stderr+'\nExit: '+str(r.returncode))
        assert r.returncode==0,r.stderr
        assert '<output id="qa-result" hidden="">PASS</output>' in r.stdout,r.stdout[-2500:]
        results.append({'viewport':size,'layout':name,'program_prover_combinations':20,
                        'no_slide_controls':True,'selection_persistence':True,'deep_links':True,
                        'reference_sections':9,'theme':True,'overflow':False,'proof_players':17,
                        'recorded_goals':True,'proof_navigation':True,'proof_arrow_keys':True,
                        'syntax_languages':['c','acsl','rocq','isabelle'],'lossless_highlighting':True})
(root/'results/rework/browser-qa.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results))
