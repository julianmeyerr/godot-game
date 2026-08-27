extends Area3D

var has_won : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if has_won:
		return
	if body is PhysicsBody3D:
		has_won = true
		GameManager.call_deferred("finish_run")
