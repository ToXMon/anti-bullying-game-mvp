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
		"caption": "A full-screen procedural 3D school world frames private, non-shaming practice without collecting personal stories.",
		"camera": Vector3(0.0, 2.55, 7.8),
		"target": Vector3(0.0, 1.38, -5.1),
		"accent": Color("#f1ad72"),
		"fog": Color("#ffe8c8")
	},
	"hallway": {
		"title": "Chapter 1 • Hallway Board",
		"caption": "Layered lockers, bulletin-board craft, and open walking space keep the first bystander choice calm and readable.",
		"camera": Vector3(-4.4, 2.25, 4.7),
		"target": Vector3(-5.6, 1.32, -2.5),
		"accent": Color("#96bd74"),
		"fog": Color("#f8dfbb")
	},
	"lunch": {
		"title": "Chapter 2 • Lunchroom Doorway",
		"caption": "A brighter lunch threshold, trays, and soft adult sightlines make the second space visibly distinct.",
		"camera": Vector3(3.8, 2.35, 4.1),
		"target": Vector3(5.9, 1.32, -4.3),
		"accent": Color("#62a9b7"),
		"fog": Color("#e7f4ef")
	},
	"showcase": {
		"title": "Chapter 3 • Showcase Setup",
		"caption": "Robot displays, tables, and poster-tube props signal a serious moment without fear spikes or graphic imagery.",
		"camera": Vector3(-1.4, 2.45, 3.6),
		"target": Vector3(-0.4, 1.38, -8.1),
		"accent": Color("#d99a65"),
		"fog": Color("#fff0d7")
	},
	"after_school": {
		"title": "Chapter 4 • After-School Plan",
		"caption": "A welcoming trusted-adult doorway, bench, backpacks, and plan board support a respectful close.",
		"camera": Vector3(4.4, 2.55, 4.8),
		"target": Vector3(6.2, 1.42, -8.9),
		"accent": Color("#a88ac6"),
		"fog": Color("#efe7f6")
	},
	"reflection": {
		"title": "Reflection Board • Replay Ready",
		"caption": "The ending presents private route reflection as cards on a calm board, never as a public score.",
		"camera": Vector3(0.0, 2.75, 5.6),
		"target": Vector3(0.0, 1.62, -12.3),
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
const DEEP_SHADOW := Color("#5f5047")

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
	var target_camera: Vector3 = chapter.get("camera", Vector3(0.0, 2.6, 7.0))
	var target_focus: Vector3 = chapter.get("target", Vector3(0.0, 1.4, -5.0))
	_update_chapter_visibility(chapter_key)
	_update_accent(chapter.get("accent", Color.WHITE), chapter.get("fog", Color("#fff6df")))
	if reduced_motion or camera == null or not is_inside_tree():
		_apply_camera(target_camera, target_focus)
	else:
		if active_tween != null:
			active_tween.kill()
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.tween_property(camera, "position", target_camera, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "camera_target", target_focus, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func set_visual_quality(quality: String) -> void:
	visual_quality = quality if quality == "calm" else "cinematic"
	var show_details: bool = visual_quality == "cinematic"
	for node in detail_nodes:
		if node != null:
			node.visible = show_details
	if viewport != null:
		viewport.scaling_3d_scale = 0.72 if visual_quality == "calm" else 1.0
		viewport.msaa_3d = Viewport.MSAA_DISABLED if visual_quality == "calm" else Viewport.MSAA_4X
	if fill_light != null:
		fill_light.light_energy = 0.38 if visual_quality == "calm" else 0.70
	if environment != null:
		environment.glow_enabled = visual_quality == "cinematic"

func get_chapter_title() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	return chapter.get("title", "Maple Commons")

func get_caption_text() -> String:
	var chapter: Dictionary = CHAPTERS.get(chapter_key, CHAPTERS["welcome"])
	var suffix := ""
	if visual_quality == "calm":
		suffix = " Low-detail mode hides decorative haze, light shafts, and foreground flourishes for slower laptops."
	return "%s%s" % [chapter.get("caption", "Original procedural 3D hallway."), suffix]

func get_world_metrics() -> Dictionary:
	return {
		"mesh_instances": _count_meshes(scene_root),
		"visible_mesh_instances": _count_visible_meshes(scene_root),
		"detail_nodes": detail_nodes.size(),
		"chapter": chapter_key
	}

func _build_viewport() -> void:
	viewport = SubViewport.new()
	viewport.disable_3d = false
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.scaling_3d_scale = 1.0
	viewport.msaa_3d = Viewport.MSAA_4X
	add_child(viewport)

func _build_world() -> void:
	scene_root = Node3D.new()
	viewport.add_child(scene_root)

	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#fff1d3")
	environment.ambient_light_color = Color("#fff7e5")
	environment.ambient_light_energy = 0.62
	environment.fog_enabled = true
	environment.fog_light_color = Color("#fff1d3")
	environment.fog_density = 0.020
	environment.glow_enabled = true
	environment.glow_intensity = 0.18
	environment.glow_bloom = 0.10
	world_environment = WorldEnvironment.new()
	world_environment.environment = environment
	scene_root.add_child(world_environment)

	camera = Camera3D.new()
	camera.current = true
	camera.fov = 44.0
	camera.near = 0.05
	camera.far = 90.0
	scene_root.add_child(camera)

	key_light = DirectionalLight3D.new()
	key_light.light_color = Color("#ffe2b3")
	key_light.light_energy = 1.55
	key_light.shadow_enabled = true
	key_light.rotation_degrees = Vector3(-42.0, -30.0, 0.0)
	scene_root.add_child(key_light)

	fill_light = OmniLight3D.new()
	fill_light.light_color = Color("#dff8ff")
	fill_light.light_energy = 0.70
	fill_light.omni_range = 16.0
	fill_light.position = Vector3(4.7, 3.7, 3.8)
	scene_root.add_child(fill_light)

	rim_light = DirectionalLight3D.new()
	rim_light.light_color = Color("#fffaf0")
	rim_light.light_energy = 0.52
	rim_light.rotation_degrees = Vector3(-25.0, 138.0, 0.0)
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
	_add_box("floor", Vector3(0.0, -0.05, -4.6), Vector3(18.6, 0.10, 22.2), floor_mat)
	_add_box("left wall", Vector3(-9.35, 2.55, -4.6), Vector3(0.26, 5.15, 22.2), wall_mat)
	_add_box("right wall", Vector3(9.35, 2.55, -4.6), Vector3(0.26, 5.15, 22.2), wall_mat)
	_add_box("back wall", Vector3(0.0, 2.55, -15.62), Vector3(18.6, 5.15, 0.24), wall_mat)
	_add_box("ceiling", Vector3(0.0, 5.08, -4.6), Vector3(18.6, 0.24, 22.2), _mat(Color("#ffe9ca"), 0.9))
	_add_box("left chair rail", Vector3(-9.16, 1.38, -4.6), Vector3(0.16, 0.13, 21.2), trim_mat)
	_add_box("right chair rail", Vector3(9.16, 1.38, -4.6), Vector3(0.16, 0.13, 21.2), trim_mat)
	_add_box("left baseboard", Vector3(-9.13, 0.18, -4.6), Vector3(0.20, 0.20, 21.2), _mat(Color("#bf865e"), 0.84))
	_add_box("right baseboard", Vector3(9.13, 0.18, -4.6), Vector3(0.20, 0.20, 21.2), _mat(Color("#bf865e"), 0.84))

	for i in range(10):
		var z: float = 5.2 - float(i) * 2.15
		_add_box("floor tile seam", Vector3(0.0, 0.012, z), Vector3(15.0 - float(i) * 0.55, 0.035, 0.045), _mat(Color("#d8ad78", 0.55), 0.96))
	for i in range(9):
		var x: float = -7.2 + float(i) * 1.8
		_add_box("floor perspective seam", Vector3(x, 0.014, -5.4), Vector3(0.04, 0.030, 18.4), _mat(Color("#d8ad78", 0.28), 0.96))
	for i in range(8):
		var z_band: float = 4.4 - float(i) * 2.55
		_add_box("ceiling beam", Vector3(0.0, 4.90, z_band), Vector3(18.2, 0.20, 0.12), _mat(Color("#dfb783"), 0.86))
		var light_panel := _add_box("warm ceiling light", Vector3(0.0, 4.76, z_band - 0.65), Vector3(2.4, 0.05, 0.40), _mat(Color("#fff6cc", 0.88), 0.55, true))
		detail_nodes.append(light_panel)

func _build_depth_layers() -> void:
	for i in range(6):
		var z: float = 2.8 - float(i) * 3.0
		var fog := _quad("soft depth haze", Vector3(0.0, 2.60, z), Vector2(18.1, 4.8), Color("#ffffff", 0.06 + float(i) * 0.012))
		detail_nodes.append(fog)
	for i in range(9):
		var x: float = -7.0 + float(i) * 1.75
		var glow := _add_box("floor light patch", Vector3(x, 0.026, -0.4 - float(i % 4) * 3.0), Vector3(1.10, 0.018, 1.55), _mat(Color("#fff8d8", 0.25), 0.6, true))
		detail_nodes.append(glow)
	for i in range(4):
		var shaft := _quad("cinematic light shaft", Vector3(-5.6 + float(i) * 3.7, 2.95, 1.0 - float(i) * 3.1), Vector2(1.2, 4.0), Color("#fff4bd", 0.10))
		shaft.rotation_degrees.y = -14.0 + float(i) * 8.0
		detail_nodes.append(shaft)

func _build_props() -> void:
	chapter_nodes.clear()
	for key in CHAPTERS.keys():
		chapter_nodes[key] = []

	for i in range(8):
		var locker := _make_layered_locker(Vector3(-8.95, 0.0, 4.0 - float(i) * 1.16), Color("#e8a66d") if i % 2 == 0 else Color("#d99766"))
		_register(locker, "hallway")
	_register(_make_bulletin_cluster(Vector3(-8.82, 0.0, -5.6)), "hallway")
	_register(_make_display_case(Vector3(-8.80, 0.0, -8.2), Color("#e5f5f2")), "hallway")
	_register(_make_floor_emblem(Vector3(-4.3, 0.05, -1.2), Color("#96bd74")), "hallway")

	_register(_make_scene_portal(Vector3(8.83, 0.0, -4.7), Color("#b8ddd3"), Color("#62a9b7"), "trusted adult doorway"), "lunch")
	for i in range(4):
		var table := _make_lunch_table(Vector3(3.3 + float(i % 2) * 1.55, 0.0, -3.6 - float(i / 2) * 1.20))
		_register(table, "lunch")
	_register(_make_display_case(Vector3(8.80, 0.0, -7.2), Color("#e6f8ff")), "lunch")
	_register(_make_floor_emblem(Vector3(5.6, 0.05, -4.5), Color("#62a9b7")), "lunch")

	for i in range(3):
		_register(_make_showcase_table(Vector3(-2.2 + float(i) * 2.2, 0.0, -8.3), i), "showcase")
	var tube := _add_cylinder("poster tube", Vector3(0.0, 1.12, -7.08), 0.075, 1.55, _mat(Color("#d9935f"), 0.68))
	tube.rotation_degrees.z = 90.0
	_register(tube, "showcase")
	_register(_make_floor_emblem(Vector3(-0.1, 0.05, -7.0), Color("#d99a65")), "showcase")

	_register(_make_scene_portal(Vector3(8.83, 0.0, -9.2), Color("#9acbc1"), TRUSTED_ADULT, "trusted adult doorway"), "after_school")
	_register(_make_bench_and_bags(Vector3(5.1, 0.0, -8.35)), "after_school")
	_register(_make_plan_board(Vector3(8.78, 0.0, -11.2)), "after_school")
	_register(_make_floor_emblem(Vector3(6.2, 0.05, -8.5), Color("#a88ac6")), "after_school")

	_register(_make_reflection_wall(Vector3(0.0, 0.0, -15.40)), "reflection")
	_register(_make_floor_emblem(Vector3(0.0, 0.05, -11.4), Color("#f0c767")), "reflection")

	for i in range(5):
		var rail := _add_box("chapter glow rail", Vector3(-4.0 + float(i) * 2.0, 0.055, -10.7), Vector3(1.20, 0.05, 0.10), _mat(Color("#ffffff", 0.55), 0.5, true))
		accent_nodes.append(rail)
		detail_nodes.append(rail)

func _build_characters() -> void:
	_register(_make_avatar(Vector3(-5.2, 0.0, -2.85), MINA, 1.10, true), "hallway")
	_register(_make_avatar(Vector3(-6.2, 0.0, -1.72), FRIEND, 1.02, false), "hallway")
	_register(_make_avatar(Vector3(-4.0, 0.0, -3.70), JOSS, 1.00, false), "hallway")
	_register(_make_avatar(Vector3(6.8, 0.0, -4.9), TRUSTED_ADULT, 1.14, false), "lunch")
	_register(_make_avatar(Vector3(4.6, 0.0, -3.65), MINA, 1.04, true), "lunch")
	_register(_make_avatar(Vector3(-1.05, 0.0, -6.85), MINA, 1.04, true), "showcase")
	_register(_make_avatar(Vector3(0.78, 0.0, -7.38), FRIEND, 1.02, false), "showcase")
	_register(_make_avatar(Vector3(2.9, 0.0, -8.25), TRUSTED_ADULT, 1.15, false), "showcase")
	_register(_make_avatar(Vector3(5.4, 0.0, -7.65), MINA, 1.04, true), "after_school")
	_register(_make_avatar(Vector3(6.5, 0.0, -7.15), FRIEND, 1.03, false), "after_school")
	_register(_make_avatar(Vector3(7.6, 0.0, -9.0), TRUSTED_ADULT, 1.14, false), "after_school")

func _make_layered_locker(origin: Vector3, color: Color) -> Node3D:
	var group := _node_group("layered 3D locker", origin)
	_child_box(group, "locker body", Vector3(0.0, 1.22, 0.0), Vector3(0.52, 2.30, 0.94), _mat(color, 0.82))
	_child_box(group, "locker inset", Vector3(-0.29, 1.32, 0.0), Vector3(0.06, 1.74, 0.70), _mat(color.lightened(0.10), 0.84))
	for i in range(4):
		_child_box(group, "locker vent", Vector3(-0.335, 1.86 - float(i) * 0.12, -0.22), Vector3(0.035, 0.028, 0.28), _mat(DEEP_SHADOW, 0.72))
		_child_box(group, "locker vent", Vector3(-0.335, 1.86 - float(i) * 0.12, 0.22), Vector3(0.035, 0.028, 0.28), _mat(DEEP_SHADOW, 0.72))
	_child_box(group, "locker handle", Vector3(-0.35, 1.12, -0.28), Vector3(0.05, 0.34, 0.055), _mat(Color("#6d5447"), 0.6))
	_child_box(group, "locker name plate", Vector3(-0.35, 0.60, 0.0), Vector3(0.045, 0.18, 0.42), _mat(Color("#fff5dd"), 0.86))
	return group

func _make_bulletin_cluster(origin: Vector3) -> Node3D:
	var group := _node_group("layered kindness bulletin board", origin)
	_child_box(group, "wood frame", Vector3(0.0, 2.05, 0.0), Vector3(0.25, 2.40, 3.25), _mat(Color("#b57a52"), 0.72))
	_child_box(group, "cork surface", Vector3(-0.16, 2.05, 0.0), Vector3(0.08, 2.12, 2.95), _mat(Color("#ffe0a5"), 0.78))
	for i in range(9):
		var y: float = 1.30 + float(i % 3) * 0.43
		var z: float = -1.04 + float(i / 3) * 0.72
		_child_box(group, "project-authored paper note", Vector3(-0.23, y, z), Vector3(0.04, 0.34, 0.42), _mat(_note_color(i), 0.92))
		_child_sphere(group, "round push pin", Vector3(-0.27, y + 0.16, z - 0.14), 0.035, _mat(Color("#c77b5d"), 0.65))
	_child_box(group, "robot club poster", Vector3(-0.26, 2.74, 0.0), Vector3(0.05, 0.56, 0.86), _mat(Color("#edf7f6"), 0.90))
	_child_box(group, "poster robot body", Vector3(-0.30, 2.70, 0.0), Vector3(0.06, 0.22, 0.30), _mat(Color("#86b9c2"), 0.82))
	_child_sphere(group, "poster robot eye", Vector3(-0.34, 2.77, -0.08), 0.028, _mat(Color("#ee9d72"), 0.7))
	_child_sphere(group, "poster robot eye", Vector3(-0.34, 2.77, 0.08), 0.028, _mat(Color("#ee9d72"), 0.7))
	return group

func _make_scene_portal(origin: Vector3, door_color: Color, accent: Color, node_name: String) -> Node3D:
	var group := _node_group(node_name, origin)
	_child_box(group, "door slab", Vector3(0.0, 1.84, 0.0), Vector3(0.50, 3.18, 1.86), _mat(door_color, 0.82))
	_child_box(group, "door side frame", Vector3(-0.08, 1.84, -1.05), Vector3(0.70, 3.42, 0.12), _mat(accent.darkened(0.18), 0.76))
	_child_box(group, "door side frame", Vector3(-0.08, 1.84, 1.05), Vector3(0.70, 3.42, 0.12), _mat(accent.darkened(0.18), 0.76))
	_child_box(group, "door header", Vector3(-0.08, 3.57, 0.0), Vector3(0.70, 0.18, 2.22), _mat(accent.darkened(0.12), 0.76))
	_child_box(group, "soft window", Vector3(-0.31, 2.72, 0.0), Vector3(0.06, 0.62, 1.12), _mat(Color("#eafffb", 0.88), 0.55, true))
	_child_sphere(group, "round handle", Vector3(-0.34, 1.63, 0.70), 0.055, _mat(Color("#6b5b51"), 0.62))
	_child_box(group, "trusted adult sign", Vector3(-0.36, 3.78, 0.0), Vector3(0.06, 0.30, 1.36), _mat(Color("#fff9eb"), 0.84))
	_child_torus(group, "safe check halo", Vector3(-0.41, 3.79, -0.38), 0.055, 0.105, _mat(accent, 0.54, true), Vector3(0.0, 90.0, 0.0))
	_child_box(group, "safe check mark", Vector3(-0.44, 3.76, 0.28), Vector3(0.04, 0.05, 0.36), _mat(accent, 0.54, true))
	return group

func _make_display_case(origin: Vector3, tint: Color) -> Node3D:
	var group := _node_group("glass display case", origin)
	_child_box(group, "display base", Vector3(0.0, 0.45, 0.0), Vector3(0.46, 0.34, 2.25), _mat(Color("#b98b6d"), 0.78))
	_child_box(group, "display glass", Vector3(-0.02, 1.18, 0.0), Vector3(0.38, 1.20, 2.08), _mat(Color(tint.r, tint.g, tint.b, 0.34), 0.25, true))
	for i in range(3):
		_child_sphere(group, "kindness token", Vector3(-0.23, 0.97 + float(i % 2) * 0.22, -0.62 + float(i) * 0.55), 0.11, _mat(_note_color(i), 0.64))
	return group

func _make_lunch_table(origin: Vector3) -> Node3D:
	var group := _node_group("rounded lunch table vignette", origin)
	_child_box(group, "table top", Vector3(0.0, 0.70, 0.0), Vector3(1.18, 0.18, 0.72), _mat(Color("#f3c98c"), 0.86))
	_child_cylinder(group, "table leg", Vector3(-0.42, 0.34, -0.22), 0.045, 0.62, _mat(Color("#9d745d"), 0.72))
	_child_cylinder(group, "table leg", Vector3(0.42, 0.34, -0.22), 0.045, 0.62, _mat(Color("#9d745d"), 0.72))
	_child_cylinder(group, "table leg", Vector3(-0.42, 0.34, 0.22), 0.045, 0.62, _mat(Color("#9d745d"), 0.72))
	_child_cylinder(group, "table leg", Vector3(0.42, 0.34, 0.22), 0.045, 0.62, _mat(Color("#9d745d"), 0.72))
	_child_box(group, "lunch tray", Vector3(0.0, 0.84, 0.0), Vector3(0.60, 0.045, 0.36), _mat(Color("#d9eff0"), 0.84))
	_child_sphere(group, "apple shape", Vector3(0.24, 0.94, -0.05), 0.075, _mat(Color("#dc7868"), 0.70))
	return group

func _make_showcase_table(origin: Vector3, index: int) -> Node3D:
	var group := _node_group("showcase robot table", origin)
	_child_box(group, "display table top", Vector3(0.0, 0.68, 0.0), Vector3(1.48, 0.22, 0.84), _mat(Color("#f6dcae"), 0.84))
	_child_box(group, "display table cloth", Vector3(0.0, 0.48, 0.0), Vector3(1.36, 0.34, 0.76), _mat(Color("#fff7e7"), 0.88))
	_make_robot_model(group, Vector3(0.0, 1.02, 0.0), _note_color(index))
	_child_box(group, "upright poster", Vector3(0.0, 1.58, -0.46), Vector3(0.88, 0.70, 0.05), _mat(Color("#edf7f6"), 0.90))
	_child_torus(group, "poster gear", Vector3(-0.18, 1.60, -0.50), 0.060, 0.125, _mat(Color("#6d8f9a"), 0.62), Vector3(90.0, 0.0, 0.0))
	return group

func _make_robot_model(parent: Node3D, origin: Vector3, accent: Color) -> void:
	_child_box(parent, "robot torso", origin + Vector3(0.0, 0.18, 0.0), Vector3(0.36, 0.36, 0.26), _mat(Color("#86b9c2"), 0.78))
	_child_box(parent, "robot head", origin + Vector3(0.0, 0.50, 0.0), Vector3(0.42, 0.25, 0.30), _mat(Color("#d8eef2"), 0.80))
	_child_sphere(parent, "robot eye", origin + Vector3(-0.11, 0.54, -0.16), 0.030, _mat(Color("#ee9d72"), 0.62, true))
	_child_sphere(parent, "robot eye", origin + Vector3(0.11, 0.54, -0.16), 0.030, _mat(Color("#ee9d72"), 0.62, true))
	_child_torus(parent, "robot chest gear", origin + Vector3(0.0, 0.19, -0.15), 0.060, 0.115, _mat(accent, 0.62), Vector3(90.0, 0.0, 0.0))
	_child_cylinder(parent, "robot arm", origin + Vector3(-0.28, 0.25, 0.0), 0.035, 0.36, _mat(Color("#6d8f9a"), 0.68), Vector3(0.0, 0.0, 90.0))
	_child_cylinder(parent, "robot arm", origin + Vector3(0.28, 0.25, 0.0), 0.035, 0.36, _mat(Color("#6d8f9a"), 0.68), Vector3(0.0, 0.0, 90.0))
	_child_cylinder(parent, "robot wheel", origin + Vector3(-0.12, -0.06, 0.0), 0.070, 0.08, _mat(Color("#4d5f68"), 0.68), Vector3(90.0, 0.0, 0.0))
	_child_cylinder(parent, "robot wheel", origin + Vector3(0.12, -0.06, 0.0), 0.070, 0.08, _mat(Color("#4d5f68"), 0.68), Vector3(90.0, 0.0, 0.0))

func _make_bench_and_bags(origin: Vector3) -> Node3D:
	var group := _node_group("after school bench and backpacks", origin)
	_child_box(group, "bench seat", Vector3(0.0, 0.58, 0.0), Vector3(2.38, 0.22, 0.58), _mat(Color("#b98b6d"), 0.78))
	_child_box(group, "bench back", Vector3(0.0, 0.98, 0.30), Vector3(2.38, 0.58, 0.18), _mat(Color("#a9795f"), 0.78))
	_child_cylinder(group, "bench leg", Vector3(-0.85, 0.30, -0.18), 0.045, 0.54, _mat(Color("#705849"), 0.72))
	_child_cylinder(group, "bench leg", Vector3(0.85, 0.30, -0.18), 0.045, 0.54, _mat(Color("#705849"), 0.72))
	_child_capsule(group, "rounded backpack", Vector3(-0.55, 0.98, -0.32), 0.18, 0.44, _mat(MINA.darkened(0.06), 0.82))
	_child_capsule(group, "rounded backpack", Vector3(0.55, 0.96, -0.32), 0.18, 0.42, _mat(FRIEND.darkened(0.06), 0.82))
	return group

func _make_plan_board(origin: Vector3) -> Node3D:
	var group := _node_group("trusted adult plan board", origin)
	_child_box(group, "plan board frame", Vector3(0.0, 2.10, 0.0), Vector3(0.25, 1.65, 2.18), _mat(TRUSTED_ADULT.darkened(0.18), 0.76))
	_child_box(group, "plan board paper", Vector3(-0.17, 2.10, 0.0), Vector3(0.08, 1.36, 1.88), _mat(PAPER, 0.86))
	for i in range(4):
		_child_box(group, "private plan line", Vector3(-0.24, 2.48 - float(i) * 0.24, -0.35 + float(i % 2) * 0.20), Vector3(0.045, 0.04, 0.78), _mat(TRUSTED_ADULT.lightened(0.10), 0.55, true))
	return group

func _make_reflection_wall(origin: Vector3) -> Node3D:
	var group := _node_group("private reflection card wall", origin)
	_child_box(group, "reflection board", Vector3(0.0, 2.25, 0.0), Vector3(5.2, 2.55, 0.12), _mat(PAPER, 0.88))
	_child_box(group, "reflection board frame", Vector3(0.0, 2.25, 0.08), Vector3(5.52, 2.86, 0.12), _mat(Color("#b57a52"), 0.72))
	for i in range(4):
		var card_x: float = -1.65 + float(i) * 1.10
		_child_box(group, "private route card", Vector3(card_x, 2.22, -0.05), Vector3(0.78, 0.96, 0.08), _mat(_note_color(i), 0.9))
		_child_torus(group, "route card replay ring", Vector3(card_x, 2.62, -0.12), 0.055, 0.120, _mat(Color("#f0c767"), 0.62, true), Vector3(90.0, 0.0, 0.0))
	return group

func _make_floor_emblem(origin: Vector3, color: Color) -> Node3D:
	var group := _node_group("chapter floor emblem", origin)
	_child_torus(group, "large soft chapter ring", Vector3.ZERO, 0.56, 0.68, _mat(Color(color.r, color.g, color.b, 0.46), 0.50, true), Vector3(90.0, 0.0, 0.0))
	_child_box(group, "chapter dash", Vector3(0.0, 0.01, 0.0), Vector3(0.92, 0.02, 0.12), _mat(Color(color.r, color.g, color.b, 0.52), 0.50, true))
	detail_nodes.append(group)
	return group

func _make_avatar(origin: Vector3, body_color: Color, scale: float, has_backpack: bool) -> Node3D:
	var avatar := _node_group("friendly non-photoreal avatar", origin)
	_child_capsule(avatar, "rounded torso", Vector3(0.0, 0.82 * scale, 0.0), 0.22 * scale, 0.86 * scale, _mat(body_color, 0.82))
	_child_sphere(avatar, "soft head", Vector3(0.0, 1.40 * scale, 0.0), 0.24 * scale, _mat(Color("#f0c19d"), 0.86))
	_child_sphere(avatar, "painted hair cap", Vector3(0.0, 1.53 * scale, -0.015), 0.235 * scale, _mat(Color("#725643"), 0.9))
	_child_sphere(avatar, "left eye", Vector3(-0.075 * scale, 1.43 * scale, -0.205 * scale), 0.018 * scale, _mat(INK, 0.68))
	_child_sphere(avatar, "right eye", Vector3(0.075 * scale, 1.43 * scale, -0.205 * scale), 0.018 * scale, _mat(INK, 0.68))
	_child_box(avatar, "gentle smile", Vector3(0.0, 1.35 * scale, -0.225 * scale), Vector3(0.10 * scale, 0.015 * scale, 0.018 * scale), _mat(Color("#9a6b62"), 0.62))
	for x in [-0.13, 0.13]:
		_child_capsule(avatar, "soft leg", Vector3(x * scale, 0.30 * scale, 0.0), 0.062 * scale, 0.58 * scale, _mat(Color("#4d5f68"), 0.88))
		_child_box(avatar, "rounded shoe", Vector3(x * scale, 0.05 * scale, -0.08 * scale), Vector3(0.18 * scale, 0.08 * scale, 0.25 * scale), _mat(Color("#344653"), 0.74))
	for x in [-0.30, 0.30]:
		var arm := _child_capsule(avatar, "relaxed arm", Vector3(x * scale, 0.86 * scale, 0.0), 0.048 * scale, 0.48 * scale, _mat(Color("#8f6b57"), 0.9))
		arm.rotation_degrees.z = 13.0 * signf(x)
		_child_sphere(avatar, "soft hand", Vector3((x + 0.04 * signf(x)) * scale, 0.60 * scale, -0.01), 0.060 * scale, _mat(Color("#f0c19d"), 0.86))
	if has_backpack:
		_child_capsule(avatar, "small backpack", Vector3(0.0, 0.86 * scale, 0.22 * scale), 0.16 * scale, 0.52 * scale, _mat(body_color.darkened(0.22), 0.84))
		_child_box(avatar, "backpack strap", Vector3(-0.12 * scale, 0.92 * scale, -0.18 * scale), Vector3(0.040 * scale, 0.42 * scale, 0.032 * scale), _mat(Color("#6f5c50"), 0.82))
		_child_box(avatar, "backpack strap", Vector3(0.12 * scale, 0.92 * scale, -0.18 * scale), Vector3(0.040 * scale, 0.42 * scale, 0.032 * scale), _mat(Color("#6f5c50"), 0.82))
	return avatar

func _node_group(node_name: String, position: Vector3) -> Node3D:
	var group := Node3D.new()
	group.name = node_name
	group.position = position
	scene_root.add_child(group)
	return group

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
	mesh.radial_segments = 20
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

func _child_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _child_mesh(parent, node_name, position, mesh, material)

func _child_sphere(parent: Node3D, node_name: String, position: Vector3, radius: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 18
	mesh.rings = 9
	return _child_mesh(parent, node_name, position, mesh, material)

func _child_capsule(parent: Node3D, node_name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	mesh.rings = 8
	return _child_mesh(parent, node_name, position, mesh, material)

func _child_cylinder(parent: Node3D, node_name: String, position: Vector3, radius: float, height: float, material: StandardMaterial3D, rotation_degrees_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	var node := _child_mesh(parent, node_name, position, mesh, material)
	node.rotation_degrees = rotation_degrees_value
	return node

func _child_torus(parent: Node3D, node_name: String, position: Vector3, inner_radius: float, outer_radius: float, material: StandardMaterial3D, rotation_degrees_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 12
	mesh.ring_segments = 24
	var node := _child_mesh(parent, node_name, position, mesh, material)
	node.rotation_degrees = rotation_degrees_value
	return node

func _child_mesh(parent: Node3D, node_name: String, position: Vector3, mesh: Mesh, material: StandardMaterial3D) -> MeshInstance3D:
	var node := _mesh_instance(mesh, material)
	node.name = node_name
	node.position = position
	parent.add_child(node)
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
		material.emission = Color(color.r, color.g, color.b, minf(color.a + 0.20, 1.0))
		material.emission_energy_multiplier = 0.55
	return material

func _count_meshes(node: Node) -> int:
	if node == null:
		return 0
	var count := 0
	if node is MeshInstance3D:
		count += 1
	for child in node.get_children():
		count += _count_meshes(child)
	return count

func _count_visible_meshes(node: Node) -> int:
	if node == null:
		return 0
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).is_visible_in_tree():
		count += 1
	for child in node.get_children():
		count += _count_visible_meshes(child)
	return count

func _note_color(index: int) -> Color:
	var palette: Array[Color] = [Color("#f9faf1"), Color("#d9eff0"), Color("#fde3d5"), Color("#e9e0f1"), Color("#dff3d6")]
	return palette[index % palette.size()]
