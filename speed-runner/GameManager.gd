extends Node

const RANKING_PATH := "user://ranking.json"
const VICTORY_SCENE := "res://Menu/Victory_menu.tscn"
const DEFEAT_SCENE := "res://Menu/Defeat_menu.tscn"

var player_name: String = ""
var run_time: float = 0.0
var formated_time: String
var is_running: bool = false
var waiting_to_start: bool = false
var ranking: Array = []

func _ready() -> void:
	load_ranking()

func start_run() -> void:
	run_time = 0.0
	is_running = false
	waiting_to_start = true

func finish_run() -> void:
	if waiting_to_start:
		waiting_to_start = false
		return
	if not is_running:
		return
	is_running = false

	var entry := {
		"name": player_name if player_name != "" else "SIN NOMBRE",
		"time": run_time,
		"time_string": format_time(run_time)
	}
	ranking.append(entry)
	_keep_best_per_player()
	ranking.sort_custom(_sort_by_time)
	save_ranking()

	get_tree().change_scene_to_file(VICTORY_SCENE)

func defeat() -> void:
	waiting_to_start = false
	is_running = false
	get_tree().change_scene_to_file(DEFEAT_SCENE)

func _process(delta: float) -> void:
	if waiting_to_start and _player_moved():
		waiting_to_start = false
		is_running = true
	if is_running:
		run_time += delta
	formated_time = format_time(run_time)

func _player_moved() -> bool:
	return Input.is_action_pressed("play_char_move_forward") \
		or Input.is_action_pressed("play_char_move_backward") \
		or Input.is_action_pressed("play_char_move_left") \
		or Input.is_action_pressed("play_char_move_right") \
		or Input.is_action_pressed("play_char_jump") \
		or Input.is_action_pressed("play_char_dash")

func _sort_by_time(a: Dictionary, b: Dictionary) -> bool:
	return a["time"] < b["time"]

func _keep_best_per_player() -> void:
	var best := {}
	for e in ranking:
		var name: String = e["name"]
		if not best.has(name) or e["time"] < best[name]["time"]:
			best[name] = e
	ranking = best.values()

func format_time(seconds: float) -> String:
	var m := int(seconds) / 60
	var s := int(seconds) % 60
	var cs := int((seconds - floor(seconds)) * 100)
	return "%02d:%02d.%02d" % [m, s, cs]

func save_ranking() -> void:
	var data := []
	for e in ranking:
		data.append({"name": e["name"], "time": e["time_string"]})

	var file := FileAccess.open(RANKING_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func load_ranking() -> void:
	var file := FileAccess.open(RANKING_PATH, FileAccess.READ)
	if file == null:
		return

	var data = JSON.parse_string(file.get_as_text())
	if not data is Array:
		return

	for e in data:
		if e is Dictionary and e.has("name") and e.has("time"):
			ranking.append({
				"name": str(e["name"]),
				"time": parse_time_string(str(e["time"])),
				"time_string": str(e["time"])
			})

func parse_time_string(t: String) -> float:
	var parts := t.split(":")
	if parts.size() < 2:
		return 0.0
	var m := float(parts[0])
	var rest := parts[1].split(".")
	var s := float(rest[0])
	var cs := 0.0
	if rest.size() > 1:
		cs = float(rest[1]) / 100.0
	return m * 60.0 + s + cs
