from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "scripts" / "game_controller.gd"
BACKDROP = ROOT / "scripts" / "storybook_backdrop.gd"
ILLUSTRATION = ROOT / "scripts" / "hallway_illustration.gd"


class VisualContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.controller = CONTROLLER.read_text(encoding="utf-8")
        cls.backdrop = BACKDROP.read_text(encoding="utf-8")
        cls.illustration = ILLUSTRATION.read_text(encoding="utf-8")

    def test_visual_layer_is_procedural_and_local(self):
        self.assertIn('preload("res://scripts/storybook_backdrop.gd")', self.controller)
        self.assertIn('preload("res://scripts/hallway_illustration.gd")', self.controller)
        for source in (self.controller, self.backdrop, self.illustration):
            self.assertNotIn("http://", source)
            self.assertNotIn("https://", source)
            self.assertIn("draw_", source) if source != self.controller else None

    def test_missing_optional_art_uses_storybook_fallback(self):
        self.assertIn("ResourceLoader.exists(path)", self.controller)
        self.assertIn("hallway_art.visible = true", self.controller)
        self.assertIn("Original procedural hallway art", self.controller)

    def test_reduced_motion_gates_transition_tween(self):
        self.assertIn("func _play_scene_transition()", self.controller)
        self.assertIn("if settings.reduced_motion:\n\t\treturn", self.controller)
        self.assertIn("tween.tween_property(page_panel", self.controller)

    def test_trusted_adult_path_has_distinct_safe_presentation(self):
        self.assertIn("Trusted adult help", self.controller)
        self.assertIn('approach == "trusted adult"', self.controller)
        self.assertIn("_apply_adult_button_style(button)", self.controller)
        self.assertIn("visible trusted-adult doorway", self.controller)

    def test_large_targets_and_keyboard_shortcuts_remain_present(self):
        self.assertIn("button.custom_minimum_size = Vector2(0, 72)", self.controller)
        self.assertIn("KEY_1", self.controller)
        self.assertIn("KEY_R", self.controller)
        self.assertIn("KEY_A", self.controller)


if __name__ == "__main__":
    unittest.main()
