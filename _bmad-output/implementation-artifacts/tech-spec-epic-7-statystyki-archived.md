---
title: 'Epic 7: Statystyki i Historia'
slug: 'epic-7-statystyki'
created: '2026-03-26'
status: 'in-progress'
stepsCompleted: [1, 2, 3]
tech_stack: ['GDScript', 'Godot 4.6', 'GDScript _draw() API']
files_to_modify:
  - MathHero/resources/models/player_profile.gd
  - MathHero/scripts/ui/summary.gd
  - MathHero/scenes/ui/summary.tscn
  - MathHero/scripts/ui/main_menu.gd
  - MathHero/scenes/ui/main_menu.tscn
files_to_create:
  - MathHero/scripts/ui/stats.gd
  - MathHero/scenes/ui/stats.tscn
code_patterns:
  - 'Typed arrays z JSON: for item in raw: typed_array.append(type(item))'
  - 'Custom drawing: Control._draw() + draw_line/draw_polyline'
  - 'Zapis profilu: ProfileSelect.load_profiles() → update → ProfileSelect.save_profiles()'
test_patterns: []
---

# Tech-Spec: Epic 7 — Statystyki i Historia

**Created:** 2026-03-26

## Overview

### Problem Statement

Gra nie przechowuje historii sesji ani rekordów per typ działania. Gracz nie ma wglądu w swoje postępy ani sugestii co do poziomu trudności.

### Solution

Dodać pole `session_history` do `PlayerProfile` (max 50 wpisów), ekran statystyk z historią + rekordami + wykresem dokładności, oraz sugestię trudności z przyciskiem "Zastosuj" na ekranie podsumowania.

### Scope

**W zakresie:**
- `session_history: Array[Dictionary]` w `PlayerProfile` — max 50 ostatnich sesji
- `operation_records: Dictionary` w `PlayerProfile` — najlepsza dokładność i wynik per typ działania
- Sugestia trudności na summary: tekst + przycisk "Zastosuj" (zmienia zakres min/max w konfiguracji)
- Ekran statystyk `stats.tscn`: rekordy per typ + wykres dokładności + lista historii
- Przycisk "📊 Statystyki" w main menu

**Poza zakresem:**
- Porównanie między profilami
- Eksport danych
- Statystyki per preset

---

## Context for Development

### Codebase Patterns

- **Autoloady**: `GameState`, `DataManager`, `SceneManager`, `Constants`, `EventBus` — bezpośredni dostęp bez `get_node`
- **Zapis profilu**: zawsze przez `ProfileSelect.load_profiles()` → modyfikuj → `ProfileSelect.save_profiles()` (patrz `summary.gd:_save_profile`)
- **Typed arrays z JSON**: NIE przypisuj `d.get("key", [])` bezpośrednio do `Array[String]` — iteruj i appenduj (patrz naprawiony `player_profile.gd:from_dict`)
- **Sceny**: para `.tscn` + `.gd`, węzły przez `@onready var _name: Type = $NodeName`
- **Nawigacja**: `SceneManager.go_to(Constants.SCENE_*)` — tylko przez SceneManager
- **Static typing**: obowiązkowe wszędzie, `var x: int`, `func f(a: String) -> void`

### Files to Reference

| Plik | Cel |
| ---- | --- |
| `resources/models/player_profile.gd` | Dodać session_history i operation_records |
| `scripts/ui/summary.gd` | Dodać zapis historii + sugestię trudności |
| `scenes/ui/summary.tscn` | Dodać DifficultyLabel + ApplyButton |
| `scripts/ui/main_menu.gd` | Dodać StatsButton |
| `scenes/ui/main_menu.tscn` | Dodać StatsButton node |
| `autoloads/constants.gd` | SCENE_STATS już istnieje jako "stats" |
| `resources/models/session_config.gd` | SessionConfig.from_dict — do tworzenia nowej konfiguracji w "Zastosuj" |

### Technical Decisions

1. **Format wpisu historii** — Dictionary z kluczami: `date` (String "YYYY-MM-DD"), `op` (String typ działania), `correct` (int), `total` (int), `accuracy` (int %), `score` (int), `duration` (float sekundy)

2. **operation_records** — Dictionary: klucz = typ działania (String), wartość = `{"best_accuracy": int, "best_score": int}`. Typy: `"addition"`, `"subtraction"`, `"multiplication"`, `"division"`, `"mixed"`, `"order_of_ops"`

3. **Sugestia trudności** — obliczana na podstawie `_result.get_accuracy()`:
   - `>= 0.8`: sugestia = nowy `max_value = min(current_max * 2, 1000)`, tekst "Świetnie! Spróbuj trudniejszego zakresu: 1–{nowy_max}"
   - `<= 0.4`: sugestia = nowy `max_value = max(current_max / 2, 10)`, tekst "Spróbuj łatwiejszego zakresu: 1–{nowy_max}"
   - Inaczej: brak sugestii

4. **Przycisk "Zastosuj"** — klonuje `GameState.current_session_config` (lub `profile.last_config`), ustawia nowy `max_value`, przypisuje do `GameState.current_session_config`

5. **Wykres** — niestandardowy węzeł `Control` z `_draw()`, rysuje dokładność ostatnich 20 sesji jako linię. Oś X = indeks sesji, oś Y = dokładność 0–100%. Używa `draw_polyline()`.

6. **Max historia** — przy dodaniu nowego wpisu: jeśli `session_history.size() >= 50`, usuń pierwszy element (`session_history.pop_front()`)

---

## Implementation Plan

### Tasks

Wykonuj w tej kolejności (zależności od dołu):

#### Zadanie 1 — `PlayerProfile`: nowe pola + serializacja

**Plik:** `MathHero/resources/models/player_profile.gd`

Dodaj dwa nowe pola po bloku "Progresja galaktyki (Epic 6)":

```gdscript
# Statystyki i Historia (Epic 7)
var session_history: Array[Dictionary] = []   # max 50 wpisów
var operation_records: Dictionary = {}         # { op_type: { best_accuracy: int, best_score: int } }
```

W `to_dict()` dodaj do zwracanego Dictionary:
```gdscript
"session_history": session_history,
"operation_records": operation_records,
```

W `from_dict()` dodaj (po linii z `best_session_score`):
```gdscript
for item: Variant in d.get("session_history", []):
    if item is Dictionary:
        p.session_history.append(item)
var raw_records: Variant = d.get("operation_records", {})
if raw_records is Dictionary:
    p.operation_records = raw_records
```

---

#### Zadanie 2 — `Summary`: zapis historii + rekordy + sugestia trudności

**Plik:** `MathHero/scripts/ui/summary.gd`

**2a. Nowe @onready (dodaj po `_beat_record_button`):**
```gdscript
@onready var _difficulty_label: Label = $DifficultyLabel
@onready var _apply_difficulty_button: Button = $ApplyDifficultyButton
```

**2b. W `_ready()` dodaj po `_beat_record_button.visible = false`:**
```gdscript
_difficulty_label.visible = false
_apply_difficulty_button.visible = false
_apply_difficulty_button.pressed.connect(_on_apply_difficulty_pressed)
```

**2c. Nowa zmienna na poziomie klasy:**
```gdscript
var _suggested_max: int = 0
```

**2d. W `_process_rewards()`, zaraz przed `_save_profile(profile)`:**
```gdscript
_record_session_history(profile)
_update_operation_records(profile)
```

**2e. Nowe prywatne metody (dodaj po `_save_profile`):**

```gdscript
func _record_session_history(profile: PlayerProfile) -> void:
    if _result == null:
        return
    var entry: Dictionary = {
        "date": Time.get_date_string_from_system(),
        "op": _result.config.operation_type if _result.config != null else "unknown",
        "correct": _result.correct_count,
        "total": _result.total_questions,
        "accuracy": _result.get_accuracy_percent(),
        "score": _result.score,
        "duration": _result.duration_seconds,
    }
    profile.session_history.append(entry)
    if profile.session_history.size() > 50:
        profile.session_history.pop_front()


func _update_operation_records(profile: PlayerProfile) -> void:
    if _result == null or _result.config == null:
        return
    var op: String = _result.config.operation_type
    var acc: int = _result.get_accuracy_percent()
    var score: int = _result.score
    if not profile.operation_records.has(op):
        profile.operation_records[op] = {"best_accuracy": 0, "best_score": 0}
    var rec: Dictionary = profile.operation_records[op]
    if acc > int(rec.get("best_accuracy", 0)):
        rec["best_accuracy"] = acc
    if score > int(rec.get("best_score", 0)):
        rec["best_score"] = score


func _on_apply_difficulty_pressed() -> void:
    if _result == null or _result.config == null or _suggested_max <= 0:
        return
    var new_config: SessionConfig = SessionConfig.from_dict(_result.config.to_dict())
    new_config.max_value = _suggested_max
    GameState.current_session_config = new_config
    SceneManager.go_to(Constants.SCENE_SESSION)
```

**2f. W `_update_ui()`, na końcu metody, dodaj:**
```gdscript
_show_difficulty_suggestion()
```

**2g. Nowa metoda `_show_difficulty_suggestion()`:**
```gdscript
func _show_difficulty_suggestion() -> void:
    if _result == null or _result.config == null:
        return
    var accuracy: float = _result.get_accuracy()
    var current_max: int = _result.config.max_value
    if accuracy >= 0.8:
        _suggested_max = min(current_max * 2, 1000)
        _difficulty_label.text = "💪 Świetnie! Spróbuj trudniejszego zakresu: 1–%d" % _suggested_max
        _difficulty_label.visible = true
        _apply_difficulty_button.visible = true
    elif accuracy <= 0.4:
        _suggested_max = max(current_max / 2, 10)
        _difficulty_label.text = "💡 Spróbuj łatwiejszego zakresu: 1–%d" % _suggested_max
        _difficulty_label.visible = true
        _apply_difficulty_button.visible = true
```

---

#### Zadanie 3 — `summary.tscn`: nowe węzły

**Plik:** `MathHero/scenes/ui/summary.tscn`

Dodaj dwa węzły po `BeatRecordButton` (przed `RewardPopup`):

```
[node name="DifficultyLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 10
anchor_right = 1.0
offset_top = 700.0
offset_bottom = 740.0
grow_horizontal = 2
horizontal_alignment = 1
autowrap_mode = 3
text = ""
theme_override_font_sizes/font_size = 16
visible = false

[node name="ApplyDifficultyButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -130.0
offset_top = -300.0
offset_right = 130.0
offset_bottom = -260.0
grow_horizontal = 2
grow_vertical = 0
text = "✅ Zastosuj"
theme_override_font_sizes/font_size = 16
visible = false
```

---

#### Zadanie 4 — `main_menu.gd`: dodaj przycisk Statystyki

**Plik:** `MathHero/scripts/ui/main_menu.gd`

Dodaj `@onready`:
```gdscript
@onready var _stats_button: Button = $StatsButton
```

W `_ready()` dodaj:
```gdscript
_stats_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_STATS))
```

---

#### Zadanie 5 — `main_menu.tscn`: dodaj StatsButton

**Plik:** `MathHero/scenes/ui/main_menu.tscn`

Dodaj węzeł po `GalaxyButton`:
```
[node name="StatsButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -80.0
offset_top = 210.0
offset_right = 80.0
offset_bottom = 270.0
grow_horizontal = 2
grow_vertical = 2
text = "📊 Statystyki"
theme_override_font_sizes/font_size = 20
```

---

#### Zadanie 6 — `stats.gd`: nowy ekran statystyk

**Plik:** `MathHero/scripts/ui/stats.gd` (NOWY)

```gdscript
# scripts/ui/stats.gd
extends Control

@onready var _back_button: Button = $BackButton
@onready var _records_container: VBoxContainer = $ScrollContainer/VBox/RecordsContainer
@onready var _chart: Control = $ScrollContainer/VBox/Chart
@onready var _history_container: VBoxContainer = $ScrollContainer/VBox/HistoryContainer

var _history: Array[Dictionary] = []


func _ready() -> void:
    _back_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_MAIN_MENU))
    _build_ui()
    if OS.is_debug_build():
        print("[Stats] Gotowy")


func _build_ui() -> void:
    if not GameState.has_active_profile():
        return
    var profile: PlayerProfile = GameState.current_profile
    _history = profile.session_history
    _build_records(profile)
    _chart.queue_redraw()
    _build_history()


func _build_records(profile: PlayerProfile) -> void:
    for child: Node in _records_container.get_children():
        child.queue_free()

    var op_labels: Dictionary = {
        "addition": "Dodawanie",
        "subtraction": "Odejmowanie",
        "multiplication": "Mnożenie",
        "division": "Dzielenie",
        "mixed": "Mieszane",
        "order_of_ops": "Kolejność działań",
    }

    var title: Label = Label.new()
    title.text = "🏅 Rekordy osobiste"
    title.add_theme_font_size_override("font_size", 20)
    _records_container.add_child(title)

    for op: String in op_labels.keys():
        if not profile.operation_records.has(op):
            continue
        var rec: Dictionary = profile.operation_records[op]
        var row: Label = Label.new()
        row.text = "%s — Dokładność: %d%% | Wynik: %d pkt" % [
            op_labels.get(op, op),
            int(rec.get("best_accuracy", 0)),
            int(rec.get("best_score", 0)),
        ]
        row.add_theme_font_size_override("font_size", 16)
        _records_container.add_child(row)


func _build_history() -> void:
    for child: Node in _history_container.get_children():
        child.queue_free()

    var title: Label = Label.new()
    title.text = "📋 Historia sesji (ostatnie %d)" % _history.size()
    title.add_theme_font_size_override("font_size", 20)
    _history_container.add_child(title)

    var start: int = max(0, _history.size() - 50)
    for i: int in range(_history.size() - 1, start - 1, -1):
        var entry: Dictionary = _history[i]
        var row: Label = Label.new()
        row.text = "%s | %s | %d/%d (%d%%) | %d pkt | %.0fs" % [
            str(entry.get("date", "—")),
            str(entry.get("op", "—")),
            int(entry.get("correct", 0)),
            int(entry.get("total", 0)),
            int(entry.get("accuracy", 0)),
            int(entry.get("score", 0)),
            float(entry.get("duration", 0.0)),
        ]
        row.add_theme_font_size_override("font_size", 14)
        _history_container.add_child(row)
```

Dodatkowo podłącz `_draw()` do węzła Chart przez osobny skrypt `chart.gd`:

**Plik:** `MathHero/scripts/components/accuracy_chart.gd` (NOWY)

```gdscript
# scripts/components/accuracy_chart.gd
extends Control

var data: Array[int] = []   # wartości dokładności 0–100


func _draw() -> void:
    if data.size() < 2:
        return
    var w: float = size.x
    var h: float = size.y
    var padding: float = 10.0
    var inner_w: float = w - padding * 2.0
    var inner_h: float = h - padding * 2.0

    # Tło
    draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.05, 0.15))

    # Linie pomocnicze: 0%, 50%, 100%
    for pct: int in [0, 50, 100]:
        var y: float = padding + inner_h * (1.0 - float(pct) / 100.0)
        draw_line(Vector2(padding, y), Vector2(w - padding, y), Color(0.3, 0.3, 0.3), 1.0)

    # Wykres
    var points: PackedVector2Array = PackedVector2Array()
    var count: int = data.size()
    for i: int in count:
        var x: float = padding + float(i) / float(count - 1) * inner_w
        var y: float = padding + inner_h * (1.0 - float(data[i]) / 100.0)
        points.append(Vector2(x, y))

    draw_polyline(points, Color(0.2, 0.8, 1.0), 2.0)

    # Punkty
    for pt: Vector2 in points:
        draw_circle(pt, 4.0, Color(0.2, 0.8, 1.0))
```

W `stats.gd` metoda `_build_ui()` — przed `_chart.queue_redraw()` dodaj:
```gdscript
# Przygotuj dane wykresu (ostatnie 20 sesji)
if _chart.has_method("_draw") and _chart.get_script() != null:
    var chart_data: Array[int] = []
    var start_idx: int = max(0, _history.size() - 20)
    for i: int in range(start_idx, _history.size()):
        chart_data.append(int(_history[i].get("accuracy", 0)))
    _chart.data = chart_data
```

---

#### Zadanie 7 — `stats.tscn`: nowa scena

**Plik:** `MathHero/scenes/ui/stats.tscn` (NOWY)

Struktura sceny:

```
Stats (Control) [script: stats.gd]
├── ColorRect (background, kolor 0.039, 0.039, 0.18, 1)
├── BackButton (Button, anchors top-left, offset: left=-80 top=10 right=80 bottom=50, text="← Wstecz")
├── TitleLabel (Label, anchors top-center, offset_top=10 bottom=50, text="📊 Statystyki", font_size=24, h_align=center)
└── ScrollContainer (anchors full rect, offset_top=70)
    └── VBox (VBoxContainer, size_flags_horizontal=EXPAND_FILL)
        ├── RecordsContainer (VBoxContainer)
        ├── Chart (Control) [script: accuracy_chart.gd]
        │   custom_minimum_size = Vector2(0, 200)
        └── HistoryContainer (VBoxContainer)
```

**Szczegóły węzłów ScrollContainer i VBox:**
```
[node name="ScrollContainer" type="ScrollContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_top = 70.0
grow_horizontal = 2
grow_vertical = 2

[node name="VBox" type="VBoxContainer" parent="ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 16
```

---

### Acceptance Criteria

**AC1 — Historia sesji zapisywana:**
- Given: gracz kończy sesję
- When: wyświetla się summary
- Then: do `profile.session_history` dodany jest wpis z datą, typem działań, dokładnością, punktami i czasem; jeśli historia ma > 50 wpisów, najstarszy jest usunięty

**AC2 — Rekordy aktualizowane:**
- Given: gracz kończy sesję z dokładnością X i wynikiem Y dla operacji Z
- When: summary przetwarza nagrody
- Then: `profile.operation_records["Z"]["best_accuracy"]` = max(poprzedni, X); `best_score` = max(poprzedni, Y)

**AC3 — Sugestia trudniejsza:**
- Given: gracz uzyska dokładność >= 80% na sesji z max_value=100
- When: wyświetla się summary
- Then: widać tekst "💪 Świetnie! Spróbuj trudniejszego zakresu: 1–200" i przycisk "✅ Zastosuj"

**AC4 — Sugestia łatwiejsza:**
- Given: gracz uzyska dokładność <= 40% na sesji z max_value=100
- When: wyświetla się summary
- Then: widać tekst "💡 Spróbuj łatwiejszego zakresu: 1–50" i przycisk "✅ Zastosuj"

**AC5 — Przycisk Zastosuj:**
- Given: widoczny przycisk "✅ Zastosuj" na summary
- When: gracz klika Zastosuj
- Then: uruchamia się nowa sesja z tym samym typem działań ale zmienionym max_value

**AC6 — Brak sugestii przy dokładności 41–79%:**
- Given: gracz uzyska dokładność 60%
- When: wyświetla się summary
- Then: DifficultyLabel i ApplyDifficultyButton są niewidoczne

**AC7 — Ekran statystyk dostępny z menu:**
- Given: gracz jest w głównym menu
- When: klika "📊 Statystyki"
- Then: otwiera się ekran stats z rekordami, wykresem i historią

**AC8 — Wykres poprawny:**
- Given: profil ma >= 2 sesje w historii
- When: otwiera się ekran statystyk
- Then: widoczny wykres z niebieską linią pokazującą dokładność w kolejnych sesjach

**AC9 — Historia posortowana od najnowszej:**
- Given: profil ma kilka sesji w historii
- When: otwiera się ekran statystyk
- Then: najnowsza sesja jest pierwsza na liście

**AC10 — Dane persystowane:**
- Given: gracz kończy sesję i zamyka grę
- When: ponownie otwiera grę i wchodzi do statystyk
- Then: historia sesji i rekordy są zachowane

---

## Additional Context

### Dependencies

- `PlayerProfile` musi mieć nowe pola przed implementacją `Summary` i `Stats`
- `summary.tscn` musi mieć węzły `DifficultyLabel` i `ApplyDifficultyButton` przed zmianami w `summary.gd`
- `accuracy_chart.gd` musi być utworzony przed `stats.tscn` (Chart node potrzebuje skryptu)
- `stats.tscn` musi być zarejestrowana jako `"stats"` w `SceneManager.SCENES` — **już jest** (`Constants.SCENE_STATS = "stats"`, `SceneManager.SCENES` ma `Constants.SCENE_STATS: "res://scenes/ui/stats.tscn"`)

### Testing Strategy

Po implementacji przetestuj ręcznie:
1. Zagraj sesję z dokładnością >= 80% → sprawdź sugestię i kliknij Zastosuj
2. Zagraj sesję z dokładnością <= 40% → sprawdź sugestię łatwiejszą
3. Wejdź do Statystyk → sprawdź czy rekordy i historia są widoczne
4. Zamknij i otwórz grę → sprawdź czy historia przeżyła restart
5. Zagraj 51 sesji (lub edytuj plik) → sprawdź czy historia nie przekracza 50

### Notes

- `SessionResult.config` może być `null` jeśli sesja skończyła się błędem — zawsze sprawdzaj `_result.config != null`
- JSON parsuje liczby jako `float` — zawsze konwertuj przez `int()` przy odczycie z Dictionary
- Wykres używa `queue_redraw()` — wywołaj go po ustawieniu `data`
- `pop_front()` na `Array[Dictionary]` działa w GDScript 4
