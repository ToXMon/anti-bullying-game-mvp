extends RefCounted
class_name SettingsStore

const SETTINGS_PATH := "user://settings.cfg"

var reduced_motion := false
var visual_quality := "cinematic"
var analytics_enabled := false

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		reduced_motion = false
		analytics_enabled = false
		return

	reduced_motion = bool(config.get_value("accessibility", "reduced_motion", false))
	visual_quality = str(config.get_value("accessibility", "visual_quality", "cinematic"))
	if visual_quality != "calm":
		visual_quality = "cinematic"
	# Analytics remains disabled by default; no analytics collection is implemented.
	analytics_enabled = bool(config.get_value("privacy", "analytics_enabled", false))

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value("accessibility", "visual_quality", visual_quality)
	config.set_value("privacy", "analytics_enabled", analytics_enabled)
	config.save(SETTINGS_PATH)
