#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$(pbpaste)'))"

exit 0
