extends Node2D


const SPAWN_EXPLOSION_SCENE:PackedScene = preload("res://rooms/SpawnExplosion.tscn")

const ENEMY_SCENES:Dictionary = {
	"FLYING_CREATURE":preload("res://Enemy/FlyingCreature.tscn")
}

var num_enemies: int
onready var tilemap:TileMap = get_node("TileMap2")
onready var enterance: Node2D = get_node("Enterance")
onready var door_container: Node2D = get_node("Doors")
onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
onready var player_detector:Area2D = get_node("PlayerDetector")


func _ready()->void:
	num_enemies = enemy_positions_container.get_child_count()
	

func _on_enemy_killed()->void:
	num_enemies -= 1
	if num_enemies == 0:
		_open_doors()
	



func _open_doors() ->void:
	for door in door_container.get_children():
		door.openDoor()


func _close_enterance()->void:
	for entry_position in enterance.get_children():
		tilemap.set_cellv(tilemap.world_to_map(entry_position.position),26)
		tilemap.set_cellv(tilemap.world_to_map(entry_position.position)+Vector2.UP,18)



func _spawn_enemies()->void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy:KinematicBody2D = ENEMY_SCENES.FLYING_CREATURE.instance()
		var __ = enemy.connect("tree_exited",self,"_on_enemy_killed")
		enemy.global_position = enemy_position.position
		call_deferred("add_child",enemy)
		
		var spawn_explosion:AnimatedSprite = SPAWN_EXPLOSION_SCENE.instance()
		spawn_explosion.global_position = enemy_position.position
		call_deferred("add_child",spawn_explosion)



func _on_PlayerDetector_body_entered(_body:KinematicBody2D)->void:
	player_detector.queue_free()
	if num_enemies >0:
		_close_enterance()
		_spawn_enemies()
	else:
		_open_doors()
