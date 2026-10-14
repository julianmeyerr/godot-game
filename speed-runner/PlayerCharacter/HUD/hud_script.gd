extends CanvasLayer

class_name HUD

#player character reference variable
@export var play_char : PlayerCharacter

#label references variables
@onready var crosshair: TextureRect = $Crosshair
@onready var current_state_label_text: Label = %CurrentStateLabelText
@onready var velocity_label_text: Label = %VelocityLabelText
@onready var velocity_vector_label_text : Label = %VelocityVectorLabelText
@onready var is_on_floor_label_text: Label = %IsOnFloorLabelText
@onready var ceiling_check_label_text: Label = %CeilingCheckLabelText
@onready var jump_buffer_label_text: Label = %JumpBufferLabelText
@onready var coyote_time_label_text: Label = %CoyoteTimeLabelText
@onready var nb_jumps_in_air_allowed_label_text: Label = %NbJumpsInAirAllowedLabelText
@onready var jump_cooldown_label_text: Label = %JumpCooldownLabelText
@onready var slide_time_label_text: Label = %SlideTimeLabelText
@onready var slide_cooldown_label_text: Label = %SlideCooldownLabelText
@onready var dash_cooldown_label_text: Label = %DashCooldownLabelText
@onready var wallrun_time_label_text : Label = %WallrunTimeLabelText
@onready var camera_rotation_label_text: Label = %CameraRotationLabelText
@onready var current_fov_label_text: Label = %CurrentFOVLabelText
@onready var camera_bob_vertical_offset_label_text: Label = %CameraBobVerticalOffsetLabelText
@onready var speed_lines_container: ColorRect = %SpeedLinesContainer

@onready var timer_text: Label = %TimerText
@onready var speed_text: Label = %SpeedText

@export_group("Speed Feedback")
@export_range(0.0, 50.0, 0.5) var speed_lines_start_speed: float = 6.0
@export_range(10.0, 100.0, 0.5) var speed_lines_full_speed: float = 34.0
@export_range(0.1, 10.0, 0.1) var speed_lines_fade_speed: float = 3.5

var speed_lines_intensity: float = 0.0
var speed_lines_shader_material: ShaderMaterial
var crosshair_base_scale: Vector2 = Vector2.ONE
var crosshair_base_modulate: Color = Color.WHITE
var speed_text_base_scale: Vector2 = Vector2.ONE
var speed_text_base_modulate: Color = Color.WHITE
var hit_feedback_tween: Tween
var boost_feedback_tween: Tween

func _ready() -> void:
	if play_char == null:
		assert(false, "Player character reference for the hud is mandatory")
	crosshair_base_scale = crosshair.scale
	crosshair_base_modulate = crosshair.modulate
	crosshair.pivot_offset = crosshair.size * 0.5
	speed_text_base_scale = speed_text.scale
	speed_text_base_modulate = speed_text.modulate
	speed_text.pivot_offset = speed_text.size * 0.5
	speed_lines_shader_material = speed_lines_container.material as ShaderMaterial
	if speed_lines_shader_material != null:
		speed_lines_shader_material.set_shader_parameter("effect_strength", 0.0)

func _process(delta : float) -> void:
	_update_speed_lines(delta)
	display_current_runtime()
	
	display_properties()
	
func display_properties() -> void:
	#player character properties
	current_state_label_text.set_text(str(play_char.state_machine.curr_state_name))
	velocity_label_text.set_text(str(round_to_3_decimals(play_char.speed)))
	velocity_vector_label_text.set_text(str("[ ", round_to_3_decimals(play_char.velocity.x)," ", round_to_3_decimals(play_char.velocity.y)," ", round_to_3_decimals(play_char.velocity.z), " ]"))
	is_on_floor_label_text.set_text(str(play_char.is_on_floor()))
	ceiling_check_label_text.set_text(str(play_char.ceiling_check.is_colliding()))
	jump_buffer_label_text.set_text(str(play_char.jump_buff_on))
	coyote_time_label_text.set_text(str(round_to_3_decimals(play_char.coyote_jump_cooldown)))
	nb_jumps_in_air_allowed_label_text.set_text(str(play_char.nb_jumps_in_air_allowed))
	jump_cooldown_label_text.set_text(str(round_to_3_decimals(play_char.jump_cooldown)))
	slide_time_label_text.set_text(str(round_to_3_decimals(play_char.slide_time)))
	slide_cooldown_label_text.set_text(str(round_to_3_decimals(play_char.time_bef_can_slide_again)))
	dash_cooldown_label_text.set_text(str(round_to_3_decimals(play_char.time_bef_can_dash_again)))
	wallrun_time_label_text.set_text(str(round_to_3_decimals(play_char.wallrun_time)))
	
	
	#camera properties
	camera_rotation_label_text.set_text(str("[ ", round_to_3_decimals(play_char.cam.rotation.x)," ", round_to_3_decimals(play_char.cam.rotation.y)," ", round_to_3_decimals(play_char.cam.rotation.z), " ]"))
	current_fov_label_text.set_text(str(play_char.cam.fov))
	camera_bob_vertical_offset_label_text.set_text(str(round_to_3_decimals(play_char.cam.v_offset)))
	
func display_current_runtime() -> void:
	#frames_per_second_label_text.set_text(str(Engine.get_frames_per_second()))
	timer_text.set_text(GameManager.formated_time)
	speed_text.set_text(str(round_to_3_decimals(_get_effective_speed())))

func _get_effective_speed() -> float:
	var effective_speed := play_char.speed * play_char.active_speed_boost_multiplier
	return effective_speed if is_finite(effective_speed) else 0.0

func _update_speed_lines(delta: float) -> void:
	var current_speed := _get_effective_speed()
	var speed_range := maxf(speed_lines_full_speed - speed_lines_start_speed, 0.001)
	var linear_intensity := clampf((current_speed - speed_lines_start_speed) / speed_range, 0.0, 1.0)
	var target_intensity := linear_intensity * linear_intensity * (3.0 - 2.0 * linear_intensity)
	speed_lines_intensity = move_toward(speed_lines_intensity, target_intensity, speed_lines_fade_speed * delta)
	if speed_lines_shader_material != null:
		speed_lines_shader_material.set_shader_parameter("effect_strength", speed_lines_intensity)
	speed_lines_container.visible = speed_lines_intensity > 0.002

func show_hit_feedback() -> void:
	if hit_feedback_tween != null and hit_feedback_tween.is_running():
		hit_feedback_tween.kill()
	crosshair.scale = crosshair_base_scale
	crosshair.modulate = crosshair_base_modulate
	hit_feedback_tween = create_tween()
	hit_feedback_tween.tween_property(crosshair, "scale", crosshair_base_scale * 1.28, 0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hit_feedback_tween.parallel().tween_property(crosshair, "modulate", Color(0.55, 1.0, 0.72, crosshair_base_modulate.a), 0.05)
	hit_feedback_tween.tween_property(crosshair, "scale", crosshair_base_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hit_feedback_tween.parallel().tween_property(crosshair, "modulate", crosshair_base_modulate, 0.12)

func show_speed_boost_feedback() -> void:
	if boost_feedback_tween != null and boost_feedback_tween.is_running():
		boost_feedback_tween.kill()
	speed_text.scale = speed_text_base_scale
	speed_text.modulate = speed_text_base_modulate
	boost_feedback_tween = create_tween()
	boost_feedback_tween.tween_property(speed_text, "scale", speed_text_base_scale * 1.2, 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	boost_feedback_tween.parallel().tween_property(speed_text, "modulate", Color(0.48, 0.95, 1.0, speed_text_base_modulate.a), 0.07)
	boost_feedback_tween.tween_property(speed_text, "scale", speed_text_base_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	boost_feedback_tween.parallel().tween_property(speed_text, "modulate", speed_text_base_modulate, 0.2)
	
func round_to_3_decimals(value: float) -> float:
	return round(value * 1000.0) / 1000.0
