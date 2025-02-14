extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animacao = $AnimatedSprite2D
@onready var rotulo = $Label

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	if (is_multiplayer_authority()):
		var camera = Camera2D.new()
		add_child(camera)
	rotulo.text = str(name)

func _physics_process(delta: float) -> void:
	if (!is_multiplayer_authority()):
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction == -1:
		animacao.flip_h = true
	elif direction == 1:
		animacao.flip_h = false
	
	if velocity.y < 0:
		animacao.play("jump")
	elif velocity.y > 0:
		animacao.play("fall")
	elif velocity.x != 0:
		animacao.play("run")
	else:
		animacao.play("idle")

	move_and_slide() 
