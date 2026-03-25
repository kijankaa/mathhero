# scripts/ui/galaxy.gd
extends Control

@onready var _back_button: Button = $BackButton
@onready var _daily_panel: PanelContainer = $DailyPanel
@onready var _daily_desc: Label = $DailyPanel/VBox/DailyDescLabel
@onready var _daily_button: Button = $DailyPanel/VBox/DailyStartButton
@onready var _planets_container: VBoxContainer = $ScrollContainer/PlanetsContainer


func _ready() -> void:
	_back_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_MAIN_MENU))
	_build_daily_panel()
	_build_planets()

	if OS.is_debug_build():
		print("[Galaxy] Gotowy")


func _build_daily_panel() -> void:
	if not GameState.has_active_profile():
		_daily_panel.visible = false
		return
	var profile: PlayerProfile = GameState.current_profile
	if GalaxySystem.is_daily_done(profile):
		_daily_panel.visible = false
		return
	var config: SessionConfig = GalaxySystem.get_daily_config()
	_daily_desc.text = "Operacja: %s | %d pytań" % [config.operation_type, config.question_count]
	_daily_button.pressed.connect(func() -> void:
		GameState.current_session_config = config
		GameState.active_mission_id = "daily"
		SceneManager.go_to(Constants.SCENE_SESSION)
	)


func _build_planets() -> void:
	for child: Node in _planets_container.get_children():
		child.queue_free()

	var profile: PlayerProfile = null
	if GameState.has_active_profile():
		profile = GameState.current_profile

	for mission: Dictionary in GalaxySystem.MISSIONS:
		_build_planet_row(mission, profile)


func _build_planet_row(mission: Dictionary, profile: PlayerProfile) -> void:
	var mission_id: String = mission.get("id", "")
	var completed: bool = profile != null and mission_id in profile.completed_missions
	var unlocked: bool = GalaxySystem.is_unlocked(profile, mission_id)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 60)

	var emoji_lbl := Label.new()
	emoji_lbl.text = mission.get("emoji", "🌑")
	emoji_lbl.custom_minimum_size = Vector2(60, 0)
	emoji_lbl.add_theme_font_size_override("font_size", 32)

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = "%s — %s" % [mission.get("name", ""), mission.get("desc", "")]
	name_lbl.add_theme_font_size_override("font_size", 18)

	var req_lbl := Label.new()
	req_lbl.text = "%d pytań | %.0f%% wymagane | +%d⭐" % [
		mission.get("count", 10),
		mission.get("req_acc", 0.7) * 100.0,
		mission.get("reward", 0)
	]
	req_lbl.add_theme_font_size_override("font_size", 14)

	info_vbox.add_child(name_lbl)
	info_vbox.add_child(req_lbl)

	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(140, 50)

	if completed:
		action_btn.text = "✅ Ukończona"
		action_btn.disabled = true
	elif unlocked:
		action_btn.text = "🚀 Graj!"
		action_btn.pressed.connect(_on_mission_start.bind(mission_id))
	else:
		action_btn.text = "🔒 Zablokowana"
		action_btn.disabled = true

	row.add_child(emoji_lbl)
	row.add_child(info_vbox)
	row.add_child(action_btn)
	_planets_container.add_child(row)


func _on_mission_start(mission_id: String) -> void:
	GameState.current_session_config = GalaxySystem.get_mission_config(mission_id)
	GameState.active_mission_id = mission_id
	SceneManager.go_to(Constants.SCENE_SESSION)
