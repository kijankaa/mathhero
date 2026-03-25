# scripts/ui/summary.gd
extends Control

@onready var _result_label: Label = $ResultLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _accuracy_label: Label = $AccuracyLabel
@onready var _stars_earned_label: Label = $StarsEarnedLabel
@onready var _level_up_label: Label = $LevelUpLabel
@onready var _new_badges_label: Label = $NewBadgesLabel
@onready var _play_again_button: Button = $PlayAgainButton
@onready var _config_button: Button = $ConfigButton
@onready var _rewards_button: Button = $RewardsButton
@onready var _reward_popup: Control = $RewardPopup

var _result: SessionResult = null
var _stars_earned: int = 0
var _new_badges: Array[String] = []


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_config_button.pressed.connect(_on_config_pressed)
	_rewards_button.pressed.connect(_on_rewards_pressed)

	_level_up_label.visible = false
	_new_badges_label.visible = false
	_stars_earned_label.text = ""

	if GameState.last_session_result != null:
		_result = GameState.last_session_result
		_process_rewards()
		_update_ui()
		_show_reward_popup()

	if OS.is_debug_build():
		print("[Summary] Gotowy")


## Aktualizuje profil i oblicza nagrody za tę sesję.
func _process_rewards() -> void:
	if _result == null or not GameState.has_active_profile():
		return

	var profile: PlayerProfile = GameState.current_profile
	_stars_earned = RewardSystem.calculate_stars(_result)

	var old_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)

	# Aktualizacja danych profilu
	profile.stars += _stars_earned
	profile.stars_total_earned += _stars_earned
	profile.session_count += 1
	profile.total_correct += _result.correct_count
	if _result.max_streak > profile.max_streak_ever:
		profile.max_streak_ever = _result.max_streak

	# Sprawdź nowe odznaki (po aktualizacji danych profilu)
	_new_badges = RewardSystem.check_new_badges(profile, _result)
	for badge_id: String in _new_badges:
		if not badge_id in profile.unlocked_badges:
			profile.unlocked_badges.append(badge_id)

	# Sprawdź awans poziomu
	var new_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)
	if new_level > old_level:
		_level_up_label.text = "🎉 Awans! Teraz jesteś: %s" % RewardSystem.get_level_name(new_level)
		_level_up_label.visible = true

	# Emituj sygnały
	if _stars_earned > 0:
		EventBus.stars_earned.emit(_stars_earned, profile.stars)
	for badge_id: String in _new_badges:
		EventBus.achievement_unlocked.emit(badge_id)

	# Zapisz profil
	_save_profile(profile)

	if OS.is_debug_build():
		print("[Summary] Nagrody: gwiazdki=", _stars_earned, " odznaki=", _new_badges)


func _update_ui() -> void:
	if _result == null:
		return

	_result_label.text = "%d / %d poprawnych" % [_result.correct_count, _result.total_questions]
	_score_label.text = "Punkty: %d" % _result.score
	_accuracy_label.text = "Dokładność: %d%%" % _result.get_accuracy_percent()

	# Gwiazdki
	var stars_text: String = "⭐".repeat(_stars_earned) if _stars_earned > 0 else "—"
	_stars_earned_label.text = "Gwiazdki: %s" % stars_text

	# Nowe odznaki
	if not _new_badges.is_empty():
		var badge_names: Array[String] = []
		for badge_id: String in _new_badges:
			var def: Dictionary = RewardSystem.BADGE_DEFINITIONS.get(badge_id, {})
			badge_names.append(def.get("emoji", "🏅") + " " + def.get("name", badge_id))
		_new_badges_label.text = "Nowe odznaki:\n" + "\n".join(badge_names)
		_new_badges_label.visible = true


func _show_reward_popup() -> void:
	if _stars_earned > 0 or not _new_badges.is_empty():
		if is_instance_valid(_reward_popup) and _reward_popup.has_method("show_rewards"):
			_reward_popup.show_rewards(_stars_earned, _new_badges)


## Zapisuje aktywny profil (load → update → save all).
func _save_profile(profile: PlayerProfile) -> void:
	var profiles: Array[PlayerProfile] = ProfileSelect.load_profiles()
	for i: int in profiles.size():
		if profiles[i].id == profile.id:
			profiles[i] = profile
			break
	ProfileSelect.save_profiles(profiles)


func _on_play_again_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _on_config_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_CONFIG)


func _on_rewards_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_REWARDS)
