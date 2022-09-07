#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

branch() {
    local commit
    commit=$1

    git branch -a --contains "$commit" | grep -v origin | sed 's/^\s*\*\s*//g' | awk '{print $1}'
}

commit=$(git rev-list --max-count=1 HEAD)

while true; do
    currentBranch=$(branch "$commit")
    parrent=$(git log --pretty=%P -n 1 "$commit")
    parrentBranch=$(branch "$parrent" | { grep -v "$currentBranch" || true; })

    if [[ "$currentBranch" != "$parrentBranch" ]]; then
        break
    fi
done

/bin/cat <<EOF
$(git --no-pager log --pretty=%s -n 1 "$commit")

$(git --no-pager log --pretty=%b -n 1 "$commit")
EOF

exit 0
