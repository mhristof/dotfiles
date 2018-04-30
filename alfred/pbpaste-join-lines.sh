#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

if pbpaste | ggrep -P '\\$' &> /dev/null; then
    pbpaste | tr -d '\n' | perl -p -e 's/\\ *//g'
else
    pbpaste
fi

exit 0
