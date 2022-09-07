#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

BRANCH_PREFIX="ci-precommit-autoupdate"
BRANCH="$BRANCH_PREFIX-$(date --iso=seconds | tr '+:' '-')"
USER="$(glab api /user | jq .username -r)"
# shellcheck disable=SC2034
PAGER="cat"
MR="ci: pre-commit autoupdate"

while read -r file; do
    repo="$(dirname "$file")"
    echo "repo: $repo"
    pushd "$repo"
    git stash
    glab mr list --search "$MR" | grep "No open merge requests" || {
        popd
        continue
    }
    git checkout main || git checkout master &>/dev/null
    git pull
    git for-each-ref --format='%(refname:short)' refs/heads/ | { grep "$BRANCH_PREFIX" || true; } | xargs --no-run-if-empty --max-args 1 git branch -D
    sed -i "" 's!https://github.com/prettier/pre-commit!https://github.com/pre-commit/mirrors-prettier!' .pre-commit-config.yaml
    pre-commit autoupdate
    git checkout -b "$BRANCH"
    git add .pre-commit-config.yaml
    pre-commit run --all
    git commit .pre-commit-config.yaml -m "ci: pre-commit autoupdate"
    # glab mr list --search "$MR" | grep "No open merge requests" && {
    #     glab mr create --push \
    #         --title "$MR" \
    #         --remove-source-branch \
    #         --description "Update pre-commit hooks" \
    #         --yes \
    #         --assignee "$USER"
    # }
    popd
done < <(find ./ -name '.pre-commit-config.yaml' -not -path '*.terragrunt-cache*' | head -3)

exit 0
