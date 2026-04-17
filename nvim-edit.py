#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pynvim"]
# ///
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

import os
import sys
from pathlib import Path
import glob
import subprocess

# Try to get socket from NVIM environment variable first
socket_path = os.environ.get("NVIM")

# If not set, try to find the most recent nvim socket
if not socket_path:
    # Find all nvim sockets (both /tmp/nvim.*.sock and /tmp/nvim*/0)
    sockets = glob.glob("/tmp/nvim.*.sock") + glob.glob("/tmp/nvim*/0")
    if sockets:
        # Use the most recently modified socket
        socket_path = max(sockets, key=os.path.getmtime)

file = os.path.abspath(sys.argv[1])
Path(file).touch()

# If we found a socket, use it to open in existing nvim
if socket_path:
    try:
        from pynvim import attach

        nvim = attach("socket", path=socket_path)
        nvim.command(f"edit {file}")
        try:
            line = sys.argv[2]
            nvim.command(f":{line}")
        except:
            pass
    except Exception as e:
        # If connection fails, fall back to opening new nvim
        print(f"Warning: Could not connect to nvim socket: {e}", file=sys.stderr)
        subprocess.run(["nvim", file])
else:
    # No socket found, open new nvim instance
    subprocess.run(["nvim", file])
