# resources/math_operations/order_of_operations_operation.gd
# Generuje wyrażenia 3-argumentowe z kolejnością działań.
# Tryby nawiasów (config.order_of_ops_parentheses): "none", "always", "mixed".
class_name OrderOfOperationsOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var c: int = _rand_in_range(config.min_value, config.max_value)

	var use_parentheses: bool = _should_use_parentheses(config.order_of_ops_parentheses)

	var answer: int
	var display: String

	if use_parentheses:
		answer = (a + b) * c
		display = "(%d + %d) × %d = ?" % [a, b, c]
	else:
		answer = a + b * c
		display = "%d + %d × %d = ?" % [a, b, c]

	return Question.create(a, b, "order_of_operations", answer, display)


func _should_use_parentheses(mode: String) -> bool:
	match mode:
		"always": return true
		"mixed":  return randi() % 2 == 0
		_:        return false
