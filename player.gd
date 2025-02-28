extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animacao = $AnimatedSprite2D
@onready var rotulo = $Label
@export var projetil:PackedScene
var atirando = false
var tipo = "Jogador"


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	if (is_multiplayer_authority()):
		
		var random = RandomNumberGenerator.new()
		var spawns = get_parent().spawnPoints.get_children()
		var spawnAleatorio = spawns[random.randi_range(0, spawns.size() - 1)]
		self.position = spawnAleatorio.position
		
		
		var camera = Camera2D.new()
		camera.limit_left = -686
		camera.limit_right = 1646
		camera.limit_top = 0
		camera.limit_bottom = 700
		camera.zoom = Vector2(1.5,1.5)
		add_child(camera)
	rotulo.text = str(name)

func _physics_process(delta: float) -> void:
	if (!is_multiplayer_authority()):
		return
	
	if (animacao.animation == "death"):
		return
		
	if Input.is_action_just_pressed("shoot") and atirando == false:
		
		rpc_id(1, "criar_projetil", animacao.flip_h, self.position)
		atirando = true
		
		var cooldownTimer = Timer.new()
		cooldownTimer.wait_time = 0.5
		cooldownTimer.connect("timeout", func():
			atirando = false
			cooldownTimer.queue_free())
		add_child(cooldownTimer)
		cooldownTimer.start()
		
		
		
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
	
	if direction < 0:
		animacao.flip_h = true
	elif direction > 0:
		animacao.flip_h = false
	
	if atirando == true:
		animacao.play("shoot")
	elif velocity.y < 0:
		animacao.play("jump")
	elif velocity.y > 0:
		animacao.play("fall")
	elif velocity.x != 0:
		animacao.play("run")
	else:
		animacao.play("idle")

	move_and_slide() 
	
func death():
		var random = RandomNumberGenerator.new()
		var spawns = get_parent().spawnPoints.get_children()
		var spawnAleatorio = spawns[random.randi_range(0, spawns.size() - 1)]
		animacao.play("death")
		$CollisionShape2D.disabled = true
		await animacao.animation_finished
		self.position = spawnAleatorio.position
		$CollisionShape2D.disabled = false
		animacao.play("idle")
		
	
	
	
@rpc("any_peer", "call_local","reliable")
func criar_projetil(direcao, posicao):
	#Criar a bola de fogo
	var novoProjetil = projetil.instantiate()
	novoProjetil.dono = str(multiplayer.get_remote_sender_id())
		#Ajustar as informações da bola de fogo
	if direcao == false:
		novoProjetil.position = Vector2(posicao.x+30, posicao.y)
		novoProjetil.direction = 1
	elif direcao == true:
		novoProjetil.position = Vector2(posicao.x-30, posicao.y)
		novoProjetil.direction = -1
			
		#Adicionar essa bola de fogo ao mundo
	get_parent().add_child(novoProjetil, true)
