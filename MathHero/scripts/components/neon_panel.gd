# scripts/components/neon_panel.gd
# Panel z uciętym rogiem i neonowym obramowaniem — styl cyberpunk.
extends Control

@export var neon_color: Color = Color(0.88, 0.0, 0.47, 1.0)   # magenta
@export var fill_color: Color = Color(0.04, 0.02, 0.10, 0.90)
@export var cut_size: float = 18.0
## Który róg jest ucięty: 0=górny-lewy, 1=górny-prawy, 2=dolny-prawy, 3=dolny-lewy
@export_enum("top_left", "top_right", "bottom_right", "bottom_left") var cut_corner: int = 1


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var c: float = cut_size

	var pts: PackedVector2Array = _build_polygon(w, h, c)

	# Wypełnienie
	draw_colored_polygon(pts, fill_color)

	# Poświata zewnętrzna (3 warstwy)
	var loop: PackedVector2Array = PackedVector2Array(pts)
	loop.append(loop[0])
	draw_polyline(loop, Color(neon_color.r, neon_color.g, neon_color.b, 0.12), 9.0, true)
	draw_polyline(loop, Color(neon_color.r, neon_color.g, neon_color.b, 0.25), 4.5, true)
	draw_polyline(loop, neon_color, 1.5, true)

	# Mały znacznik w uciętym rogu
	_draw_corner_tick(w, h, c)


func _build_polygon(w: float, h: float, c: float) -> PackedVector2Array:
	match cut_corner:
		0:  # top_left
			return PackedVector2Array([
				Vector2(c, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h), Vector2(0, c)
			])
		1:  # top_right
			return PackedVector2Array([
				Vector2(0, 0), Vector2(w - c, 0), Vector2(w, c),
				Vector2(w, h), Vector2(0, h)
			])
		2:  # bottom_right
			return PackedVector2Array([
				Vector2(0, 0), Vector2(w, 0), Vector2(w, h - c),
				Vector2(w - c, h), Vector2(0, h)
			])
		_:  # bottom_left
			return PackedVector2Array([
				Vector2(0, 0), Vector2(w, 0), Vector2(w, h),
				Vector2(c, h), Vector2(0, h - c)
			])


func _draw_corner_tick(w: float, h: float, c: float) -> void:
	var tick_color: Color = Color(neon_color.r, neon_color.g, neon_color.b, 0.6)
	var tick_len: float = c * 0.55
	match cut_corner:
		0:
			draw_line(Vector2(c, 0), Vector2(c + tick_len, 0), tick_color, 1.5)
			draw_line(Vector2(0, c), Vector2(0, c + tick_len), tick_color, 1.5)
		1:
			draw_line(Vector2(w - c, 0), Vector2(w - c - tick_len, 0), tick_color, 1.5)
			draw_line(Vector2(w, c), Vector2(w, c + tick_len), tick_color, 1.5)
		2:
			draw_line(Vector2(w, h - c), Vector2(w, h - c - tick_len), tick_color, 1.5)
			draw_line(Vector2(w - c, h), Vector2(w - c - tick_len, h), tick_color, 1.5)
		3:
			draw_line(Vector2(c, h), Vector2(c + tick_len, h), tick_color, 1.5)
			draw_line(Vector2(0, h - c), Vector2(0, h - c - tick_len), tick_color, 1.5)
