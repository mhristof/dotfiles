#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TOOL=terraform
TG="$(find ./ -maxdepth 2 -mindepth 2 -name terragrunt.hcl | wc -l)"

if [[ -f terragrunt.hcl ]]; then
    TOOL=terragrunt
fi

if [[ $TG -gt 0 ]]; then
    TOOL="terragrunt run-all"
fi

PLAN=$("$DIR/.terraform-plan.sh")

CMD="$TOOL plan -out $PLAN"
echo "$CMD"
eval "$CMD"
