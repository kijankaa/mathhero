# scripts/ui/splash_screen.gd
# Ekran startowy — KRYTYCZNY dla Safari audio autoplay policy.
# Wyświetlany przy każdym uruchomieniu. Kliknięcie odblokowuje audio.
extends Control

@onready var _tap_button: Button = $TapButton
@onready var _version_label: Label = $VersionLabel


func _ready() -> void:
	_version_label.text = "v" + Constants.APP_VERSION
	_tap_button.pressed.connect(_on_tap)
	_tap_button.grab_focus()

	if OS.is_debug_build():
		print("[SplashScreen] Gotowy")


func _on_tap() -> void:
	# KRYTYCZNE: to jest jedyny moment odblokowania audio w Safari.
	# Musi być wywołane bezpośrednio z interakcji użytkownika (nie z timera/sygnału).
	AudioManager.unlock_audio()

	# Epic 2: zawsze idź do menu głównego (profile dopiero w Epic 3)
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)
