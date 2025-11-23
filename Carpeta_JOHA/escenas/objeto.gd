extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	# Efecto visual
	$Sprite2D.modulate = Color.YELLOW

func _on_body_entered(body):
	if body.name == "Player":
		var gestor = get_parent()
		if gestor.has_method("_on_objetivo_alcanzado"):
			gestor._on_objetivo_alcanzado()
