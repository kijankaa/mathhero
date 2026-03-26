# scripts/ui/main_menu.gd
extends Control

@onready var _play_button: Button = $PlayButton
@onready var _rewards_button: Button = $RewardsButton
@onready var _galaxy_button: Button = $GalaxyButton
@onready var _stats_button: Button = $StatsButton
@onready var _config_button: Button = $ConfigButton
@onready var _astronaut_display: Control = $AstronautDisplay


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_config_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_CONFIG))
	_rewards_button.pressed.connect(_on_rewards_pressed)
	_galaxy_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_GALAXY))
	_stats_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_STATS))

	if GameState.has_active_profile():
		_astronaut_display.refresh(GameState.current_profile)

	if OS.is_debug_build():
		print("[MainMenu] Gotowy")


func _on_play_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_rewards_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_REWARDS)
