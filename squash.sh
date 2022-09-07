#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

main=$(git-main.sh)
message=$(git --no-pager log -n1 --format=%B "$(git cherry "$main" -v | head -1 | awk '{print $2}')")
git reset --soft "$(git merge-base "$main" "$(git rev-parse --abbrev-ref HEAD)")"
git commit -am "$message"
git rebase "$main"

exit 0
