"""
Version information for Alfred Paste.
Reads metadata from info.plist file.
"""

import plistlib
import os


def _read_plist():
    """Read the info.plist file and return its contents."""
    plist_path = os.path.join(os.path.dirname(__file__), "info.plist")
    with open(plist_path, "rb") as f:
        return plistlib.load(f)


# Read plist data
_plist_data = _read_plist()

# Export the values
__version__ = _plist_data["version"]
__author__ = _plist_data["createdby"]
__description__ = _plist_data["description"]
__github_url__ = _plist_data["webaddress"]


def get_version_info():
    """Get detailed version information."""
    return {
        "version": __version__,
        "author": __author__,
        "description": __description__,
        "github_url": __github_url__,
    }
