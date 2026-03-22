# resources/models/session_config.gd
# Konfiguracja sesji. W Epic 2 — hardcoded defaults.
# W Epic 3 wszystkie pola będą edytowalne przez użytkownika.
class_name SessionConfig
extends Resource

# Podstawowe
var operation_type: String = "addition"
var question_count: int = 10
var min_value: int = 1
var max_value: int = 100

# Timer (wyłączony w Epic 2)
var time_limit_enabled: bool = false
var time_limit_seconds: float = 30.0

# Tryb odpowiedzi
var answer_mode: String = "keyboard"  # "keyboard" lub "multiple_choice"

# Zachowanie przy błędzie
var on_error_mode: String = "show_answer"  # "show_answer" lub "second_chance"

# Powtórki błędów (0 = brak, -1 = do poprawnej)
var retry_count: int = 0

# Punktacja — w Epic 2 tylko bazowe punkty
var scoring_base_points: bool = true
var scoring_time_bonus: bool = false
var scoring_streak_multiplier: bool = false
var scoring_error_penalty: bool = false
var base_points_value: int = 10
var time_bonus_max: int = 10
var streak_multiplier_max: float = 3.0
var error_penalty_value: int = 5


## Oblicza punkty za odpowiedź. Jedyny punkt w kodzie gdzie liczymy punkty.
func calculate_score(correct: bool, response_time: float,
					 time_limit: float, streak: int) -> int:
	if not correct:
		return -error_penalty_value if scoring_error_penalty else 0

	var points: int = base_points_value if scoring_base_points else 0

	if scoring_time_bonus and time_limit > 0:
		var ratio: float = clamp(1.0 - (response_time / time_limit), 0.0, 1.0)
		points += int(time_bonus_max * ratio)

	if scoring_streak_multiplier and streak > 1:
		var mult: float = min(1.0 + (streak - 1) * 0.5, streak_multiplier_max)
		points = int(points * mult)

	return max(0, points)


## Zwraca domyślną konfigurację (hardcoded Epic 2).
static func create_default() -> SessionConfig:
	return SessionConfig.new()
