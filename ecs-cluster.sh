#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

CLUSTER=${1:-}

if [[ -z $CLUSTER ]]; then
    die "Plese provide cluster"
fi

while read -r line; do
    id="$(basename "$line")"
    task="$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$id")"
    jq '.tasks[].containers[] | .name, " ", .image, " ", (.imageDigest | split(":")[1] | .[0:7])' -j <<<"$task"
    echo ""

done < <(aws ecs list-tasks --cluster "$CLUSTER" | jq '.taskArns[]' -r) | column -t

exit 0
