extends Control

const GAME_SCENE := "res://Map/template_map_scene.tscn"
const MAIN_MENU_SCENE := "res://Menu/Main_menu.tscn"
const RANKING_SCENE :="res://Menu/Ranking_menu.tscn"

const MOCKUP_PERSONAL_TIME := "1:47:32"
const MOCKUP_RANKING := [
	{"name": "Alejandro Marchena", "time": "1:52:32"},
	{"name": "Sean Ron", "time": "1:58:09"},
	{"name": "Julian Meyer", "time": "2:05:56"}
]

func _ready() -> void:
	$Content/PersonalTime/Time.text = MOCKUP_PERSONAL_TIME
	_show_mockup_ranking()

func _show_mockup_ranking() -> void:
	for index in MOCKUP_RANKING.size():
		var entry: Dictionary = MOCKUP_RANKING[index]
		var row: HBoxContainer = $Content/Ranking.get_node("Rank%d" % (index + 1))
		row.get_node("RankNumber").text = "%d." % (index + 1)
		row.get_node("PlayerName").text = entry["name"]
		row.get_node("Time").text = entry["time"]

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_ranking_button_pressed() -> void:
	get_tree().change_scene_to_file(RANKING_SCENE)
