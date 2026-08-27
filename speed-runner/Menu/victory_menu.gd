extends Control

const GAME_SCENE := "res://Map/template_map_scene.tscn"
const MAIN_MENU_SCENE := "res://Menu/Main_menu.tscn"
const RANKING_SCENE :="res://Menu/Ranking_menu.tscn"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Content/PersonalTime/Time.text = GameManager.format_time(GameManager.run_time)
	_show_ranking()

func _show_ranking() -> void:
	var top := GameManager.ranking.slice(0, 3)
	for index in top.size():
		var entry: Dictionary = top[index]
		var row: HBoxContainer = $Content/Ranking.get_node("Rank%d" % (index + 1))
		row.get_node("RankNumber").text = "%d." % (index + 1)
		row.get_node("PlayerName").text = entry["name"]
		row.get_node("Time").text = entry["time_string"]

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_ranking_button_pressed() -> void:
	get_tree().change_scene_to_file(RANKING_SCENE)
