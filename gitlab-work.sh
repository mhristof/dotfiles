#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

repo() {
    local url
    url="$1"

    echo "cd $(DRY=true ~/bin/clone "$url" | awk '{print $NF}')"

    exit 0
}

URL=${1:-}
if [[ -z $URL ]]; then
    die "Error, please provide a url"
fi

# shellcheck disable=SC2001
project="$(sed 's!/-/.*!!' <<<"${URL/https:\/\/gitlab.com\//}")"
projectURL="$(echo -ne "$project" | hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g')"

if [[ -z ${GITLAB_TOKEN:-} ]]; then
    GITLAB_TOKEN=$(/usr/bin/security find-generic-password -s germ -w -a GITLAB_READONLY_TOKEN | cut -d"'" -f2)
    export GITLAB_TOKEN
fi

case $URL in
    */jobs/*)
        id="$(basename "$URL")"
        mrID="$(glab api "/projects/$projectURL/jobs/$id" | jq -r .ref | cut -d/ -f3)"
        ;;
    */merge_requests/*)
        #shellcheck disable=SC2001
        mrID="$(sed 's/.*\(merge_requests.*\)/\1/g' <<<"$URL" | cut -d/ -f2)"
        ;;
    */-/tree/*)
        # https://gitlab.com/_bcgroup/infra/platform/-/tree/master/terraform/runner.tf#L196
        #shellcheck disable=SC2001
        project=$(sed 's!https://gitlab.com/!!g' <<<"$URL" | sed 's!/-/.*!!g')

        #shellcheck disable=SC2001
        branch=$(sed 's!.*/(tree|tree)/!!g' <<<"$URL" | cut -d/ -f1)
        ;;
    */-/blob/*)
        # https://gitlab.com/_bcgroup/infra/platform/-/blob/master/terraform/runner.tf#L196
        #shellcheck disable=SC2001
        project=$(sed 's!https://gitlab.com/!!g' <<<"$URL" | sed 's!/-/.*!!g')

        #shellcheck disable=SC2001
        branch=$(sed 's!.*/(blob|tree)/!!g' <<<"$URL" | cut -d/ -f1)
        ;;

    *) repo "$URL" ;;
esac

if [[ -n ${mrID:-} ]]; then
    branch=$(glab api "/projects/$projectURL/merge_requests/$mrID" | jq -r .source_branch)
fi

if [[ -z ${branch:-} ]]; then
    die "Error, branch is not set"
fi

dest="$HOME/code/gitlab.com/$project"
if [[ ! -d $dest ]]; then
    clone "$(glab api "/projects/$projectURL" | jq -r .ssh_url_to_repo)"
fi

cat <<EOF
cd $dest && git checkout $(git-main.sh) && git pull && git fetch --prune && git checkout $branch && (git pull || git-force-fetch.sh)
EOF
