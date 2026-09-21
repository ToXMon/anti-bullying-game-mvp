from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "scripts" / "game_controller.gd"
BACKDROP = ROOT / "scripts" / "storybook_backdrop.gd"
ILLUSTRATION = ROOT / "scripts" / "hallway_illustration.gd"
WORLD = ROOT / "scripts" / "playful_school_world.gd"
SETTINGS = ROOT / "scripts" / "settings_store.gd"
README = ROOT / "README.md"


class VisualContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.controller = CONTROLLER.read_text(encoding="utf-8")
        cls.backdrop = BACKDROP.read_text(encoding="utf-8")
        cls.illustration = ILLUSTRATION.read_text(encoding="utf-8")
        cls.world = WORLD.read_text(encoding="utf-8")
        cls.settings = SETTINGS.read_text(encoding="utf-8")
        cls.readme = README.read_text(encoding="utf-8")

    def test_visual_layer_is_procedural_and_local(self):
        self.assertIn('preload("res://scripts/storybook_backdrop.gd")', self.controller)
        self.assertIn('preload("res://scripts/hallway_illustration.gd")', self.controller)
        self.assertIn('preload("res://scripts/playful_school_world.gd")', self.controller)
        for source in (self.controller, self.backdrop, self.illustration, self.world):
            self.assertNotIn("http://", source)
            self.assertNotIn("https://", source)
        self.assertIn("BoxMesh.new()", self.world)
        self.assertIn("SphereMesh.new()", self.world)
        self.assertIn("CapsuleMesh.new()", self.world)
        self.assertIn("draw_", self.backdrop)
        self.assertIn("draw_", self.illustration)

    def test_child_appropriate_world_avoids_forbidden_mood_language(self):
        combined = "\n".join((self.controller, self.world, self.readme)).lower()
        for banned in (
            "cinematic",
            "fog",
            "haze",
            "night",
            "rain",
            "ominous",
            "horror",
            "watched",
            "trapped",
            "threatened",
        ):
            self.assertNotIn(banned, combined)

    def test_missing_optional_art_uses_3d_or_2d_fallback(self):
        self.assertIn("ResourceLoader.exists(path)", self.controller)
        self.assertIn("school_world.visible = true", self.controller)
        self.assertIn("hallway_art.visible = true", self.controller)
        self.assertIn("Original procedural 3D school world", self.controller)
        self.assertIn("Original procedural 2D hallway fallback", self.controller)
        self.assertIn('DisplayServer.get_name().to_lower() != "headless"', self.controller)

    def test_reduced_motion_gates_transition_tween(self):
        self.assertIn("func _play_scene_transition()", self.controller)
        self.assertIn("if settings.reduced_motion:\n\t\treturn", self.controller)
        self.assertIn("tween.tween_property(page_panel", self.controller)
        self.assertIn("reduced_motion or camera == null", self.world)
        self.assertIn("tween_property(camera", self.world)

    def test_four_decision_chapters_have_readable_daytime_spaces(self):
        for label in (
            "Chapter 1 • Color Hallway Board",
            "Chapter 2 • Bright Lunch Commons",
            "Chapter 3 • Robot Showcase Setup",
            "Chapter 4 • Plan-For-Tomorrow Corner",
        ):
            self.assertIn(label, self.world)
        for landmark in (
            "classroom maker door",
            "lunchroom doorway landmark",
            "recess garden window",
            "safe route tile",
            "trusted adult doorway",
            "friendly avatar",
        ):
            self.assertIn(landmark, self.world)
        self.assertIn("no public scores", self.controller)
        self.assertIn("No timer", self.controller)

    def test_trusted_adult_path_has_distinct_safe_presentation(self):
        self.assertIn("Trusted adult help", self.controller)
        self.assertIn('approach == "trusted adult"', self.controller)
        self.assertIn("_apply_adult_button_style(button)", self.controller)
        self.assertIn("adult path available", self.controller)
        self.assertIn("trusted adult welcome", self.world)
        self.assertIn("safe route", self.world)

    def test_large_targets_keyboard_and_quality_controls_remain_present(self):
        self.assertIn("button.custom_minimum_size = Vector2(0, 72)", self.controller)
        self.assertIn("progress_meter", self.controller)
        self.assertIn("World detail", self.controller)
        self.assertIn('visual_quality = "playful"', self.settings)
        self.assertIn('config.set_value("accessibility", "visual_quality", visual_quality)', self.settings)
        self.assertIn("KEY_1", self.controller)
        self.assertIn("KEY_R", self.controller)
        self.assertIn("KEY_A", self.controller)


if __name__ == "__main__":
    unittest.main()
