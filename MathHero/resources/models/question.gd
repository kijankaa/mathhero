# resources/models/question.gd
class_name Question
extends Resource

var id: String = ""
var operand_a: int = 0
var operand_b: int = 0
var operation: String = ""
var correct_answer: int = 0
var display_text: String = ""  # np. "12 + 7 = ?"


static func create(a: int, b: int, op: String, answer: int, display: String) -> Question:
	var q := Question.new()
	q.id = str(randi())
	q.operand_a = a
	q.operand_b = b
	q.operation = op
	q.correct_answer = answer
	q.display_text = display
	return q
