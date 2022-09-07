#!/usr/bin/env bash

if [ -t 1 ]; then
    git diff "$@"
else
    git diff --no-ext-diff "$@"
fi
