#!/usr/bin/env bash
set -euo pipefail

TYPE=${1:-resource}
NAME=${2:-}
PROVIDER="$(cut -d '_' -f1 <<< "$NAME")"

open "https://www.terraform.io/docs/providers/${PROVIDER}/${TYPE:0:1}/${NAME/${PROVIDER}_/}.html"
