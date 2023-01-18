#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

LOG=/tmp/$(basename "$0" .sh).log

src="$*"

if [[ -z $src ]]; then
    die "error, please specify a repo"
fi

repo=$(cut -d'"' -f2 <<<"$src")
repo=$(sed 's/\?ref.*//g' <<<"$repo")
module=$(basename "$repo")
repo=$(sed 's!//.*!!g' <<<"$repo")

export DRY=true
dest=$(awk '{print $5}' <<<"$(clone "$repo")")

file=$dest/$module/variables.tf
if [[ ! -f $file ]]; then
    file=$dest/module
fi

cat <<EOF >>"$LOG"
$(date --iso=seconds)
src: $src
repo: $repo
module: $module
dest: $dest
file: $file
EOF

echo "$file"

exit 0
