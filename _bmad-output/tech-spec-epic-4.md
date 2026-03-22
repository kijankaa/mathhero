# Tech-Spec: Epic 4 — Wszystkie Działania Fazy 1

**Projekt:** MathHero
**Epic:** 4 — Wszystkie Działania Fazy 1
**Data:** 2026-03-22
**Zależność:** Epic 3 ✅

---

## Cel

Dodać 4 nowe typy działań (odejmowanie, mnożenie, dzielenie, kolejność działań), tryb sesji mieszanej oraz rozszerzyć panel konfiguracji o wybór operacji.

---

## Stories i Acceptance Criteria

| Story | AC |
|---|---|
| S1: Odejmowanie | Widzę `a - b = ?`, wynik zawsze ≥ 0 |
| S2: Mnożenie | Widzę `a × b = ?` |
| S3: Dzielenie | Widzę `a ÷ b = ?`, wynik zawsze całkowity |
| S4: Kolejność działań | Widzę `a + b × c = ?` lub `(a + b) × c = ?` |
| S5: Sesja mieszana | Pytania losują operację z wybranych typów |
| S6: Wybór operacji w config | Mogę wybrać typ lub zaznaczyć kilka do mieszanej |
| S7: Tryb nawiasów | Mogę wybrać: bez/z/mieszane nawiasy dla kolejności działań |
| S8: Auto-zakres | Po zmianie operacji zakres automatycznie się aktualizuje |

---

## Pliki do stworzenia/zmiany

### Nowe skrypty (Claude pisze)

| Plik | Opis |
|---|---|
| `resources/math_operations/subtraction_operation.gd` | Odejmowanie |
| `resources/math_operations/multiplication_operation.gd` | Mnożenie |
| `resources/math_operations/division_operation.gd` | Dzielenie (wynik całkowity) |
| `resources/math_operations/order_of_operations_operation.gd` | Kolejność działań |

### Zmodyfikowane skrypty (Claude pisze)

| Plik | Co się zmienia |
|---|---|
| `resources/models/session_config.gd` | Nowe pola: `mixed_operations`, `order_of_ops_parentheses` + serializacja |
| `autoloads/constants.gd` | Stałe dla typów operacji + domyślne zakresy |
| `scripts/gameplay/session_controller.gd` | `_resolve_operation()`, obsługa mixed mode |
| `scripts/components/question_display.gd` | Format kolumnowy tylko dla 2-argumentowych działań |
| `scripts/ui/session_config.gd` | UI wyboru operacji, checkboxy mixed, opcja nawiasów, auto-zakres |

### Brak nowych scen
Wszystkie zmiany UI trafiają do istniejącej `session_config.tscn` — Jarek modyfikuje ją w Godot Editorze.

---

## Implementacja — nowe operacje

### `resources/math_operations/subtraction_operation.gd`

```gdscript
# resources/math_operations/subtraction_operation.gd
class_name SubtractionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	# Zawsze a >= b, żeby wynik był ≥ 0
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, a)
	var answer: int = a - b
	var display: String = "%d - %d = ?" % [a, b]
	return Question.create(a, b, "subtraction", answer, display)
```

---

### `resources/math_operations/multiplication_operation.gd`

```gdscript
# resources/math_operations/multiplication_operation.gd
class_name MultiplicationOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var answer: int = a * b
	var display: String = "%d × %d = ?" % [a, b]
	return Question.create(a, b, "multiplication", answer, display)
```

---

### `resources/math_operations/division_operation.gd`

```gdscript
# resources/math_operations/division_operation.gd
# Generuje dzielenie z gwarancją wyniku całkowitego.
# Strategia: losuj wynik (c) i dzielnik (b), oblicz a = b * c.
class_name DivisionOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var c: int = _rand_in_range(config.min_value, config.max_value)
	var a: int = b * c
	var answer: int = c
	var display: String = "%d ÷ %d = ?" % [a, b]
	return Question.create(a, b, "division", answer, display)
```

---

### `resources/math_operations/order_of_operations_operation.gd`

```gdscript
# resources/math_operations/order_of_operations_operation.gd
# Generuje wyrażenia 3-argumentowe z kolejnością działań.
# Tryby nawiasów: "none", "always", "mixed" (losowo jeden z dwóch).
class_name OrderOfOperationsOperation
extends MathOperation


func generate_question(config: SessionConfig) -> Question:
	var a: int = _rand_in_range(config.min_value, config.max_value)
	var b: int = _rand_in_range(config.min_value, config.max_value)
	var c: int = _rand_in_range(config.min_value, config.max_value)

	var use_parentheses: bool = _should_use_parentheses(config.order_of_ops_parentheses)

	var answer: int
	var display: String

	if use_parentheses:
		# (a + b) × c — nawiasy wymuszają dodawanie przed mnożeniem
		answer = (a + b) * c
		display = "(%d + %d) × %d = ?" % [a, b, c]
	else:
		# a + b × c — standardowa kolejność (mnożenie pierwsze)
		answer = a + b * c
		display = "%d + %d × %d = ?" % [a, b, c]

	return Question.create(a, b, "order_of_operations", answer, display)


func _should_use_parentheses(mode: String) -> bool:
	match mode:
		"always":
			return true
		"mixed":
			return randi() % 2 == 0
		_:  # "none"
			return false
```

---

## Implementacja — zmiany w SessionConfig

### Nowe pola (dopisz po `question_format`):

```gdscript
# Sesja mieszana — lista operacji do losowania
var mixed_operations: Array[String] = []  # puste = nie mieszana

# Tryb nawiasów dla kolejności działań: "none", "always", "mixed"
var order_of_ops_parentheses: String = "none"
```

### Aktualizacja `to_dict()` — dopisz:

```gdscript
"mixed_operations": mixed_operations,
"order_of_ops_parentheses": order_of_ops_parentheses,
```

### Aktualizacja `from_dict()` — dopisz:

```gdscript
c.mixed_operations = d.get("mixed_operations", [])
c.order_of_ops_parentheses = d.get("order_of_ops_parentheses", "none")
```

---

## Implementacja — Constants

### Dopisz do `autoloads/constants.gd`:

```gdscript
# Typy operacji matematycznych
const OP_ADDITION: String = "addition"
const OP_SUBTRACTION: String = "subtraction"
const OP_MULTIPLICATION: String = "multiplication"
const OP_DIVISION: String = "division"
const OP_ORDER_OF_OPERATIONS: String = "order_of_operations"

# Domyślne zakresy per operacja (do auto-sugestii w UI)
const OP_DEFAULT_RANGES: Dictionary = {
	"addition":           {"min": 1, "max": 100},
	"subtraction":        {"min": 1, "max": 100},
	"multiplication":     {"min": 1, "max": 12},
	"division":           {"min": 1, "max": 12},
	"order_of_operations":{"min": 1, "max": 20},
	"mixed":              {"min": 1, "max": 20},
}
```

---

## Implementacja — SessionController

### Zastąp całą metodę `_start_session()`:

```gdscript
func _start_session() -> void:
	var config: SessionConfig = GameState.current_session_config
	if config == null:
		config = SessionConfig.create_default()

	var questions: Array[Question] = []
	var is_mixed: bool = not config.mixed_operations.is_empty()

	for i in config.question_count:
		var op_type: String
		if is_mixed:
			op_type = config.mixed_operations[randi() % config.mixed_operations.size()]
		else:
			op_type = config.operation_type

		var operation: MathOperation = _resolve_operation(op_type, config)
		questions.append(operation.generate_question(config))

	_state = SessionState.create(config, questions)
	GameState.current_session_state = _state

	_question_display.set_format(config.question_format)

	if config.answer_mode == "multiple_choice":
		_keyboard.visible = false
		_multiple_choice.visible = true
	else:
		_keyboard.visible = true
		_multiple_choice.visible = false

	_show_next_question()
```

### Dodaj nową metodę `_resolve_operation()`:

```gdscript
## Zwraca instancję MathOperation dla podanego typu.
func _resolve_operation(op_type: String, config: SessionConfig) -> MathOperation:
	match op_type:
		Constants.OP_SUBTRACTION:
			return SubtractionOperation.new()
		Constants.OP_MULTIPLICATION:
			return MultiplicationOperation.new()
		Constants.OP_DIVISION:
			return DivisionOperation.new()
		Constants.OP_ORDER_OF_OPERATIONS:
			return OrderOfOperationsOperation.new()
		_:  # addition i fallback
			return AdditionOperation.new()
```

---

## Implementacja — QuestionDisplay

### Zaktualizuj `show_question()` — format kolumnowy tylko dla 2-argumentowych działań:

```gdscript
func show_question(question: Question) -> void:
	var two_arg_ops: Array[String] = ["addition", "subtraction", "multiplication", "division"]
	if _format == "vertical" and question.operation in two_arg_ops:
		var op_symbol: String = _get_op_symbol(question.operation)
		_question_label.text = "  %d\n%s %d\n───" % [question.operand_a, op_symbol, question.operand_b]
	else:
		_question_label.text = question.display_text
	_current_answer = ""
	_answer_label.text = "_"
	_answer_label.modulate = Color.WHITE


func _get_op_symbol(operation: String) -> String:
	match operation:
		"subtraction": return "-"
		"multiplication": return "×"
		"division": return "÷"
		_: return "+"
```

---

## Implementacja — SessionConfig UI

### Nowe pola w `session_config.gd`

Dopisz @onready (zakładając nowe węzły w scenie):

```gdscript
@onready var _operation_button: OptionButton = $ConfigPanel/OperationRow/OperationButton
@onready var _mixed_container: VBoxContainer = $ConfigPanel/MixedContainer
@onready var _mixed_addition: CheckBox = $ConfigPanel/MixedContainer/MixedAddition
@onready var _mixed_subtraction: CheckBox = $ConfigPanel/MixedContainer/MixedSubtraction
@onready var _mixed_multiplication: CheckBox = $ConfigPanel/MixedContainer/MixedMultiplication
@onready var _mixed_division: CheckBox = $ConfigPanel/MixedContainer/MixedDivision
@onready var _mixed_order: CheckBox = $ConfigPanel/MixedContainer/MixedOrder
@onready var _parentheses_row: HBoxContainer = $ConfigPanel/ParenthesesRow
@onready var _parentheses_button: OptionButton = $ConfigPanel/ParenthesesRow/ParenthesesButton
```

### Inicjalizacja w `_ready()` — dopisz po istniejących `add_item`:

```gdscript
	_operation_button.add_item("Dodawanie")
	_operation_button.add_item("Odejmowanie")
	_operation_button.add_item("Mnożenie")
	_operation_button.add_item("Dzielenie")
	_operation_button.add_item("Kolejność działań")
	_operation_button.add_item("Mieszane")
	_operation_button.item_selected.connect(_on_operation_changed)

	_parentheses_button.add_item("Bez nawiasów")
	_parentheses_button.add_item("Z nawiasami")
	_parentheses_button.add_item("Mieszane")
```

### Nowe metody do dopisania w `session_config.gd`:

```gdscript
const _OP_INDEX_MAP: Array[String] = [
	"addition", "subtraction", "multiplication", "division",
	"order_of_operations", "mixed"
]

const _OP_DEFAULT_RANGES: Dictionary = {
	"addition":            {"min": 1, "max": 100},
	"subtraction":         {"min": 1, "max": 100},
	"multiplication":      {"min": 1, "max": 12},
	"division":            {"min": 1, "max": 12},
	"order_of_operations": {"min": 1, "max": 20},
	"mixed":               {"min": 1, "max": 20},
}


func _on_operation_changed(index: int) -> void:
	var op: String = _OP_INDEX_MAP[index]
	var is_mixed: bool = op == "mixed"
	var is_order: bool = op == "order_of_operations"

	_mixed_container.visible = is_mixed
	_parentheses_row.visible = is_order or (is_mixed and _mixed_order.button_pressed)

	# Auto-aktualizacja zakresu
	var range_def: Dictionary = _OP_DEFAULT_RANGES.get(op, {"min": 1, "max": 100})
	_min_value_input.value = range_def["min"]
	_max_value_input.value = range_def["max"]


func _get_operation_index(op_type: String) -> int:
	var idx: int = _OP_INDEX_MAP.find(op_type)
	return idx if idx >= 0 else 0
```

### Zaktualizuj `_apply_config_to_ui()` — dopisz/zamień sekcję operacji:

```gdscript
	# Operacja
	var is_mixed: bool = not config.mixed_operations.is_empty()
	if is_mixed:
		_operation_button.selected = _OP_INDEX_MAP.find("mixed")
		_mixed_container.visible = true
		_mixed_addition.button_pressed = "addition" in config.mixed_operations
		_mixed_subtraction.button_pressed = "subtraction" in config.mixed_operations
		_mixed_multiplication.button_pressed = "multiplication" in config.mixed_operations
		_mixed_division.button_pressed = "division" in config.mixed_operations
		_mixed_order.button_pressed = "order_of_operations" in config.mixed_operations
	else:
		_operation_button.selected = _get_operation_index(config.operation_type)
		_mixed_container.visible = false

	var show_parentheses: bool = config.operation_type == "order_of_operations" or \
		(is_mixed and "order_of_operations" in config.mixed_operations)
	_parentheses_row.visible = show_parentheses
	match config.order_of_ops_parentheses:
		"always": _parentheses_button.selected = 1
		"mixed":  _parentheses_button.selected = 2
		_:        _parentheses_button.selected = 0
```

### Zaktualizuj `_read_config_from_ui()` — dopisz/zamień sekcję operacji:

```gdscript
	var op_index: int = _operation_button.selected
	var op: String = _OP_INDEX_MAP[op_index]

	if op == "mixed":
		c.operation_type = "mixed"
		c.mixed_operations = []
		if _mixed_addition.button_pressed:    c.mixed_operations.append("addition")
		if _mixed_subtraction.button_pressed: c.mixed_operations.append("subtraction")
		if _mixed_multiplication.button_pressed: c.mixed_operations.append("multiplication")
		if _mixed_division.button_pressed:    c.mixed_operations.append("division")
		if _mixed_order.button_pressed:       c.mixed_operations.append("order_of_operations")
	else:
		c.operation_type = op
		c.mixed_operations = []

	match _parentheses_button.selected:
		1: c.order_of_ops_parentheses = "always"
		2: c.order_of_ops_parentheses = "mixed"
		_: c.order_of_ops_parentheses = "none"
```

### Zaktualizuj `_validate_config()` — dopisz sprawdzenie dla mixed:

```gdscript
	if c.operation_type == "mixed" and c.mixed_operations.is_empty():
		return "Wybierz co najmniej jedną operację do mieszanej sesji"
```

---

## Instrukcja modyfikacji sceny w Godot Editorze

### `scenes/ui/session_config.tscn` — zmiany

W `ConfigPanel` (VBoxContainer) dodaj **przed** `QuestionCountRow`:

```
OperationRow (HBoxContainer)
  ├── Label "Operacja:" (min_size 200px)
  └── OptionButton → OperationButton (min_size 220px)

MixedContainer (VBoxContainer) [visible=false]
  ├── CheckBox → MixedAddition,      tekst "Dodawanie"
  ├── CheckBox → MixedSubtraction,   tekst "Odejmowanie"
  ├── CheckBox → MixedMultiplication,tekst "Mnożenie"
  ├── CheckBox → MixedDivision,      tekst "Dzielenie"
  └── CheckBox → MixedOrder,         tekst "Kolejność działań"

ParenthesesRow (HBoxContainer) [visible=false]
  ├── Label "Nawiasy:" (min_size 200px)
  └── OptionButton → ParenthesesButton (min_size 220px)
```

---

## Kolejność implementacji

```
1. subtraction_operation.gd
2. multiplication_operation.gd
3. division_operation.gd
4. order_of_operations_operation.gd
5. session_config.gd (nowe pola) + to_dict/from_dict
6. constants.gd (stałe operacji)
7. session_controller.gd (_resolve_operation, nowy _start_session)
8. question_display.gd (kolumna dla wszystkich operacji + _get_op_symbol)
9. session_config.gd (UI — nowe @onready + metody)
10. Modyfikacja session_config.tscn w Godot Editorze
11. Test każdej operacji osobno, potem sesja mieszana
```

---

## Pliki do stworzenia/zmiany przez Claude

| Plik | Status |
|---|---|
| `resources/math_operations/subtraction_operation.gd` | ❌ |
| `resources/math_operations/multiplication_operation.gd` | ❌ |
| `resources/math_operations/division_operation.gd` | ❌ |
| `resources/math_operations/order_of_operations_operation.gd` | ❌ |
| `resources/models/session_config.gd` (rozszerzenie) | ❌ |
| `autoloads/constants.gd` (stałe) | ❌ |
| `scripts/gameplay/session_controller.gd` (zmiana) | ❌ |
| `scripts/components/question_display.gd` (zmiana) | ❌ |
| `scripts/ui/session_config.gd` (zmiana) | ❌ |
| `session_config.tscn` (nowe węzły) | ❌ Jarek w Godot |

---

_Tech-spec stworzony: 2026-03-22_
