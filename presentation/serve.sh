#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
exec podman run --rm --name c-itp-presentation --userns keep-id \
  -p "${LAB_BIND:-0.0.0.0}:${LAB_PORT:-8000}:8000" \
  -v "$PWD/presentation:/site:ro,z" -w /site --entrypoint python3 \
  docker.io/framac/frama-c@sha256:35c7b8c98fa0109f4dcd44d59c3aa3245362ec8d0276df025986c2c0919c7777 \
  -m http.server 8000 --bind 0.0.0.0
