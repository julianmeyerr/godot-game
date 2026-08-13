extends Control

const GAME_SCENE := "res://Map/template_map_scene.tscn"
const RANKING_SCENE :="res://Menu/Ranking_menu.tscn"

@onready var main_panel: VBoxContainer = %MainPanel

@onready var controls_panel: VBoxContainer = %ControlsPanel
@onready var controls_button: Button = %ControlsButton
@onready var controls_back_button: Button = %ControlsBackButton

@onready var credits_panel: VBoxContainer = %CreditsPanel
@onready var credits_button : Button = %CreditsButton
@onready var credits_back_button: Button = %CreditsBackButton

@onready var play_button: Button = %PlayButton
@onready var name_panel: VBoxContainer = %NamePanel
@onready var start_button: Button = %StartButton
@onready var name_input: LineEdit = %NameInput
@onready var error_message: Label = %ErrorMessage


func _ready() -> void:
	play_button.grab_focus()


func _on_play_button_pressed() -> void: 
	main_panel.visible = false
	name_panel.visible = true
	name_input.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	main_panel.visible = false
	credits_panel.visible = true
	credits_back_button.grab_focus()

func _on_credits_back_button_pressed() -> void:
	credits_panel.visible = false
	main_panel.visible = true
	credits_button.grab_focus()


func _on_controls_button_pressed() -> void:
	main_panel.visible = false
	controls_panel.visible = true
	controls_back_button.grab_focus()

func _on_ranking_button_pressed() -> void:
	get_tree().change_scene_to_file(RANKING_SCENE)
	
func _on_controls_back_button_pressed() -> void:
	controls_panel.visible = false
	main_panel.visible = true
	controls_button.grab_focus()


func _on_accept_button_pressed() -> void:
	if name_input.text: get_tree().change_scene_to_file(GAME_SCENE);
	else: error_message.visible = true
