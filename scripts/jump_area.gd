extends Area2D

@export var force: float = -1000.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = force
