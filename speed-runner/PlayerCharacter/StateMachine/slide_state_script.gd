extends State

class_name SlideState

var state_name : String = "Slide"

var play_char : CharacterBody3D

@export_range(0.0, 90.0, 0.1) var max_slope_angle: float = 75.0 #max slope angle where the slide time operate
@export_range(0.0, 0.1, 0.001) var uphill_tolerance: float = 0.05 #vertical tolerance, to avoid fake uphills
@export var slope_sliding_ms_incre: float = 2.0 #slope sliding slide speed incrementer
@export var continious_slide: bool = true
var slope_angle : float

var speed: float = 12.0
var speed_boost : float = 10
var aplied_speed_boost : bool = false
var speed_ref : float = speed
var acceleration: float = 23.0
var friction: float = 3.5
var slide_hitbox_height: float = 1.0
var slide_model_height: float = 0.5
var amount_velocity_lost_per_sec: float = 16.0

var slide_direction = Vector3.ZERO

var new_velocity_x : float = 0.0
var new_velocity_z : float = 0.0

func enter(play_char_ref : CharacterBody3D) -> void:
	play_char = play_char_ref
	
	verifications()
	
func verifications() -> void:
	
	slide_direction = play_char.move_direction.normalized() #get move direction before actually start sliding, and stick to that direction
	aplied_speed_boost = false
	
	if play_char.floor_snap_length != 1.0: play_char.floor_snap_length = 1.0
	if play_char.jump_cooldown > 0.0: play_char.jump_cooldown = -1.0
	if play_char.nb_jumps_in_air_allowed < play_char.nb_jumps_in_air_allowed_ref: 
		play_char.nb_jumps_in_air_allowed = play_char.nb_jumps_in_air_allowed_ref
	if play_char.coyote_jump_cooldown < play_char.coyote_jump_cooldown_ref: 
		play_char.coyote_jump_cooldown = play_char.coyote_jump_cooldown_ref
	if play_char.has_dashed: play_char.has_dashed = false
	if play_char.last_wallrunned_wall_out_of_time != 0: 
		play_char.last_wallrunned_wall_out_of_time = 0
	
	play_char.tween_hitbox_height(slide_hitbox_height)
	play_char.tween_model_height(slide_model_height)
	
func physics_update(delta : float) -> void:
	applies()
	
	play_char.gravity_apply(delta)
	
	input_management()
	
	move(delta)
	
func applies() -> void:
	if (play_char.global_position.y - play_char.last_frame_position.y) > uphill_tolerance: #check if play char is uphill
		slide_direction = Vector3.ZERO
		if !raycast_verification():
			transitioned.emit(self, "RunState")
		else:
			transitioned.emit(self, "CrouchState")
			
	slope_angle = rad_to_deg(acos(play_char.get_floor_normal().dot(Vector3.UP)))
	
	#if current slope angle superior than max slope angle, play char slides indefinitely while he's on the slope
	if slope_angle < max_slope_angle:
		if play_char.speed <=5:
			slide_direction = Vector3.ZERO
			play_char.time_bef_can_slide_again = play_char.time_bef_can_slide_again_ref
			if !raycast_verification():
				transitioned.emit(self, "RunState")
			else:
				transitioned.emit(self, "CrouchState")
				
	if play_char.is_on_floor():
		if play_char.jump_buff_on and play_char.jump_cooldown <= 0.0:
			play_char.buffered_jump = true
			play_char.jump_buff_on = false
			transitioned.emit(self, "JumpState")
				
func input_management() -> void:
	if Input.is_action_just_pressed(play_char.jump_action):
		#if nothing block play char when he will leave the slide state
		if (slope_angle > max_slope_angle or !raycast_verification()) and play_char.jump_cooldown <= 0.0:
			#force break slide state
			play_char.slide_time = -1.0
			slide_direction = Vector3.ZERO
			play_char.time_bef_can_slide_again = play_char.time_bef_can_slide_again_ref
			transitioned.emit(self, "JumpState")
			
	if continious_slide: 
		#has to press slide button once to run
		if Input.is_action_just_pressed(play_char.slide_action):
			play_char.slide_time = -1.0
			slide_direction = Vector3.ZERO
			play_char.time_bef_can_slide_again = play_char.time_bef_can_slide_again_ref
			if !raycast_verification():
				transitioned.emit(self, "RunState")
			else:
				transitioned.emit(self, "CrouchState")
	else:
		#has to continuously press slide button to play_charouch
		if !Input.is_action_pressed(play_char.slide_action):
			if !raycast_verification():
				play_char.slide_time = -1.0
				slide_direction = Vector3.ZERO
				play_char.time_bef_can_slide_again = play_char.time_bef_can_slide_again_ref
				if !raycast_verification():
					transitioned.emit(self, "RunState")
				else:
					transitioned.emit(self, "CrouchState")
			
func raycast_verification() -> bool:
	#check if the raycast used to check ceilings is colliding or not
	return play_char.ceiling_check.is_colliding()
	
func move(delta : float) -> void:
	#can't change direction while sliding	
	speed = play_char.speed
	if slide_direction and play_char.is_on_floor():
		if slope_angle < max_slope_angle and (play_char.desired_move_speed - amount_velocity_lost_per_sec * delta > 0.0): 
			speed = lerp(speed, 0.0, friction * play_char.movement_deceleration_multiplier * delta)
		else: speed += slope_sliding_ms_incre * delta
		
		var slide_acceleration: float = acceleration * play_char.movement_acceleration_multiplier
		new_velocity_x = lerp(play_char.velocity.x, play_char.move_direction.x * speed, slide_acceleration * delta)
		new_velocity_z = lerp(play_char.velocity.z, play_char.move_direction.z * speed, slide_acceleration * delta)
		
		play_char.set_horizontal(Vector3(new_velocity_x, 0.0, new_velocity_z))
		
		#apply the speed boost in the first frame
		if !aplied_speed_boost: play_char.apply_horizontal(speed_boost * slide_direction); aplied_speed_boost = true
		
