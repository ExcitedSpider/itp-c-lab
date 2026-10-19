# RefinedC

All five programs pass; swap has separate alias and disjoint cases. Run
`bash refinedc/run.sh` from the root. Each local build is cleaned before checking;
generated Rocq proofs remain in `proofs/`. P3 has a helper lemma and tactic hooks;
P4 has tactic hooks. These count as manual work, not annotation-only automation.
The deliberately broken P3 must fail. Exact pins and the pre-install Rocq
compatibility check are in `results/rework/`; see the root README for scope.
