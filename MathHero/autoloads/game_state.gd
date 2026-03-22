# autoloads/game_state.gd
# Stan runtime aplikacji — aktywny profil, konfiguracja sesji, stan sesji.
# NIE persystuje danych — to robi DataManager.
# NIE trzymaj kopii danych profilu w scenach — zawsze GameState.current_profile_id
extends Node

# Aktywny profil (ustawiany na ekranie wyboru profilu)
var current_profile: PlayerProfile = null

# Konfiguracja sesji (ustawiana na ekranie konfiguracji) — do Epic 3
var current_session_config: Resource = null

# Stan aktywnej sesji (tylko podczas sesji) — do Epic 2
var current_session_state: Resource = null

# Wynik ostatniej sesji (odczytywany przez Summary)
var last_session_result: Resource = null


func _ready() -> void:
	if OS.is_debug_build():
		print("[GameState] Inicjalizacja")


## Ustawia aktywny profil.
func set_profile(profile: PlayerProfile) -> void:
	current_profile = profile
	EventBus.profile_selected.emit(profile.id)
	if OS.is_debug_build():
		print("[GameState] Profil ustawiony: ", profile.name)


## Czy profil jest wybrany.
func has_active_profile() -> bool:
	return current_profile != null


## Czyści stan sesji po zakończeniu.
func clear_session() -> void:
	current_session_config = null
	current_session_state = null
	if OS.is_debug_build():
		print("[GameState] Stan sesji wyczyszczony")
