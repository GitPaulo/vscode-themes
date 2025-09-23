# Single-line comment
"""
Multi-line / module docstring comment
Demonstrates a wide variety of Python syntax.
"""

from __future__ import annotations

import asyncio
import logging
import math
from contextlib import contextmanager, asynccontextmanager
from dataclasses import dataclass
from enum import Enum, auto
from pathlib import Path
from typing import (
    Any,
    Dict,
    List,
    Optional,
    TypeVar,
    Generic,
    Protocol,
    Callable,
    Iterator,
    Annotated,
)

PI: float = 3.14159
count: int = 0

# ---------------------------------------------------------------------------
# Decorators
# ---------------------------------------------------------------------------

def decorator(func: Callable[..., Any]) -> Callable[..., Any]:
    """Example decorator"""
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

def debug_class(cls):
    """Class decorator adding a __repr__"""
    def __repr__(self):
        return f"<{cls.__name__} {self.__dict__}>"
    cls.__repr__ = __repr__
    return cls

# ---------------------------------------------------------------------------
# Data classes and Enums
# ---------------------------------------------------------------------------

@dataclass
class Point:
    x: float
    y: float

class Color(Enum):
    RED = auto()
    GREEN = auto()
    BLUE = auto()

# ---------------------------------------------------------------------------
# Protocol & Generics
# ---------------------------------------------------------------------------

T = TypeVar("T")

class SupportsLen(Protocol):
    def __len__(self) -> int: ...

class Box(Generic[T]):
    def __init__(self, item: T):
        self.item = item
    def __len__(self) -> int:
        return 1
    def __iter__(self) -> Iterator[T]:
        yield self.item

# ---------------------------------------------------------------------------
# Core functions
# ---------------------------------------------------------------------------

@decorator
def area(radius: Annotated[float, "circle radius"] = 1.0) -> float:
    """Compute area of a circle"""
    return PI * radius ** 2

def factorial(n: int) -> int:
    if n <= 1:
        return 1
    return n * factorial(n - 1)

# Context manager examples
@contextmanager
def temp_file(path: Path) -> Iterator[Path]:
    print(f"Creating temp file {path}")
    path.write_text("temporary")
    try:
        yield path
    finally:
        print("Cleaning up")
        path.unlink(missing_ok=True)

@asynccontextmanager
async def async_resource() -> AsyncIterator[str]:
    print("Acquiring async resource")
    try:
        yield "resource"
    finally:
        print("Releasing async resource")

# Async function
async def async_task(n: int) -> List[int]:
    data: List[int] = [i for i in range(n)]
    await asyncio.sleep(0.01)
    return [x * 2 for x in data]

# Generator
def countdown(start: int) -> Iterator[int]:
    while start > 0:
        yield start
        start -= 1

# ---------------------------------------------------------------------------
# Classes
# ---------------------------------------------------------------------------

@debug_class
class Shape:
    kind: str = "2D"

    def __init__(self, name: Optional[str] = None) -> None:
        self.name = name or "unknown"

    @property
    def description(self) -> str:
        return f"{self.name} of kind {Shape.kind}"

    async def render_async(self) -> None:
        await asyncio.sleep(0.01)
        print(f"Rendering {self.name}")

# ---------------------------------------------------------------------------
# Pattern matching example
# ---------------------------------------------------------------------------

def describe_color(c: Color) -> str:
    match c:
        case Color.RED:
            return "warm"
        case Color.GREEN:
            return "neutral"
        case Color.BLUE:
            return "cool"
        case _:
            return "unknown"

# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------

async def main() -> None:
    logging.basicConfig(level=logging.INFO)
    result = area(2.5)
    print(f"Area is {result}")

    numbers: Dict[str, Any] = {"one": 1, "two": 2}
    for key, value in numbers.items():
        print(f"{key} => {value}")

    print("factorial(5):", factorial(5))

    p = Point(1.0, 2.0)
    box = Box(p)
    print("Box length:", len(box))

    shape = Shape("Circle")
    await shape.render_async()

    # Context managers
    temp_path = Path("temp_demo.txt")
    with temp_file(temp_path) as f:
        print("Temp file exists:", f.exists())

    async with async_resource() as res:
        print("Using", res)

    # Countdown generator
    for i in countdown(3):
        print("countdown:", i)

    # Pattern matching
    for c in Color:
        print(c, "=>", describe_color(c))

if __name__ == "__main__":
    asyncio.run(main())
