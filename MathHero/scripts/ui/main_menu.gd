# scripts/ui/main_menu.gd
extends Control

@onready var _play_button: Button = $PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)

	if OS.is_debug_build():
		print("[MainMenu] Gotowy")


func _on_play_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)
