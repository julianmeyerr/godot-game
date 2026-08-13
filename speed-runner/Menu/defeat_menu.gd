extends Control

const GAME_SCENE := "res://Map/template_map_scene.tscn"
const MAIN_MENU_SCENE := "res://Menu/Main_menu.tscn"

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
