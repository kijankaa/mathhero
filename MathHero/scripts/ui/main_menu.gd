# scripts/ui/main_menu.gd
extends Control

@onready var _play_button: Button = $PlayButton
@onready var _rewards_button: Button = $RewardsButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_rewards_button.pressed.connect(_on_rewards_pressed)

	if OS.is_debug_build():
		print("[MainMenu] Gotowy")


func _on_play_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_rewards_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_REWARDS)
