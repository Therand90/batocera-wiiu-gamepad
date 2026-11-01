#!/usr/bin/env python3
"""Compute a collision-free position for the virtual Wii U GamePad output."""

from __future__ import annotations

import argparse
import math
import re
import sys
from dataclasses import dataclass

PAD_OUTPUT = "WIIU-GAMEPAD"
_MODE_RE = re.compile(r"^(\d+)x(\d+)\s+px,.*\bcurrent\b")
_POSITION_RE = re.compile(r"^Position:\s*(-?\d+),(-?\d+)$")


@dataclass
class Output:
    name: str
    enabled: bool = False
    width: int | None = None
    height: int | None = None
    x: int = 0
    y: int = 0
    scale: float = 1.0
    transform: str = "normal"

    @property
    def logical_width(self) -> int:
        if self.width is None or self.height is None:
            raise ValueError(f"No current mode found for {self.name}")

        physical_width = self.height if self._swaps_axes() else self.width
        scale = self.scale if self.scale > 0 else 1.0
        return math.ceil(physical_width / scale)

    def _swaps_axes(self) -> bool:
        transform = self.transform.lower()
        return transform in {"90", "270", "flipped-90", "flipped-270"}


def parse_wlr_randr(text: str) -> list[Output]:
    outputs: list[Output] = []
    current: Output | None = None

    for raw in text.splitlines():
        if raw and not raw[0].isspace():
            name = raw.split(maxsplit=1)[0]
            current = Output(name=name)
            outputs.append(current)
            continue

        if current is None:
            continue

        line = raw.strip()
        if line == "Enabled: yes":
            current.enabled = True
        elif line == "Enabled: no":
            current.enabled = False
        elif line.startswith("Position:"):
            match = _POSITION_RE.match(line)
            if match:
                current.x = int(match.group(1))
                current.y = int(match.group(2))
        elif line.startswith("Scale:"):
            try:
                current.scale = float(line.split(":", 1)[1].strip())
            except ValueError:
                pass
        elif line.startswith("Transform:"):
            current.transform = line.split(":", 1)[1].strip()
        elif " px," in line and "current" in line:
            match = _MODE_RE.match(line)
            if match:
                current.width = int(match.group(1))
                current.height = int(match.group(2))

    return outputs


def gamepad_position(text: str, primary: str | None = None) -> tuple[int, int]:
    outputs = [
        output
        for output in parse_wlr_randr(text)
        if output.enabled and output.name != PAD_OUTPUT
    ]

    usable = [output for output in outputs if output.width and output.height]
    if not usable:
        raise ValueError("No enabled physical output with a current mode found")

    # Place the virtual GamePad after the right-most logical edge of every
    # existing output. This avoids collisions even when a second/third monitor
    # is already located to the right of the Batocera primary display.
    right_edge = max(output.x + output.logical_width for output in usable)

    primary_output = next((output for output in usable if output.name == primary), None)
    anchor_y = primary_output.y if primary_output else min(output.y for output in usable)

    return right_edge, anchor_y


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--primary", default=None)
    args = parser.parse_args()

    try:
        x, y = gamepad_position(sys.stdin.read(), args.primary)
    except ValueError as exc:
        print(f"display-layout: {exc}", file=sys.stderr)
        return 1

    print(f"{x} {y}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
