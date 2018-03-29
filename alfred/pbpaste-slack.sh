#! /usr/bin/env bash
# image: https://cdn0.iconfinder.com/data/icons/tuts/256/slack_alt.png
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

ALFRED=$(dirname $0)

pbpaste | head -1 | ggrep -oP '^http' && {
    exit 0
}

if pbpaste | ggrep 'failed: ' &> /dev/null; then
    FORCE_MULTILINE=1
else
    FORCE_MULTILINE=0
fi

if [[ $FORCE_MULTILINE -eq 1 ]] || [[ $(pbpaste | wc -l) -gt 1 ]]; then
    echo '```'
    $ALFRED/pbpaste-json.sh || pbpaste
    echo '```'
else
    echo '`'$(pbpaste)'`'
fi

exit 0
