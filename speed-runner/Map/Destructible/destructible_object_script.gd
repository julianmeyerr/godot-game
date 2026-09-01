extends StaticBody3D

class_name DestructibleObject

func take_damage(_amount: int = 1, _shooter: Node = null) -> void:
	queue_free()
