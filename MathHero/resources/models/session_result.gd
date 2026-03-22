# resources/models/session_result.gd
# Niezmienny wynik zakończonej sesji.
class_name SessionResult
extends Resource

var config: SessionConfig = null
var score: int = 0
var correct_count: int = 0
var total_questions: int = 0
var streak: int = 0
var max_streak: int = 0
var duration_seconds: float = 0.0


static func from_state(state: SessionState) -> SessionResult:
	var r := SessionResult.new()
	r.config = state.config
	r.score = state.score
	r.correct_count = state.correct_count
	r.total_questions = state.get_total_asked()
	r.streak = state.streak
	r.max_streak = state.max_streak
	r.duration_seconds = Time.get_unix_time_from_system() - state.start_time
	return r


func get_accuracy() -> float:
	if total_questions == 0:
		return 0.0
	return float(correct_count) / float(total_questions)


func get_accuracy_percent() -> int:
	return int(get_accuracy() * 100)
