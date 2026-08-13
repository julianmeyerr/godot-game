extends Control

const RANKING_PATH := "user://ranking.json"
const MAIN_MENU_SCENE := "res://Menu/Main_menu.tscn"

@onready var ranking_list: VBoxContainer = %RankingList

func _ready() -> void:
	_load_ranking()

func _load_ranking() -> void:
	var file := FileAccess.open(RANKING_PATH, FileAccess.READ)
	if file == null:
		_show_empty_ranking()
		return

	var data = JSON.parse_string(file.get_as_text())
	if not data is Array or data.is_empty():
		_show_empty_ranking()
		return

	for index in data.size():
		var entry = data[index]
		if entry is Dictionary:
			_add_ranking_row(index + 1, str(entry.get("name", "SIN NOMBRE")), str(entry.get("time", "--:--.--")))

	if ranking_list.get_child_count() == 0:
		_show_empty_ranking()

func _add_ranking_row(place: int, player_name: String, time: String) -> void:
	var row := Label.new()
	row.text = "%02d    %-20s    %s" % [place, player_name, time]
	row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking_list.add_child(row)

func _show_empty_ranking() -> void:
	var empty_label := Label.new()
	empty_label.text = "Todavia no hay tiempos registrados."
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking_list.add_child(empty_label)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
