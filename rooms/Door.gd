extends StaticBody2D


onready var animation_player:AnimationPlayer = get_node("AnimationPlayer")


func openDoor()->void:
	animation_player.play("open")
