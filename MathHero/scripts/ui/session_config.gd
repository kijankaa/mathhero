# scripts/ui/session_config.gd
extends Control

const ProfileSelectScript = preload("res://scripts/ui/profile_select.gd")

const SYSTEM_PRESETS: Array[Dictionary] = [
	{"name": "Łatwe",       "config": {"operation_type": "addition", "question_format": "horizontal", "question_count": 10, "min_value": 1,  "max_value": 20,  "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard",          "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true,  "scoring_time_bonus": false, "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10}},
	{"name": "Standardowe", "config": {"operation_type": "addition", "question_format": "horizontal", "question_count": 10, "min_value": 1,  "max_value": 100, "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard",          "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true,  "scoring_time_bonus": false, "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10}},
	{"name": "Szybkie",     "config": {"operation_type": "addition", "question_format": "horizontal", "question_count": 10, "min_value": 1,  "max_value": 50,  "time_limit_enabled": true,  "time_limit_seconds": 15.0, "answer_mode": "keyboard",          "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true,  "scoring_time_bonus": true,  "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10}},
	{"name": "Wyzwanie",    "config": {"operation_type": "addition", "question_format": "horizontal", "question_count": 20, "min_value": 1,  "max_value": 100, "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard",          "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true,  "scoring_time_bonus": false, "scoring_streak_multiplier": true,  "scoring_error_penalty": false, "base_points_value": 10}},
	{"name": "Na czas",     "config": {"operation_type": "addition", "question_format": "horizontal", "question_count": 15, "min_value": 1,  "max_value": 100, "time_limit_enabled": true,  "time_limit_seconds": 10.0, "answer_mode": "keyboard",          "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true,  "scoring_time_bonus": true,  "scoring_streak_multiplier": true,  "scoring_error_penalty": false, "base_points_value": 10}},
]

@onready var _profile_label: Label = $ProfileLabel
@onready var _presets_container: HBoxContainer = $PresetsContainer
@onready var _question_count_input: SpinBox = $ConfigPanel/QuestionCountRow/QuestionCountInput
@onready var _min_value_input: SpinBox = $ConfigPanel/RangeRow/MinValueInput
@onready var _max_value_input: SpinBox = $ConfigPanel/RangeRow/MaxValueInput
@onready var _time_limit_toggle: CheckButton = $ConfigPanel/TimeLimitRow/TimeLimitToggle
@onready var _time_limit_input: SpinBox = $ConfigPanel/TimeLimitRow/TimeLimitInput
@onready var _answer_mode_button: OptionButton = $ConfigPanel/AnswerModeRow/AnswerModeButton
@onready var _on_error_button: OptionButton = $ConfigPanel/OnErrorRow/OnErrorButton
@onready var _format_button: OptionButton = $ConfigPanel/FormatRow/FormatButton
@onready var _scoring_base: CheckBox = $ConfigPanel/ScoringRow/ScoringBase
@onready var _scoring_time: CheckBox = $ConfigPanel/ScoringRow/ScoringTime
@onready var _scoring_streak: CheckBox = $ConfigPanel/ScoringRow/ScoringStreak
@onready var _play_button: Button = $PlayButton
@onready var _save_preset_button: Button = $SavePresetButton
@onready var _error_label: Label = $ErrorLabel


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_save_preset_button.pressed.connect(_on_save_preset_pressed)
	_time_limit_toggle.toggled.connect(_on_time_limit_toggled)

	_answer_mode_button.add_item("Klawiatura")
	_answer_mode_button.add_item("4 odpowiedzi")

	_on_error_button.add_item("Pokaż odpowiedź")
	_on_error_button.add_item("Druga szansa")

	_format_button.add_item("Poziomy")
	_format_button.add_item("Kolumnowy")

	_build_system_presets()
	_load_profile_config()

	if OS.is_debug_build():
		print("[SessionConfig] Gotowy")


func _load_profile_config() -> void:
	if GameState.current_profile == null:
		_profile_label.text = ""
		_apply_config_to_ui(SessionConfig.create_default())
		return

	var p := GameState.current_profile
	var avatar: String = Constants.AVATARS[p.avatar_id] if p.avatar_id < Constants.AVATARS.size() else "🚀"
	_profile_label.text = avatar + "  " + p.name

	var config: SessionConfig
	if p.last_config.is_empty():
		config = SessionConfig.create_default()
	else:
		config = SessionConfig.from_dict(p.last_config)
	_apply_config_to_ui(config)

	# Presety własne profilu
	for preset in p.custom_presets:
		_add_preset_button(preset.get("name", "?"), preset.get("config", {}))


func _build_system_presets() -> void:
	for preset in SYSTEM_PRESETS:
		_add_preset_button(preset["name"], preset["config"])


func _add_preset_button(preset_name: String, config_dict: Dictionary) -> void:
	var btn := Button.new()
	btn.text = preset_name
	btn.pressed.connect(_on_preset_selected.bind(config_dict))
	_presets_container.add_child(btn)


func _on_preset_selected(config_dict: Dictionary) -> void:
	_apply_config_to_ui(SessionConfig.from_dict(config_dict))


func _apply_config_to_ui(config: SessionConfig) -> void:
	_question_count_input.value = config.question_count
	_min_value_input.value = config.min_value
	_max_value_input.value = config.max_value
	_time_limit_toggle.button_pressed = config.time_limit_enabled
	_time_limit_input.value = config.time_limit_seconds
	_time_limit_input.editable = config.time_limit_enabled
	_answer_mode_button.selected = 0 if config.answer_mode == "keyboard" else 1
	_on_error_button.selected = 0 if config.on_error_mode == "show_answer" else 1
	_format_button.selected = 0 if config.question_format == "horizontal" else 1
	_scoring_base.button_pressed = config.scoring_base_points
	_scoring_time.button_pressed = config.scoring_time_bonus
	_scoring_streak.button_pressed = config.scoring_streak_multiplier


func _read_config_from_ui() -> SessionConfig:
	var c := SessionConfig.new()
	c.operation_type = "addition"
	c.question_count = int(_question_count_input.value)
	c.min_value = int(_min_value_input.value)
	c.max_value = int(_max_value_input.value)
	c.time_limit_enabled = _time_limit_toggle.button_pressed
	c.time_limit_seconds = _time_limit_input.value
	c.answer_mode = "keyboard" if _answer_mode_button.selected == 0 else "multiple_choice"
	c.on_error_mode = "show_answer" if _on_error_button.selected == 0 else "second_chance"
	c.question_format = "horizontal" if _format_button.selected == 0 else "vertical"
	c.scoring_base_points = _scoring_base.button_pressed
	c.scoring_time_bonus = _scoring_time.button_pressed
	c.scoring_streak_multiplier = _scoring_streak.button_pressed
	return c


func _validate_config(c: SessionConfig) -> String:
	if c.min_value >= c.max_value:
		return "Min musi być mniejsze niż Max"
	if c.min_value < Constants.CONFIG_MIN_VALUE_MIN:
		return "Min musi być ≥ %d" % Constants.CONFIG_MIN_VALUE_MIN
	if c.max_value > Constants.CONFIG_MAX_VALUE_MAX:
		return "Max może być ≤ %d" % Constants.CONFIG_MAX_VALUE_MAX
	if c.question_count < Constants.CONFIG_QUESTION_COUNT_MIN or c.question_count > Constants.CONFIG_QUESTION_COUNT_MAX:
		return "Liczba pytań: %d–%d" % [Constants.CONFIG_QUESTION_COUNT_MIN, Constants.CONFIG_QUESTION_COUNT_MAX]
	if c.time_limit_enabled:
		if c.time_limit_seconds < Constants.CONFIG_TIME_LIMIT_MIN or c.time_limit_seconds > Constants.CONFIG_TIME_LIMIT_MAX:
			return "Czas: %d–%d sekund" % [int(Constants.CONFIG_TIME_LIMIT_MIN), int(Constants.CONFIG_TIME_LIMIT_MAX)]
	return ""


func _on_time_limit_toggled(enabled: bool) -> void:
	_time_limit_input.editable = enabled


func _on_play_pressed() -> void:
	var config := _read_config_from_ui()
	var error := _validate_config(config)
	if error != "":
		_error_label.text = error
		return
	_error_label.text = ""

	GameState.current_session_config = config

	if GameState.current_profile != null:
		GameState.current_profile.last_config = config.to_dict()
		_save_current_profile()

	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_save_preset_pressed() -> void:
	if GameState.current_profile == null:
		_error_label.text = "Wybierz profil, aby zapisać preset"
		return

	var config := _read_config_from_ui()
	var error := _validate_config(config)
	if error != "":
		_error_label.text = error
		return
	_error_label.text = ""

	var preset_name: String = "Preset %d" % (GameState.current_profile.custom_presets.size() + 1)
	var preset_entry := {"name": preset_name, "config": config.to_dict()}
	GameState.current_profile.custom_presets.append(preset_entry)
	_save_current_profile()
	_add_preset_button(preset_name, config.to_dict())

	if OS.is_debug_build():
		print("[SessionConfig] Zapisano preset: ", preset_name)


func _save_current_profile() -> void:
	var profiles := ProfileSelectScript.load_profiles()
	for i in profiles.size():
		if profiles[i].id == GameState.current_profile.id:
			profiles[i] = GameState.current_profile
			ProfileSelectScript.save_profiles(profiles)
			return
