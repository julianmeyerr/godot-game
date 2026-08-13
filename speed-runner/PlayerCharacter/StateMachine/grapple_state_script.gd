extends State

class_name GrappleState

var state_name: String = "Grapple"
var play_char: PlayerCharacter

func enter(play_char_ref: CharacterBody3D) -> void:
	play_char = play_char_ref
	play_char.grapple_active = true
	play_char.set_vertical(play_char.velocity.y)
	play_char.floor_snap_length = 0.0
	play_char.hud.display_speed_lines(true)

func exit() -> void:
	if play_char == null:
		return
	play_char.grapple_active = false
	play_char.grapple_cooldown = play_char.grapple_cooldown_ref
	play_char.hud.display_speed_lines(false)

func physics_update(delta: float) -> void:
	if Input.is_action_just_released(play_char.grapple_action):
		release()
		return

	if !play_char.global_position.is_finite() or !play_char.grapple_point.is_finite():
		if play_char.last_frame_position.is_finite():
			play_char.global_position = play_char.last_frame_position
		play_char.set_horizontal(Vector3.ZERO)
		play_char.set_vertical(0.0)
		release()
		return

	play_char.gravity_apply(delta)
	var current_velocity : Vector3 = play_char.horizontal_velocity + Vector3.UP * play_char.vertical_velocity
	if !current_velocity.is_finite():
		play_char.set_horizontal(Vector3.ZERO)
		play_char.set_vertical(0.0)
		release()
		return

	var to_anchor := play_char.grapple_point - play_char.global_position
	var distance := to_anchor.length()
	if !is_finite(distance) or distance <= 0.001:
		release()
		return

	var rope_direction := to_anchor / distance
	if !rope_direction.is_finite():
		release()
		return
	var radial_velocity := current_velocity.dot(rope_direction)
	if radial_velocity < 0.0:
		current_velocity -= rope_direction * radial_velocity

	var input := Input.get_vector(play_char.move_left_action, play_char.move_right_action, play_char.move_forward_action, play_char.move_backward_action)
	var desired_direction := play_char.cam_holder.global_basis * Vector3(input.x, 0.0, input.y)
	if desired_direction.length_squared() > 0.001:
		desired_direction = desired_direction.normalized()
	else:
		desired_direction = Vector3.ZERO
	var tangent_input := desired_direction - rope_direction * desired_direction.dot(rope_direction)
	if tangent_input.length_squared() > 0.001:
		current_velocity += tangent_input.normalized() * play_char.grapple_swing_acceleration * delta

	# El jugador controla manualmente la longitud de la cuerda.
	# La velocidad tangencial no se elimina, por lo que el balanceo conserva
	# la inercia mientras se recoge el cable.
	if Input.is_action_pressed(play_char.crouch_action):
		play_char.grapple_rope_length = move_toward(
			play_char.grapple_rope_length,
			play_char.grapple_min_distance,
			play_char.grapple_reel_speed * delta
		)

	if current_velocity.length() > play_char.grapple_max_speed:
		current_velocity = current_velocity.normalized() * play_char.grapple_max_speed

	if distance > play_char.grapple_rope_length:
		# No corregimos global_position directamente: CharacterBody3D debe
		# resolver el desplazamiento mediante move_and_slide().
		# Primero eliminamos la velocidad que se aleja del anclaje.
		var outward_velocity := current_velocity.dot(rope_direction)
		if outward_velocity < 0.0:
			current_velocity -= rope_direction * outward_velocity

		# La cuerda acortándose tira hacia el anclaje, pero no elimina la
		# velocidad tangencial responsable del balanceo.
		var rope_error := distance - play_char.grapple_rope_length
		current_velocity += rope_direction * min(rope_error / delta, play_char.grapple_reel_speed)

	# Segunda protección después de todas las fuerzas. La cuerda nunca puede
	# dejar una velocidad que se aleje del anclaje.
	var final_outward_velocity := current_velocity.dot(rope_direction)
	if final_outward_velocity < 0.0:
		current_velocity -= rope_direction * final_outward_velocity
	if current_velocity.length() > play_char.grapple_max_speed:
		current_velocity = current_velocity.normalized() * play_char.grapple_max_speed

	play_char.set_horizontal(current_velocity)
	play_char.set_vertical(current_velocity.y)
func release() -> void:
	# Al soltar se conserva exactamente la velocidad acumulada del balanceo.
	# No se añade ningún impulso artificial que pueda cambiar su dirección.
	transitioned.emit(self, "InairState")
