#!/usr/bin/env bash
# :vi ft=bash:


set -euo pipefail

if [[ $(git config "branch.$(git rev-parse --abbrev-ref HEAD).merge") = '' ]]; then
    git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)
else
    git push
fi
