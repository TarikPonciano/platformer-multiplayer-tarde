extends Area2D

const SPEED = 200
var direction = 1
@onready var animacao = $AnimatedSprite2D
func _ready() -> void:
	var despawnTimer = Timer.new()
	despawnTimer.wait_time = 3
	despawnTimer.connect("timeout", func():
		
		self.queue_free()
		despawnTimer.queue_free() )
	add_child(despawnTimer)
	despawnTimer.start()

func _physics_process(delta: float) -> void:
	if direction == 1:
		position.x += SPEED * delta
		animacao.flip_h = false
	elif direction == -1:
		position.x -= SPEED * delta
		animacao.flip_h = true
	
