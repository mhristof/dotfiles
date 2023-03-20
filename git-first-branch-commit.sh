#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

branch() {
    local commit
    commit=$1

    git branch -a --contains "$commit" | grep -v origin | sed 's/^\s*\*\s*//g' | awk '{print $1}'
}

commit=$(git rev-list --max-count=1 HEAD)
currentBranch=$(branch "$commit")

firstCommitOfBranch=$(git --no-pager log --format=%H main..$currentBranch | tail -1)

/bin/cat <<EOF
$(git --no-pager log --pretty=%s -n 1 "$firstCommitOfBranch")

$(git --no-pager log --pretty=%b -n 1 "$firstCommitOfBranch")
EOF

exit 0
