#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

if [[ -z "${1:-}" ]]; then
    die "Error, please provide instance id"
fi

ID="${1}"

case $ID in
    i-*) ;;
    *arn:aws:autoscaling:*)
        asg=$(basename "$ID")
        ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$asg" | jq -r '.AutoScalingGroups[].Instances[] | select(.LifecycleState != "Terminating") | .InstanceId')
        echo "found instance $ID from ARN $asg"
        ;;
    */ec2autoscaling/home*)
        asg=$(echo "$ID" | cut -d/ -f7 | sed 's/\?.*//' | sed 's/\\//')
        ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$asg" | jq -r '.AutoScalingGroups[].Instances[] | select(.LifecycleState != "Terminating") | .InstanceId')
        echo "found instance $ID from $asg"
        ;;
    ?)
        die "Error, cannot handle provided argument"
        ;;
esac

if [[ -z "$ID" ]]; then
    die "Error, cannot find ID from ${1:-}"
fi

while [[ "$(aws ec2 get-console-output --instance-id "$ID" | jq '.Output | length')" -eq 0 ]]; do
    echo -n .
    sleep 3
done

aws ec2 get-console-output --instance-id "$ID" | jq '.Output' -r

exit 0
