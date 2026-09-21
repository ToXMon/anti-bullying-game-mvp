extends SubViewportContainer
class_name CinematicHallwayWorld

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
		"title": "Prologue • Maple Commons",
		"caption": "A warm, fictional school hallway frames practice without collecting personal stories.",
		"camera": Vector3(0.0, 2.25, 7.2),
		"target": Vector3(0.0, 1.28, -3.2),
		"accent": Color("#f1ad72"),
		"fog": Color("#ffe8c8")
	},
	"hallway": {
		"title": "Chapter 1 • Hallway Board",
		"caption": "Lockers, a bulletin board, and open walking space keep the first bystander choice calm and readable.",
		"camera": Vector3(-2.3, 2.05, 5.8),
		"target": Vector3(-2.7, 1.20, -3.1),
		"accent": Color("#96bd74"),
		"fog": Color("#f8dfbb")
	},
	"lunch": {
		"title": "Chapter 2 • Lunchroom Doorway",
		"caption": "A brighter lunch threshold adds a new space while keeping the trusted-adult route visible.",
		"camera": Vector3(2.2, 2.15, 4.9),
		"target": Vector3(2.8, 1.22, -4.9),
		"accent": Color("#62a9b7"),
		"fog": Color("#e7f4ef")
	},
	"showcase": {
		"title": "Chapter 3 • Showcase Setup",
		"caption": "Display tables and poster shapes signal a more serious moment without fear spikes or graphic imagery.",
		"camera": Vector3(-0.8, 2.25, 4.4),
		"target": Vector3(-0.6, 1.18, -7.2),
		"accent": Color("#d99a65"),
		"fog": Color("#fff0d7")
	},
	"after_school": {
		"title": "Chapter 4 • After-School Plan",
		"caption": "Soft exit light and a nearby adult doorway support a respectful follow-up plan.",
		"camera": Vector3(2.8, 2.35, 5.4),
		"target": Vector3(4.4, 1.32, -7.7),
		"accent": Color("#a88ac6"),
		"fog": Color("#efe7f6")
	},
	"reflection": {
		"title": "Reflection Board • Replay Ready",
		"caption": "The ending keeps route reflection private, replayable, and free of public scores.",
		"camera": Vector3(0.0, 2.55, 6.1),
		"target": Vector3(0.0, 1.42, -8.8),
		"accent": Color("#f0c767"),
		"fog": Color("#fff6df")
	}
}

const INK := Color("#182832")
const PAPER := Color("#fff7e7")
const WALL := Color("#f6d7ad")
const FLOOR := Color("#edc894")
const LOCKER := Color("#e7a86f")
const TRUSTED_ADULT := Color("#5f9eae")
const MINA := Color("#a888c5")
const FRIEND := Color("#78a66f")
const JOSS := Color("#d9935f")

var viewport: SubViewport
var scene_root: Node3D
var camera: Camera3D
var world_environment: WorldEnvironment
var environment: Environment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var rim_light: DirectionalLight3D
var camera_target := Vector3.ZERO
var chapter_key := "welcome"
var reduced_motion := false
var visual_quality := "cinematic"
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
	var target_focus: Vector3 = chapter.get("target", Vector3(0.0, 1.3, -4.0))
	_update_chapter_visibility(chapter_key)
	_update_accent(chapter.get("accent", Color.WHITE), chapter.get("fog", Color("#fff6df")))
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
	visual_quality = quality if quality == "calm" else "cinematic"
	var show_details := visual_quality == "cinematic"
	for node in detail_nodes:
		if node != null:
			node.visible = show_details
	if viewport != null:
		viewport.scaling_3d_scale = 0.68 if visual_quality == "calm" else 0.86
		viewport.msaa_3d = Viewport.MSAA_DISABLED if visual_quality == "calm" else Viewport.MSAA_2X
	if fill_light != null:
		fill_light.light_energy = 0.42 if visual_quality == "calm" else 0.64

func get_chapter_title() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	return chapter.get("title", "Maple Commons")

func get_caption_text() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	var suffix := ""
	if visual_quality == "calm":
		suffix = " Low-detail mode hides decorative fog layers for slower laptops."
	return "%s%s" % [chapter.get("caption", "Original procedural 3D hallway."), suffix]

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
	environment.background_color = Color("#fff1d3")
	environment.ambient_light_color = Color("#fff7e5")
	environment.ambient_light_energy = 0.54
	environment.fog_enabled = true
	environment.fog_light_color = Color("#fff1d3")
	environment.fog_density = 0.018
	environment.glow_enabled = true
	environment.glow_intensity = 0.13
	environment.glow_bloom = 0.08
	world_environment = WorldEnvironment.new()
	world_environment.environment = environment
	scene_root.add_child(world_environment)

	camera = Camera3D.new()
	camera.current = true
	camera.fov = 50.0
	camera.near = 0.05
	camera.far = 80.0
	scene_root.add_child(camera)

	key_light = DirectionalLight3D.new()
	key_light.light_color = Color("#ffe2b3")
	key_light.light_energy = 1.42
	key_light.rotation_degrees = Vector3(-38.0, -31.0, 0.0)
	scene_root.add_child(key_light)

	fill_light = OmniLight3D.new()
	fill_light.light_color = Color("#dff8ff")
	fill_light.light_energy = 0.64
	fill_light.omni_range = 13.0
	fill_light.position = Vector3(3.8, 3.2, 3.4)
	scene_root.add_child(fill_light)

	rim_light = DirectionalLight3D.new()
	rim_light.light_color = Color("#fffaf0")
	rim_light.light_energy = 0.46
	rim_light.rotation_degrees = Vector3(-22.0, 138.0, 0.0)
	scene_root.add_child(rim_light)

	_build_architecture()
	_build_depth_layers()
	_build_props()
	_build_characters()
	_apply_camera(CHAPTERS["welcome"]["camera"], CHAPTERS["welcome"]["target"])

func _build_architecture() -> void:
	var floor_mat := _mat(FLOOR, 0.92)
	var wall_mat := _mat(WALL, 0.88)
	var trim_mat := _mat(Color("#c58b5f"), 0.82)
	_add_box("floor", Vector3(0.0, -0.05, -3.8), Vector3(16.6, 0.10, 19.4), floor_mat)
	_add_box("left wall", Vector3(-8.35, 2.35, -3.8), Vector3(0.22, 4.8, 19.4), wall_mat)
	_add_box("right wall", Vector3(8.35, 2.35, -3.8), Vector3(0.22, 4.8, 19.4), wall_mat)
	_add_box("back wall", Vector3(0.0, 2.35, -13.45), Vector3(16.6, 4.8, 0.22), wall_mat)
	_add_box("ceiling", Vector3(0.0, 4.72, -3.8), Vector3(16.6, 0.20, 19.4), _mat(Color("#ffe9ca"), 0.9))
	_add_box("left chair rail", Vector3(-8.21, 1.35, -3.8), Vector3(0.14, 0.13, 18.4), trim_mat)
	_add_box("right chair rail", Vector3(8.21, 1.35, -3.8), Vector3(0.14, 0.13, 18.4), trim_mat)
	for i in range(8):
		var z := 4.0 - float(i) * 2.15
		_add_box("floor guide", Vector3(0.0, 0.01, z), Vector3(13.4 - float(i) * 0.55, 0.035, 0.045), _mat(Color("#d8ad78", 0.55), 0.96))
	for i in range(7):
		var z_band := 3.2 - float(i) * 2.35
		_add_box("ceiling beam", Vector3(0.0, 4.55, z_band), Vector3(16.3, 0.18, 0.10), _mat(Color("#dfb783"), 0.86))

func _build_depth_layers() -> void:
	for i in range(5):
		var z := 1.8 - float(i) * 3.2
		var fog := _quad("soft depth haze", Vector3(0.0, 2.35, z), Vector2(16.0, 4.2), Color("#ffffff", 0.085 + float(i) * 0.012))
		detail_nodes.append(fog)
	for i in range(7):
		var x := -5.8 + float(i) * 1.9
		var glow := _add_box("floor light patch", Vector3(x, 0.025, -0.4 - float(i % 3) * 3.4), Vector3(0.9, 0.018, 1.35), _mat(Color("#fff8d8", 0.28), 0.6, true))
		detail_nodes.append(glow)

func _build_props() -> void:
	chapter_nodes.clear()
	for key in CHAPTERS.keys():
		chapter_nodes[key] = []

	# Hallway lockers and bulletin board.
	for i in range(6):
		var z := 2.8 - float(i) * 1.35
		var locker := _add_box("locker", Vector3(-7.83, 1.22, z), Vector3(0.35, 2.15, 0.92), _mat(LOCKER, 0.82))
		locker.rotation_degrees.y = 0.0
		_register(locker, "hallway")
		_register(_add_box("locker seam", Vector3(-7.62, 1.22, z), Vector3(0.035, 1.9, 0.04), _mat(Color("#bd764d"), 0.8)), "hallway")
		_register(_add_box("locker handle", Vector3(-7.60, 1.04, z - 0.20), Vector3(0.04, 0.08, 0.20), _mat(Color("#6d5447"), 0.6)), "hallway")

	var board := _add_box("bulletin board", Vector3(-4.05, 1.95, -2.6), Vector3(0.18, 1.55, 2.20), _mat(Color("#ffe0a5"), 0.78))
	_register(board, "hallway")
	_register(_add_box("bulletin frame", Vector3(-4.16, 1.95, -2.6), Vector3(0.12, 1.73, 2.40), _mat(Color("#b57a52"), 0.72)), "hallway")
	for i in range(4):
		var note := _add_box("kindness note", Vector3(-4.25, 1.62 + float(i % 2) * 0.48, -3.25 + float(i) * 0.38), Vector3(0.04, 0.34, 0.30), _mat(_note_color(i), 0.92))
		_register(note, "hallway")

	# Lunchroom doorway.
	var lunch_door := _add_box("lunch doorway", Vector3(7.82, 1.92, -4.5), Vector3(0.36, 3.1, 2.05), _mat(Color("#b8ddd3"), 0.82))
	_register(lunch_door, "lunch")
	_register(_add_box("lunch light", Vector3(7.58, 2.82, -4.5), Vector3(0.06, 0.30, 1.45), _mat(Color("#fff9e8", 0.82), 0.5, true)), "lunch")
	for i in range(4):
		var tray := _add_box("lunch table", Vector3(3.3 + float(i % 2) * 1.35, 0.58, -3.7 - float(i / 2) * 0.95), Vector3(1.0, 0.18, 0.56), _mat(Color("#f3c98c"), 0.86))
		_register(tray, "lunch")

	# Showcase tables and robot-poster-safe display.
	for i in range(3):
		var table := _add_box("showcase table", Vector3(-1.8 + float(i) * 1.75, 0.62, -8.2), Vector3(1.32, 0.28, 0.74), _mat(Color("#f6dcae"), 0.84))
		_register(table, "showcase")
		var poster := _add_box("showcase poster", Vector3(-1.8 + float(i) * 1.75, 1.35, -8.55), Vector3(1.02, 0.78, 0.05), _mat(Color("#edf7f6"), 0.9))
		_register(poster, "showcase")
	var tube := _add_cylinder("poster tube", Vector3(-0.1, 1.08, -7.42), 0.06, 1.28, _mat(Color("#d9935f"), 0.68))
	tube.rotation_degrees.z = 90.0
	_register(tube, "showcase")

	# After-school exit and trusted-adult office door.
	var adult_door := _add_box("trusted adult doorway", Vector3(7.82, 1.95, -8.8), Vector3(0.40, 3.16, 1.75), _mat(Color("#9acbc1"), 0.82))
	_register(adult_door, "after_school")
	_register(_add_box("adult doorway window", Vector3(7.56, 2.62, -8.8), Vector3(0.06, 0.55, 1.05), _mat(Color("#eafffb", 0.88), 0.55, true)), "after_school")
	_register(_add_box("quiet bench", Vector3(5.0, 0.55, -8.25), Vector3(2.2, 0.25, 0.55), _mat(Color("#b98b6d"), 0.78)), "after_school")

	# Reflection board at the far end.
	var reflection_board := _add_box("reflection board", Vector3(0.0, 2.08, -13.30), Vector3(4.2, 2.2, 0.08), _mat(PAPER, 0.88))
	_register(reflection_board, "reflection")
	for i in range(4):
		var card := _add_box("private route card", Vector3(-1.45 + float(i) * 0.96, 2.02, -13.22), Vector3(0.62, 0.82, 0.06), _mat(_note_color(i), 0.9))
		_register(card, "reflection")

	# Shared soft accent rails mark the active chapter.
	for i in range(4):
		var rail := _add_box("chapter glow rail", Vector3(-3.0 + float(i) * 2.0, 0.055, -10.7), Vector3(1.05, 0.05, 0.10), _mat(Color("#ffffff", 0.55), 0.5, true))
		accent_nodes.append(rail)
		detail_nodes.append(rail)

func _build_characters() -> void:
	_register(_make_avatar(Vector3(-2.35, 0.0, -2.85), MINA, 1.02), "hallway")
	_register(_make_avatar(Vector3(-3.2, 0.0, -1.85), FRIEND, 0.98), "hallway")
	_register(_make_avatar(Vector3(-1.15, 0.0, -3.45), JOSS, 0.96), "hallway")
	_register(_make_avatar(Vector3(4.2, 0.0, -4.7), TRUSTED_ADULT, 1.08), "lunch")
	_register(_make_avatar(Vector3(3.1, 0.0, -3.7), MINA, 0.98), "lunch")
	_register(_make_avatar(Vector3(-0.8, 0.0, -7.1), MINA, 0.98), "showcase")
	_register(_make_avatar(Vector3(0.58, 0.0, -7.55), FRIEND, 0.98), "showcase")
	_register(_make_avatar(Vector3(2.2, 0.0, -8.25), TRUSTED_ADULT, 1.08), "showcase")
	_register(_make_avatar(Vector3(4.6, 0.0, -7.75), MINA, 0.98), "after_school")
	_register(_make_avatar(Vector3(5.65, 0.0, -7.35), FRIEND, 0.98), "after_school")
	_register(_make_avatar(Vector3(6.92, 0.0, -8.9), TRUSTED_ADULT, 1.08), "after_school")

func _make_avatar(origin: Vector3, body_color: Color, scale: float) -> Node3D:
	var avatar := Node3D.new()
	avatar.name = "friendly avatar"
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
	(hair.mesh as SphereMesh).height = 0.26 * scale
	hair.position = origin + Vector3(0.0, 1.42 * scale, -0.015)
	avatar.add_child(hair)
	for x in [-0.12, 0.12]:
		var leg := _mesh_instance(CapsuleMesh.new(), _mat(Color("#4d5f68"), 0.88))
		(leg.mesh as CapsuleMesh).radius = 0.055 * scale
		(leg.mesh as CapsuleMesh).height = 0.55 * scale
		leg.position = origin + Vector3(x * scale, 0.28 * scale, 0.0)
		avatar.add_child(leg)
	for x in [-0.25, 0.25]:
		var arm := _mesh_instance(CapsuleMesh.new(), _mat(Color("#6f5c50"), 0.9))
		(arm.mesh as CapsuleMesh).radius = 0.045 * scale
		(arm.mesh as CapsuleMesh).height = 0.44 * scale
		arm.position = origin + Vector3(x * scale, 0.82 * scale, 0.0)
		arm.rotation_degrees.z = 12.0 * signf(x)
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

func _update_accent(accent: Color, fog_color: Color) -> void:
	for node in accent_nodes:
		if node != null:
			var mat := node.get_surface_override_material(0) as StandardMaterial3D
			if mat != null:
				mat.albedo_color = accent.lightened(0.18)
				mat.emission = accent
	if environment != null:
		environment.background_color = fog_color.lightened(0.12)
		environment.fog_light_color = fog_color

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
	mesh.radial_segments = 16
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
	if index == 0:
		return Color("#f9faf1")
	if index == 1:
		return Color("#d9eff0")
	if index == 2:
		return Color("#fde3d5")
	return Color("#e9e0f1")
