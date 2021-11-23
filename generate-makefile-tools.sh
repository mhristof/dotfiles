#!/usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

rm -f makefile.tools.mk
sed '/^#/d' tools.txt | while read -r line; do
    binary=$(cut -d/ -f5 <<<"$line")
    BINARY="$(tr '[:lower:]' '[:upper:]' <<<"$binary")"
    echo "$line $binary"
    cat <<EOF >>makefile.tools.mk
$binary: ~/bin/$binary

$BINARY := "${line}"
${BINARY}_VERSION := \$(shell echo \$($BINARY) | cut -d/ -f8)
${BINARY}_BIN := \$(XDG_CACHE_HOME)/$binary-\$(${BINARY}_VERSION)

\$(${BINARY}_BIN):
	\$(WGET) \$($BINARY) -O \$(${BINARY}_BIN)

~/bin/$binary: \$(${BINARY}_BIN) | ~/.zsh.site-functions
	ln -sf \$(${BINARY}_BIN) ~/bin/$binary
	chmod +x ~/bin/$binary
	~/bin/$binary completion zsh > ~/.zsh.site-functions/_$binary
EOF
done

exit 0
