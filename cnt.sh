#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

CNT=~/.cnt
GREP=/usr/local/bin/ggrep
if [[ -f $CNT ]]; then
    COUNTER=$(cat $CNT | $GREP -oP '\d*' | sed 's/^0*//') || COUNTER=1
else
    COUNTER=1
fi

printf "$USER%04d" $(( COUNTER + 1)) | tee $CNT

exit 0
