extends State

class_name CrouchState

var state_name : String = "Crouch"

var play_char : CharacterBody3D
@export var continious_crouch: bool = false #if true, doesn't need to keep crouch button on to crouch
var speed: float = 4.5
var acceleration: float = 12.0
var decceleration: float = 11.0
var crouch_hitbox_height: float = 1.2
var crouch_model_height: float = 0.6
var backward_speed_multiplier : float = 0.7

var new_velocity_x : float = 0.0
var new_velocity_z : float = 0.0

func enter(play_char_ref : CharacterBody3D) -> void:
	play_char = play_char_ref
	
	verifications()
	
func verifications() -> void:
	
	play_char.floor_snap_length = 1.0
	if play_char.jump_cooldown > 0.0: play_char.jump_cooldown = -1.0
	if play_char.nb_jumps_in_air_allowed < play_char.nb_jumps_in_air_allowed_ref:
		play_char.nb_jumps_in_air_allowed = play_char.nb_jumps_in_air_allowed_ref
	if play_char.coyote_jump_cooldown < play_char.coyote_jump_cooldown_ref:
		play_char.coyote_jump_cooldown = play_char.coyote_jump_cooldown_ref
	if play_char.has_dashed:
		play_char.has_dashed = false
	if play_char.last_wallrunned_wall_out_of_time != 0:
		play_char.last_wallrunned_wall_out_of_time = 0
	
	play_char.tween_hitbox_height(crouch_hitbox_height)
	play_char.tween_model_height(crouch_model_height)
	
func physics_update(delta : float) -> void:
	applies(delta)
	
	play_char.gravity_apply(delta)
	
	input_management()
	
	move(delta)
	
func applies(delta : float) -> void:
	if play_char.hit_ground_cooldown > 0.0: play_char.hit_ground_cooldown -= delta
	if !play_char.is_on_floor() and !play_char.is_on_wall():
		if play_char.velocity.y < 0.0:
			transitioned.emit(self, "InairState")
			
	if play_char.is_on_floor():
		if play_char.jump_buff_on and play_char.jump_cooldown <= 0.0:
			play_char.buffered_jump = true
			play_char.jump_buff_on = false
			transitioned.emit(self, "JumpState")
	
func input_management() -> void:
	if Input.is_action_just_pressed(play_char.jump_action):
		if play_char.jump_cooldown <= 0.0 and !raycast_verification(): #if nothing block the player character when it will leaves the crouch state
			transitioned.emit(self, "JumpState")
			
	if continious_crouch: 
		#has to press run button once to run
		if Input.is_action_just_pressed(play_char.crouch_action):
			if !raycast_verification():
				transitioned.emit(self, "RunState")
	else:
		#has to continuously press play_charouch button to play_charouch
		if !Input.is_action_pressed(play_char.crouch_action):
			if !raycast_verification():
				transitioned.emit(self, "RunState")
			
func raycast_verification() -> bool:
	#check if the raycast used to check ceilings is colliding or not
	return play_char.ceiling_check.is_colliding()
			
func move(delta : float) -> void:
	play_char.input_direction = Input.get_vector(play_char.move_left_action, play_char.move_right_action, play_char.move_forward_action, play_char.move_backward_action)
	play_char.move_direction = (play_char.cam_holder.global_basis * Vector3(play_char.input_direction.x, 0.0, play_char.input_direction.y)).normalized()
	
	
	if play_char.move_direction and play_char.is_on_floor():
		new_velocity_x = lerp(
			play_char.velocity.x, 
			play_char.move_direction.x * speed * (backward_speed_multiplier if play_char.input_direction.y > 0.0 else 1.0), 
			acceleration * play_char.movement_acceleration_multiplier * delta)
			
		new_velocity_z = lerp(
			play_char.velocity.z, 
			play_char.move_direction.z * speed * (backward_speed_multiplier if play_char.input_direction.y > 0.0 else 1.0), 
			acceleration * play_char.movement_acceleration_multiplier * delta)
	else:
		var deceleration: float = decceleration * play_char.movement_deceleration_multiplier
		new_velocity_x = lerp(play_char.velocity.x, 0.0, deceleration * delta)
		new_velocity_z = lerp(play_char.velocity.z, 0.0, deceleration * delta)
		
	play_char.set_horizontal(Vector3(new_velocity_x, 0.0, new_velocity_z))
	if play_char.hit_ground_cooldown <= 0: play_char.desired_move_speed = play_char.velocity.length()
