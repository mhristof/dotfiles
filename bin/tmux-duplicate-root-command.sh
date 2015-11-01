#!/usr/bin/env bash

# this does not work if window is '0'.
# but i never use window '0'

CURRENT_WINDOW=$(tmux display-message -p '#I')
CURRENT_SESSION=$(tmux server-info | grep -P "$CURRENT_WINDOW:.*flags.*references" -A1)
ROOT_DEV_PTS=$(echo $CURRENT_SESSION | grep -oP "/dev/pts/\d*")
ROOT_PTS=$(echo $ROOT_DEV_PTS | perl -p -e 's!/dev/!!g')
#echo $ROOT_PTS
ROOT_CMD=$(ps -ao pid,tty,args | grep $ROOT_PTS | grep -v grep | tr -s ' ' | cut -d ' ' -f3-)
echo "eval [$ROOT_CMD]" >> /tmp/tmux.log
eval $ROOT_CMD
echo "$?" >> /tmp/tmux.log
[ $? -ne 0 ] && /usr/bin/env bash
[ "$ROOT_CMD" == "" ] && /usr/bin/env bash
