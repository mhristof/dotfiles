#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

branch=$(git rev-parse --abbrev-ref HEAD)
git checkout "$(git-main.sh)"
git pull
git branch -m "$branch" "$branch-$(date --iso=seconds | tr -s ':' '-')"
git checkout "$branch"

exit 0
