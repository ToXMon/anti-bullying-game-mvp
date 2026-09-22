from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "scripts" / "game_controller.gd"
BACKDROP = ROOT / "scripts" / "storybook_backdrop.gd"
ILLUSTRATION = ROOT / "scripts" / "hallway_illustration.gd"
CINEMATIC = ROOT / "scripts" / "cinematic_hallway_world.gd"
SETTINGS = ROOT / "scripts" / "settings_store.gd"


class VisualContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.controller = CONTROLLER.read_text(encoding="utf-8")
        cls.backdrop = BACKDROP.read_text(encoding="utf-8")
        cls.illustration = ILLUSTRATION.read_text(encoding="utf-8")
        cls.cinematic = CINEMATIC.read_text(encoding="utf-8")
        cls.settings = SETTINGS.read_text(encoding="utf-8")

    def test_visual_layer_is_procedural_and_local(self):
        self.assertIn('preload("res://scripts/storybook_backdrop.gd")', self.controller)
        self.assertIn('preload("res://scripts/hallway_illustration.gd")', self.controller)
        self.assertIn('preload("res://scripts/cinematic_hallway_world.gd")', self.controller)
        for source in (self.controller, self.backdrop, self.illustration, self.cinematic):
            self.assertNotIn("http://", source)
            self.assertNotIn("https://", source)
        self.assertIn("BoxMesh.new()", self.cinematic)
        self.assertIn("SphereMesh.new()", self.cinematic)
        self.assertIn("CapsuleMesh.new()", self.cinematic)
        self.assertIn("TorusMesh.new()", self.cinematic)
        self.assertIn("_make_robot_model", self.cinematic)
        self.assertIn("_make_layered_locker", self.cinematic)
        self.assertIn("draw_", self.backdrop)
        self.assertIn("draw_", self.illustration)

    def test_missing_optional_art_uses_3d_or_2d_fallback(self):
        self.assertIn("ResourceLoader.exists(path)", self.controller)
        self.assertIn("cinematic_world.set_anchors_preset(Control.PRESET_FULL_RECT)", self.controller)
        self.assertIn("cinematic_world.visible = true", self.controller)
        self.assertIn("hallway_art.visible = true", self.controller)
        self.assertIn("Original procedural 3D hallway art", self.controller)
        self.assertIn("Original procedural 2D hallway fallback", self.controller)
        self.assertIn('DisplayServer.get_name().to_lower() != "headless"', self.controller)

    def test_reduced_motion_gates_transition_tween(self):
        self.assertIn("func _play_scene_transition()", self.controller)
        self.assertIn("if settings.reduced_motion:\n\t\treturn", self.controller)
        self.assertIn("tween.tween_property(page_panel", self.controller)
        self.assertIn("reduced_motion or camera == null", self.cinematic)
        self.assertIn("tween_property(camera", self.cinematic)

    def test_four_decision_chapters_have_distinct_safe_presentation(self):
        for label in (
            "Chapter 1 • Hallway Board",
            "Chapter 2 • Lunchroom Doorway",
            "Chapter 3 • Showcase Setup",
            "Chapter 4 • After-School Plan",
        ):
            self.assertIn(label, self.cinematic)
        self.assertIn("trusted adult doorway", self.cinematic)
        self.assertIn("layered kindness bulletin board", self.cinematic)
        self.assertIn("showcase robot table", self.cinematic)
        self.assertIn("no public scores", self.controller)
        self.assertIn("No timer", self.controller)

    def test_trusted_adult_path_has_distinct_safe_presentation(self):
        self.assertIn("Trusted adult help", self.controller)
        self.assertIn('approach == "trusted adult"', self.controller)
        self.assertIn("_apply_adult_button_style(button)", self.controller)
        self.assertIn("visible trusted-adult doorway", self.controller)

    def test_large_targets_keyboard_and_quality_controls_remain_present(self):
        self.assertIn("button.custom_minimum_size = Vector2(0, 72)", self.controller)
        self.assertIn("progress_meter", self.controller)
        self.assertIn("3D detail", self.controller)
        self.assertIn('visual_quality = "cinematic"', self.settings)
        self.assertIn('config.set_value("accessibility", "visual_quality", visual_quality)', self.settings)
        self.assertIn("KEY_1", self.controller)
        self.assertIn("KEY_R", self.controller)
        self.assertIn("KEY_A", self.controller)


if __name__ == "__main__":
    unittest.main()
