#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

while security delete-internet-password -l git-codecommit.eu-west-2.amazonaws.com; do
    :
done

exit 0
