# Inicializa el enemigo y conecta el Blackboard de LimboAI con el jugador.
# Todo el comportamiento de movimiento y animación lo maneja el BehaviorTree.
class_name Enemy
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var bt_player: BTPlayer = $BTPlayer

func _ready() -> void:
	add_to_group("enemy")
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		bt_player.blackboard.set_var(&"player", player)
	health_component.health_depleted.connect(_on_death)

func _on_death() -> void:
	bt_player.set_active(false)
	set_physics_process(false)
	animated_sprite.play("dead")
