#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

YAML="$(cat)"
MODULE=$(echo "$YAML" | yq -r '.[-1] | keys | to_entries[] | select(.value != "name") .value')
FIELD=$(echo "$YAML" | yq -r '.[-1].'"$MODULE"' | to_entries[-1].key' 2> /dev/null || echo "")

if [[ $FIELD != "" ]]; then
    FIELD="#parameter-${FIELD}"
fi

ANSIBLE_VERSION=$(ansible --version ansible --version | head -1 | grep -oP '\d*\.\d*' | head -1)

open "https://docs.ansible.com/ansible/${ANSIBLE_VERSION}/modules/${MODULE}_module.html${FIELD}"

exit 0
