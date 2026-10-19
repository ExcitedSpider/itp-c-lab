# VST-Floyd

All five function proofs pass, including distinct and identical swap pointers.
Run `bash vst/run.sh` from the repository root. It regenerates Clight and checks
the AST and proofs three times, then requires the broken P3 proof to fail.
See `results/rework/vst-checks.json` and stage logs for exact commands/output.
Versions and proof boundaries are documented in the root README. Printed
assumptions are retained; no VST-A or compiler-link theorem is claimed.
