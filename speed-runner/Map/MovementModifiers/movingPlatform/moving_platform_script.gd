extends AnimatableBody3D

@export var travel_offset: Vector3 = Vector3(8.0, 0.0, 0.0)
@export_range(0.1, 20.0, 0.1) var movement_speed: float = 2.5
@export_range(0.0, 5.0, 0.1) var endpoint_wait_time: float = 0.5

var start_position: Vector3
var end_position: Vector3
var moving_to_end: bool = true
var wait_remaining: float = 0.0

func _ready() -> void:
	start_position = global_position
	end_position = start_position + travel_offset

func _physics_process(delta: float) -> void:
	if wait_remaining > 0.0:
		wait_remaining = maxf(wait_remaining - delta, 0.0)
		return

	var target_position := end_position if moving_to_end else start_position
	global_position = global_position.move_toward(target_position, movement_speed * delta)
	if global_position.is_equal_approx(target_position):
		moving_to_end = not moving_to_end
		wait_remaining = endpoint_wait_time
