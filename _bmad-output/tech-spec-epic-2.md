# Tech-Spec: Epic 2 — Vertical Slice (MVP Core)

**Projekt:** MathHero
**Epic:** 2 — Vertical Slice
**Data:** 2026-03-22
**Zależność:** Epic 1 ✅

---

## Cel

Zbudować kompletną, grywalną pętlę dla jednego typu działania (dodawanie). Od ekranu głównego przez sesję do podsumowania. Wszystkie wartości hardcoded — konfiguracja dopiero w Epic 3.

---

## Stories i Acceptance Criteria

| Story | AC |
|---|---|
| S1: Ekran główny | Widzę ekran z przyciskiem "Graj" |
| S2: Zadanie dodawania | Widzę `a + b = ?` w czytelnym formacie |
| S3: Klawiatura numeryczna | Mogę wpisać odpowiedź cyframi on-screen |
| S4: Feedback poprawna | Zielony kolor / komunikat przy dobrej odpowiedzi |
| S5: Feedback błędna | Czerwony kolor + prawidłowa odpowiedź przy złej |
| S6: Postęp sesji | Widzę aktualny wynik i `X/10` pytań |
| S7: Ekran podsumowania | Po 10 pytaniach widzę wynik końcowy |
| S8: Nowa sesja | Z podsumowania mogę zacząć od nowa |

**Hardcoded w Epic 2:**
- 10 pytań, tylko dodawanie, zakres 1-100
- Bez limitu czasu, bez konfiguracji, bez profili, bez nagród, bez dźwięków

---

## Przepływ ekranów

```
SplashScreen → MainMenu → Session → Summary → Session (nowa)
                                  ↗ (Zagraj ponownie)
```

---

## Pliki do stworzenia

### Skrypty (Claude pisze)

| Plik | Opis |
|---|---|
| `resources/models/question.gd` | Model pytania |
| `resources/models/session_config.gd` | Konfiguracja sesji (hardcoded defaults) |
| `resources/models/session_state.gd` | Stan aktywnej sesji |
| `resources/models/session_result.gd` | Wynik zakończonej sesji |
| `resources/math_operations/math_operation.gd` | Klasa bazowa operacji |
| `resources/math_operations/addition_operation.gd` | Dodawanie |
| `scripts/gameplay/session_controller.gd` | Logika sesji |
| `scripts/components/numeric_keyboard.gd` | Klawiatura numeryczna |
| `scripts/components/question_display.gd` | Wyświetlanie pytania |
| `scripts/ui/main_menu.gd` | Ekran główny |
| `scripts/ui/summary.gd` | Ekran podsumowania |

### Sceny (Jarek tworzy w Godot Editorze)

| Scena | Root node | Dzieci |
|---|---|---|
| `scenes/ui/main_menu.tscn` | Control | Label (tytuł), Button (TapButton "Graj") |
| `scenes/gameplay/session.tscn` | Control | QuestionDisplay, ProgressLabel, ScoreLabel, NumericKeyboard, FeedbackLabel |
| `scenes/components/numeric_keyboard.tscn` | Control | GridContainer z 12 Button (0-9, backspace, OK) |
| `scenes/components/question_display.tscn` | Control | Label (QuestionLabel), Label (AnswerLabel) |
| `scenes/ui/summary.tscn` | Control | Label (wynik), Label (punkty), Button (ZagrajPonownie) |

---

## Implementacja — modele danych

### `resources/models/question.gd`

```gdscript
# resources/models/question.gd
class_name Question
extends Resource

var id: String = ""          # unikalny identyfikator (UUID-like)
var operand_a: int = 0
var operand_b: int = 0
var operation: String = ""   # "addition", "subtraction", itp.
var correct_answer: int = 0
var display_text: String = ""  # np. "12 + 7 = ?"


static func create(a: int, b: int, op: String, answer: int, display: String) -> Question:
	var q := Question.new()
	q.id = str(randi())  # prosty unikalny ID
	q.operand_a = a
	q.operand_b = b
	q.operation = op
	q.correct_answer = answer
	q.display_text = display
	return q
```

---

### `resources/models/session_config.gd`

```gdscript
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
```

---

### `resources/models/session_state.gd`

```gdscript
# resources/models/session_state.gd
# Stan aktywnej sesji. Przechowywany w GameState.current_session_state.
class_name SessionState
extends Resource

var config: SessionConfig = null
var questions: Array[Question] = []
var current_index: int = 0
var score: int = 0
var correct_count: int = 0
var streak: int = 0           # aktualna seria bezbłędnych
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
	# Co 3 pytania wstrzyknij powtórkę jeśli jest
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

	# Dodaj do kolejki powtórek jeśli skonfigurowane
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
```

---

### `resources/models/session_result.gd`

```gdscript
# resources/models/session_result.gd
# Niezmienny wynik zakończonej sesji. Przekazywany do ekranu Summary i RewardSystem.
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
```

---

## Implementacja — generator zadań

### `resources/math_operations/math_operation.gd`

```gdscript
# resources/math_operations/math_operation.gd
# Klasa bazowa dla wszystkich typów działań matematycznych.
# Każdy nowy typ = nowa klasa dziedzicząca po tej.
# NIE modyfikuj session_controller.gd przy dodawaniu nowych typów.
class_name MathOperation
extends Resource


## Generuje jedno pytanie na podstawie konfiguracji sesji.
## OVERRIDE w klasach pochodnych.
func generate_question(config: SessionConfig) -> Question:
	push_error("[MathOperation] generate_question() nie jest zaimplementowane!")
	return Question.new()


## Pomocnik — generuje liczbę losową z zakresu [min_val, max_val].
func _rand_in_range(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)
```

---

### `resources/math_operations/addition_operation.gd`

```gdscript
# resources/math_operations/addition_operation.gd
class_name AdditionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var answer: int = a + b
	var display: String = "%d + %d = ?" % [a, b]
	return Question.create(a, b, "addition", answer, display)
```

---

## Implementacja — komponenty

### `scripts/components/numeric_keyboard.gd`

```gdscript
# scripts/components/numeric_keyboard.gd
# Wirtualna klawiatura numeryczna on-screen.
# Komunikuje się przez lokalne sygnały — NIE zna logiki sesji.
extends Control

signal digit_pressed(digit: int)
signal backspace_pressed
signal confirm_pressed

# Podłącz w scenie: 10 przycisków cyfr (0-9), BackspaceButton, ConfirmButton
@onready var _digit_buttons: Array[Button] = []
@onready var _backspace_button: Button = $GridContainer/BackspaceButton
@onready var _confirm_button: Button = $GridContainer/ConfirmButton

var _enabled: bool = true


func _ready() -> void:
	# Zbierz przyciski cyfr (zakładamy nazwy Digit0..Digit9)
	for i in range(10):
		var btn: Button = $GridContainer.get_node_or_null("Digit%d" % i)
		if btn:
			_digit_buttons.append(btn)
			btn.pressed.connect(_on_digit_pressed.bind(i))

	_backspace_button.pressed.connect(_on_backspace_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)


func _on_digit_pressed(digit: int) -> void:
	if _enabled:
		digit_pressed.emit(digit)


func _on_backspace_pressed() -> void:
	if _enabled:
		backspace_pressed.emit()


func _on_confirm_pressed() -> void:
	if _enabled:
		confirm_pressed.emit()


## Blokuje klawiaturę (np. podczas pokazywania feedbacku).
func set_enabled(value: bool) -> void:
	_enabled = value
	modulate.a = 1.0 if value else 0.5
```

---

### `scripts/components/question_display.gd`

```gdscript
# scripts/components/question_display.gd
# Wyświetla treść pytania i aktualnie wpisywaną odpowiedź.
# Komunikuje się przez sygnały — NIE zna logiki sesji.
extends Control

@onready var _question_label: Label = $QuestionLabel
@onready var _answer_label: Label = $AnswerLabel

var _current_answer: String = ""


## Wyświetla nowe pytanie i czyści pole odpowiedzi.
func show_question(question: Question) -> void:
	_question_label.text = question.display_text
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE


## Dodaje cyfrę do aktualnie wpisywanej odpowiedzi.
func append_digit(digit: int) -> void:
	if _current_answer.length() >= 6:  # max 6 cyfr
		return
	_current_answer += str(digit)
	_answer_label.text = _current_answer


## Usuwa ostatnią cyfrę.
func remove_last_digit() -> void:
	if _current_answer.length() > 0:
		_current_answer = _current_answer.left(_current_answer.length() - 1)
	_answer_label.text = _current_answer if _current_answer != "" else "_"


## Zwraca aktualnie wpisaną wartość (lub null jeśli puste).
func get_answer() -> Variant:
	if _current_answer == "":
		return null
	return int(_current_answer)


## Pokazuje feedback (zielony = poprawna, czerwony = błędna).
func show_feedback(correct: bool, correct_answer: int = 0) -> void:
	if correct:
		_answer_label.modulate = Color.GREEN
	else:
		_answer_label.modulate = Color.RED
		_question_label.text += "  ✓ %d" % correct_answer


## Czyści feedback i pole odpowiedzi.
func clear() -> void:
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE
```

---

## Implementacja — logika sesji

### `scripts/gameplay/session_controller.gd`

```gdscript
# scripts/gameplay/session_controller.gd
# Główna logika sesji matematycznej.
# Podłącz w scenie session.tscn jako skrypt na root node.
extends Control

@onready var _question_display: Control = $QuestionDisplay
@onready var _keyboard: Control = $NumericKeyboard
@onready var _progress_label: Label = $ProgressLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _feedback_label: Label = $FeedbackLabel

var _state: SessionState = null
var _current_question: Question = null
var _question_start_time: float = 0.0
var _waiting_for_next: bool = false  # blokada podczas pokazywania feedbacku


func _ready() -> void:
	# Podłącz sygnały klawiatury
	_keyboard.digit_pressed.connect(_on_digit_pressed)
	_keyboard.backspace_pressed.connect(_on_backspace_pressed)
	_keyboard.confirm_pressed.connect(_on_confirm_pressed)

	# Inicjalizuj sesję
	_start_session()

	if OS.is_debug_build():
		print("[SessionController] Sesja rozpoczęta")


func _start_session() -> void:
	var config: SessionConfig = SessionConfig.create_default()
	var operation: MathOperation = AdditionOperation.new()

	var questions: Array[Question] = []
	for i in config.question_count:
		questions.append(operation.generate_question(config))

	_state = SessionState.create(config, questions)
	GameState.current_session_state = _state

	_show_next_question()


func _show_next_question() -> void:
	_current_question = _state.get_next_question()

	if _current_question == null or _state.is_finished():
		_end_session()
		return

	_question_display.show_question(_current_question)
	_keyboard.set_enabled(true)
	_feedback_label.text = ""
	_waiting_for_next = false
	_question_start_time = Time.get_unix_time_from_system()

	_update_ui()


func _on_digit_pressed(digit: int) -> void:
	if _waiting_for_next:
		return
	_question_display.append_digit(digit)


func _on_backspace_pressed() -> void:
	if _waiting_for_next:
		return
	_question_display.remove_last_digit()


func _on_confirm_pressed() -> void:
	if _waiting_for_next:
		return

	var answer: Variant = _question_display.get_answer()
	if answer == null:
		return  # puste pole — ignoruj

	_process_answer(int(answer))


func _process_answer(answer: int) -> void:
	_keyboard.set_enabled(false)
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

	# Przejdź do następnego pytania po 1.5 sekundy
	await get_tree().create_timer(1.5).timeout
	_show_next_question()


func _update_ui() -> void:
	_progress_label.text = "%d / %d" % [_state.get_total_asked(), _state.config.question_count]
	_score_label.text = "Punkty: %d" % _state.score


func _end_session() -> void:
	var result: SessionResult = SessionResult.from_state(_state)
	GameState.current_session_state = null
	EventBus.session_completed.emit(result)

	if OS.is_debug_build():
		print("[SessionController] Sesja zakończona. Wynik: %d%%" % result.get_accuracy_percent())

	SceneManager.go_to(Constants.SCENE_SUMMARY)
```

---

## Implementacja — ekrany UI

### `scripts/ui/main_menu.gd`

```gdscript
# scripts/ui/main_menu.gd
extends Control

@onready var _play_button: Button = $PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)

	if OS.is_debug_build():
		print("[MainMenu] Gotowy")


func _on_play_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)
```

---

### `scripts/ui/summary.gd`

```gdscript
# scripts/ui/summary.gd
extends Control

@onready var _result_label: Label = $ResultLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _accuracy_label: Label = $AccuracyLabel
@onready var _play_again_button: Button = $PlayAgainButton

var _result: SessionResult = null


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)

	# Odbierz wynik z EventBus (przekazany przez SessionController)
	EventBus.session_completed.connect(_on_session_completed)

	if OS.is_debug_build():
		print("[Summary] Gotowy")


func _on_session_completed(result: SessionResult) -> void:
	_result = result
	_update_ui()


func _update_ui() -> void:
	if _result == null:
		return
	_result_label.text = "%d / %d poprawnych" % [_result.correct_count, _result.total_questions]
	_score_label.text = "Punkty: %d" % _result.score
	_accuracy_label.text = "Dokładność: %d%%" % _result.get_accuracy_percent()


func _on_play_again_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)
```

---

## Instrukcja tworzenia scen w Godot Editorze

### Kolejność tworzenia

```
1. scenes/ui/main_menu.tscn
2. scenes/components/numeric_keyboard.tscn
3. scenes/components/question_display.tscn
4. scenes/gameplay/session.tscn
5. scenes/ui/summary.tscn
```

---

### 1. `main_menu.tscn`

- Root: `Control` (Full Rect) → rename `MainMenu`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `TitleLabel`, tekst `MathHero`, wyśrodkuj górna część
  - `Button` → `PlayButton`, tekst `Graj`, wyśrodkuj środek ekranu
- Skrypt: `res://scripts/ui/main_menu.gd`
- Zapisz: `res://scenes/ui/main_menu.tscn`

---

### 2. `numeric_keyboard.tscn`

- Root: `Control` → rename `NumericKeyboard`
- Dodaj `GridContainer` → `GridContainer`, Columns = 3
- Dodaj przyciski wewnątrz GridContainer (w kolejności):
  ```
  Digit7  Digit8  Digit9
  Digit4  Digit5  Digit6
  Digit1  Digit2  Digit3
  BackspaceButton  Digit0  ConfirmButton
  ```
  - Każdy przycisk cyfry: tekst = cyfra (np. `7`), min size `60x60`
  - `BackspaceButton`: tekst `⌫`
  - `ConfirmButton`: tekst `OK`
- Skrypt: `res://scripts/components/numeric_keyboard.gd`
- Zapisz: `res://scenes/components/numeric_keyboard.tscn`

---

### 3. `question_display.tscn`

- Root: `Control` → rename `QuestionDisplay`
- Dzieci:
  - `Label` → `QuestionLabel`, tekst `12 + 7 = ?`, duża czcionka (rozmiar 48+), wyśrodkuj
  - `Label` → `AnswerLabel`, tekst `_`, duża czcionka (rozmiar 48+), wyśrodkuj pod pytaniem
- Skrypt: `res://scripts/components/question_display.gd`
- Zapisz: `res://scenes/components/question_display.tscn`

---

### 4. `session.tscn`

- Root: `Control` (Full Rect) → rename `Session`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `ProgressLabel`, tekst `0 / 10`, prawy górny róg
  - `Label` → `ScoreLabel`, tekst `Punkty: 0`, lewy górny róg
  - instancja sceny `question_display.tscn` → `QuestionDisplay`, środek ekranu górna część
  - `Label` → `FeedbackLabel`, tekst pusty, pod QuestionDisplay, wyśrodkuj
  - instancja sceny `numeric_keyboard.tscn` → `NumericKeyboard`, dół ekranu wyśrodkowany
- Skrypt: `res://scripts/gameplay/session_controller.gd`
- Zapisz: `res://scenes/gameplay/session.tscn`

---

### 5. `summary.tscn`

- Root: `Control` (Full Rect) → rename `Summary`
- Dzieci:
  - `ColorRect` (Full Rect, kolor `#0a0a2e`)
  - `Label` → `ResultLabel`, tekst `- / -`, wyśrodkuj
  - `Label` → `ScoreLabel`, tekst `Punkty: -`, wyśrodkuj pod ResultLabel
  - `Label` → `AccuracyLabel`, tekst `Dokładność: -%`, wyśrodkuj
  - `Button` → `PlayAgainButton`, tekst `Zagraj ponownie`, wyśrodkuj dół
- Skrypt: `res://scripts/ui/summary.gd`
- Zapisz: `res://scenes/ui/summary.tscn`

---

## Aktualizacja splash_screen.gd

W `splash_screen.gd` zmień docelową scenę z `profile_select` na `main_menu` (profile dopiero w Epic 3):
```gdscript
# Zmień w _on_tap():
SceneManager.go_to(Constants.SCENE_MAIN_MENU)  # zawsze, bez sprawdzania profilu
```

---

## Kolejność implementacji

```
1. Napisz modele danych (question, session_config, session_state, session_result)
2. Napisz math_operation.gd + addition_operation.gd
3. Napisz komponenty (numeric_keyboard.gd, question_display.gd)
4. Napisz session_controller.gd
5. Napisz main_menu.gd + summary.gd
6. Zaktualizuj splash_screen.gd
7. Stwórz sceny w Godot Editorze (kolejność jak wyżej)
8. Przetestuj pełny flow: Splash → Menu → Sesja → Podsumowanie → Sesja
```

---

## Pliki do stworzenia przez Claude

| Plik | Status |
|---|---|
| `resources/models/question.gd` | ✅ Gotowy |
| `resources/models/session_config.gd` | ✅ Gotowy |
| `resources/models/session_state.gd` | ✅ Gotowy |
| `resources/models/session_result.gd` | ✅ Gotowy |
| `resources/math_operations/math_operation.gd` | ✅ Gotowy |
| `resources/math_operations/addition_operation.gd` | ✅ Gotowy |
| `scripts/components/numeric_keyboard.gd` | ✅ Gotowy |
| `scripts/components/question_display.gd` | ✅ Gotowy |
| `scripts/gameplay/session_controller.gd` | ✅ Gotowy |
| `scripts/ui/main_menu.gd` | ✅ Gotowy |
| `scripts/ui/summary.gd` | ✅ Gotowy |
| Sceny .tscn (5 sztuk) | ❌ Jarek tworzy w Godot Editorze |

---

_Tech-spec stworzony: 2026-03-22_
_Następny krok: Implementacja plików GDScript, potem sceny w Godot Editorze_
