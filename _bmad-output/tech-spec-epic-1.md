# Tech-Spec: Epic 1 — Fundament Techniczny

**Projekt:** MathHero
**Epic:** 1 — Fundament Techniczny
**Data:** 2026-03-22
**Status:** Gotowy do implementacji

---

## Cel

Zbudować działający fundament projektu Godot 4.5.2 z eksportem HTML5 jako PWA na iPad Air 2. Po zakończeniu: aplikacja działa offline, zapisuje dane w localStorage i uruchamia się poprawnie w Safari z dźwiękiem.

---

## Stories i Acceptance Criteria

| Story | AC |
|---|---|
| S1: Uruchomić projekt Godot | Projekt Godot 4.5.2 otwiera się, widać podstawową scenę testową |
| S2: Eksport HTML5 lokalnie | `index.html` uruchamia się na lokalnym serwerze HTTP |
| S3: PWA na iPadzie | Safari pokazuje "Dodaj do ekranu głównego", ikona pojawia się na home screen |
| S4: Offline | Aplikacja działa po wyłączeniu Wi-Fi (Service Worker) |
| S5: localStorage | Zapis i odczyt danych z localStorage działa przez DataManager |
| S6: Landscape + dźwięk | Aplikacja uruchamia się w trybie landscape, dźwięk działa po kliknięciu |

---

## Struktura projektu do stworzenia

```
MathHero/                          ← katalog projektu Godot
├── project.godot                  ← konfiguracja Godot (ręcznie)
├── autoloads/
│   ├── constants.gd               ← wszystkie stałe aplikacji
│   ├── event_bus.gd               ← globalne sygnały
│   ├── game_state.gd              ← stan runtime
│   ├── data_manager.gd            ← localStorage wrapper (JEDYNY)
│   ├── audio_manager.gd           ← zarządzanie dźwiękiem + unlock
│   └── scene_manager.gd           ← przejścia między scenami (JEDYNE)
├── scenes/
│   └── ui/
│       └── splash_screen.tscn     ← ekran splash (tworzyć ręcznie w Godot)
├── scripts/
│   └── ui/
│       └── splash_screen.gd       ← logika splash screen
├── resources/
│   ├── models/                    ← (puste — do Epic 2+)
│   └── math_operations/           ← (puste — do Epic 4)
├── assets/
│   ├── audio/                     ← (puste — do Epic 8)
│   ├── images/                    ← (puste — do Epic 8)
│   └── fonts/                     ← (puste — do Epic 8)
└── web/
    ├── manifest.json              ← PWA manifest
    ├── service_worker.js          ← Service Worker (offline)
    └── icons/
        ├── icon-192.png           ← placeholder (wymagane dla PWA)
        └── icon-512.png           ← placeholder (wymagane dla PWA)
```

> **Uwaga:** Pliki `.tscn` i `project.godot` tworzone są przez Godot Editor — nie przez ten tech-spec. Ten dokument dostarcza wszystkie pliki `.gd` i pliki `web/`.

---

## Implementacja — pliki GDScript

### 1. `autoloads/constants.gd`

Wszystkie stałe aplikacji. Zero magic numbers w reszcie kodu.

```gdscript
# autoloads/constants.gd
class_name Constants

# Wersja aplikacji
const APP_VERSION: String = "0.1.0"
const CACHE_VERSION: String = "mathhero-v1"

# Klucze localStorage
const STORAGE_KEY_PROFILES: String = "mathhero_profiles"
const STORAGE_KEY_SETTINGS: String = "mathhero_settings"
const STORAGE_KEY_SESSION_HISTORY: String = "mathhero_history"

# Limity
const MAX_PROFILES: int = 5
const MAX_HISTORY_ENTRIES: int = 100
const STORAGE_MAX_BYTES: int = 4_500_000  # 4.5MB z 5MB limitu

# UI
const MIN_TOUCH_SIZE_DIGIT: int = 60   # px — klawiatura numeryczna
const MIN_TOUCH_SIZE_NAV: int = 44     # px — przyciski nawigacji
const SCENE_TRANSITION_TIME: float = 0.3

# Sceny — nazwy używane przez SceneManager
const SCENE_SPLASH: String = "splash"
const SCENE_MAIN_MENU: String = "main_menu"
const SCENE_SESSION: String = "session"
const SCENE_SUMMARY: String = "summary"
const SCENE_CONFIG: String = "config"
const SCENE_PROFILE_SELECT: String = "profile_select"
const SCENE_STATS: String = "stats"
const SCENE_REWARDS: String = "rewards"
const SCENE_GALAXY: String = "galaxy"

# Punkty i nagrody
const STARS_PER_PERFECT: int = 3
const STARS_PER_GOOD: int = 2
const STARS_PER_PASS: int = 1
const SCORE_THRESHOLD_PERFECT: float = 0.95
const SCORE_THRESHOLD_GOOD: float = 0.75
const SCORE_THRESHOLD_PASS: float = 0.5
```

---

### 2. `autoloads/event_bus.gd`

Centralna szyna sygnałów dla komunikacji między niezwiązanymi systemami.

```gdscript
# autoloads/event_bus.gd
extends Node

# Audio
signal audio_unlocked()

# Profil
signal profile_selected(profile_id: String)
signal profile_created(profile_id: String)

# Sesja
signal session_started(config: Resource)
signal session_completed(result: Resource)
signal question_answered(correct: bool, response_time: float)

# Nagrody
signal stars_earned(amount: int, total: int)
signal achievement_unlocked(achievement_id: String)
signal costume_purchased(item_id: String)

# UI
signal scene_changed(scene_name: String)
```

---

### 3. `autoloads/data_manager.gd`

JEDYNY punkt dostępu do localStorage. Nie wywoływać `JavaScriptBridge.eval()` nigdzie indziej.

```gdscript
# autoloads/data_manager.gd
extends Node

# Wewnętrzny cache — unikamy zbędnych wywołań JS
var _cache: Dictionary = {}

func _ready() -> void:
	if OS.is_debug_build():
		print("[DataManager] Inicjalizacja. Web: ", OS.has_feature("web"))


## Zapisuje wartość do localStorage (i lokalnego cache).
## Klucz musi być z Constants — nigdy hardcoded string.
func save(key: String, data: Variant) -> bool:
	var json_string: String = JSON.stringify(data)
	if json_string.length() > Constants.STORAGE_MAX_BYTES:
		push_error("[DataManager] Dane przekraczają limit: " + key)
		return false

	_cache[key] = data

	if OS.has_feature("web"):
		var js_code: String = "localStorage.setItem('{key}', '{value}')".format({
			"key": key,
			"value": json_string.replace("'", "\\'")
		})
		JavaScriptBridge.eval(js_code)
	else:
		# Fallback dla edytora Godot (tryb nie-web)
		if OS.is_debug_build():
			print("[DataManager] TRYB EDITOR — dane nie są persystowane: ", key)

	return true


## Odczytuje wartość z localStorage (lub cache).
## Zwraca null jeśli klucz nie istnieje.
func load_data(key: String) -> Variant:
	if _cache.has(key):
		return _cache[key]

	if OS.has_feature("web"):
		var js_code: String = "localStorage.getItem('{key}')".format({"key": key})
		var result: Variant = JavaScriptBridge.eval(js_code)
		if result == null or result == "null":
			return null
		var parse_result: Variant = JSON.parse_string(str(result))
		_cache[key] = parse_result
		return parse_result

	return null


## Usuwa klucz z localStorage i cache.
func delete(key: String) -> void:
	_cache.erase(key)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('" + key + "')")


## Sprawdza czy klucz istnieje.
func has_key(key: String) -> bool:
	if _cache.has(key):
		return true
	return load_data(key) != null


## Czyści cały localStorage (UWAGA: nieodwracalne).
func clear_all() -> void:
	_cache.clear()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.clear()")
	if OS.is_debug_build():
		print("[DataManager] Wyczyszczono localStorage")
```

---

### 4. `autoloads/audio_manager.gd`

JEDYNY punkt odtwarzania dźwięku. Obsługuje Safari autoplay policy.

```gdscript
# autoloads/audio_manager.gd
extends Node

var _audio_unlocked: bool = false

# Magistrale audio
var _sfx_bus: int = -1
var _music_bus: int = -1

# Aktywny odtwarzacz muzyki
var _music_player: AudioStreamPlayer = null


func _ready() -> void:
	_sfx_bus = AudioServer.get_bus_index("SFX")
	_music_bus = AudioServer.get_bus_index("Music")

	# Jeśli magistrale nie istnieją — użyj master
	if _sfx_bus == -1:
		_sfx_bus = 0
	if _music_bus == -1:
		_music_bus = 0

	if OS.is_debug_build():
		print("[AudioManager] Gotowy. Bus SFX: ", _sfx_bus, " Music: ", _music_bus)


## Wywołać JEDNORAZOWO po pierwszej interakcji użytkownika (kliknięcie splash screenu).
## Bez tego Safari blokuje dźwięk.
func unlock_audio() -> void:
	if _audio_unlocked:
		return
	_audio_unlocked = true
	EventBus.audio_unlocked.emit()
	if OS.is_debug_build():
		print("[AudioManager] Audio odblokowane")


## Odtwarza efekt dźwiękowy (one-shot).
## stream — załadowany AudioStream (np. preload("res://assets/audio/sfx_correct.ogg"))
func play_sfx(stream: AudioStream) -> void:
	if not _audio_unlocked:
		if OS.is_debug_build():
			push_warning("[AudioManager] Audio zablokowane — pomiń SFX")
		return
	if stream == null:
		push_warning("[AudioManager] Próba odtworzenia null stream")
		return

	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = AudioServer.get_bus_name(_sfx_bus)
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


## Uruchamia muzykę w pętli.
func play_music(stream: AudioStream) -> void:
	if not _audio_unlocked:
		return
	stop_music()
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = stream
	_music_player.bus = AudioServer.get_bus_name(_music_bus)
	add_child(_music_player)
	_music_player.play()


## Zatrzymuje muzykę.
func stop_music() -> void:
	if is_instance_valid(_music_player):
		_music_player.queue_free()
		_music_player = null


## Wycisza/odcisza dźwięki SFX.
func set_sfx_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(_sfx_bus, muted)


## Wycisza/odcisza muzykę.
func set_music_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(_music_bus, muted)
```

---

### 5. `autoloads/scene_manager.gd`

JEDYNE miejsce zmiany scen. Obsługuje przejścia i walidację nazw.

```gdscript
# autoloads/scene_manager.gd
extends Node

# Mapowanie nazw → ścieżki scen
const SCENES: Dictionary = {
	Constants.SCENE_SPLASH: "res://scenes/ui/splash_screen.tscn",
	Constants.SCENE_MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	Constants.SCENE_SESSION: "res://scenes/gameplay/session.tscn",
	Constants.SCENE_SUMMARY: "res://scenes/ui/summary.tscn",
	Constants.SCENE_CONFIG: "res://scenes/ui/config.tscn",
	Constants.SCENE_PROFILE_SELECT: "res://scenes/ui/profile_select.tscn",
	Constants.SCENE_STATS: "res://scenes/ui/stats.tscn",
	Constants.SCENE_REWARDS: "res://scenes/ui/rewards.tscn",
	Constants.SCENE_GALAXY: "res://scenes/ui/galaxy.tscn",
}

var _current_scene: String = ""
var _transitioning: bool = false


## Przechodzi do sceny o podanej nazwie (z Constants.SCENE_*).
func go_to(scene_name: String) -> void:
	if _transitioning:
		push_warning("[SceneManager] Trwa przejście, ignoruję: " + scene_name)
		return

	if not SCENES.has(scene_name):
		push_error("[SceneManager] Nieznana scena: " + scene_name)
		return

	_transitioning = true
	_current_scene = scene_name

	if OS.is_debug_build():
		print("[SceneManager] Przejście do: ", scene_name)

	var tween: Tween = get_tree().create_tween()
	tween.tween_interval(Constants.SCENE_TRANSITION_TIME)
	tween.tween_callback(_do_change_scene.bind(scene_name))


func _do_change_scene(scene_name: String) -> void:
	get_tree().change_scene_to_file(SCENES[scene_name])
	EventBus.scene_changed.emit(scene_name)
	_transitioning = false


## Zwraca nazwę aktualnej sceny.
func get_current() -> String:
	return _current_scene
```

---

### 6. `autoloads/game_state.gd`

Stan runtime aplikacji. Dane sesji, aktywny profil. NIE persystuje — to robi DataManager.

```gdscript
# autoloads/game_state.gd
extends Node

# Aktywny profil (ustawiany na ekranie wyboru profilu)
var current_profile_id: String = ""
var current_profile_name: String = ""

# Konfiguracja sesji (ustawiana na ekranie konfiguracji)
var current_session_config: Resource = null  # SessionConfig — do Epic 3

# Stan aktywnej sesji (tylko podczas sesji)
var current_session_state: Resource = null   # SessionState — do Epic 2


func _ready() -> void:
	if OS.is_debug_build():
		print("[GameState] Inicjalizacja")


## Czy profil jest wybrany.
func has_active_profile() -> bool:
	return current_profile_id != ""


## Czyści stan sesji po zakończeniu.
func clear_session() -> void:
	current_session_config = null
	current_session_state = null
	if OS.is_debug_build():
		print("[GameState] Stan sesji wyczyszczony")
```

---

### 7. `scripts/ui/splash_screen.gd`

Ekran startowy — rozwiązanie Safari audio autoplay policy. Wyświetlany przy każdym starcie.

```gdscript
# scripts/ui/splash_screen.gd
extends Control

# Podłącz w edytorze: przycisk "Dotknij aby zacząć"
@onready var _tap_button: Button = $TapButton
@onready var _version_label: Label = $VersionLabel


func _ready() -> void:
	_tap_button.pressed.connect(_on_tap)
	_version_label.text = "v" + Constants.APP_VERSION

	# Zablokuj input do czasu aż splash jest widoczny
	_tap_button.grab_focus()

	if OS.is_debug_build():
		print("[SplashScreen] Gotowy")


func _on_tap() -> void:
	# KRYTYCZNE: to jest punkt odblokowania audio Safari
	AudioManager.unlock_audio()

	# Sprawdź czy jest zapisany profil — jeśli tak, idź do menu
	# Jeśli nie — idź do wyboru/tworzenia profilu
	if DataManager.has_key(Constants.STORAGE_KEY_PROFILES):
		SceneManager.go_to(Constants.SCENE_MAIN_MENU)
	else:
		SceneManager.go_to(Constants.SCENE_PROFILE_SELECT)
```

---

## Implementacja — pliki Web (PWA)

### 8. `web/manifest.json`

PWA manifest — wymagany dla "Dodaj do ekranu głównego" w Safari.

```json
{
  "name": "MathHero",
  "short_name": "MathHero",
  "description": "Platforma ćwiczeń matematycznych dla dzieci",
  "start_url": "./",
  "display": "fullscreen",
  "orientation": "landscape",
  "background_color": "#0a0a2e",
  "theme_color": "#1a1a4e",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

---

### 9. `web/service_worker.js`

Service Worker — cache dla trybu offline. Aktualizuj `CACHE_VERSION` przy każdym deployu.

```javascript
const CACHE_VERSION = 'mathhero-v1';
const CACHE_NAME = CACHE_VERSION;

// Pliki do cache przy instalacji (core assets)
const PRECACHE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  // Godot generuje te pliki — dodaj po pierwszym eksporcie:
  // './MathHero.js',
  // './MathHero.pck',
  // './MathHero.wasm',
  // './MathHero.audio.worklet.js',
];

// Instalacja — cache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

// Aktywacja — usuń stare wersje cache
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name !== CACHE_NAME)
          .map(name => caches.delete(name))
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch — Cache First, fallback do sieci
self.addEventListener('fetch', (event) => {
  // Tylko GET requests
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;

      return fetch(event.request).then(response => {
        // Cache nowych assetów dynamicznie
        if (response.ok) {
          const cloned = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, cloned));
        }
        return response;
      });
    }).catch(() => {
      // Offline fallback — zwróć index.html dla nawigacji
      if (event.request.destination === 'document') {
        return caches.match('./index.html');
      }
    })
  );
});
```

---

### 10. Rejestracja Service Workera w `index.html`

Po eksporcie HTML5 z Godot, dodaj do sekcji `<head>` w wygenerowanym `index.html`:

```html
<!-- PWA: manifest -->
<link rel="manifest" href="manifest.json">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="MathHero">
<link rel="apple-touch-icon" href="icons/icon-192.png">

<!-- PWA: Service Worker -->
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('./service_worker.js')
        .then(reg => console.log('[SW] Registered:', reg.scope))
        .catch(err => console.error('[SW] Error:', err));
    });
  }
</script>

<!-- Landscape orientation lock (CSS) -->
<style>
  body {
    margin: 0;
    overflow: hidden;
  }
  @media (orientation: portrait) {
    body::before {
      content: "Obróć urządzenie poziomo";
      display: flex;
      justify-content: center;
      align-items: center;
      position: fixed;
      inset: 0;
      background: #0a0a2e;
      color: white;
      font-size: 24px;
      font-family: sans-serif;
      z-index: 9999;
    }
    canvas { display: none; }
  }
</style>
```

---

## Konfiguracja Godot (ręczna — w edytorze)

> Tych kroków nie da się wykonać skryptami — wymagają Godot Editora.

### Nowy projekt

1. **File → New Project**
   - Renderer: **Compatibility** (NIE Forward+, NIE Mobile)
   - Lokalizacja: `MathHero/`

### Project Settings → Autoloads

Dodaj w kolejności (kolejność ma znaczenie — Constants musi być pierwszy):

| Nazwa | Ścieżka |
|---|---|
| `Constants` | `res://autoloads/constants.gd` |
| `EventBus` | `res://autoloads/event_bus.gd` |
| `GameState` | `res://autoloads/game_state.gd` |
| `DataManager` | `res://autoloads/data_manager.gd` |
| `AudioManager` | `res://autoloads/audio_manager.gd` |
| `SceneManager` | `res://autoloads/scene_manager.gd` |

### Project Settings → Display → Window

| Ustawienie | Wartość |
|---|---|
| Viewport Width | `1366` |
| Viewport Height | `1024` |
| Stretch Mode | `canvas_items` |
| Stretch Aspect | `expand` |

### Project Settings → Audio

- Utwórz 2 magistrale: **SFX** i **Music** (oprócz domyślnego Master)

### Export → HTML5

1. **Project → Export → Add → Web**
2. Export Path: `../docs/index.html` (GitHub Pages serwuje z `/docs`)
3. Sprawdź że **Godot Export Templates** dla wersji 4.5.2 są zainstalowane

### Splash Screen (scena startowa)

1. Utwórz scenę: `scenes/ui/splash_screen.tscn`
   - Root node: `Control` (full rect)
   - Dodaj `Button` jako `TapButton` (tekst: "Dotknij, aby zacząć")
   - Dodaj `Label` jako `VersionLabel`
   - Przypisz skrypt: `scripts/ui/splash_screen.gd`
2. Ustaw jako główną scenę: **Project Settings → Application → Run → Main Scene**

---

## GitHub Pages — konfiguracja

```bash
# W katalogu projektu (poziom wyżej niż MathHero/)
git init
git add .
git commit -m "Initial MathHero project"

# Na GitHub: Utwórz repo, następnie:
git remote add origin https://github.com/TWOJ_USER/mathhero.git
git push -u origin main

# Settings → Pages → Source: Deploy from branch → main → /docs
```

> Godot eksportuje do `docs/` (skonfigurowane wyżej). GitHub Pages serwuje z `/docs`.

---

## Test na iPad Air 2 — checklist

Po deployu na GitHub Pages:

- [ ] Otwórz URL w Safari na iPadzie
- [ ] Kliknij "Dodaj do ekranu głównego"
- [ ] Uruchom z ekranu głównego (pełny ekran)
- [ ] Wyłącz Wi-Fi → odśwież → aplikacja nadal działa (offline)
- [ ] Dotknij przycisku → sprawdź czy AudioManager nie rzuca warningów
- [ ] Obróć do portretu → pojawia się overlay "Obróć urządzenie"
- [ ] Obróć z powrotem do landscape → aplikacja wraca normalnie
- [ ] Otwórz Safari DevTools (Mac → Develop → iPad) → sprawdź localStorage

---

## Zależności i kolejność implementacji

```
1. Stwórz strukturę folderów
2. Napisz constants.gd           ← brak zależności
3. Napisz event_bus.gd           ← brak zależności
4. Napisz game_state.gd          ← zależy od Constants
5. Napisz data_manager.gd        ← zależy od Constants
6. Napisz audio_manager.gd       ← zależy od Constants, EventBus
7. Napisz scene_manager.gd       ← zależy od Constants, EventBus
8. Napisz splash_screen.gd       ← zależy od wszystkich autoloadów
9. Stwórz web/manifest.json
10. Stwórz web/service_worker.js
11. Konfiguracja w Godot Editorze (ręczna)
12. Eksport HTML5 → docs/
13. Modyfikacja index.html (PWA tags + SW rejestracja)
14. Deploy na GitHub Pages
15. Test na iPad Air 2
```

---

## Pliki do stworzenia przez Claude (gotowy kod)

| Plik | Status |
|---|---|
| `autoloads/constants.gd` | ✅ Gotowy w tym spec |
| `autoloads/event_bus.gd` | ✅ Gotowy w tym spec |
| `autoloads/game_state.gd` | ✅ Gotowy w tym spec |
| `autoloads/data_manager.gd` | ✅ Gotowy w tym spec |
| `autoloads/audio_manager.gd` | ✅ Gotowy w tym spec |
| `autoloads/scene_manager.gd` | ✅ Gotowy w tym spec |
| `scripts/ui/splash_screen.gd` | ✅ Gotowy w tym spec |
| `web/manifest.json` | ✅ Gotowy w tym spec |
| `web/service_worker.js` | ✅ Gotowy w tym spec |
| `web/index.html` (fragmenty) | ✅ Gotowy w tym spec |
| `project.godot` | ❌ Tworzy Godot Editor |
| `scenes/ui/splash_screen.tscn` | ❌ Tworzy Godot Editor |

---

_Tech-spec stworzony: 2026-03-22_
_Następny krok: Implementacja — stworzenie plików GDScript i web/_
