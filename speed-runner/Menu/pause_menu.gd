extends CanvasLayer

const GAME_SCENE := "res://Map/template_map_scene.tscn"
const MAIN_MENU_SCENE := "res://Menu/Main_menu.tscn"

@onready var pause_overlay: Control = $PauseOverlay
@onready var continue_button: Button = $PauseOverlay/CenterContainer/Menu/ContinueButton

var is_paused: bool = false
var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	pause_overlay.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause_game"):
		return
	if event is InputEventKey and event.echo:
		return
	get_viewport().set_input_as_handled()
	if is_paused:
		_resume_game()
	else:
		_pause_game()

func _pause_game() -> void:
	previous_mouse_mode = Input.get_mouse_mode()
	is_paused = true
	get_tree().paused = true
	pause_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	continue_button.grab_focus()

func _resume_game() -> void:
	is_paused = false
	pause_overlay.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(previous_mouse_mode)

func _on_continue_button_pressed() -> void:
	# Deja que expire el clic de la interfaz antes de reactivar el disparo.
	await get_tree().process_frame
	_resume_game()

func _on_restart_button_pressed() -> void:
	await get_tree().process_frame
	_change_scene(GAME_SCENE)

func _on_main_menu_button_pressed() -> void:
	await get_tree().process_frame
	_change_scene(MAIN_MENU_SCENE)

func _change_scene(scene_path: String) -> void:
	GameManager.is_running = false
	GameManager.waiting_to_start = false
	is_paused = false
	pause_overlay.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(scene_path)
