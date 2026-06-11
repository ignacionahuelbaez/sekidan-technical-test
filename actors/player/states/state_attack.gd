class_name StateAttack
extends PlayerState

const ATTACK_RANGE: float = 60.0

func enter() -> void:
	player.ejecutar_ataque_direccional()
	_deal_damage_to_nearby_enemies()

func _deal_damage_to_nearby_enemies() -> void:
	for e: Node in player.get_tree().get_nodes_in_group("enemy"):
		var enemy: Enemy = e as Enemy
		if not enemy:
			continue
		if player.global_position.distance_to(enemy.global_position) <= ATTACK_RANGE:
			enemy.take_hit(10.0)

func physics_update(_delta: float) -> void:
	if not player.sprite.is_playing():
		player.change_state("Idle")
