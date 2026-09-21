extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	if scene == null:
		_fail("main scene could not be loaded")
		_finish()
		return

	var main: Node = scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	_expect(main.game_state.current_node_id == "intro", "starts at intro")
	_expect(main.progress_meter.value == 0.0, "progress starts at zero")
	_expect(main.illustration_caption.text.find("fallback") >= 0 or main.illustration_caption.text.find("procedural 3D") >= 0, "procedural visual fallback or 3D caption is visible")

	await _press(main, KEY_1) # intro continue
	_expect(main.game_state.current_node_id == "hallway_first", "number key starts the first chapter")
	await _press(main, KEY_1) # safe redirection
	await _press(main, KEY_1) # continue
	_expect(main.game_state.current_node_id == "lunch_followup", "route reaches lunch chapter")
	await _press(main, KEY_2) # private support + adult loop
	await _press(main, KEY_1) # continue
	await _press(main, KEY_1) # trusted adult now
	await _press(main, KEY_1) # continue
	await _press(main, KEY_2) # plan with adult

	_expect(main.game_state.current_node_id == "ending", "keyboard route reaches ending")
	_expect(main.game_state.decision_count() == 4, "four decisions are recorded in memory only")
	_expect(main.game_state.has_trusted_adult_path(), "trusted adult path remains reachable")
	_expect(main.story_label.text.find("Ending card") >= 0, "ending card is rendered")
	_expect(main.story_label.text.find("does not save your route") >= 0, "ending repeats privacy promise")

	var initial_reduced_motion: bool = main.settings.reduced_motion
	main._toggle_reduced_motion()
	_expect(main.settings.reduced_motion != initial_reduced_motion, "reduced motion can be toggled")
	await _press(main, KEY_R)
	_expect(main.game_state.current_node_id == "intro", "keyboard replay returns to intro")
	if main.settings.reduced_motion != initial_reduced_motion:
		main._toggle_reduced_motion()

	_finish()

func _press(main: Node, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	main._unhandled_input(event)
	await process_frame
	await process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	failures.append(message)
	push_error("interactive smoke failed: %s" % message)

func _finish() -> void:
	if failures.is_empty():
		print("Interactive smoke path passed: keyboard route, trusted-adult path, ending, replay, and reduced-motion toggle.")
		quit(0)
	else:
		printerr("Interactive smoke path failed: %s" % ", ".join(failures))
		quit(1)
