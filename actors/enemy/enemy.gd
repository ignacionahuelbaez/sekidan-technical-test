extends CharacterBody2D
class_name Enemy

@export var speed: float = 80.0
@export var min_attack_distance: float = 30.0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var bt_player = $BTPlayer

func _ready() -> void:
	add_to_group("enemy")
	
	# IMPORTANTE: Desactivamos colisión física con el jugador (Capa 1).
	# Esto evita que el motor físico empuje al enemigo marcha atrás (el bug de la huida).
	set_collision_mask_value(1, false)
	
	# Inicialización oficial de LimboAI en Godot 4
	if bt_player:
		bt_player.blackboard.set_var("enemy", self)
		bt_player.blackboard.set_var("player", player)
		bt_player.set_active(true) # Corrección del .enabled que tiraba error
		
	if health_component and health_component.has_signal("health_depleted"):
		health_component.connect("health_depleted", Callable(self, "_on_death"))

func _physics_process(_delta: float) -> void:
	if not player:
		return
		
	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	
	if distance > min_attack_distance:
		velocity = direction * speed
		move_and_slide()
		
		if animated_sprite and animated_sprite.animation != "walk":
			animated_sprite.play("walk")
			
		if velocity.x != 0 and animated_sprite:
			animated_sprite.flip_h = velocity.x < 0
	else:
		# Si está en rango de ataque, frena y ejecuta comportamiento
		velocity = Vector2.ZERO
		if animated_sprite and animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _on_death() -> void:
	if bt_player:
		bt_player.set_active(false)
	set_physics_process(false)
	if animated_sprite:
		animated_sprite.play("dead")
