extends Area2D

const SPEED = 200
var direction = 1
@onready var animacao = $AnimatedSprite2D
@export var dono: String

func _enter_tree() -> void:
	set_multiplayer_authority(1)

func _ready() -> void:
	var despawnTimer = Timer.new()
	despawnTimer.wait_time = 3
	despawnTimer.connect("timeout", func():
		
		self.queue_free()
		despawnTimer.queue_free() )
	add_child(despawnTimer)
	despawnTimer.start()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if direction == 1:
			position.x += SPEED * delta
			animacao.flip_h = false
		elif direction == -1:
			position.x -= SPEED * delta
			animacao.flip_h = true
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogadores"):
		if (body.name != dono and multiplayer.get_unique_id() == 1):
			#body.death()
			rpc_id(body.name.to_int(), "player_death_multiplayer", body.name)
			self.queue_free()
			
@rpc("any_peer", "call_local", "reliable")
func player_death_multiplayer(id_jogador):
	var jogador = get_parent().get_node_or_null(str(id_jogador))
	if jogador:
		jogador.death()
		
