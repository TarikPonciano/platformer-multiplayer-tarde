extends Node2D

const ADDRESS = "127.0.0.1"
const PORT = 3333
var peer = ENetMultiplayerPeer.new()
@onready var interface = $Control
@export var projetil_scene:PackedScene
@export var player_scene:PackedScene
@onready var spawnPoints = $SpawnPoints
@onready var leaderBoard = $HUD/LeaderBoard
@onready var points = {}

func _on_botao_join_pressed() -> void:
	var resultado = peer.create_client(ADDRESS, PORT)
	if resultado == OK: 
		multiplayer.multiplayer_peer = peer
		print ("deu bom entrar no servidor")
		interface.visible= false
	else:
		print("nao deu bom entrar no servidor") 
		print(resultado)

func _on_botao_host_pressed() -> void:
	var resultado = peer.create_server(PORT)
 
	if resultado == OK: 
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(jogador_conectado)
		interface.visible= false
		print ("deu bom criar o servidor")
		adicionar_jogador(1)
	else:
		print("nao deu bom criar o servidor") 
		print(resultado)
	
func jogador_conectado(id):
	print("O jogador foi conectado", id)
	adicionar_jogador(id)

func adicionar_jogador(id): 
	
	var novo_jogador = player_scene.instantiate()
	novo_jogador.name = str(id)
	add_child(novo_jogador)
	
func update_scores(killer, victim):
	if (points.get(killer)):
		points[killer]["kills"] += 1
	else:
		points[killer] = {"kills": 1, "deaths": 0}
		
	if (points.get(victim)):
		points[victim]["deaths"] += 1
	else:
		points[victim] = {"kills": 0, "deaths": 1}
		
	var texto = "ID - K - D \n"
	for id in points.keys():	
		texto += str(id," - ",points[id]["kills"]," - ",points[id]["deaths"],"\n")
		
	leaderBoard.text = texto
		
	rpc("update_leaderboard", leaderBoard.text)

@rpc("any_peer","call_local", "reliable")
func update_leaderboard(novoLeaderBoard):
	leaderBoard.text = novoLeaderBoard
	
