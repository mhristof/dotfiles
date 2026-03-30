#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$DIR/.lib"

TOOL=terraform
TG="$(find ./ -maxdepth 2 -mindepth 2 -name terragrunt.hcl | wc -l)"

if [[ -f terragrunt.hcl ]]; then
    TOOL=terragrunt
fi

if [[ $TG -gt 0 ]]; then
    TOOL="terragrunt run-all"
fi

PLAN=$(terraform_plan_name)

# Dry run mode - just print plan name
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
    echo "$PLAN"
    exit 0
fi

CMD="$TOOL plan -out $PLAN $*"
echo "$CMD"
eval "$CMD"
uv run $DIR/terraform-plan-changes.py $PLAN