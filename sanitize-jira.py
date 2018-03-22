#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Distributed under terms of the MIT license.

"""

"""

import os
from jira import JIRA
import json


def get_creds():
    """retrieve jira credentials"""
    try:
        return tuple(open(os.path.expanduser('~/.jira'),
                          'r'))[0].strip().split(':')
    except FileNotFoundError:
        return ['~/.jira not found'] * 2


def capitalize_first_word(sentence):
    sent = sentence.split(' ')
    ret = ' '.join([sent[0].capitalize()] + sent[1:])
    return ret


def config_fname():
    return (os.path.expanduser(
        os.path.join('~/', '.' + os.path.basename(__file__))) + '.json'
            )


def load_options():
    username, password = get_creds()
    data = {
        'server': 'https://todo.atlassian.net/',
        'user': os.getenv('USER'),
        'username': username,
        'password': password,
        'capitalize_title': False,
    }

    fname = config_fname()
    try:
        return {**data, **json.load(open(fname))}
    except FileNotFoundError:
        print('Generate sample config file in', fname)
        with open(fname, 'w') as out:
            out.write(json.dumps(data, indent=4))
        exit(1)


class Sanitize:
    def __init__(self, options, dry=False, verbose=0):
        self.options = options
        self.verbose = verbose
        self.dry = dry
        self.jira = JIRA(options, basic_auth=(options['username'],
                                              options['password']))
        self.issues = self.jira.search_issues(
            'status not in (Resolved, Closed, Done) ' +
            'AND (assignee in ({user}) OR reporter in ({user}))'.format(
                user=options['user'])
        )
        pass

    def check(self, key):
        if key in self.options and self.options[key]:
            return True
        return False

    def apply(self):
        if self.check('capitalize_title'):
            self.capitalize_title()
        if self.check('labels'):
            self.add_labels()
        pass

    def add_labels(self):
        for issue in self.issues:
            labels = issue.fields.labels
            for label in self.options['labels']:
                if label in labels:
                    continue
                issue.fields.labels.append(label)
                if not self.dry:
                    issue.update(fields={"labels": issue.fields.labels})
                print('(dry) ' if self.dry else '',
                      'Updated', issue.key, 'with labels', label)

    def capitalize_title(self):
        for issue in self.issues:
            summary = issue.fields.summary
            update = capitalize_first_word(summary)
            if self.verbose:
                print('Checking', issue.key, summary)

            if summary != update:
                if not self.dry:
                    issue.update(summary=update)
                print('(dry) ' if self.dry else '', 'Updated', issue.key)


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Sanitize jira issues')

    parser.add_argument('-n', '--dry-run',
                        dest='dry',
                        action='store_true',
                        help='Dry run mode')
    parser.add_argument('-v', '--verbose',
                        action='count',
                        default=0,
                        help='Increase verbosity')

    args = parser.parse_args()
    options = load_options()

    if args.verbose > 1:
        print('config = ', json.dumps(options, indent=4))

    Sanitize(options, args.dry, args.verbose).apply()


if __name__ == '__main__':
    main()
