class_name StateAttack
extends PlayerState

const ATTACK_RANGE: float = 60.0

func enter() -> void:
	# 1. Ejecutamos el ataque visual en la dirección correcta
	player.ejecutar_ataque_direccional()
	
	# 2. ¡ENCENDEMOS la espada activando el monitoring!
	if player and player.hitbox:
		player.hitbox.monitoring = true
		
	# Mantenemos tu función original que aplica el daño directo a los enemigos cercanos
	_deal_damage_to_nearby_enemies()

func _deal_damage_to_nearby_enemies() -> void:
	for e: Node in player.get_tree().get_nodes_in_group("enemy"):
		var enemy: Enemy = e as Enemy
		if not enemy: 
			continue
		if player.global_position.distance_to(enemy.global_position) <= ATTACK_RANGE:
			# Tu lógica original de daño directo
			if enemy.has_method("take_hit"):
				enemy.take_hit(10.0)

func physics_update(_delta: float) -> void:
	# Si la animación de ataque ya terminó, volvemos a Idle
	if player and player.sprite and not player.sprite.is_playing():
		player.change_state("Idle")

func exit() -> void:
	# 3. ¡APAGAMOS la espada al salir del estado de ataque para no dañar por proximidad!
	if player and player.hitbox:
		player.hitbox.monitoring = false
