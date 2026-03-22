# autoloads/constants.gd
# Wszystkie stałe aplikacji. Zero magic numbers w reszcie kodu.

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
