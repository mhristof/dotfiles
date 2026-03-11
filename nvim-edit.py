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
import glob

# Try to get socket from NVIM environment variable first
socket_path = os.environ.get('NVIM')

# If not set, try to find a running nvim socket
if not socket_path:
    sockets = glob.glob('/tmp/nvim*/0')
    if sockets:
        socket_path = sockets[0]
    else:
        print("Error: No running nvim instance found", file=sys.stderr)
        sys.exit(1)

nvim = attach("socket", path=socket_path)

file = os.path.abspath(sys.argv[1])
Path(file).touch()

nvim.command(f"edit {file}")

try:
    line = sys.argv[2]
    nvim.command(f":{line}")
except:
    pass
