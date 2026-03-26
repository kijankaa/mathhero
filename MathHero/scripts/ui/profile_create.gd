# scripts/ui/profile_create.gd
extends Control

const ProfileSelectScript = preload("res://scripts/ui/profile_select.gd")

@onready var _name_input: LineEdit = $NameInput
@onready var _avatars_container: GridContainer = $AvatarsContainer
@onready var _create_button: Button = $CreateButton
@onready var _cancel_button: Button = $CancelButton
@onready var _error_label: Label = $ErrorLabel

var _selected_avatar: int = 0


func _ready() -> void:
	_create_button.pressed.connect(_on_create_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_error_label.text = ""

	for i in Constants.AVATARS.size():
		var btn := Button.new()
		btn.text = Constants.AVATARS[i]
		btn.custom_minimum_size = Vector2(70, 70)
		btn.pressed.connect(_on_avatar_selected.bind(i))
		_avatars_container.add_child(btn)

	_highlight_avatar(0)

	if OS.is_debug_build():
		print("[ProfileCreate] Gotowy")


func _on_avatar_selected(index: int) -> void:
	_selected_avatar = index
	_highlight_avatar(index)


func _highlight_avatar(index: int) -> void:
	var buttons := _avatars_container.get_children()
	for i in buttons.size():
		var btn := buttons[i] as Button
		btn.modulate = Color(1.5, 1.5, 0.5) if i == index else Color.WHITE


func _on_create_pressed() -> void:
	var name_text: String = _name_input.text.strip_edges()

	if name_text.length() < 2:
		_error_label.text = "Nazwa musi mieć min. 2 znaki"
		return
	if name_text.length() > 20:
		_error_label.text = "Nazwa może mieć max. 20 znaków"
		return

	var profiles := ProfileSelectScript.load_profiles()
	if profiles.size() >= Constants.MAX_PROFILES:
		_error_label.text = "Maksymalnie %d profili" % Constants.MAX_PROFILES
		return

	var profile := PlayerProfile.create(name_text, _selected_avatar)
	profiles.append(profile)
	ProfileSelectScript.save_profiles(profiles)

	GameState.set_profile(profile)
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)


func _on_cancel_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_PROFILE_SELECT)
