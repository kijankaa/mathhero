# resources/math_operations/division_operation.gd
# Generuje dzielenie z gwarancją wyniku całkowitego.
# Strategia: losuj wynik (c) i dzielnik (b), oblicz dzielną a = b * c.
class_name DivisionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var c: int = _rand_in_range(config.min_value, config.max_value)
	var a: int = b * c
	var answer: int = c
	var display: String = "%d ÷ %d = ?" % [a, b]
	return Question.create(a, b, "division", answer, display)
