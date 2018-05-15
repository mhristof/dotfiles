#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

PATH=/usr/local/bin:$PATH
xkcdpassword -ds '-' $@ || {
  pip2 install xkcdpassword
  xkcdpassword -ds '-' $@
}

exit 0
