extends Node2D

const Player = preload("res://player/Player.tscn")
var player = null

const ENEMY_SCENES:Dictionary = {
	#"FLYING_CREATURE":preload("res://Enemy/FlyingCreature.tscn"),
	"ROBOT_1":preload("res://Enemy/Robot_1.tscn"),
	"ROBOT_2":preload("res://Enemy/Robot_2.tscn"),
	"FLOAT_ROBOT":preload("res://Enemy/Floating_robot.tscn")
}

const TRAPS_SCENES:Dictionary ={
	"Spikes":preload("res://traps/Spikes.tscn")
}

const FLOOR_TILE:Dictionary = {
	"FLOOR_1":0,
	"FLOOR_2":1,
	"FLOOR_3":3,
	"FLOOR_4":4,
	"FLOOR_5":6
}

var borders = Rect2(2, 2, 38, 21)

onready var tileMap:TileMap = get_node("TileMap")
onready var tileMap2:TileMap = get_node("TileMap2")
onready var tileMapSciFi:TileMap = get_node("Sci-Fi")

var enemies_created:int
var enemies_killed:int


func _ready():
	randomize()
	generate_level()
	generate_floor()
	generate_wall()
	generate_ceiling()
	generate_traps()


func generate_level():
	var walker = Walker.new(Vector2(19, 11), borders)
	var map = walker.walk(300,6)
	player = Player.instance()
	add_child(player)
	player.position = map.front()*32
	#_place_traps_in_scene(walker.place_traps())
	_place_object_in_scene(walker.place_enemy())
	
	
	walker.queue_free()
	for location in map:
		tileMap.set_cellv(location, 1)
	tileMap.update_bitmask_region(borders.position, borders.end)

func generate_floor()->void:
	var cells = tileMap.get_used_cells()
	var tile_chance:float = 0.2
	for tile_pos in cells:
		if tileMap.get_cellv(tile_pos) == 1 and  randf() < tile_chance:
			var tile_rand = random_dictionary(FLOOR_TILE)
			tileMap2.set_cellv(tile_pos,FLOOR_TILE[tile_rand])
			
			
func generate_traps()->void:
	var cells = tileMap.get_used_cells()
	var tile_chance:float = 0.05
	for tile_pos in cells:
		if tileMap.get_cellv(tile_pos) == 1 and randf() < tile_chance and tileMap.map_to_world(tile_pos) != player.position:
			var localCell = tileMap.map_to_world(tile_pos)
			var globalCell = tileMap.to_global(Vector2(localCell.x+16,localCell.y+16))
			var loaded_trap = random_dictionary(TRAPS_SCENES)
			var trap:Area2D = TRAPS_SCENES[loaded_trap].instance()
			trap.position = globalCell
			call_deferred("add_child",trap)

func generate_wall()->void:
	var cells = tileMap.get_used_cells()
	for tile_pos in cells:
		if tileMap.get_cellv(tile_pos) == 0:
			if tileMap.get_cell(tile_pos.x,tile_pos.y)==0:
				tileMap2.set_cellv(tile_pos,2)

func generate_ceiling()->void:
	var cells = tileMap.get_used_cells()
	for tile_pos in cells:
		if tileMap.get_cellv(tile_pos) == 0:
			if tileMap.get_cell(tile_pos.x,tile_pos.y+1)==0:
				tileMap2.set_cellv(tile_pos,5)
	

func reload_level():
	SceneTransition.start_transition_to("res://Game.tscn")
	#get_tree().reload_current_scene()

func random_dictionary(dictionary:Dictionary):
	var dict = dictionary.keys()
	dict = dict[randi() % dict.size()]
	
	return dict
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		reload_level()


func _place_object_in_scene(rooms:Array)->void:
	for room in rooms:
		if !(room.position *32).distance_to(player.global_position)<128:
			enemies_created +=1
			var loaded_enemy = random_dictionary(ENEMY_SCENES)
			var enemy:KinematicBody2D = ENEMY_SCENES[loaded_enemy].instance()
			var __ = enemy.connect("tree_exited",self,"_on_enemy_killed")
			enemy.global_position = room.position * 32 + Vector2(rand_range(-16,16),rand_range(-16,16))
			call_deferred("add_child",enemy)
	print(enemies_created)
	

func _on_enemy_killed()->void:
	enemies_killed += 1

