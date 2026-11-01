import importlib.util
from pathlib import Path
import unittest
import sys

MODULE_PATH = Path(__file__).resolve().parents[1] / "files" / "bin" / "display_layout.py"
SPEC = importlib.util.spec_from_file_location("display_layout", MODULE_PATH)
display_layout = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = display_layout
SPEC.loader.exec_module(display_layout)


def output(name, mode, pos="0,0", scale="1.000000", transform="normal", enabled="yes"):
    return f"""\
{name} "Test ({name})"
  Enabled: {enabled}
  Modes:
    {mode} px, 60.000000 Hz (preferred, current)
  Position: {pos}
  Transform: {transform}
  Scale: {scale}
"""


class DisplayLayoutTests(unittest.TestCase):
    def test_single_1080p_output(self):
        text = output("HDMI-A-1", "1920x1080")
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (1920, 0))

    def test_existing_monitor_to_right_is_not_overlapped(self):
        text = (
            output("HDMI-A-1", "1920x1080")
            + output("DP-1", "1920x1080", "1920,0")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (3840, 0))

    def test_monitor_to_left_does_not_push_gamepad_left(self):
        text = (
            output("DP-1", "1920x1080", "-1920,0")
            + output("HDMI-A-1", "1920x1080", "0,0")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (1920, 0))

    def test_scaled_output_uses_logical_width(self):
        text = (
            output("HDMI-A-1", "1920x1080")
            + output("DP-1", "2560x1440", "1920,0", scale="2.000000")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (3200, 0))

    def test_rotated_output_swaps_axes(self):
        text = (
            output("HDMI-A-1", "1920x1080")
            + output("DP-1", "1920x1080", "1920,0", transform="90")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (3000, 0))

    def test_existing_gamepad_output_is_ignored(self):
        text = (
            output("HDMI-A-1", "1920x1080")
            + output("WIIU-GAMEPAD", "854x480", "1920,0")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (1920, 0))

    def test_primary_vertical_position_is_preserved(self):
        text = (
            output("DP-1", "1280x720", "0,0")
            + output("HDMI-A-1", "1920x1080", "1280,-200")
        )
        self.assertEqual(display_layout.gamepad_position(text, "HDMI-A-1"), (3200, -200))


if __name__ == "__main__":
    unittest.main()
