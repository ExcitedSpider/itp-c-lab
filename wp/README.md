# Frama-C/WP

P1–P4 pass using ordinary WP/Why3/Alt-Ergo. P5 remains partial (7/15 console
goals); no interactive Rocq proof is claimed. Run `bash wp/run.sh` from the root.
It performs three runs per case, checks JSON goal statuses rather than trusting
exit 0, and requires rejection of the broken P3 invariant. Exit 2 is expected
while P5 is open. Earlier JavaScript exported-VC runners are historical only.
