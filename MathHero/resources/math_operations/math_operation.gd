# resources/math_operations/math_operation.gd
# Klasa bazowa dla wszystkich typów działań matematycznych.
# Każdy nowy typ = nowa klasa dziedzicząca po tej.
# NIE modyfikuj session_controller.gd przy dodawaniu nowych typów — tylko dodaj nowy plik tutaj.
class_name MathOperation
extends Resource


## Generuje jedno pytanie na podstawie konfiguracji sesji.
## OVERRIDE w klasach pochodnych.
func generate_question(config: SessionConfig) -> Question:
	push_error("[MathOperation] generate_question() nie jest zaimplementowane!")
	return Question.new()


## Pomocnik — losowa liczba z zakresu [min_val, max_val].
func _rand_in_range(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)
