#! /usr/bin/env bash
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
        ;;
    Darwin)
        which brew &> /dev/null || {
            yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        }
        which pip &> /dev/null || {
            brew install python
            export PATH="/usr/local/opt/python/libexec/bin:$PATH"
        }
        readlink -f /dev/null &> /dev/null || {
            brew install coreutils
            export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
        }
        ;;
esac

which ansible-playbook &> /dev/null || {
    pip install ansible --user
    AP=$(readlink -f "$(python -m site --user-site)/../../../bin/ansible-playbook")
}

ANSIBLE_ROLES_PATH=$(readlink -f $(dirname $0)/../) $AP -i localhost, -c local "$(dirname "$0")/dotfiles.yml" -b "$@"
