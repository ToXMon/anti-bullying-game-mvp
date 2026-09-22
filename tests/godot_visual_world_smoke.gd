extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world_script: Script = load("res://scripts/cinematic_hallway_world.gd")
	if world_script == null:
		_fail("cinematic hallway script could not be loaded")
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
		world.set_context(context, {}, true, "cinematic")
		await process_frame
		var metrics: Dictionary = world.get_world_metrics()
		_expect(world.get_chapter_title() != "", "chapter title exists for %s" % context)
		_expect(world.get_caption_text() != "", "caption exists for %s" % context)
		_expect(int(metrics.get("mesh_instances", 0)) >= 190, "world has a substantial procedural mesh library for %s" % context)
		_expect(int(metrics.get("visible_mesh_instances", 0)) >= 45, "active chapter exposes visible 3D objects for %s" % context)
	world.set_visual_quality("calm")
	var calm_metrics: Dictionary = world.get_world_metrics()
	_expect(world.get_caption_text().find("Low-detail") >= 0, "low-detail caption documents quality mode")
	_expect(int(calm_metrics.get("detail_nodes", 0)) >= 20, "quality toggle manages decorative detail nodes")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	failures.append(message)
	push_error("visual world smoke failed: %s" % message)

func _finish() -> void:
	if failures.is_empty():
		print("Visual world smoke passed: procedural 3D chapters and low-detail mode instantiate.")
		quit(0)
	else:
		printerr("Visual world smoke failed: %s" % ", ".join(failures))
		quit(1)
