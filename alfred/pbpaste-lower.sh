#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

pbpaste | awk '{ print tolower($0) }'

exit 0
