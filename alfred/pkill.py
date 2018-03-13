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
from sh import docker
import json
import re
import requests
import shutil


def ps_items():
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
                'arg': 'kill -9 ' + output[1],
                'icon': {
                    'path': wget('https://cdn1.macworld.co.uk/cmsdata/features/3608274/Terminalicon2_thumb800.png')
                }
            }
            procs.append(proc)
    return procs


def simple_image_name(name):
    """ simplify teh docker image name reported in `docker ps` """

    name = re.sub(':[0-9a-fA-F]{40}', '', name)
    name = re.sub('.*amazonaws.com/', '', name)

    return name


def docker_items():
    ret = []
    for item in str(docker('ps', '--format', "table {{.ID}} {{.Image}} {{.Names}} {{.Labels}}")).split('\n')[1:]:
        fields = item.split()
        if len(fields) == 0:
            continue
        ret += [
            {
                'uid': fields[0],
                'arg': 'docker rm -f ' + fields[0],
                'match': item.replace('/', ' '),
                'title': ', '.join([simple_image_name(fields[1]), fields[2]]),
                'icon': {
                    'path': wget('https://goo.gl/9iZD4B', '/tmp/docker.jpeg')
                }
            }
        ]

    return ret


def wget(url, dest=None):
    """docstring for download_file"""
    if dest is None:
        dest = os.path.join('/tmp', os.path.basename(url))
    if not os.path.exists(dest):
        r = requests.get(url, stream=True, allow_redirects=True)
        with open(dest, 'wb') as f:
            shutil.copyfileobj(r.raw, f)
    return dest

def main():
    """docstring for main"""
    print(json.dumps({
        'items': docker_items() + ps_items()
    }, indent=4))


if __name__ == '__main__':
    main()
