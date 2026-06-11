extends CharacterBody2D
class_name Enemy

@export var speed: float = 100.0
@export var min_attack_distance: float = 30.0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(_delta: float) -> void:
	if not player:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# 1. Lógica de movimiento: 
	# Usamos vector directo para asegurar que siempre apunte al jugador
	if distance_to_player > min_attack_distance:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# 2. Control de animación: Solo reproducir si no está ya reproduciéndose
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
			
		# Orientación horizontal
		if velocity.x != 0:
			animated_sprite.flip_h = velocity.x < 0
	else:
		# En rango de ataque
		velocity = Vector2.ZERO
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
