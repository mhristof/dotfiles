#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

REMOTE="$(git config --get remote.origin.url)"

if [[ $REMOTE =~ 'git@github' ]]; then
    echo "Remote $REMOTE seems to be ssh, aborting"
    exit 0
fi

REPO="git@github.com:$(git config --get remote.origin.url | sed 's!https://github.com/!!').git"
REPO="${REPO/.git.git/.git}"

git remote set-url --add origin $REPO
git remote set-url --delete origin $REMOTE
