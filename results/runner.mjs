import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
export const root = path.resolve(import.meta.dirname, '..');
process.chdir(root);
export function run(label, command, args=[], env={}, timeout=120000) {
  const start = performance.now();
  const r = spawnSync(command, args, {cwd:root, env:{...process.env,...env}, encoding:'utf8', timeout, maxBuffer:16*1024*1024});
  const record = {label, timestamp:new Date().toISOString(), cwd:root, command:[command,...args], env, exit_code:r.status, signal:r.signal, error:r.error?.message, wall_seconds:(performance.now()-start)/1000, stdout:r.stdout||'', stderr:r.stderr||''};
  fs.mkdirSync('results/logs',{recursive:true});
  fs.writeFileSync(`results/logs/${label}.json`,JSON.stringify(record,null,2)+'\n');
  fs.writeFileSync(`results/logs/${label}.txt`, `$ ${JSON.stringify(record.command)}\nEnvironment overrides: ${JSON.stringify(env)}\n${record.stdout}${record.stderr}${record.error?'\nRunner error: '+record.error:''}\nExit: ${record.exit_code}; signal: ${record.signal}; wall_seconds: ${record.wall_seconds}\n`);
  console.log(`${label}: exit=${r.status} ${record.wall_seconds.toFixed(3)}s\n${record.stdout}${record.stderr}`);
  return record;
}
export function sha(file) {return createHash('sha256').update(fs.readFileSync(file)).digest('hex');}
