# scripts/components/astronaut_display.gd
# Wyświetla astronautę z widocznym kostiumem:
# - kolor skafandra zależy od wyposażonego suit
# - emoji elementów kostiumu nałożone na sylwetkę
extends Control

@onready var _body: TextureRect = $Body
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
	var suit_id: String = profile.equipped_costume.get("suit", "suit_1")
	_body.modulate = SUIT_COLORS.get(suit_id, Color.WHITE)
	_glow_rect.color = SUIT_GLOW.get(suit_id, Color(0, 0, 0, 0))
