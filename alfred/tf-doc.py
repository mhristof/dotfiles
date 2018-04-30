#! /usr/bin/env python3
# -*- coding: utf-8 -*-

from sh import git
import argparse
import copy
import json
import os
import re
import requests
import shutil
import subprocess
import yaml


def find_doc_files(folder):
    """docstring for find_doc_files"""
    for root, dirs, files in os.walk(folder):
        for f in files:
            if f.endswith('.markdown') and re.search('website/docs', root):
                yield os.path.join(root, f)


def file2url(fyle):
    return os.path.splitext(
        re.sub('.*terraform-provider-(\w*).git/website/docs',
               'https://www.terraform.io/docs/providers/\\1',
               fyle)
    )[0]


def extract_yaml_from_doc(lines):
    started = False
    ret = []
    for line in lines:
        if '---' == line.rstrip() and started:
            return yaml.load(' '.join(ret))
        if '---' == line.rstrip() and not started:
            started = True
        ret += [line]


def extract_example(lines):
    look_for_code_block = False
    found_code_block = False
    ret = []
    for line in lines:
        line = line.rstrip()
        # print('looking', look_for_code_block,
        #       'found', found_code_block, line)
        if found_code_block and re.search('^```$', line):
            return '\n'.join(ret[1:])
        if (re.search('## Example Usage', line, re.IGNORECASE) or
                re.search('## Basic Example Usage', line) or
                re.search('## Example with', line)):
            look_for_code_block = True
        if not found_code_block and (
                look_for_code_block and re.search('^```\w*', line)):
            found_code_block = True
        if found_code_block:
            ret += [line]


def filter_description(description):
    """shorten the module description"""
    replacements = {
        '^Provides details about a specific': 'info',
        '^Provides a resource to manage': 'manage',
        '^Get information on': 'info',
        '^Creates and manages an': '',
        '^Creates and manages a': '',
        '^Creates a new': 'new',
        '^Defines a new': 'new',
        '^Creates a': '',
        '^Provides a ': '',
        '^Provides an': '',
    }

    for key, val in replacements.items():
        description = re.sub(key, val, description)

    return description


def generate_entry(fyle, icons):
    """docstring for generate_entry"""
    ret = {
        'arg': file2url(fyle),
        'icon': {
            'path': icons['web'],
        },
    }

    lines = tuple(open(fyle, 'r'))
    header = extract_yaml_from_doc(lines)

    ret['uid'] = header['page_title']
    ret['title'] = filter_description(header['description'])
    ret['match'] = (header['page_title'].replace('_', ' ')
                    + header['sidebar_current'].replace('-', ' ')
                    + ret['title'])

    example = copy.deepcopy(ret)
    example['uid'] += '-example'
    example['match'] += ' example'
    example['title'] += ' example'
    example['arg'] = extract_example(lines)
    example['icon'] = {
        'path': icons['code'],
    }
    if example['arg'] == '':
        raise Exception('Error, could not extract example from', fyle)
    return [ret, example]


def provider_to_repo(provider):
    """docstring for provider_to_repo"""
    return 'git@github.com:terraform-providers/terraform-provider-{}.git'.format(
        provider)


def main():
    """docstring for main"""
    parser = argparse.ArgumentParser(
        description='Generate terraform help for alfred'
    )

    parser.add_argument('-u', '--update',
                        action='store_true',
                        default=False,
                        help='Update the repositories')

    parser.add_argument('-c', '--clear-cache',
                        action='store_true',
                        default=False,
                        help='Clears the cache')

    args = parser.parse_args()

    if args.clear_cache:
        print('Clearing cache')
        out = subprocess.run(
            ['find', cache_path(), '-name', ".*.json"],
            stdout=subprocess.PIPE
        )
        for fyle in str(out.stdout.decode('ascii')).rstrip().split('\n'):
            if fyle is '':
                continue
            print(fyle)
            os.remove(fyle)
        exit(0)

    items = [
        {
            'uid': 'clear-cache',
            'title': 'clear the cache',
            'arg': "exec={} --clear-cache".format(__file__),
        },
        {
            'uid': 'update',
            'title': 'update the git repositories and also clear the cache',
            'arg': 'exec={} --clear-cache --update'.format(__file__),
        },
    ]

    providers = [
        'aws', 'github', 'terraform', 'kubernetes', 'azure'
    ]

    try:
        items = load_cache(cache_path(), 'master')['items']
    except FileNotFoundError:
        for prov in providers:
            items += generate_entries(provider_to_repo(prov), args.update)

    data = json.dumps({
        'items': items
    }, indent=4)

    with open(cache_fname(cache_path(), 'master'), 'w') as out:
        out.write(data)

    print(data)


def wget(url, dest=None):
    """docstring for download_file"""
    if dest is None:
        dest = os.path.join('/tmp', os.path.basename(url))
    if not os.path.exists(dest):
        r = requests.get(url, stream=True, allow_redirects=True)
        with open(dest, 'wb') as f:
            shutil.copyfileobj(r.raw, f)
    return dest


def fetch_icons(cache):
    icons = {
        'web': 'https://rastamouse.me/images/terraform/icon.png',
        'code': 'https://static.vmguru.com/wordpress/wp-content/uploads/2018/04/as_code.png',
    }

    for name, url in icons.items():
        icons[name] = wget(url, os.path.join(
            cache, '{}.{}'.format(name, url.split('.')[-1])
        ))

    return icons


def cache_fname(repo, rev):
    """docstring for cache_fname"""
    return os.path.join(repo, '.{}.json'.format(rev))


def load_cache(repo, rev):
    return json.loads('\n'.join(tuple(open(cache_fname(repo, rev), 'r'))))


def cache_path():
    base = os.path.expanduser('~/.cache/alfred/')
    return os.path.join(base, os.path.basename(__file__))


def generate_entries(repo, update_repos=True):
    ret = []
    rev = None
    cache = cache_path()

    icons = fetch_icons(cache)
    dest = os.path.join(cache, os.path.basename(repo))
    git_dir_arg = '--git-dir=' + os.path.join(dest, '.git')

    if not os.path.exists(dest):
        git('clone', repo, '--depth=1', dest)
    elif update_repos:
        git(git_dir_arg, 'pull')

    rev = str(git(git_dir_arg, 'rev-parse', 'HEAD')).rstrip()

    try:
        return load_cache(dest, rev)
    except FileNotFoundError:
        pass

    for fyle in find_doc_files(dest):
        ret += generate_entry(fyle, icons)

    with open(cache_fname(dest, rev), 'w') as out:
        out.write(json.dumps(ret, indent=4))
    return ret


if __name__ == '__main__':
    main()
