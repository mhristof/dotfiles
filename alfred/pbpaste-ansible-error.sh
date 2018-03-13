#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

pbpaste | grep 'failed: .*=>' &> /dev/null && {
    pbpaste | perl -p -e 's/.*=>//' | jq '.'
    exit 0
}

exit 1
