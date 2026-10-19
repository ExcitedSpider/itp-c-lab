#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
exec podman exec c-itp-wp python3 /work/presentation/build.py
