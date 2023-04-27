#!/usr/bin/env bash
set -euo pipefail

source $HOME/bin/.lib
PATH=$(sed "s@$HOME/bin:@@" <<<"$PATH")

BIN=$(basename "$0")
which "$BIN" &>/dev/null || {
    brew install bats-core
    brew install parallel || true
}

PATH=$(dirname $(find /opt/homebrew/Cellar/parallel -name parallel -type f -path '*/bin/*')):$PATH
"$BIN" "$@"
