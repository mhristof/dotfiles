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


def ip_ssr():
    return {
        "notes": "ip conversion",
        "precision": "very_low",
        "actions": [
            {
                "title": "launch keyboard maestro macro to resolve ip",
                "action": 3,
                "parameter": """osascript -e 'tell application "Keyboard Maestro Engine" to do script "852CD61E-DBDC-4BEF-9AEB-15116C04A36D" with parameter "\\0"' """,
            }
        ],
        "regex": "addr:\d*\.\d*\.\d*\.\d*"
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

    yield {
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
        {
            "regex": "^zsh: permission denied: (.*)",
            "action": "SendTextTrigger",
            "parameter": " chmod +x \\1 && \\1",
        },
    ]


def triggers_ctags(root, cmd):
    """docstring for trigger_"""
    return {
            "regex": '^"[a-zA-Z0-9].*?" \d*L, \d*C written',
            "action": "CoprocessTrigger",
            "parameter": "cd {} && {} {}".format(
                root,
                which('ctags'),
                cmd)
        }


def default_profile(guid, folder, config, bound=False):
    new = {
        'Guid': guid,
        "Working Directory": folder,
        'AWDS Window Directory': folder,
        'AWDS Tab Directory': folder,
        'AWDS Tab Option': 'Yes',
        'AWDS Window Option': 'Yes',
        'Flashing Bell': True,
        'Visual Bell': True,
        'Silence Bell': True,
        'Smart Selection Rules': [],
        'Terminal Type': 'xterm-256color',
        'Unlimited Scrollback': True,
        'Tags': config['tags'],
        'Jobs to Ignore': [
            'rlogin',
            'ssh',
            'slogin',
            'telnet'
        ],
    }

    new['Smart Selection Rules'].append(ip_ssr())

    if 'guid' in config:
        new['Guid'] = config['guid']

    new['Name'] = new['Guid']

    if 'badge' in config:
        new['Badge Text'] = config['badge']
    else:
        new['Badge Text'] = new['Guid']

    if bound:
        new['Bound Hosts'] = ['*:' + folder + '/*']
    return new


def generate_cmd_profile(name, config):
    if 'folder' not in config:
        config['folder'] = '~/'

    new = default_profile(
        guid=name,
        folder=config['folder'],
        config=config,
        )

    new['Initial Text'] = config['cmd']
    return new


def generate_profile(fyle, config):

    new = default_profile(
        guid=re.sub('/', '-', fyle.strip("/")),
        folder=fyle,
        config=config,
        bound=True,
    )

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
    if 'ctags' in config:
        new['Triggers'] += [triggers_ctags(fyle, config['ctags'])]
    if 'triggers' in config:
        new['Triggers'] += config['triggers']

    return new


def aws_instances_skip(tags, stags):
    for tag in tags:
        if tag['Key'] in stags:
            return True
    return False


def find_rgb_color(name, config):
    for color, rgb in config['color'].items():
        if re.search(color, name):
            return {
                "Background Color": {
                    "Red Component": rgb[0],
                    "Color Space": "sRGB",
                    "Blue Component": rgb[1],
                    "Alpha Component": 1,
                    "Green Component": rgb[2],
                },
            }
            return rgb
    return None


def aws_instances(config):
    import boto3
    ec2client = boto3.client('ec2')
    response = ec2client.describe_instances()
    ret = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            # This sample print will output entire Dictionary object
            name = None
            for tag in instance['Tags']:
                if tag['Key'] == 'Name':
                    name = tag['Value']

            if name == 'Packer Builder':
                continue
            if aws_instances_skip(instance['Tags'], config['skip_tags']):
                continue

            cmd = 'ssh ubuntu@$(jqawstags.py -t Name:{} -s)'.format(name)
            if 'pre_ssh_cmd' in config:
                cmd = '{} && {}'.format(
                    config['pre_ssh_cmd'], cmd
                )

            try:

                new = generate_cmd_profile(name, {
                    'tags': [name],
                    'cmd': cmd,
                })

                rgb = find_rgb_color(name, config)
                if rgb is not None:
                    new = {**new, **rgb}

                ret += [new]
            except KeyError:
                continue
    return ret


def main():
    """docstring for main"""

    import argparse
    parser = argparse.ArgumentParser(description='Generate iterm profiles')

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
    parser.add_argument('-c', '--config',
                        default='~/.code.yml',
                        help='Config file to use')

    args = parser.parse_args()

    with open(os.path.expanduser(args.config), 'r') as stream:
        config = yaml.load(stream)

    fout = {
        'Profiles': []
    }

    for profile, conf in config.items():
        if profile == 'aws_instances_as_profiles':
            fout['Profiles'] += aws_instances(conf)
            continue

        try:
            conf['tags'] += [profile]
        except KeyError:
            conf['tags'] = [profile]

        if 'folders' in conf:
            folders = conf['folders']
        elif 'glob' in conf:
            folders = find(conf['glob'])
        elif 'cmd' in conf:
            fout['Profiles'] += [generate_cmd_profile(profile, conf)]
            continue
        else:
            raise Exception('Error, folders/find is not defined for profile',
                            profile)

        for fyle in folders:
            fout['Profiles'] += [generate_profile(fyle, conf)]

    if args.dry_run is not None:
        dest = args.dry_run
    else:
        dest = iterm2_dp('profiles.py.json')

    with open(dest, 'w') as out:
        out.write(json.dumps(fout, indent=4))
        print('Generated', dest)


if __name__ == '__main__':
    main()
