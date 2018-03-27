#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

which python3 &> /dev/null || {
    PATH=/usr/local/opt/python/bin/:$PATH
}
which python3 &> /dev/null

query=$*
equery=$(python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$query'))")

open "https://www.google.co.uk/search?q=$equery&btnI=1"

exit 0
