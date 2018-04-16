#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
LOG=/tmp/$(basename $0).log

function options {
    cat << EOF
haproxy-health-check
consul-leader
consul-ui
EOF
}

function haproxy {
    echo http://$IP:9600
}

function consul_leader {
    echo http://$IP:8500/v1/status/leader
}

function consul_ui {
    echo http://$IP:8500/ui/
}

function extract_ip {
    local input
    local ip
    input="$*"
    ip=$(echo $input | ggrep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
    if [[ -z "$ip" ]]; then
        exit 10
    fi
    echo $ip | tee -a $LOG
}

function usage {
    cat << EOF
    Opens a tool webpage for a given ip

    Current tools suported are:
        haproxy $(haproxy)
        consul-leader $(consul_leader)
        consul-ui $(consul_ui)
EOF
}

DRY=0

echo $* >> $LOG

echo "Parsing long args" >> $LOG

# https://stackoverflow.com/a/30026641/2599522
for arg in "$@"; do
  shift
  case "$arg" in
    "--haproxy-health-check") action="haproxy";;
    "--consul-leader") action="consul-leader";;
    "--consul-ui") action="consul-ui";;
    "--help") set -- "$@" "-h" ;;
    *)        set -- "$@" "$arg"
  esac
done

echo "Parsing short args" >> $LOG

while getopts "ni:LHCVhv" OPTION
do
     case $OPTION in
         V) action="consul_ui";;
         C) action="consul_leader";;
         H) action="haproxy";;
         L) options; exit 0;;
         i) IP=$(extract_ip $OPTARG);;
         n) DRY=1;;
         h) usage; exit 0;;
         v) VERBOSE=1;;
     esac
done

case $action in
    haproxy) URL=$(haproxy);;
    consul-leader) URL=$(consul_leader);;
    consul-ui) URL=$(consul_ui);;
esac

echo $URL >> $LOG
if [[ $DRY -eq 0 ]]; then
    open "$URL"
else
    echo "$URL"
fi

exit 0
