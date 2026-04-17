#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "$*" 1>&2
  exit 1
}

log() {
  echo "$(date --iso-8601=seconds) - $*" >>"/tmp/$(basename $0).log"
}

# git::git@gitlab.com:a5959/infrastructure/terraform-ecs-service.git?ref=v2.10.0

SOURCE=${1:-}

if [ -z "$SOURCE" ]; then
  die "Usage: $0 <source>"
fi

log "source $SOURCE"

case "$SOURCE" in
  # git@gitlab.com:a5959/infrastructure/terraform-ec2.git?ref=v2.7.1
  git@*)
    REPONAME=$(echo "$SOURCE" | cut -d: -f2 | cut -d? -f1)
    SERVER=$(echo "$SOURCE" | cut -d: -f1 | cut -d@ -f2)
    LOCAL_PATH="$HOME/code/$SERVER/$REPONAME"
    ;;
  git::*)
    REPO=$(echo "$SOURCE" | cut -d: -f4 | cut -d? -f1)
    SERVER=$(echo "$SOURCE" | cut -d: -f3 | cut -d@ -f2)

    LOCAL_PATH="$HOME/code/$SERVER/$REPO"
    ;;
  *)
    die "Unsupported source: $SOURCE"
    ;;
esac

# remove .git
LOCAL_PATH=${LOCAL_PATH//.git/}
LOCAL_PATH=${LOCAL_PATH//\/\//\/}
if [[ ! -d $LOCAL_PATH ]]; then
  echo "Error: $LOCAL_PATH does not exist"
fi

log "LOCAL_PATH=$LOCAL_PATH"
echo "$LOCAL_PATH"
exit 0
