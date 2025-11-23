extends Camera2D

@onready var player = get_parent().get_node("Player")

func _process(_delta):
	if player:
		global_position = player.global_position
