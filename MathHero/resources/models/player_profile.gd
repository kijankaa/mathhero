# resources/models/player_profile.gd
class_name PlayerProfile
extends Resource

var id: String = ""
var name: String = ""
var avatar_id: int = 0
var last_config: Dictionary = {}
var custom_presets: Array[Dictionary] = []


static func create(profile_name: String, avatar: int) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = str(randi()) + str(randi())
	p.name = profile_name
	p.avatar_id = avatar
	p.last_config = SessionConfig.create_default().to_dict()
	return p


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"avatar_id": avatar_id,
		"last_config": last_config,
		"custom_presets": custom_presets,
	}


static func from_dict(d: Dictionary) -> PlayerProfile:
	var p := PlayerProfile.new()
	p.id = d.get("id", "")
	p.name = d.get("name", "")
	p.avatar_id = d.get("avatar_id", 0)
	p.last_config = d.get("last_config", {})
	p.custom_presets = d.get("custom_presets", [])
	return p
