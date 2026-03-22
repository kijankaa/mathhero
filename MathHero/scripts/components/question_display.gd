# scripts/components/question_display.gd
# Wyświetla treść pytania i aktualnie wpisywaną odpowiedź.
# Komunikuje się przez sygnały — NIE zna logiki sesji.
extends Control

@onready var _question_label: Label = $QuestionLabel
@onready var _answer_label: Label = $AnswerLabel

var _current_answer: String = ""
var _format: String = "horizontal"


## Ustawia format wyświetlania pytania ("horizontal" lub "vertical").
func set_format(format: String) -> void:
	_format = format


## Wyświetla nowe pytanie i czyści pole odpowiedzi.
func show_question(question: Question) -> void:
	if _format == "vertical":
		_question_label.text = "  %d\n+ %d\n───" % [question.operand_a, question.operand_b]
	else:
		_question_label.text = question.display_text
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE


## Dodaje cyfrę do wpisywanej odpowiedzi.
func append_digit(digit: int) -> void:
	if _current_answer.length() >= 6:
		return
	_current_answer += str(digit)
	_answer_label.text = _current_answer


## Usuwa ostatnią cyfrę.
func remove_last_digit() -> void:
	if _current_answer.length() > 0:
		_current_answer = _current_answer.left(_current_answer.length() - 1)
	_answer_label.text = _current_answer if _current_answer != "" else "_"


## Zwraca wpisaną wartość lub null jeśli pole puste.
func get_answer() -> Variant:
	if _current_answer == "":
		return null
	return int(_current_answer)


## Pokazuje feedback po odpowiedzi.
func show_feedback(correct: bool, correct_answer: int = 0) -> void:
	if correct:
		_answer_label.modulate = Color.GREEN
	else:
		_answer_label.modulate = Color.RED
		_question_label.text += "   ✓ %d" % correct_answer


## Czyści feedback i pole odpowiedzi.
func clear() -> void:
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE
