#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
  echo "$*" 1>&2
  exit 1
}

DEST="${1:-/tmp/clipboard.txt}"

rm -f "$DEST" || true

previous_clipboard=""
while True; do
  clipboard=$(pbpaste)

  if [[ $clipboard != "$previous_clipboard" ]]; then
    previous_clipboard="$clipboard"
    echo "$clipboard" >>"$DEST"
    echo "$(date --iso-8601=seconds) - Clipboard updated"
  fi

  sleep 1
done

echo "Clipboard monitoring stopped. Result saved to $DEST."
exit 0
