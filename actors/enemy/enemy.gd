class_name Enemy
extends CharacterBody2D

@onready var bt_player: BTPlayer = $BTPlayer

func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player:
		bt_player.blackboard.set_var(&"player", player)
