extends Node3D

class_name HitscanWeapon

@export_group("Weapon variables")
@export var shoot_action: StringName = &"play_char_shoot"
@export var damage: int = 1
@export var max_distance: float = 100.0
@export var fire_cooldown: float = 0.6
@export_flags_3d_physics var collision_mask: int = 9

var cooldown_remaining: float = 0.0

@onready var camera: Camera3D = get_node("../CameraHolder/Camera")
@onready var player: CollisionObject3D = get_parent() as CollisionObject3D

func _physics_process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining -= delta

	if Input.is_action_just_pressed(shoot_action) and cooldown_remaining <= 0.0:
		shoot()

func shoot() -> void:
	print("shoot")
	cooldown_remaining = fire_cooldown

	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * max_distance)
	query.collision_mask = collision_mask
	query.exclude = [player.get_rid()]
	query.collide_with_areas = true

	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return

	_apply_damage(result["collider"])

func _apply_damage(collider: Object) -> void:
	var target := collider as Node
	while target != null:
		if target.has_method("take_damage"):
			target.take_damage(damage, player)
			return
		target = target.get_parent()
