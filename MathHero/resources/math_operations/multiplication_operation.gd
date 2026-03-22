# resources/math_operations/multiplication_operation.gd
class_name MultiplicationOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var answer: int = a * b
	var display: String = "%d × %d = ?" % [a, b]
	return Question.create(a, b, "multiplication", answer, display)
