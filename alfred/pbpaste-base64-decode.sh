#! /usr/bin/env bash
# image: https://i1.wp.com/quickhash-gui.org/wp-content/uploads/2017/07/base64.png
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

OUT=$(pbpaste | base64 -d 2> /dev/null)
if [[ $? -eq 0 ]]; then
    echo $OUT
fi

exit 0
