"""
Core transformation functions for Alfred Paste.
"""

from .registry import register_transformation
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from version import __version__, __author__, __description__


@register_transformation("sort", "Sort clipboard lines alphabetically")
def sort_lines(content: str) -> str:
    """Sort lines in the content alphabetically."""
    if not content.strip():
        return content

    lines = content.splitlines()
    sorted_lines = sorted(lines)
    return "\n".join(sorted_lines)


@register_transformation("reverse", "Reverse the order of clipboard lines")
def reverse_lines(content: str) -> str:
    """Reverse the order of lines in the content."""
    if not content.strip():
        return content

    lines = content.splitlines()
    reversed_lines = list(reversed(lines))
    return "\n".join(reversed_lines)


@register_transformation("upper", "Convert clipboard text to uppercase")
def to_uppercase(content: str) -> str:
    """Convert content to uppercase."""
    return content.upper()


@register_transformation("lower", "Convert clipboard text to lowercase")
def to_lowercase(content: str) -> str:
    """Convert content to lowercase."""
    return content.lower()


@register_transformation("trim", "Remove leading/trailing whitespace from each line")
def trim_lines(content: str) -> str:
    """Remove leading and trailing whitespace from each line."""
    if not content.strip():
        return content

    lines = content.splitlines()
    trimmed_lines = [line.strip() for line in lines]
    return "\n".join(trimmed_lines)


@register_transformation("base64", "Base64 encode/decode (auto-detect input)")
def base64_transform(content: str) -> str:
    """Base64 encode or decode based on input detection."""
    import base64
    import re

    if not content.strip():
        return content

    # Clean the content by removing whitespace and newlines
    clean_content = content.strip().replace("\n", "").replace("\r", "").replace(" ", "")

    # Check if input looks like base64 (only contains base64 characters)
    base64_pattern = re.compile(r"^[A-Za-z0-9+/]*={0,2}$")

    # Additional checks for base64:
    # 1. Must match base64 character pattern
    # 2. Length must be multiple of 4
    # 3. Must be at least 4 characters long
    if (
        base64_pattern.match(clean_content)
        and len(clean_content) % 4 == 0
        and len(clean_content) >= 4
    ):

        # Looks like base64, try to decode
        try:
            decoded = base64.b64decode(clean_content).decode("utf-8")
            return decoded
        except Exception:
            # If decode fails, encode instead
            pass

    # Encode to base64
    encoded = base64.b64encode(content.encode("utf-8")).decode("utf-8")
    return encoded


@register_transformation("json", "Format JSON (also handles Python dicts)")
def format_json(content: str) -> str:
    """Format JSON with proper indentation. Also handles Python dictionaries."""
    import json
    import ast

    if not content.strip():
        return content

    try:
        # First try to parse as JSON
        parsed = json.loads(content)
        formatted = json.dumps(parsed, indent=2, ensure_ascii=False)
        return formatted
    except json.JSONDecodeError:
        try:
            # If JSON parsing fails, try to parse as Python literal
            python_obj = ast.literal_eval(content)
            # Convert to JSON
            formatted = json.dumps(python_obj, indent=2, ensure_ascii=False)
            return formatted
        except (ValueError, SyntaxError):
            return f"Error: Invalid JSON or Python dict format\n{content}"


@register_transformation("sha256", "Generate SHA256 hash")
def sha256_hash(content: str) -> str:
    """Generate SHA256 hash of the content."""
    import hashlib

    if not content.strip():
        return content

    # Create SHA256 hash
    hash_obj = hashlib.sha256(content.encode("utf-8"))
    return hash_obj.hexdigest()


@register_transformation("join", "Join lines together")
def join_lines(content: str) -> str:
    """Join lines together without any separator."""
    if not content.strip():
        return content

    lines = content.splitlines()
    # Remove empty lines and strip whitespace
    clean_lines = [line.strip() for line in lines if line.strip()]
    return "".join(clean_lines)


@register_transformation("joinspace", "Join lines with spaces")
def join_lines_with_spaces(content: str) -> str:
    """Join lines with spaces."""
    if not content.strip():
        return content

    lines = content.splitlines()
    # Remove empty lines and strip whitespace
    clean_lines = [line.strip() for line in lines if line.strip()]
    return " ".join(clean_lines)


@register_transformation("update", "Update to latest version from GitHub")
def update_workflow(content: str) -> str:
    """Update the workflow to the latest version from GitHub."""
    import urllib.request
    import json
    import tempfile
    import os
    import shutil
    import subprocess

    try:
        # Get the latest release info from GitHub API
        api_url = "https://api.github.com/repos/mhristof/alfred-paste/releases/latest"

        with urllib.request.urlopen(api_url) as response:
            release_data = json.loads(response.read().decode())

        latest_version = release_data["tag_name"].lstrip("v")
        download_url = None

        # Find the .alfredworkflow asset
        for asset in release_data["assets"]:
            if asset["name"].endswith(".alfredworkflow"):
                download_url = asset["browser_download_url"]
                break

        if not download_url:
            return f"Error: No .alfredworkflow file found in latest release"

        # Check if we're already on the latest version
        if latest_version == __version__:
            return f"Already on latest version v{__version__}"

        # Check if this is actually a newer version (handle version comparison)
        def version_compare(v1, v2):
            """Compare two version strings. Returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal."""
            v1_parts = [int(x) for x in v1.split(".")]
            v2_parts = [int(x) for x in v2.split(".")]

            # Pad shorter version with zeros
            max_len = max(len(v1_parts), len(v2_parts))
            v1_parts.extend([0] * (max_len - len(v1_parts)))
            v2_parts.extend([0] * (max_len - len(v2_parts)))

            for i in range(max_len):
                if v1_parts[i] > v2_parts[i]:
                    return 1
                elif v1_parts[i] < v2_parts[i]:
                    return -1
            return 0

        if version_compare(latest_version, __version__) <= 0:
            return (
                f"Already on latest version v{__version__} (latest: v{latest_version})"
            )

        # Download the latest workflow file
        with tempfile.NamedTemporaryFile(
            suffix=".alfredworkflow", delete=False
        ) as tmp_file:
            with urllib.request.urlopen(download_url) as response:
                shutil.copyfileobj(response, tmp_file)
            tmp_path = tmp_file.name

        # Open the workflow file with Alfred (this will install/update it)
        subprocess.run(["open", tmp_path], check=True)

        # Clean up the temporary file after a short delay
        import threading

        def cleanup():
            import time

            time.sleep(5)  # Wait 5 seconds for Alfred to process
            try:
                os.unlink(tmp_path)
            except:
                pass

        threading.Thread(target=cleanup, daemon=True).start()

        return f"Downloaded v{latest_version} workflow file!\n\nAlfred should prompt you to install/update the workflow. If you don't see a prompt, the workflow file has been opened in Alfred. You may need to manually replace the existing workflow or restart Alfred for changes to take effect."

    except Exception as e:
        return f"Error updating workflow: {str(e)}\n\nYou can manually download the latest version from:\nhttps://github.com/mhristof/alfred-paste/releases/latest"


@register_transformation("version", "Show version information")
def show_version(content: str) -> str:
    """Show version information (ignores clipboard content)."""
    version_info = f"""Alfred Paste v{__version__}
Created by: {__author__}
Description: {__description__}

Available transformations:
- psort: Sort lines alphabetically
- preverse: Reverse line order  
- pupper: Convert to uppercase
- plower: Convert to lowercase
- ptrim: Trim whitespace from lines
- pjoin: Join lines together
- pjoinspace: Join lines with spaces
- pbase64: Base64 encode/decode (auto-detect)
- pjson: Format JSON (also handles Python dicts)
- psha256: Generate SHA256 hash
- pupdate: Update to latest version
- pversion: Show this version info

Current clipboard content: {len(content)} characters"""

    return version_info
