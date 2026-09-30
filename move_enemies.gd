extends Area3D

var enemies: Array = []

func _ready() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")

	print("Inimigos encontrados: ", enemies.size())

	for enemy in enemies:
		if enemy is CharacterBody3D:
			enemy.is_active = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("JOGADOR ENTROU")
		
		for enemy in enemies:
			if not is_instance_valid(enemy):
				return
			if enemy is CharacterBody3D:
				enemy.is_active = true
