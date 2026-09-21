extends Control

const ContentRepositoryScript := preload("res://scripts/content_repository.gd")
const GameStateScript := preload("res://scripts/game_state.gd")
const SettingsStoreScript := preload("res://scripts/settings_store.gd")

var repository = ContentRepositoryScript.new()
var game_state = GameStateScript.new()
var settings = SettingsStoreScript.new()
var scenario: Dictionary = {}
var active_node: Dictionary = {}
var last_feedback := {"consequence": "", "reflection": ""}
var choice_buttons: Array[Button] = []

var title_label: Label
var progress_label: Label
var illustration: TextureRect
var missing_asset_label: Label
var speaker_label: Label
var story_label: RichTextLabel
var prompt_label: Label
var feedback_label: RichTextLabel
var choices_box: VBoxContainer
var replay_button: Button
var motion_button: Button
var adult_button: Button
var adult_dialog: AcceptDialog

func _ready() -> void:
	settings.load_settings()
	game_state.reduced_motion = settings.reduced_motion
	_build_ui()
	_load_game()

func _build_ui() -> void:
	var theme := Theme.new()
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", Color("#10202f"))
	theme.set_color("font_color", "Button", Color("#10202f"))
	theme.set_font_size("font_size", "Button", 22)
	theme.set_font_size("font_size", "Label", 22)
	theme.set_font_size("normal_font_size", "RichTextLabel", 22)
	self.theme = theme

	var background := ColorRect.new()
	background.color = Color("#f7fff7")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	root.add_child(header)

	title_label = Label.new()
	title_label.text = "Kindness Crew"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 30)
	header.add_child(title_label)

	adult_button = _make_small_button("Trusted adult help")
	adult_button.pressed.connect(_show_adult_help)
	header.add_child(adult_button)

	motion_button = _make_small_button("Reduced motion: Off")
	motion_button.pressed.connect(_toggle_reduced_motion)
	header.add_child(motion_button)

	replay_button = _make_small_button("Replay")
	replay_button.pressed.connect(_restart)
	header.add_child(replay_button)

	progress_label = Label.new()
	progress_label.text = "No timer. Use mouse, touch, Enter, or number keys 1-4."
	progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(progress_label)

	illustration = TextureRect.new()
	illustration.custom_minimum_size = Vector2(0, 110)
	illustration.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(illustration)

	missing_asset_label = Label.new()
	missing_asset_label.text = "Text-only mode: optional illustration not found."
	missing_asset_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(missing_asset_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 24)
	content.add_child(speaker_label)

	story_label = RichTextLabel.new()
	story_label.fit_content = true
	story_label.bbcode_enabled = false
	story_label.scroll_active = false
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(story_label)

	feedback_label = RichTextLabel.new()
	feedback_label.fit_content = true
	feedback_label.bbcode_enabled = false
	feedback_label.scroll_active = false
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_color_override("default_color", Color("#10202f"))
	content.add_child(feedback_label)

	prompt_label = Label.new()
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.add_theme_font_size_override("font_size", 24)
	content.add_child(prompt_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 10)
	content.add_child(choices_box)

	adult_dialog = AcceptDialog.new()
	adult_dialog.title = "Trusted adult path"
	adult_dialog.dialog_text = "If someone is being targeted, you can tell a trusted adult the facts: who was there, what happened, where it happened, and what help is needed now. In this game, adult-help choices are always available and never punish the person being targeted."
	add_child(adult_dialog)

func _make_small_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(130, 48)
	return button

func _load_game() -> void:
	scenario = repository.load_scenario()
	if scenario.is_empty():
		_show_load_error()
		return

	title_label.text = scenario.get("title", "Kindness Crew")
	_load_optional_illustration(scenario.get("optional_illustration", ""))
	game_state.reset(scenario.get("start_node", "intro"))
	last_feedback = {"consequence": scenario.get("safety_note", ""), "reflection": "Analytics are off by default. No personal data is stored."}
	_render_current_node()

func _load_optional_illustration(path: String) -> void:
	if path != "" and ResourceLoader.exists(path):
		illustration.texture = load(path)
		illustration.visible = true
		missing_asset_label.visible = false
	else:
		illustration.visible = false
		missing_asset_label.visible = true

func _show_load_error() -> void:
	speaker_label.text = "Project setup"
	story_label.text = "The scenario data could not be loaded. Check res://data/scenarios/hallway_helpers.json."
	prompt_label.text = ""
	feedback_label.text = ""
	_clear_choices()

func _render_current_node() -> void:
	active_node = repository.get_node(scenario, game_state.current_node_id)
	if active_node.is_empty():
		_show_load_error()
		return

	_clear_choices()
	speaker_label.text = active_node.get("speaker", "Narrator")
	story_label.text = active_node.get("text", "")
	prompt_label.text = active_node.get("prompt", "Choose what to do next.")
	feedback_label.text = _format_feedback()
	_update_progress()
	motion_button.text = "Reduced motion: %s" % ["On" if settings.reduced_motion else "Off"]

	if active_node.get("type", "story") == "ending":
		_render_ending()
		return

	for index in range(active_node.get("choices", []).size()):
		var choice: Dictionary = active_node["choices"][index]
		var button := Button.new()
		button.text = "%d. %s" % [index + 1, choice.get("label", "Continue")]
		button.custom_minimum_size = Vector2(0, 64)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = choice.get("approach", "continue")
		button.pressed.connect(_on_choice_pressed.bind(choice))
		choices_box.add_child(button)
		choice_buttons.append(button)

	if not choice_buttons.is_empty():
		choice_buttons[0].grab_focus()

func _format_feedback() -> String:
	var consequence: String = last_feedback.get("consequence", "")
	var reflection: String = last_feedback.get("reflection", "")
	if consequence == "" and reflection == "":
		return ""
	return "What happened: %s\nReflection: %s" % [consequence, reflection]

func _update_progress() -> void:
	var decisions := game_state.decision_count()
	var adult_status := "adult path tried" if game_state.has_trusted_adult_path() else "adult path available"
	progress_label.text = "Decision practice: %d of 4 • %s • no timer • number keys 1-4 work" % [decisions, adult_status]

func _on_choice_pressed(choice: Dictionary) -> void:
	last_feedback = {
		"consequence": choice.get("consequence", ""),
		"reflection": choice.get("reflection", "")
	}
	game_state.apply_choice(game_state.current_node_id, choice)
	if not settings.reduced_motion:
		modulate = Color("#f1f7ff")
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.18)
	_render_current_node()

func _render_ending() -> void:
	var band := game_state.choose_ending_band(scenario.get("ending_bands", []))
	var lines: Array[String] = []
	lines.append(active_node.get("text", ""))
	lines.append("")
	lines.append("Ending card: %s" % band.get("title", "Practice Complete"))
	lines.append(band.get("summary", "You practiced safe choices."))
	lines.append("")
	lines.append("Your route:")
	for choice_data in game_state.choices:
		var choice: Dictionary = choice_data
		if choice.get("approach", "story") == "story":
			continue
		lines.append("• %s — %s" % [choice.get("approach", "choice"), choice.get("label", "")])
	lines.append("")
	lines.append("Reflect: %s" % band.get("prompt", "What would you like to try next time?"))
	lines.append("Replay to test a different route. The game does not save your route.")
	story_label.text = "\n".join(lines)
	prompt_label.text = "Replay or review the trusted-adult path."
	feedback_label.text = _format_feedback()

	var replay := Button.new()
	replay.text = "Replay a different route"
	replay.custom_minimum_size = Vector2(0, 68)
	replay.pressed.connect(_restart)
	choices_box.add_child(replay)
	choice_buttons.append(replay)
	replay.grab_focus()

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()
	choice_buttons.clear()

func _restart() -> void:
	if scenario.is_empty():
		_load_game()
		return
	game_state.reset(scenario.get("start_node", "intro"))
	last_feedback = {"consequence": scenario.get("safety_note", ""), "reflection": "Try a new pattern: private support, trusted adult, safe redirection, or noticing what happens when no one acts."}
	_render_current_node()

func _toggle_reduced_motion() -> void:
	settings.reduced_motion = not settings.reduced_motion
	game_state.reduced_motion = settings.reduced_motion
	settings.save_settings()
	motion_button.text = "Reduced motion: %s" % ["On" if settings.reduced_motion else "Off"]

func _show_adult_help() -> void:
	adult_dialog.popup_centered(Vector2i(560, 260))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_4:
			var index := key_event.keycode - KEY_1
			if index >= 0 and index < choice_buttons.size():
				choice_buttons[index].emit_signal("pressed")
		elif key_event.keycode == KEY_R:
			_restart()
		elif key_event.keycode == KEY_A:
			_show_adult_help()
