# Isabelle/HOL + AutoCorres2

All five total-correctness proofs pass. Run `bash autocorres/run.sh` from the root.
Each program session is rebuilt three times against the prebuilt AFP heap.
The broken P3 session must fail. Project correctness theorems reject oracle
dependencies, and quick_and_dirty is disabled. ROOT pins the session layout;
the installation script pins Isabelle2025-2 / AFP 2026-10-16. The default ARM
model has 32-bit pointers. P5 retains attribution to AFP ListRev.
