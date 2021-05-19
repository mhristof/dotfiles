#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
die() {
    echo "$*" 1>&2
    exit 1
}

FILE=${1:-}

if [[ -z $FILE ]]; then
    die "Error, please provide a file name to search"
fi

for i in $(seq 1 10); do
    gh api "/search/code?q=filename:$FILE&per_page=100&page=$i" | jq '.items[].html_url' -r
done | tee "$FILE.list"
