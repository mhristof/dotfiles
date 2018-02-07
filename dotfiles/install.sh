#! /usr/bin/env bash
#
# install.sh
# Copyright (C) 2018 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
# :vim ft=bash:
#


AP='ansible-playbook'
SUDO='sudo'

if [[ -f /.dockerenv ]]; then
    SUDO=''
fi

case $(uname) in
    Linux)
        which python &> /dev/null || {
            $SUDO apt-get update
            $SUDO apt-get install -y python-minimal
        }
        which pip &> /dev/null || {
            $SUDO apt-get install -y python-pip
        }
        which ansible &> /dev/null || {
            pip install ansible --user
            AP=$(readlink -f "$(python -m site --user-site)/../../../bin/ansible-playbook")
        }
        ;;
esac

$AP -i localhost, -c local "$(dirname "$0")/dotfiles.yml" -b "$@"
