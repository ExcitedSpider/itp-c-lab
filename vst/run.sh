#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
exec podman exec c-itp-vst python3 /work/vst/check.py
