extends CanvasLayer

var new_scene: String

onready var animation_player:AnimationPlayer = get_node("AnimationPlayer")

func start_transition_to(path:String)->void:
	new_scene = path
	animation_player.play("change_scene")
	
func change_scene()->void:
	assert(get_tree().change_scene(new_scene) == OK)
