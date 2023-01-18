#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

mkdir -p ~/.gnupg
touch ~/.gnupg/gpg.conf ~/.gnupg/gpg-agent.conf
echo use-agent >>~/.gnupg/gpg.conf
cat <<EOF >~/.gnupg/gpg-agent.conf
default-cache-ttl 34560000
max-cache-ttl 34560000
pinentry-program /opt/homebrew/bin/pinentry-mac
EOF

which pinentry-mac &>/dev/null || {
    brew install pinentry-mac
}

exit 0
