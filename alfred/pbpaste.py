#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2018 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.

import os
import json
import re
import requests
import shutil
import time


def scripts(dyr):
    """docstring for scripts"""
    for root, dirs, files in os.walk(dyr):
        for f in files:
            if re.search('pbpaste-.*.sh$', f):
                yield os.path.join(root, f)


def image_path(fyle):
    lines = tuple(open(fyle, 'r'))
    image_lines = [x.strip() for x in lines
                   if re.match('^# image:', x)]
    if image_lines:
        image_url = image_lines[0].split(' ')[2]
        # print('peos', fyle, image_lines, image_url)
        dest = os.path.join('/tmp/',
                            os.path.splitext(
                                os.path.basename(fyle))[0] + '.jpg')
        if os.path.exists(dest):
            return dest
        return download_file(image_url, dest)
    return None


def download_file(url, dest):
    """docstring for download_file"""
    r = requests.get(url, stream=True, allow_redirects=True)
    with open(dest, 'wb') as f:
        shutil.copyfileobj(r.raw, f)
        return dest


def scripts2items():
    """docstring for items"""
    ret = []
    dyr = os.path.dirname(__file__)
    for fyle in scripts(dyr):
        # start = time.time()
        item = {
            'uid': os.path.basename(fyle),
            'title': os.path.splitext(
                os.path.basename(fyle)
            )[0].split('-')[1:][0],
            'arg': os.path.abspath(fyle)
        }

        image = image_path(fyle)
        if image is not None:
            item['icon'] = {
                'path': image
            }
        ret += [item]
        # print(fyle, time.time() - start)
    return ret


def main():
    """docstring for main"""

    # start = time.time()
    opts = {
        "items": scripts2items()
    }
    print(json.dumps(opts, indent=4))


if __name__ == '__main__':
    main()
