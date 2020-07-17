#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

EXE=$(readlink -f $(python3 -c 'import site; print(site.getusersitepackages())')/../../../bin/xkcdpass)
[ -f  "$EXE" ] || pip3 install --user xkcdpass

xkcdpass -d '-' $@

exit 0
