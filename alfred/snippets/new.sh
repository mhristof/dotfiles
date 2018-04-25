#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

if [[ -z $1 ]]; then
    echo Error, please provide a name for the snippet
    exit 1
fi

uuid=$(uuidgen)

cat << EOF > json/$1-[$uuid].json
{
  "alfredsnippet" : {
    "snippet" : "",
    "uid" : "$uuid",
    "name" : "$1",
    "keyword" : "£$1"
  }
}
EOF

exit 0
