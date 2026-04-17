#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pynvim"]
# ///
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

import sys
import os
import glob
from pynvim import attach

# Try to get socket from NVIM environment variable first
socket_path = os.environ.get("NVIM")

# If not set, try to find the most recent nvim socket
if not socket_path:
    # Find all nvim sockets (both /tmp/nvim.*.sock and /tmp/nvim*/0)
    sockets = glob.glob("/tmp/nvim.*.sock") + glob.glob("/tmp/nvim*/0")
    if sockets:
        # Use the most recently modified socket
        socket_path = max(sockets, key=os.path.getmtime)
    else:
        print("Error: No running nvim instance found", file=sys.stderr)
        sys.exit(1)

nvim = attach("socket", path=socket_path)

buffer = nvim.current.buffer

print(buffer.name)
print(buffer.name, file=sys.stderr)
