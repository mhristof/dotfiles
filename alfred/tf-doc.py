#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
from sh import git
import yaml
import json
import copy


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


def generate_entry(fyle):
    """docstring for generate_entry"""
    ret = {
        'arg': file2url(fyle)
    }

    lines = tuple(open(fyle, 'r'))
    header = extract_yaml_from_doc(lines)

    ret['uid'] = header['page_title']
    ret['title'] = header['description']
    ret['match'] = (header['page_title'].replace('_', ' ')
                    + header['sidebar_current'].replace('-', ' '))

    example = copy.deepcopy(ret)
    example['uid'] += '-example'
    example['match'] += ' example'
    example['title'] += ' example'
    example['arg'] = extract_example(lines)
    if example['arg'] == '':
        raise Exception('Error, could not extract example from', fyle)
    return [ret, example]


def provider_to_repo(provider):
    """docstring for provider_to_repo"""
    return 'git@github.com:terraform-providers/terraform-provider-{}.git'.format(
        provider)


def main():
    """docstring for main"""
    providers = [
        'aws', 'github', 'terraform'
    ]

    items = []
    for prov in providers:
        items += generate_entries(provider_to_repo(prov))

    print(json.dumps({
        'items': items
    }, indent=4))


def generate_entries(repo):
    ret = []
    cache = os.path.expanduser(
        os.path.join('~/.cache/alfred/', os.path.basename(__file__))
    )
    dest = os.path.join(cache, os.path.basename(repo))
    if not os.path.exists(dest):
        git('clone', repo, '--depth=1', dest)
    else:
        git('--git-dir=' + os.path.join(dest, '.git'), 'pull')

    for fyle in find_doc_files(dest):
        ret += generate_entry(fyle)

    return ret


if __name__ == '__main__':
    main()
