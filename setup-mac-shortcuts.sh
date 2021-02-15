#!/usr/bin/env bash

# shellcheck disable=SC2016
defaults write -g NSUserKeyEquivalents '{
    "\033Window\033Move Window to Left Side of Screen"="@$a";
    "\033Window\033Move Window to Right Side of Screen"="@$d";
    "\033Window\033Zoom"="@$s";
}'

