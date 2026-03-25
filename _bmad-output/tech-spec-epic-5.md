# Tech-Spec: Epic 5 — Progresja i Nagrody

**Projekt:** MathHero
**Epic:** 5 — Progresja i Nagrody
**Data:** 2026-03-25
**Zależność:** Epic 4 ✅

---

## Cel

Zbudować kompletny system motywacyjny: gwiazdki kosmiczne po sesji, 6 poziomów bohatera,
sklep kostiumu (emoji-based), odznaki osiągnięć i ekran kolekcji.

---

## Stories i Acceptance Criteria

| Story | AC |
|---|---|
| S1: Gwiazdki po sesji | Widzę 0–3 gwiazdki zarobione po sesji (zależne od dokładności) |
| S2: Poziom bohatera | Widzę swój poziom (0–5) i tytuł: Rekrut → Legenda Galaktyki |
| S3: Ekran kolekcji | Mogę wejść do kolekcji z menu głównego i ze summary |
| S4: Sklep kostiumu | Widzę sklep (5 slotów × 2–3 itemy), mogę kupić za gwiazdki |
| S5: Ubieranie bohatera | Mogę wybrać zakupiony element, wyświetla się w kolekcji |
| S6: Odznaki | Zdobywam odznaki automatycznie za milestony (sesje, serie, poziom) |
| S7: Animacja nagrody | Popup animuje gwiazdki i nowe odznaki po sesji |
| S8: Persystencja | Gwiazdki, kostium i odznaki są zapisane między sesjami |
| S9: Pasek postępu | W kolekcji widzę ile gwiazdek do następnego poziomu |

---

## Pliki do stworzenia/zmiany

### Nowe pliki (Claude pisze)

| Plik | Opis |
|---|---|
| `scripts/reward_system.gd` | Statyczna klasa — cała logika nagród |
| `scripts/ui/rewards.gd` | Ekran kolekcji (bohater + sklep + odznaki) |
| `scripts/components/reward_popup.gd` | Popup animacji nagrody po sesji |

### Zmodyfikowane pliki (Claude pisze)

| Plik | Co się zmienia |
|---|---|
| `resources/models/player_profile.gd` | Nowe pola progresji + serializacja |
| `scripts/ui/summary.gd` | Przetwarza nagrody, wyświetla gwiazdki i odznaki |
| `scripts/ui/main_menu.gd` | Przycisk "Kolekcja" |

### Nowe sceny (Jarek w Godot Editorze)

| Scena | Opis |
|---|---|
| `scenes/ui/rewards.tscn` | Ekran kolekcji — TabContainer z 3 zakładkami |
| `scenes/components/reward_popup.tscn` | Panel popupu nagrody |

### Zmodyfikowane sceny (Jarek w Godot Editorze)

| Scena | Co dodać |
|---|---|
| `scenes/ui/summary.tscn` | StarsEarnedLabel, LevelUpLabel, NewBadgesLabel, RewardsButton, RewardPopup (instancja) |
| `scenes/ui/main_menu.tscn` | RewardsButton |

---

## Implementacja — `scripts/reward_system.gd` (nowy plik)

```gdscript
# scripts/reward_system.gd
# Statyczna klasa logiki systemu nagród.
# Oblicza gwiazdki, sprawdza odznaki, definicje poziomów i sklepu.
class_name RewardSystem

# ─── Poziomy bohatera ─────────────────────────────────────────────────────────

const LEVEL_THRESHOLDS: Array[int] = [0, 20, 50, 100, 200, 500]
const LEVEL_NAMES: Array[String] = [
	"Rekrut", "Kosmonauta", "Pilot", "Kapitan", "MathHero", "Legenda Galaktyki"
]

# ─── Sklep kostiumu ───────────────────────────────────────────────────────────
# slot: "helmet" | "suit" | "backpack" | "boots" | "gloves"
# cost: gwiazdki, level_req: minimalny poziom bohatera

const SHOP_ITEMS: Dictionary = {
	"helmet_1":  {"name": "Hełm Bazowy",       "slot": "helmet",   "cost": 0,  "emoji": "⛑️", "level_req": 0},
	"helmet_2":  {"name": "Hełm Kosmiczny",    "slot": "helmet",   "cost": 10, "emoji": "🪖", "level_req": 1},
	"helmet_3":  {"name": "Hełm Złoty",        "slot": "helmet",   "cost": 30, "emoji": "👑", "level_req": 3},
	"suit_1":    {"name": "Skafander Biały",   "slot": "suit",     "cost": 0,  "emoji": "🥼", "level_req": 0},
	"suit_2":    {"name": "Skafander Niebieski","slot": "suit",    "cost": 15, "emoji": "🔵", "level_req": 1},
	"suit_3":    {"name": "Skafander Złoty",   "slot": "suit",     "cost": 40, "emoji": "✨", "level_req": 3},
	"backpack_1":{"name": "Plecak Standardowy","slot": "backpack", "cost": 0,  "emoji": "🎒", "level_req": 0},
	"backpack_2":{"name": "Plecak Rakietowy",  "slot": "backpack", "cost": 20, "emoji": "🚀", "level_req": 2},
	"boots_1":   {"name": "Buty Bazowe",       "slot": "boots",    "cost": 0,  "emoji": "👟", "level_req": 0},
	"boots_2":   {"name": "Buty Kosmiczne",    "slot": "boots",    "cost": 15, "emoji": "🥾", "level_req": 1},
	"gloves_1":  {"name": "Rękawice Bazowe",   "slot": "gloves",   "cost": 0,  "emoji": "🧤", "level_req": 0},
	"gloves_2":  {"name": "Rękawice Złote",    "slot": "gloves",   "cost": 25, "emoji": "🌟", "level_req": 2},
}

# Domyślny kostium (darmowe itemy — przydzielane przy tworzeniu profilu)
const DEFAULT_COSTUME: Dictionary = {
	"helmet": "helmet_1", "suit": "suit_1", "backpack": "backpack_1",
	"boots": "boots_1", "gloves": "gloves_1",
}

# ─── Odznaki ──────────────────────────────────────────────────────────────────

const BADGE_DEFINITIONS: Dictionary = {
	"first_session":    {"name": "Pierwszy Krok",     "desc": "Ukończ pierwszą sesję",              "emoji": "🚀"},
	"sessions_10":      {"name": "Regularny",          "desc": "Ukończ 10 sesji",                    "emoji": "📅"},
	"sessions_50":      {"name": "Weteran",            "desc": "Ukończ 50 sesji",                    "emoji": "🏅"},
	"sessions_100":     {"name": "Legenda",            "desc": "Ukończ 100 sesji",                   "emoji": "🏆"},
	"streak_5":         {"name": "Seria 5",            "desc": "Seria 5 poprawnych w jednej sesji",  "emoji": "🔥"},
	"streak_10":        {"name": "Seria 10",           "desc": "Seria 10 poprawnych w jednej sesji", "emoji": "⚡"},
	"streak_20":        {"name": "Seria 20",           "desc": "Seria 20 poprawnych w jednej sesji", "emoji": "💥"},
	"perfect_score":    {"name": "Perfekcja",          "desc": "100% dokładność w sesji",            "emoji": "💯"},
	"correct_100":      {"name": "Sto Odpowiedzi",     "desc": "100 poprawnych odpowiedzi łącznie",  "emoji": "💪"},
	"correct_1000":     {"name": "Tysiąc Odpowiedzi",  "desc": "1000 poprawnych odpowiedzi łącznie", "emoji": "🌟"},
	"level_kosmonauta": {"name": "Awans: Kosmonauta",  "desc": "Osiągnij poziom Kosmonauty",         "emoji": "👨‍🚀"},
	"level_mathhero":   {"name": "MathHero!",          "desc": "Osiągnij poziom MathHero",           "emoji": "🦸"},
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


## Zwraca informacje o progresji poziomu dla danego profilu.
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

	_check("first_session",    not "first_session" in already and profile.session_count >= 1,            new_badges)
	_check("sessions_10",      not "sessions_10" in already and profile.session_count >= 10,             new_badges)
	_check("sessions_50",      not "sessions_50" in already and profile.session_count >= 50,             new_badges)
	_check("sessions_100",     not "sessions_100" in already and profile.session_count >= 100,           new_badges)
	_check("streak_5",         not "streak_5" in already and profile.max_streak_ever >= 5,               new_badges)
	_check("streak_10",        not "streak_10" in already and profile.max_streak_ever >= 10,             new_badges)
	_check("streak_20",        not "streak_20" in already and profile.max_streak_ever >= 20,             new_badges)
	_check("perfect_score",    not "perfect_score" in already and result.get_accuracy() >= 1.0,          new_badges)
	_check("correct_100",      not "correct_100" in already and profile.total_correct >= 100,            new_badges)
	_check("correct_1000",     not "correct_1000" in already and profile.total_correct >= 1000,          new_badges)

	var level: int = get_hero_level(profile.stars_total_earned)
	_check("level_kosmonauta", not "level_kosmonauta" in already and level >= 1,                         new_badges)
	_check("level_mathhero",   not "level_mathhero" in already and level >= 4,                           new_badges)

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


## Pełny tekst kostiumu astronauty (5 slotów w wierszach).
static func get_costume_display(profile: PlayerProfile) -> String:
	return "%s %s %s\n%s %s" % [
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
```

---

## Implementacja — `resources/models/player_profile.gd` (zmiany)

### Nowe pola (dopisz po `custom_presets`):

```gdscript
# Progresja
var stars: int = 0                      # aktualne saldo (earned - spent)
var stars_total_earned: int = 0         # łączne zarobione (do obliczeń poziomu)
var owned_items: Array[String] = []     # ID zakupionych itemów sklepu
var equipped_costume: Dictionary = {}   # { slot: item_id }
var unlocked_badges: Array[String] = [] # ID zdobytych odznak
var session_count: int = 0              # łączna liczba ukończonych sesji
var total_correct: int = 0              # łączna liczba poprawnych odpowiedzi
var max_streak_ever: int = 0            # najlepsza seria kiedykolwiek
```

### Zaktualizuj `create()` — po `p.last_config = ...` dopisz:

```gdscript
	# Przyznaj darmowe itemy na start
	p.owned_items = ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"]
	p.equipped_costume = RewardSystem.DEFAULT_COSTUME.duplicate()
```

### Zaktualizuj `to_dict()` — dopisz do słownika:

```gdscript
		"stars": stars,
		"stars_total_earned": stars_total_earned,
		"owned_items": owned_items,
		"equipped_costume": equipped_costume,
		"unlocked_badges": unlocked_badges,
		"session_count": session_count,
		"total_correct": total_correct,
		"max_streak_ever": max_streak_ever,
```

### Zaktualizuj `from_dict()` — dopisz po istniejących liniach:

```gdscript
	p.stars = d.get("stars", 0)
	p.stars_total_earned = d.get("stars_total_earned", 0)
	p.owned_items = d.get("owned_items", ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"])
	p.equipped_costume = d.get("equipped_costume", RewardSystem.DEFAULT_COSTUME.duplicate())
	p.unlocked_badges = d.get("unlocked_badges", [])
	p.session_count = d.get("session_count", 0)
	p.total_correct = d.get("total_correct", 0)
	p.max_streak_ever = d.get("max_streak_ever", 0)
```

---

## Implementacja — `scripts/ui/summary.gd` (zastąp całość)

```gdscript
# scripts/ui/summary.gd
extends Control

@onready var _result_label: Label = $ResultLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _accuracy_label: Label = $AccuracyLabel
@onready var _stars_earned_label: Label = $StarsEarnedLabel
@onready var _level_up_label: Label = $LevelUpLabel
@onready var _new_badges_label: Label = $NewBadgesLabel
@onready var _play_again_button: Button = $PlayAgainButton
@onready var _config_button: Button = $ConfigButton
@onready var _rewards_button: Button = $RewardsButton
@onready var _reward_popup: Control = $RewardPopup

var _result: SessionResult = null
var _stars_earned: int = 0
var _new_badges: Array[String] = []


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_config_button.pressed.connect(_on_config_pressed)
	_rewards_button.pressed.connect(_on_rewards_pressed)

	_level_up_label.visible = false
	_new_badges_label.visible = false
	_stars_earned_label.text = ""

	if GameState.last_session_result != null:
		_result = GameState.last_session_result
		_process_rewards()
		_update_ui()
		_show_reward_popup()

	if OS.is_debug_build():
		print("[Summary] Gotowy")


## Aktualizuje profil i oblicza nagrody za tę sesję.
func _process_rewards() -> void:
	if _result == null or not GameState.has_active_profile():
		return

	var profile: PlayerProfile = GameState.current_profile
	_stars_earned = RewardSystem.calculate_stars(_result)

	var old_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)

	# Aktualizacja danych profilu
	profile.stars += _stars_earned
	profile.stars_total_earned += _stars_earned
	profile.session_count += 1
	profile.total_correct += _result.correct_count
	if _result.max_streak > profile.max_streak_ever:
		profile.max_streak_ever = _result.max_streak

	# Sprawdź nowe odznaki (po aktualizacji danych profilu)
	_new_badges = RewardSystem.check_new_badges(profile, _result)
	for badge_id: String in _new_badges:
		if not badge_id in profile.unlocked_badges:
			profile.unlocked_badges.append(badge_id)

	# Sprawdź awans poziomu
	var new_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)
	if new_level > old_level:
		_level_up_label.text = "🎉 Awans! Teraz jesteś: %s" % RewardSystem.get_level_name(new_level)
		_level_up_label.visible = true

	# Emituj sygnały
	if _stars_earned > 0:
		EventBus.stars_earned.emit(_stars_earned, profile.stars)
	for badge_id: String in _new_badges:
		EventBus.achievement_unlocked.emit(badge_id)

	# Zapisz profil
	_save_profile(profile)

	if OS.is_debug_build():
		print("[Summary] Nagrody: gwiazdki=", _stars_earned, " odznaki=", _new_badges)


func _update_ui() -> void:
	if _result == null:
		return

	_result_label.text = "%d / %d poprawnych" % [_result.correct_count, _result.total_questions]
	_score_label.text = "Punkty: %d" % _result.score
	_accuracy_label.text = "Dokładność: %d%%" % _result.get_accuracy_percent()

	# Gwiazdki
	var stars_text: String = "⭐".repeat(_stars_earned) if _stars_earned > 0 else "—"
	_stars_earned_label.text = "Gwiazdki: %s" % stars_text

	# Nowe odznaki
	if not _new_badges.is_empty():
		var badge_names: Array[String] = []
		for badge_id: String in _new_badges:
			var def: Dictionary = RewardSystem.BADGE_DEFINITIONS.get(badge_id, {})
			badge_names.append(def.get("emoji", "🏅") + " " + def.get("name", badge_id))
		_new_badges_label.text = "Nowe odznaki:\n" + "\n".join(badge_names)
		_new_badges_label.visible = true


func _show_reward_popup() -> void:
	if _stars_earned > 0 or not _new_badges.is_empty():
		if is_instance_valid(_reward_popup) and _reward_popup.has_method("show_rewards"):
			_reward_popup.show_rewards(_stars_earned, _new_badges)


## Zapisuje aktywny profil (load → update → save all).
func _save_profile(profile: PlayerProfile) -> void:
	var profiles: Array[PlayerProfile] = ProfileSelect.load_profiles()
	for i: int in profiles.size():
		if profiles[i].id == profile.id:
			profiles[i] = profile
			break
	ProfileSelect.save_profiles(profiles)


func _on_play_again_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_config_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_CONFIG)


func _on_rewards_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_REWARDS)
```

---

## Implementacja — `scripts/components/reward_popup.gd` (nowy plik)

```gdscript
# scripts/components/reward_popup.gd
# Popup animacji nagrody — wysuwa się po sesji, auto-chowa po 3 sekundach.
extends Control

@onready var _panel: Panel = $Panel
@onready var _stars_label: Label = $Panel/VBox/StarsLabel
@onready var _badges_label: Label = $Panel/VBox/BadgesLabel


func _ready() -> void:
	visible = false
	modulate.a = 0.0


## Pokazuje popup z nagrodami. Wywołuje animację wejścia.
func show_rewards(stars: int, new_badges: Array[String]) -> void:
	# Tekst
	if stars > 0:
		_stars_label.text = "⭐ +" + str(stars) + (" gwiazdka!" if stars == 1 else " gwiazdki!" if stars < 5 else " gwiazdek!")
	else:
		_stars_label.text = ""

	if not new_badges.is_empty():
		var lines: Array[String] = []
		for badge_id: String in new_badges:
			var def: Dictionary = RewardSystem.BADGE_DEFINITIONS.get(badge_id, {})
			lines.append(def.get("emoji", "🏅") + " " + def.get("name", badge_id))
		_badges_label.text = "Nowa odznaka!\n" + "\n".join(lines)
	else:
		_badges_label.text = ""

	visible = true

	# Animacja: fade in + slide up → czekaj → fade out
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "position:y", position.y - 20.0, 0.4)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: visible = false)
```

---

## Implementacja — `scripts/ui/rewards.gd` (nowy plik)

```gdscript
# scripts/ui/rewards.gd
extends Control

# ── Zakładka Bohater ──────────────────────────────────────────────────────────
@onready var _hero_display: Label = $TabContainer/Bohater/HeroDisplay
@onready var _hero_level_label: Label = $TabContainer/Bohater/LevelLabel
@onready var _stars_label: Label = $TabContainer/Bohater/StarsLabel
@onready var _progress_bar: ProgressBar = $TabContainer/Bohater/ProgressBar
@onready var _progress_label: Label = $TabContainer/Bohater/ProgressLabel

# ── Zakładka Sklep ────────────────────────────────────────────────────────────
@onready var _shop_container: VBoxContainer = $TabContainer/Sklep/ScrollContainer/ItemsContainer
@onready var _shop_stars_label: Label = $TabContainer/Sklep/CurrentStarsLabel

# ── Zakładka Odznaki ──────────────────────────────────────────────────────────
@onready var _badges_container: GridContainer = $TabContainer/Odznaki/ScrollContainer/BadgesContainer

# ── Nawigacja ─────────────────────────────────────────────────────────────────
@onready var _back_button: Button = $BackButton

const _SLOTS: Array[String] = ["helmet", "suit", "backpack", "boots", "gloves"]
const _SLOT_NAMES: Dictionary = {
	"helmet": "Hełm", "suit": "Skafander", "backpack": "Plecak",
	"boots": "Buty", "gloves": "Rękawice",
}


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)

	if not GameState.has_active_profile():
		push_warning("[Rewards] Brak aktywnego profilu")
		SceneManager.go_to(Constants.SCENE_MAIN_MENU)
		return

	_refresh_hero_tab()
	_build_shop_tab()
	_build_badges_tab()

	if OS.is_debug_build():
		print("[Rewards] Gotowy")


# ── Zakładka Bohater ──────────────────────────────────────────────────────────

func _refresh_hero_tab() -> void:
	var profile: PlayerProfile = GameState.current_profile
	_hero_display.text = RewardSystem.get_costume_display(profile)

	var progress: Dictionary = RewardSystem.get_level_progress(profile.stars_total_earned)
	_hero_level_label.text = "Poziom %d: %s" % [progress.level, progress.name]
	_stars_label.text = "⭐ %d gwiazdek" % profile.stars

	if progress.is_max:
		_progress_bar.value = 1.0
		_progress_label.text = "Maksymalny poziom!"
	else:
		_progress_bar.value = progress.progress
		_progress_label.text = "%d gwiazdek do: %s" % [progress.stars_to_next, progress.next_name]


# ── Zakładka Sklep ────────────────────────────────────────────────────────────

func _build_shop_tab() -> void:
	for child in _shop_container.get_children():
		child.queue_free()

	var profile: PlayerProfile = GameState.current_profile
	_shop_stars_label.text = "Masz: ⭐ %d" % profile.stars

	var hero_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)

	for slot: String in _SLOTS:
		# Nagłówek slotu
		var slot_label := Label.new()
		slot_label.text = "── %s ──" % _SLOT_NAMES.get(slot, slot)
		_shop_container.add_child(slot_label)

		# Itemy slotu
		var items: Array[Dictionary] = RewardSystem.get_items_for_slot(slot)
		for item: Dictionary in items:
			_build_shop_item(item, profile, hero_level)


func _build_shop_item(item: Dictionary, profile: PlayerProfile, hero_level: int) -> void:
	var item_id: String = item.get("id", "")
	var owned: bool = item_id in profile.owned_items
	var equipped: bool = profile.equipped_costume.get(item.get("slot", ""), "") == item_id
	var cost: int = item.get("cost", 0)
	var level_req: int = item.get("level_req", 0)
	var level_ok: bool = hero_level >= level_req
	var can_buy: bool = not owned and level_ok and profile.stars >= cost

	var row := HBoxContainer.new()

	var emoji_lbl := Label.new()
	emoji_lbl.text = item.get("emoji", "?")
	emoji_lbl.custom_minimum_size = Vector2(50, 0)

	var name_lbl := Label.new()
	name_lbl.text = item.get("name", "")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(160, 44)

	if equipped:
		action_btn.text = "✅ Ubrane"
		action_btn.disabled = true
	elif owned:
		action_btn.text = "Ubierz"
		action_btn.pressed.connect(_on_equip_pressed.bind(item_id, item.get("slot", "")))
	elif not level_ok:
		action_btn.text = "Poziom %d ❌" % level_req
		action_btn.disabled = true
	elif can_buy:
		action_btn.text = "Kup ⭐%d" % cost
		action_btn.pressed.connect(_on_buy_pressed.bind(item_id, cost))
	else:
		action_btn.text = "Za mało ⭐"
		action_btn.disabled = true

	row.add_child(emoji_lbl)
	row.add_child(name_lbl)
	row.add_child(action_btn)
	_shop_container.add_child(row)


func _on_buy_pressed(item_id: String, cost: int) -> void:
	var profile: PlayerProfile = GameState.current_profile
	if profile.stars < cost or item_id in profile.owned_items:
		return

	profile.stars -= cost
	profile.owned_items.append(item_id)
	EventBus.costume_purchased.emit(item_id)

	_save_profile(profile)
	_build_shop_tab()
	_refresh_hero_tab()

	if OS.is_debug_build():
		print("[Rewards] Kupiono: ", item_id)


func _on_equip_pressed(item_id: String, slot: String) -> void:
	var profile: PlayerProfile = GameState.current_profile
	if not item_id in profile.owned_items:
		return

	profile.equipped_costume[slot] = item_id
	_save_profile(profile)
	_build_shop_tab()
	_refresh_hero_tab()

	if OS.is_debug_build():
		print("[Rewards] Ubrano: ", item_id, " w slocie: ", slot)


# ── Zakładka Odznaki ──────────────────────────────────────────────────────────

func _build_badges_tab() -> void:
	for child in _badges_container.get_children():
		child.queue_free()

	var profile: PlayerProfile = GameState.current_profile

	for badge_id: String in RewardSystem.BADGE_DEFINITIONS:
		var def: Dictionary = RewardSystem.BADGE_DEFINITIONS[badge_id]
		var earned: bool = badge_id in profile.unlocked_badges

		var panel := PanelContainer.new()
		var vbox := VBoxContainer.new()
		panel.custom_minimum_size = Vector2(140, 100)

		var emoji_lbl := Label.new()
		emoji_lbl.text = def.get("emoji", "🏅")
		emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_lbl.add_theme_font_size_override("font_size", 32)

		var name_lbl := Label.new()
		name_lbl.text = def.get("name", "")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		vbox.add_child(emoji_lbl)
		vbox.add_child(name_lbl)
		panel.add_child(vbox)

		if not earned:
			panel.modulate = Color(0.4, 0.4, 0.4, 0.6)

		_badges_container.add_child(panel)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _save_profile(profile: PlayerProfile) -> void:
	var profiles: Array[PlayerProfile] = ProfileSelect.load_profiles()
	for i: int in profiles.size():
		if profiles[i].id == profile.id:
			profiles[i] = profile
			break
	ProfileSelect.save_profiles(profiles)


func _on_back_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)
```

---

## Implementacja — `scripts/ui/main_menu.gd` (zmiana)

### Dopisz `@onready`:

```gdscript
@onready var _rewards_button: Button = $RewardsButton
```

### Dopisz w `_ready()` po istniejących connect():

```gdscript
	_rewards_button.pressed.connect(_on_rewards_pressed)
```

### Dopisz nową metodę:

```gdscript
func _on_rewards_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_REWARDS)
```

---

## Instrukcja modyfikacji scen w Godot Editorze

### `scenes/ui/summary.tscn` — nowe węzły

Dodaj pod istniejącymi etykietami i przyciskami:

```
StarsEarnedLabel     (Label)   — tekst gwiazdek zarobione
LevelUpLabel         (Label)   — awans, visible=false
NewBadgesLabel       (Label)   — nowe odznaki, visible=false, autowrap=true
RewardsButton        (Button)  — tekst "Kolekcja 🏆", min_size 160x56

RewardPopup          (Control) — instancja scenes/components/reward_popup.tscn
                                  pozycja: dolna część ekranu, centered X
```

### `scenes/components/reward_popup.tscn` — nowa scena

```
RewardPopup (Control)  ← root, script=reward_popup.gd
  └── Panel
        └── VBox (VBoxContainer, margin 16px)
              ├── StarsLabel (Label, font_size=28, align=center)
              └── BadgesLabel (Label, font_size=20, align=center, autowrap=true)
```

Panel: zaokrąglone rogi, półprzezroczyste tło (Color(0, 0, 0, 0.7)), szerokość ~500px.
Pozycja root Control: zakotwiczone do dołu ekranu (anchor bottom_center).

### `scenes/ui/rewards.tscn` — nowa scena

```
Rewards (Control)  ← root, script=rewards.gd
├── BackButton (Button) — tekst "← Wstecz", min_size 44px, góra-lewo
└── TabContainer
      ├── Bohater (VBoxContainer)
      │     ├── HeroDisplay (Label, font_size=48, align=center)   ← emoji kostiumu
      │     ├── LevelLabel  (Label, font_size=24, align=center)
      │     ├── StarsLabel  (Label, font_size=20, align=center)
      │     ├── ProgressBar (min_size: 400x20)
      │     └── ProgressLabel (Label, font_size=16, align=center)
      ├── Sklep (VBoxContainer)
      │     ├── CurrentStarsLabel (Label, font_size=20)
      │     └── ScrollContainer
      │           └── ItemsContainer (VBoxContainer)  ← wypełniany w kodzie
      └── Odznaki (VBoxContainer)
            └── ScrollContainer
                  └── BadgesContainer (GridContainer, columns=4)  ← wypełniany w kodzie
```

### `scenes/ui/main_menu.tscn` — dodaj

```
RewardsButton (Button) — tekst "🏆 Kolekcja", min_size 160x56
```

---

## Kolejność implementacji

```
1. reward_system.gd                  — logika (bez zależności od scen)
2. player_profile.gd                 — nowe pola + serializacja
3. reward_popup.gd + reward_popup.tscn w Godot
4. summary.gd + zmiany summary.tscn w Godot
5. rewards.gd + rewards.tscn w Godot
6. main_menu.gd + zmiany main_menu.tscn w Godot
7. Test: sesja → summary (gwiazdki + popup) → kolekcja (sklep + odznaki)
```

---

## Tabela statusu

| Plik | Status |
|---|---|
| `scripts/reward_system.gd` | ❌ |
| `resources/models/player_profile.gd` (rozszerzenie) | ❌ |
| `scripts/ui/summary.gd` (zmiana) | ❌ |
| `scripts/ui/rewards.gd` | ❌ |
| `scripts/components/reward_popup.gd` | ❌ |
| `scripts/ui/main_menu.gd` (zmiana) | ❌ |
| `scenes/ui/rewards.tscn` | ❌ Jarek w Godot |
| `scenes/components/reward_popup.tscn` | ❌ Jarek w Godot |
| `scenes/ui/summary.tscn` (nowe węzły) | ❌ Jarek w Godot |
| `scenes/ui/main_menu.tscn` (RewardsButton) | ❌ Jarek w Godot |

---

_Tech-spec stworzony: 2026-03-25_
