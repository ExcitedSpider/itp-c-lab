import fs from 'node:fs';
import {run,sha} from '../results/runner.mjs';
const p='/tmp/framac/4.14.1';
const env={OCAMLPATH:`${p}/lib`,DUNE_DIR_LOCATIONS:`frama-c:share:${p}/share/frama-c:frama-c:lib:${p}/lib/frama-c`};
const parse=text=>JSON.parse(text.replace(/(:\s*-?\d+)\.(?=\s*[,}\]])/g,'$1.0'));
const files=process.argv.slice(2);
for(const file of files) {
 const id=(file.includes('/broken/')?'broken-':'')+file.split('/').at(-1).replace('.c','');
 const fingerprint=sha(file), dir=`results/generated/${id}-${fingerprint.slice(0,12)}`;
 const runs=[];
 for(let i=1;i<=3;i++) {
  const started=performance.now();
  const inventory=`results/${id}-inventory-${i}.json`;
  const gen=run(`${id}-inventory-${i}`,'/usr/bin/time',['-f','PEAK_RSS_KB=%M',`${p}/bin/frama-c`,'-wp-why3-extra-config','wp/why3.conf','-machdep','x86_64','-wp','-wp-rte','-wp-prover','alt-ergo','-wp-gen','-wp-report-json',inventory,file],env);
  const goals=fs.existsSync(inventory)?parse(fs.readFileSync(inventory,'utf8')):[];
  const exports=fs.existsSync(dir)?fs.readdirSync(dir,{recursive:true}).filter(f=>f.endsWith('.psmt2')).map(f=>`${dir}/${f}`):[];
  const rows=[]; let peak=+(gen.stderr.match(/PEAK_RSS_KB=(\d+)/)?.[1]||0);
  for(const g of goals) {
   if(g.passed){rows.push({...g,method:'Qed'});continue;}
   const matches=exports.filter(f=>f.split('/').at(-1).startsWith(`zilch-${g.goal}_AltmnErgo_`));
   if(matches.length!==1){rows.push({...g,method:'missing export'});continue;}
   const r=run(`${id}-${i}-${g.goal}`,'/usr/bin/time',['-f','PEAK_RSS_KB=%M',`${p}/bin/alt-ergo`,'--frontend','dolmen','--timelimit','3',matches[0]],{},8000);
   peak=Math.max(peak,+(r.stderr.match(/PEAK_RSS_KB=(\d+)/)?.[1]||0));
   rows.push({...g,passed:r.exit_code===0&&/^unsat$/m.test(r.stdout)&&/: Valid /.test(r.stdout+r.stderr)&&!/I don't know|Timeout|Error/.test(r.stdout+r.stderr),method:'Alt-Ergo (direct Why3-export replay)',export:matches[0],sha256:sha(matches[0]),log:r.label});
  }
  const warnings=gen.stdout.split('\n').filter(l=>/Warning|User Error/.test(l));
  runs.push({run:i,wall_seconds:(performance.now()-started)/1000,peak_rss_kb:peak,goals:rows,inventory_exit:gen.exit_code,warnings,all_obligations_closed:goals.length>0&&gen.exit_code===0&&rows.every(g=>g.passed)&&warnings.length===0});
 }
 const complete=runs.every(r=>r.all_obligations_closed);
 const same_outcomes=runs.every(r=>JSON.stringify(r.goals.map(g=>[g.goal,g.passed]))===JSON.stringify(runs[0].goals.map(g=>[g.goal,g.passed])));
 const data={source:file,source_sha256:fingerprint,mode:'Fresh WP inventory + replay of previously exported SMT tasks; NOT end-to-end source check timing',complete,same_outcomes,median_seconds:runs.map(r=>r.wall_seconds).sort((a,b)=>a-b)[1],peak_rss_kb:Math.max(...runs.map(r=>r.peak_rss_kb)),runs};
 fs.writeFileSync(`results/${id}-checked.json`,JSON.stringify(data,null,2)+'\n');
 console.log(`${id}: ${complete?'ALL EXPORTED OBLIGATIONS CHECKED':'PARTIAL'}; ${runs[0].goals.filter(g=>g.passed).length}/${runs[0].goals.length}`);
 if(!complete&&!id.startsWith('broken-'))process.exitCode=2;
 if(complete&&id.startsWith('broken-'))throw new Error('Negative control was unexpectedly accepted');
}
