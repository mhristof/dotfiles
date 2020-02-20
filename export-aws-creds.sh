#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echo export AWS_ACCESS_KEY_ID=$(tail -1 ~/Downloads/credentials.csv  | cut -d',' -f3)
echo export AWS_SECRET_ACCESS_KEY=$(tail -1 ~/Downloads/credentials.csv  | cut -d',' -f4)

exit 0
