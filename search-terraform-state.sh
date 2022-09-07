#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

NEEDLE=${1:-}
if [[ -z $NEEDLE ]]; then
    die "error, please provide an argument to search"
fi

if [[ ! -f buckets.txt ]]; then
    aws s3 ls | grep terraform | awk '{print $3}' >buckets.txt
    echo "created buckets.txt"
fi

if [[ ! -f files.txt ]]; then
    xargs -I{} bash -c 'aws s3 ls --recursive s3://{} | awk "{print \$4}" | sed "s!^!{}/!g"' <buckets.txt | tee files.txt
    echo "created files.txt"
fi

echo "Grepping for '$1'"
xargs -I{} bash -c 'aws s3 cp s3://{} - | sed "s!^!{}:!g"' <files.txt | grep "$1"

exit 0
