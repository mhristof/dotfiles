#! /usr/bin/env bash
set -euo pipefail

cat <<EOF >~/.fzf.projects.vim
let g:fzfSwitchProjectProjects = $(find ~/code -type d -name .git -not -path "*.terra*" 2>/dev/null | sed 's!/.git!!g' | while read dir; do [ -d "$dir" ] && echo "$dir"; done | jq -R -s 'split("\n")[:-1]' | sed 's/^\s*"/\\"/g' | sed 's/]/\\]/g')
EOF

exit 0
