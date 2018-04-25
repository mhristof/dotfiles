#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

rm json/awk* json/fawk*

for f in $(seq 1 9); do
    uuid=$(uuidgen)
    fout="json/awk-$f-[$uuid].json"
    cat << EOF > $fout
{
  "alfredsnippet" : {
    "snippet" : "awk '{print \$$f}'",
    "uid" : "$uuid",
    "name" : "awk $f",
    "keyword" : "£awk$f"
  }
}
EOF
done

for f in $(seq 1 9); do
    uuid=$(uuidgen)
    fout="json/fawk-$f-[$uuid].json"
    cat << EOF > $fout
{
  "alfredsnippet" : {
    "snippet" : "awk -F'{cursor}' '{print \$$f}'",
    "uid" : "$uuid",
    "name" : "awk $f with delimiter",
    "keyword" : "£fawk$f"
  }
}
EOF
done

exit 0
