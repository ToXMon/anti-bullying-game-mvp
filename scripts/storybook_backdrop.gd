extends Control

const CREAM := Color("#fff6df")
const FLOOR := Color("#edd0a8")
const FLOOR_SHADOW := Color("#d8b789")
const LOCKER := Color("#f0b986")
const LOCKER_DARK := Color("#d59a67")

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

	# Warm paper base.
	draw_rect(Rect2(Vector2.ZERO, size), CREAM)

	# Soft hallway depth bands.
	var wall_top: float = h * 0.12
	var horizon: float = h * 0.48
	draw_rect(Rect2(0.0, 0.0, w, horizon), Color("#ffe8c7"))
	draw_rect(Rect2(0.0, wall_top, w, horizon - wall_top), Color("#f6d7ad"))
	draw_polygon(PackedVector2Array([
		Vector2(0.0, horizon), Vector2(w, horizon), Vector2(w, h), Vector2(0.0, h)
	]), PackedColorArray([FLOOR, FLOOR, Color("#f7e2be"), Color("#f7e2be")]))

	# Receding floor guide lines for depth without visual clutter.
	var vanishing: Vector2 = Vector2(w * 0.52, horizon)
	_draw_floor_guide(vanishing, w * 0.08, h)
	_draw_floor_guide(vanishing, w * 0.25, h)
	_draw_floor_guide(vanishing, w * 0.75, h)
	_draw_floor_guide(vanishing, w * 0.92, h)
	for i in range(4):
		var y: float = horizon + float(i + 1) * (h - horizon) / 5.0
		draw_line(Vector2(w * 0.08, y), Vector2(w * 0.92, y), Color("#e8c596", 0.46), 1.5, true)

	# Left lockers.
	var locker_w: float = maxf(72.0, w * 0.09)
	for i in range(4):
		var lx: float = 24.0 + float(i) * (locker_w + 8.0)
		var rect: Rect2 = Rect2(lx, horizon - h * 0.24, locker_w, h * 0.34)
		draw_rect(rect, LOCKER)
		draw_rect(rect, LOCKER_DARK, false, 2.0)
		draw_line(Vector2(rect.position.x + locker_w * 0.5, rect.position.y + 8.0), Vector2(rect.position.x + locker_w * 0.5, rect.end.y - 8.0), Color("#d3925f"), 1.0, true)
		draw_rect(Rect2(rect.position.x + locker_w * 0.62, rect.position.y + rect.size.y * 0.42, 9.0, 3.0), Color("#915f45"))

	# Right classroom door and safe-adult office sign.
	var door_rect: Rect2 = Rect2(w - maxf(190.0, w * 0.22), horizon - h * 0.29, maxf(130.0, w * 0.14), h * 0.42)
	draw_rect(door_rect, Color("#a6c9be"))
	draw_rect(door_rect, Color("#6f9c91"), false, 3.0)
	draw_rect(Rect2(door_rect.position.x + 18.0, door_rect.position.y + 18.0, door_rect.size.x - 36.0, door_rect.size.y * 0.28), Color("#dff1ec"))
	draw_circle(Vector2(door_rect.end.x - 20.0, door_rect.position.y + door_rect.size.y * 0.56), 4.0, Color("#6c584c"))
	var sign_rect: Rect2 = Rect2(door_rect.position.x - 18.0, door_rect.position.y - 42.0, door_rect.size.x + 36.0, 30.0)
	draw_rect(sign_rect, Color("#fff9eb"))
	draw_rect(sign_rect, Color("#78a69b"), false, 2.0)

	# Bulletin board and friendly poster shapes.
	var board: Rect2 = Rect2(w * 0.38, horizon - h * 0.25, w * 0.22, h * 0.24)
	draw_rect(board.grow(7.0), Color("#c99468"))
	draw_rect(board, Color("#ffe5a8"))
	for i in range(3):
		var note: Rect2 = Rect2(board.position.x + 16.0 + float(i) * board.size.x * 0.28, board.position.y + 18.0 + float(i % 2) * 22.0, board.size.x * 0.2, board.size.y * 0.42)
		draw_rect(note, _note_color(i))
		draw_circle(note.position + Vector2(note.size.x * 0.5, 6.0), 3.0, Color("#c77b5d"))

	# Gentle light patches.
	for i in range(5):
		var center: Vector2 = Vector2(w * (0.18 + float(i) * 0.17), h * (0.18 + float(i % 2) * 0.08))
		draw_circle(center, 54.0 + float(i) * 8.0, Color("#ffffff", 0.12))

	# Rounded vignette edge for storybook page feel.
	draw_rect(Rect2(Vector2.ZERO, size), Color("#c58c61", 0.08), false, 12.0)

func _draw_floor_guide(vanishing: Vector2, x: float, h: float) -> void:
	draw_line(Vector2(x, h), vanishing, FLOOR_SHADOW, 2.0, true)

func _note_color(index: int) -> Color:
	if index == 0:
		return Color("#f9faf1")
	if index == 1:
		return Color("#d9eff0")
	return Color("#fde3d5")
