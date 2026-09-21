import json
from pathlib import Path
import unittest

SCENARIO_PATH = Path(__file__).resolve().parents[1] / "data" / "scenarios" / "hallway_helpers.json"


class ScenarioContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scenario = json.loads(SCENARIO_PATH.read_text(encoding="utf-8"))
        cls.nodes = cls.scenario["nodes"]

    def test_product_safety_contract_is_explicit(self):
        self.assertEqual(self.scenario["age_range"], "8-12")
        self.assertEqual(self.scenario["estimated_minutes"], "8-12")
        self.assertTrue(self.scenario["no_personal_data"])
        self.assertEqual(self.scenario["analytics_default"], "off")
        self.assertIn("trusted adult", self.scenario["safety_note"].lower())

    def test_decision_shape_matches_vertical_slice_scope(self):
        decisions = [node for node in self.nodes.values() if node.get("type") == "decision"]
        self.assertGreaterEqual(len(decisions), 3)
        self.assertLessEqual(len(decisions), 5)
        self.assertEqual([node["decision_number"] for node in decisions], [1, 2, 3, 4])
        for node in decisions:
            choices = node["choices"]
            self.assertEqual(len(choices), 4)
            approaches = {choice["approach"] for choice in choices}
            self.assertIn("private support", approaches)
            self.assertIn("trusted adult", approaches)
            self.assertIn("safe redirection", approaches)
            self.assertIn("do nothing", approaches)

    def test_every_route_reaches_reflection_without_dead_ends(self):
        endings = set()
        routes_checked = 0

        def walk(node_id, decisions_seen, adult_score):
            node = self.nodes[node_id]
            if node["type"] == "ending":
                endings.add(node_id)
                self.assertGreaterEqual(decisions_seen, 4)
                return 1 if adult_score > 0 else 0

            adult_routes = 0
            for choice in node["choices"]:
                self.assertIn(choice["next"], self.nodes)
                effects = choice.get("effects", {})
                next_adult_score = adult_score + int(effects.get("adult_loop", 0))
                next_decisions = decisions_seen + (1 if node["type"] == "decision" else 0)
                adult_routes += walk(choice["next"], next_decisions, next_adult_score)
            return adult_routes

        adult_routes = walk(self.scenario["start_node"], 0, 0)
        self.assertEqual(endings, {"ending"})
        self.assertGreater(adult_routes, 0)

    def test_choice_consequences_are_distinct_and_non_shaming(self):
        banned_judgement_words = {"bad kid", "bully forever", "coward", "stupid", "therapy", "diagnosis"}
        for node in self.nodes.values():
            if node.get("type") != "decision":
                continue
            consequences = [choice["consequence"] for choice in node["choices"]]
            self.assertEqual(len(consequences), len(set(consequences)))
            for choice in node["choices"]:
                combined = f"{choice['consequence']} {choice['reflection']}".lower()
                for banned in banned_judgement_words:
                    self.assertNotIn(banned, combined)
                self.assertTrue(choice["reflection"].endswith("."))
                self.assertIsInstance(choice["effects"], dict)

    def test_ending_bands_cover_adult_and_replay_outcomes(self):
        bands = self.scenario["ending_bands"]
        titles = {band["title"] for band in bands}
        self.assertIn("Adult Anchor", titles)
        self.assertIn("Try Another Route", titles)
        self.assertTrue(any("Replay" in band["summary"] or "Replay" in band["prompt"] for band in bands))


if __name__ == "__main__":
    unittest.main()
