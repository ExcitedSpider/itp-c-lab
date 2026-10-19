#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
exec podman exec c-itp-autocorres python3 /work/autocorres/check.py
