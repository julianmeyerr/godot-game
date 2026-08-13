extends Area3D

@export_range(0.0, 0.3, 0.01) var friction_multiplier : float = 0.1
@export_range(0.0, 1.0, 0.01) var acceleration_multiplier : float = 0.3

var play_char_body : PlayerCharacter

var original_values : Dictionary = {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body) -> void:
	if body is PlayerCharacter:
		play_char_body = body
		
		original_values[body] = {
			"acceleration": body.movement_acceleration_multiplier,
			"deceleration": body.movement_deceleration_multiplier
		}
		body.movement_acceleration_multiplier = acceleration_multiplier
		body.movement_deceleration_multiplier = friction_multiplier
	
func _on_body_exited(body) -> void:
	if body is PlayerCharacter:
		if body in original_values:
			body.movement_acceleration_multiplier = original_values[body]["acceleration"]
			body.movement_deceleration_multiplier = original_values[body]["deceleration"]
			original_values.erase(body)
	
		play_char_body = null
