#!/usr/bin/env bash
# Optional convenience wrapper; equivalent Git commands are in README.md.
set -euo pipefail
cd "$(dirname "$0")/.."
repo=git@github.com:ExcitedSpider/itp-c-lab.git
test -f dist/static/index.html
git add .gitignore README.md programs vst refinedc wp autocorres results presentation scripts dist/static
if ! git diff --cached --quiet; then
  git commit -m 'Update C verification lab sources and static site'
fi
git push "$repo" HEAD:main
