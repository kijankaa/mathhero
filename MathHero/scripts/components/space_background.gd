# scripts/components/space_background.gd
# Reużywalne animowane tło kosmiczne. Dodaj jako pierwsze dziecko każdej sceny.
# mouse_filter = MOUSE_FILTER_IGNORE — nie blokuje kliknięć.
extends Control

const STAR_COUNT: int = 80

var _stars: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	_generate_stars()
	set_process(true)


func _generate_stars() -> void:
	_stars.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 42  # deterministyczne — te same gwiazdy zawsze
	for i: int in STAR_COUNT:
		_stars.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"size": rng.randf_range(1.0, 3.0),
			"brightness": rng.randf_range(0.5, 1.0),
			"speed": rng.randf_range(0.3, 1.2),
			"offset": rng.randf_range(0.0, TAU),
		})


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y

	# Gradient tło (dwa prostokąty imitujące gradient)
	draw_rect(Rect2(0.0, 0.0, w, h * 0.5), Color(0.02, 0.02, 0.11))
	draw_rect(Rect2(0.0, h * 0.5, w, h * 0.5), Color(0.04, 0.04, 0.18))

	# Gwiazdy z migotaniem
	for star: Dictionary in _stars:
		var alpha: float = star["brightness"] * (0.6 + 0.4 * sin(_time * star["speed"] + star["offset"]))
		var color: Color = Color(0.8, 0.9, 1.0, alpha)
		var pos: Vector2 = Vector2(star["x"] * w, star["y"] * h)
		draw_circle(pos, star["size"], color)
