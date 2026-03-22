# scripts/components/multiple_choice.gd
# Wyświetla 4 przyciski odpowiedzi (tryb multiple choice).
# Komunikuje się przez sygnał — NIE zna logiki sesji.
extends Control

signal answer_selected(answer: int)

@onready var _buttons: Array[Button] = [
	$GridContainer/Choice0,
	$GridContainer/Choice1,
	$GridContainer/Choice2,
	$GridContainer/Choice3,
]

var _enabled: bool = true
var _correct_answer: int = 0


func _ready() -> void:
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_choice_pressed.bind(i))


## Wyświetla opcje: poprawna + 3 dystraktory, w losowej kolejności.
func show_choices(correct: int, max_val: int) -> void:
	_correct_answer = correct
	var choices := _generate_choices(correct, max_val)
	for i in _buttons.size():
		_buttons[i].text = str(choices[i])
		_buttons[i].set_meta("value", choices[i])
		_buttons[i].modulate = Color.WHITE


## Generuje 4 unikalne opcje (1 poprawna + 3 dystraktory).
func _generate_choices(correct: int, max_val: int) -> Array[int]:
	var choices: Array[int] = [correct]
	var offsets: Array[int] = [-10, -5, -2, -1, 1, 2, 5, 10]
	offsets.shuffle()

	for offset in offsets:
		if choices.size() >= 4:
			break
		var candidate: int = correct + offset
		if candidate > 0 and candidate <= max_val * 2 and candidate not in choices:
			choices.append(candidate)

	var filler: int = 1
	while choices.size() < 4:
		if filler not in choices:
			choices.append(filler)
		filler += 1

	choices.shuffle()
	return choices


func _on_choice_pressed(index: int) -> void:
	if not _enabled:
		return
	var value: int = _buttons[index].get_meta("value")
	answer_selected.emit(value)


## Zaznacza wynik po odpowiedzi: zielony = poprawna, czerwony = błędna.
func show_result(answer: int) -> void:
	for btn in _buttons:
		var val: int = btn.get_meta("value")
		if val == _correct_answer:
			btn.modulate = Color.GREEN
		elif val == answer and val != _correct_answer:
			btn.modulate = Color.RED


func set_enabled(value: bool) -> void:
	_enabled = value
	modulate.a = 1.0 if value else 0.5
