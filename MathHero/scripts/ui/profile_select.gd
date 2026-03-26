# scripts/ui/profile_select.gd
class_name ProfileSelect
extends Control

@onready var _profiles_container: HBoxContainer = $ProfilesContainer
@onready var _add_button: Button = $AddProfileButton

var _profiles: Array[PlayerProfile] = []


func _ready() -> void:
	_add_button.pressed.connect(_on_add_pressed)
	_load_and_display()

	if OS.is_debug_build():
		print("[ProfileSelect] Gotowy")


func _load_and_display() -> void:
	_profiles = load_profiles()

	for child in _profiles_container.get_children():
		child.queue_free()

	for profile in _profiles:
		_add_profile_card(profile)


func _add_profile_card(profile: PlayerProfile) -> void:
	var btn := Button.new()
	var avatar: String = Constants.AVATARS[profile.avatar_id] if profile.avatar_id < Constants.AVATARS.size() else "🚀"
	btn.text = avatar + "\n" + profile.name
	btn.custom_minimum_size = Vector2(120, 120)
	btn.pressed.connect(_on_profile_selected.bind(profile))
	_profiles_container.add_child(btn)


func _on_profile_selected(profile: PlayerProfile) -> void:
	GameState.set_profile(profile)
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)


func _on_add_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_PROFILE_CREATE)


## Wczytuje wszystkie profile z localStorage.
static func load_profiles() -> Array[PlayerProfile]:
	var raw: Variant = DataManager.load_data(Constants.STORAGE_KEY_PROFILES)
	if raw == null or not raw is Array:
		return []
	var profiles: Array[PlayerProfile] = []
	for d: Variant in raw:
		if d is Dictionary:
			profiles.append(PlayerProfile.from_dict(d))
	return profiles


## Zapisuje tablicę profili do localStorage.
static func save_profiles(profiles: Array[PlayerProfile]) -> void:
	var data: Array = []
	for p in profiles:
		data.append(p.to_dict())
	DataManager.save(Constants.STORAGE_KEY_PROFILES, data)
