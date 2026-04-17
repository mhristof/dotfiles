#!/usr/bin/env python3
"""
Main Alfred script for the Alfred Paste workflow.
"""
import sys
import json
import argparse
from typing import List, Dict, Any

# Import our modules
from transformations.registry import registry
from transformations import core  # This imports and registers all transformations


class AlfredResult:
    """Represents an Alfred result item."""
    
    def __init__(self, uid: str, title: str, subtitle: str, arg: str, valid: bool = True):
        self.uid = uid
        self.title = title
        self.subtitle = subtitle
        self.arg = arg
        self.valid = valid
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON output."""
        return {
            "uid": self.uid,
            "title": self.title,
            "subtitle": self.subtitle,
            "arg": self.arg,
            "valid": self.valid,
            "icon": {"type": "default"}
        }


class ClipboardTransformer:
    """Main application class."""
    
    def get_matching_transformations(self, query: str) -> List[AlfredResult]:
        """Get transformations that match the query."""
        results = []
        
        # The query comes from Alfred - it could be 'p', 'ps', 'psort', etc.
        # We need to handle both cases: when user types 'p' and when they type 'psort'
        
        if query.startswith('p'):
            verb = query[1:]  # Remove 'p' prefix
        else:
            verb = query  # Query is already the verb (like 'sort')
        
        # Get matching transformations
        available_verbs = registry.get_available_transformations()
        
        if not verb:
            # Show all available transformations (when user just types 'p')
            for v in available_verbs:
                transformation = registry.get_transformation(v)
                results.append(AlfredResult(
                    uid=f"transform_{v}",
                    title=f"p{v}",
                    subtitle=transformation.description,
                    arg=v
                ))
        else:
            # Check for exact match first
            if verb in available_verbs:
                transformation = registry.get_transformation(verb)
                results.append(AlfredResult(
                    uid=f"transform_{verb}",
                    title=f"p{verb}",
                    subtitle=transformation.description,
                    arg=verb
                ))
            else:
                # Show matching transformations (partial matches)
                matching_verbs = [v for v in available_verbs if v.startswith(verb)]
                
                if matching_verbs:
                    for v in matching_verbs:
                        transformation = registry.get_transformation(v)
                        results.append(AlfredResult(
                            uid=f"transform_{v}",
                            title=f"p{v}",
                            subtitle=transformation.description,
                            arg=v
                        ))
                else:
                    results.append(AlfredResult(
                        uid="no_match",
                        title=f"No transformation found for 'p{verb}'",
                        subtitle="Available: " + ", ".join([f"p{v}" for v in available_verbs]),
                        arg="",
                        valid=False
                    ))
        
        return results
    
    def execute_transformation(self, verb: str, content: str) -> str:
        """Execute a transformation and return the result."""
        try:
            # Check if transformation exists
            if not registry.is_valid_verb(verb):
                return f"Error: Unknown transformation '{verb}'"
            
            # Get transformation function
            transformation = registry.get_transformation(verb)
            
            # Apply transformation and return result
            return transformation.function(content)
            
        except Exception as e:
            return f"Error executing transformation: {e}"
    
    def output_alfred_results(self, results: List[AlfredResult]):
        """Output results in Alfred JSON format."""
        alfred_output = {
            "items": [result.to_dict() for result in results]
        }
        print(json.dumps(alfred_output, indent=2))


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: clipboard_transformer.py <query>", file=sys.stderr)
        sys.exit(1)
    
    query = sys.argv[1]
    transformer = ClipboardTransformer()
    
    # Check if this is an execution request (when Alfred passes clipboard content)
    if len(sys.argv) > 2:
        # Execution mode - transform the clipboard content
        verb = query
        content = sys.argv[2]  # Alfred passes clipboard content as second argument
        
        # If content is the literal string "{clipboard}", use pbpaste to get actual clipboard
        if content == "{clipboard}":
            import subprocess
            try:
                result = subprocess.run(['pbpaste'], capture_output=True, text=True, check=True)
                content = result.stdout
            except subprocess.CalledProcessError:
                content = ""
        
        result = transformer.execute_transformation(verb, content)
        print(result)  # Alfred will use this as the output to paste
    else:
        # Script filter mode - return Alfred results
        results = transformer.get_matching_transformations(query)
        transformer.output_alfred_results(results)


if __name__ == '__main__':
    main()