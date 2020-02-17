#! /usr/bin/env python

from thefuck.utils import for_app, replace_argument

def match(command):
    return "gmake: command not found" in command.output


def get_new_command(command):
    return "brew install homebrew/core/make"
