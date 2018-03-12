#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2018 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.

"""

"""

import os
from sh import ps
import json


def items():
    """docstring for items"""
    procs = []
    header_skipped = False
    for line in str(ps('-u', os.getenv('USER'), '-wwwxa')).split('\n'):
        if not header_skipped:
            header_skipped = True
            continue
        output = line.split()
        if len(output) >= 4:
            proc = {
                'uid': output[1],
                'title': ' '.join(output[4:]),
                'match': ' '.join(output[4:]).replace('/', ' '),
                'arg': output[1]
            }
            procs.append(proc)
    return procs


def main():
    """docstring for main"""
    print(json.dumps({
        'items': items()
    }, indent=4))


if __name__ == '__main__':
    main()
