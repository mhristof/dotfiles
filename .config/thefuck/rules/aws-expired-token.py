#! /usr/bin/env python

import os

def match(command):
    return "An error occurred (ExpiredToken)" in command.output

def get_new_command(command):
    profile = os.getenv("AWS_PROFILE")
    return "aws-azure-login --profile " + profile + " && " + command.script
