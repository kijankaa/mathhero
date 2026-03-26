# scripts/ui/onboarding.gd
# Onboarding — 4 slajdy pokazywane po stworzeniu pierwszego profilu.
extends Control

@onready var _title_label: Label = $CenterContainer/VBox/TitleLabel
@onready var _slide_label: Label = $CenterContainer/VBox/SlideLabel
@onready var _dots_container: HBoxContainer = $CenterContainer/VBox/DotsContainer
@onready var _next_button: Button = $NextButton
@onready var _skip_button: Button = $SkipButton

const SLIDES: Array[Dictionary] = [
	{
		"title": "Witaj w MathHero!",
		"text": "Ćwicz matematykę w kosmicznej przygodzie.\nZdobywaj gwiazdki i odblokuj planety!",
	},
	{
		"title": "Jak grać?",
		"text": "Zobaczysz zadanie matematyczne.\nWpisz odpowiedź klawiaturą lub wybierz spośród opcji.\nCzym szybciej — tym więcej punktów!",
	},
	{
		"title": "Nagrody i postępy",
		"text": "Za każdą sesję zdobywasz gwiazdki.\nKupuj kostiumy dla astronauty\ni zdobywaj odznaki za osiągnięcia!",
	},
	{
		"title": "Galaktyka Misji",
		"text": "Ukończaj misje planetarne w odpowiedniej kolejności.\nCodziennie czeka na Ciebie wyzwanie dnia!\nPowodzenia, MathHero!",
	},
]

var _current: int = 0


func _ready() -> void:
	_next_button.pressed.connect(_on_next_pressed)
	_skip_button.pressed.connect(_finish)
	_show_slide(0)
	if OS.is_debug_build():
		print("[Onboarding] Gotowy")


func _show_slide(index: int) -> void:
	_current = index
	var slide: Dictionary = SLIDES[index]
	_title_label.text = slide["title"]
	_slide_label.text = slide["text"]
	_next_button.text = "Dalej →" if index < SLIDES.size() - 1 else "Zaczynamy!"
	_update_dots()


func _update_dots() -> void:
	for i: int in _dots_container.get_child_count():
		var dot: Control = _dots_container.get_child(i)
		dot.modulate = Color.WHITE if i == _current else Color(1.0, 1.0, 1.0, 0.3)


func _on_next_pressed() -> void:
	if _current < SLIDES.size() - 1:
		_current += 1
		_show_slide(_current)
	else:
		_finish()


func _finish() -> void:
	DataManager.save(Constants.STORAGE_KEY_ONBOARDING, true)
	SceneManager.go_to(Constants.SCENE_MAIN_MENU)
