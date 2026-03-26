# autoloads/constants.gd
# Wszystkie stałe aplikacji. Zero magic numbers w reszcie kodu.
extends Node

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
const SCENE_PROFILE_CREATE: String = "profile_create"
const SCENE_STATS: String = "stats"
const SCENE_REWARDS: String = "rewards"
const SCENE_GALAXY: String = "galaxy"
const SCENE_ONBOARDING: String = "onboarding"

# Klucze storage — Epic 8
const STORAGE_KEY_ONBOARDING: String = "mathhero_onboarding_done"

# Audio — ścieżki plików (null-safe: brak pliku = cisza)
const SFX_CORRECT: String = "res://assets/audio/sfx_correct.ogg"
const SFX_WRONG: String = "res://assets/audio/sfx_wrong.ogg"
const SFX_STREAK: String = "res://assets/audio/sfx_streak.ogg"
const SFX_FANFARE: String = "res://assets/audio/sfx_fanfare.ogg"
const SFX_CLICK: String = "res://assets/audio/sfx_click.ogg"
const MUSIC_AMBIENT: String = "res://assets/audio/music_ambient.ogg"

# Typy operacji matematycznych
const OP_ADDITION: String = "addition"
const OP_SUBTRACTION: String = "subtraction"
const OP_MULTIPLICATION: String = "multiplication"
const OP_DIVISION: String = "division"
const OP_ORDER_OF_OPERATIONS: String = "order_of_operations"

# Domyślne zakresy per operacja
const OP_DEFAULT_RANGES: Dictionary = {
	"addition":            {"min": 1, "max": 100},
	"subtraction":         {"min": 1, "max": 100},
	"multiplication":      {"min": 1, "max": 12},
	"division":            {"min": 1, "max": 12},
	"order_of_operations": {"min": 1, "max": 20},
	"mixed":               {"min": 1, "max": 20},
}

# Avatary profilu
const AVATARS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

# Walidacja konfiguracji sesji
const CONFIG_MIN_VALUE_MIN: int = 1
const CONFIG_MIN_VALUE_MAX: int = 199
const CONFIG_MAX_VALUE_MIN: int = 2
const CONFIG_MAX_VALUE_MAX: int = 200
const CONFIG_QUESTION_COUNT_MIN: int = 5
const CONFIG_QUESTION_COUNT_MAX: int = 50
const CONFIG_TIME_LIMIT_MIN: float = 5.0
const CONFIG_TIME_LIMIT_MAX: float = 120.0

# Punkty i nagrody
const STARS_PER_PERFECT: int = 3
const STARS_PER_GOOD: int = 2
const STARS_PER_PASS: int = 1
const SCORE_THRESHOLD_PERFECT: float = 0.95
const SCORE_THRESHOLD_GOOD: float = 0.75
const SCORE_THRESHOLD_PASS: float = 0.5
