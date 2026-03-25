# scripts/galaxy_system.gd
# Autoload — logika systemu misji galaktyki, dzienne wyzwanie, bonus misji.
# Zarejestrowany jako GalaxySystem w project.godot.
extends Node

# ─── Definicje misji ──────────────────────────────────────────────────────────

const MISSIONS: Array[Dictionary] = [
	{
		"id": "prolog", "name": "Prolog", "emoji": "🌑",
		"desc": "Pierwsze kroki", "op": "addition",
		"min": 1, "max": 10, "count": 5, "req_acc": 0.7, "reward": 5,
		"unlock_requires": ""
	},
	{
		"id": "luna", "name": "Luna", "emoji": "🌕",
		"desc": "Dodawanie do 50", "op": "addition",
		"min": 1, "max": 50, "count": 10, "req_acc": 0.75, "reward": 8,
		"unlock_requires": "prolog"
	},
	{
		"id": "mars", "name": "Mars", "emoji": "🔴",
		"desc": "Odejmowanie", "op": "subtraction",
		"min": 1, "max": 30, "count": 10, "req_acc": 0.75, "reward": 8,
		"unlock_requires": "luna"
	},
	{
		"id": "wenus", "name": "Wenus", "emoji": "⭐",
		"desc": "Tabliczka mnożenia", "op": "multiplication",
		"min": 1, "max": 10, "count": 10, "req_acc": 0.7, "reward": 10,
		"unlock_requires": "mars"
	},
	{
		"id": "jowisz", "name": "Jowisz", "emoji": "🟠",
		"desc": "Dzielenie", "op": "division",
		"min": 1, "max": 10, "count": 10, "req_acc": 0.7, "reward": 10,
		"unlock_requires": "wenus"
	},
	{
		"id": "saturn", "name": "Saturn", "emoji": "💫",
		"desc": "Dodawanie i odejmowanie", "op": "mixed",
		"mixed": ["addition", "subtraction"],
		"min": 1, "max": 50, "count": 15, "req_acc": 0.8, "reward": 15,
		"unlock_requires": "jowisz"
	},
	{
		"id": "neptun", "name": "Neptun", "emoji": "🌀",
		"desc": "Mnożenie i dzielenie", "op": "mixed",
		"mixed": ["multiplication", "division"],
		"min": 1, "max": 12, "count": 15, "req_acc": 0.8, "reward": 15,
		"unlock_requires": "saturn"
	},
	{
		"id": "kosmos", "name": "Kosmos", "emoji": "🌌",
		"desc": "Wszystkie działania", "op": "mixed",
		"mixed": ["addition", "subtraction", "multiplication", "division"],
		"min": 1, "max": 20, "count": 20, "req_acc": 0.85, "reward": 25,
		"unlock_requires": "neptun"
	},
]


func _ready() -> void:
	if OS.is_debug_build():
		print("[GalaxySystem] Inicjalizacja, misji: ", MISSIONS.size())


# ─── Dostęp do misji ──────────────────────────────────────────────────────────

## Zwraca definicję misji po ID. Pusty słownik jeśli nie znaleziono.
func get_mission(mission_id: String) -> Dictionary:
	for m: Dictionary in MISSIONS:
		if m.get("id", "") == mission_id:
			return m
	return {}


## Tworzy SessionConfig na podstawie definicji misji.
func get_mission_config(mission_id: String) -> SessionConfig:
	var mission: Dictionary = get_mission(mission_id)
	var config := SessionConfig.new()
	if mission.is_empty():
		return config
	config.operation_type = mission.get("op", "addition")
	config.min_value = mission.get("min", 1)
	config.max_value = mission.get("max", 10)
	config.question_count = mission.get("count", 10)
	if mission.has("mixed"):
		var mixed_raw: Variant = mission.get("mixed", [])
		var mixed_ops: Array[String] = []
		for item: Variant in mixed_raw:
			mixed_ops.append(str(item))
		config.mixed_operations = mixed_ops
	return config


# ─── Stan misji profilu ───────────────────────────────────────────────────────

## Czy misja jest odblokowana dla danego profilu.
func is_unlocked(profile: PlayerProfile, mission_id: String) -> bool:
	var mission: Dictionary = get_mission(mission_id)
	if mission.is_empty():
		return false
	var requires: String = mission.get("unlock_requires", "")
	if requires.is_empty():
		return true
	if profile == null:
		return false
	return requires in profile.completed_missions


## Czy misja jest ukończona przez profil.
func is_completed(profile: PlayerProfile, mission_id: String) -> bool:
	if profile == null:
		return false
	return mission_id in profile.completed_missions


## Zwraca odblokowane, ale nieukończone misje.
func get_available_missions(profile: PlayerProfile) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for m: Dictionary in MISSIONS:
		var mid: String = m.get("id", "")
		if is_unlocked(profile, mid) and not is_completed(profile, mid):
			result.append(m)
	return result


# ─── Dzienne wyzwanie ─────────────────────────────────────────────────────────

## Zwraca datę w formacie "YYYY-MM-DD" (z systemowego zegara).
func get_daily_date() -> String:
	return Time.get_date_string_from_system()


## Generuje deterministyczną konfigurację dziennego wyzwania (na podstawie daty).
func get_daily_config() -> SessionConfig:
	var date_str: String = get_daily_date()
	# Sumuj cyfry daty jako seed
	var seed_val: int = 0
	for ch: String in date_str:
		if ch.is_valid_int():
			seed_val += int(ch)

	var ops: Array[String] = ["addition", "subtraction", "multiplication", "division"]
	var op_idx: int = seed_val % ops.size()
	var counts: Array[int] = [10, 12, 15]
	var count_idx: int = (seed_val / ops.size()) % counts.size()
	var maxes: Array[int] = [20, 50, 100]
	var max_idx: int = (seed_val / (ops.size() * counts.size())) % maxes.size()

	var config := SessionConfig.new()
	config.operation_type = ops[op_idx]
	config.question_count = counts[count_idx]
	config.min_value = 1
	config.max_value = maxes[max_idx]
	return config


## Czy profil ukończył już dzisiejsze wyzwanie.
func is_daily_done(profile: PlayerProfile) -> bool:
	if profile == null:
		return false
	return profile.daily_challenge_date == get_daily_date()


# ─── Misja bonusowa ───────────────────────────────────────────────────────────

## Zwraca losową nieukończoną misję jako sugestię bonusową. Pusty słownik jeśli brak.
func get_bonus_mission(profile: PlayerProfile) -> Dictionary:
	var available: Array[Dictionary] = get_available_missions(profile)
	if available.is_empty():
		return {}
	var idx: int = randi() % available.size()
	return available[idx]
