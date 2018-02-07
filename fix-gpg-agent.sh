#! /usr/bin/env bash
#
# fix-gpg-agent.sh
# Copyright (C) 2017 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#


pkill -f gpg-agent
gpg-agent --daemon
