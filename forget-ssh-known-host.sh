#! /usr/bin/env bash
#
# forget-ssh-known-host.sh
# Copyright (C) 2017 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#

# sample input
# /Users/mhristof/.ssh/known_hosts:235
arg=$1
file=$(echo "$arg" | cut -d: -f1)
line=$(echo "$arg" | cut -d: -f2)

if [[ ! -f $file ]]; then
    echo "Error, $file is not a file"
    exit 1
fi

echo "Removing line $line from file $file"
sed -i.bak -e "${line}d" "$file"
