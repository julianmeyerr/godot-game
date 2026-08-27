extends Area3D

var has_lost : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if has_lost:
		return
	if body is PhysicsBody3D:
		has_lost = true
		GameManager.call_deferred("defeat")
