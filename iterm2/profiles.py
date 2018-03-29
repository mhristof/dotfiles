#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

import os
import yaml
import json
from pathlib import Path
import re
from sh import git
from sh import which


def find(regex):
    ret = []
    regex = os.path.expanduser(regex)
    p = Path(os.path.dirname(regex))
    for path in p.glob(os.path.basename(regex)):
        ret += [str(path)]
    return ret


def gremote(path):
    path = os.path.join(path, '.git')

    origin = str(
        git('--git-dir', path, 'remote', '-v')
    ).split('\n')[0].split()[1]

    # convert to github http
    origin = re.sub('git@github.com:', 'https://github.com/', origin)
    # remove .git from urls
    if origin.startswith('http'):
        origin = re.sub('\.git', '', origin)
    return origin


def escape(string):
    return re.sub('/', '\/', string)


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


def aws_cf_docs():
    return {
        "notes": "aws docs",
        "precision": "very_high",
        "actions": [
            {
                "title": "call ~/bin/aws-cf-doc.sh",
                "action": 3,
                "parameter": "~/bin/aws-cf-doc.sh \\0"
            }
        ],
        "regex": "AWS::[a-zA-Z0-9:]*",
    }


def aws_ssr():
    return {
        "notes": "aws",
        "precision": "very_high",
        "actions": [
            {
                "title": "call aws-finder.rb",
                "action": 3,
                "parameter": "open $(~/bin/aws-finder.rb \\0) &> /tmp/log"
            }
        ],
        "regex": "((r|i|vpc|subnet|sg)-[0-9a-fA-F]+|s3://[a-zA-Z0-9-_]*)"
    }


def aws_internal_ip_ssr():
    """docstring for aws_internal_ip_ssr"""
    return {
        "notes": "aws internal IP address",
        "precision": "very_high",
        "actions": [
            {
                "title": "open internal IP url",
                "action": 3
            }
        ],
        "regex": "ip-(\d{1,3})-(\d{1,3})-(\d{1,3})-(\d{1,3})"
    }


def git_ssr(fyle, branch_re=None):
    remote = gremote(fyle)
    yield {
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
    }

    if branch_re:
        yield {
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


def iterm2_dp(fname):
    lib = '~/Library/Application Support/iTerm2/DynamicProfiles'
    dest = os.path.expanduser(lib)
    return os.path.join(dest, fname)


def jira_ssr(config):
    return {
        "notes": "Jira ticket",
        "precision": "very_high",
        "actions": [
            {
                "title": "Open Jira ticket",
                "action": 1,
                "parameter": config['url'] + '/browse/\\0'
            }
        ],
        "regex": config['re']
    }


def apt_get_install(package):
    """docstring for apt_get_install"""
    return "sudo bash -c 'apt-get update && apt-get install -y {}'".format(
        package)


def triggers():
    return [
        {
            "partial": True,
            "parameter": "SUDO password",
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
    ]


def triggers_tags(root, cmd):
    """docstring for trigger_"""
    return {
            # "banco-environments-provisioning/cloudformation/application.json.erb" 468L, 15844C written
            "regex": '^"[a-zA-Z0-9].*?" \d*L, \d*C written',
            "action": "CoprocessTrigger",
            "parameter": "cd {} && {} {}".format(
                root,
                which('ctags'),
                cmd)
        }


def generate_profile(fyle, config):

    new = {
        'Guid': re.sub('/', '-', fyle.strip("/")),
        "Working Directory": fyle,
        'Flashing Bell': True,
        'Visual Bell': True,
        'Silence Bell': True,
        'Bound Hosts': ['*:' + fyle + '/*'],
        'Smart Selection Rules': [],
        'Terminal Type': 'xterm-256color',
        'Unlimited Scrollback': True,
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

    if os.path.isdir(os.path.join(fyle, '.git')):
        if 'branch' not in config:
            config['branch'] = None
        for item in git_ssr(fyle, config['branch']):
            new['Smart Selection Rules'].append(item)

    if 'jira' in config:
        new['Smart Selection Rules'].append(jira_ssr(config['jira']))

    try:
        # lazy check if aws is in the disabled list
        'aws' in config['disable']
    except KeyError:
        new['Smart Selection Rules'].append(aws_ssr())
        new['Smart Selection Rules'].append(aws_internal_ip_ssr())
        new['Smart Selection Rules'].append(aws_cf_docs())

    new['Smart Selection Rules'].append(shellcheck_ssr())

    new['Triggers'] = triggers()
    if 'tags' in config:
        new['Triggers'] += [triggers_tags(fyle, config['tags'])]
    if 'triggers' in config:
        new['Triggers'] += config['triggers']

    return new


def main():
    """docstring for main"""

    import argparse
    parser = argparse.ArgumentParser(description='Generate iterm profiles')

    parser.add_argument('-n', '--dry-run',
                        action='store_true',
                        help='Dry run mode')
    parser.add_argument('-v', '--verbose',
                        action='count',
                        default=0,
                        help='Increase verbosity')

    args = parser.parse_args()

    with open(os.path.expanduser('~/.code.yml'), 'r') as stream:
        config = yaml.load(stream)

    fout = {
        'Profiles': []
    }

    for profile, conf in config.items():
        # print(conf)
        if 'folders' in conf:
            folders = conf['folders']
        elif 'glob' in conf:
            folders = find(conf['glob'])
        else:
            raise Exception('Error, folders/find is not defined for profile',
                            profile)

        for fyle in folders:
            print(fyle)
            fout['Profiles'] += [generate_profile(fyle, conf)]

    if args.dry_run:
        dest = 'profiles.py.json'
    else:
        dest = iterm2_dp('/tmp/profiles.py.json')
    with open(dest, 'w') as out:
        out.write(json.dumps(fout, indent=4))
        print('Generated', dest)


if __name__ == '__main__':
    main()
