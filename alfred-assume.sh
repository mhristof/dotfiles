#!/usr/bin/env bash
# Alfred workflow script for granted/assume

SHELL=/bin/bash \
GRANTED_ALIAS_CONFIGURED=true \
PATH=/opt/homebrew/bin:/usr/local/bin:$PATH \
/opt/homebrew/bin/assumego "$1" --console --service "$($HOME/dotfiles/assume-for-service.sh)"
