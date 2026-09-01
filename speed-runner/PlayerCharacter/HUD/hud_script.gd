extends CanvasLayer

class_name HUD

#player character reference variable
@export var play_char : PlayerCharacter

@onready var speed_lines_container: ColorRect = %SpeedLinesContainer

@onready var timer_text: Label = %TimerText
@onready var speed_text: Label = %SpeedText

func _ready() -> void:
	if play_char == null:
		assert(false, "Player character reference for the hud is mandatory")

func _process(_delta : float) -> void:
	display_hud()

func display_hud() -> void:
	timer_text.set_text(GameManager.formated_time)
	speed_text.set_text(str(round_to_3_decimals(play_char.speed)))
	
func display_speed_lines(value : bool) -> void:
	speed_lines_container.visible = value
	
func round_to_3_decimals(value: float) -> float:
	return round(value * 1000.0) / 1000.0
