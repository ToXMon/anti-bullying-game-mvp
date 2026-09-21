extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world_script: Script = load("res://scripts/playful_school_world.gd")
	if world_script == null:
		_fail("playful school world script could not be loaded")
		_finish()
		return

	var world: Node = world_script.new()
	root.add_child(world)
	await process_frame
	await process_frame

	var contexts := [
		"intro",
		"hallway_first",
		"lunch_followup",
		"showcase_setup",
		"final_choice",
		"ending",
	]
	for context in contexts:
		world.set_context(context, {}, true, "playful")
		await process_frame
		_expect(world.get_chapter_title() != "", "chapter title exists for %s" % context)
		_expect(world.get_caption_text() != "", "caption exists for %s" % context)
	world.set_visual_quality("calm")
	_expect(world.get_caption_text().find("Low-detail") >= 0, "low-detail caption documents quality mode")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	failures.append(message)
	push_error("visual world smoke failed: %s" % message)

func _finish() -> void:
	if failures.is_empty():
		print("Visual world smoke passed: procedural 3D daytime chapters and low-detail mode instantiate.")
		quit(0)
	else:
		printerr("Visual world smoke failed: %s" % ", ".join(failures))
		quit(1)
