# scripts/ui/rewards.gd
extends Control

# ── Zakładka Bohater ──────────────────────────────────────────────────────────
@onready var _hero_display: Label = $TabContainer/Bohater/HeroDisplay
@onready var _hero_level_label: Label = $TabContainer/Bohater/LevelLabel
@onready var _stars_label: Label = $TabContainer/Bohater/StarsLabel
@onready var _progress_bar: ProgressBar = $TabContainer/Bohater/ProgressBar
@onready var _progress_label: Label = $TabContainer/Bohater/ProgressLabel

# ── Zakładka Sklep ────────────────────────────────────────────────────────────
@onready var _shop_container: VBoxContainer = $TabContainer/Sklep/ScrollContainer/ItemsContainer
@onready var _shop_stars_label: Label = $TabContainer/Sklep/CurrentStarsLabel

# ── Zakładka Odznaki ──────────────────────────────────────────────────────────
@onready var _badges_container: GridContainer = $TabContainer/Odznaki/ScrollContainer/BadgesContainer

# ── Nawigacja ─────────────────────────────────────────────────────────────────
@onready var _back_button: Button = $BackButton

const _SLOTS: Array[String] = ["helmet", "suit", "backpack", "boots", "gloves"]
const _SLOT_NAMES: Dictionary = {
	"helmet": "Hełm", "suit": "Skafander", "backpack": "Plecak",
	"boots": "Buty", "gloves": "Rękawice",
}


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)

	if not GameState.has_active_profile():
		push_warning("[Rewards] Brak aktywnego profilu")
		SceneManager.go_to(Constants.SCENE_MAIN_MENU)
		return

	_refresh_hero_tab()
	_build_shop_tab()
	_build_badges_tab()

	if OS.is_debug_build():
		print("[Rewards] Gotowy")

# ── Zakładka Bohater ──────────────────────────────────────────────────────────

func _refresh_hero_tab() -> void:
	var profile: PlayerProfile = GameState.current_profile
	_hero_display.text = RewardSystem.get_costume_display(profile)

	var progress: Dictionary = RewardSystem.get_level_progress(profile.stars_total_earned)
	_hero_level_label.text = "Poziom %d: %s" % [progress.level, progress.name]
	_stars_label.text = "⭐ %d gwiazdek" % profile.stars

	if progress.is_max:
		_progress_bar.value = 1.0
		_progress_label.text = "Maksymalny poziom!"
	else:
		_progress_bar.value = progress.progress
		_progress_label.text = "%d gwiazdek do: %s" % [progress.stars_to_next, progress.next_name]

# ── Zakładka Sklep ────────────────────────────────────────────────────────────

func _build_shop_tab() -> void:
	for child in _shop_container.get_children():
		child.queue_free()

	var profile: PlayerProfile = GameState.current_profile
	_shop_stars_label.text = "Masz: ⭐ %d" % profile.stars

	var hero_level: int = RewardSystem.get_hero_level(profile.stars_total_earned)

	for slot: String in _SLOTS:
		var slot_label := Label.new()
		slot_label.text = "── %s ──" % _SLOT_NAMES.get(slot, slot)
		_shop_container.add_child(slot_label)

		var items: Array[Dictionary] = RewardSystem.get_items_for_slot(slot)
		for item: Dictionary in items:
			_build_shop_item(item, profile, hero_level)


func _build_shop_item(item: Dictionary, profile: PlayerProfile, hero_level: int) -> void:
	var item_id: String = item.get("id", "")
	var slot: String = item.get("slot", "")
	var owned: bool = item_id in profile.owned_items
	var equipped: bool = profile.equipped_costume.get(slot, "") == item_id
	var cost: int = item.get("cost", 0)
	var level_req: int = item.get("level_req", 0)
	var level_ok: bool = hero_level >= level_req
	var can_afford: bool = profile.stars >= cost

	var row := HBoxContainer.new()

	var emoji_lbl := Label.new()
	emoji_lbl.text = item.get("emoji", "?")
	emoji_lbl.custom_minimum_size = Vector2(50, 0)

	var name_lbl := Label.new()
	name_lbl.text = item.get("name", "")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(160, 44)

	if equipped:
		action_btn.text = "✅ Ubrane"
		action_btn.disabled = true
	elif owned:
		action_btn.text = "Ubierz"
		action_btn.pressed.connect(_on_equip_pressed.bind(item_id, slot))
	elif not level_ok:
		action_btn.text = "Poziom %d ❌" % level_req
		action_btn.disabled = true
	elif can_afford:
		action_btn.text = "Kup ⭐%d" % cost
		action_btn.pressed.connect(_on_buy_pressed.bind(item_id, cost))
	else:
		action_btn.text = "Za mało ⭐"
		action_btn.disabled = true

	row.add_child(emoji_lbl)
	row.add_child(name_lbl)
	row.add_child(action_btn)
	_shop_container.add_child(row)


func _on_buy_pressed(item_id: String, cost: int) -> void:
	var profile: PlayerProfile = GameState.current_profile
	if profile.stars < cost or item_id in profile.owned_items:
		return

	profile.stars -= cost
	profile.owned_items.append(item_id)
	EventBus.costume_purchased.emit(item_id)

	_save_profile(profile)
	_build_shop_tab()
	_refresh_hero_tab()

	if OS.is_debug_build():
		print("[Rewards] Kupiono: ", item_id)


func _on_equip_pressed(item_id: String, slot: String) -> void:
	var profile: PlayerProfile = GameState.current_profile
	if not item_id in profile.owned_items:
		return

	profile.equipped_costume[slot] = item_id
	_save_profile(profile)
	_build_shop_tab()
	_refresh_hero_tab()

	if OS.is_debug_build():
		print("[Rewards] Ubrano: ", item_id, " w slocie: ", slot)

# ── Zakładka Odznaki ──────────────────────────────────────────────────────────

func _build_badges_tab() -> void:
	for child in _badges_container.get_children():
		child.queue_free()

	var profile: PlayerProfile = GameState.current_profile

	for badge_id: String in RewardSystem.BADGE_DEFINITIONS:
		var def: Dictionary = RewardSystem.BADGE_DEFINITIONS[badge_id]
		var earned: bool = badge_id in profile.unlocked_badges

		var panel := PanelContainer.new()
		var vbox := VBoxContainer.new()
		panel.custom_minimum_size = Vector2(140, 100)

		var emoji_lbl := Label.new()
		emoji_lbl.text = def.get("emoji", "🏅")
		emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_lbl.add_theme_font_size_override("font_size", 32)

		var name_lbl := Label.new()
		name_lbl.text = def.get("name", "")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		vbox.add_child(emoji_lbl)
		vbox.add_child(name_lbl)
		panel.add_child(vbox)

		if not earned:
			panel.modulate = Color(0.4, 0.4, 0.4, 0.6)

		_badges_container.add_child(panel)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _save_profile(profile: PlayerProfile) -> void:
	var profiles: Array[PlayerProfile] = ProfileSelect.load_profiles()
	for i: int in profiles.size():
		if profiles[i].id == profile.id:
			profiles[i] = profile
			break
	ProfileSelect.save_profiles(profiles)


func _on_back_pressed() -> void:
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)
