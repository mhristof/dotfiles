#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2018 mhristof <mhristof@chessell.local>
#
# Distributed under terms of the MIT license.

import os
import json
from sh import git
import re
import configparser


def list_code_folders(root):
    """docstring for list_code_folders"""
    import glob

    return glob.glob(os.path.join(os.path.expanduser(root), '*'))


def shellcheck_ssr():
    return {
        "notes": "shellcheck",
        "precision": "very_low",
        "actions": [
            {
                "title": "open github shellcheck wiki",
                "action": 1,
                "parameter": "https://github.com/koalaman/shellcheck/wiki/\\0"
            }
        ],
        "regex": "SC\\d*"
    }


def default_profile(config):
    if 'folder' not in config:
        config['folder'] = os.path.expanduser('~/')

    config['folder'] = config['folder'].rstrip('/')

    new = {
        'Guid': config['guid'],
        "Working Directory": config['folder'],
        'AWDS Window Directory': config['folder'],
        'AWDS Tab Directory': config['folder'],
        'AWDS Tab Option': 'Yes',
        'AWDS Window Option': 'Yes',
        'Flashing Bell': True,
        'Visual Bell': True,
        'Silence Bell': True,
        'Smart Selection Rules': [],
        'Terminal Type': 'xterm-256color',
        'Unlimited Scrollback': True,
        # 'Tags': config['tags'],
        'Jobs to Ignore': [
            'rlogin',
            'ssh',
            'slogin',
            'telnet'
        ],
    }

    new['Name'] = new['Guid']

    if 'badge' in config:
        new['Badge Text'] = config['badge']
    else:
        new['Badge Text'] = new['Guid']

    if 'bound' in config and config['bound']:
        new['Bound Hosts'] = ['*:' + config['folder'] + '/*']

    if 'badge' in config:
        new['Badge Text'] = config['badge']
    else:
        new['Badge Text'] = new['Guid']

    new['Smart Selection Rules'].append(shellcheck_ssr())
    new['Triggers'] = triggers()

    if 'cmd' in config:
        new['Initial Text'] = config['cmd']

    return new


def apt_get_install(package):
    """docstring for apt_get_install"""
    return "sudo bash -c 'apt-get update && apt-get install -y {}'".format(
        package)


def triggers():
    return [
        {
            "partial": True,
            "parameter": "sudo password",
            "regex": "^(Password|SUDO password):",
            "action": "PasswordTrigger"
        },
        {
            "partial": True,
            "parameter": apt_get_install('iputils-ping'),
            "regex": "^bash: ping: command not found",
            "action": "SendTextTrigger"
        },
        {
            "partial": True,
            "regex": "^bash: dig: command not found",
            "action": "SendTextTrigger",
            "parameter": apt_get_install('dnsutils')
        },
        {
            "regex": "^docker: 'layers' is not a docker command",
            "action": "SendTextTrigger",
            "parameter": "docker history !$"
        },
        {
            "regex": "^bash: sudo: command not found",
            "action": "SendTextTrigger",
            "parameter": "!!:s/sudo//"
        },
        {
            "regex": "\"[/a-zA-Z0-9_-]*\" E212: Can't open file for writing",
            "action": "SendTextTrigger",
            "parameter": ":echom 'Did you mean: :w !sudo tee %'\n"
        },
        {
            "regex": "^zsh: permission denied: (.*)",
            "action": "SendTextTrigger",
            "parameter": " chmod +x \\1 && \\1",
        },
    ]


def generate_github_profile(folder, code_folder=None):

    relative = folder.replace(os.path.expanduser('~/'), '')
    guid = relative.strip('/').replace('/', '-')
    new = default_profile({
        'guid': guid,
        'folder': folder,
        'bound': True,
    })

    if os.path.isdir(os.path.join(folder, '.git')):
        for ssr in git_ssr(folder):
            new['Smart Selection Rules'].append(ssr)

    return new


def gremote(path):
    path = os.path.join(path, '.git')

    try:
        origin = str(
            git('--git-dir', path, 'remote', '-v')
        ).split('\n')[0].split()[1]
    except IndexError:
        return None

    # convert to github http
    origin = re.sub('git@github.com:', 'https://github.com/', origin)
    # remove .git from urls
    if origin.startswith('http'):
        origin = re.sub(r'\.git', '', origin)
    return origin


def git_ssr(folder, branch_re=None):
    remote = gremote(folder)
    if remote is None:
        return []
    ret = [
        {
            "notes": "Git hash",
            "precision": "low",
            "actions": [
                {
                    "title": "Open commit in github",
                    "action": 1,
                    "parameter": remote + '/commit/\\0'
                }
            ],
            "regex": "[0-9a-fA-f]{7,9}"
        },
        {
            "notes": "Vim2github link from statusline",
            "precision": "low",
            "actions": [
                {
                    "title": "show file in github",
                    "action": 1,
                    "parameter": remote + '/blob/\\1/\\2#L\\3'
                }
            ],
            "regex": "\[Git\(([-_/0-9a-zA-Z]*)\)\]([-_/0-9a-zA-Z.]*):(\d*)"
        }
    ]

    if branch_re:
        ret += {
            "notes": "Git branch name",
            "precision": "very_high",
            "actions": [
                {
                    "title": "Open branch in github",
                    "action": 1,
                    "parameter": remote + "/tree/\\0"
                }
            ],
            "regex": '(master|{})'.format(branch_re),
        }

    return ret


def github():
    ret = []
    for folder in list_code_folders('~/code'):
        ret += [generate_github_profile(folder)]

    return ret


def aws_profiles():
    ret = []
    config = configparser.ConfigParser()
    config.read_file(open(os.path.expanduser('~/.aws/config')))
    for section in config.sections():
        if section.startswith('profile '):
            name = section.split()[1]
            ret += [default_profile({
                'guid': 'aws-' + name,
                'cmd': 'export AWS_PROFILE=' + name,
            })]
    return ret


def main():
    """docstring for main"""
    import argparse
    parser = argparse.ArgumentParser(
        description='Generates dynamic iterm profiles')

    parser.add_argument('-n', '--dry-run',
                        nargs='?',
                        action='store',
                        default=None,
                        const='/tmp/profiles.py.json',
                        help='Dry run mode')
    parser.add_argument('-v', '--verbose',
                        action='count',
                        default=0,
                        help='Increase verbosity')

    args = parser.parse_args()

    profiles = []
    profiles += github()
    profiles += aws_profiles()
    profiles += [generate_github_profile(os.path.expanduser('~/bin'))]
    profiles += [default_profile({
        'guid': 'home',
        'folder': os.path.expanduser('~/'),
        'bound': True,
    })]

    if args.dry_run is not None:
        dest = args.dry_run
    else:
        dest = iterm2_dp('profiles.py.json')

    with open(dest, 'w') as out:
        json_out = {
            'Profiles': profiles
        }
        out.write(json.dumps(json_out, indent=4))
        print('Generated', dest)


def iterm2_dp(fname):
    lib = '~/Library/Application Support/iTerm2/DynamicProfiles'
    dest = os.path.expanduser(lib)
    return os.path.join(dest, fname)


if __name__ == '__main__':
    main()
