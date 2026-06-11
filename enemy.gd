extends CharacterBody2D
class_name Enemy

@export var speed: float = 100.0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not player: return
	
	var dir = (player.global_position - global_position).normalized()
	var dist = global_position.distance_to(player.global_position)
	
	if dist > 40:
		position += dir * speed * delta
		animated_sprite.play("walk")
		animated_sprite.flip_h = dir.x < 0
	else:
		animated_sprite.play("idle")
