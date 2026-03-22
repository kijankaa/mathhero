# resources/models/session_state.gd
# Stan aktywnej sesji. Przechowywany w GameState.current_session_state.
class_name SessionState
extends Resource

var config: SessionConfig = null
var questions: Array[Question] = []
var current_index: int = 0
var score: int = 0
var correct_count: int = 0
var streak: int = 0
var max_streak: int = 0
var start_time: float = 0.0
var retry_queue: Array[Question] = []
var retry_counts: Dictionary = {}


static func create(cfg: SessionConfig, qs: Array[Question]) -> SessionState:
	var s := SessionState.new()
	s.config = cfg
	s.questions = qs
	s.start_time = Time.get_unix_time_from_system()
	return s


## Zwraca kolejne pytanie (z uwzględnieniem kolejki powtórek).
func get_next_question() -> Question:
	if not retry_queue.is_empty() and current_index % 3 == 0:
		return retry_queue.pop_front()
	if current_index < questions.size():
		var q: Question = questions[current_index]
		current_index += 1
		return q
	if not retry_queue.is_empty():
		return retry_queue.pop_front()
	return null


## Rejestruje poprawną odpowiedź.
func on_correct_answer(response_time: float) -> void:
	streak += 1
	max_streak = max(max_streak, streak)
	correct_count += 1
	score += config.calculate_score(true, response_time,
									config.time_limit_seconds, streak)


## Rejestruje błędną odpowiedź.
func on_incorrect_answer(question: Question) -> void:
	streak = 0
	score += config.calculate_score(false, 0.0, 0.0, 0)

	var max_retries: int = config.retry_count
	if max_retries == 0:
		return
	var done: int = retry_counts.get(question.id, 0)
	if max_retries == -1 or done < max_retries:
		retry_queue.append(question)
		retry_counts[question.id] = done + 1


## Czy sesja jest zakończona.
func is_finished() -> bool:
	return current_index >= questions.size() and retry_queue.is_empty()


## Łączna liczba zadanych pytań.
func get_total_asked() -> int:
	return current_index


## Procent poprawnych odpowiedzi.
func get_accuracy() -> float:
	if current_index == 0:
		return 0.0
	return float(correct_count) / float(current_index)
