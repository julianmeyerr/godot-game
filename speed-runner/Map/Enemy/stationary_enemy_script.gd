extends StaticBody3D

class_name StationaryEnemy

@export_group("Speed boost")
@export var enable_speed_boost: bool = true
@export_range(1.0, 5.0, 0.1) var speed_boost_multiplier: float = 1.5
@export_range(0.0, 10.0, 0.1) var speed_boost_duration: float = 3.0

func take_damage(_amount: int = 1, shooter: Node = null) -> void:
	if enable_speed_boost and shooter is PlayerCharacter:
		shooter.apply_speed_boost(speed_boost_multiplier, speed_boost_duration)

	queue_free()
