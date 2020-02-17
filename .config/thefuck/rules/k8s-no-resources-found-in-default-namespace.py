#! /usr/bin/env python3

import os
import re


def match(command):
    return "No resources found in default namespace." in command.output

def get_new_command(command):
    return f"{command.script} --all-namespaces"

priority = 100
