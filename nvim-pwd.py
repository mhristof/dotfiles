#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""

"""

import sys

from pynvim import attach

nvim = attach("socket", path="/tmp/nvim")

buffer = nvim.current.buffer

print(buffer.name)
print(buffer.name, file=sys.stderr)
