# scripts/ui/stats.gd
extends Control

@onready var _back_button: Button = $BackButton
@onready var _records_container: VBoxContainer = $ScrollContainer/VBox/RecordsContainer
@onready var _chart: Control = $ScrollContainer/VBox/Chart
@onready var _history_container: VBoxContainer = $ScrollContainer/VBox/HistoryContainer

var _history: Array[Dictionary] = []


func _ready() -> void:
	_back_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_MAIN_MENU))
	_build_ui()
	if OS.is_debug_build():
		print("[Stats] Gotowy")


func _build_ui() -> void:
	if not GameState.has_active_profile():
		return
	var profile: PlayerProfile = GameState.current_profile
	_history = profile.session_history
	_build_records(profile)
	_build_chart()
	_build_history()


func _build_records(profile: PlayerProfile) -> void:
	for child: Node in _records_container.get_children():
		child.queue_free()

	var op_labels: Dictionary = {
		"addition": "Dodawanie",
		"subtraction": "Odejmowanie",
		"multiplication": "Mnożenie",
		"division": "Dzielenie",
		"mixed": "Mieszane",
		"order_of_ops": "Kolejność działań",
	}

	var title: Label = Label.new()
	title.text = "🏅 Rekordy osobiste"
	title.add_theme_font_size_override("font_size", 20)
	_records_container.add_child(title)

	var has_any: bool = false
	for op: String in op_labels.keys():
		if not profile.operation_records.has(op):
			continue
		var rec: Dictionary = profile.operation_records[op]
		var row: Label = Label.new()
		row.text = "%s — Dokładność: %d%% | Wynik: %d pkt" % [
			op_labels.get(op, op),
			int(rec.get("best_accuracy", 0)),
			int(rec.get("best_score", 0)),
		]
		row.add_theme_font_size_override("font_size", 16)
		_records_container.add_child(row)
		has_any = true

	if not has_any:
		var empty: Label = Label.new()
		empty.text = "Brak rekordów — zagraj pierwszą sesję!"
		empty.add_theme_font_size_override("font_size", 16)
		_records_container.add_child(empty)


func _build_chart() -> void:
	var chart_data: Array[int] = []
	var start_idx: int = max(0, _history.size() - 20)
	for i: int in range(start_idx, _history.size()):
		chart_data.append(int(_history[i].get("accuracy", 0)))
	_chart.data = chart_data
	_chart.queue_redraw()


func _build_history() -> void:
	for child: Node in _history_container.get_children():
		child.queue_free()

	var title: Label = Label.new()
	title.text = "📋 Historia sesji (ostatnie %d)" % _history.size()
	title.add_theme_font_size_override("font_size", 20)
	_history_container.add_child(title)

	if _history.is_empty():
		var empty: Label = Label.new()
		empty.text = "Brak historii — zagraj pierwszą sesję!"
		empty.add_theme_font_size_override("font_size", 16)
		_history_container.add_child(empty)
		return

	for i: int in range(_history.size() - 1, -1, -1):
		var entry: Dictionary = _history[i]
		var row: Label = Label.new()
		row.text = "%s | %s | %d/%d (%d%%) | %d pkt | %.0fs" % [
			str(entry.get("date", "—")),
			str(entry.get("op", "—")),
			int(entry.get("correct", 0)),
			int(entry.get("total", 0)),
			int(entry.get("accuracy", 0)),
			int(entry.get("score", 0)),
			float(entry.get("duration", 0.0)),
		]
		row.add_theme_font_size_override("font_size", 14)
		_history_container.add_child(row)
