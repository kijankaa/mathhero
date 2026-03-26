# scripts/components/reward_popup.gd
# Popup animacji nagrody — wysuwa się po sesji, auto-chowa po ~3 sekundach.
extends Control

@onready var _stars_label: Label = $Panel/VBox/StarsLabel
@onready var _badges_label: Label = $Panel/VBox/BadgesLabel


func _ready() -> void:
	visible = false
	modulate.a = 0.0


## Pokazuje popup z nagrodami i animuje wejście.
func show_rewards(stars: int, new_badges: Array[String]) -> void:
	if stars <= 0 and new_badges.is_empty():
		return

	# Tekst gwiazdek
	if stars > 0:
		var suffix: String
		if stars == 1:
			suffix = "gwiazdka!"
		elif stars < 5:
			suffix = "gwiazdki!"
		else:
			suffix = "gwiazdek!"
		_stars_label.text = "★ +%d %s" % [stars, suffix]
	else:
		_stars_label.text = ""

	# Tekst odznak
	if not new_badges.is_empty():
		var lines: Array[String] = []
		for badge_id: String in new_badges:
			var def: Dictionary = RewardSystem.BADGE_DEFINITIONS.get(badge_id, {})
			lines.append(def.get("emoji", "★") + " " + def.get("name", badge_id))
		_badges_label.text = "Nowa odznaka!\n" + "\n".join(lines)
	else:
		_badges_label.text = ""

	visible = true
	var start_y: float = position.y

	# Animacja: fade in + slide up → czekaj → fade out
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(self, "position:y", start_y - 20.0, 0.4)
	tween.tween_interval(2.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void:
		visible = false
		position.y = start_y
	)
