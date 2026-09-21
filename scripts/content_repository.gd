extends RefCounted
class_name ContentRepository

const SCENARIO_PATH := "res://data/scenarios/hallway_helpers.json"

func load_scenario(path: String = SCENARIO_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("Scenario file is missing: %s" % path)
		return {}

	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Scenario file could not be parsed: %s" % path)
		return {}

	return parsed

func get_node(scenario: Dictionary, node_id: String) -> Dictionary:
	var nodes: Dictionary = scenario.get("nodes", {})
	return nodes.get(node_id, {})
