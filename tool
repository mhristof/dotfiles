#!/usr/bin/env bash

die() {
    echo "$*" 1>&2
    exit 1
}

URL="$*"
TOOLS="$(dirname "$0")/tools"
NAME="$(cut -d/ -f 5 <<<"$URL")"
NAME_U="$(tr '[:lower:]' '[:upper:]' <<<"$NAME")"
VERSION="$(cut -d/ -f 8 <<<"$URL")"

case "$URL" in
    https://github.com/*) ;;
    *) die "Error, cannot handle this url [$URL]" ;;
esac

if [[ -z "$NAME" ]]; then
    die "Error, could not determine tool name"
fi

if [[ -z "$VERSION" ]]; then
    die "Error, could not determine version"
fi

if [[ -z "$URL" ]]; then
    die "Error, please provide one url"
fi

mkdir -p "$TOOLS"

echo "Adding $NAME from $URL"

cat <<EOF >"$TOOLS/makefile.lib"
\$(XDG_DATA_HOME)/dotfiles:
	mkdir \$@
EOF

cat <<EOF >"$TOOLS/makefile.$NAME"
.PHONY: $NAME
$NAME: ~/bin/$NAME

${NAME_U}_VERSION := \$(word 7,\$(subst /, ,\$(${NAME_U}_URL)))

\$(XDG_DATA_HOME)/dotfiles/$NAME-\$(${NAME_U}_VERSION): | \$(XDG_DATA_HOME)/dotfiles
	wget --quiet \$(${NAME_U}_URL) --output-document \$@

~/bin/$NAME: \$(XDG_DATA_HOME)/dotfiles/$NAME-\$(${NAME_U}_VERSION) | ~/bin ~/.zsh.site-functions
	chmod +x $<
	ln -sf $< \$@
	\$@ completion zsh > ~/.zsh.site-functions/_$NAME || true
EOF

sed -i '' "/^${NAME_U}_URL/d" Makefile
sed -i '' '/^# tools/a\
'$NAME_U'_URL := '$URL'
' Makefile

TOOLS="$(tr ' ' '\n' <<<"$NAME $(grep '^tools:' Makefile | cut -d: -f2)" | sort | uniq | tr '\n' ' ')"
sed -i '' "s/^tools:.*/tools: $TOOLS/g" Makefile
