extends Node2D

const ADDRESS = "127.0.0.1"
const PORT = 3333
var peer = ENetMultiplayerPeer.new()
@onready var interface = $Control

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
	var player_scene = preload("res://player.tscn")
	var novo_jogador = player_scene.instantiate()
	novo_jogador.name = str (id)
	add_child(novo_jogador)
