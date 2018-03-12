#! /usr/bin/env bash
# image: https://cdn0.iconfinder.com/data/icons/tuts/256/slack_alt.png
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

pbpaste | head -1 | grep -oP '^http' && {
    exit 0
}

if [[ $(pbpaste | wc -l) -gt 1 ]]; then
    echo '```'
    pbpaste-json.sh || pbpaste
    echo '```'
else
    echo '`'$(pbpaste)'`'
fi

exit 0
