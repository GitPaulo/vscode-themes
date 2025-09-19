# Single-line comment
"""
Multi-line / docstring comment
"""

import math
from typing import Any, List, Dict, Optional

PI: float = 3.14159
count: int = 0

def decorator(func):
    """Example decorator"""
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@decorator
def area(radius: float = 1.0) -> float:
    """Compute area of a circle"""
    return PI * radius ** 2

class Shape:
    kind: str = "2D"

    def __init__(self, name: Optional[str] = None) -> None:
        self.name = name or "unknown"

    @property
    def description(self) -> str:
        return f"{self.name} of kind {Shape.kind}"

async def async_task(n: int) -> List[int]:
    data: List[int] = [i for i in range(n)]
    return [x * 2 for x in data]

if __name__ == "__main__":
    result = area(2.5)
    print(f"Area is {result}")
    numbers: Dict[str, Any] = {"one": 1, "two": 2}
    for key, value in numbers.items():
        print(f"{key} => {value}")
