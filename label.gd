extends Label

@onready var player = $Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = $Player.name
