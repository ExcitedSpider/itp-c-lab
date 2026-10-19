#!/usr/bin/env bash
# Install the requested isolated toolchains. Existing containers are reused.
set -eu
cd "$(dirname "$0")/.."
lab_root="$PWD"
image='docker.io/framac/frama-c@sha256:35c7b8c98fa0109f4dcd44d59c3aa3245362ec8d0276df025986c2c0919c7777'
for tool in wp vst refinedc; do
  if ! podman container exists "c-itp-$tool"; then
    podman run -d --name "c-itp-$tool" --userns keep-id --entrypoint sleep \
      -v "$lab_root:/work:z" -w /work "$image" infinity
  fi
done
podman exec c-itp-wp python3 results/capture.py wp-why3-detect opam exec -- why3 config detect
for tool in vst refinedc; do
  podman exec "c-itp-$tool" python3 results/capture.py "$tool-default-repository" \
    opam repository set-url default https://opam.ocaml.org -y
  podman exec "c-itp-$tool" python3 results/capture.py "$tool-coq-repository" \
    opam repository add coq-released https://coq.inria.fr/opam/released -y
done
podman exec c-itp-vst python3 results/capture.py vst-install \
  opam install -y -j 4 coq.9.1.0 coq-vst.2.17 coq-compcert.3.18
podman exec c-itp-refinedc python3 results/capture.py refinedc-repository \
  opam repository add iris-dev https://gitlab.mpi-sws.org/iris/opam.git -y
podman exec c-itp-refinedc python3 results/capture.py refinedc-source sh -c \
  'test -d /home/opam/refinedc || git clone https://gitlab.mpi-sws.org/iris/refinedc.git /home/opam/refinedc; git -C /home/opam/refinedc checkout 2e89846baeaa7f65cbe17e3ae7297a8ed5b4feca'
podman exec c-itp-refinedc python3 results/capture.py refinedc-pins sh -c \
  'opam pin add -yn cerberus-lib git+https://github.com/rems-project/cerberus.git#f11e6b335a687c1b77539f7e5695607d09dfc3ea && opam pin add -yn coq-lithium /home/opam/refinedc && opam pin add -yn refinedc /home/opam/refinedc'
podman exec c-itp-refinedc python3 results/capture.py refinedc-install opam install -y -j 4 refinedc \
  coq.9.1.0 rocq-stdlib.9.0.0 rocq-iris.dev.2026-09-10.3.b3495ef9 \
  rocq-stdpp.dev.2026-09-09.1.c3186aad rocq-stdpp-bitvector.dev.2026-09-09.1.c3186aad \
  rocq-stdpp-unstable.dev.2026-09-09.1.c3186aad
if ! podman container exists c-itp-autocorres; then
  podman run -d --name c-itp-autocorres --userns keep-id:uid=1001,gid=1001 --entrypoint sleep \
    -v "$lab_root:/work:z" -w /work \
    docker.io/makarius/isabelle@sha256:9bd33b183c399327c5d554fc8cde27c29b5d2b20cdc6fe7a604caa3f951018fc infinity
fi
podman exec --user root c-itp-autocorres python3 results/capture.py autocorres-cpp-install \
  sh -c 'apt-get update && apt-get install -y cpp time'
podman exec c-itp-autocorres python3 results/capture.py afp-download \
  curl -fL https://www.isa-afp.org/release/afp-2026-10-16.tar.gz -o /tmp/afp.tar.gz
podman exec c-itp-autocorres python3 results/capture.py afp-extract sh -c \
  'sha256sum /tmp/afp.tar.gz && tar -xzf /tmp/afp.tar.gz -C /home/isabelle'
podman exec c-itp-autocorres python3 results/capture.py autocorres-build \
  /home/isabelle/Isabelle/bin/isabelle build -o threads=4 -d /home/isabelle/afp-2026-10-16/thys -b AutoCorres2
