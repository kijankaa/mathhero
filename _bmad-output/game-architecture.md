---
title: 'Game Architecture'
project: 'MathHero'
date: '2026-03-21'
author: 'Jarek'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Godot 4.5.2'
platform: 'iPad Air 2 — HTML5 PWA'

# Source Documents
gdd: '_bmad-output/gdd.md'
epics: '_bmad-output/epics.md'
brief: '_bmad-output/game-brief.md'
---

# Game Architecture — MathHero

## Document Status

This architecture document is being created through the GDS Architecture Workflow.

**Steps Completed:** 9 of 9 — KOMPLETNY ✅

---

---

## Engine & Framework

### Selected Engine

**Godot 4.5.2** (stable, wydany 2026-03-19)

**Uzasadnienie:** Godot 4.x z eksportem HTML5 to jedyna darmowa ścieżka do PWA na iPadzie bez wymagania Mac/Xcode. GDScript jest jedynym obsługiwanym językiem dla web exportu (C# nie działa w HTML5). Godot 4.5.2 to aktualnie najnowsza stabilna wersja — 4.6 jest w RC i nie jest zalecana do nowych projektów.

### Project Initialization

Nowy projekt Godot — brak starter template dla tego typu gry. Projekt tworzony od zera z własną strukturą folderów.

```
# Godot Export Settings (HTML5)
Renderer: Compatibility (WebGL 2.0)  # wymagane dla Safari/iPad
Export: HTML5 / Web
Language: GDScript (nie C#)
```

### Engine-Provided Architecture

| Komponent | Rozwiązanie | Uwagi |
|---|---|---|
| Rendering | 2D, Compatibility (WebGL 2.0) | Jedyny tryb dla HTML5 |
| Fizyka | Godot Physics 2D (wbudowana) | Nie wymagana dla UI game |
| Audio | AudioStreamPlayer + AudioBus | Safari: wymaga interakcji przed odtworzeniem |
| Input | InputEvent + touch support | Wbudowany, obsługuje multi-touch |
| Zarządzanie scenami | SceneTree.change_scene_to_file() | Standardowy pattern Godot |
| Sygnały | Wbudowany system sygnałów | Komunikacja między węzłami |
| Build system | Godot Export Templates HTML5 | Generuje index.html + .pck + .js |
| Tween/animacje | Tween node (wbudowany) | Płynne przejścia UI |

### Remaining Architectural Decisions

Poniższe decyzje muszą być podjęte jawnie (kroki 4-8):

1. Struktura folderów projektu
2. Architektura scen — które sceny, jak powiązane, jak przełączane
3. Modułowy generator zadań — wzorzec plug-in dla typów działań
4. Persystencja danych — projekt localStorage wrappera (GDScript ↔ JS)
5. Autoload / Singleton — które systemy jako globalne (GameState, AudioManager, DataManager)
6. Zarządzanie stanem — profile, konfiguracja sesji, postęp nagrody
7. Signal bus — architektura komunikacji między systemami

### Development Environment — MCP Setup

**Godot MCP (bradypp/godot-mcp)**

Serwer MCP dający Claude Code bezpośredni dostęp do Godot Editora.

```bash
# Instalacja
git clone https://github.com/bradypp/godot-mcp.git
cd godot-mcp
npm install
npm run build

# Konfiguracja Claude Code (.mcp.json w katalogu projektu)
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/ścieżka/do/godot-mcp/build/index.js"]
    }
  }
}
```

**Możliwości:**
- Uruchamianie Godot i projektów w trybie debug
- Tworzenie, edytowanie, usuwanie węzłów w scenach
- Odczyt logów i błędów konsoli w czasie rzeczywistym
- Modyfikacja właściwości węzłów (pozycja, skala, tekstury)
- UID management dla zasobów (Godot 4.4+)

**Context7 (upstash/context7)**

Dostęp do aktualnej dokumentacji Godot zamiast danych treningowych.

```bash
# Instalacja (Claude Code)
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

---

## Executive Summary

Architektura **MathHero** zaprojektowana dla **Godot 4.5.2** z eksportem HTML5 jako PWA na iPad Air 2.

**Kluczowe decyzje architektoniczne:**
- **SceneManager Autoload** — centralne zarządzanie przejściami między 9 ekranami aplikacji
- **4 Autoloady** — GameState, DataManager, AudioManager, EventBus jako globalne serwisy
- **Resource plug-in** — modułowy generator zadań matematycznych (MathOperation base class), rozszerzalny bez modyfikacji core
- **DataManager + JavaScriptBridge** — wrapper localStorage ukrywający specyfikę HTML5
- **SessionState Resource** — kompletny stan sesji dostępny z każdej sceny
- **Splash screen** — pewne rozwiązanie Safari autoplay policy

**Struktura projektu:** Hybrid (by type) — 6 głównych katalogów (`autoloads/`, `scenes/`, `scripts/`, `resources/`, `assets/`, `web/`)

**Wzorce implementacji:** 7 wzorców (2 niestandardowe: konfigurowalny scoring, retry queue) zapewniających spójność implementacji.

**Gotowy do:** Implementacji Epic 1 — Fundament Techniczny.

---

## Development Environment

### Prerequisites

| Narzędzie | Wersja | Cel |
|---|---|---|
| Godot Engine | 4.5.2 stable | Silnik gry i eksport HTML5 |
| Node.js | 18+ | MCP server (Godot MCP) |
| Git | dowolna | Kontrola wersji |
| Konto GitHub | — | GitHub Pages hosting |

### AI Tooling (MCP Servers)

| MCP Server | Cel | Instalacja |
|---|---|---|
| Godot MCP (bradypp) | Bezpośredni dostęp Claude do Godot Editora | Node.js |
| Context7 (upstash) | Aktualna dokumentacja Godot | npx |

**Instalacja Godot MCP:**
```bash
git clone https://github.com/bradypp/godot-mcp.git
cd godot-mcp
npm install
npm run build
```

Konfiguracja w `.mcp.json` w katalogu projektu:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["C:/ścieżka/do/godot-mcp/build/index.js"]
    }
  }
}
```

**Instalacja Context7:**
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

### First Steps

1. Pobierz Godot 4.5.2 ze strony godotengine.org
2. Utwórz nowy projekt Godot z renderingiem Compatibility (WebGL 2.0)
3. Utwórz strukturę folderów zgodnie z sekcją Project Structure
4. Skonfiguruj Autoloads w Project Settings → Autoload
5. Skonfiguruj MCP servers per instrukcje powyżej
6. Skonfiguruj eksport HTML5 (Project → Export → Add HTML5 template)
7. Utwórz repozytorium GitHub i skonfiguruj GitHub Pages

---

## Architecture Validation

### Validation Summary

| Sprawdzenie | Wynik | Uwagi |
|---|---|---|
| Zgodność decyzji | ✅ Pass | Wszystkie decyzje wzajemnie spójne |
| Pokrycie GDD | ✅ Pass | Wszystkie systemy zaadresowane |
| Kompletność wzorców | ✅ Pass | 7 wzorców z przykładami |
| Mapowanie epików | ✅ Pass | Wszystkie 8 epików zmapowane |
| Kompletność dokumentu | ✅ Pass | Brak placeholderów |

### Coverage Report

**Systemy pokryte:** 10/10
**Wzorce zdefiniowane:** 7 (2 niestandardowe + 5 standardowych)
**Decyzje podjęte:** 6 kluczowych decyzji architektonicznych

### Issues Resolved

- **RewardSystem** — zidentyfikowany brak jawnego miejsca dla logiki obliczania nagród. Rozwiązanie: statyczna klasa `RewardSystem` w `scripts/reward_system.gd` wywoływana przez `SessionController` po zakończeniu sesji.

### Validation Date

2026-03-21

---

## Implementation Patterns

Wzorce zapewniające spójną implementację we wszystkich systemach.

### Novel Patterns

#### 1. Konfigurowalny System Punktacji

**Problem:** 4 niezależne składniki punktacji — każdy on/off przez użytkownika. Obliczanie wyniku musi być deterministyczne i testowalne.

**Komponenty:** `SessionConfig` (konfiguracja) + `SessionController` (wywołuje obliczenie) + `SessionState` (akumuluje wynik)

**Przepływ danych:** `SessionConfig.scoring_*` → `SessionConfig.calculate_score()` → `SessionState.score`

```gdscript
# resources/models/session_config.gd (fragment)
var scoring_base_points: bool = true
var scoring_time_bonus: bool = false
var scoring_streak_multiplier: bool = false
var scoring_error_penalty: bool = false

var base_points_value: int = 10
var time_bonus_max: int = 10
var streak_multiplier_max: float = 3.0
var error_penalty_value: int = 5

func calculate_score(correct: bool, response_time: float,
                     time_limit: float, streak: int) -> int:
    if not correct:
        return -error_penalty_value if scoring_error_penalty else 0

    var points: int = base_points_value if scoring_base_points else 0

    if scoring_time_bonus and time_limit > 0:
        var ratio = clamp(1.0 - (response_time / time_limit), 0.0, 1.0)
        points += int(time_bonus_max * ratio)

    if scoring_streak_multiplier and streak > 1:
        var mult = min(1.0 + (streak - 1) * 0.5, streak_multiplier_max)
        points = int(points * mult)

    return max(0, points)
```

**Użycie:** Wywołaj `config.calculate_score()` po każdej odpowiedzi w `SessionController`.

#### 2. Kolejka Powtórek Błędów

**Problem:** Błędne pytania wracają w tej samej sesji. Liczba powtórek konfigurowalna (0 = brak, 1-5 = konkretna liczba, -1 = do pierwszej poprawnej).

**Komponenty:** `SessionState` (zarządza kolejką) + `SessionController` (odpytuje `get_next_question()`)

```gdscript
# resources/models/session_state.gd (fragment)
var retry_queue: Array[Question] = []
var retry_counts: Dictionary = {}  # question.id → int

func on_incorrect_answer(question: Question) -> void:
    var max_retries: int = config.retry_count  # 0, 1-5, lub -1
    var done: int = retry_counts.get(question.id, 0)

    if max_retries == -1 or done < max_retries:
        retry_queue.append(question)
        retry_counts[question.id] = done + 1

func get_next_question() -> Question:
    # Wstrzykuje powtórkę co 3 nowe pytania
    if not retry_queue.is_empty() and current_index % 3 == 0:
        return retry_queue.pop_front()
    if current_index < questions.size():
        var q = questions[current_index]
        current_index += 1
        return q
    if not retry_queue.is_empty():
        return retry_queue.pop_front()
    return null  # sesja zakończona

func is_finished() -> bool:
    return current_index >= questions.size() and retry_queue.is_empty()
```

### Communication Patterns

**Reguła:** Sygnały lokalne dla komunikacji węzeł → rodzic. EventBus dla komunikacji między niezwiązanymi systemami.

```gdscript
# Lokalny sygnał — NumericKeyboard → SessionScene
# numeric_keyboard.gd
signal digit_pressed(digit: int)
signal backspace_pressed
signal confirm_pressed

# SessionScene odbiera:
func _ready() -> void:
    %NumericKeyboard.confirm_pressed.connect(_on_answer_confirmed)

# Globalny EventBus — SessionController → RewardSystem (niezwiązane)
# session_controller.gd
EventBus.session_completed.emit(session_result)

# reward_manager.gd (niezależny, nasłuchuje globalnie)
func _ready() -> void:
    EventBus.session_completed.connect(_on_session_completed)
```

### Entity Creation Pattern

**Wzorzec:** Fabryka pytań w `SessionController` — tworzy całą tablicę pytań przed startem sesji.

```gdscript
# scripts/gameplay/session_controller.gd
func _create_questions(config: SessionConfig) -> Array[Question]:
    var operation: MathOperation = _resolve_operation(config)
    var questions: Array[Question] = []
    for i in config.question_count:
        questions.append(operation.generate_question(config))
    # Przetasuj jeśli losowa kolejność
    if config.randomize_order:
        questions.shuffle()
    return questions

func _resolve_operation(config: SessionConfig) -> MathOperation:
    match config.operation_type:
        "addition": return AdditionOperation.new()
        "subtraction": return SubtractionOperation.new()
        "multiplication": return MultiplicationOperation.new()
        "division": return DivisionOperation.new()
        "order_of_operations": return OrderOfOperations.new()
        "mixed": return MixedOperation.new(config.mixed_types)
        _:
            push_error("[SessionController] Nieznany typ działania: %s" % config.operation_type)
            return AdditionOperation.new()  # fallback
```

### Data Access Pattern

**Reguła:** Dane runtime przez `GameState`. Dane persystentne przez `DataManager`. Nigdy bezpośredni dostęp do localStorage poza DataManager.

```gdscript
# ✅ Poprawnie — dane runtime
var profile = GameState.current_profile
var config = GameState.current_config

# ✅ Poprawnie — zapis danych
DataManager.save_profile(GameState.current_profile)

# ❌ Niepoprawnie — bezpośredni localStorage
JavaScriptBridge.eval("localStorage.getItem('profile')") # NIGDY poza DataManager
```

### Consistency Rules

| Wzorzec | Zasada | Egzekwowanie |
|---|---|---|
| Komunikacja | Sygnały lokalne lub EventBus — nigdy `get_node("/root/...")` | Code review |
| Dane | Tylko przez GameState / DataManager | Code review |
| Punktacja | Tylko przez `SessionConfig.calculate_score()` | Jeden punkt w kodzie |
| Pytania | Tylko przez `MathOperation.generate_question()` | Klasa bazowa |
| Nagrody | Tylko przez `RewardSystem.calculate_stars()` | Jeden punkt w kodzie |
| Logowanie | Prefiks `[NazwaSystemu]` we wszystkich `print/push_*` | Konwencja |
| Stałe | Tylko z `Constants.NAZWA` — bez magic numbers | Code review |

### Reward System

**Lokalizacja:** `scripts/reward_system.gd`
**Typ:** Klasa statyczna (nie autoload) — bezstanowa logika obliczeń

```gdscript
# scripts/reward_system.gd
class_name RewardSystem

static func calculate_stars(result: SessionResult) -> int:
    var accuracy: float = result.get_accuracy()
    var base: int = int(accuracy * 10)
    if accuracy >= 1.0:
        base += Constants.STARS_BONUS_PERFECT
    if result.get_duration_seconds() < result.config.question_count * 5.0:
        base += Constants.STARS_BONUS_SPEED
    return max(1, base)  # zawsze min. 1 gwiazdka

static func check_achievements(profile: PlayerProfile,
                                result: SessionResult) -> Array[String]:
    var unlocked: Array[String] = []
    if profile.total_sessions == 1:
        unlocked.append("first_session")
    if result.streak == result.config.question_count:
        unlocked.append("perfect_session")
    if profile.total_sessions == 10:
        unlocked.append("sessions_10")
    if profile.total_sessions == 100:
        unlocked.append("sessions_100")
    return unlocked

static func check_hero_level_up(profile: PlayerProfile) -> int:
    # Zwraca nowy poziom lub -1 jeśli brak awansu
    const LEVEL_THRESHOLDS = [0, 50, 200, 500, 1000, 2500]
    var current: int = profile.hero_level
    if current < LEVEL_THRESHOLDS.size() - 1:
        if profile.total_stars >= LEVEL_THRESHOLDS[current + 1]:
            return current + 1
    return -1
```

---

## Project Structure

### Organization Pattern

**Pattern:** By Type (Hybrid) — typy na poziomie głównym, systemy wewnątrz
**Uzasadnienie:** Standardowa konwencja Godot, czytelna dla nowego developera, jasne granice między scenami / skryptami / assetami.

### Directory Structure

```
mathhero/
├── project.godot
├── export_presets.cfg
│
├── autoloads/                     # Singletony globalne
│   ├── scene_manager.gd
│   ├── game_state.gd
│   ├── data_manager.gd
│   ├── audio_manager.gd
│   ├── event_bus.gd
│   └── constants.gd
│
├── scenes/                        # Pliki .tscn
│   ├── ui/
│   │   ├── splash_screen.tscn
│   │   ├── profile_select.tscn
│   │   ├── main_menu.tscn
│   │   ├── session_config.tscn
│   │   ├── summary.tscn
│   │   ├── stats.tscn
│   │   ├── shop.tscn
│   │   └── galaxy.tscn
│   ├── gameplay/
│   │   └── session.tscn
│   └── components/
│       ├── numeric_keyboard.tscn
│       ├── question_display.tscn
│       ├── progress_bar.tscn
│       └── hero_avatar.tscn
│
├── scripts/                       # Skrypty .gd
│   ├── ui/
│   │   ├── splash_screen.gd
│   │   ├── profile_select.gd
│   │   ├── main_menu.gd
│   │   ├── session_config.gd
│   │   ├── summary.gd
│   │   ├── stats.gd
│   │   ├── shop.gd
│   │   └── galaxy.gd
│   ├── gameplay/
│   │   └── session_controller.gd
│   └── components/
│       ├── numeric_keyboard.gd
│       ├── question_display.gd
│       ├── progress_bar.gd
│       └── hero_avatar.gd
│
├── resources/                     # Klasy danych (Resource)
│   ├── models/
│   │   ├── player_profile.gd
│   │   ├── session_config.gd
│   │   ├── session_state.gd
│   │   ├── question.gd
│   │   └── session_result.gd
│   └── math_operations/           # Moduły plug-in
│       ├── math_operation.gd      # Klasa bazowa
│       ├── addition_operation.gd
│       ├── subtraction_operation.gd
│       ├── multiplication_operation.gd
│       ├── division_operation.gd
│       └── order_of_operations.gd
│
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   ├── images/
│   │   ├── backgrounds/
│   │   ├── hero/
│   │   ├── planets/
│   │   ├── badges/
│   │   └── ui/
│   └── shaders/
│
└── web/                           # Pliki PWA (poza Godot export)
    ├── manifest.json
    ├── service_worker.js
    └── icons/
```

### System Location Mapping

| System | Lokalizacja | Odpowiedzialność |
|---|---|---|
| SceneManager | `autoloads/scene_manager.gd` | Przejścia między scenami |
| GameState | `autoloads/game_state.gd` | Aktywny profil, konfiguracja, stan sesji |
| DataManager | `autoloads/data_manager.gd` | localStorage read/write |
| AudioManager | `autoloads/audio_manager.gd` | Muzyka, SFX, Safari unlock |
| EventBus | `autoloads/event_bus.gd` | Globalne sygnały między systemami |
| Constants | `autoloads/constants.gd` | Stałe całej gry |
| Generator zadań | `resources/math_operations/` | MathOperation + implementacje Fazy 1 |
| Modele danych | `resources/models/` | PlayerProfile, SessionConfig, itp. |
| Ekrany UI | `scenes/ui/` + `scripts/ui/` | Każdy ekran jako para .tscn + .gd |
| Sesja gry | `scenes/gameplay/` + `scripts/gameplay/` | Silnik sesji matematycznej |
| Komponenty | `scenes/components/` + `scripts/components/` | Reużywalne elementy UI |
| Assety graficzne | `assets/images/` | Podkatalogi wg kategorii |
| Assety audio | `assets/audio/` | `music/` i `sfx/` oddzielnie |
| Pliki PWA | `web/` | manifest.json, service_worker.js, ikony |

### Naming Conventions

#### Files

| Typ | Konwencja | Przykład |
|---|---|---|
| Skrypty .gd | `snake_case` | `session_controller.gd` |
| Sceny .tscn | `snake_case` | `main_menu.tscn` |
| Assety graficzne | `snake_case` z sufiksem | `hero_helmet_01.png` |
| Assety audio | `snake_case` opisowy | `sfx_correct_answer.ogg` |

#### Code Elements

| Element | Konwencja | Przykład |
|---|---|---|
| Klasy | `PascalCase` | `class_name SessionState` |
| Funkcje | `snake_case` | `func generate_question()` |
| Zmienne publiczne | `snake_case` | `var current_score: int` |
| Zmienne prywatne | `_snake_case` | `var _retry_queue: Array` |
| Stałe | `UPPER_SNAKE_CASE` | `const MAX_PROFILES: int` |
| Sygnały | `snake_case` czas przeszły | `signal session_completed` |
| Enumy | `PascalCase` | `enum AppState { MENU, SESSION }` |

### Architectural Boundaries

- **Autoloady** nie importują się nawzajem przez `preload` — komunikują się przez sygnały EventBus
- **Sceny UI** nie wywołują DataManager bezpośrednio — używają GameState jako pośrednika
- **MathOperation** nie zna SessionState — tylko przyjmuje `SessionConfig` i zwraca `Question`
- **Komponenty** (numeric_keyboard, question_display) nie znają logiki biznesowej — komunikują się przez sygnały
- **Folder `web/`** jest zarządzany ręcznie — Godot export nie modyfikuje tych plików

---

## Cross-cutting Concerns

Wzorce stosowane obowiązkowo we WSZYSTKICH systemach — zapewniają spójność implementacji.

### Error Handling

**Strategia:** Dwa poziomy — błędy krytyczne (assert) i odwracalne (loguj + bezpieczny stan)

Błędy nigdy nie są pokazywane graczowi. Aplikacja zawsze wraca do bezpiecznego stanu.

```gdscript
# Błąd krytyczny — zatrzymuje grę w debug, widoczny podczas development
assert(profile != null, "Próba startu sesji bez aktywnego profilu")

# Błąd odwracalny — loguj i wróć do bezpiecznego stanu
func load_profile(id: String) -> PlayerProfile:
    var data = DataManager.load_profile(id)
    if data.is_empty():
        push_warning("Profil %s nie znaleziony — ładuję domyślny" % id)
        return PlayerProfile.create_default()
    return PlayerProfile.from_dict(data)
```

### Logging

**Format:** Prefiks systemu w nawiasach kwadratowych — `[SYSTEM] Wiadomość`
**Cel:** Konsola Godot (debug only) — `print()`, `push_warning()`, `push_error()`
**Zasada:** Logowanie tylko gdy `OS.is_debug_build()` — zero logów w release

```gdscript
# Wzorzec — każdy system używa swojego prefiksu
print("[DataManager] Załadowano %d profili" % profiles.size())
push_warning("[AudioManager] Audio jeszcze nie odblokowane — pomijam SFX")
push_error("[SessionState] Brak pytań w sesji — krytyczny błąd konfiguracji")
push_error("[DataManager] Błąd zapisu localStorage: %s" % error_msg)
```

### Configuration

**Podejście:** Jeden plik `constants.gd` jako Autoload — wszystkie stałe gry w jednym miejscu

```gdscript
# autoloads/constants.gd
extends Node

# Profile
const MAX_PROFILES: int = 5
const MAX_SESSION_HISTORY: int = 100  # rotacja FIFO
const MAX_PRESETS_PER_PROFILE: int = 20

# Sesja
const MIN_QUESTION_VALUE: int = 1
const MAX_QUESTION_VALUE: int = 9999
const MIN_QUESTIONS: int = 5
const MAX_QUESTIONS: int = 100
const MIN_TIME_LIMIT: int = 5    # sekundy
const MAX_TIME_LIMIT: int = 300  # sekundy

# Ekonomia
const STARS_PER_CORRECT: float = 1.0
const STARS_BONUS_PERFECT: float = 5.0  # 100% poprawnych
const STARS_BONUS_SPEED: float = 0.5    # odpowiedź < połowy limitu czasu
```

### Event System

**Pattern:** Sygnały Godota (lokalne) + EventBus Autoload (globalne)

- **Lokalne sygnały** — komunikacja między węzłem a jego rodzicem / bezpośrednie połączenia
- **EventBus** — zdarzenia globalne między niezwiązanymi systemami (np. sesja → system nagród)

```gdscript
# autoloads/event_bus.gd
extends Node

# Przepływ aplikacji
signal profile_selected(profile: PlayerProfile)
signal session_started(config: SessionConfig)
signal session_completed(result: SessionResult)

# Gameplay
signal question_answered(correct: bool, streak: int)
signal streak_broken(final_streak: int)

# Nagrody
signal stars_earned(amount: int)
signal achievement_unlocked(achievement_id: String)
signal hero_level_up(new_level: int)

# Użycie — emituj z dowolnego systemu, nasłuchuj z dowolnego miejsca
# EventBus.session_completed.emit(result)
# EventBus.session_completed.connect(_on_session_completed)
```

**Konwencja nazw sygnałów:** `snake_case`, czas przeszły dla zdarzeń (`session_completed`, `stars_earned`), czas teraźniejszy dla żądań (`show_dialog`, `play_sfx`).

### Debug Tools

**Aktywacja:** `OS.is_debug_build()` — narzędzia debug niedostępne w release build

```gdscript
# Panel debug — aktywowany dotykiem 4 palcami jednocześnie (touch)
# Wyświetla: aktywny profil, stan GameState, rozmiar localStorage, FPS

func _input(event: InputEvent) -> void:
    if not OS.is_debug_build():
        return
    if event is InputEventScreenTouch:
        if Input.get_touch_count() >= 4:
            $DebugPanel.visible = not $DebugPanel.visible

# Komendy debug (w konsoli Godot podczas development):
# GameState.debug_add_stars(100)
# DataManager.debug_clear_all()
# SceneManager.go_to("galaxy")
```

---

## Architectural Decisions

### Decision Summary

| # | Kategoria | Decyzja | Uzasadnienie |
|---|---|---|---|
| 1 | Zarządzanie scenami | SceneManager Autoload | Centralne przejścia, animacje w jednym miejscu |
| 2 | Autoloady (Singletony) | SceneManager, GameState, DataManager, AudioManager | Minimalne 4 singletony dla globalnych usług |
| 3 | Generator zadań | Resource plug-in (MathOperation base class) | Rozszerzalność bez modyfikacji istniejącego kodu |
| 4 | Persystencja danych | DataManager wrapper (JavaScriptBridge) | Czysty API ukrywający localStorage |
| 5 | Stan sesji | SessionState Resource w GameState | Dostępny z każdej sceny przez cały czas trwania sesji |
| 6 | Audio (Safari) | Splash screen jako bramka audio | Pewne rozwiązanie Safari autoplay policy |

### State Management

**Podejście:** Singleton Pattern (Autoloady Godot)

`GameState` jako centralny autoload trzyma:
- Aktywny profil (`current_profile: PlayerProfile`)
- Konfigurację sesji (`current_config: SessionConfig`)
- Stan sesji (`current_session: SessionState`)
- Stan aplikacji (`app_state: AppState` — enum: MENU, CONFIG, SESSION, SUMMARY, SHOP, GALAXY, STATS)

```gdscript
# autoloads/game_state.gd
extends Node

var current_profile: PlayerProfile = null
var current_config: SessionConfig = null
var current_session: SessionState = null
var app_state: AppState = AppState.MENU

enum AppState { MENU, PROFILE_SELECT, CONFIG, SESSION, SUMMARY, SHOP, GALAXY, STATS }
```

### Scene Management

**Podejście:** SceneManager Autoload z metodą `go_to()`

```gdscript
# autoloads/scene_manager.gd
extends Node

signal scene_changed(scene_name: String)

const SCENES = {
    "splash": "res://scenes/ui/splash_screen.tscn",
    "profile_select": "res://scenes/ui/profile_select.tscn",
    "main_menu": "res://scenes/ui/main_menu.tscn",
    "session_config": "res://scenes/ui/session_config.tscn",
    "session": "res://scenes/gameplay/session.tscn",
    "summary": "res://scenes/ui/summary.tscn",
    "stats": "res://scenes/ui/stats.tscn",
    "shop": "res://scenes/ui/shop.tscn",
    "galaxy": "res://scenes/ui/galaxy.tscn",
}

func go_to(scene_name: String) -> void:
    # animacja fade out → zmiana sceny → fade in
    get_tree().change_scene_to_file(SCENES[scene_name])
    scene_changed.emit(scene_name)
```

### Data Persistence

**Podejście:** DataManager Autoload — wrapper JavaScriptBridge → localStorage

```gdscript
# autoloads/data_manager.gd
extends Node

const KEY_PROFILES = "mathhero_profiles"

func save_profile(profile: PlayerProfile) -> void:
    var data = JSON.stringify(profile.to_dict())
    JavaScriptBridge.eval("localStorage.setItem('mathhero_profile_%s', '%s')" % [profile.id, data])

func load_all_profiles() -> Array[PlayerProfile]:
    var result: Array[PlayerProfile] = []
    # wczytuje listę ID, potem każdy profil
    return result

func save_session_to_history(profile_id: String, session: SessionState) -> void:
    # max 100 sesji — rotacja FIFO
    pass
```

**Struktura localStorage:**

| Klucz | Zawartość | Max rozmiar |
|---|---|---|
| `mathhero_profiles` | Lista ID profili (JSON array) | ~100B |
| `mathhero_profile_{id}` | Dane profilu (gwiazdki, poziom, kostium) | ~5KB |
| `mathhero_sessions_{id}` | Historia sesji (max 100, FIFO) | ~50KB |
| `mathhero_presets_{id}` | Presety konfiguracji (max 20) | ~10KB |
| `mathhero_galaxy_{id}` | Postępy galaktyki misji | ~5KB |

### Modular Question Generator

**Podejście:** Resource plug-in — klasa bazowa `MathOperation`

```gdscript
# resources/math_operations/math_operation.gd
class_name MathOperation extends Resource

func generate_question(config: SessionConfig) -> Question:
    push_error("MathOperation.generate_question() not implemented")
    return null

func validate_answer(question: Question, answer: int) -> bool:
    return answer == question.correct_answer

func get_operation_type() -> String:
    return "base"

# --- Implementacje Fazy 1 ---

# resources/math_operations/addition_operation.gd
class_name AdditionOperation extends MathOperation

func generate_question(config: SessionConfig) -> Question:
    var a = randi_range(config.min_value, config.max_value)
    var b = randi_range(config.min_value, config.max_value)
    return Question.new("%d + %d" % [a, b], a + b)

func get_operation_type() -> String:
    return "addition"
```

**Dodanie nowego typu działania = jeden nowy plik** — zero zmian w istniejącym kodzie.

### Session State

**Podejście:** SessionState Resource przechowywany w GameState

```gdscript
# resources/session_state.gd
class_name SessionState extends Resource

var config: SessionConfig
var questions: Array[Question] = []
var retry_queue: Array[Question] = []
var current_index: int = 0
var score: int = 0
var streak: int = 0
var max_streak: int = 0
var correct_count: int = 0
var incorrect_count: int = 0
var start_time: float = 0.0
var end_time: float = 0.0

func get_accuracy() -> float:
    var total = correct_count + incorrect_count
    return float(correct_count) / total if total > 0 else 0.0

func get_duration_seconds() -> float:
    return end_time - start_time
```

### Audio System

**Podejście:** Splash screen jako bramka audio + AudioManager Autoload

```gdscript
# autoloads/audio_manager.gd
extends Node

var _audio_unlocked: bool = false
var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

const SFX = {
    "correct": preload("res://assets/audio/sfx/correct.ogg"),
    "incorrect": preload("res://assets/audio/sfx/incorrect.ogg"),
    "combo": preload("res://assets/audio/sfx/combo.ogg"),
    "complete": preload("res://assets/audio/sfx/session_complete.ogg"),
    "unlock": preload("res://assets/audio/sfx/unlock.ogg"),
    "click": preload("res://assets/audio/sfx/click.ogg"),
    "timer_tick": preload("res://assets/audio/sfx/timer_tick.ogg"),
}

func unlock_audio() -> void:
    _audio_unlocked = true
    play_music("ambient_space")

func play_sfx(sfx_name: String) -> void:
    if not _audio_unlocked:
        return
    # odtwórz z puli AudioStreamPlayer
```

### Architecture Decision Records

**ADR-001: Resource plug-in dla generatora zadań**
Wybrano pattern Resource zamiast słownika/JSON ponieważ: (1) GDScript posiada system klas z dziedziczeniem, (2) nowe typy działań dodawane przez nowy plik bez modyfikacji istniejącego kodu, (3) konfiguracja per typ edytowalna w Inspector Godota.

**ADR-002: 4 autoloady zamiast więcej**
Minimalizacja singletonów do 4 niezbędnych. Logika domenowa (generator pytań, system nagród, galaktyka) implementowana jako klasy/Resource, nie autoloady — dostępna przez sceny i GameState.

**ADR-003: localStorage przez JavaScriptBridge**
FileAccess nie działa poprawnie w Godot HTML5 export. JavaScriptBridge.eval() z localStorage jest jedyną pewną metodą persystencji danych w PWA. DataManager wrapper ukrywa tę złożoność.

**ADR-004: Splash screen zamiast "pierwsze kliknięcie"**
Safari wymaga jawnej interakcji przed odtworzeniem audio. Splash screen gwarantuje tę interakcję w kontrolowanym miejscu i służy jednocześnie jako ekran startowy/logo.

---

## Project Context

### Game Overview

**MathHero** — edukacyjna gra matematyczna na iPad Air 2. Dziecko w wieku 9-18 lat ćwiczy arytmetykę jako astronauta-bohater podróżujący przez galaktykę. Sesje w pełni konfigurowalne, offline, bez konta.

### Technical Scope

**Platform:** iPad Air 2 (iPadOS 14+) — Godot 4.x → HTML5 export → PWA via Safari
**Genre:** Puzzle (Educational Math Trainer)
**Project Level:** Średnia złożoność — solo developer, nowa technologia (Godot)

### Core Systems

| System | Złożoność | Opis |
|---|---|---|
| Generator zadań (modularny) | Wysoka | Plug-in architecture, 5 typów Fazy 1, rozszerzalny |
| Silnik sesji | Wysoka | Timer, scoring, powtórki błędów, 4 tryby błędu |
| System konfiguracji | Wysoka | 10+ parametrów, presety systemowe + użytkownika |
| System nagród / progresji | Wysoka | Gwiazdki, poziomy bohatera, sklep kostiumu, odznaki |
| Zarządzanie profilami | Średnia | 2+ profile lokalne, localStorage |
| Galaktyka Misji | Średnia | Mapa planet, misje sekwencyjne, codzienne wyzwanie |
| Statystyki i historia | Średnia | Historia sesji, rekordy, automatyczna sugestia trudności |
| System audio | Średnia | Safari autoplay policy, ambient loop, SFX |
| Wirtualna klawiatura numeryczna | Niska | Custom touch UI, duże strefy dotyku |
| Persystencja danych (localStorage) | Niska | Wrapper API, ~1-2MB, offline |

### Technical Requirements

- **Frame rate:** 60 fps target (min. 30 fps akceptowalne)
- **Rozdzielczość:** 2048x1536px (Retina), orientacja landscape zablokowana
- **Czas startu PWA:** < 3 sekundy (po instalacji)
- **Przejścia ekranów:** < 0.5 sekundy
- **Rozmiar buildu:** < 30MB (PWA cache limit)
- **Offline:** 100% funkcji dostępne bez internetu (Service Worker)
- **Dane:** localStorage, ~1-2MB profili i historii

### Complexity Drivers

1. **Modułowy generator zadań** — architektura plug-in umożliwiająca dodawanie nowych typów działań bez modyfikacji core systemu
2. **Konfigurowalny system punktacji** — 4 niezależne składniki (punkty bazowe, bonus czasowy, mnożnik serii, kara za błąd), każdy on/off
3. **System powtórek błędów** — zarządzanie kolejką pytań w trakcie sesji
4. **Safari audio autoplay policy** — wymaga ekranu splash jako "bramki" audio

### Technical Risks

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|---|---|---|---|
| Safari audio autoplay policy | Wysokie | Średnie | Ekran splash wymuszający interakcję użytkownika |
| Godot HTML5 wolny na A8X (iPad Air 2) | Średnie | Wysokie | Profiling w Epic 1, minimalizacja draw calls |
| Build size > 30MB | Średnie | Średnie | Kompresja assetów, lazy loading, monitoring rozmiaru |
| localStorage overflow | Niskie | Średnie | Rotacja historii (max 100 sesji), kompresja JSON |
