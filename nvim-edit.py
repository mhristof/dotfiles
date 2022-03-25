#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""

"""

import os
import sys
from pynvim import attach
nvim = attach('socket', path='/tmp/nvim')

file = os.path.abspath(sys.argv[1])
if not os.path.exists(file):
    print(f"Error, {file} does not exist")
    sys.exit(1)

nvim.command(f'edit {file}')
