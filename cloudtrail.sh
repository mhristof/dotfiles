#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

ID=${1:-}

if [[ -z $ID ]]; then
    die "Provide the Resouce Name to search for"
fi

aws cloudtrail lookup-events \
    --lookup-attributes "AttributeKey=ResourceName,AttributeValue=$ID" \
    --query 'Events[].{username:Username,time:EventTime,event:EventName,eventid:EventId,accesskey:AccessKeyId,resource:(Resources[0].ResourceName)}' \
    --output table --region=ap-east-1

exit 0
