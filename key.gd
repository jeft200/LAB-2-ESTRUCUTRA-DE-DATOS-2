extends Node2D

func _ready():
	if self.name in Global.key_founded:
		queue_free()
	print(Global.key_founded)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	Global.key_founded.append(self.name)
	queue_free()
	
