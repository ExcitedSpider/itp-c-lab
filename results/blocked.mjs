import {run} from './runner.mjs';
const tool=process.argv[2];
const probes={vst:[['coqc',['--version']],['clightgen',['-version']]],refinedc:[['rocq',['--version']],['refinedc',['--help']]],autocorres:[['isabelle',['version']]]};
for(const [exe,args] of probes[tool])run(`${tool}-${exe}-probe`,exe,args);
console.error(`${tool}: BLOCKED. No proof files were checked. See results/logs/podman-isolated.txt and network probes. Installing a tool later does not make absent proofs pass.`);
process.exitCode=2;
