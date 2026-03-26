# resources/models/session_config.gd
# Konfiguracja sesji. W Epic 2 — hardcoded defaults.
# W Epic 3 wszystkie pola będą edytowalne przez użytkownika.
class_name SessionConfig
extends Resource

# Podstawowe
var operation_type: String = "addition"
var question_format: String = "horizontal"  # "horizontal" lub "vertical"
var mixed_operations: Array[String] = []    # niepuste = tryb mieszany
var order_of_ops_parentheses: String = "none"  # "none", "always", "mixed"
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


## Zwraca domyślną konfigurację.
static func create_default() -> SessionConfig:
	return SessionConfig.new()


## Serializuje konfigurację do słownika (zapis w localStorage).
func to_dict() -> Dictionary:
	return {
		"operation_type": operation_type,
		"question_format": question_format,
		"question_count": question_count,
		"min_value": min_value,
		"max_value": max_value,
		"time_limit_enabled": time_limit_enabled,
		"time_limit_seconds": time_limit_seconds,
		"answer_mode": answer_mode,
		"on_error_mode": on_error_mode,
		"retry_count": retry_count,
		"scoring_base_points": scoring_base_points,
		"scoring_time_bonus": scoring_time_bonus,
		"scoring_streak_multiplier": scoring_streak_multiplier,
		"scoring_error_penalty": scoring_error_penalty,
		"base_points_value": base_points_value,
		"mixed_operations": mixed_operations,
		"order_of_ops_parentheses": order_of_ops_parentheses,
	}


## Odtwarza konfigurację ze słownika.
static func from_dict(d: Dictionary) -> SessionConfig:
	var c := SessionConfig.new()
	c.operation_type = d.get("operation_type", "addition")
	c.question_format = d.get("question_format", "horizontal")
	c.question_count = d.get("question_count", 10)
	c.min_value = d.get("min_value", 1)
	c.max_value = d.get("max_value", 100)
	c.time_limit_enabled = d.get("time_limit_enabled", false)
	c.time_limit_seconds = d.get("time_limit_seconds", 30.0)
	c.answer_mode = d.get("answer_mode", "keyboard")
	c.on_error_mode = d.get("on_error_mode", "show_answer")
	c.retry_count = d.get("retry_count", 0)
	c.scoring_base_points = d.get("scoring_base_points", true)
	c.scoring_time_bonus = d.get("scoring_time_bonus", false)
	c.scoring_streak_multiplier = d.get("scoring_streak_multiplier", false)
	c.scoring_error_penalty = d.get("scoring_error_penalty", false)
	c.base_points_value = d.get("base_points_value", 10)
	for item: Variant in d.get("mixed_operations", []):
		c.mixed_operations.append(str(item))
	c.order_of_ops_parentheses = d.get("order_of_ops_parentheses", "none")
	return c
