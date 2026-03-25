# autoloads/event_bus.gd
# Centralna szyna sygnałów dla komunikacji między niezwiązanymi systemami.
# NIE używaj bezpośrednich sygnałów między niezwiązanymi węzłami — tylko EventBus.
extends Node

# Audio
signal audio_unlocked()

# Profil
signal profile_selected(profile_id: String)
signal profile_created(profile_id: String)

# Sesja
signal session_started(config: Resource)
signal session_completed(result: Resource)
signal question_answered(correct: bool, response_time: float)

# Nagrody
signal stars_earned(amount: int, total: int)
signal achievement_unlocked(achievement_id: String)
signal costume_purchased(item_id: String)

# Galaktyka misji (Epic 6)
signal mission_completed(mission_id: String)

# UI
signal scene_changed(scene_name: String)
