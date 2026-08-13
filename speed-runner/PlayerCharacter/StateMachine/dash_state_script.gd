extends State

class_name DashState

var state_name : String = "Dash"

var play_char : CharacterBody3D

var dash_direction: Vector3 = Vector3.ZERO
var dash_speed: float = 30.0
var velocity_pre_dash : Vector3

var new_velocity_x : float = 0.0
var new_velocity_y : float = 0.0
var new_velocity_z : float = 0.0


func enter(play_char_ref : CharacterBody3D):
	play_char = play_char_ref
	
	verifications()
	
func verifications():
	velocity_pre_dash = play_char.velocity #get velocity before start dashing, to apply it later, after dash finished, to keep a smooth transitio between dash state and next state
	#play_char.dash_direction = play_char.move_direction.normalized() #get move direction before actually start dashing, and stick to that direction
	
	dash_direction = (-play_char.cam.global_transform.basis.z).normalized()
	
	play_char.hud.display_speed_lines(true)
	
	play_char.tween_hitbox_height(play_char.base_hitbox_height)
	play_char.tween_model_height(play_char.base_model_height)
	
func physics_update(delta : float):
	applies(delta)
	
	move()
	
func applies(delta : float):
	if play_char.dash_time > 0.0: 
		play_char.dash_time -= delta
	else:
		play_char.time_bef_can_dash_again = play_char.time_bef_can_dash_again_ref
		#reset velocity on x and z axis
		play_char.set_horizontal(velocity_pre_dash)
		play_char.has_dashed = true
		play_char.hud.display_speed_lines(false)
		
		play_char.nb_jumps_in_air_allowed = play_char. nb_jumps_in_air_allowed_ref
		
		if play_char.is_on_floor():
			transitioned.emit(self, "RunState")
		else:
			transitioned.emit(self, "InairState")

func move():
	#can't change direction while dashing
	if dash_direction != Vector3.ZERO:
		
		new_velocity_x = dash_direction.x * dash_speed
		new_velocity_y = dash_direction.y * dash_speed 
		new_velocity_z = dash_direction.z * dash_speed
		
		play_char.set_horizontal(Vector3(new_velocity_x, 0.0, new_velocity_z))
		play_char.set_vertical(new_velocity_y)
