# scripts/components/accuracy_chart.gd
# Prosty wykres liniowy dokładności sesji. Dane: Array[int] wartości 0-100.
extends Control

var data: Array[int] = []


func _draw() -> void:
	if data.size() < 2:
		# Brak danych — pokaż komunikat
		draw_rect(Rect2(0.0, 0.0, size.x, size.y), Color(0.05, 0.05, 0.15))
		return

	var w: float = size.x
	var h: float = size.y
	var padding: float = 20.0
	var inner_w: float = w - padding * 2.0
	var inner_h: float = h - padding * 2.0

	# Tło
	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.05, 0.05, 0.15))

	# Linie pomocnicze: 0%, 50%, 100%
	for pct: int in [0, 50, 100]:
		var y: float = padding + inner_h * (1.0 - float(pct) / 100.0)
		draw_line(Vector2(padding, y), Vector2(w - padding, y), Color(0.25, 0.25, 0.35), 1.0)

	# Punkty wykresu
	var count: int = data.size()
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in count:
		var x: float = padding + float(i) / float(count - 1) * inner_w
		var y: float = padding + inner_h * (1.0 - float(data[i]) / 100.0)
		points.append(Vector2(x, y))

	# Linia
	draw_polyline(points, Color(0.2, 0.8, 1.0), 2.0)

	# Punkty
	for pt: Vector2 in points:
		draw_circle(pt, 4.0, Color(0.2, 0.8, 1.0))
