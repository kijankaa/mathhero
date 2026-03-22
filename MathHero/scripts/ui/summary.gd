# scripts/ui/summary.gd
extends Control

@onready var _result_label: Label = $ResultLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _accuracy_label: Label = $AccuracyLabel
@onready var _play_again_button: Button = $PlayAgainButton
@onready var _config_button: Button = $ConfigButton

var _result: SessionResult = null


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_config_button.pressed.connect(_on_config_pressed)

	# Odczytaj wynik zapisany w GameState (sygnał mógł przyjść przed załadowaniem sceny)
	if GameState.last_session_result != null:
		_result = GameState.last_session_result
		_update_ui()

	if OS.is_debug_build():
		print("[Summary] Gotowy")


func _on_session_completed(result: SessionResult) -> void:
	_result = result
	_update_ui()


func _update_ui() -> void:
	if _result == null:
		return
	_result_label.text = "%d / %d poprawnych" % [_result.correct_count, _result.total_questions]
	_score_label.text = "Punkty: %d" % _result.score
	_accuracy_label.text = "Dokładność: %d%%" % _result.get_accuracy_percent()


func _on_play_again_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_config_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_CONFIG)
