#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

for f in $(seq 1 9); do
    uuid=$(uuidgen)
    fout="json/awk-$f-[$uuid].json"
    cat << EOF > $fout
{
  "alfredsnippet" : {
    "snippet" : "awk '{print $f}'",
    "uid" : "$uuid",
    "name" : "awk $f",
    "keyword" : "£awk$f"
  }
}
EOF
done

exit 0
