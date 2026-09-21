extends RefCounted
class_name GameState

var current_node_id := ""
var choices: Array[Dictionary] = []
var scores := {
	"mina_trust": 0,
	"scene_pressure": 0,
	"adult_loop": 0,
	"crew_energy": 0
}
var reduced_motion := false

func reset(start_node: String) -> void:
	current_node_id = start_node
	choices.clear()
	for key in scores.keys():
		scores[key] = 0

func apply_choice(node_id: String, choice: Dictionary) -> void:
	var effects: Dictionary = choice.get("effects", {})
	for key in effects.keys():
		scores[key] = int(scores.get(key, 0)) + int(effects[key])

	choices.append({
		"node_id": node_id,
		"choice_id": choice.get("id", ""),
		"label": choice.get("label", ""),
		"approach": choice.get("approach", "story"),
		"consequence": choice.get("consequence", ""),
		"reflection": choice.get("reflection", "")
	})
	current_node_id = choice.get("next", current_node_id)

func decision_count() -> int:
	var count := 0
	for choice in choices:
		if choice.get("approach", "story") != "story":
			count += 1
	return count

func has_trusted_adult_path() -> bool:
	return int(scores.get("adult_loop", 0)) > 0

func choose_ending_band(bands: Array) -> Dictionary:
	for band in bands:
		var condition: Dictionary = band.get("condition", {})
		if _matches_condition(condition):
			return band
	return {}

func _matches_condition(condition: Dictionary) -> bool:
	for key in condition.keys():
		if key.ends_with("_min"):
			var score_key := key.trim_suffix("_min")
			if int(scores.get(score_key, 0)) < int(condition[key]):
				return false
	return true
