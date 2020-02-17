#! /usr/bin/env python

import os
import re

def match(command):
    return command.output.rstrip().endswith("no basic auth credentials")

def get_new_command(command):
    # example error line
    # Error response from daemon: Get https://1231231231.dkr.ecr.eu-west-1.amazonaws.com/v2/image/stuff/latest: no basic auth credentials
    error = ' '.join(command.output.split('\n'))
    m = re.search('(.*)Error response from daemon: Get https://(\d*)\.dkr\.ecr.([\w-]*)(.*): no basic auth credentials', error)

    return f'$(aws ecr get-login --no-include-email --registry-ids {m.group(2)} --region {m.group(3)}) && {command.script}'

priority = 100
