#!/usr/bin/env bash
set -euo pipefail

source $HOME/bin/.lib
PATH=$(sed "s@$HOME/bin@@" <<<"$PATH")

which gi &>/dev/null || {
  ~/bin/clone git@github.com:mhristof/gi.git || true
  export DRY=true
  dest="$(awk '{print $5}' <<<"$(~/bin/clone git@github.com:mhristof/gi.git)")"
  cd "$dest" && make install || true
  ~/.local/bin/gi completion zsh >~/.zsh.site-functions/_gi
}

gi "$@"
