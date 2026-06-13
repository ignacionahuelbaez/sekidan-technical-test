extends PlayerState

const FLASH_COUNT: int = 4
const FLASH_INTERVAL: float = 0.08


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("idle", Vector2.ZERO)
	_flash()


func _flash() -> void:
	for i: int in range(FLASH_COUNT):
		player.sprite.modulate = Color.RED
		await player.get_tree().create_timer(FLASH_INTERVAL).timeout
		player.sprite.modulate = Color.WHITE
		await player.get_tree().create_timer(FLASH_INTERVAL).timeout
	player.change_state("Idle")
