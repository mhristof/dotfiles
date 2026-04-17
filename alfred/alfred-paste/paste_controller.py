"""
Paste controller for automatic pasting using AppleScript.
"""
import subprocess
import sys
import time


class PasteController:
    """Manages automatic pasting functionality."""
    
    @staticmethod
    def paste_content() -> bool:
        """Simulate Cmd+V paste operation."""
        try:
            # Use AppleScript to simulate Cmd+V
            applescript = '''
            tell application "System Events"
                keystroke "v" using command down
            end tell
            '''
            
            result = subprocess.run(
                ['osascript', '-e', applescript],
                capture_output=True,
                text=True
            )
            
            return result.returncode == 0
            
        except Exception as e:
            print(f"Error pasting content: {e}", file=sys.stderr)
            return False
    
    @staticmethod
    def simulate_paste_keypress() -> bool:
        """Alternative paste method using key simulation."""
        return PasteController.paste_content()