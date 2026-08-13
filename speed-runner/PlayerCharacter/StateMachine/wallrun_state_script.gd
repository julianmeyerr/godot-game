extends State

class_name WallrunState

var state_name : String = "Wallrun"

var play_char : CharacterBody3D

var speed : float = 18.0
var acceleration : float = 2.3
var decceleration : float = 7.0

var wall_forward_dir : Vector3 = Vector3.ZERO

var new_velocity_x : float = 0.0
var new_velocity_y : float = 0.0
var new_velocity_z : float = 0.0

func enter(play_char_ref : CharacterBody3D) -> void:
	play_char = play_char_ref
	
	verifications()
	
func verifications() -> void:
	wallrun_forward_direction_calculus()
	
	play_char.set_vertical(0.0)
	
	if play_char.floor_snap_length != 1.0: play_char.floor_snap_length = 1.0
	if play_char.jump_cooldown > 0.0: play_char.jump_cooldown = -1.0
	if play_char.nb_jumps_in_air_allowed < play_char.nb_jumps_in_air_allowed_ref:
		play_char.nb_jumps_in_air_allowed = play_char.nb_jumps_in_air_allowed_ref
	if play_char.coyote_jump_cooldown < play_char.coyote_jump_cooldown_ref:
		play_char.coyote_jump_cooldown = play_char.coyote_jump_cooldown_ref
	if play_char.time_bef_can_wallrun_again < play_char.time_bef_can_wallrun_again_ref:
		play_char.time_bef_can_wallrun_again = play_char.time_bef_can_wallrun_again_ref
	if play_char.has_dashed: play_char.has_dashed = false
	
	play_char.tween_hitbox_height(play_char.base_hitbox_height)
	play_char.tween_model_height(play_char.base_model_height)
	
func physics_update(delta : float) -> void:
	applies(delta)
	
	
	move(delta)
	input_management()
	
func applies(delta : float) -> void:
	wallrun_forward_direction_calculus()
	
	if !play_char.infinite_wallrun_time:
		if play_char.wallrun_time > 0.0: play_char.wallrun_time -= delta
		else:
			play_char.can_wallrun = false
			play_char.last_wallrunned_wall_out_of_time = play_char.side_check_raycast_collided #get last wall side where play char wallrunned
			transitioned.emit(self, "InairState")
			
	if (!play_char.is_on_floor() and !play_char.is_on_wall() and \
	!play_char.left_wall_check.is_colliding() and !play_char.right_wall_check.is_colliding()) or \
	play_char.wallrun_floor_check.is_colliding():
		play_char.can_wallrun = false
		transitioned.emit(self, "InairState")
	
func input_management() -> void:
	if play_char.try_grapple():
		transitioned.emit(self, "GrappleState")
		return

	if Input.is_action_just_pressed(play_char.jump_action):
		if play_char.jump_cooldown <= 0.0:
			play_char.can_wallrun = false
			transitioned.emit(self, "JumpState")
	
func move(delta : float) -> void:
	
	if Input.is_action_pressed(play_char.move_forward_action):
		
			new_velocity_x = lerp(play_char.velocity.x, wall_forward_dir.x * speed, acceleration * delta)
			new_velocity_z = lerp(play_char.velocity.z, wall_forward_dir.z * speed, acceleration * delta)
			
			play_char.set_horizontal(Vector3(new_velocity_x, 0.0, new_velocity_z))
	else:
		play_char.can_wallrun = false
		transitioned.emit(self, "InairState")
		
func wallrun_forward_direction_calculus():
	#get wall normal
	if play_char.side_check_raycast_collided == -1:
		play_char.wall_normal = play_char.left_wall_check.get_collision_normal()
	if play_char.side_check_raycast_collided == 1:
		play_char.wall_normal = play_char.right_wall_check.get_collision_normal()
		
	#calculate the forward direction of the wall the player character will move to
	wall_forward_dir = (play_char.velocity.normalized() - play_char.wall_normal * \
	play_char.velocity.normalized().dot(play_char.wall_normal)).normalized()
