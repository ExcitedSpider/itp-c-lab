# C verification lab

An interactive comparison of four deductive C verification tools: **VST-Floyd**,
**RefinedC**, **Frama-C/WP**, and **Isabelle/HOL with AutoCorres2**. The lab shows
what each tool requires you to write, what it generates, and what its checker
actually proves.

## Build the static website

The repository includes the proof sources, recorded proof states, and measured
results needed to build the page. Building the website does **not** rerun the
verifiers or require their toolchains. The builder uses Python 3's standard
library; there are no npm dependencies or frontend compilation steps.

From the repository root, build and package using Podman:

```sh
podman run --rm \
  -v "$PWD":/work:z -w /work \
  --entrypoint /bin/sh docker.io/framac/frama-c:32.0 \
  -c 'python3 presentation/build.py && python3 presentation/package_site.py'
```

This reuses the experiment's container image; no verifier is invoked. If the
project's `c-itp-wp` container is already running with this checkout mounted at
`/work`, use:

```sh
podman exec c-itp-wp python3 presentation/build.py
podman exec c-itp-wp python3 presentation/package_site.py
```

Alternatively, with Python 3 already available:

```sh
python3 presentation/build.py
python3 presentation/package_site.py
```

The first command generates `presentation/index.html`. The second copies it to
**`dist/static/index.html`**, the deployment artifact. It is one self-contained
HTML file with embedded styles, JavaScript, code, metrics, and proof recordings.
Open it directly in a browser; no server or network connection is needed.

For Cloudflare Pages, connect this GitHub repository and configure:

| Setting | Value |
| --- | --- |
| Production branch | `main` |
| Framework preset | None |
| Build command | Leave blank |
| Build output directory | `dist/static` |

Rebuild and commit `dist/static/index.html` when the site changes. Pages deploys
that committed file. Configure `itp-c.qiuyif.org` under the project's custom domains.

## What the lab does

Choose a program and a prover to inspect the C code, specifications, proof scripts,
and recorded checker output. The five examples cover progressively richer reasoning:

| Program | Verification task |
| --- | --- |
| Absolute value | Integer bounds, excluding `INT_MIN` |
| Pointer swap | Memory ownership and pointer aliasing |
| Array sum | Loop invariants and signed-overflow bounds |
| Binary search | Sorted arrays, matching indices, and absence of a key |
| Linked-list reversal | Mutable pointers and inductive list predicates |

VST, RefinedC, and AutoCorres2 include step-by-step replays of real recorded
Rocq or Isabelle proof states. Use the buttons or **← / →** to navigate. These
are offline recordings, not live proof assistants: editing or checking new
tactics in the browser is not supported. WP shows its verification-condition
reports and solver outcomes.

The comparison distinguishes authored specifications and proofs from generated
code. It includes proof-size counts, manual-step counts, median check times over
three runs, memory measurements, trust assumptions, and diagnostics from a
deliberately broken loop invariant. It also assesses the tools as reward oracles
for reinforcement learning with verifiable rewards (RLVR), particularly for
loop-invariant generation.

### Verification results

**19 of 20 tool/program cases are checked under their displayed contracts.**
VST, RefinedC, and AutoCorres2 check all five programs. WP checks the first four;
list reversal remains partial, with 7 of 15 console obligations closed and eight
open after timeout. No interactive Rocq discharge is claimed for those goals.

The contracts and memory models differ in places; the lab documents those
differences. VST and RefinedC establish functional partial correctness, without
separate termination proofs. AutoCorres2 proves total correctness, and WP includes
termination obligations. No binary/compiler-link theorem is instantiated.
Unfinished proofs are not presented as successful checks.

## Source and evidence

| Directory | Contents |
| --- | --- |
| `programs/` | Common C examples |
| `vst/`, `refinedc/`, `wp/`, `autocorres/` | Tool-specific inputs, specifications, proofs, and check scripts |
| `results/rework/` | Authoritative versions, commands, outputs, metrics, and proof-state recordings |
| `presentation/` | HTML generator, styling, highlighting, player, and browser checks |
| `dist/static/` | Compiled website served by Cloudflare Pages |
| `scripts/` | Toolchain installation and publishing helpers |

Earlier results outside `results/rework/` are retained as development history.
Exact tool versions and environment details are recorded in
[`results/rework/setup.json`](results/rework/setup.json).

### Changing proofs

Rebuilding HTML only republishes existing evidence. To change a proof, rerun the
corresponding tool's `run.sh` in the installed experiment environment and regenerate
the affected evidence. Proof recordings include source hashes; the page builder
rejects recordings whose proof sources have changed.

With the experiment containers and generated dependencies available, regenerate
the recordings using `bash presentation/record-proofs.sh`, then rebuild and package
the HTML. After a full RefinedC check, restore its positive dependencies first with
`podman exec c-itp-refinedc python3 refinedc/audit.py`.

Tool setup is in `scripts/install.sh`; per-tool details are in their directories.
The installer records the installation procedure but has not had a clean-room
end-to-end reproduction test. Installing these toolchains is unnecessary for
building or hosting the static website.
