# Deductive C verification experiment

## Publish with Cloudflare Pages

The GitHub repository is `ExcitedSpider/itp-c-lab`. Pages serves the committed
`dist/static/index.html`; no prover installation or build runs on Cloudflare.
The repository also includes the C sources, specifications, proofs, page source,
build scripts, and recorded verification evidence. Cloudflare serves only `dist/static`.

After changing the lab, rebuild and package using the existing container:

```sh
podman exec c-itp-wp python3 presentation/build.py
podman exec c-itp-wp python3 presentation/package_site.py
git add .gitignore README.md programs vst refinedc wp autocorres results presentation scripts dist/static
git commit -m "Update verification lab"
git push origin main
```

Use the SSH remote `git@github.com:ExcitedSpider/itp-c-lab.git`.
SSH authentication uses your configured SSH key.

In Cloudflare **Workers & Pages**, create a **Pages** project connected to
`ExcitedSpider/itp-c-lab`: production branch `main`, framework preset **None**,
build command blank, build output directory `dist/static`, root directory default.
Under the project's **Custom domains**, add `itp-c.qiuyif.org` and complete the
Cloudflare DNS setup. Subsequent pushes to `main` deploy the committed output.

## Explore the lab

Open `presentation/index.html` directly: a self-contained offline verification
lab with independent program and prover lists. Choose one of the 20 cases to
inspect its real sources, proofs, metrics and checker outputs. Setup, comparison
charts, notable projects, TCB and RLVR notes are expandable reference sections.
There is no slide navigation; Previous/Next controls only step through proofs.
VST and RefinedC tabs include offline proof steppers: actual Rocq responses and
`Show.` goal inspections recorded command by command, with source highlighting.
These are navigable recordings, not a live jsCoq checker; editing or checking
new tactics is not supported. RefinedC generated proofs and the authored P3
helper proof are labeled separately. AutoCorres2 also has recorded Isabelle
states for all five programs, using the same controls and arrow keys. WP shows
VC reports rather than an interactive proof script.
The authoritative experiment is in `results/rework/`. Earlier records in
`results/logs/` and JavaScript runners are historical and superseded.
The earlier installation-blocked diagnosis was incorrect. Direct Podman commands
worked without changing permissions. All four toolchains are installed.

| Tool | P1 abs | P2 swap + alias | P3 sum | P4 search | P5 reverse |
|---|---|---|---|---|---|
| VST-Floyd | checked | checked | checked | checked | checked |
| RefinedC | checked | checked | checked | checked | checked |
| Frama-C/WP | checked | checked | checked | checked | **partial** |
| AutoCorres2 | checked | checked | checked | checked | checked |

These are function-level safety and correctness proofs under the displayed
contracts. VST and RefinedC establish partial correctness; separate termination
proofs were not supplied. AutoCorres2 proves total correctness. WP includes
termination VCs. No compiler/linking theorem was instantiated. No admitted
project proof is counted as success. WP P5 closes 7/15 console obligations;
eight remain open after timeout. No interactive Rocq discharge is claimed.

## Reproduce in Podman

From this directory, with Podman available:

```sh
bash scripts/install.sh
bash vst/run.sh
bash refinedc/run.sh
bash wp/run.sh
bash autocorres/run.sh
podman exec c-itp-wp python3 results/measure.py
bash presentation/build.sh
```

Proof-state recordings are embedded in the HTML and stored under
`results/rework/proof-states/`, with exact commands, raw responses and source
hashes. After changing proof sources, regenerate them with
`bash presentation/record-proofs.sh` before building the page. This requires
the generated Clight and RefinedC dependencies already built; after a full
RefinedC check (which cleans between cases), restore all positive dependencies
with `podman exec c-itp-refinedc python3 refinedc/audit.py`. The builder rejects
stale recordings whose source hashes no longer match. Each compound tactic
is a single recorded step; the replay does not expand its internal execution.

For Isabelle alone: `podman exec c-itp-autocorres python3 autocorres/record.py`.
The capture sessions in `autocorres/recording/` load the unchanged original
theories with `Thy_Info.use_theories` and `record_theories=true`, then export
`Toplevel.pretty_state` after each parsed command. This includes actual Isar
goals and focused subgoals, not reconstructed build-log summaries. Theories
load under the capture namespace `Draft`; their source and proofs are unchanged.
Session commands/output and raw XML are in `results/rework/autocorres-record-p*.txt`
and `autocorres-p*-states.xml`. Empty state output means no open proof state;
other command messages remain in the session log. Each original theory's oracle
audit also executes, and skipped proofs are rejected by the recorder.

Each checker runs every positive case three times and checks a deliberately
broken P3 invariant. WP exits 2 while P5 remains partial; continue with the other
commands. The install script reproduces recorded operations and reuses project
containers; the script itself has not had a clean-room end-to-end test. Actual
installations and checks are logged. No host packages were installed. Separate
container-local switches isolate the Rocq/OCaml stacks.

Exact versions, image digests and logs are in `results/rework/setup.json`:

- VST 2.17, Rocq 9.1.0, stdlib 9.0.0, CompCert opam package 3.18.
  Installed `clightgen` reports 3.17; both strings are retained.
- RefinedC/Lithium commit `2e89846baeaa7f65cbe17e3ae7297a8ed5b4feca`,
  Rocq 9.1.0, Iris `dev.2026-09-10.3.b3495ef9`, stdpp
  `dev.2026-09-09.1.c3186aad`. Compatibility was checked before installation.
  The executable reports `2e89846-dirty` despite a clean source checkout.
- Frama-C 32.0 Germanium, Why3 1.8.2, Alt-Ergo 2.5.4, OCaml 4.14.2.
  Ordinary WP/Why3 invocation works; no exported-VC fallback is used.
- Isabelle2025-2, AFP 2026-10-16, Poly/ML 5.9.2. The image needed cpp;
  the missing-preprocessor error and successful retry are retained.

Recorded VST installation took about 17 minutes and RefinedC about 10 minutes.
AutoCorres2's parent build failed after about 6 minutes; after installing cpp,
the retry took about 8 minutes. These are observations, not clean-machine setup
benchmarks. Exact commands, exit codes, times and outputs are in `results/rework/`.

## Host on your LAN

```sh
bash presentation/serve.sh
```

Open `http://HOST-LAN-IP:8000` on another device on the same network, or
`http://localhost:8000` on this machine. Use the host address, not a container IP.
If the host firewall blocks TCP 8000, allow it on your trusted LAN. Ctrl-C stops
the disposable serving container. Only the presentation directory is served.
Use `LAB_PORT=8080 bash presentation/serve.sh` to select another port.

## Contracts and C differences

- P1 excludes INT_MIN and proves mathematical absolute value.
- P2 permits identical or separate pointers. VST and RefinedC prove separate
  specs for the two cases; WP and AutoCorres2 admit aliasing in one contract.
- P3 bounds every prefix sum by signed-int limits, including intermediate sums.
- P4 supports duplicates and empty arrays; proves a matching index or absence;
  uses a half-open interval and `lo+(hi-lo)/2` to avoid overflow.
- P5 uses finite inductive/recursive lists. VST and RefinedC prove reversed
  values; AutoCorres2 and unfinished WP also preserve node identities and values.
  Frame and ownership contracts are not identical.

VST and RefinedC own initialized arrays; WP permits read-only initialized
storage. Empty-array pointer domains can differ. AutoCorres2's default ARM model
uses 32-bit pointers; the other tested environments use x86_64/i32. RefinedC adds
attributes, a header and a node typedef. AutoCorres2 P1/P3 omit limits.h, used
only in ACSL. Executable function bodies otherwise match. The AutoCorres2 P5
proof adapts AFP ListRev and retains its BSD attribution. No VST-A run was made.

## Metrics and oracle boundaries

`results/rework/metrics.json` enumerates every counted physical line and every
recognized manual tactic/method occurrence. These are syntactic counts, not
executed tactics or equivalent units of cognitive effort. Generated RefinedC
proof text is separate; human proof scaffolding is included. External loop
assertions count as specifications.

Times are medians of three fresh local checks, including front-end and startup,
with installed libraries/AFP parent heaps retained. Tools ran sequentially.
RefinedC P2 sums alias and separate-case checks. RSS is the largest process
high-water mark, not total concurrent memory. Repeated Boolean outcomes agree;
this is not a general determinism guarantee. WP P5 times a failed attempt.
Recorded source hashes bind proof measurements to their inputs.

All four reject the +1 accumulator invariant. WP exposes JSON VC outcomes;
other runners retain process/session status and textual goals. An RL reward
must freeze C, contracts and helpers; reject stale/skipped proofs; require all
expected obligations; distinguish timeout, invalidity and infrastructure errors.
WP was fastest for these successful array cases. RefinedC is a useful Rocq-backed
pilot but P3/P4 need fixed pure-proof hooks. VST needs Floyd scaffolding;
AutoCorres2 needs HOL proofs and measures. Isabelle becomes more compelling
when integrating with seL4.

The presentation details the TCB and observed learning costs. VST's assumptions
include classical/extensionality axioms. RefinedC's six generated function/case
theorems audit closed under the global context. AutoCorres2 disables
quick_and_dirty and rejects oracle dependencies. WP trusts the VC pipeline
and SMT results without kernel certificate replay.
