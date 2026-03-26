# scripts/components/space_background.gd
# Animowane tło kosmiczne z nebulą i migotającymi gwiazdami.
extends Control

const STAR_COUNT: int = 100

var _stars: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	_generate_stars()
	set_process(true)


func _generate_stars() -> void:
	_stars.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i: int in STAR_COUNT:
		# Część gwiazd ma kolor — cyan lub magenta
		var color_roll: float = rng.randf()
		var star_color: int = 0  # 0=biała, 1=cyan, 2=magenta
		if color_roll > 0.88:
			star_color = 1
		elif color_roll > 0.80:
			star_color = 2
		_stars.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"size": rng.randf_range(0.8, 2.8),
			"brightness": rng.randf_range(0.4, 1.0),
			"speed": rng.randf_range(0.2, 1.0),
			"offset": rng.randf_range(0.0, TAU),
			"color": star_color,
		})


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y

	# Głęboki gradient — prawie czarny z fioletowym odcieniem
	draw_rect(Rect2(0.0, 0.0, w, h * 0.4), Color(0.01, 0.01, 0.07))
	draw_rect(Rect2(0.0, h * 0.4, w, h * 0.6), Color(0.03, 0.01, 0.10))

	# Nebula magenta (prawy górny)
	draw_circle(Vector2(w * 0.80, h * 0.18), 420.0, Color(0.55, 0.00, 0.45, 0.028))
	draw_circle(Vector2(w * 0.80, h * 0.18), 280.0, Color(0.70, 0.00, 0.50, 0.032))
	draw_circle(Vector2(w * 0.80, h * 0.18), 150.0, Color(0.85, 0.00, 0.55, 0.030))

	# Nebula cyan (lewy dolny)
	draw_circle(Vector2(w * 0.12, h * 0.80), 380.0, Color(0.00, 0.40, 0.80, 0.022))
	draw_circle(Vector2(w * 0.12, h * 0.80), 220.0, Color(0.00, 0.55, 0.90, 0.026))
	draw_circle(Vector2(w * 0.12, h * 0.80), 110.0, Color(0.00, 0.70, 1.00, 0.022))

	# Gwiazdy z migotaniem i kolorami
	for star: Dictionary in _stars:
		var alpha: float = star["brightness"] * (0.55 + 0.45 * sin(_time * star["speed"] + star["offset"]))
		var color: Color
		match star["color"]:
			1: color = Color(0.3, 0.95, 1.0, alpha)   # cyan
			2: color = Color(1.0, 0.3, 0.7, alpha)    # magenta
			_: color = Color(0.85, 0.90, 1.0, alpha)  # biała/lekko niebieska
		var pos: Vector2 = Vector2(star["x"] * w, star["y"] * h)
		draw_circle(pos, star["size"], color)
