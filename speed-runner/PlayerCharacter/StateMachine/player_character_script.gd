extends CharacterBody3D

class_name PlayerCharacter

@export_group("Movement variables")
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float
var active_speed_boost_multiplier: float = 1.0
var speed_boost_time_remaining: float = 0.0
@export var hit_ground_cooldown: float = 0.1 #amount of time the character keep his accumulated speed before losing it (while being on ground)
var movement_acceleration_multiplier: float = 1.0
var movement_deceleration_multiplier: float = 1.0
var hit_ground_cooldown_ref: float
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool
@export var base_hitbox_height: float = 2.0
@export var base_model_height: float = 1.0
@export var height_change_duration: float = 0.15

@export_group("Jump variables")
var jump_height: float = 3.0
var jump_time_to_peak: float = 0.3
var jump_time_to_fall: float = 0.25
@export var jump_cooldown: float = 0.25
var jump_cooldown_ref: float
@export var nb_jumps_in_air_allowed: int = 1
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false

@export_group("Slide variables")
@export var slide_time: float = 1.2
var slide_time_ref: float
@export var time_bef_can_slide_again: float = 0.5
var time_bef_can_slide_again_ref: float
var slide_buff_on: bool = false

@export_group("Dash variables")
@export var dash_time: float = 0.1
var dash_time_ref: float
@export var time_bef_can_dash_again: float = 0.8
var time_bef_can_dash_again_ref: float
var has_dashed : bool = false

@export_group("Wallrun variables")
var can_wallrun : bool = true
var side_check_raycast_collided : int = 0 #if -1, left side, if 1, right side
var last_wallrunned_wall_out_of_time : int = 0 #if -1, left side, if 1, right side
var wall_normal : Vector3 = Vector3.ZERO
@export var wallrun_time : float = 4.5
var wallrun_time_ref : float 
@export var infinite_wallrun_time : bool = false
@export var time_bef_can_wallrun_again : float = 0.2
var time_bef_can_wallrun_again_ref : float

@export_group("Grapple variables")
@export var grapple_max_distance: float = 45.0
@export var grapple_min_distance: float = 5.0
@export_flags_3d_physics var grapple_collision_mask: int = 16
@export var grapple_reel_speed: float = 5.0
@export var grapple_swing_acceleration: float = 11.0
@export var grapple_max_speed: float = 42.0
@export var grapple_cooldown: float = 0.3
var grapple_cooldown_ref: float
var grapple_point: Vector3 = Vector3.ZERO
var grapple_rope_length: float = 0.0
var grapple_active: bool = false

@export_group("Walljump variables")
@export var walljump_lock_in_air_movement_time : float = 0.15
var walljump_lock_in_air_movement_time_ref : float

@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

@export_group("Keybind variables")
@export var move_forward_action: StringName = "play_char_move_forward"
@export var move_backward_action: StringName = "play_char_move_backward"
@export var move_left_action: StringName = "play_char_move_left"
@export var move_right_action: StringName = "play_char_move_right"
@export var crouch_action: StringName = "play_char_crouch"
@export var jump_action: StringName = "play_char_jump"
@export var slide_action: StringName = "play_char_slide"
@export var dash_action: StringName = "play_char_dash"
@export var fly_action: StringName = "play_char_fly"
@export var grapple_action: StringName = "play_char_grapple"
@onready var input_actions_list : Array[StringName] = [move_forward_action, move_backward_action, move_left_action, move_right_action, 
crouch_action, jump_action, slide_action, dash_action, fly_action, grapple_action]
@export var check_on_ready_if_inputs_registered : bool = true
var default_input_actions : Dictionary

#references variables
@onready var cam_holder: Node3D = $CameraHolder
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = $Model
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var state_machine: Node = $StateMachine
@onready var hud: CanvasLayer = $HUD
@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck
@onready var wallrun_floor_check : RayCast3D = %WallrunFloorCheck
@onready var slide_floor_check: RayCast3D = %SlideFloorCheck
@onready var left_wall_check : RayCast3D = %LeftWallCheck
@onready var right_wall_check : RayCast3D = %RightWallCheck

var horizontal_velocity = Vector3.ZERO
var vertical_velocity : float = 0.0

var speed : float

func _ready() -> void:
	#set and value references
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	slide_time_ref = slide_time
	time_bef_can_slide_again_ref = time_bef_can_slide_again
	time_bef_can_slide_again = -1.0
	time_bef_can_dash_again_ref = time_bef_can_dash_again
	time_bef_can_dash_again = -1.0
	wallrun_time_ref = wallrun_time
	time_bef_can_wallrun_again_ref = time_bef_can_wallrun_again
	grapple_cooldown_ref = grapple_cooldown
	grapple_cooldown = -1.0
	walljump_lock_in_air_movement_time_ref = walljump_lock_in_air_movement_time
	walljump_lock_in_air_movement_time = -1.0
	
	build_default_keybinding()
	input_actions_check()
	
func build_default_keybinding() -> void:
	#build it in runtime to ensure that export variables have been set
	default_input_actions = {
		move_forward_action : [Key.KEY_W, Key.KEY_UP],
		move_backward_action : [Key.KEY_S, Key.KEY_DOWN],
		move_left_action : [Key.KEY_A, Key.KEY_LEFT],
		move_right_action : [Key.KEY_D, Key.KEY_RIGHT],
		crouch_action : [Key.KEY_C],
		jump_action : [Key.KEY_SPACE],
		slide_action : [Key.KEY_C],
		dash_action : [Key.KEY_CTRL],
		fly_action : [Key.KEY_F],
		grapple_action : [Key.KEY_Q]
	}
	
func input_actions_check() -> void:
	#check if the input actions written in the editor are the same as the ones registered in the Input map, and if they are written correctly
	#if not, add it to runtime Input map with default keybindings
	if check_on_ready_if_inputs_registered:
		var registered_input_actions: Array[StringName] = []
		for input_action in InputMap.get_actions():
			if input_action.begins_with(&"play_char_"):
				registered_input_actions.append(input_action)
				
		for input_action in input_actions_list:
			if input_action == &"":
				assert(false, "There's an undefined input action")
				
			if not registered_input_actions.has(input_action):
				var key_names = default_input_actions[input_action].map(func(key):
					return OS.get_keycode_string(key)
				)
				
				push_warning("'{input}' missing in InputMap, or input action wrongly named in the editor.\nAdding the '{input}' to runtime InputMap temporarily with the key/s: {keys}"
				.format({"input": input_action, "keys": String(", ").join(key_names)}))
				
				InputMap.add_action(input_action)
				for keycode in default_input_actions[input_action]:
					var input_event_key = InputEventKey.new()
					input_event_key.physical_keycode = keycode
					InputMap.action_add_event(input_action, input_event_key)

func _process(delta: float) -> void:
	wallrun_timer(delta)
	
	slide_timer(delta)
	if grapple_cooldown > 0.0:
		grapple_cooldown -= delta

	jump_timer(delta)
	
	if speed>20: hud.display_speed_lines(true);
	else: hud.display_speed_lines(false)

func jump_timer(delta : float) -> void:
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
		
func wallrun_timer(delta : float) -> void:
	if !can_wallrun:
		if time_bef_can_wallrun_again > 0.0: time_bef_can_wallrun_again -= delta
		else:
			#can only reset capacity of wallrunning when not currently wallrunning
			if state_machine.curr_state_name != "Wallrun":
				wallrun_time = wallrun_time_ref
				can_wallrun = true
	
func slide_timer(delta: float) -> void:
	if time_bef_can_slide_again > 0.0: time_bef_can_slide_again -= delta
	else:
		#can only reset slide time when not sliding
		if state_machine.curr_state_name != "Slide":
			slide_time = slide_time_ref
			
	if time_bef_can_dash_again > 0.0: time_bef_can_dash_again -= delta
	else:
		#can only reset dash time when not dashing
		if state_machine.curr_state_name != "Dash":
			dash_time = dash_time_ref
			
func modify_physics_properties() -> void:
	last_frame_position = global_position #get play char global position every frame
	last_frame_velocity = velocity #get play char velocity every frame
	was_on_floor = is_on_floor() #check if play char was on floor every frame
	
#use of 2 tweens to change the hitbox and model heights, relative to a specific state
func tween_hitbox_height(state_hitbox_height : float) -> void:
	var hitbox_tween: Tween = create_tween()
	if hitbox != null:
		hitbox_tween.tween_method(func(v): set_hitbox_height(v), hitbox.shape.height, 
		state_hitbox_height, height_change_duration)
	#to avoid "no tweeners" error
	else:
		hitbox_tween.tween_interval(0.1)
	hitbox_tween.finished.connect(Callable(hitbox_tween, "kill"))

func set_hitbox_height(value: float) -> void:
	if hitbox.shape is CapsuleShape3D:
		hitbox.shape.height = value
		
func tween_model_height(state_model_height : float) -> void:
	var model_tween: Tween = create_tween()
	if model != null:
		model_tween.tween_property(model, "scale:y", 
		state_model_height, height_change_duration)
	#to avoid "no tweeners" error
	else:
		model_tween.tween_interval(0.1)
	model_tween.finished.connect(Callable(model_tween, "kill"))
	
func _physics_process(_delta: float) -> void:
	update_speed_boost(_delta)

	# Evita propagar NaN/INF al transform del CharacterBody y al renderer.
	if !global_position.is_finite():
		global_position = last_frame_position if last_frame_position.is_finite() else Vector3.ZERO
	if !horizontal_velocity.is_finite():
		horizontal_velocity = Vector3.ZERO
	if !is_finite(vertical_velocity):
		vertical_velocity = 0.0

	modify_physics_properties()
	
	var movement_multiplier := active_speed_boost_multiplier
	speed = Vector2(velocity.x, velocity.z).length()
	velocity = horizontal_velocity * movement_multiplier + Vector3.UP * vertical_velocity
	move_and_slide()
	if movement_multiplier != 1.0:
		velocity.x /= movement_multiplier
		velocity.z /= movement_multiplier

func gravity_apply(delta: float) -> void:
	if is_on_floor():
		vertical_velocity = -0.1  # "stick" al piso, no cero exacto
	else:
		if velocity.y >= 0.0: vertical_velocity += jump_gravity * delta
		elif velocity.y < 0.0: vertical_velocity += fall_gravity * delta
	
func set_horizontal(new_horizontal_v : Vector3):
	new_horizontal_v.y = 0.0
	horizontal_velocity = new_horizontal_v
	
func apply_horizontal(delta_v : Vector3):
	delta_v.y = 0.0
	horizontal_velocity += delta_v

func apply_speed_boost(multiplier: float, duration: float) -> void:
	if multiplier <= 0.0 or duration <= 0.0:
		return
	active_speed_boost_multiplier = multiplier
	speed_boost_time_remaining = duration
	if cam_holder.has_method("set_speed_boost_fov"):
		cam_holder.call("set_speed_boost_fov", true)

func update_speed_boost(delta: float) -> void:
	if speed_boost_time_remaining <= 0.0:
		return

	speed_boost_time_remaining -= delta
	if speed_boost_time_remaining <= 0.0:
		speed_boost_time_remaining = 0.0
		active_speed_boost_multiplier = 1.0
		if cam_holder.has_method("set_speed_boost_fov"):
			cam_holder.call("set_speed_boost_fov", false)

func try_grapple() -> bool:
	if !Input.is_action_just_pressed(grapple_action) or grapple_cooldown > 0.0 or grapple_active:
		return false
	var origin := cam.global_position
	var direction := -cam.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * grapple_max_distance)
	query.collision_mask = grapple_collision_mask
	query.exclude = [get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return false

	var target: Vector3 = result.position
	if origin.distance_to(target) < grapple_min_distance:
		return false

	grapple_point = target
	grapple_rope_length = global_position.distance_to(target)
	return true

func set_vertical(new_vertical_v: float):
	vertical_velocity = new_vertical_v
	
