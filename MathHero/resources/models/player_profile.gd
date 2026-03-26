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

# Progresja galaktyki (Epic 6)
var completed_missions: Array[String] = []  # ID ukończonych misji
var daily_challenge_date: String = ""        # "YYYY-MM-DD" ostatnio ukończonego wyzwania
var daily_challenge_streak: int = 0          # seria dziennych wyzwań
var best_session_score: int = 0              # najlepszy wynik kiedykolwiek (dowolna sesja)


static func create(profile_name: String, avatar: int) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = str(randi()) + str(randi())
	p.name = profile_name
	p.avatar_id = avatar
	p.last_config = SessionConfig.create_default().to_dict()
	# Przyznaj darmowe itemy na start
	p.owned_items = ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"]
	p.equipped_costume = {"helmet": "helmet_1", "suit": "suit_1", "backpack": "backpack_1", "boots": "boots_1", "gloves": "gloves_1"}
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
		"completed_missions": completed_missions,
		"daily_challenge_date": daily_challenge_date,
		"daily_challenge_streak": daily_challenge_streak,
		"best_session_score": best_session_score,
	}


static func from_dict(d: Dictionary) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = d.get("id", "")
	p.name = d.get("name", "")
	p.avatar_id = int(d.get("avatar_id", 0))
	p.last_config = d.get("last_config", {})
	for item: Variant in d.get("custom_presets", []):
		if item is Dictionary:
			p.custom_presets.append(item)
	p.stars = int(d.get("stars", 0))
	p.stars_total_earned = int(d.get("stars_total_earned", 0))
	for item: Variant in d.get("owned_items", ["helmet_1", "suit_1", "backpack_1", "boots_1", "gloves_1"]):
		p.owned_items.append(str(item))
	p.equipped_costume = d.get("equipped_costume", {"helmet": "helmet_1", "suit": "suit_1", "backpack": "backpack_1", "boots": "boots_1", "gloves": "gloves_1"})
	for item: Variant in d.get("unlocked_badges", []):
		p.unlocked_badges.append(str(item))
	p.session_count = int(d.get("session_count", 0))
	p.total_correct = int(d.get("total_correct", 0))
	p.max_streak_ever = int(d.get("max_streak_ever", 0))
	for item: Variant in d.get("completed_missions", []):
		p.completed_missions.append(str(item))
	p.daily_challenge_date = d.get("daily_challenge_date", "")
	p.daily_challenge_streak = int(d.get("daily_challenge_streak", 0))
	p.best_session_score = int(d.get("best_session_score", 0))
	return p
