# scripts/components/astronaut_display.gd
# Wyświetla astronautę z widocznym kostiumem:
# - kolor skafandra zależy od wyposażonego suit
# - emoji elementów kostiumu nałożone na sylwetkę
extends Control

@onready var _body: TextureRect = $Body
@onready var _helmet_label: Label = $HelmetLabel
@onready var _backpack_label: Label = $BackpackLabel
@onready var _boots_label: Label = $BootsLabel
@onready var _gloves_l_label: Label = $GlovesL
@onready var _gloves_r_label: Label = $GlovesR
@onready var _glow_rect: ColorRect = $GlowRect

const SUIT_COLORS: Dictionary = {
	"suit_1": Color(1.0, 1.0, 1.0, 1.0),
	"suit_2": Color(0.35, 0.75, 1.0, 1.0),
	"suit_3": Color(1.0, 0.82, 0.15, 1.0),
}

const SUIT_GLOW: Dictionary = {
	"suit_1": Color(0, 0, 0, 0),
	"suit_2": Color(0.0, 0.5, 1.0, 0.18),
	"suit_3": Color(1.0, 0.75, 0.0, 0.22),
}


func refresh(profile: PlayerProfile) -> void:
	var costume: Dictionary = profile.equipped_costume

	var suit_id: String = costume.get("suit", "suit_1")
	_body.modulate = SUIT_COLORS.get(suit_id, Color.WHITE)
	_glow_rect.color = SUIT_GLOW.get(suit_id, Color(0, 0, 0, 0))

	_helmet_label.text = _emoji(costume.get("helmet", "helmet_1"))
	_backpack_label.text = _emoji(costume.get("backpack", "backpack_1"))
	_boots_label.text = _emoji(costume.get("boots", "boots_1"))
	_gloves_l_label.text = _emoji(costume.get("gloves", "gloves_1"))
	_gloves_r_label.text = _emoji(costume.get("gloves", "gloves_1"))


func _emoji(item_id: String) -> String:
	return RewardSystem.SHOP_ITEMS.get(item_id, {}).get("emoji", "")
