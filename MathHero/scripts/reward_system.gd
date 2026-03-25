# scripts/reward_system.gd
# Autoload — logika systemu nagród.
# Oblicza gwiazdki, sprawdza odznaki, definicje poziomów i sklepu.
extends Node

# ─── Poziomy bohatera ─────────────────────────────────────────────────────────

const LEVEL_THRESHOLDS: Array[int] = [0, 20, 50, 100, 200, 500]
const LEVEL_NAMES: Array[String] = [
	"Rekrut", "Kosmonauta", "Pilot", "Kapitan", "MathHero", "Legenda Galaktyki"
]

# ─── Sklep kostiumu ───────────────────────────────────────────────────────────
# slot: "helmet" | "suit" | "backpack" | "boots" | "gloves"
# cost: gwiazdki, level_req: minimalny poziom bohatera

const SHOP_ITEMS: Dictionary = {
	"helmet_1":  {"name": "Hełm Bazowy",        "slot": "helmet",   "cost": 0,  "emoji": "⛑️", "level_req": 0},
	"helmet_2":  {"name": "Hełm Kosmiczny",     "slot": "helmet",   "cost": 10, "emoji": "🪖", "level_req": 1},
	"helmet_3":  {"name": "Hełm Złoty",         "slot": "helmet",   "cost": 30, "emoji": "👑", "level_req": 3},
	"suit_1":    {"name": "Skafander Biały",    "slot": "suit",     "cost": 0,  "emoji": "🥼", "level_req": 0},
	"suit_2":    {"name": "Skafander Niebieski","slot": "suit",     "cost": 15, "emoji": "🔵", "level_req": 1},
	"suit_3":    {"name": "Skafander Złoty",    "slot": "suit",     "cost": 40, "emoji": "✨", "level_req": 3},
	"backpack_1":{"name": "Plecak Standardowy", "slot": "backpack", "cost": 0,  "emoji": "🎒", "level_req": 0},
	"backpack_2":{"name": "Plecak Rakietowy",   "slot": "backpack", "cost": 20, "emoji": "🚀", "level_req": 2},
	"boots_1":   {"name": "Buty Bazowe",        "slot": "boots",    "cost": 0,  "emoji": "👟", "level_req": 0},
	"boots_2":   {"name": "Buty Kosmiczne",     "slot": "boots",    "cost": 15, "emoji": "🥾", "level_req": 1},
	"gloves_1":  {"name": "Rękawice Bazowe",    "slot": "gloves",   "cost": 0,  "emoji": "🧤", "level_req": 0},
	"gloves_2":  {"name": "Rękawice Złote",     "slot": "gloves",   "cost": 25, "emoji": "🌟", "level_req": 2},
}

# Domyślny kostium (darmowe itemy — przydzielane przy tworzeniu profilu)
const DEFAULT_COSTUME: Dictionary = {
	"helmet": "helmet_1", "suit": "suit_1", "backpack": "backpack_1",
	"boots": "boots_1", "gloves": "gloves_1",
}

# ─── Odznaki ──────────────────────────────────────────────────────────────────

const BADGE_DEFINITIONS: Dictionary = {
	"first_session":    {"name": "Pierwszy Krok",    "desc": "Ukończ pierwszą sesję",              "emoji": "🚀"},
	"sessions_10":      {"name": "Regularny",         "desc": "Ukończ 10 sesji",                    "emoji": "📅"},
	"sessions_50":      {"name": "Weteran",           "desc": "Ukończ 50 sesji",                    "emoji": "🏅"},
	"sessions_100":     {"name": "Legenda",           "desc": "Ukończ 100 sesji",                   "emoji": "🏆"},
	"streak_5":         {"name": "Seria 5",           "desc": "Seria 5 poprawnych w jednej sesji",  "emoji": "🔥"},
	"streak_10":        {"name": "Seria 10",          "desc": "Seria 10 poprawnych w jednej sesji", "emoji": "⚡"},
	"streak_20":        {"name": "Seria 20",          "desc": "Seria 20 poprawnych w jednej sesji", "emoji": "💥"},
	"perfect_score":    {"name": "Perfekcja",         "desc": "100% dokładność w sesji",            "emoji": "💯"},
	"correct_100":      {"name": "Sto Odpowiedzi",    "desc": "100 poprawnych odpowiedzi łącznie",  "emoji": "💪"},
	"correct_1000":     {"name": "Tysiąc Odpowiedzi", "desc": "1000 poprawnych odpowiedzi łącznie", "emoji": "🌟"},
	"level_kosmonauta": {"name": "Awans: Kosmonauta", "desc": "Osiągnij poziom Kosmonauty",         "emoji": "👨‍🚀"},
	"level_mathhero":   {"name": "MathHero!",         "desc": "Osiągnij poziom MathHero",           "emoji": "🦸"},
}

# ─── Gwiazdki ─────────────────────────────────────────────────────────────────

## Oblicza gwiazdki za sesję (0–3).
static func calculate_stars(result: SessionResult) -> int:
	var accuracy: float = result.get_accuracy()
	if accuracy >= Constants.SCORE_THRESHOLD_PERFECT:
		return Constants.STARS_PER_PERFECT
	elif accuracy >= Constants.SCORE_THRESHOLD_GOOD:
		return Constants.STARS_PER_GOOD
	elif accuracy >= Constants.SCORE_THRESHOLD_PASS:
		return Constants.STARS_PER_PASS
	return 0

# ─── Poziomy ──────────────────────────────────────────────────────────────────

## Zwraca poziom bohatera (0–5) na podstawie łącznych gwiazdek.
static func get_hero_level(stars_total: int) -> int:
	var level: int = 0
	for i: int in LEVEL_THRESHOLDS.size():
		if stars_total >= LEVEL_THRESHOLDS[i]:
			level = i
	return level


## Zwraca nazwę poziomu.
static func get_level_name(level: int) -> String:
	level = clamp(level, 0, LEVEL_NAMES.size() - 1)
	return LEVEL_NAMES[level]


## Zwraca informacje o progresji poziomu.
## Wynik: { level, name, is_max, stars_to_next, next_name, progress }
static func get_level_progress(stars_total: int) -> Dictionary:
	var level: int = get_hero_level(stars_total)
	var is_max: bool = level >= LEVEL_THRESHOLDS.size() - 1
	var next_idx: int = min(level + 1, LEVEL_THRESHOLDS.size() - 1)
	var current_threshold: int = LEVEL_THRESHOLDS[level]
	var next_threshold: int = LEVEL_THRESHOLDS[next_idx]

	var progress: float = 1.0
	if not is_max:
		progress = float(stars_total - current_threshold) / float(next_threshold - current_threshold)

	return {
		"level": level,
		"name": get_level_name(level),
		"is_max": is_max,
		"stars_to_next": max(0, next_threshold - stars_total),
		"next_name": get_level_name(next_idx),
		"progress": clamp(progress, 0.0, 1.0),
	}

# ─── Odznaki ──────────────────────────────────────────────────────────────────

## Sprawdza nowe odznaki.
## Wywołuj po aktualizacji profilu (session_count, total_correct, max_streak_ever, stars_total_earned).
## Zwraca tablicę ID nowo odblokowanych odznak.
static func check_new_badges(profile: PlayerProfile, result: SessionResult) -> Array[String]:
	var new_badges: Array[String] = []
	var already: Array[String] = profile.unlocked_badges

	_check("first_session",    not "first_session" in already and profile.session_count >= 1,          new_badges)
	_check("sessions_10",      not "sessions_10" in already and profile.session_count >= 10,           new_badges)
	_check("sessions_50",      not "sessions_50" in already and profile.session_count >= 50,           new_badges)
	_check("sessions_100",     not "sessions_100" in already and profile.session_count >= 100,         new_badges)
	_check("streak_5",         not "streak_5" in already and profile.max_streak_ever >= 5,             new_badges)
	_check("streak_10",        not "streak_10" in already and profile.max_streak_ever >= 10,           new_badges)
	_check("streak_20",        not "streak_20" in already and profile.max_streak_ever >= 20,           new_badges)
	_check("perfect_score",    not "perfect_score" in already and result.get_accuracy() >= 1.0,        new_badges)
	_check("correct_100",      not "correct_100" in already and profile.total_correct >= 100,          new_badges)
	_check("correct_1000",     not "correct_1000" in already and profile.total_correct >= 1000,        new_badges)

	var level: int = get_hero_level(profile.stars_total_earned)
	_check("level_kosmonauta", not "level_kosmonauta" in already and level >= 1,                       new_badges)
	_check("level_mathhero",   not "level_mathhero" in already and level >= 4,                         new_badges)

	return new_badges


static func _check(id: String, condition: bool, out: Array[String]) -> void:
	if condition:
		out.append(id)

# ─── Kostium ──────────────────────────────────────────────────────────────────

## Emoji aktualnie wyposażonego elementu w slocie.
static func get_costume_emoji(profile: PlayerProfile, slot: String) -> String:
	var item_id: String = profile.equipped_costume.get(slot, DEFAULT_COSTUME.get(slot, ""))
	if item_id.is_empty() or not SHOP_ITEMS.has(item_id):
		return "❓"
	return SHOP_ITEMS[item_id].get("emoji", "❓")


## Pełny tekst kostiumu astronauty (5 slotów w 2 wierszach).
static func get_costume_display(profile: PlayerProfile) -> String:
	return "%s %s %s\n    %s %s" % [
		get_costume_emoji(profile, "helmet"),
		get_costume_emoji(profile, "suit"),
		get_costume_emoji(profile, "backpack"),
		get_costume_emoji(profile, "boots"),
		get_costume_emoji(profile, "gloves"),
	]


## Lista itemów dla danego slotu, posortowana po cost.
static func get_items_for_slot(slot: String) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for item_id: String in SHOP_ITEMS:
		var item: Dictionary = SHOP_ITEMS[item_id]
		if item.get("slot", "") == slot:
			var entry: Dictionary = item.duplicate()
			entry["id"] = item_id
			items.append(entry)
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.get("cost", 0) < b.get("cost", 0))
	return items
