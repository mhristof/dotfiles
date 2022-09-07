#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

PATH="/usr/local/bin:$PATH"

eval "$(dirname "$0")/nvim-edit.py $*"

exit 0
