# resources/models/player_profile.gd
class_name PlayerProfile
extends Resource

var id: String = ""
var name: String = ""
var avatar_id: int = 0
var last_config: Dictionary = {}
var custom_presets: Array[Dictionary] = []

# Progresja (Epic 5)
var stars: int = 0                      # aktualne saldo (earned - spent)
var stars_total_earned: int = 0         # łączne zarobione (do obliczeń poziomu)
var owned_items: Array[String] = []     # ID zakupionych itemów sklepu
var equipped_costume: Dictionary = {}   # { slot: item_id }
var unlocked_badges: Array[String] = [] # ID zdobytych odznak
var session_count: int = 0              # łączna liczba ukończonych sesji
var total_correct: int = 0              # łączna liczba poprawnych odpowiedzi
var max_streak_ever: int = 0            # najlepsza seria kiedykolwiek


static func create(profile_name: String, avatar: int) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = str(randi()) + str(randi())
	p.name = profile_name
	p.avatar_id = avatar
	p.last_config = SessionConfig.create_default().to_dict()
	# Przyznaj darmowe itemy na start
	p.owned_items = ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"]
	p.equipped_costume = RewardSystem.DEFAULT_COSTUME.duplicate()
	return p


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"avatar_id": avatar_id,
		"last_config": last_config,
		"custom_presets": custom_presets,
		"stars": stars,
		"stars_total_earned": stars_total_earned,
		"owned_items": owned_items,
		"equipped_costume": equipped_costume,
		"unlocked_badges": unlocked_badges,
		"session_count": session_count,
		"total_correct": total_correct,
		"max_streak_ever": max_streak_ever,
	}


static func from_dict(d: Dictionary) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = d.get("id", "")
	p.name = d.get("name", "")
	p.avatar_id = d.get("avatar_id", 0)
	p.last_config = d.get("last_config", {})
	p.custom_presets = d.get("custom_presets", [])
	p.stars = d.get("stars", 0)
	p.stars_total_earned = d.get("stars_total_earned", 0)
	p.owned_items = d.get("owned_items", ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"])
	p.equipped_costume = d.get("equipped_costume", RewardSystem.DEFAULT_COSTUME.duplicate())
	p.unlocked_badges = d.get("unlocked_badges", [])
	p.session_count = d.get("session_count", 0)
	p.total_correct = d.get("total_correct", 0)
	p.max_streak_ever = d.get("max_streak_ever", 0)
	return p
