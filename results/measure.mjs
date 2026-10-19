import fs from 'node:fs';
import {sha} from './runner.mjs';
const rows=[];
for(const file of fs.readdirSync('programs').filter(f=>f.endsWith('.c'))) {
 const id=file.replace('.c',''), source=fs.readFileSync(`programs/${file}`,'utf8');
 let spec=0, annotation=0;
 const lineMap=[];
 for(const m of source.matchAll(/\/\*@([\s\S]*?)\*\//g)) {
  const isLoop=/\b(loop|assert|ghost)\b/.test(m[1]);
  const before=source.slice(0,m.index).split('\n').length;
  m[1].split('\n').forEach((l,i)=>{if(l.trim()){if(isLoop)annotation++;else spec++;lineMap.push({line:before+i,kind:isLoop?'annotation':'spec'});}});
 }
 const record=`results/${id}-checked.json`;
 const check=fs.existsSync(record)?JSON.parse(fs.readFileSync(record)):null;
 const fresh=check?.source_sha256===sha(`programs/${file}`);
 const normal=[1,2,3].map(i=>`results/logs/wp-${id}-${i}.json`).filter(f=>fs.existsSync(f)).map(f=>JSON.parse(fs.readFileSync(f)));
 const endToEnd=normal.length===3&&normal.every(r=>r.source_sha256===sha(`programs/${file}`)&&r.all_generated_goals_closed)?normal.map(r=>r.wall_seconds).sort((a,b)=>a-b)[1]:null;
 rows.push({tool:'WP',program:id,source:`programs/${file}`,source_sha256:sha(`programs/${file}`),spec_lines:spec,annotation_lines:annotation,proof_script_lines:0,manual_proof_steps:0,counted_lines:lineMap,automation:'annotations only',status:fresh&&check.complete?'exported VCs checked':'partial',replay_median_seconds:fresh?check.median_seconds:null,end_to_end_median_seconds:endToEnd,peak_rss_kb:fresh?check.peak_rss_kb:null,goals:fresh?check.runs[0].goals.length:null,closed:fresh?check.runs[0].goals.filter(g=>g.passed).length:null});
 for(const tool of ['VST','RefinedC','AutoCorres2'])rows.push({tool,program:id,status:'blocked',spec_lines:null,annotation_lines:null,proof_script_lines:null,manual_proof_steps:null,replay_median_seconds:null,end_to_end_median_seconds:null,peak_rss_kb:null,automation:'not measured'});
}
fs.writeFileSync('results/metrics.json',JSON.stringify({method:'Nonempty physical ACSL lines, delimiters excluded; loop blocks separate. No manual proof files: exactly 0 tactic/Isar/apply steps for WP. Absent tool artifacts are null, never 0. Replay time is NOT source-to-proof latency.',rows},null,2)+'\n');
