# autoloads/audio_manager.gd
# JEDYNY punkt odtwarzania dźwięku w aplikacji.
# Obsługuje Safari autoplay policy — audio wymaga unlock_audio() przed odtworzeniem.
extends Node

var _audio_unlocked: bool = false

var _sfx_bus: int = -1
var _music_bus: int = -1
var _music_player: AudioStreamPlayer = null


func _ready() -> void:
	_sfx_bus = AudioServer.get_bus_index("SFX")
	_music_bus = AudioServer.get_bus_index("Music")

	# Fallback do magistrali Master jeśli SFX/Music nie istnieją
	if _sfx_bus == -1:
		_sfx_bus = 0
	if _music_bus == -1:
		_music_bus = 0

	if OS.is_debug_build():
		print("[AudioManager] Gotowy. Bus SFX: ", _sfx_bus, " Music: ", _music_bus)


## KRYTYCZNE: Wywołać jednorazowo po pierwszej interakcji użytkownika (kliknięcie splash screenu).
## Bez tego Safari blokuje dźwięk całkowicie.
func unlock_audio() -> void:
	if _audio_unlocked:
		return
	_audio_unlocked = true
	EventBus.audio_unlocked.emit()
	if OS.is_debug_build():
		print("[AudioManager] Audio odblokowane")


## Odtwarza efekt dźwiękowy (one-shot, auto-cleanup).
## stream — załadowany AudioStream (używaj preload() w scenach)
func play_sfx(stream: AudioStream) -> void:
	if not _audio_unlocked:
		if OS.is_debug_build():
			push_warning("[AudioManager] Audio zablokowane — pomijam SFX")
		return
	if stream == null:
		push_warning("[AudioManager] Próba odtworzenia null stream")
		return

	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = AudioServer.get_bus_name(_sfx_bus)
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


## Uruchamia muzykę w pętli. Zatrzymuje poprzednią jeśli grała.
func play_music(stream: AudioStream) -> void:
	if not _audio_unlocked:
		if OS.is_debug_build():
			push_warning("[AudioManager] Audio zablokowane — pomijam muzykę")
		return
	stop_music()
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = stream
	_music_player.bus = AudioServer.get_bus_name(_music_bus)
	add_child(_music_player)
	_music_player.play()


## Zatrzymuje aktywną muzykę.
func stop_music() -> void:
	if is_instance_valid(_music_player):
		_music_player.queue_free()
		_music_player = null


## Wycisza/odcisza efekty dźwiękowe.
func set_sfx_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(_sfx_bus, muted)


## Wycisza/odcisza muzykę.
func set_music_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(_music_bus, muted)


## Czy audio zostało odblokowane.
func is_unlocked() -> bool:
	return _audio_unlocked
