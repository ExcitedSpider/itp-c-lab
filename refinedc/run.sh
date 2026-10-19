#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
exec podman exec c-itp-refinedc python3 /work/refinedc/check.py
