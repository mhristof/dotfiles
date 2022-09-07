#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CACHE="$XDG_CACHE_HOME/$(basename "$0")"
if [[ ! -d $CACHE ]]; then
    mkdir -p "$CACHE"
fi

CACHE_FILE=$CACHE/$(git rev-parse --show-toplevel | md5sum | awk '{print $1}')

if [[ -f $CACHE_FILE ]]; then
    main="$(cat "$CACHE_FILE")"
else
    main=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
    echo "$main" >"$CACHE_FILE"
fi

echo "$main"

exit 0
