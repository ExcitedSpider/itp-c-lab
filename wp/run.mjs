import fs from 'node:fs';
import {run,sha} from '../results/runner.mjs';
const prefix=process.env.WP_PREFIX||'/tmp/framac/4.14.1';
const env={OCAMLPATH:`${prefix}/lib`,DUNE_DIR_LOCATIONS:`frama-c:share:${prefix}/share/frama-c:frama-c:lib:${prefix}/lib/frama-c`};
const fc=`${prefix}/bin/frama-c`;
const common=['-wp-why3-extra-config','wp/why3.conf','-machdep','x86_64','-wp','-wp-rte','-wp-prover','alt-ergo','-wp-par','1','-wp-timeout','10','-wp-cache','none'];
const mode=process.argv[2]||'all';
let failed=false;
if(mode==='smoke') {
  run('wp-version',fc,['-version'],env);
  run('alt-ergo-version',`${prefix}/bin/alt-ergo`,['--version']);
  run('wp-detect',fc,['-wp-why3-extra-config','wp/why3.conf','-wp-detect'],env);
} else {
  const files=fs.readdirSync('programs').filter(f=>/\.c$/.test(f)).filter(f=>mode==='all'||f.startsWith(mode));
  for(const file of files) {
    const count=process.env.RUNS?Number(process.env.RUNS):3;
    for(let i=1;i<=count;i++) {
      const label=`wp-${file.replace('.c','')}-${i}`;
      const r=run(label,'/usr/bin/time',['-f','PEAK_RSS_KB=%M',fc,...common,'-wp-out',`results/generated/${file.replace('.c','')}`,'-wp-report-json',`results/${label}-goals.json`,`programs/${file}`],env,600000);
      r.source_sha256=sha(`programs/${file}`);
      const matches=[...r.stdout.matchAll(/Proved goals:\s*(\d+)\s*\/\s*(\d+)/g)];
      const m=matches.at(-1);
      r.proved=m?+m[1]:null; r.total=m?+m[2]:null;
      r.all_generated_goals_closed=r.exit_code===0 && r.total>0 && r.proved===r.total && !/Warning|User Error|Failed|Unknown|Timeout/i.test(r.stdout);
      failed ||= !r.all_generated_goals_closed;
      r.peak_rss_kb=Number(r.stderr.match(/PEAK_RSS_KB=(\d+)/)?.[1])||null;
      fs.writeFileSync(`results/logs/${label}.json`,JSON.stringify(r,null,2)+'\n');
    }
  }
}
if(failed) process.exitCode=2;
