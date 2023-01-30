#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

if [[ ! -f snapshots.json ]]; then
    aws ec2 describe-snapshots --owner-ids self | jq '.Snapshots[]' -cr >snapshots.json
fi

echo "total: $(wc -l snapshots.json)"

YEAR=$(date +%Y)
for ((i = YEAR - 10; i <= YEAR; i++)); do
    echo "$i $(grep -c $i snapshots.json)"
done
MONTH=$(date +%m)
for ((i = 1; i <= MONTH; i++)); do
    month=$(printf "%02d" $i)
    echo "$YEAR-$month $(grep -c "StartTime\":\"$YEAR-$month" snapshots.json)"
done

for reason in CreateImage policy- AWS\ Backup\ service; do
    echo "$reason: $(grep -c "$reason" snapshots.json)"
done

exit 0
