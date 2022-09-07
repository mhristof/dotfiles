#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    rm -rf approvals.json project.json
}

if [[ -z ${GITLAB_TOKEN:-} ]]; then
    eval "$(/usr/bin/security find-generic-password -s germ -w -a GITLAB_TOKEN)"
fi

export PAGER=/bin/cat
REPO=$(echo -n "$(git config --get remote.origin.url | cut -d: -f2 | sed 's/.git$//g')" | python3 -c 'import sys; import urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=""))')

approvals() { ## required at least one approval
    glab api "/projects/$REPO/approval_rules" >approvals.json
    if [[ $(jq -r '.[] | select(.approvals_required > 0) | length' approvals.json) -eq 0 ]]; then
        echo "setting approvals required to 1"
        glab api "/projects/$REPO/approval_rules?id=2&name=requireOneApproval&approvals_required=1" -XPOST
    fi
}

ff() { ## set merge to fast forward
    glab api "/projects/$REPO" >project.json
    if ! jq -r .merge_method project.json | grep 'ff' &>/dev/null; then
        echo 'setting merge method to ff'
        glab api -XPUT "/projects/$REPO?merge_method=ff"
    fi
}

squash() { ## allow squas and setup squash commit
    glab api "/projects/$REPO" >project.json
    if ! jq -r .squash_option project.json | grep 'default_off' &>/dev/null; then
        echo 'allow squash'
        glab api -XPUT "/projects/$REPO?squash_option=default_off"
    fi

    if jq -r .squash_commit_template project.json | grep 'null' &>/dev/null; then
        echo 'setting squash_commit_template'
        glab api -XPUT "/projects/$REPO?squash_commit_template=%25{first_multiline_commit}"
    fi
}

pushrules() { ## setup push rules to allow unverified users and unsigned commits
    glab api -XPUT "projects/$REPO/push_rule?member_check=false&reject_unsigned_commits=false&commit_committer_check=false&deny_delete_tag=true"
}

usage() { ## show usage and exit
    grep '() { ##' "$0" | grep -v grep | column -t -s '#'
    die "please come back."
}

case "${1:-}" in
    "pushrules") pushrules ;;
    "approvals") approvals ;;
    "ff") ff ;;
    "squash") squash ;;
    h | -h) usage ;;
    *) usage ;;
esac
exit 0
