#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

JIRAS="$(git log --pretty=format:%s master.. | grep -oP '[A-Z]{1,}-[0-9]{1,}' | sort -u | paste -s -d ','): " || {
    JIRAS=""
}

git reset --soft "$(git merge-base master "$(git rev-parse --abbrev-ref HEAD)")"
git commit -am "${JIRAS}$(git rev-parse --abbrev-ref HEAD)"
git rebase master

exit 0
