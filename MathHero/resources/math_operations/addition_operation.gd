# resources/math_operations/addition_operation.gd
class_name AdditionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var answer: int = a + b
	var display: String = "%d + %d = ?" % [a, b]
	return Question.create(a, b, "addition", answer, display)
