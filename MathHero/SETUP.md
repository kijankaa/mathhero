# MathHero — Instrukcja konfiguracji Godot

## Krok 1: Nowy projekt Godot

1. Pobierz **Godot 4.5.2** ze strony: https://godotengine.org/download/
2. Otwórz Godot → **New Project**
   - Project Name: `MathHero`
   - Project Path: ten katalog (`MathHero/`)
   - Renderer: **Compatibility** ← KRYTYCZNE (NIE Forward+, NIE Mobile)
3. Kliknij **Create & Edit**

---

## Krok 2: Autoloads (Project Settings → Autoload)

Dodaj w TEJ KOLEJNOŚCI (kolejność ma znaczenie):

| Nazwa | Ścieżka | Singleton |
|---|---|---|
| `Constants` | `res://autoloads/constants.gd` | ✅ |
| `EventBus` | `res://autoloads/event_bus.gd` | ✅ |
| `GameState` | `res://autoloads/game_state.gd` | ✅ |
| `DataManager` | `res://autoloads/data_manager.gd` | ✅ |
| `AudioManager` | `res://autoloads/audio_manager.gd` | ✅ |
| `SceneManager` | `res://autoloads/scene_manager.gd` | ✅ |

---

## Krok 3: Display Settings (Project Settings → Display → Window)

| Ustawienie | Wartość |
|---|---|
| Viewport Width | `1366` |
| Viewport Height | `1024` |
| Stretch Mode | `canvas_items` |
| Stretch Aspect | `expand` |

---

## Krok 4: Magistrale audio (Project Settings → Audio)

Utwórz 2 magistrale (Add Bus):
- `SFX`
- `Music`

(Master pozostaje bez zmian)

---

## Krok 5: Scena Splash Screen

1. **Scene → New Scene**
2. Root node: `Control`
   - Rename na `SplashScreen`
   - Layout: **Full Rect** (Ctrl+L)
   - Background color: `#0a0a2e` (dodaj ColorRect jako pierwsze dziecko)
3. Dodaj dzieci do SplashScreen:
   - `Button` → rename na `TapButton`
     - Text: `Dotknij, aby zacząć`
     - Anchors: wyśrodkuj na ekranie
     - Min size: 300×80
   - `Label` → rename na `VersionLabel`
     - Text: `v0.1.0` (skrypt to nadpisze)
     - Anchors: prawy dolny róg
4. Przypisz skrypt: **Attach Script** → `scripts/ui/splash_screen.gd`
5. Zapisz jako: `res://scenes/ui/splash_screen.tscn`

6. Ustaw jako główną scenę:
   **Project Settings → Application → Run → Main Scene** → `res://scenes/ui/splash_screen.tscn`

---

## Krok 6: Eksport HTML5

1. **Project → Export → Add → Web**
2. Export Path: `../../docs/index.html`
   (GitHub Pages serwuje z `/docs` — katalog nadrzędny względem `MathHero/`)
3. Zainstaluj Export Templates jeśli wymagane: **Editor → Manage Export Templates**
4. Kliknij **Export Project** (nie "Export PCK")

---

## Krok 7: Przygotuj docs/ do deployu

```
Skopiuj do docs/:
  - index.html      (wygenerowany przez Godot)
  - MathHero.js
  - MathHero.pck
  - MathHero.wasm
  - MathHero.audio.worklet.js
  - web/manifest.json
  - web/service_worker.js
  - web/icons/icon-192.png
  - web/icons/icon-512.png
```

Następnie **edytuj** `docs/index.html` — wklej zawartość `web/pwa_index_patch.html`
do sekcji `<head>`, przed `</head>`.

Zaktualizuj `web/service_worker.js` — odkomentuj nazwy plików Godot w `PRECACHE_URLS`.

---

## Krok 8: GitHub Pages

```bash
git init
git add .
git commit -m "Epic 1: Fundament Techniczny"
git remote add origin https://github.com/TWOJ_USER/mathhero.git
git push -u origin main
```

Na GitHub: **Settings → Pages → Source: Deploy from branch → main → /docs**

Po ~2 minutach aplikacja dostępna pod: `https://TWOJ_USER.github.io/mathhero/`

---

## Krok 9: Test na iPad Air 2

- [ ] Otwórz URL w Safari
- [ ] Share → Dodaj do ekranu głównego
- [ ] Uruchom z home screen → pełny ekran, landscape
- [ ] Wyłącz Wi-Fi → aplikacja działa offline
- [ ] Dotknij przycisku → console nie pokazuje błędów audio
- [ ] Obróć do portretu → pojawia się overlay "Obróć urządzenie"

---

## Weryfikacja DataManager (opcjonalna)

W splash_screen.gd tymczasowo dodaj do `_on_tap()`:

```gdscript
# Test DataManager
DataManager.save("test_key", {"hello": "MathHero", "version": 1})
var result = DataManager.load_data("test_key")
print("[TEST] localStorage: ", result)
DataManager.delete("test_key")
```

Sprawdź w Safari DevTools (Mac → Develop → [iPad] → Console).
