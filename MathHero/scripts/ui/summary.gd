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
@onready var _galaxy_button: Button = $GalaxyButton
@onready var _reward_popup: Control = $RewardPopup
@onready var _mission_result_label: Label = $MissionResultLabel
@onready var _bonus_label: Label = $BonusLabel
@onready var _bonus_button: Button = $BonusButton
@onready var _beat_record_button: Button = $BeatRecordButton
@onready var _difficulty_label: Label = $DifficultyLabel
@onready var _apply_difficulty_button: Button = $ApplyDifficultyButton

var _result: SessionResult = null
var _stars_earned: int = 0
var _new_badges: Array[String] = []
var _suggested_max: int = 0


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_config_button.pressed.connect(_on_config_pressed)
	_rewards_button.pressed.connect(_on_rewards_pressed)
	_galaxy_button.pressed.connect(func() -> void: SceneManager.go_to(Constants.SCENE_GALAXY))
	_beat_record_button.pressed.connect(_on_beat_record_pressed)

	_level_up_label.visible = false
	_new_badges_label.visible = false
	_stars_earned_label.text = ""
	_mission_result_label.visible = false
	_bonus_label.visible = false
	_bonus_button.visible = false
	_beat_record_button.visible = false
	_difficulty_label.visible = false
	_apply_difficulty_button.visible = false
	_apply_difficulty_button.pressed.connect(_on_apply_difficulty_pressed)

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

	# Aktualizuj najlepszy wynik
	if _result.score > profile.best_session_score:
		profile.best_session_score = _result.score

	# Zapisz historię i rekordy (Epic 7)
	_record_session_history(profile)
	_update_operation_records(profile)

	# Sprawdź ukończenie misji lub dziennego wyzwania
	if GameState.active_mission_id != "":
		_check_mission_completion(profile)

	# Reset kontekstu misji
	GameState.active_mission_id = ""

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


## Sprawdza ukończenie misji galaktyki lub dziennego wyzwania.
func _check_mission_completion(profile: PlayerProfile) -> void:
	var mission_id: String = GameState.active_mission_id

	# Obsługa dziennego wyzwania
	if mission_id == "daily":
		var today: String = GalaxySystem.get_daily_date()
		if profile.daily_challenge_date != today:
			# Sprawdź serię
			var yesterday: Dictionary = Time.get_datetime_dict_from_system()
			# Prosta heurystyka serii: jeśli wczoraj była data - 1 dzień
			profile.daily_challenge_date = today
			profile.daily_challenge_streak += 1
			var daily_reward: int = 3
			profile.stars += daily_reward
			profile.stars_total_earned += daily_reward
			EventBus.stars_earned.emit(daily_reward, profile.stars)
			_mission_result_label.text = "Wyzwanie dnia ukończone! +%d★ (Seria: %d)" % [daily_reward, profile.daily_challenge_streak]
			_mission_result_label.visible = true
			# Sprawdź odznakę za wyzwanie
			var daily_badges: Array[String] = RewardSystem.check_new_badges(profile, _result)
			for badge_id: String in daily_badges:
				if not badge_id in profile.unlocked_badges:
					profile.unlocked_badges.append(badge_id)
		return

	# Obsługa zwykłej misji
	var mission: Dictionary = GalaxySystem.get_mission(mission_id)
	if mission.is_empty():
		return

	var req_acc: float = mission.get("req_acc", 0.7)
	if _result.get_accuracy() >= req_acc and not mission_id in profile.completed_missions:
		profile.completed_missions.append(mission_id)
		var reward: int = mission.get("reward", 0)
		profile.stars += reward
		profile.stars_total_earned += reward
		EventBus.mission_completed.emit(mission_id)
		EventBus.stars_earned.emit(reward, profile.stars)
		_mission_result_label.text = "Misja ukończona! +%d★" % reward
		_mission_result_label.visible = true
		# Sprawdź nowe odznaki za misję
		var new_mission_badges: Array[String] = RewardSystem.check_new_badges(profile, _result)
		for badge_id: String in new_mission_badges:
			if not badge_id in profile.unlocked_badges:
				profile.unlocked_badges.append(badge_id)
	elif _result.get_accuracy() < req_acc:
		_mission_result_label.text = "Misja nieudana (%.0f%% / %.0f%% wymagane)" % [_result.get_accuracy() * 100.0, req_acc * 100.0]
		_mission_result_label.visible = true


func _update_ui() -> void:
	if _result == null:
		return

	_result_label.text = "%d / %d poprawnych" % [_result.correct_count, _result.total_questions]
	_score_label.text = "Punkty: %d" % _result.score
	_accuracy_label.text = "Dokładność: %d%%" % _result.get_accuracy_percent()

	# Gwiazdki
	var stars_text: String = "★".repeat(_stars_earned) if _stars_earned > 0 else "—"
	_stars_earned_label.text = "Gwiazdki: %s" % stars_text

	# Nowe odznaki
	if not _new_badges.is_empty():
		var badge_names: Array[String] = []
		for badge_id: String in _new_badges:
			var def: Dictionary = RewardSystem.BADGE_DEFINITIONS.get(badge_id, {})
			badge_names.append(def.get("emoji", "★") + " " + def.get("name", badge_id))
		_new_badges_label.text = "Nowe odznaki:\n" + "\n".join(badge_names)
		_new_badges_label.visible = true

	# Przycisk Pobij Rekord
	if GameState.has_active_profile() and GameState.current_profile.best_session_score > 0:
		_beat_record_button.text = "Pobij Rekord: %d" % GameState.current_profile.best_session_score
		_beat_record_button.visible = true

	# Misja bonusowa (tylko jeśli nie byliśmy w misji)
	if GameState.active_mission_id == "":
		_show_bonus_mission()

	_show_difficulty_suggestion()


func _show_reward_popup() -> void:
	if _stars_earned > 0 or not _new_badges.is_empty():
		if is_instance_valid(_reward_popup) and _reward_popup.has_method("show_rewards"):
			_reward_popup.show_rewards(_stars_earned, _new_badges)


## Wyświetla sugestię misji bonusowej po wolnej grze.
func _show_bonus_mission() -> void:
	if not GameState.has_active_profile():
		return
	var bonus: Dictionary = GalaxySystem.get_bonus_mission(GameState.current_profile)
	if bonus.is_empty():
		return
	_bonus_label.text = "🎯 Misja bonusowa: %s %s\n%s" % [bonus.get("emoji", ""), bonus.get("name", ""), bonus.get("desc", "")]
	_bonus_label.visible = true
	_bonus_button.visible = true
	_bonus_button.pressed.connect(func() -> void:
		var config: SessionConfig = GalaxySystem.get_mission_config(bonus.get("id", ""))
		GameState.current_session_config = config
		GameState.active_mission_id = bonus.get("id", "")
		SceneManager.go_to(Constants.SCENE_SESSION)
	)


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


func _on_beat_record_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_SESSION)


func _record_session_history(profile: PlayerProfile) -> void:
	if _result == null:
		return
	var entry: Dictionary = {
		"date": Time.get_date_string_from_system(),
		"op": _result.config.operation_type if _result.config != null else "unknown",
		"correct": _result.correct_count,
		"total": _result.total_questions,
		"accuracy": _result.get_accuracy_percent(),
		"score": _result.score,
		"duration": _result.duration_seconds,
	}
	profile.session_history.append(entry)
	if profile.session_history.size() > 50:
		profile.session_history.pop_front()


func _update_operation_records(profile: PlayerProfile) -> void:
	if _result == null or _result.config == null:
		return
	var op: String = _result.config.operation_type
	var acc: int = _result.get_accuracy_percent()
	var score: int = _result.score
	if not profile.operation_records.has(op):
		profile.operation_records[op] = {"best_accuracy": 0, "best_score": 0}
	var rec: Dictionary = profile.operation_records[op]
	if acc > int(rec.get("best_accuracy", 0)):
		rec["best_accuracy"] = acc
	if score > int(rec.get("best_score", 0)):
		rec["best_score"] = score


func _show_difficulty_suggestion() -> void:
	if _result == null or _result.config == null:
		return
	var accuracy: float = _result.get_accuracy()
	var current_max: int = _result.config.max_value
	if accuracy >= 0.8:
		_suggested_max = min(current_max * 2, 1000)
		_difficulty_label.text = "💪 Świetnie! Spróbuj trudniejszego zakresu: 1–%d" % _suggested_max
		_difficulty_label.visible = true
		_apply_difficulty_button.visible = true
	elif accuracy <= 0.4:
		_suggested_max = max(current_max / 2, 10)
		_difficulty_label.text = "💡 Spróbuj łatwiejszego zakresu: 1–%d" % _suggested_max
		_difficulty_label.visible = true
		_apply_difficulty_button.visible = true


func _on_apply_difficulty_pressed() -> void:
	if _result == null or _result.config == null or _suggested_max <= 0:
		return
	var new_config: SessionConfig = SessionConfig.from_dict(_result.config.to_dict())
	new_config.max_value = _suggested_max
	GameState.current_session_config = new_config
	SceneManager.go_to(Constants.SCENE_SESSION)
