# scripts/gameplay/session_controller.gd
# Główna logika sesji matematycznej.
extends Control

@onready var _question_display: Control = $QuestionDisplay
@onready var _keyboard: Control = $NumericKeyboard
@onready var _multiple_choice: Control = $MultipleChoice
@onready var _progress_label: Label = $ProgressLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _feedback_label: Label = $FeedbackLabel

var _state: SessionState = null
var _current_question: Question = null
var _question_start_time: float = 0.0
var _waiting_for_next: bool = false


func _ready() -> void:
	_keyboard.digit_pressed.connect(_on_digit_pressed)
	_keyboard.backspace_pressed.connect(_on_backspace_pressed)
	_keyboard.confirm_pressed.connect(_on_confirm_pressed)
	_multiple_choice.answer_selected.connect(_on_choice_selected)

	_start_session()

	if OS.is_debug_build():
		print("[SessionController] Sesja rozpoczęta")


func _start_session() -> void:
	var config: SessionConfig = GameState.current_session_config
	if config == null:
		config = SessionConfig.create_default()

	var operation: MathOperation = AdditionOperation.new()
	var questions: Array[Question] = []
	for i in config.question_count:
		questions.append(operation.generate_question(config))

	_state = SessionState.create(config, questions)
	GameState.current_session_state = _state

	_question_display.set_format(config.question_format)

	if config.answer_mode == "multiple_choice":
		_keyboard.visible = false
		_multiple_choice.visible = true
	else:
		_keyboard.visible = true
		_multiple_choice.visible = false

	_show_next_question()


func _show_next_question() -> void:
	_current_question = _state.get_next_question()

	if _current_question == null or _state.is_finished():
		_end_session()
		return

	_question_display.show_question(_current_question)
	_feedback_label.text = ""
	_waiting_for_next = false
	_question_start_time = Time.get_unix_time_from_system()

	if _state.config.answer_mode == "multiple_choice":
		_multiple_choice.show_choices(_current_question.correct_answer, _state.config.max_value)
		_multiple_choice.set_enabled(true)
	else:
		_keyboard.set_enabled(true)

	_update_ui()


func _on_digit_pressed(digit: int) -> void:
	if _waiting_for_next:
		return
	_question_display.append_digit(digit)


func _on_backspace_pressed() -> void:
	if _waiting_for_next:
		return
	_question_display.remove_last_digit()


func _on_confirm_pressed() -> void:
	if _waiting_for_next:
		return
	var answer: Variant = _question_display.get_answer()
	if answer == null:
		return
	_process_answer(int(answer))


func _on_choice_selected(answer: int) -> void:
	if _waiting_for_next:
		return
	_process_answer(answer)


func _process_answer(answer: int) -> void:
	_keyboard.set_enabled(false)
	_multiple_choice.set_enabled(false)
	_waiting_for_next = true

	var response_time: float = Time.get_unix_time_from_system() - _question_start_time
	var correct: bool = answer == _current_question.correct_answer

	if correct:
		_state.on_correct_answer(response_time)
		_question_display.show_feedback(true)
		_feedback_label.text = "Brawo!"
		_feedback_label.modulate = Color.GREEN
	else:
		_state.on_incorrect_answer(_current_question)
		_question_display.show_feedback(false, _current_question.correct_answer)
		_feedback_label.text = "Spróbuj następnym razem"
		_feedback_label.modulate = Color.RED

	if _state.config.answer_mode == "multiple_choice":
		_multiple_choice.show_result(answer)

	_update_ui()

	await get_tree().create_timer(1.5).timeout
	_show_next_question()


func _update_ui() -> void:
	_progress_label.text = "%d / %d" % [_state.get_total_asked(), _state.config.question_count]
	_score_label.text = "Punkty: %d" % _state.score


func _end_session() -> void:
	var result: SessionResult = SessionResult.from_state(_state)
	GameState.current_session_state = null
	GameState.last_session_result = result
	EventBus.session_completed.emit(result)

	if OS.is_debug_build():
		print("[SessionController] Sesja zakończona. Wynik: %d%%" % result.get_accuracy_percent())

	SceneManager.go_to(Constants.SCENE_SUMMARY)
