#! /usr/bin/env bash
#

function usage {
    cat << EOF
    Converts an s3 link to an http link.

        example:

    $0 s3://bucket/adsf
    https://console.aws.amazon.com/s3/buckets/bucket
EOF
}

dir=$(dirname $@)
url=$(echo $dir | perl -p -e 's/^s3/http/' | perl -p -e 's!//!//console.aws.amazon.com/s3/buckets/!g')
echo $url
