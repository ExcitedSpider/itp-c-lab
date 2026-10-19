// Fallback for an environment where Why3's prover server cannot start.
// Every unresolved WP property must map to an exported goal and direct SMT result.
import fs from 'node:fs';
import {run,sha} from '../results/runner.mjs';
const p='/tmp/framac/4.14.1';
const env={OCAMLPATH:`${p}/lib`,DUNE_DIR_LOCATIONS:`frama-c:share:${p}/share/frama-c:frama-c:lib:${p}/lib/frama-c`};
const fc=`${p}/bin/frama-c`;
const base=['-wp-why3-extra-config','wp/why3.conf','-machdep','x86_64','-wp','-wp-rte','-wp-prover','alt-ergo','-wp-cache','none'];
const files=process.argv.slice(2);
for(const file of files) {
  const id=(file.includes('/broken/')?'broken-':'')+file.split('/').at(-1).replace('.c','');
  const dir=`results/replay/${id}`;
  fs.mkdirSync(dir,{recursive:true});
  const report=`${dir}/goals.json`;
  const gen=run(`${id}-inventory`,fc,[...base,'-wp-gen','-wp-report-json',report,file],env);
  if(!fs.existsSync(report)){continue;}
  // Why3 1.7.2 / WP 30 emits OCaml float literals such as 0. in this report.
  const goals=JSON.parse(fs.readFileSync(report,'utf8').replace(/(:\s*-?\d+)\.(?=\s*[,}\]])/g,'$1.0'));
  for(const property of new Set(goals.filter(g=>!g.passed).map(g=>g.property))) {
    const out=`${dir}/${property}`;
    run(`${id}-export-${property}`,'timeout',['-k','1','1',fc,...base,'-wp-prop',property,'-wp-par','1','-wp-out',out,file],env,5000);
  }
  const exports=fs.readdirSync(dir,{recursive:true}).filter(f=>f.endsWith('.psmt2')).map(f=>`${dir}/${f}`);
  const results=[];
  for(const goal of goals) {
    if(goal.passed){results.push({...goal,method:'Qed'});continue;}
    const candidates=exports.filter(f=>f.split('/').at(-1).startsWith(`zilch-${goal.goal}_AltmnErgo_`));
    if(candidates.length!==1){results.push({...goal,method:'missing export',candidates});continue;}
    const r=run(`${id}-smt-${goal.goal}`,`${p}/bin/alt-ergo`,['--frontend','dolmen','--timelimit','5',candidates[0]],{},8000);
    const passed=r.exit_code===0 && /^unsat$/m.test(r.stdout) && /: Valid /.test(r.stdout+r.stderr) && !/I don't know|Timeout|Error/.test(r.stdout+r.stderr);
    results.push({...goal,passed,method:'direct Alt-Ergo on Why3 export',export:candidates[0],sha256:sha(candidates[0]),log:r.label});
  }
  fs.writeFileSync(`${dir}/coverage.json`,JSON.stringify({source:file,source_sha256:sha(file),inventory_exit:gen.exit_code,goals:results,complete:goals.length>0&&results.every(g=>g.passed)},null,2)+'\n');
  console.log(`${id}: ${results.filter(g=>g.passed).length}/${results.length} mapped obligations closed`);
}
