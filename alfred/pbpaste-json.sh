#! /usr/bin/env bash
# image: https://stedolan.github.io/jq/jq.png
# http://redsymbol.net/articles/unofficial-bash-strict-mode/


$(dirname $0)/pbpaste-ansible-error.sh && exit 0

pbpaste | jq '.' &> /dev/null
if [[ $? -eq 0 ]]; then
    pbpaste | jq '.'
fi

exit 0
