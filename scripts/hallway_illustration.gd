extends Control

const OUTLINE := Color("#5b504a")
const PAPER := Color("#fff9ea")
const POSTER := Color("#d8eef2")
const POSTER_ACCENT := Color("#ee9d72")
const ADULT_BLUE := Color("#5f9eae")
const FRIEND_GREEN := Color("#78a66f")
const MINA_PURPLE := Color("#a888c5")
const JOSS_ORANGE := Color("#d9935f")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 0.0 or h <= 0.0:
		return

	_draw_soft_frame(w, h)
	_draw_hallway(w, h)
	_draw_characters(w, h)
	_draw_poster(w, h)
	_draw_help_marker(w, h)

func _draw_soft_frame(w: float, h: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(w, h)), Color("#fce9c5"))
	for i in range(4):
		var inset: float = 6.0 + float(i) * 7.0
		draw_rect(Rect2(Vector2(inset, inset), Vector2(w - inset * 2.0, h - inset * 2.0)), Color("#ffffff", 0.08 + float(i) * 0.03), false, 3.0)

func _draw_hallway(w: float, h: float) -> void:
	var horizon: float = h * 0.50
	draw_polygon(PackedVector2Array([
		Vector2(18.0, horizon), Vector2(w - 18.0, horizon), Vector2(w - 44.0, h - 18.0), Vector2(44.0, h - 18.0)
	]), PackedColorArray([Color("#efbf86"), Color("#efbf86"), Color("#f8dfb7"), Color("#f8dfb7")]))
	draw_rect(Rect2(22.0, 20.0, w - 44.0, horizon - 20.0), Color("#ffe1b5"))
	draw_line(Vector2(32.0, horizon), Vector2(w - 32.0, horizon), Color("#cf9368"), 3.0, true)

	# Left lockers and right safe-adult doorway.
	for i in range(3):
		var rect: Rect2 = Rect2(44.0 + float(i) * 48.0, horizon - 56.0, 40.0, 76.0)
		draw_rect(rect, Color("#edb37b"))
		draw_rect(rect, Color("#bd764d"), false, 2.0)
		draw_line(Vector2(rect.position.x + 20.0, rect.position.y + 5.0), Vector2(rect.position.x + 20.0, rect.end.y - 5.0), Color("#d28c5a"), 1.0)
		draw_rect(Rect2(rect.position.x + 24.0, rect.position.y + 34.0, 7.0, 3.0), Color("#7f5c49"))

	var door: Rect2 = Rect2(w - 156.0, horizon - 72.0, 96.0, 106.0)
	draw_rect(door, Color("#a8cec4"))
	draw_rect(door, Color("#6b988e"), false, 3.0)
	draw_rect(Rect2(door.position.x + 14.0, door.position.y + 14.0, door.size.x - 28.0, 25.0), Color("#e9f7f3"))
	draw_circle(Vector2(door.end.x - 16.0, door.position.y + 62.0), 3.5, Color("#6b5b51"))

func _draw_characters(w: float, h: float) -> void:
	_draw_person(Vector2(w * 0.40, h * 0.70), MINA_PURPLE, 1.05)
	_draw_person(Vector2(w * 0.29, h * 0.73), FRIEND_GREEN, 1.0)
	_draw_person(Vector2(w * 0.58, h * 0.71), JOSS_ORANGE, 0.98)
	_draw_person(Vector2(w * 0.78, h * 0.64), ADULT_BLUE, 1.1)

func _draw_person(origin: Vector2, shirt: Color, scale: float) -> void:
	var head_r: float = 11.0 * scale
	draw_circle(origin + Vector2(0.0, -43.0 * scale), head_r, Color("#8f6b57"))
	draw_circle(origin + Vector2(0.0, -46.0 * scale), head_r * 0.88, Color("#f2c49f"))
	draw_rect(Rect2(origin.x - 16.0 * scale, origin.y - 34.0 * scale, 32.0 * scale, 33.0 * scale), shirt)
	draw_line(origin + Vector2(-15.0 * scale, -6.0 * scale), origin + Vector2(-23.0 * scale, 22.0 * scale), OUTLINE, 4.0 * scale, true)
	draw_line(origin + Vector2(15.0 * scale, -6.0 * scale), origin + Vector2(23.0 * scale, 22.0 * scale), OUTLINE, 4.0 * scale, true)
	draw_line(origin + Vector2(-10.0 * scale, -25.0 * scale), origin + Vector2(-27.0 * scale, -12.0 * scale), OUTLINE, 4.0 * scale, true)
	draw_line(origin + Vector2(10.0 * scale, -25.0 * scale), origin + Vector2(27.0 * scale, -12.0 * scale), OUTLINE, 4.0 * scale, true)
	draw_rect(Rect2(origin.x - 17.0 * scale, origin.y - 34.0 * scale, 34.0 * scale, 34.0 * scale), OUTLINE, false, 2.0 * scale)

func _draw_poster(w: float, h: float) -> void:
	var poster: Rect2 = Rect2(w * 0.43, h * 0.49, w * 0.14, h * 0.22)
	draw_rect(poster, PAPER)
	draw_rect(poster, Color("#73665e"), false, 2.5)
	var robot_center: Vector2 = poster.position + poster.size * 0.5
	draw_rect(Rect2(robot_center.x - 18.0, robot_center.y - 5.0, 36.0, 28.0), POSTER)
	draw_rect(Rect2(robot_center.x - 18.0, robot_center.y - 5.0, 36.0, 28.0), Color("#6d8f9a"), false, 2.0)
	draw_circle(robot_center + Vector2(-8.0, 5.0), 2.5, POSTER_ACCENT)
	draw_circle(robot_center + Vector2(8.0, 5.0), 2.5, POSTER_ACCENT)
	draw_line(robot_center + Vector2(-10.0, 17.0), robot_center + Vector2(10.0, 17.0), Color("#6d8f9a"), 2.0, true)
	draw_line(robot_center + Vector2(0.0, -5.0), robot_center + Vector2(0.0, -18.0), Color("#6d8f9a"), 2.0, true)
	draw_circle(robot_center + Vector2(0.0, -20.0), 3.0, POSTER_ACCENT)

func _draw_help_marker(w: float, h: float) -> void:
	var center: Vector2 = Vector2(w * 0.79, h * 0.28)
	draw_circle(center, 24.0, Color("#fffdf2"))
	draw_circle(center, 24.0, ADULT_BLUE, false, 3.0)
	draw_line(center + Vector2(-9.0, 1.0), center + Vector2(-2.0, 9.0), ADULT_BLUE, 4.0, true)
	draw_line(center + Vector2(-2.0, 9.0), center + Vector2(12.0, -10.0), ADULT_BLUE, 4.0, true)
