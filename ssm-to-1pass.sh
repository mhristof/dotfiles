#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
  echo "$*" 1>&2
  exit 1
}

NAME=${1:-}

if [[ -z $NAME ]]; then
  die "Usage: $0 <name>"
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_NAME=$(aws iam list-account-aliases --query "AccountAliases[0]" --output text)

echo "id: $ACCOUNT_ID name: $ACCOUNT_NAME"
DATA=$(aws ssm get-parameter --name "$NAME" --with-decryption)
VALUE=$(jq -r '.Parameter.Value' <<<"$DATA")
ARN=$(jq -r '.Parameter.ARN' <<<"$DATA")

TITLE="$ACCOUNT_NAME $NAME"

ACTION="create --category=login --title"
if op item get "$TITLE" &>/dev/null; then
  ACTION="edit"
fi

if jq '.' <<<"$VALUE"; then
  echo "Data is valid JSON $VALUE"
  data=$(jq -r '. | to_entries[] | "\(.key)=\(.value)"' <<<"$VALUE" | tr -s '\n' ' ')
  url=$(jq -r '.url' <<<"$VALUE")
  if [[ -n $url ]]; then
    data="$data --url=$url"
  fi

  eval "op item $ACTION '$TITLE' $data arn[text]=$ARN --tags $ACCOUNT_NAME,$ACCOUNT_ID"
fi

exit 0
