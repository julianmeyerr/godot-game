extends MeshInstance3D

@onready var play_char: PlayerCharacter = get_parent()
@onready var origin: Node3D = get_node("../GrappleOrigin")

func _process(_delta: float) -> void:
	if !play_char.grapple_active:
		visible = false
		return

	visible = true
	var start := origin.global_position
	var end := play_char.grapple_point
	if !start.is_finite() or !end.is_finite():
		visible = false
		return

	var length := start.distance_to(end)
	if !is_finite(length) or length <= 0.001:
		visible = false
		return

	var direction := (end - start).normalized()
	var up := Vector3.UP
	if abs(direction.dot(up)) > 0.98:
		up = Vector3.RIGHT

	global_position = (start + end) * 0.5
	look_at(end, up)
	rotate_object_local(Vector3.RIGHT, -PI * 0.5)
	scale = Vector3(0.025, length * 0.5, 0.025)
