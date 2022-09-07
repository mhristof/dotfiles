#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

REMOTE="$(git config --get remote.origin.url)"

case $REMOTE in
    git@github*) die "Remote $REMOTE is ssh, aborting" ;;
    git@gitlab*) die "Remote $REMOTE is ssh, aborting" ;;
esac

case $REMOTE in
    *gitlab*) gl=gitlab ;;
    *github*) gl=github ;;
esac

# shellcheck disable=SC2001
REPO="git@$gl.com:$(sed "s!https://$gl.com/!!" <<<"$REMOTE").git"

REPO="${REPO/.git.git/.git}"

git remote set-url --add origin "$REPO"
git remote set-url --delete origin "$REMOTE"
