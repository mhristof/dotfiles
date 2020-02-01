#!/usr/bin/env bash
# :vi ft=bash:


set -euo pipefail

if [[ $(git config "branch.$(git rev-parse --abbrev-ref HEAD).merge") = '' ]]; then
    git push -u
else
    git push
fi
