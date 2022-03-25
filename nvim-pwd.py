#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""

"""

from pynvim import attach
nvim = attach('socket', path='/tmp/nvim')
# nvim.command('echo "hello world!"')

buffer = nvim.current.buffer

print(buffer.name)
