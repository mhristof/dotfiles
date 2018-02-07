#! /usr/bin/env bash
#
# remove-ssh-host.sh
# Copyright (C) 2017 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#

sed -i.$(date --iso=seconds | cut -d+ -f1) "/$*/d" ~/.ssh/known_hosts
