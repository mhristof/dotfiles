#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

SG=${1:-}

if [[ -z $SG ]]; then
    die "error, please provide SG to delete"
fi

for interface in $(aws ec2 describe-network-interfaces --filters Name=group-id,Values=$SG | jq '.NetworkInterfaces[] | [.NetworkInterfaceId, .VpcId] | @csv' -r); do
    iface=$(cut -d, -f1 <<<"$interface" | tr -d '"')
    vpc=$(cut -d, -f2 <<<"$interface" | tr -d '"')
    defaultsg=$(aws ec2 describe-security-groups --filters Name=group-name,Values=default Name=vpc-id,Values=$vpc | jq '.SecurityGroups[].GroupId' | tr -d '"')

    echo "$iface on $vpc with sg $defaultsg"
    aws ec2 modify-network-interface-attribute --network-interface-id $iface --groups $defaultsg
done

exit 0
