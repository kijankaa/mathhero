# autoloads/scene_manager.gd
# JEDYNE miejsce zmiany scen w aplikacji.
# Używaj SceneManager.go_to(Constants.SCENE_*) — nigdy get_tree().change_scene_to_file() bezpośrednio.
extends Node

# Mapowanie nazw → ścieżki scen
const SCENES: Dictionary = {
	Constants.SCENE_SPLASH:          "res://scenes/ui/splash_screen.tscn",
	Constants.SCENE_MAIN_MENU:       "res://scenes/ui/main_menu.tscn",
	Constants.SCENE_SESSION:         "res://scenes/gameplay/session.tscn",
	Constants.SCENE_SUMMARY:         "res://scenes/ui/summary.tscn",
	Constants.SCENE_CONFIG:          "res://scenes/ui/config.tscn",
	Constants.SCENE_PROFILE_SELECT:  "res://scenes/ui/profile_select.tscn",
	Constants.SCENE_STATS:           "res://scenes/ui/stats.tscn",
	Constants.SCENE_REWARDS:         "res://scenes/ui/rewards.tscn",
	Constants.SCENE_GALAXY:          "res://scenes/ui/galaxy.tscn",
}

var _current_scene: String = ""
var _transitioning: bool = false


## Przechodzi do sceny o podanej nazwie (Constants.SCENE_*).
## Ignoruje wywołanie jeśli trwa już przejście.
func go_to(scene_name: String) -> void:
	if _transitioning:
		push_warning("[SceneManager] Trwa przejście, ignoruję: " + scene_name)
		return

	if not SCENES.has(scene_name):
		push_error("[SceneManager] Nieznana scena: " + scene_name)
		return

	_transitioning = true

	if OS.is_debug_build():
		print("[SceneManager] Przejście: ", _current_scene, " → ", scene_name)

	var tween: Tween = get_tree().create_tween()
	tween.tween_interval(Constants.SCENE_TRANSITION_TIME)
	tween.tween_callback(_do_change_scene.bind(scene_name))


func _do_change_scene(scene_name: String) -> void:
	_current_scene = scene_name
	get_tree().change_scene_to_file(SCENES[scene_name])
	EventBus.scene_changed.emit(scene_name)
	_transitioning = false


## Zwraca nazwę aktualnej sceny.
func get_current() -> String:
	return _current_scene


## Czy trwa przejście między scenami.
func is_transitioning() -> bool:
	return _transitioning
