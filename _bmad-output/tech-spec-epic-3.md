# Tech-Spec: Epic 3 — Pełna Konfiguracja Sesji

**Projekt:** MathHero
**Epic:** 3 — Pełna Konfiguracja Sesji
**Data:** 2026-03-22
**Zależność:** Epic 2 ✅

---

## Cel

Zastąpić hardcoded wartości Epic 2 pełnym panelem konfiguracji, dodać profile użytkowników z avatarami, system presetów oraz tryb multiple choice.

---

## Nowy przepływ ekranów

```
Splash → ProfileSelect → SessionConfig → Session → Summary
                ↑                            ↑         |
                |____ (nowy profil) _____|   |_________|
                      ProfileCreate          "Zagraj ponownie" = ten sam config
                                             "Konfiguruj" = powrót do SessionConfig
```

---

## Stories i Acceptance Criteria

| Story | AC |
|---|---|
| S1: Wybór profilu | Widzę listę profili + przycisk "Nowy profil" |
| S2: Tworzenie profilu | Mogę wpisać nazwę i wybrać avatar (8 ikonek) |
| S3: Konfiguracja sesji | Widzę panel z wszystkimi parametrami |
| S4: Presety systemowe | Mogę wybrać 1 z 5 presetów jednym kliknięciem |
| S5: Zapis własnego presetu | Mogę zapisać aktualną konfigurację jako preset z nazwą |
| S6: Zapis konfiguracji | Konfiguracja jest zapamiętana per profil w localStorage |
| S7: Tryb multiple choice | Widzę 4 przyciski z opcjami zamiast klawiatury |
| S8: Format kolumnowy | Widzę zadanie w formacie kolumnowym (opcja) |
| S9: Walidacja | Sensowne komunikaty przy błędnych wartościach |

---

## Pliki do stworzenia przez Claude

### Nowe skrypty

| Plik | Opis |
|---|---|
| `resources/models/player_profile.gd` | Model profilu użytkownika |
| `scripts/ui/profile_select.gd` | Ekran wyboru profilu |
| `scripts/ui/profile_create.gd` | Ekran tworzenia profilu |
| `scripts/ui/session_config.gd` | Ekran konfiguracji sesji |
| `scripts/components/multiple_choice.gd` | Tryb 4 odpowiedzi |

### Zmodyfikowane skrypty

| Plik | Co się zmienia |
|---|---|
| `resources/models/session_config.gd` | Dodać `to_dict()`, `from_dict()`, pole `question_format` |
| `autoloads/game_state.gd` | Dodać `current_profile: PlayerProfile` |
| `autoloads/constants.gd` | Dodać `AVATARS`, stałe walidacji |
| `scripts/ui/splash_screen.gd` | Zmienić cel: `SCENE_MAIN_MENU` → `SCENE_PROFILE_SELECT` |
| `scripts/ui/summary.gd` | Dodać przycisk "Konfiguruj" → `SCENE_CONFIG` |
| `scripts/gameplay/session_controller.gd` | Użyć `GameState.current_session_config`, obsługa multiple choice |
| `scripts/components/question_display.gd` | Obsługa formatu kolumnowego |

### Nowe sceny (Jarek tworzy w Godot Editorze)

| Scena | Root node | Dzieci |
|---|---|---|
| `scenes/ui/profile_select.tscn` | Control | TitleLabel, ProfilesContainer (HBoxContainer), AddProfileButton |
| `scenes/ui/profile_create.tscn` | Control | TitleLabel, NameInput (LineEdit), AvatarsContainer (GridContainer z 8 Button), CreateButton, CancelButton |
| `scenes/ui/session_config.tscn` | Control | PresetsContainer, ConfigPanel (VBoxContainer z polami), PlayButton, SavePresetButton |
| `scenes/components/multiple_choice.tscn` | Control | GridContainer z 4× ChoiceButton |

### Zmodyfikowane sceny (Jarek modyfikuje w Godot Editorze)

| Scena | Zmiana |
|---|---|
| `scenes/gameplay/session.tscn` | Dodać instancję `multiple_choice.tscn` → `MultipleChoice` (domyślnie ukryta) |
| `scenes/ui/summary.tscn` | Dodać `Button` → `ConfigButton`, tekst "Konfiguruj" |

---

## Implementacja — modele danych

### `resources/models/player_profile.gd` (NOWY)

```gdscript
# resources/models/player_profile.gd
class_name PlayerProfile
extends Resource

var id: String = ""
var name: String = ""
var avatar_id: int = 0
var last_config: Dictionary = {}       # serializowana SessionConfig
var custom_presets: Array[Dictionary] = []  # [{name: String, config: Dictionary}]


static func create(profile_name: String, avatar: int) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = str(randi()) + str(randi())
	p.name = profile_name
	p.avatar_id = avatar
	p.last_config = SessionConfig.create_default().to_dict()
	return p


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"avatar_id": avatar_id,
		"last_config": last_config,
		"custom_presets": custom_presets
	}


static func from_dict(d: Dictionary) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = d.get("id", "")
	p.name = d.get("name", "")
	p.avatar_id = d.get("avatar_id", 0)
	p.last_config = d.get("last_config", {})
	p.custom_presets = d.get("custom_presets", [])
	return p
```

---

### `resources/models/session_config.gd` — ZMIANY

Dopisz na końcu klasy (po `create_default()`):

```gdscript
# Dodaj nowe pole na początku klasy (po istniejących polach):
var question_format: String = "horizontal"  # "horizontal" lub "vertical"


## Serializuje konfigurację do słownika (do zapisu w localStorage).
func to_dict() -> Dictionary:
	return {
		"operation_type": operation_type,
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
		"question_format": question_format,
	}


## Odtwarza konfigurację ze słownika.
static func from_dict(d: Dictionary) -> SessionConfig:
	var c := SessionConfig.new()
	c.operation_type = d.get("operation_type", "addition")
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
	c.question_format = d.get("question_format", "horizontal")
	return c
```

---

## Implementacja — autoloads

### `autoloads/constants.gd` — ZMIANY

Dopisz:

```gdscript
# Avatary — indeks odpowiada avatar_id w PlayerProfile
const AVATARS: Array[String] = ["🚀", "🌟", "👾", "🤖", "🦊", "🐉", "🎯", "⚡"]

# Walidacja konfiguracji sesji
const CONFIG_MIN_VALUE_MIN: int = 1
const CONFIG_MIN_VALUE_MAX: int = 199
const CONFIG_MAX_VALUE_MIN: int = 2
const CONFIG_MAX_VALUE_MAX: int = 200
const CONFIG_QUESTION_COUNT_MIN: int = 5
const CONFIG_QUESTION_COUNT_MAX: int = 50
const CONFIG_TIME_LIMIT_MIN: float = 5.0
const CONFIG_TIME_LIMIT_MAX: float = 120.0
```

---

### `autoloads/game_state.gd` — ZMIANY

Zastąp:
```gdscript
var current_profile_id: String = ""
var current_profile_name: String = ""
```
Dodaj:
```gdscript
var current_profile: PlayerProfile = null
```

Usuń metodę `set_profile()` i zastąp:
```gdscript
## Ustawia aktywny profil.
func set_profile(profile: PlayerProfile) -> void:
	current_profile = profile
	EventBus.profile_selected.emit(profile.id)
	if OS.is_debug_build():
		print("[GameState] Profil ustawiony: ", profile.name)
```

---

## Implementacja — persystencja profili

### Format danych w localStorage

Klucz: `Constants.STORAGE_KEY_PROFILES`

```json
[
  {
    "id": "12345678",
    "name": "Jan",
    "avatar_id": 0,
    "last_config": { "operation_type": "addition", "question_count": 10, ... },
    "custom_presets": [
      { "name": "Moje łatwe", "config": { ... } }
    ]
  }
]
```

### Pomocnicze funkcje persystencji (używane w profile_select.gd i profile_create.gd)

```gdscript
## Wczytuje wszystkie profile z localStorage.
static func load_profiles() -> Array[PlayerProfile]:
	var raw: Variant = DataManager.load_data(Constants.STORAGE_KEY_PROFILES)
	if raw == null or not raw is Array:
		return []
	var profiles: Array[PlayerProfile] = []
	for d in raw:
		if d is Dictionary:
			profiles.append(PlayerProfile.from_dict(d))
	return profiles


## Zapisuje tablicę profili do localStorage.
static func save_profiles(profiles: Array[PlayerProfile]) -> void:
	var data: Array = []
	for p in profiles:
		data.append(p.to_dict())
	DataManager.save(Constants.STORAGE_KEY_PROFILES, data)
```

Te funkcje zdefiniuj jako metody statyczne bezpośrednio w `profile_select.gd`.

---

## Implementacja — presety systemowe

```gdscript
# Zdefiniuj jako stałą w session_config.gd (ekran konfiguracji)
const SYSTEM_PRESETS: Array[Dictionary] = [
	{
		"name": "Łatwe",
		"config": {
			"question_count": 10, "min_value": 1, "max_value": 20,
			"time_limit_enabled": false, "answer_mode": "keyboard",
			"scoring_base_points": true, "scoring_time_bonus": false,
			"scoring_streak_multiplier": false
		}
	},
	{
		"name": "Standardowe",
		"config": {
			"question_count": 10, "min_value": 1, "max_value": 100,
			"time_limit_enabled": false, "answer_mode": "keyboard",
			"scoring_base_points": true, "scoring_time_bonus": false,
			"scoring_streak_multiplier": false
		}
	},
	{
		"name": "Szybkie",
		"config": {
			"question_count": 10, "min_value": 1, "max_value": 50,
			"time_limit_enabled": true, "time_limit_seconds": 15.0,
			"answer_mode": "keyboard",
			"scoring_base_points": true, "scoring_time_bonus": true,
			"scoring_streak_multiplier": false
		}
	},
	{
		"name": "Wyzwanie",
		"config": {
			"question_count": 20, "min_value": 1, "max_value": 100,
			"time_limit_enabled": false, "answer_mode": "keyboard",
			"scoring_base_points": true, "scoring_time_bonus": false,
			"scoring_streak_multiplier": true
		}
	},
	{
		"name": "Na czas",
		"config": {
			"question_count": 15, "min_value": 1, "max_value": 100,
			"time_limit_enabled": true, "time_limit_seconds": 10.0,
			"answer_mode": "keyboard",
			"scoring_base_points": true, "scoring_time_bonus": true,
			"scoring_streak_multiplier": true
		}
	},
]
```

---

## Implementacja — ekrany

### `scripts/ui/profile_select.gd` (NOWY)

```gdscript
# scripts/ui/profile_select.gd
extends Control

@onready var _profiles_container: HBoxContainer = $ProfilesContainer
@onready var _add_button: Button = $AddProfileButton

var _profiles: Array[PlayerProfile] = []


func _ready() -> void:
	_add_button.pressed.connect(_on_add_pressed)
	_load_and_display()

	if OS.is_debug_build():
		print("[ProfileSelect] Gotowy")


func _load_and_display() -> void:
	_profiles = _load_profiles()

	# Wyczyść stary widok
	for child in _profiles_container.get_children():
		child.queue_free()

	# Utwórz kartę dla każdego profilu
	for profile in _profiles:
		_add_profile_card(profile)


func _add_profile_card(profile: PlayerProfile) -> void:
	var btn := Button.new()
	var avatar: String = Constants.AVATARS[profile.avatar_id] if profile.avatar_id < Constants.AVATARS.size() else "🚀"
	btn.text = avatar + "\n" + profile.name
	btn.custom_minimum_size = Vector2(120, 120)
	btn.pressed.connect(_on_profile_selected.bind(profile))
	_profiles_container.add_child(btn)


func _on_profile_selected(profile: PlayerProfile) -> void:
	GameState.set_profile(profile)
	SceneManager.go_to(Constants.SCENE_CONFIG)


func _on_add_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_PROFILE_SELECT)  # zastąp po dodaniu SCENE_PROFILE_CREATE


## Wczytuje wszystkie profile z localStorage.
static func _load_profiles() -> Array[PlayerProfile]:
	var raw: Variant = DataManager.load_data(Constants.STORAGE_KEY_PROFILES)
	if raw == null or not raw is Array:
		return []
	var profiles: Array[PlayerProfile] = []
	for d: Variant in raw:
		if d is Dictionary:
			profiles.append(PlayerProfile.from_dict(d))
	return profiles


## Zapisuje tablicę profili do localStorage.
static func _save_profiles(profiles: Array[PlayerProfile]) -> void:
	var data: Array = []
	for p in profiles:
		data.append(p.to_dict())
	DataManager.save(Constants.STORAGE_KEY_PROFILES, data)
```

---

### `scripts/ui/profile_create.gd` (NOWY)

```gdscript
# scripts/ui/profile_create.gd
extends Control

@onready var _name_input: LineEdit = $NameInput
@onready var _avatars_container: GridContainer = $AvatarsContainer
@onready var _create_button: Button = $CreateButton
@onready var _cancel_button: Button = $CancelButton
@onready var _error_label: Label = $ErrorLabel

var _selected_avatar: int = 0


func _ready() -> void:
	_create_button.pressed.connect(_on_create_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_error_label.text = ""

	# Utwórz przyciski avatarów
	for i in Constants.AVATARS.size():
		var btn := Button.new()
		btn.text = Constants.AVATARS[i]
		btn.custom_minimum_size = Vector2(60, 60)
		btn.pressed.connect(_on_avatar_selected.bind(i))
		_avatars_container.add_child(btn)

	_highlight_avatar(0)

	if OS.is_debug_build():
		print("[ProfileCreate] Gotowy")


func _on_avatar_selected(index: int) -> void:
	_selected_avatar = index
	_highlight_avatar(index)


func _highlight_avatar(index: int) -> void:
	var buttons := _avatars_container.get_children()
	for i in buttons.size():
		var btn := buttons[i] as Button
		btn.modulate = Color.WHITE if i != index else Color(1.5, 1.5, 0.5)


func _on_create_pressed() -> void:
	var name_text: String = _name_input.text.strip_edges()

	if name_text.length() < 2:
		_error_label.text = "Nazwa musi mieć min. 2 znaki"
		return
	if name_text.length() > 20:
		_error_label.text = "Nazwa może mieć max. 20 znaków"
		return

	var profile := PlayerProfile.create(name_text, _selected_avatar)

	# Załaduj istniejące profile i dodaj nowy
	var profiles := ProfileSelect._load_profiles()
	if profiles.size() >= Constants.MAX_PROFILES:
		_error_label.text = "Maksymalnie %d profili" % Constants.MAX_PROFILES
		return

	profiles.append(profile)
	ProfileSelect._save_profiles(profiles)

	GameState.set_profile(profile)
	SceneManager.go_to(Constants.SCENE_CONFIG)


func _on_cancel_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_PROFILE_SELECT)
```

**Uwaga:** `ProfileSelect._load_profiles()` i `ProfileSelect._save_profiles()` wywołują statyczne metody z `profile_select.gd`. W Godot 4 możliwy dostęp przez `load("res://scripts/ui/profile_select.gd")._load_profiles()` — lub wyodrębnij te metody do osobnej klasy pomocniczej `ProfileStorage` (zalecane dla czystości kodu). Alternatywnie zduplikuj metody — to prostsza opcja dla Epic 3.

---

### `scripts/ui/session_config.gd` (NOWY)

```gdscript
# scripts/ui/session_config.gd
extends Control

const SYSTEM_PRESETS: Array[Dictionary] = [
	{"name": "Łatwe",      "config": {"question_count": 10, "min_value": 1,  "max_value": 20,  "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard", "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true, "scoring_time_bonus": false, "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10, "question_format": "horizontal", "operation_type": "addition"}},
	{"name": "Standardowe","config": {"question_count": 10, "min_value": 1,  "max_value": 100, "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard", "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true, "scoring_time_bonus": false, "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10, "question_format": "horizontal", "operation_type": "addition"}},
	{"name": "Szybkie",    "config": {"question_count": 10, "min_value": 1,  "max_value": 50,  "time_limit_enabled": true,  "time_limit_seconds": 15.0, "answer_mode": "keyboard", "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true, "scoring_time_bonus": true,  "scoring_streak_multiplier": false, "scoring_error_penalty": false, "base_points_value": 10, "question_format": "horizontal", "operation_type": "addition"}},
	{"name": "Wyzwanie",   "config": {"question_count": 20, "min_value": 1,  "max_value": 100, "time_limit_enabled": false, "time_limit_seconds": 30.0, "answer_mode": "keyboard", "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true, "scoring_time_bonus": false, "scoring_streak_multiplier": true,  "scoring_error_penalty": false, "base_points_value": 10, "question_format": "horizontal", "operation_type": "addition"}},
	{"name": "Na czas",    "config": {"question_count": 15, "min_value": 1,  "max_value": 100, "time_limit_enabled": true,  "time_limit_seconds": 10.0, "answer_mode": "keyboard", "on_error_mode": "show_answer", "retry_count": 0, "scoring_base_points": true, "scoring_time_bonus": true,  "scoring_streak_multiplier": true,  "scoring_error_penalty": false, "base_points_value": 10, "question_format": "horizontal", "operation_type": "addition"}},
]

@onready var _presets_container: HBoxContainer = $PresetsContainer
@onready var _question_count_input: SpinBox = $ConfigPanel/QuestionCountInput
@onready var _min_value_input: SpinBox = $ConfigPanel/MinValueInput
@onready var _max_value_input: SpinBox = $ConfigPanel/MaxValueInput
@onready var _time_limit_toggle: CheckButton = $ConfigPanel/TimeLimitToggle
@onready var _time_limit_input: SpinBox = $ConfigPanel/TimeLimitInput
@onready var _answer_mode_button: OptionButton = $ConfigPanel/AnswerModeButton
@onready var _on_error_button: OptionButton = $ConfigPanel/OnErrorButton
@onready var _format_button: OptionButton = $ConfigPanel/FormatButton
@onready var _scoring_base: CheckBox = $ConfigPanel/ScoringBase
@onready var _scoring_time: CheckBox = $ConfigPanel/ScoringTime
@onready var _scoring_streak: CheckBox = $ConfigPanel/ScoringStreak
@onready var _play_button: Button = $PlayButton
@onready var _save_preset_button: Button = $SavePresetButton
@onready var _error_label: Label = $ErrorLabel
@onready var _profile_label: Label = $ProfileLabel

var _current_config: SessionConfig = null


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_save_preset_button.pressed.connect(_on_save_preset_pressed)
	_time_limit_toggle.toggled.connect(_on_time_limit_toggled)

	_answer_mode_button.add_item("Klawiatura")
	_answer_mode_button.add_item("4 odpowiedzi")

	_on_error_button.add_item("Pokaż odpowiedź")
	_on_error_button.add_item("Druga szansa")

	_format_button.add_item("Poziomy")
	_format_button.add_item("Kolumnowy")

	_build_preset_buttons()
	_load_profile_config()

	if OS.is_debug_build():
		print("[SessionConfig] Gotowy")


func _load_profile_config() -> void:
	if GameState.current_profile == null:
		_current_config = SessionConfig.create_default()
		_profile_label.text = ""
		return

	_profile_label.text = Constants.AVATARS[GameState.current_profile.avatar_id] + " " + GameState.current_profile.name

	var saved: Dictionary = GameState.current_profile.last_config
	_current_config = SessionConfig.from_dict(saved) if not saved.is_empty() else SessionConfig.create_default()

	_apply_config_to_ui(_current_config)

	# Dodaj presety własne profilu
	for preset in GameState.current_profile.custom_presets:
		_add_preset_button(preset.get("name", "?"), preset.get("config", {}), false)


func _build_preset_buttons() -> void:
	for child in _presets_container.get_children():
		child.queue_free()
	for preset in SYSTEM_PRESETS:
		_add_preset_button(preset["name"], preset["config"], true)


func _add_preset_button(preset_name: String, config_dict: Dictionary, _system: bool) -> void:
	var btn := Button.new()
	btn.text = preset_name
	btn.pressed.connect(_on_preset_selected.bind(config_dict))
	_presets_container.add_child(btn)


func _on_preset_selected(config_dict: Dictionary) -> void:
	_current_config = SessionConfig.from_dict(config_dict)
	_apply_config_to_ui(_current_config)


func _apply_config_to_ui(config: SessionConfig) -> void:
	_question_count_input.value = config.question_count
	_min_value_input.value = config.min_value
	_max_value_input.value = config.max_value
	_time_limit_toggle.button_pressed = config.time_limit_enabled
	_time_limit_input.value = config.time_limit_seconds
	_time_limit_input.editable = config.time_limit_enabled
	_answer_mode_button.selected = 0 if config.answer_mode == "keyboard" else 1
	_on_error_button.selected = 0 if config.on_error_mode == "show_answer" else 1
	_format_button.selected = 0 if config.question_format == "horizontal" else 1
	_scoring_base.button_pressed = config.scoring_base_points
	_scoring_time.button_pressed = config.scoring_time_bonus
	_scoring_streak.button_pressed = config.scoring_streak_multiplier


func _read_config_from_ui() -> SessionConfig:
	var c := SessionConfig.new()
	c.operation_type = "addition"
	c.question_count = int(_question_count_input.value)
	c.min_value = int(_min_value_input.value)
	c.max_value = int(_max_value_input.value)
	c.time_limit_enabled = _time_limit_toggle.button_pressed
	c.time_limit_seconds = _time_limit_input.value
	c.answer_mode = "keyboard" if _answer_mode_button.selected == 0 else "multiple_choice"
	c.on_error_mode = "show_answer" if _on_error_button.selected == 0 else "second_chance"
	c.question_format = "horizontal" if _format_button.selected == 0 else "vertical"
	c.scoring_base_points = _scoring_base.button_pressed
	c.scoring_time_bonus = _scoring_time.button_pressed
	c.scoring_streak_multiplier = _scoring_streak.button_pressed
	return c


func _validate_config(c: SessionConfig) -> String:
	if c.min_value >= c.max_value:
		return "Min musi być mniejsze niż Max"
	if c.min_value < Constants.CONFIG_MIN_VALUE_MIN:
		return "Min musi być ≥ %d" % Constants.CONFIG_MIN_VALUE_MIN
	if c.max_value > Constants.CONFIG_MAX_VALUE_MAX:
		return "Max może być ≤ %d" % Constants.CONFIG_MAX_VALUE_MAX
	if c.question_count < Constants.CONFIG_QUESTION_COUNT_MIN or c.question_count > Constants.CONFIG_QUESTION_COUNT_MAX:
		return "Liczba pytań: %d–%d" % [Constants.CONFIG_QUESTION_COUNT_MIN, Constants.CONFIG_QUESTION_COUNT_MAX]
	if c.time_limit_enabled:
		if c.time_limit_seconds < Constants.CONFIG_TIME_LIMIT_MIN or c.time_limit_seconds > Constants.CONFIG_TIME_LIMIT_MAX:
			return "Czas: %d–%d sekund" % [int(Constants.CONFIG_TIME_LIMIT_MIN), int(Constants.CONFIG_TIME_LIMIT_MAX)]
	return ""


func _on_time_limit_toggled(enabled: bool) -> void:
	_time_limit_input.editable = enabled


func _on_play_pressed() -> void:
	var config := _read_config_from_ui()
	var error := _validate_config(config)
	if error != "":
		_error_label.text = error
		return
	_error_label.text = ""

	GameState.current_session_config = config

	# Zapisz konfigurację per profil
	if GameState.current_profile != null:
		GameState.current_profile.last_config = config.to_dict()
		_save_current_profile()

	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_save_preset_pressed() -> void:
	if GameState.current_profile == null:
		_error_label.text = "Wybierz profil, aby zapisać preset"
		return

	var config := _read_config_from_ui()
	var error := _validate_config(config)
	if error != "":
		_error_label.text = error
		return

	# Prosty dialog — na razie użyj nazwy z timestamp
	var preset_name: String = "Mój preset %d" % GameState.current_profile.custom_presets.size()
	GameState.current_profile.custom_presets.append({
		"name": preset_name,
		"config": config.to_dict()
	})
	_save_current_profile()
	_add_preset_button(preset_name, config.to_dict(), false)

	if OS.is_debug_build():
		print("[SessionConfig] Zapisano preset: ", preset_name)


func _save_current_profile() -> void:
	var raw: Variant = DataManager.load_data(Constants.STORAGE_KEY_PROFILES)
	var all_profiles: Array = raw if raw is Array else []
	for i in all_profiles.size():
		if all_profiles[i].get("id", "") == GameState.current_profile.id:
			all_profiles[i] = GameState.current_profile.to_dict()
			DataManager.save(Constants.STORAGE_KEY_PROFILES, all_profiles)
			return
```

---

### `scripts/components/multiple_choice.gd` (NOWY)

```gdscript
# scripts/components/multiple_choice.gd
# Wyświetla 4 przyciski odpowiedzi (multiple choice).
# Komunikuje się przez sygnał — NIE zna logiki sesji.
extends Control

signal answer_selected(answer: int)

@onready var _buttons: Array[Button] = [
	$GridContainer/Choice0,
	$GridContainer/Choice1,
	$GridContainer/Choice2,
	$GridContainer/Choice3,
]

var _enabled: bool = true
var _correct_answer: int = 0


func _ready() -> void:
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_choice_pressed.bind(i))


## Wyświetla opcje: poprawna odpowiedź + 3 dystraktory. Miesza kolejność.
func show_choices(correct: int, question_max: int) -> void:
	_correct_answer = correct
	var choices: Array[int] = _generate_choices(correct, question_max)
	for i in _buttons.size():
		_buttons[i].text = str(choices[i])
		_buttons[i].set_meta("value", choices[i])
		_buttons[i].modulate = Color.WHITE


## Generuje 4 unikalne opcje (1 poprawna + 3 dystraktory).
func _generate_choices(correct: int, max_val: int) -> Array[int]:
	var choices: Array[int] = [correct]
	var offsets: Array[int] = [-10, -5, -2, -1, 1, 2, 5, 10]
	offsets.shuffle()

	for offset in offsets:
		if choices.size() >= 4:
			break
		var candidate: int = correct + offset
		if candidate > 0 and candidate <= max_val * 2 and candidate not in choices:
			choices.append(candidate)

	# Uzupełnij jeśli brakuje
	var filler: int = 1
	while choices.size() < 4:
		if filler not in choices:
			choices.append(filler)
		filler += 1

	choices.shuffle()
	return choices


func _on_choice_pressed(index: int) -> void:
	if not _enabled:
		return
	var value: int = _buttons[index].get_meta("value")
	answer_selected.emit(value)


## Zaznacza wynik: zielony = poprawna, czerwony = błędna.
func show_result(selected_index: int, correct: bool) -> void:
	for i in _buttons.size():
		var val: int = _buttons[i].get_meta("value")
		if val == _correct_answer:
			_buttons[i].modulate = Color.GREEN
		elif i == selected_index and not correct:
			_buttons[i].modulate = Color.RED


func set_enabled(value: bool) -> void:
	_enabled = value
	modulate.a = 1.0 if value else 0.5
```

---

## Implementacja — zmiany w istniejących skryptach

### `scripts/gameplay/session_controller.gd` — ZMIANY

**1. Użyj konfiguracji z GameState (zamiast hardcoded):**

Zmień `_start_session()`:
```gdscript
func _start_session() -> void:
	var config: SessionConfig = GameState.current_session_config
	if config == null:
		config = SessionConfig.create_default()

	var operation: MathOperation = AdditionOperation.new()
	var questions: Array[Question] = []
	for i in config.question_count:
		questions.append(operation.generate_question(config))

	_state = SessionState.create(config, questions)
	GameState.current_session_state = _state

	# Pokaż odpowiedni tryb odpowiedzi
	if config.answer_mode == "multiple_choice":
		_keyboard.visible = false
		_multiple_choice.visible = true
		_multiple_choice.answer_selected.connect(_on_choice_selected)
	else:
		_keyboard.visible = true
		_multiple_choice.visible = false

	_show_next_question()
```

**2. Dodaj @onready dla MultipleChoice:**
```gdscript
@onready var _multiple_choice: Control = $MultipleChoice
```

**3. Zaktualizuj `_show_next_question()` — pokaż opcje w trybie multiple choice:**
```gdscript
func _show_next_question() -> void:
	_current_question = _state.get_next_question()

	if _current_question == null or _state.is_finished():
		_end_session()
		return

	_question_display.show_question(_current_question)

	# Dla multiple choice — ustaw format pytania bez "= ?"
	if _state.config.answer_mode == "multiple_choice":
		_multiple_choice.show_choices(_current_question.correct_answer, _state.config.max_value)
		_multiple_choice.set_enabled(true)
	else:
		_keyboard.set_enabled(true)

	_feedback_label.text = ""
	_waiting_for_next = false
	_question_start_time = Time.get_unix_time_from_system()
	_update_ui()
```

**4. Dodaj handler dla multiple choice:**
```gdscript
func _on_choice_selected(answer: int) -> void:
	if _waiting_for_next:
		return
	_process_answer(answer)
```

**5. Zaktualizuj `_process_answer()` — obsługa multiple choice feedback:**
```gdscript
func _process_answer(answer: int) -> void:
	_keyboard.set_enabled(false)
	if _state.config.answer_mode == "multiple_choice":
		_multiple_choice.set_enabled(false)
	_waiting_for_next = true

	var response_time: float = Time.get_unix_time_from_system() - _question_start_time
	var correct: bool = answer == _current_question.correct_answer

	if correct:
		_state.on_correct_answer(response_time)
		_question_display.show_feedback(true)
		_feedback_label.text = "Brawo!"
		_feedback_label.modulate = Color.GREEN
	else:
		_state.on_incorrect_answer(_current_question)
		_question_display.show_feedback(false, _current_question.correct_answer)
		_feedback_label.text = "Spróbuj następnym razem"
		_feedback_label.modulate = Color.RED

	_update_ui()
	await get_tree().create_timer(1.5).timeout
	_show_next_question()
```

---

### `scripts/components/question_display.gd` — ZMIANY

Dodaj metodę `set_format()` i zaktualizuj `show_question()`:

```gdscript
var _format: String = "horizontal"


## Ustawia format wyświetlania pytania.
func set_format(format: String) -> void:
	_format = format


## Wyświetla nowe pytanie i czyści pole odpowiedzi.
func show_question(question: Question) -> void:
	if _format == "vertical":
		_question_label.text = " %d\n+ %d\n───" % [question.operand_a, question.operand_b]
	else:
		_question_label.text = question.display_text
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE
```

---

### `scripts/ui/splash_screen.gd` — ZMIANA

```gdscript
# Zmień w _on_tap():
SceneManager.go_to(Constants.SCENE_PROFILE_SELECT)
```

---

### `scripts/ui/summary.gd` — ZMIANY

```gdscript
@onready var _config_button: Button = $ConfigButton

func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_config_button.pressed.connect(_on_config_pressed)
	# ... reszta bez zmian

func _on_config_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_CONFIG)
```

---

### `autoloads/constants.gd` — ZMIANA: dodaj nową stałą

```gdscript
const SCENE_PROFILE_CREATE: String = "profile_create"
```

I zaktualizuj `scene_manager.gd` — dodaj:
```gdscript
Constants.SCENE_PROFILE_CREATE: "res://scenes/ui/profile_create.tscn",
```

Popraw też `profile_select.gd` — zmień `_on_add_pressed()`:
```gdscript
func _on_add_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_PROFILE_CREATE)
```

---

## Instrukcja tworzenia scen w Godot Editorze

### Kolejność tworzenia

```
1. scenes/ui/profile_select.tscn
2. scenes/ui/profile_create.tscn
3. scenes/ui/session_config.tscn
4. scenes/components/multiple_choice.tscn
5. Modyfikacja scenes/gameplay/session.tscn
6. Modyfikacja scenes/ui/summary.tscn
```

---

### 1. `profile_select.tscn`

- Root: `Control` (Full Rect) → rename `ProfileSelect`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `TitleLabel`, tekst `Kto gra?`, wyśrodkuj górna część
  - `Label` → `ProfileLabel` (pusty — placeholder)
  - `HBoxContainer` → `ProfilesContainer`, środek ekranu, alignment Center
  - `Button` → `AddProfileButton`, tekst `+ Nowy profil`, dół ekranu wyśrodkowany
- Skrypt: `res://scripts/ui/profile_select.gd`
- Zapisz: `res://scenes/ui/profile_select.tscn`

---

### 2. `profile_create.tscn`

- Root: `Control` (Full Rect) → rename `ProfileCreate`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `TitleLabel`, tekst `Nowy profil`
  - `LineEdit` → `NameInput`, placeholder `Wpisz imię...`, max_length = 20
  - `Label` → etykieta `Wybierz ikonkę:`
  - `GridContainer` → `AvatarsContainer`, columns = 4
  - `Label` → `ErrorLabel`, tekst pusty, kolor czerwony
  - `Button` → `CreateButton`, tekst `Utwórz`
  - `Button` → `CancelButton`, tekst `Anuluj`
- Skrypt: `res://scripts/ui/profile_create.gd`
- Zapisz: `res://scenes/ui/profile_create.tscn`

---

### 3. `session_config.tscn`

- Root: `Control` (Full Rect) → rename `SessionConfig`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `ProfileLabel`, lewy górny róg
  - `HBoxContainer` → `PresetsContainer`, górna część, odstępy 8px
  - `VBoxContainer` → `ConfigPanel`, środek ekranu, dzieci:
    - `HBoxContainer`: `Label` "Pytań:" + `SpinBox` → `QuestionCountInput` (min=5, max=50, step=5)
    - `HBoxContainer`: `Label` "Zakres od:" + `SpinBox` → `MinValueInput` (min=1, max=199)
    - `HBoxContainer`: `Label` "do:" + `SpinBox` → `MaxValueInput` (min=2, max=200)
    - `HBoxContainer`: `Label` "Limit czasu:" + `CheckButton` → `TimeLimitToggle` + `SpinBox` → `TimeLimitInput` (min=5, max=120)
    - `HBoxContainer`: `Label` "Tryb:" + `OptionButton` → `AnswerModeButton`
    - `HBoxContainer`: `Label` "Przy błędzie:" + `OptionButton` → `OnErrorButton`
    - `HBoxContainer`: `Label` "Format:" + `OptionButton` → `FormatButton`
    - `HBoxContainer`: `Label` "Punktacja:" + `CheckBox` → `ScoringBase` + `CheckBox` → `ScoringTime` + `CheckBox` → `ScoringStreak`
  - `Label` → `ErrorLabel`, tekst pusty, kolor czerwony
  - `Button` → `PlayButton`, tekst `GRAJ`, dół środek
  - `Button` → `SavePresetButton`, tekst `Zapisz preset`, obok PlayButton
- Skrypt: `res://scripts/ui/session_config.gd`
- Zapisz: `res://scenes/ui/session_config.tscn`

---

### 4. `multiple_choice.tscn`

- Root: `Control` → rename `MultipleChoice`
- Dzieci:
  - `GridContainer` → `GridContainer`, columns = 2
    - `Button` → `Choice0`, min size `200x80`
    - `Button` → `Choice1`, min size `200x80`
    - `Button` → `Choice2`, min size `200x80`
    - `Button` → `Choice3`, min size `200x80`
- Skrypt: `res://scripts/components/multiple_choice.gd`
- Zapisz: `res://scenes/components/multiple_choice.tscn`

---

### 5. Modyfikacja `session.tscn`

- Otwórz istniejącą scenę
- Dodaj instancję `res://scenes/components/multiple_choice.tscn` → `MultipleChoice`
- Ustaw pozycję jak NumericKeyboard (dół ekranu, wyśrodkowany)
- Ustaw `visible = false`

---

### 6. Modyfikacja `summary.tscn`

- Otwórz istniejącą scenę
- Dodaj `Button` → `ConfigButton`, tekst `Konfiguruj`, obok `PlayAgainButton`

---

## Kolejność implementacji

```
1. session_config.gd (to_dict/from_dict) + player_profile.gd  ← modele
2. constants.gd + game_state.gd                                ← autoloady
3. scene_manager.gd                                            ← rejestracja scen
4. profile_select.gd + profile_create.gd                      ← profile
5. session_config.gd (ekran)                                   ← config UI
6. multiple_choice.gd                                          ← nowy komponent
7. session_controller.gd + question_display.gd                 ← zmiany sesji
8. splash_screen.gd + summary.gd                               ← zmiany przepływu
9. Sceny w Godot Editorze (kolejność jak wyżej)
10. Test pełnego flow: Splash → Profil → Config → Sesja → Podsumowanie
```

---

## Pliki do stworzenia przez Claude

| Plik | Status |
|---|---|
| `resources/models/player_profile.gd` | ❌ |
| `resources/models/session_config.gd` (rozszerzenie) | ❌ |
| `autoloads/constants.gd` (rozszerzenie) | ❌ |
| `autoloads/game_state.gd` (zmiana) | ❌ |
| `autoloads/scene_manager.gd` (dodanie sceny) | ❌ |
| `scripts/ui/profile_select.gd` | ❌ |
| `scripts/ui/profile_create.gd` | ❌ |
| `scripts/ui/session_config.gd` | ❌ |
| `scripts/components/multiple_choice.gd` | ❌ |
| `scripts/gameplay/session_controller.gd` (zmiana) | ❌ |
| `scripts/components/question_display.gd` (zmiana) | ❌ |
| `scripts/ui/splash_screen.gd` (zmiana) | ❌ |
| `scripts/ui/summary.gd` (zmiana) | ❌ |
| Sceny .tscn (4 nowe + 2 modyfikacje) | ❌ Jarek robi w Godot |

---

_Tech-spec stworzony: 2026-03-22_
_Następny krok: Implementacja plików GDScript, potem sceny w Godot Editorze_
