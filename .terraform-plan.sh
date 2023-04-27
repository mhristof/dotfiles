#!/usr/bin/env bash
set -euo pipefail

PLAN=terraform.tfplan
if [[ -n ${TF_DATA_DIR:-} ]]; then
    PLAN=terraform.$TF_DATA_DIR.tfplan
    PLAN=${PLAN/../.}
    PLAN=${PLAN/terraform-/}
fi

echo "$PLAN"

exit 0
