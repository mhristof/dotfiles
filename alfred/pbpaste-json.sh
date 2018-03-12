#! /usr/bin/env bash
# image: https://stedolan.github.io/jq/jq.png
# http://redsymbol.net/articles/unofficial-bash-strict-mode/

pbpaste | jq '.' &> /dev/null
if [[ $? -eq 0 ]]; then
    pbpaste | jq '.'
fi

exit 0
