#!/usr/bin/env python3
import sys
import json

# Simple test - just return what we received
result = {
    "items": [
        {
            "uid": "test",
            "title": f"Received: '{sys.argv[1] if len(sys.argv) > 1 else 'NO_ARG'}'",
            "subtitle": f"Total args: {len(sys.argv)}, Args: {sys.argv}",
            "arg": sys.argv[1] if len(sys.argv) > 1 else "",
            "valid": True,
        }
    ]
}

print(json.dumps(result, indent=2))
