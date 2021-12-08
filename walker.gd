extends Node
class_name Walker

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []
var steps_since_turn = 0
var rooms = []
var avaliable_rooms = []

export(float, 0.0,1.0) var enemy_room_chance:float = 0.4
export(float, 0.0,1.0) var trap_room_chance:float = 0.8
var enemy_rooms:Array =[]
var trap_rooms:Array=[]

func _init(starting_position, new_borders):
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders

func walk(steps,turns):
	place_room(position)
	for step in steps:
		if steps_since_turn >= turns:
			change_direction()
		
		if step():
			step_history.append(position)
		else:
			change_direction()
	avaliable_rooms = rooms
	return step_history

func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		return true
	else:
		return false

func change_direction():
	place_room(position)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func create_room(position, size):
	return {position = position, size = size}

func place_room(position):
	var size = Vector2(randi() % 4 + 2, randi() % 4 + 2)
	var top_left_corner = (position - size/2).ceil()
	rooms.append(create_room(position, size))
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				step_history.append(new_step)

func get_end_room():
	var end_room = rooms.pop_front()
	var starting_position = step_history.front()
	for room in rooms:
		if starting_position.distance_to(room.position) > starting_position.distance_to(end_room.position):
			end_room = room
			avaliable_rooms.erase(room)
	return end_room

func place_enemy():
	for room in avaliable_rooms:
		if randf() < enemy_room_chance:
			enemy_rooms.append(room)
			avaliable_rooms.erase(room)
	return enemy_rooms

func place_traps():
	for room in avaliable_rooms:
		if randf() < trap_room_chance:
			trap_rooms.append(room)
	return trap_rooms


