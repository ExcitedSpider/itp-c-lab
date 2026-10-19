import fs from 'node:fs';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {run,sha} from './runner.mjs';
const positive=['p1_abs','p2_swap','p3_sum','p4_binary_search','p5_reverse'];
for(const id of [...positive,'broken-p3_sum']) {
 const file=`results/${id}-checked.json`;
 const c=JSON.parse(fs.readFileSync(file));
 assert.equal(c.source_sha256,sha(c.source),`Stale source for ${id}`);
 assert.equal(c.runs.length,3);
 for(const r of c.runs)for(const g of r.goals) {
  if(g.export)assert.equal(g.sha256,sha(g.export));
  if(g.passed&&g.method!=='Qed') {
   const log=JSON.parse(fs.readFileSync(`results/logs/${g.log}.json`));
   assert.equal(log.exit_code,0);
   assert.match(log.stdout,/^unsat$/m);
   assert.match(log.stdout+log.stderr,/: Valid /);
   assert.ok(log.command.includes(g.export));
  }
 }
 assert.equal(c.complete,c.runs.every(r=>r.all_obligations_closed));
}
const good=fs.readFileSync('programs/p3_sum.c','utf8');
const bad=fs.readFileSync('wp/broken/p3_sum.c','utf8');
assert.equal(good.replace('loop invariant s == prefix_sum(a,i);','loop invariant s == prefix_sum(a,i) + 1;'),bad,'Negative control changed more than the invariant');
assert.equal(JSON.parse(fs.readFileSync('results/broken-p3_sum-checked.json')).complete,false);
const html=fs.readFileSync('presentation/index.html','utf8');
assert.equal((html.match(/class="slide"/g)||[]).length,13);
assert.ok(!/<(?:script|link)[^>]+(?:src|href)=/i.test(html),'External dependency in self-contained page');
new vm.Script(html.match(/<script>([\s\S]*?)<\/script>/)[1]);
const gcc=run('c-syntax','gcc',['-std=c11','-Wall','-Wextra','-Werror','-fsyntax-only',...positive.map(id=>`programs/${id}.c`)]);
assert.equal(gcc.exit_code,0);
const binaries=['/tmp/framac/4.14.1/bin/frama-c','/tmp/framac/4.14.1/bin/alt-ergo'];
fs.writeFileSync('results/binary-hashes.json',JSON.stringify(binaries.map(file=>({file,sha256:sha(file)})),null,2)+'\n');
fs.copyFileSync('/tmp/framac/4.14.1/.opam-switch/switch-state','results/wp-switch-state.txt');
fs.writeFileSync('results/audit.json',JSON.stringify({passed:true,checks:['source SHA256 match','export SHA256 match','every positive SMT verdict backed by exact command and successful real output','three runs per WP program','negative control changes exactly one invariant and is rejected','13-slide self-contained HTML; inline JavaScript parses','C syntax with GCC warnings as errors'],browser:'Not validated: Chrome aborts on prohibited socket operation'},null,2)+'\n');
console.log('Evidence audit passed. Browser rendering was not validated.');
