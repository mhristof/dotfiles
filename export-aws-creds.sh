#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

if [[ -f ${1:-} ]]; then
    echo "export AWS_ACCESS_KEY_ID=$(tail -1 "$1"   | cut -d',' -f1)"
    echo "export AWS_SECRET_ACCESS_KEY=$(tail -1 "$1" | cut -d',' -f2)"
    exit
fi

get_user_name() {
    aws sts get-caller-identity \
        --query Arn \
        --output text | cut -f 2 -d /
}

get_access_keys() {
    aws iam list-access-keys \
        --user-name "$1" \
    --query 'AccessKeyMetadata[].AccessKeyId' \
        --output text
}

create_new_access_key() {
    aws iam create-access-key \
    --query '[AccessKey.AccessKeyId,AccessKey.SecretAccessKey]' \
        --output text | awk '{ print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\n" "export AWS_SECRET_ACCESS_KEY=\"" $2 "\"" }'
}

delete_old_keys() {
    for key in "$@"; do
        aws iam delete-access-key \
            --access-key-id "${key}"
    done
}

username="$(get_user_name)"
access_keys="$(get_access_keys "${username}")"
create_new_access_key
delete_old_keys "${access_keys}"


exit 0
