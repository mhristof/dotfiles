#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""

"""

import os
import sys
from pathlib import Path

from pynvim import attach

nvim = attach("socket", path="/tmp/nvim")

file = os.path.abspath(sys.argv[1])
Path(file).touch()

nvim.command(f"edit {file}")

try:
    line = sys.argv[2]
    nvim.command(f":{line}")
except:
    pass
