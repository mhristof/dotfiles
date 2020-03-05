#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'


echo "export VAULT_TOKEN=$1" | pbcopy
echo "$(date) copied token $1" >> /tmp/log

exit 0
