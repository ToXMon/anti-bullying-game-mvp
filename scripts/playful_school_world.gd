extends SubViewportContainer
class_name PlayfulSchoolWorld

const NODE_CHAPTERS := {
	"intro": "welcome",
	"hallway_first": "hallway",
	"redirect_result": "hallway",
	"private_support_result": "hallway",
	"adult_result": "hallway",
	"nothing_result": "hallway",
	"lunch_followup": "lunch",
	"invite_result": "lunch",
	"ask_adult_result": "lunch",
	"lunch_aide_result": "lunch",
	"wait_result": "lunch",
	"showcase_setup": "showcase",
	"adult_now_result": "showcase",
	"boundary_result": "showcase",
	"stand_result": "showcase",
	"hope_result": "showcase",
	"final_choice": "after_school",
	"ending": "reflection"
}

const CHAPTERS := {
	"welcome": {
		"title": "Welcome • Maple Commons",
		"caption": "A sunny toy-like school commons introduces private practice, friendly landmarks, and a clear adult-help route.",
		"camera": Vector3(0.0, 2.45, 7.2),
		"target": Vector3(0.0, 1.20, -3.4),
		"accent": Color("#f6b95e"),
		"sky": Color("#dff8ff")
	},
	"hallway": {
		"title": "Chapter 1 • Color Hallway Board",
		"caption": "Lockers, a maker-classroom door, and an open walking lane make the first bystander choice calm and readable.",
		"camera": Vector3(-2.7, 2.20, 5.9),
		"target": Vector3(-3.15, 1.12, -2.9),
		"accent": Color("#8cc36f"),
		"sky": Color("#eaf9ff")
	},
	"lunch": {
		"title": "Chapter 2 • Bright Lunch Commons",
		"caption": "Lunch tables, tray colors, and an aide doorway show a busy space with help nearby.",
		"camera": Vector3(2.4, 2.25, 4.9),
		"target": Vector3(3.3, 1.18, -4.6),
		"accent": Color("#48aabd"),
		"sky": Color("#e6fbf4")
	},
	"showcase": {
		"title": "Chapter 3 • Robot Showcase Setup",
		"caption": "Display tables, supply bins, and poster stands keep the scene about safe setup choices instead of spectacle.",
		"camera": Vector3(-0.7, 2.35, 4.4),
		"target": Vector3(-0.4, 1.15, -7.0),
		"accent": Color("#f2a75e"),
		"sky": Color("#fff4df")
	},
	"after_school": {
		"title": "Chapter 4 • Plan-For-Tomorrow Corner",
		"caption": "A welcome bench, route tiles, and the trusted-adult doorway make follow-up support easy to understand.",
		"camera": Vector3(2.9, 2.35, 5.3),
		"target": Vector3(4.9, 1.25, -8.0),
		"accent": Color("#b193d4"),
		"sky": Color("#f3ecff")
	},
	"reflection": {
		"title": "Reflection Board • Replay Ready",
		"caption": "The ending keeps route reflection private, replayable, and free of public scores.",
		"camera": Vector3(0.0, 2.55, 6.0),
		"target": Vector3(0.0, 1.36, -8.8),
		"accent": Color("#f3ca62"),
		"sky": Color("#fff8e4")
	}
}

const INK := Color("#182832")
const PAPER := Color("#fff8e6")
const WALL := Color("#ffe1ad")
const FLOOR := Color("#f7d49a")
const PATH_TEAL := Color("#61b9b2")
const TRUSTED_ADULT := Color("#4d99a7")
const MINA := Color("#a987d6")
const FRIEND := Color("#78b96a")
const CLASSMATE := Color("#f0a35f")

var viewport: SubViewport
var scene_root: Node3D
var camera: Camera3D
var world_environment: WorldEnvironment
var environment: Environment
var sun_light: DirectionalLight3D
var bounce_light: OmniLight3D
var path_light: OmniLight3D
var camera_target := Vector3.ZERO
var chapter_key := "welcome"
var reduced_motion := false
var visual_quality := "playful"
var chapter_nodes: Dictionary = {}
var accent_nodes: Array[MeshInstance3D] = []
var detail_nodes: Array[Node3D] = []
var active_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	_build_viewport()
	_build_world()
	set_context("intro", {}, false, visual_quality)

func _process(_delta: float) -> void:
	if camera != null:
		camera.look_at(camera_target, Vector3.UP)

func set_context(node_id: String, _node: Dictionary, motion_is_reduced: bool, quality: String) -> void:
	reduced_motion = motion_is_reduced
	set_visual_quality(quality)
	chapter_key = NODE_CHAPTERS.get(node_id, "welcome")
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	var target_camera: Vector3 = chapter.get("camera", Vector3(0.0, 2.2, 6.0))
	var target_focus: Vector3 = chapter.get("target", Vector3(0.0, 1.2, -4.0))
	_update_chapter_visibility(chapter_key)
	_update_accent(chapter.get("accent", Color.WHITE), chapter.get("sky", Color("#dff8ff")))
	if reduced_motion or camera == null or not is_inside_tree():
		_apply_camera(target_camera, target_focus)
	else:
		if active_tween != null:
			active_tween.kill()
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.tween_property(camera, "position", target_camera, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "camera_target", target_focus, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func set_visual_quality(quality: String) -> void:
	visual_quality = "calm" if quality == "calm" else "playful"
	var show_details := visual_quality == "playful"
	for node in detail_nodes:
		if node != null:
			node.visible = show_details
	if viewport != null:
		viewport.scaling_3d_scale = 0.68 if visual_quality == "calm" else 0.86
		viewport.msaa_3d = Viewport.MSAA_DISABLED if visual_quality == "calm" else Viewport.MSAA_2X
	if bounce_light != null:
		bounce_light.light_energy = 0.48 if visual_quality == "calm" else 0.66

func get_chapter_title() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	return chapter.get("title", "Maple Commons")

func get_caption_text() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	var suffix := ""
	if visual_quality == "calm":
		suffix = " Low-detail mode keeps the same route and hides extra playful props for slower laptops."
	return "%s%s" % [chapter.get("caption", "Original procedural 3D school commons."), suffix]

func _build_viewport() -> void:
	viewport = SubViewport.new()
	viewport.disable_3d = false
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.scaling_3d_scale = 0.86
	viewport.msaa_3d = Viewport.MSAA_2X
	add_child(viewport)

func _build_world() -> void:
	scene_root = Node3D.new()
	viewport.add_child(scene_root)

	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#dff8ff")
	environment.ambient_light_color = Color("#fff8df")
	environment.ambient_light_energy = 0.86
	environment.glow_enabled = true
	environment.glow_intensity = 0.08
	environment.glow_bloom = 0.05
	world_environment = WorldEnvironment.new()
	world_environment.environment = environment
	scene_root.add_child(world_environment)

	camera = Camera3D.new()
	camera.current = true
	camera.fov = 50.0
	camera.near = 0.05
	camera.far = 80.0
	scene_root.add_child(camera)

	sun_light = DirectionalLight3D.new()
	sun_light.light_color = Color("#fff3bd")
	sun_light.light_energy = 1.55
	sun_light.rotation_degrees = Vector3(-46.0, -28.0, 0.0)
	scene_root.add_child(sun_light)

	bounce_light = OmniLight3D.new()
	bounce_light.light_color = Color("#e2fbff")
	bounce_light.light_energy = 0.66
	bounce_light.omni_range = 14.0
	bounce_light.position = Vector3(3.4, 3.4, 3.8)
	scene_root.add_child(bounce_light)

	path_light = OmniLight3D.new()
	path_light.light_color = Color("#e9fffa")
	path_light.light_energy = 0.32
	path_light.omni_range = 9.0
	path_light.position = Vector3(5.9, 2.2, -7.8)
	scene_root.add_child(path_light)

	_build_architecture()
	_build_safe_route()
	_build_props()
	_build_characters()
	_apply_camera(CHAPTERS["welcome"]["camera"], CHAPTERS["welcome"]["target"])

func _build_architecture() -> void:
	var floor_mat := _mat(FLOOR, 0.92)
	var wall_mat := _mat(WALL, 0.9)
	var trim_mat := _mat(Color("#d09358"), 0.82)
	_add_box("open commons floor", Vector3(0.0, -0.05, -3.8), Vector3(16.8, 0.10, 19.4), floor_mat)
	_add_box("sunny center walkway", Vector3(0.0, 0.01, -3.8), Vector3(5.2, 0.04, 18.4), _mat(Color("#ffecc4"), 0.94))
	_add_box("left mural wall", Vector3(-8.35, 1.82, -4.5), Vector3(0.22, 3.7, 16.6), wall_mat)
	_add_box("right landmark wall", Vector3(8.35, 1.82, -4.5), Vector3(0.22, 3.7, 16.6), wall_mat)
	_add_box("far reflection wall", Vector3(0.0, 1.82, -13.45), Vector3(16.8, 3.7, 0.22), wall_mat)
	_add_box("left color trim", Vector3(-8.20, 2.95, -4.6), Vector3(0.12, 0.16, 15.6), _mat(Color("#f6b95e"), 0.86))
	_add_box("right color trim", Vector3(8.20, 2.95, -4.6), Vector3(0.12, 0.16, 15.6), _mat(Color("#61b9b2"), 0.86))
	for i in range(6):
		var z := 3.7 - float(i) * 2.55
		var stripe_color := Color("#f7c76d") if i % 2 == 0 else Color("#b7df8a")
		_add_box("friendly floor stripe", Vector3(0.0, 0.035, z), Vector3(7.2, 0.035, 0.08), _mat(stripe_color, 0.96))
	for i in range(4):
		var x := -3.6 + float(i) * 2.4
		var panel := _quad("skylight color panel", Vector3(x, 3.75, 0.7 - float(i % 2) * 3.5), Vector2(1.4, 0.65), Color("#ffffff", 0.30))
		panel.rotation_degrees.x = -68.0
		detail_nodes.append(panel)

	# Always-visible readable landmarks, including classroom, lunch, recess, and adult support spaces.
	_add_box("classroom maker door", Vector3(-7.96, 1.55, 0.65), Vector3(0.34, 2.85, 1.45), _mat(Color("#acd889"), 0.84))
	_add_box("classroom window", Vector3(-7.70, 2.18, 0.65), Vector3(0.06, 0.62, 0.92), _mat(Color("#f4fff4", 0.86), 0.55, true))
	_add_box("lunchroom doorway landmark", Vector3(7.96, 1.58, -3.9), Vector3(0.34, 2.92, 1.78), _mat(Color("#9fded3"), 0.84))
	_add_box("recess garden window", Vector3(-7.96, 1.82, -6.95), Vector3(0.34, 2.24, 1.85), _mat(Color("#b9e3ff"), 0.86))
	_add_box("recess grass view", Vector3(-7.72, 1.20, -6.95), Vector3(0.08, 0.55, 1.42), _mat(Color("#84c76a"), 0.78))
	_add_box("trusted adult doorway", Vector3(7.94, 1.72, -8.7), Vector3(0.42, 3.15, 1.95), _mat(Color("#87cfc3"), 0.82))
	_add_box("trusted adult welcome window", Vector3(7.60, 2.56, -8.7), Vector3(0.08, 0.55, 1.20), _mat(Color("#ecfffb", 0.90), 0.55, true))
	_add_box("trusted adult welcome mat", Vector3(6.72, 0.04, -8.7), Vector3(1.15, 0.045, 1.04), _mat(Color("#d8f5ee"), 0.90))

func _build_safe_route() -> void:
	for i in range(8):
		var z := 2.6 - float(i) * 1.42
		var x := 0.8 + float(i) * 0.78
		var tile := _add_box("safe route tile", Vector3(x, 0.055, z), Vector3(0.76, 0.055, 0.45), _mat(PATH_TEAL.lightened(float(i) * 0.025), 0.88))
		accent_nodes.append(tile)
	for i in range(5):
		var dot := _add_cylinder("adult path stepping stone", Vector3(4.4 + float(i) * 0.48, 0.075, -6.2 - float(i) * 0.50), 0.18, 0.045, _mat(Color("#e8fff9"), 0.9))
		accent_nodes.append(dot)
	var arrow := _add_box("safe route arrow", Vector3(6.12, 0.10, -8.05), Vector3(0.92, 0.07, 0.34), _mat(Color("#e8fff9"), 0.88))
	arrow.rotation_degrees.y = -18.0
	accent_nodes.append(arrow)

func _build_props() -> void:
	chapter_nodes.clear()
	for key in CHAPTERS.keys():
		chapter_nodes[key] = []

	# Hallway lockers, kindness board, and maker supplies.
	for i in range(5):
		var z := 2.7 - float(i) * 1.18
		var locker_color := Color("#f6b46d") if i % 2 == 0 else Color("#f7cc6d")
		_register(_add_box("color locker", Vector3(-7.78, 1.18, z), Vector3(0.35, 2.05, 0.78), _mat(locker_color, 0.84)), "hallway")
		_register(_add_box("locker handle", Vector3(-7.55, 1.03, z - 0.16), Vector3(0.045, 0.08, 0.16), _mat(Color("#6d5447"), 0.7)), "hallway")
	var board := _add_box("kindness board", Vector3(-4.20, 1.90, -2.55), Vector3(0.18, 1.55, 2.32), _mat(Color("#ffe4a8"), 0.80))
	_register(board, "hallway")
	_register(_add_box("kindness board frame", Vector3(-4.31, 1.90, -2.55), Vector3(0.12, 1.75, 2.52), _mat(Color("#ba7f52"), 0.74)), "hallway")
	for i in range(5):
		var note := _add_box("kindness note", Vector3(-4.39, 1.42 + float(i % 2) * 0.46, -3.34 + float(i) * 0.34), Vector3(0.04, 0.30, 0.28), _mat(_note_color(i), 0.92))
		_register(note, "hallway")
	_register(_add_box("robot poster", Vector3(-3.05, 0.78, -2.05), Vector3(0.06, 0.90, 0.70), _mat(Color("#dff2ff"), 0.9)), "hallway")
	_register(_add_box("marker cart", Vector3(-2.20, 0.45, -1.50), Vector3(0.72, 0.55, 0.48), _mat(Color("#b7df8a"), 0.84)), "hallway")

	# Lunch tables, trays, and aide doorway cues.
	_register(_add_box("lunch doorway", Vector3(7.70, 1.88, -4.45), Vector3(0.28, 2.75, 1.85), _mat(Color("#a8e4d8"), 0.82)), "lunch")
	_register(_add_box("aide welcome marker", Vector3(7.48, 2.72, -4.45), Vector3(0.06, 0.30, 1.22), _mat(Color("#fff8df", 0.86), 0.55, true)), "lunch")
	for i in range(4):
		var table := _add_box("lunch table", Vector3(3.05 + float(i % 2) * 1.45, 0.58, -3.55 - float(i / 2) * 1.05), Vector3(1.05, 0.18, 0.58), _mat(Color("#f4c985"), 0.86))
		_register(table, "lunch")
		var tray := _add_box("lunch tray", table.position + Vector3(0.08, 0.14, 0.02), Vector3(0.46, 0.045, 0.30), _mat(_note_color(i + 1), 0.88))
		_register(tray, "lunch")
	for i in range(3):
		var fruit := _add_sphere("fruit prop", Vector3(2.65 + float(i) * 0.42, 0.78, -4.95), 0.12, _mat(Color("#f28a66") if i % 2 == 0 else Color("#f5d765"), 0.9))
		_register(fruit, "lunch")

	# Showcase tables and robot-project props.
	for i in range(3):
		var table := _add_box("showcase table", Vector3(-1.9 + float(i) * 1.82, 0.62, -8.1), Vector3(1.34, 0.28, 0.76), _mat(Color("#f7ddb0"), 0.84))
		_register(table, "showcase")
		var poster := _add_box("robot showcase poster", Vector3(-1.9 + float(i) * 1.82, 1.35, -8.46), Vector3(1.02, 0.78, 0.05), _mat(Color("#edf9ff"), 0.9))
		_register(poster, "showcase")
		var gear := _add_cylinder("friendly gear circle", Vector3(-1.9 + float(i) * 1.82, 1.36, -8.39), 0.18, 0.045, _mat(_note_color(i), 0.86))
		gear.rotation_degrees.x = 90.0
		_register(gear, "showcase")
	var tube := _add_cylinder("poster tube", Vector3(-0.15, 1.08, -7.35), 0.06, 1.20, _mat(Color("#ee9b5f"), 0.72))
	tube.rotation_degrees.z = 90.0
	_register(tube, "showcase")
	_register(_add_box("supply bin", Vector3(1.80, 0.42, -7.18), Vector3(0.70, 0.44, 0.46), _mat(Color("#b7df8a"), 0.86)), "showcase")

	# After-school trusted-adult plan corner.
	_register(_add_box("welcome bench", Vector3(5.10, 0.54, -8.10), Vector3(2.18, 0.25, 0.55), _mat(Color("#bf916c"), 0.80)), "after_school")
	_register(_add_box("plan clipboard", Vector3(5.04, 0.84, -8.05), Vector3(0.62, 0.06, 0.42), _mat(PAPER, 0.88)), "after_school")
	_register(_add_box("tomorrow plan card", Vector3(6.45, 1.52, -8.72), Vector3(0.08, 0.92, 0.68), _mat(Color("#f8f3ff"), 0.88)), "after_school")
	_register(_add_box("adult office plant", Vector3(6.68, 0.48, -9.75), Vector3(0.44, 0.34, 0.44), _mat(Color("#7fc66d"), 0.86)), "after_school")

	# Reflection board at the far end.
	var reflection_board := _add_box("private reflection board", Vector3(0.0, 2.02, -13.28), Vector3(4.5, 2.08, 0.08), _mat(PAPER, 0.88))
	_register(reflection_board, "reflection")
	for i in range(4):
		var card := _add_box("replay route card", Vector3(-1.50 + float(i) * 1.00, 2.00, -13.19), Vector3(0.64, 0.82, 0.06), _mat(_note_color(i), 0.9))
		_register(card, "reflection")
		var dot := _add_cylinder("choice dot", Vector3(-1.50 + float(i) * 1.00, 1.55, -13.15), 0.10, 0.045, _mat(Color("#61b9b2"), 0.88))
		dot.rotation_degrees.x = 90.0
		_register(dot, "reflection")

	# Shared accent rails mark the active chapter without pressure or countdowns.
	for i in range(4):
		var rail := _add_box("chapter color rail", Vector3(-3.0 + float(i) * 2.0, 0.075, -10.7), Vector3(1.05, 0.06, 0.12), _mat(Color("#ffffff", 0.70), 0.5, true))
		accent_nodes.append(rail)
		detail_nodes.append(rail)

func _build_characters() -> void:
	_register(_make_avatar(Vector3(-2.35, 0.0, -2.82), MINA, 1.02, "Mina-friendly avatar"), "hallway")
	_register(_make_avatar(Vector3(-3.28, 0.0, -1.78), FRIEND, 0.98, "peer helper avatar"), "hallway")
	_register(_make_avatar(Vector3(-1.12, 0.0, -3.52), CLASSMATE, 0.96, "classmate avatar"), "hallway")
	_register(_make_avatar(Vector3(4.34, 0.0, -4.72), TRUSTED_ADULT, 1.08, "lunch aide avatar"), "lunch")
	_register(_make_avatar(Vector3(3.02, 0.0, -3.62), MINA, 0.98, "Mina lunch avatar"), "lunch")
	_register(_make_avatar(Vector3(4.95, 0.0, -3.48), FRIEND, 0.96, "tablemate avatar"), "lunch")
	_register(_make_avatar(Vector3(-0.82, 0.0, -7.05), MINA, 0.98, "Mina showcase avatar"), "showcase")
	_register(_make_avatar(Vector3(0.58, 0.0, -7.54), FRIEND, 0.98, "peer bridge avatar"), "showcase")
	_register(_make_avatar(Vector3(2.18, 0.0, -8.20), TRUSTED_ADULT, 1.08, "Ms Rivera avatar"), "showcase")
	_register(_make_avatar(Vector3(4.62, 0.0, -7.70), MINA, 0.98, "Mina plan avatar"), "after_school")
	_register(_make_avatar(Vector3(5.72, 0.0, -7.30), FRIEND, 0.98, "follow-up friend avatar"), "after_school")
	_register(_make_avatar(Vector3(6.90, 0.0, -8.86), TRUSTED_ADULT, 1.10, "trusted adult welcome avatar"), "after_school")

func _make_avatar(origin: Vector3, body_color: Color, scale: float, avatar_name: String) -> Node3D:
	var avatar := Node3D.new()
	avatar.name = avatar_name
	scene_root.add_child(avatar)
	var torso := _mesh_instance(CapsuleMesh.new(), _mat(body_color, 0.82))
	(torso.mesh as CapsuleMesh).radius = 0.18 * scale
	(torso.mesh as CapsuleMesh).height = 0.78 * scale
	torso.position = origin + Vector3(0.0, 0.77 * scale, 0.0)
	avatar.add_child(torso)
	var head := _mesh_instance(SphereMesh.new(), _mat(Color("#f0c19d"), 0.86))
	(head.mesh as SphereMesh).radius = 0.21 * scale
	(head.mesh as SphereMesh).height = 0.42 * scale
	head.position = origin + Vector3(0.0, 1.31 * scale, 0.0)
	avatar.add_child(head)
	var hair := _mesh_instance(SphereMesh.new(), _mat(Color("#725643"), 0.9))
	(hair.mesh as SphereMesh).radius = 0.215 * scale
	(hair.mesh as SphereMesh).height = 0.22 * scale
	hair.position = origin + Vector3(0.0, 1.42 * scale, -0.015)
	avatar.add_child(hair)
	for x in [-0.07, 0.07]:
		var eye := _mesh_instance(SphereMesh.new(), _mat(INK, 0.92))
		(eye.mesh as SphereMesh).radius = 0.025 * scale
		(eye.mesh as SphereMesh).height = 0.05 * scale
		eye.name = "friendly eye"
		eye.position = origin + Vector3(x * scale, 1.34 * scale, 0.18 * scale)
		avatar.add_child(eye)
	for x in [-0.12, 0.12]:
		var leg := _mesh_instance(CapsuleMesh.new(), _mat(Color("#4d5f68"), 0.88))
		(leg.mesh as CapsuleMesh).radius = 0.055 * scale
		(leg.mesh as CapsuleMesh).height = 0.55 * scale
		leg.position = origin + Vector3(x * scale, 0.28 * scale, 0.0)
		avatar.add_child(leg)
	for x in [-0.25, 0.25]:
		var arm := _mesh_instance(CapsuleMesh.new(), _mat(Color("#7a6252"), 0.9))
		(arm.mesh as CapsuleMesh).radius = 0.045 * scale
		(arm.mesh as CapsuleMesh).height = 0.44 * scale
		arm.position = origin + Vector3(x * scale, 0.84 * scale, 0.0)
		arm.rotation_degrees.z = 10.0 * signf(x)
		avatar.add_child(arm)
	return avatar

func _register(node: Node3D, key: String) -> void:
	if not chapter_nodes.has(key):
		chapter_nodes[key] = []
	chapter_nodes[key].append(node)

func _update_chapter_visibility(active_key: String) -> void:
	for key in chapter_nodes.keys():
		var should_show: bool = key == active_key or (key == "reflection" and active_key == "welcome")
		for node in chapter_nodes[key]:
			if node != null:
				node.visible = should_show

func _update_accent(accent: Color, sky_color: Color) -> void:
	for node in accent_nodes:
		if node != null:
			var mat := node.get_surface_override_material(0) as StandardMaterial3D
			if mat != null:
				mat.albedo_color = accent.lightened(0.18)
				mat.emission = accent
	if environment != null:
		environment.background_color = sky_color
	if path_light != null:
		path_light.light_color = accent.lightened(0.28)

func _apply_camera(position: Vector3, target: Vector3) -> void:
	if camera == null:
		return
	camera.position = position
	camera_target = target
	camera.look_at(camera_target, Vector3.UP)

func _add_box(node_name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := _mesh_instance(mesh, material)
	node.name = node_name
	node.position = position
	scene_root.add_child(node)
	return node

func _add_cylinder(node_name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	var node := _mesh_instance(mesh, material)
	node.name = node_name
	node.position = position
	scene_root.add_child(node)
	return node

func _add_sphere(node_name: String, position: Vector3, radius: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var node := _mesh_instance(mesh, material)
	node.name = node_name
	node.position = position
	scene_root.add_child(node)
	return node

func _quad(node_name: String, position: Vector3, size: Vector2, color: Color) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = size
	var node := _mesh_instance(mesh, _mat(color, 1.0, true))
	node.name = node_name
	node.position = position
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	scene_root.add_child(node)
	return node

func _mesh_instance(mesh: Mesh, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.set_surface_override_material(0, material)
	return node

func _mat(color: Color, roughness: float = 0.86, unshaded: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.0
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = Color(color.r, color.g, color.b, minf(color.a + 0.18, 1.0))
		material.emission_energy_multiplier = 0.45
	return material

func _note_color(index: int) -> Color:
	if index % 5 == 0:
		return Color("#f9faf1")
	if index % 5 == 1:
		return Color("#d9eff0")
	if index % 5 == 2:
		return Color("#fde3d5")
	if index % 5 == 3:
		return Color("#e9e0f1")
	return Color("#def2c9")
