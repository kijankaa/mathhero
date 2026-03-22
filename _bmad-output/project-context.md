---
project_name: 'MathHero'
user_name: 'Jarek'
date: '2026-03-21'
sections_completed: ['technology_stack', 'engine_rules', 'performance_rules', 'platform_rules', 'organization_rules', 'implementation_patterns', 'anti_patterns']
status: 'complete'
rule_count: 45
optimized_for_llm: true
---

# Project Context — MathHero

_Plik zawiera krytyczne reguły i wzorce dla AI agentów implementujących kod w tym projekcie. Skup się na nieoczywistych detalach, które agenci mogą przeoczyć._

---

## Technology Stack

| Technologia | Wersja | Uwagi |
|---|---|---|
| Godot Engine | 4.5.2 stable | NIE 4.6 (RC) |
| Język | GDScript | C# NIE obsługiwany dla HTML5 |
| Renderer | Compatibility (WebGL 2.0) | Wymagany dla Safari/iPad |
| Export target | HTML5 | index.html + .pck + .js |
| Hosting | GitHub Pages | HTTPS wymagane dla PWA |
| Persystencja | localStorage (JavaScriptBridge) | ~5MB limit |
| Audio | Web Audio API | Safari autoplay policy |
| Platforma | iPad Air 2 (iPadOS 14+, Safari) | A8X, 2GB RAM |

## Godot Engine Rules

### Node Lifecycle
- Używaj `@onready var x = $Node` — NIE odwołuj się do węzłów przed `_ready()`
- `_ready()` wywołuje się od dołu drzewa do góry — dzieci są gotowe przed rodzicem
- Używaj `call_deferred()` gdy modyfikujesz scenę wewnątrz `_ready()`
- `queue_free()` zamiast `free()` — deferred usuwanie jest bezpieczne

### Static Typing — OBOWIĄZKOWE
- Zawsze deklaruj typy: `var score: int`, `func go_to(scene: String) -> void`
- Typed GDScript = szybszy kod + wcześniejsze wykrywanie błędów
- Array z typem: `var questions: Array[Question] = []`

### Autoloads — granice dostępu
- `GameState` — stan runtime (aktywny profil, sesja, konfiguracja)
- `DataManager` — JEDYNY punkt dostępu do localStorage
- `AudioManager` — JEDYNY punkt odtwarzania dźwięku
- `SceneManager` — JEDYNE miejsce zmiany scen
- `EventBus` — sygnały globalne między niezwiązanymi systemami
- `Constants` — JEDYNE miejsce stałych (bez magic numbers w kodzie)

### Sygnały
- Definicja: `signal session_completed(result: SessionResult)` — zawsze typowane
- Czas przeszły dla zdarzeń: `session_completed`, `stars_earned`
- Połącz w `_ready()`: `EventBus.session_completed.connect(_on_session_completed)`
- NIE używaj `get_node("/root/...")` — tylko sygnały lub autoloady

### HTML5 / JavaScriptBridge
- localStorage TYLKO przez `DataManager` — nigdy bezpośrednio
- `JavaScriptBridge.eval()` jest synchroniczne — unikaj w `_process()`
- Sprawdzaj `OS.has_feature("web")` przed wywołaniami JS-specific

## Performance Rules

### Cel wydajnościowy
- 60 fps target na iPad Air 2 (A8X, WebGL 2.0)
- Czas startu PWA: < 3 sekundy
- Rozmiar buildu: < 30MB (PWA cache limit)
- Przejścia między ekranami: < 0.5s

### Godot HTML5 / WebGL 2.0
- Renderer: TYLKO Compatibility — Forward+ nie działa w HTML5
- Unikaj `_process()` na węzłach które nie potrzebują per-frame update — używaj sygnałów/timerów
- NIE używaj cieniowania 3D, efektów post-process — niezgodne z Compatibility
- Minimalny draw call count — łącz tekstury (atlas), unikaj wielu CanvasLayer

### Pamięć i assety
- `preload()` dla małych assetów zawsze potrzebnych (SFX, czcionki)
- `load()` dla dużych assetów (tła, muzyka) — ładuj per scena
- Tekstury: format WebP lub kompresja PNG — cel < 512KB per tło
- Audio: .ogg format, mono dla SFX, stereo dla muzyki ambient
- Nie trzymaj referencji do usuniętych węzłów — sprawdzaj `is_instance_valid()`

## Platform Rules (iPad Air 2 / Safari PWA)

### Safari Audio Autoplay Policy
- Audio NIE zostanie odtworzone bez interakcji użytkownika
- `AudioManager.unlock_audio()` MUSI być wywołane po kliknięciu splash screenu
- NIE próbuj odtwarzać audio w `_ready()` lub autoloadach przy starcie
- Sprawdzaj `AudioManager._audio_unlocked` przed każdym `play_sfx()`

### Orientacja i rozmiar ekranu
- TYLKO landscape — orientacja zablokowana w CSS i Godot
- Viewport: 1366x1024 (logical) lub 2048x1536 (physical Retina)
- Używaj `stretch_mode = canvas_items` + `aspect = expand` w Godot
- Przyciski dotykowe: min. 60x60pt dla cyfr klawiatury, min. 44x44pt dla nawigacji

### PWA / Service Worker
- Wszystkie assety muszą być w cache Service Workera dla trybu offline
- Po zmianie assetów — zaktualizuj wersję cache w `service_worker.js`
- NIE używaj absolutnych URL do assetów — tylko ścieżki relatywne

## Code Organization Rules

### Struktura folderów — gdzie co trafia
- `autoloads/` — TYLKO singletony (SceneManager, GameState, DataManager, AudioManager, EventBus, Constants)
- `scenes/ui/` + `scripts/ui/` — każdy ekran jako para .tscn + .gd
- `scenes/gameplay/` — scena sesji matematycznej
- `scenes/components/` — reużywalne elementy UI (klawiatura, wyświetlacz pytania)
- `resources/models/` — klasy danych (PlayerProfile, SessionConfig, SessionState, Question)
- `resources/math_operations/` — moduły działań (MathOperation + implementacje)
- `scripts/reward_system.gd` — logika nagród (klasa statyczna)
- `assets/` — TYLKO assety (audio, images, fonts, shaders)
- `web/` — pliki PWA (manifest.json, service_worker.js) — NIE modyfikowane przez Godot

### Konwencje nazewnictwa

| Element | Konwencja | Przykład |
|---|---|---|
| Pliki .gd | snake_case | `session_controller.gd` |
| Pliki .tscn | snake_case | `main_menu.tscn` |
| Klasy | PascalCase | `class_name SessionState` |
| Funkcje | snake_case | `func generate_question()` |
| Zmienne pub. | snake_case | `var current_score: int` |
| Zmienne pryw. | _snake_case | `var _retry_queue: Array` |
| Stałe | UPPER_SNAKE | `const MAX_PROFILES: int` |
| Sygnały | snake_case przeszły | `signal session_completed` |
| Assety | snake_case opisowy | `sfx_correct_answer.ogg` |

### Logowanie — format obowiązkowy
- Prefiks systemu: `print("[DataManager] wiadomość")`
- TYLKO w debug: `if OS.is_debug_build(): print(...)`
- Poziomy: `print()` info, `push_warning()` ostrzeżenia, `push_error()` błędy krytyczne

## Implementation Patterns

### Dostęp do danych — OBOWIĄZKOWE reguły
- Dane runtime: TYLKO przez `GameState` (aktywny profil, konfiguracja, stan sesji)
- Dane persystentne: TYLKO przez `DataManager` (localStorage read/write)
- NIE wywołuj `JavaScriptBridge.eval()` poza `DataManager`
- NIE trzymaj kopii danych profilu w scenach — zawsze `GameState.current_profile`

### Generator zadań — wzorzec plug-in
- KAŻDY nowy typ działania = nowa klasa dziedzicząca po `MathOperation`
- NIE modyfikuj `session_controller.gd` przy dodawaniu nowych typów
- Dodaj tylko: nowy plik w `resources/math_operations/` + wpis w `_resolve_operation()`
- Constraint system: dzielenie zawsze wynik całkowity, odejmowanie wynik ≥ 0

### Punktacja — jeden punkt w kodzie
- Obliczaj punkty TYLKO przez `config.calculate_score(correct, time, limit, streak)`
- NIE implementuj logiki punktacji w innych miejscach

### Nagrody — jeden punkt w kodzie
- Obliczaj gwiazdki TYLKO przez `RewardSystem.calculate_stars(result)`
- Sprawdzaj odznaki TYLKO przez `RewardSystem.check_achievements(profile, result)`

### Zmiana scen
- TYLKO przez `SceneManager.go_to("scene_name")` — nigdy bezpośrednio
- Dostępne nazwy scen zdefiniowane w `SceneManager.SCENES` dictionary

## Critical Don't-Miss Rules

### NIE rób tego nigdy
- ❌ `get_node("/root/GameState")` — używaj autoloadu bezpośrednio: `GameState`
- ❌ `FileAccess.open()` w HTML5 — nie działa; używaj `DataManager` + localStorage
- ❌ `AudioStreamPlayer.play()` bez sprawdzenia `AudioManager._audio_unlocked`
- ❌ C# — nie kompiluje się dla HTML5 export w Godot 4
- ❌ Forward+ renderer — tylko Compatibility dla HTML5
- ❌ Magic numbers — wszystkie stałe w `Constants.gd`
- ❌ Bezpośrednie sygnały między niezwiązanymi systemami — używaj EventBus
- ❌ Modyfikacja `web/` przez skrypty Godot — zarządzaj ręcznie

### Gotchas Godot + HTML5
- `DisplayServer.window_set_size()` nie działa w HTML5 — rozmiar kontroluje CSS
- `OS.get_user_data_dir()` zwraca pusty string w HTML5 — używaj localStorage
- `Time.get_unix_time_from_system()` działa poprawnie w HTML5
- Particle systems: używaj tylko `CPUParticles2D` — `GPUParticles2D` może być wolny na A8X
- `Input.is_action_pressed()` dla dotyku — używaj `InputEventScreenTouch` bezpośrednio
- Lokalizacja: wszystkie stringi UI po polsku — brak systemu i18n w v1.0

---

## Usage Guidelines

**Dla AI agentów:**
- Czytaj ten plik PRZED implementacją jakiegokolwiek kodu
- Przestrzegaj WSZYSTKICH reguł dokładnie jak udokumentowane
- Gdy wątpliwość — wybieraj bardziej restrykcyjną opcję
- Odwołuj się do `game-architecture.md` dla szczegółów architektonicznych

**Dla Jarka:**
- Aktualizuj gdy zmienia się stos technologiczny lub wzorce
- Dodawaj nowe reguły gdy odkryjesz nowe gotcha
- Usuń reguły które stają się oczywiste po czasie

**Powiązane dokumenty:**
- `_bmad-output/gdd.md` — Game Design Document
- `_bmad-output/game-architecture.md` — Architektura techniczna
- `_bmad-output/epics.md` — Epiki deweloperskie

Last Updated: 2026-03-21
