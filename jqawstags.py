#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

import re
import sys
import json
from sh import aws


def tags_match(name, value, tags):
    """docstring for MacBook"""
    for tag in tags:
        try:
            if (re.search(name, tag['Key'])
                    and re.search(value, tag['Value'])):
                return True
        except KeyError:
            next
    return False


def display(instances, key, delim='\n', trailing_delim=False):
    """docstring for display"""
    if key is not None:
        to_print = []
        for instance in instances:
            for ikey in instance.keys():
                if key.lower() == ikey.lower():
                    to_print += [instance[ikey]]
        if trailing_delim:
            to_print += ['']
        print(delim.join(to_print))
    else:
        print(json.dumps(instances, indent=4))


def load_data(input_option):
    if input_option == '-':
        return json.load(sys.stdin)
    else:
        return json.loads(str(aws('ec2', 'describe-instances')))


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Filter aws ec2 describe instances for tags')
    # subparsers = parser.add_subparsers(help='commands')

    parser.add_argument(
        '-t', '--tag',
        help='Tag to filter with. Used in the form of NAME_REGEX:VALUE_REGEX')
    parser.add_argument(
        '-o', '--out',
        default=None,
        help='Output key to output from the instance (ie InstanceId)')
    parser.add_argument('-d', '--delim',
                        default='\n',
                        help='Delimiter for output (if --out is specified).')
    parser.add_argument(
        '-i', '--input',
        help=""" Input json. Can be "-" for stdin (think pipe) or ommited.
        If its ommited, the script will execute and parse
        "aws ec2 describe-instances".""")

    parser.add_argument(
        '-a', '--ansible',
        action="store_true",
        default=False,
        help="""Display results in ansible mode (ie comma delimited and a
        trailing comma).""")

    parser.add_argument('-s', '--ssh',
                        action="store_true",
                        default=False,
                        help="""Ssh node, this is the equivalent of printing
                        the private ips""")

    args = parser.parse_args()

    if args.ansible:
        args.delim = ','
        args.out = 'privateipaddress'

    if args.ssh:
        args.out = 'privateipaddress'

    data = load_data(args.input)
    to_print = []
    for reservation in data['Reservations']:
        for instance in reservation['Instances']:
            # print(instance['Tags'])
            if tags_match(name=args.tag.split(':')[0],
                          value=args.tag.split(':')[1],
                          tags=instance['Tags']):
                to_print += [instance]

    display(to_print, args.out, args.delim, args.ansible)


if __name__ == '__main__':
    main()
