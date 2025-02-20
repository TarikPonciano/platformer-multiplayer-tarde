extends Area2D

const SPEED = 200
func _physics_process(delta: float) -> void:
	position.x += SPEED * delta
	
