#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

# example 1213123123.dkr.ecr.region.amazonaws.com/repo/image
IMAGE="${1:-}"

if [[ -z $IMAGE ]]; then
    die "Error, please provide the image"
fi

ACCOUNT="$(cut -d. -f1 <<<"$IMAGE")"
REGION="$(cut -d. -f4 <<<"$IMAGE")"

echo "$ACCOUNT on $REGION"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

exit 0
