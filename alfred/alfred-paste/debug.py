#!/usr/bin/env python3
"""
Debug script to see what Alfred is passing.
"""

import sys
import json

# Log all arguments to a file for debugging
with open("/tmp/alfred_debug.log", "a") as f:
    f.write(f"Arguments: {sys.argv}\n")
    f.write(f"Number of args: {len(sys.argv)}\n")
    for i, arg in enumerate(sys.argv):
        f.write(f"  arg[{i}]: '{arg}'\n")
    f.write("---\n")

# Return a simple result
result = {
    "items": [
        {
            "uid": "debug",
            "title": f"Debug: received {len(sys.argv)} args",
            "subtitle": f"Args: {sys.argv}",
            "arg": "debug",
            "valid": True,
        }
    ]
}

print(json.dumps(result, indent=2))
