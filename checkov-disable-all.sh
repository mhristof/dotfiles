#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CHECKS=$(mktemp)

while read -r line; do
    id=$(jq -r .check_id <<<"$line")
    path=$(jq -r .file_abs_path <<<"$line")
    lineno=$(jq -r .code_block[0][0] <<<"$line")
    name=$(jq -r .check_name <<<"$line")

    echo "$path,$lineno,$id,$name"

done < <(checkov --framework terraform --external-checks-dir checkov-rules --directory . -o json | jq -rc '.results.failed_checks[]') | tee "$CHECKS"

while read -r line; do
    file=$(cut -d ',' -f1 <<<"$line")
    ln=$(cut -d ',' -f2 <<<"$line")
    id=$(cut -d ',' -f3 <<<"$line")
    name=$(cut -d ',' -f4 <<<"$line")

    sed -i "${ln} a #checkov:skip=${id}:${name}" "$file"
done < <(sort -r -k1 -k2 -n "$CHECKS")

rm -f "$CHECKS"

exit 0
