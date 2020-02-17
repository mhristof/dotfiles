#! /usr/bin/env python3

import os
import re


def match(command):
    return "Error: unknown shorthand flag: 'a' in -a" in command.output

def get_new_command(command):
    return command.script.replace('-a', '-A')

priority = 100
