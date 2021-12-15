#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

cat <<EOF >~/.fzf.projects.vim
let g:fzfSwitchProjectProjects = $(find ~/code -type d -name .git -not -path "*.terra*" | sed 's!/.git!!g' | jq -R -s -c 'split("\n")[:-1]')
EOF

exit 0
