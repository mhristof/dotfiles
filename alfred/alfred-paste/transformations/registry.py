"""
Transformation registry system for managing and discovering transformation functions.
"""

from typing import Dict, List, Callable
from dataclasses import dataclass


@dataclass
class TransformationFunction:
    """Data class representing a transformation function."""

    verb: str
    description: str
    function: Callable[[str], str]
    error_handler: Callable = None


class TransformationRegistry:
    """Registry for managing transformation functions."""

    def __init__(self):
        self._transformations: Dict[str, TransformationFunction] = {}

    def register_transformation(
        self,
        verb: str,
        description: str,
        func: Callable[[str], str],
        error_handler: Callable = None,
    ) -> None:
        """Register a transformation function."""
        self._transformations[verb] = TransformationFunction(
            verb=verb,
            description=description,
            function=func,
            error_handler=error_handler,
        )

    def get_available_transformations(self) -> List[str]:
        """Get list of available transformation verbs."""
        return list(self._transformations.keys())

    def is_valid_verb(self, verb: str) -> bool:
        """Check if a verb is registered."""
        return verb in self._transformations

    def get_transformation(self, verb: str) -> TransformationFunction:
        """Get transformation function by verb."""
        return self._transformations.get(verb)

    def get_matching_verbs(self, prefix: str) -> List[str]:
        """Get verbs that start with the given prefix."""
        return [
            verb for verb in self._transformations.keys() if verb.startswith(prefix)
        ]


# Global registry instance
registry = TransformationRegistry()


def register_transformation(verb: str, description: str = None):
    """Decorator for registering transformation functions."""

    def decorator(func: Callable[[str], str]):
        desc = description or f"Transform clipboard content using {verb}"
        registry.register_transformation(verb, desc, func)
        return func

    return decorator
