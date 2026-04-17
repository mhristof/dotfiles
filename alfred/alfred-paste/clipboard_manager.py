"""
Clipboard management for macOS using pbcopy/pbpaste commands.
"""

import subprocess
import sys


class ClipboardManager:
    """Handles clipboard operations on macOS."""

    @staticmethod
    def get_clipboard_content() -> str:
        """Get current clipboard content."""
        try:
            result = subprocess.run(
                ["pbpaste"], capture_output=True, text=True, check=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            print(f"Error reading clipboard: {e}", file=sys.stderr)
            return ""
        except Exception as e:
            print(f"Unexpected error reading clipboard: {e}", file=sys.stderr)
            return ""

    @staticmethod
    def set_clipboard_content(content: str) -> bool:
        """Set clipboard content."""
        try:
            subprocess.run(["pbcopy"], input=content, text=True, check=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error writing to clipboard: {e}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"Unexpected error writing to clipboard: {e}", file=sys.stderr)
            return False

    @staticmethod
    def is_clipboard_empty() -> bool:
        """Check if clipboard is empty."""
        content = ClipboardManager.get_clipboard_content()
        return not content.strip()
