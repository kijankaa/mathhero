# scripts/components/numeric_keyboard.gd
# Wirtualna klawiatura numeryczna on-screen.
# Komunikuje się przez lokalne sygnały — NIE zna logiki sesji.
extends Control

signal digit_pressed(digit: int)
signal backspace_pressed
signal confirm_pressed

@onready var _backspace_button: Button = $GridContainer/BackspaceButton
@onready var _confirm_button: Button = $GridContainer/ConfirmButton

var _enabled: bool = true


func _ready() -> void:
	for i in range(10):
		var btn: Button = $GridContainer.get_node_or_null("Digit%d" % i)
		if btn:
			btn.pressed.connect(_on_digit_pressed.bind(i))

	_backspace_button.pressed.connect(_on_backspace_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)


func _on_digit_pressed(digit: int) -> void:
	if _enabled:
		digit_pressed.emit(digit)


func _on_backspace_pressed() -> void:
	if _enabled:
		backspace_pressed.emit()


func _on_confirm_pressed() -> void:
	if _enabled:
		confirm_pressed.emit()


## Blokuje / odblokowuje klawiaturę (np. podczas feedbacku).
func set_enabled(value: bool) -> void:
	_enabled = value
	modulate.a = 1.0 if value else 0.5
