import {run,sha} from '../results/runner.mjs';
const p='/tmp/framac/4.14.1';
const env={OCAMLPATH:`${p}/lib`,DUNE_DIR_LOCATIONS:`frama-c:share:${p}/share/frama-c:frama-c:lib:${p}/lib/frama-c`};
const file=process.argv[2];
const id=(file.includes('/broken/')?'broken-':'')+file.split('/').at(-1).replace('.c','');
const fingerprint=sha(file);
run(`${id}-export-all-${fingerprint.slice(0,12)}`,`${p}/bin/frama-c`,['-wp-why3-extra-config','wp/why3.conf','-machdep','x86_64','-wp','-wp-rte','-wp-prover','alt-ergo','-wp-timeout','1','-wp-par','64','-wp-msg-key','prover','-wp-out',`results/generated/${id}-${fingerprint.slice(0,12)}`,'-wp-report-json',`results/${id}-export-report.json`,file],env,600000);
