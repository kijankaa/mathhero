---
title: 'Epic 8: Polish i UX'
slug: 'epic-8-polish'
created: '2026-03-26'
status: 'in-progress'
stepsCompleted: [1, 2, 3]
tech_stack: ['GDScript', 'Godot 4.6', 'SVG', 'CPUParticles2D', 'Tween']
files_to_create:
  - MathHero/assets/images/astronaut.svg
  - MathHero/assets/images/bg_stars.svg
  - MathHero/scripts/components/space_background.gd
  - MathHero/scenes/components/space_background.tscn
  - MathHero/scripts/components/particles_correct.gd
  - MathHero/scenes/components/particles_correct.tscn
  - MathHero/scripts/ui/onboarding.gd
  - MathHero/scenes/ui/onboarding.tscn
files_to_modify:
  - MathHero/autoloads/constants.gd
  - MathHero/autoloads/scene_manager.gd
  - MathHero/scripts/ui/profile_create.gd
  - MathHero/scripts/gameplay/session_controller.gd
  - MathHero/scenes/gameplay/session.tscn
  - MathHero/scenes/ui/main_menu.tscn
  - MathHero/scenes/ui/summary.tscn
  - MathHero/scenes/ui/galaxy.tscn
  - MathHero/scenes/ui/stats.tscn
  - MathHero/scenes/ui/rewards.tscn
---

# Tech-Spec: Epic 8 — Polish i UX

**Created:** 2026-03-26

## Overview

### Problem Statement

Gra wygląda ascetycznie — granatowe tło, biały tekst, zero grafiki i animacji. Brak onboardingu dla nowego gracza.

### Solution

Dodać tło kosmiczne (SVG + animowane gwiazdy), cartoon astronautę, efekty cząsteczkowe na poprawną odpowiedź, animacje przycisków, onboarding po stworzeniu pierwszego profilu oraz stub audio (wywołania play_sfx w kluczowych momentach — pliki .ogg dostarczy Jarek).

### Scope

**W zakresie:**
- `bg_stars.svg` + `SpaceBackground` — reużywalna scena tła na wszystkich ekranach
- `astronaut.svg` — cartoon astronauta widoczny w MainMenu i Rewards
- `CPUParticles2D` — efekt gwiazdek przy poprawnej odpowiedzi w sesji
- Animacje Tween — feedback przy poprawnej/błędnej odpowiedzi (skala/kolor)
- Onboarding — 4 slajdy po stworzeniu pierwszego profilu (przed głównym menu)
- Audio stub — stałe ścieżek + wywołania play_sfx/play_music (null-safe, pliki dostarczane przez Jarka)

**Poza zakresem:**
- Pliki audio .ogg (dostarcza Jarek z freesound/opengameart)
- Animacja idle bohatera (klatki animacji)
- Efekty 3D / shadery

---

## Context for Development

### Codebase Patterns

- **CPUParticles2D** — TYLKO CPU particles (GPUParticles2D wolne na iPad Air 2 / A8X)
- **Tween** — `get_tree().create_tween()` zamiast AnimationPlayer dla prostych animacji
- **SVG** — Godot 4 importuje SVG natywnie jako Texture2D; umieść w `assets/images/`
- **AudioManager.play_sfx(stream)** — stream może być null (graceful skip — już obsługuje)
- **SceneManager.SCENES** — każda nowa scena musi być zarejestrowana
- **SpaceBackground** — dodaj jako pierwsze dziecko (za ColorRect) w każdej scenie

### Files to Reference

| Plik | Cel |
|---|---|
| `autoloads/audio_manager.gd` | play_sfx/play_music — null-safe |
| `autoloads/constants.gd` | Dodać SCENE_ONBOARDING + STORAGE_KEY_ONBOARDING + ścieżki audio |
| `autoloads/scene_manager.gd` | Zarejestrować SCENE_ONBOARDING |
| `scripts/ui/profile_create.gd` | Przekieruj do onboardingu przy pierwszym profilu |
| `scripts/gameplay/session_controller.gd` | Dodać particles + play_sfx |

### Technical Decisions

1. **SpaceBackground** — `Control` node z `_draw()`, rysuje 80 losowych gwiazd (kropki różnych rozmiarów, biały/niebieski kolor), subtelne migotanie przez Tween. NIE używaj TextureRect z SVG dla tła — rysuj programatycznie dla wydajności.

2. **Astronaut SVG** — CartoonTexture2D w `TextureRect`, widoczny w MainMenu (lewy dolny róg, 150x200px) i w zakładce Bohater w Rewards.

3. **Onboarding trigger** — w `profile_create.gd` po zapisaniu profilu: sprawdź `DataManager.load_data(Constants.STORAGE_KEY_ONBOARDING)`. Jeśli null → idź do `SCENE_ONBOARDING`. Jeśli istnieje → idź do `SCENE_MAIN_MENU`. Onboarding na końcu zapisuje flagę i przechodzi do `SCENE_MAIN_MENU`.

4. **Particles** — `CPUParticles2D` jako dziecko sceny sesji. `amount=20`, `lifetime=1.0`, kolor żółty/złoty, kierunek w górę. Emituj przez `restart()` przy poprawnej odpowiedzi.

5. **Audio stubs** — Dodaj do Constants ścieżki (np. `SFX_CORRECT = "res://assets/audio/sfx_correct.ogg"`). W `session_controller` ładuj przez `load()` z try-graceful: jeśli plik nie istnieje zwraca null, `play_sfx(null)` jest już obsługiwane.

6. **Feedback animacja** — przy poprawnej: `QuestionDisplay` skaluje się do 1.1 i wraca (0.15s). Przy błędnej: trzęsie się w poziomie (shake, 0.2s). Przez Tween.

---

## Implementation Plan

### Tasks

#### Zadanie 1 — `constants.gd`: nowe stałe

**Plik:** `MathHero/autoloads/constants.gd`

Dodaj:
```gdscript
const SCENE_ONBOARDING: String = "onboarding"
const STORAGE_KEY_ONBOARDING: String = "mathhero_onboarding_done"

# Audio — ścieżki plików (null-safe: brak pliku = cisza)
const SFX_CORRECT: String = "res://assets/audio/sfx_correct.ogg"
const SFX_WRONG: String = "res://assets/audio/sfx_wrong.ogg"
const SFX_STREAK: String = "res://assets/audio/sfx_streak.ogg"
const SFX_FANFARE: String = "res://assets/audio/sfx_fanfare.ogg"
const SFX_CLICK: String = "res://assets/audio/sfx_click.ogg"
const MUSIC_AMBIENT: String = "res://assets/audio/music_ambient.ogg"
```

---

#### Zadanie 2 — `scene_manager.gd`: rejestracja onboardingu

**Plik:** `MathHero/autoloads/scene_manager.gd`

Dodaj do `SCENES`:
```gdscript
Constants.SCENE_ONBOARDING: "res://scenes/ui/onboarding.tscn",
```

---

#### Zadanie 3 — `bg_stars.svg`: tło kosmiczne (asset)

**Plik:** `MathHero/assets/images/bg_stars.svg`

Prosty SVG z granatowym gradientem i 60 białymi kropkami (gwiazdy). Używany jako TextureRect backup — główne tło rysowane programatycznie przez SpaceBackground.

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="1366" height="1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#050514"/>
      <stop offset="100%" stop-color="#0a0a2e"/>
    </linearGradient>
  </defs>
  <rect width="1366" height="1024" fill="url(#bg)"/>
  <!-- gwiazdy generowane jako circle elementy -->
</svg>
```

(Pełna zawartość — patrz implementacja)

---

#### Zadanie 4 — `astronaut.svg`: cartoon astronauta (asset)

**Plik:** `MathHero/assets/images/astronaut.svg`

Cartoon astronauta: biały skafander, niebieski wizjer, żółte detale. Widok frontalny. Wymiary 200x280.

(Pełna zawartość SVG — patrz implementacja)

---

#### Zadanie 5 — `space_background.gd` + `space_background.tscn`: reużywalne tło

**Plik:** `MathHero/scripts/components/space_background.gd`

```gdscript
# scripts/components/space_background.gd
extends Control

const STAR_COUNT: int = 80

var _stars: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
    _generate_stars()
    set_process(true)


func _generate_stars() -> void:
    _stars.clear()
    var rng := RandomNumberGenerator.new()
    rng.seed = 42  # deterministyczne — te same gwiazdy zawsze
    for i: int in STAR_COUNT:
        _stars.append({
            "x": rng.randf(),
            "y": rng.randf(),
            "size": rng.randf_range(1.0, 3.0),
            "brightness": rng.randf_range(0.5, 1.0),
            "speed": rng.randf_range(0.3, 1.2),
            "offset": rng.randf_range(0.0, TAU),
        })


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _draw() -> void:
    var w: float = size.x
    var h: float = size.y

    # Gradient tło
    draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.02, 0.11))

    # Gwiazdy z migotaniem
    for star: Dictionary in _stars:
        var alpha: float = star["brightness"] * (0.6 + 0.4 * sin(_time * star["speed"] + star["offset"]))
        var color: Color = Color(0.8, 0.9, 1.0, alpha)
        var pos: Vector2 = Vector2(star["x"] * w, star["y"] * h)
        draw_circle(pos, star["size"], color)
```

**Plik:** `MathHero/scenes/components/space_background.tscn`

```
[gd_scene format=3]
[ext_resource type="Script" path="res://scripts/components/space_background.gd" id="1"]

[node name="SpaceBackground" type="Control"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
script = ExtResource("1")
```

---

#### Zadanie 6 — `particles_correct.gd` + `particles_correct.tscn`

**Plik:** `MathHero/scripts/components/particles_correct.gd`

```gdscript
# scripts/components/particles_correct.gd
extends CPUParticles2D

func emit_burst() -> void:
    restart()
    emitting = true
```

**Plik:** `MathHero/scenes/components/particles_correct.tscn`

```
[gd_scene format=3]
[ext_resource type="Script" path="res://scripts/components/particles_correct.gd" id="1"]

[node name="ParticlesCorrect" type="CPUParticles2D"]
emitting = false
amount = 24
lifetime = 0.8
one_shot = true
explosiveness = 0.9
direction = Vector2(0, -1)
spread = 60.0
gravity = Vector2(0, 200)
initial_velocity_min = 150.0
initial_velocity_max = 300.0
color = Color(1, 0.85, 0.1, 1)
scale_amount_min = 4.0
scale_amount_max = 8.0
script = ExtResource("1")
```

---

#### Zadanie 7 — `session.tscn`: dodaj particles + SpaceBackground

**Plik:** `MathHero/scenes/gameplay/session.tscn`

- Dodaj `SpaceBackground` jako pierwsze dziecko (przed lub zaraz po ColorRect, z `mouse_filter=2`)
- Dodaj `ParticlesCorrect` jako dziecko sceny (pozycja centralna, np. `position = Vector2(683, 400)`)
- Usuń lub zostaw ColorRect (SpaceBackground go zastępuje wizualnie)

---

#### Zadanie 8 — `session_controller.gd`: particles + sfx + feedback animacja

**Plik:** `MathHero/scripts/gameplay/session_controller.gd`

**8a. Dodaj @onready:**
```gdscript
@onready var _particles: CPUParticles2D = $ParticlesCorrect
```

**8b. Dodaj zmienną na poziomie klasy:**
```gdscript
var _sfx_correct: AudioStream = null
var _sfx_wrong: AudioStream = null
var _sfx_streak: AudioStream = null
```

**8c. W `_ready()` załaduj audio (null-safe):**
```gdscript
if ResourceLoader.exists(Constants.SFX_CORRECT):
    _sfx_correct = load(Constants.SFX_CORRECT)
if ResourceLoader.exists(Constants.SFX_WRONG):
    _sfx_wrong = load(Constants.SFX_WRONG)
if ResourceLoader.exists(Constants.SFX_STREAK):
    _sfx_streak = load(Constants.SFX_STREAK)
```

**8d. W `_process_answer()`, blok `if correct:`:**
```gdscript
AudioManager.play_sfx(_sfx_streak if _state.streak >= 3 else _sfx_correct)
if is_instance_valid(_particles):
    _particles.emit_burst()
_animate_feedback_correct()
```

**8e. W `_process_answer()`, blok `else:`:**
```gdscript
AudioManager.play_sfx(_sfx_wrong)
_animate_feedback_wrong()
```

**8f. Nowe metody animacji:**
```gdscript
func _animate_feedback_correct() -> void:
    var tween: Tween = get_tree().create_tween()
    tween.tween_property(_question_display, "scale", Vector2(1.1, 1.1), 0.1)
    tween.tween_property(_question_display, "scale", Vector2(1.0, 1.0), 0.1)


func _animate_feedback_wrong() -> void:
    var original_pos: Vector2 = _question_display.position
    var tween: Tween = get_tree().create_tween()
    tween.tween_property(_question_display, "position",
        original_pos + Vector2(12, 0), 0.05)
    tween.tween_property(_question_display, "position",
        original_pos - Vector2(12, 0), 0.05)
    tween.tween_property(_question_display, "position",
        original_pos + Vector2(8, 0), 0.04)
    tween.tween_property(_question_display, "position",
        original_pos, 0.04)
```

---

#### Zadanie 9 — SpaceBackground na pozostałych scenach

Dla każdej sceny: `main_menu.tscn`, `summary.tscn`, `galaxy.tscn`, `stats.tscn`, `rewards.tscn`, `profile_select.tscn`, `profile_create.tscn`, `session_config.tscn` — dodaj instancję SpaceBackground jako pierwsze dziecko (po ColorRect lub zamiast niego).

Format wpisu w .tscn:
```
[ext_resource type="PackedScene" path="res://scenes/components/space_background.tscn" id="X_bg"]
...
[node name="SpaceBackground" parent="." instance=ExtResource("X_bg")]
layout_mode = 1
```

---

#### Zadanie 10 — `main_menu.tscn`: astronauta

Dodaj `TextureRect` z `astronaut.svg` w lewym dolnym rogu:
```
[ext_resource type="Texture2D" path="res://assets/images/astronaut.svg" id="X_astro"]

[node name="AstronautTexture" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 2
anchor_top = 1.0
anchor_bottom = 1.0
offset_left = 20.0
offset_top = -220.0
offset_right = 180.0
offset_bottom = -20.0
texture = ExtResource("X_astro")
expand_mode = 1
stretch_mode = 5
```

---

#### Zadanie 11 — `onboarding.gd` + `onboarding.tscn`

**Plik:** `MathHero/scripts/ui/onboarding.gd`

```gdscript
# scripts/ui/onboarding.gd
extends Control

@onready var _slide_label: Label = $SlideLabel
@onready var _title_label: Label = $TitleLabel
@onready var _next_button: Button = $NextButton
@onready var _skip_button: Button = $SkipButton
@onready var _dots_container: HBoxContainer = $DotsContainer

const SLIDES: Array[Dictionary] = [
    {
        "title": "Witaj w MathHero! 🚀",
        "text": "Ćwicz matematykę w kosmicznej przygodzie.\nZdobywaj gwiazdki i odblokuj planety!",
    },
    {
        "title": "Jak grać? 🧮",
        "text": "Zobaczysz zadanie matematyczne.\nWpisz odpowiedź klawiaturą lub wybierz spośród opcji.\nCzym szybciej — tym więcej punktów!",
    },
    {
        "title": "Nagrody i postępy ⭐",
        "text": "Za każdą sesję zdobywasz gwiazdki.\nKupuj kostiumy dla astronauty\ni zdobywaj odznaki za osiągnięcia!",
    },
    {
        "title": "Galaktyka Misji 🌌",
        "text": "Ukończaj misje planetarne w odpowiedniej kolejności.\nCodziennie czeka na Ciebie wyzwanie dnia!\nPowodzenia, MathHero!",
    },
]

var _current: int = 0


func _ready() -> void:
    _next_button.pressed.connect(_on_next_pressed)
    _skip_button.pressed.connect(_finish)
    _show_slide(0)
    if OS.is_debug_build():
        print("[Onboarding] Gotowy")


func _show_slide(index: int) -> void:
    _current = index
    var slide: Dictionary = SLIDES[index]
    _title_label.text = slide["title"]
    _slide_label.text = slide["text"]
    _next_button.text = "Dalej →" if index < SLIDES.size() - 1 else "Zaczynamy! 🚀"
    _update_dots()


func _update_dots() -> void:
    for i: int in _dots_container.get_child_count():
        var dot: Control = _dots_container.get_child(i)
        dot.modulate = Color.WHITE if i == _current else Color(1, 1, 1, 0.3)


func _on_next_pressed() -> void:
    if _current < SLIDES.size() - 1:
        _current += 1
        _show_slide(_current)
    else:
        _finish()


func _finish() -> void:
    DataManager.save(Constants.STORAGE_KEY_ONBOARDING, true)
    SceneManager.go_to(Constants.SCENE_MAIN_MENU)
```

**Plik:** `MathHero/scenes/ui/onboarding.tscn` — struktura:

```
Onboarding (Control, fullscreen, script=onboarding.gd)
├── SpaceBackground (instance)
├── CenterContainer (anchors=center)
│   └── VBox (VBoxContainer, separation=30)
│       ├── TitleLabel (Label, font_size=28, h_align=center)
│       ├── SlideLabel (Label, font_size=18, h_align=center, autowrap, min_size=(600,120))
│       └── DotsContainer (HBoxContainer, alignment=center, separation=12)
│           └── [4x ColorRect, size=12x12, color=white] (tworzone statycznie)
├── NextButton (Button, anchors=bottom-center, offset_top=-80, text="Dalej →", font_size=22)
└── SkipButton (Button, anchors=bottom-right, offset=-20 -20, text="Pomiń", font_size=16)
```

---

#### Zadanie 12 — `profile_create.gd`: trigger onboardingu

**Plik:** `MathHero/scripts/ui/profile_create.gd`

Zmień w `_on_save_pressed()` ostatnią linię:
```gdscript
# Było:
SceneManager.go_to(Constants.SCENE_MAIN_MENU)

# Teraz:
var onboarding_done: Variant = DataManager.load_data(Constants.STORAGE_KEY_ONBOARDING)
if onboarding_done == null:
    SceneManager.go_to(Constants.SCENE_ONBOARDING)
else:
    SceneManager.go_to(Constants.SCENE_MAIN_MENU)
```

---

### Acceptance Criteria

**AC1 — Tło kosmiczne:**
- Given: dowolny ekran gry
- When: ekran jest wyświetlony
- Then: widoczne granatowe tło z migoczącymi gwiazdami

**AC2 — Particles przy poprawnej odpowiedzi:**
- Given: gracz odpowiada poprawnie w sesji
- When: odpowiedź jest zatwierdzona
- Then: widoczny burst złotych cząsteczek przez ~0.8s

**AC3 — Animacja poprawna:**
- Given: poprawna odpowiedź
- When: feedback
- Then: QuestionDisplay pulsuje (skala 1.0→1.1→1.0 w 0.2s)

**AC4 — Animacja błędna:**
- Given: błędna odpowiedź
- When: feedback
- Then: QuestionDisplay trzęsie się w poziomie (shake w 0.18s)

**AC5 — Onboarding przy pierwszym profilu:**
- Given: brak flagi `mathhero_onboarding_done` w storage
- When: nowy profil jest tworzony
- Then: wyświetlają się 4 slajdy onboardingu

**AC6 — Onboarding nie powtarza się:**
- Given: flaga `mathhero_onboarding_done` istnieje
- When: tworzony jest kolejny profil
- Then: onboarding jest pomijany, przejście do main menu

**AC7 — Astronauta w main menu:**
- Given: główne menu
- When: wyświetlone
- Then: widoczna postać astronauty w lewym dolnym rogu

**AC8 — Audio stub (null-safe):**
- Given: brak plików .ogg w assets/audio/
- When: poprawna/błędna odpowiedź
- Then: brak błędów, gra działa normalnie (cisza)

---

## Additional Context

### Dependencies

- SpaceBackground musi być stworzony (Zad 5) przed dodaniem do scen (Zad 9)
- ParticlesCorrect musi być stworzony (Zad 6) przed modyfikacją session.tscn (Zad 7)
- Constants muszą być zaktualizowane (Zad 1) przed wszystkim
- Onboarding.tscn (Zad 11) musi być zarejestrowany (Zad 2) przed trigger (Zad 12)

### Testing Strategy

1. Uruchom grę → sprawdź migoczące gwiazdy na każdym ekranie
2. Zagraj sesję → sprawdź burst cząsteczek + animacje feedback
3. Stwórz nowy profil (wyczyść storage lub użyj nowego) → sprawdź 4 slajdy onboardingu
4. Stwórz drugi profil → onboarding NIE powinien się pokazać
5. Sprawdź czy gra działa bez plików audio (brak błędów)

### Notes

- `mouse_filter = 2` (MOUSE_FILTER_IGNORE) na SpaceBackground — NIE blokuje kliknięć
- `rng.seed = 42` — deterministyczne gwiazdy, te same na każdym uruchomieniu (brak random każdy frame)
- Dots w onboardingu: 4 statyczne ColorRect (nie tworzone dynamicznie) dla prostoty
- `set_process(true)` w SpaceBackground — wywoła `_process()` co klatkę dla animacji migotania
