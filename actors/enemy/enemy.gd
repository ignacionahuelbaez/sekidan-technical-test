class_name Enemy
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var bt_player: BTPlayer = $BTPlayer

func _ready() -> void:
	add_to_group("enemy")
	set_collision_mask_value(1, false)
	health_component.health_depleted.connect(_on_death)

func take_hit(damage: float) -> void:
	health_component.take_damage(damage)

func _on_death() -> void:
	bt_player.set_active(false)
	set_physics_process(false)
	animated_sprite.play("dead")
