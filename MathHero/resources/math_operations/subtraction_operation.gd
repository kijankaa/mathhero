# resources/math_operations/subtraction_operation.gd
class_name SubtractionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, a)
	var answer: int = a - b
	var display: String = "%d - %d = ?" % [a, b]
	return Question.create(a, b, "subtraction", answer, display)
