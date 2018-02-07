#!/usr/bin/env bash
# :vi ft=bash:


set -eo pipefail

git_cmd="git push"
if [[ "--force" == "$1" ]]; then
    git_cmd="$git_cmd --force"
    shift
fi
$git_cmd "$@"
