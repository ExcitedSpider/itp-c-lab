#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
# Uses existing checked/generated .vo dependencies in the project containers.
podman exec c-itp-vst python3 results/record_proofs.py vst
podman exec c-itp-refinedc python3 results/record_proofs.py refinedc
podman exec c-itp-autocorres python3 autocorres/record.py
podman exec c-itp-wp python3 presentation/build.py
