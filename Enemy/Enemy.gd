extends Character
class_name Enemy

var path: PoolVector2Array
var player_spotted:bool = false

onready var navigation:Navigation2D = get_tree().current_scene.get_node("World")
onready var player: KinematicBody2D = get_tree().current_scene.get_node("World/Player")
onready var path_timer:Timer = get_node("PathTimer")
onready var los:RayCast2D = get_node("EnemyLOS")

func check_player_detection()->bool:
	var collider = los.get_collider()
	if collider and collider.get_tree().current_scene.get_node("World/Player"):
		player_spotted = true
		return true
	return false
	
func find_player()->void:
	if is_instance_valid(player):
		los.look_at(player.position)
		check_player_detection()
		if player_spotted:
			chase()

func chase() ->void:
	if path:
		state_machine.set_state(state_machine.states.chase)
		var vector_to_next_point: Vector2 = path[0] - global_position
		var distance_to_next_point: float = vector_to_next_point.length()
		if distance_to_next_point < 1 :
			path.remove(0)
			if not path:
				return
		move_direction = vector_to_next_point
		
		if vector_to_next_point.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
		elif vector_to_next_point.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true



func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		path = navigation.get_simple_path(global_position,player.position)
	else:
		state_machine.set_state(state_machine.states.idle)
		path_timer.stop()
		path = []
		move_direction = Vector2.ZERO
