#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

CACHE="$XDG_CACHE_HOME/$(basename "$0" .sh)"

if [[ ! -f Dockerfile ]]; then
    die "Error, Dockerfile not found"
fi

SHA=$(sha256sum Dockerfile | awk '{print $1}')
SBOM=$CACHE/sbom.$SHA.json

if [[ ! -f $SBOM ]]; then
    docker build -t sbom:$SHA .
    docker sbom sbom:$SHA --format syft-json --output $SBOM
fi

while read -r package; do
    sbom=$(jq --arg package $package '.artifacts[] | select(.name == $package)' $SBOM)
    if [[ -z "$sbom" ]]; then
        continue
    fi

    version=$(jq -r .version <<<"$sbom")
    pType=$(jq -r .type <<<"$sbom")

    case $pType in
        apk)
            replace="$package==$version"
            double_version="$version==$version"
            ;;
    esac

    echo "$replace"

    sed -i -z "s/$package/$replace/" Dockerfile
    sed -i -z "s/$double_version/$version/" Dockerfile

done < <(grep '[a-z-]*' -o Dockerfile)

exit 0
