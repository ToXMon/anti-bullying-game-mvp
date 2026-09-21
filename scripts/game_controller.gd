extends Control

const ContentRepositoryScript := preload("res://scripts/content_repository.gd")
const GameStateScript := preload("res://scripts/game_state.gd")
const SettingsStoreScript := preload("res://scripts/settings_store.gd")
const StorybookBackdropScript := preload("res://scripts/storybook_backdrop.gd")
const HallwayIllustrationScript := preload("res://scripts/hallway_illustration.gd")
const PlayfulSchoolWorldScript := preload("res://scripts/playful_school_world.gd")

const INK := Color("#10202f")
const MUTED_INK := Color("#4e5f68")
const PAPER := Color("#fffaf0")
const CARD := Color("#fff7e8")
const CARD_ALT := Color("#eef8f6")
const TEAL := Color("#4f8f99")
const TEAL_DARK := Color("#276777")

var repository = ContentRepositoryScript.new()
var game_state = GameStateScript.new()
var settings = SettingsStoreScript.new()
var scenario: Dictionary = {}
var active_node: Dictionary = {}
var last_feedback: Dictionary = {"consequence": "", "reflection": ""}
var choice_buttons: Array[Button] = []

var page_panel: PanelContainer
var header_card: PanelContainer
var story_card: PanelContainer
var feedback_card: PanelContainer
var choices_card: PanelContainer
var hallway_art: Control
var school_world
var illustration: TextureRect
var illustration_caption: Label
var title_label: Label
var chapter_label: Label
var safety_label: Label
var progress_label: Label
var progress_meter: ProgressBar
var speaker_label: Label
var story_label: RichTextLabel
var prompt_label: Label
var feedback_label: RichTextLabel
var choices_box: VBoxContainer
var replay_button: Button
var motion_button: Button
var quality_button: Button
var adult_button: Button
var adult_dialog: AcceptDialog

func _ready() -> void:
	settings.load_settings()
	game_state.reduced_motion = settings.reduced_motion
	_build_ui()
	_load_game()

func _build_ui() -> void:
	self.theme = _make_storybook_theme()

	var background: Control = StorybookBackdropScript.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	page_panel = PanelContainer.new()
	page_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_panel.add_theme_stylebox_override("panel", _make_panel_style(PAPER, Color("#e1b783"), 28, 2, Color("#7b5633", 0.18), 14))
	margin.add_child(page_panel)

	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_panel.add_child(root)

	header_card = PanelContainer.new()
	header_card.add_theme_stylebox_override("panel", _make_panel_style(Color("#fff1d5"), Color("#e4b36d"), 22, 2, Color("#8a5d2c", 0.10), 6))
	root.add_child(header_card)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header_card.add_child(header)

	var title_stack: VBoxContainer = VBoxContainer.new()
	title_stack.add_theme_constant_override("separation", 2)
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_stack)

	title_label = Label.new()
	title_label.text = "Kindness Crew"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", Color("#284451"))
	title_stack.add_child(title_label)

	progress_label = Label.new()
	progress_label.text = "No timer. Use mouse, touch, Enter, or number keys 1-4."
	progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_color_override("font_color", MUTED_INK)
	title_stack.add_child(progress_label)

	progress_meter = ProgressBar.new()
	progress_meter.min_value = 0.0
	progress_meter.max_value = 4.0
	progress_meter.value = 0.0
	progress_meter.show_percentage = false
	progress_meter.custom_minimum_size = Vector2(0, 12)
	progress_meter.add_theme_stylebox_override("background", _make_progress_style(Color("#f6dfb7")))
	progress_meter.add_theme_stylebox_override("fill", _make_progress_style(Color("#5f9eae")))
	title_stack.add_child(progress_meter)

	adult_button = _make_small_button("Trusted adult help")
	_apply_adult_button_style(adult_button)
	adult_button.pressed.connect(_show_adult_help)
	header.add_child(adult_button)

	motion_button = _make_small_button("Reduced motion: Off")
	motion_button.pressed.connect(_toggle_reduced_motion)
	header.add_child(motion_button)

	quality_button = _make_small_button("World detail: Full")
	quality_button.pressed.connect(_toggle_visual_quality)
	header.add_child(quality_button)

	replay_button = _make_small_button("Replay")
	replay_button.pressed.connect(_restart)
	header.add_child(replay_button)

	var scene_frame: PanelContainer = PanelContainer.new()
	scene_frame.add_theme_stylebox_override("panel", _make_panel_style(Color("#ffe8c6"), Color("#d99a66"), 24, 2, Color("#8a5d2c", 0.13), 8))
	root.add_child(scene_frame)

	var scene_stack: VBoxContainer = VBoxContainer.new()
	scene_stack.add_theme_constant_override("separation", 10)
	scene_frame.add_child(scene_stack)

	var chapter_strip: HBoxContainer = HBoxContainer.new()
	chapter_strip.add_theme_constant_override("separation", 10)
	scene_stack.add_child(chapter_strip)

	chapter_label = Label.new()
	chapter_label.text = "Prologue • Maple Commons"
	chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chapter_label.add_theme_font_size_override("font_size", 22)
	chapter_label.add_theme_color_override("font_color", Color("#284451"))
	chapter_strip.add_child(chapter_label)

	safety_label = Label.new()
	safety_label.text = "Private practice • no public scores"
	safety_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	safety_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	safety_label.add_theme_font_size_override("font_size", 16)
	safety_label.add_theme_color_override("font_color", MUTED_INK)
	chapter_strip.add_child(safety_label)

	if _can_use_3d_presentation():
		school_world = PlayfulSchoolWorldScript.new()
		school_world.custom_minimum_size = Vector2(0, 240)
		school_world.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scene_stack.add_child(school_world)

	hallway_art = HallwayIllustrationScript.new()
	hallway_art.custom_minimum_size = Vector2(0, 200)
	hallway_art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_stack.add_child(hallway_art)

	illustration = TextureRect.new()
	illustration.custom_minimum_size = Vector2(0, 150)
	illustration.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.visible = false
	scene_stack.add_child(illustration)

	illustration_caption = Label.new()
	illustration_caption.text = "A sunny school commons with classroom, lunch, recess, and trusted-adult landmarks."
	illustration_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	illustration_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	illustration_caption.add_theme_font_size_override("font_size", 17)
	illustration_caption.add_theme_color_override("font_color", MUTED_INK)
	scene_stack.add_child(illustration_caption)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)

	story_card = PanelContainer.new()
	story_card.add_theme_stylebox_override("panel", _make_panel_style(CARD, Color("#dfb172"), 22, 2, Color("#8a5d2c", 0.11), 8))
	content.add_child(story_card)

	var story_stack: VBoxContainer = VBoxContainer.new()
	story_stack.add_theme_constant_override("separation", 8)
	story_card.add_child(story_stack)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 25)
	speaker_label.add_theme_color_override("font_color", Color("#6c4b35"))
	story_stack.add_child(speaker_label)

	story_label = RichTextLabel.new()
	story_label.fit_content = true
	story_label.bbcode_enabled = false
	story_label.scroll_active = false
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_label.add_theme_color_override("default_color", INK)
	story_stack.add_child(story_label)

	feedback_card = PanelContainer.new()
	feedback_card.add_theme_stylebox_override("panel", _make_panel_style(CARD_ALT, Color("#9fc5bd"), 20, 2, Color("#3d6b70", 0.08), 6))
	content.add_child(feedback_card)

	feedback_label = RichTextLabel.new()
	feedback_label.fit_content = true
	feedback_label.bbcode_enabled = false
	feedback_label.scroll_active = false
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_color_override("default_color", INK)
	feedback_card.add_child(feedback_label)

	choices_card = PanelContainer.new()
	choices_card.add_theme_stylebox_override("panel", _make_panel_style(Color("#fffdf7"), Color("#ead2a5"), 22, 2, Color("#8a5d2c", 0.08), 6))
	content.add_child(choices_card)

	var choices_stack: VBoxContainer = VBoxContainer.new()
	choices_stack.add_theme_constant_override("separation", 12)
	choices_card.add_child(choices_stack)

	prompt_label = Label.new()
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.add_theme_font_size_override("font_size", 25)
	prompt_label.add_theme_color_override("font_color", Color("#284451"))
	choices_stack.add_child(prompt_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 12)
	choices_stack.add_child(choices_box)

	adult_dialog = AcceptDialog.new()
	adult_dialog.title = "Trusted adult path"
	adult_dialog.dialog_text = "If someone is being targeted, you can tell a trusted adult the facts: who was there, what happened, where it happened, and what help is needed now. In this game, adult-help choices are always available and never punish the person being targeted."
	adult_dialog.add_theme_stylebox_override("panel", _make_panel_style(PAPER, TEAL, 22, 2, Color("#284451", 0.16), 10))
	add_child(adult_dialog)

func _make_storybook_theme() -> Theme:
	var theme: Theme = Theme.new()
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", Color("#152936"))
	theme.set_color("font_focus_color", "Button", Color("#152936"))
	theme.set_color("default_color", "RichTextLabel", INK)
	theme.set_font_size("font_size", "Button", 22)
	theme.set_font_size("font_size", "Label", 22)
	theme.set_font_size("normal_font_size", "RichTextLabel", 22)
	theme.set_stylebox("normal", "Button", _make_button_style(Color("#fff5df"), Color("#d79a62")))
	theme.set_stylebox("hover", "Button", _make_button_style(Color("#ffe9bd"), Color("#c47f48")))
	theme.set_stylebox("pressed", "Button", _make_button_style(Color("#f5d49b"), Color("#a96435")))
	theme.set_stylebox("focus", "Button", _make_button_style(Color("#fff5df"), TEAL_DARK, 4))
	return theme

func _make_panel_style(fill: Color, border: Color, radius: int, border_width: int, shadow: Color, shadow_size: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_corner_radius_all(radius)
	style.set_border_width_all(border_width)
	style.shadow_color = shadow
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	return style

func _make_progress_style(fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(8)
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style

func _make_button_style(fill: Color, border: Color, border_width: int = 2) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_corner_radius_all(18)
	style.set_border_width_all(border_width)
	style.shadow_color = Color("#7b5633", 0.10)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style

func _make_small_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(140, 52)
	button.focus_mode = Control.FOCUS_ALL
	return button

func _apply_adult_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(Color("#e8f6f4"), TEAL))
	button.add_theme_stylebox_override("hover", _make_button_style(Color("#d7efeb"), TEAL_DARK))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color("#c4e4df"), TEAL_DARK))
	button.add_theme_stylebox_override("focus", _make_button_style(Color("#e8f6f4"), Color("#174c5a"), 4))

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
	var has_optional_illustration: bool = path != "" and ResourceLoader.exists(path)
	if has_optional_illustration:
		illustration.texture = load(path)
		illustration.visible = true
		if school_world != null:
			school_world.visible = false
		hallway_art.visible = false
		illustration_caption.text = "Project-local illustration loaded. The trusted-adult path remains available."
	elif school_world != null:
		illustration.visible = false
		school_world.visible = true
		hallway_art.visible = false
		illustration_caption.text = "Original procedural 3D school world uses project-authored Godot meshes and no external assets."
	else:
		illustration.visible = false
		if school_world != null:
			school_world.visible = false
		hallway_art.visible = true
		illustration_caption.text = "Original procedural 2D hallway fallback keeps the scene readable when 3D rendering is unavailable."
	_sync_visual_controls()

func _can_use_3d_presentation() -> bool:
	return DisplayServer.get_name().to_lower() != "headless"

func _sync_visual_controls() -> void:
	if quality_button == null:
		return
	if school_world == null or not school_world.visible:
		quality_button.text = "Visuals: 2D fallback"
		quality_button.disabled = true
		return
	quality_button.disabled = false
	quality_button.text = "World detail: %s" % ["Low" if settings.visual_quality == "calm" else "Full"]

func _update_scene_presentation() -> void:
	var fallback_title: String = _fallback_chapter_title()
	chapter_label.text = fallback_title
	safety_label.text = "Private practice • no public scores"
	if school_world != null and school_world.visible:
		school_world.set_context(game_state.current_node_id, active_node, settings.reduced_motion, settings.visual_quality)
		chapter_label.text = school_world.get_chapter_title()
		illustration_caption.text = school_world.get_caption_text()
	elif hallway_art != null and hallway_art.visible:
		illustration_caption.text = "Original procedural 2D hallway fallback keeps the scene readable when 3D rendering is unavailable."

func _fallback_chapter_title() -> String:
	if active_node.get("type", "story") == "ending":
		return "Reflection Board • Replay Ready"
	var decision_number: int = int(active_node.get("decision_number", max(0, game_state.decision_count())))
	if decision_number <= 0:
		return "Prologue • Maple Commons"
	return "Chapter %d • Bystander practice" % decision_number

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
	_sync_visual_controls()
	_update_scene_presentation()

	if active_node.get("type", "story") == "ending":
		_render_ending()
		return

	for index in range(active_node.get("choices", []).size()):
		var choice: Dictionary = active_node["choices"][index]
		var button: Button = Button.new()
		button.text = "%d. %s" % [index + 1, choice.get("label", "Continue")]
		button.custom_minimum_size = Vector2(0, 72)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = choice.get("approach", "continue")
		_style_choice_button(button, choice.get("approach", ""))
		button.pressed.connect(_on_choice_pressed.bind(choice))
		choices_box.add_child(button)
		choice_buttons.append(button)

	if not choice_buttons.is_empty():
		choice_buttons[0].grab_focus()

func _style_choice_button(button: Button, approach: String) -> void:
	if approach == "trusted adult":
		_apply_adult_button_style(button)
	elif approach == "private support":
		button.add_theme_stylebox_override("normal", _make_button_style(Color("#f3edf8"), Color("#b399c9")))
		button.add_theme_stylebox_override("hover", _make_button_style(Color("#eadff2"), Color("#9477b0")))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color("#ddcfe9"), Color("#7b5fa0")))
		button.add_theme_stylebox_override("focus", _make_button_style(Color("#f3edf8"), Color("#5b3f80"), 4))
	elif approach == "safe redirection":
		button.add_theme_stylebox_override("normal", _make_button_style(Color("#eef7e7"), Color("#95b86f")))
		button.add_theme_stylebox_override("hover", _make_button_style(Color("#e2f0d7"), Color("#789b55")))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color("#d1e7bd"), Color("#5e7f3e")))
		button.add_theme_stylebox_override("focus", _make_button_style(Color("#eef7e7"), Color("#3f6f2c"), 4))
	elif approach == "do nothing":
		button.add_theme_stylebox_override("normal", _make_button_style(Color("#f5f0e8"), Color("#b8a897")))
		button.add_theme_stylebox_override("hover", _make_button_style(Color("#ece5dc"), Color("#958575")))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color("#ded4c8"), Color("#77685a")))
		button.add_theme_stylebox_override("focus", _make_button_style(Color("#f5f0e8"), Color("#5e5146"), 4))

func _format_feedback() -> String:
	var consequence: String = last_feedback.get("consequence", "")
	var reflection: String = last_feedback.get("reflection", "")
	if consequence == "" and reflection == "":
		return ""
	return "What happened: %s\nReflection: %s" % [consequence, reflection]

func _update_progress() -> void:
	var decisions: int = game_state.decision_count()
	var adult_status: String = "adult path tried" if game_state.has_trusted_adult_path() else "adult path available"
	progress_label.text = "Decision practice: %d of 4 • %s • no timer • number keys 1-4 work" % [decisions, adult_status]
	if progress_meter != null:
		progress_meter.value = float(decisions)

func _on_choice_pressed(choice: Dictionary) -> void:
	last_feedback = {
		"consequence": choice.get("consequence", ""),
		"reflection": choice.get("reflection", "")
	}
	game_state.apply_choice(game_state.current_node_id, choice)
	_render_current_node()
	_play_scene_transition()

func _play_scene_transition() -> void:
	if settings.reduced_motion:
		return
	page_panel.modulate = Color("#fff4df")
	var tween: Tween = create_tween()
	tween.tween_property(page_panel, "modulate", Color.WHITE, 0.18)

func _render_ending() -> void:
	var band: Dictionary = game_state.choose_ending_band(scenario.get("ending_bands", []))
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

	var replay: Button = Button.new()
	replay.text = "Replay a different route"
	replay.custom_minimum_size = Vector2(0, 72)
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
	_play_scene_transition()

func _toggle_reduced_motion() -> void:
	settings.reduced_motion = not settings.reduced_motion
	game_state.reduced_motion = settings.reduced_motion
	settings.save_settings()
	motion_button.text = "Reduced motion: %s" % ["On" if settings.reduced_motion else "Off"]
	_update_scene_presentation()

func _toggle_visual_quality() -> void:
	settings.visual_quality = "calm" if settings.visual_quality != "calm" else "playful"
	settings.save_settings()
	_sync_visual_controls()
	_update_scene_presentation()

func _show_adult_help() -> void:
	adult_dialog.popup_centered(Vector2i(620, 300))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_4:
			var index: int = key_event.keycode - KEY_1
			if index >= 0 and index < choice_buttons.size():
				choice_buttons[index].emit_signal("pressed")
		elif key_event.keycode == KEY_R:
			_restart()
		elif key_event.keycode == KEY_A:
			_show_adult_help()
