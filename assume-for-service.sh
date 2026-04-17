#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
  echo "$*" 1>&2
  exit 1
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE=$("$DIR/nvim-pwd.py" 2>/dev/null)

if [[ -z $FILE ]]; then
  echo "ec2"
  exit 0
fi

grep 'aws_instance' $FILE | grep -v "data" >/dev/null && {
  echo "ec2"
  exit 0
}

while read -r line; do
  case "$line" in
    *lambda*)
      echo "lambda"
      exit 0
      ;;
    *iam*)
      echo "iam"
      exit 0
      ;;
    *s3*)
      echo "s3"
      exit 0
      ;;
    *instance*)
      echo "ec2"
      exit 0
      ;;
  esac
done < <(grep -wE "source|resource" $FILE | tr -s '_-' ' ' | tr -d '"' | grep -wo "[[:alnum:]]\+" | sort | uniq -c | sort -r)

exit 0
