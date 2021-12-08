extends Character

enum {UP,DOWN}

const BULLET_SCENE: PackedScene = preload("res://Enemy/Bullet.tscn")


onready var shoot_timer: Timer = get_node("ShootTimer")

onready var weapons:Node2D = get_node("Weapons")

var current_weapon: Node2D


export(int) var projectile_speed: int = 150

var can_attack:bool = true

func _ready()->void:
	_restore_previous_state()


func _restore_previous_state()->void:
	self.hp = SaveData.hp
	for weapon in SaveData.weapons:
		weapon = weapon.duplicate()
		weapon.hide()
		weapon.position = Vector2.ZERO
		weapons.add_child(weapon)
	current_weapon = weapons.get_child(SaveData.equipped_weapon_index)
	current_weapon.show()



func _process(_delta:float) ->void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	current_weapon.move(mouse_direction)
		
		
func get_input() ->void:
	move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		move_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		move_direction += Vector2.UP
		
	
	if not current_weapon.is_busy():
		if Input.is_action_just_released("ui_prev_weapon"):
			_switch_weapon(UP)
		elif Input.is_action_just_released("ui_next_weapon"):
			_switch_weapon(DOWN)
		elif Input.is_action_just_pressed("ui_throw_weapon") and current_weapon.get_index() != 0:
			_drop_weapon()
	
	current_weapon.get_input()


func _switch_weapon(direction:int)->void:
	var index:int = current_weapon.get_index()
	if direction == UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0
	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	SaveData.equipped_weapon_index = index


func _shoot_bullet()->void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	var projectile:Area2D =BULLET_SCENE.instance()
	projectile.fire(global_position,mouse_direction,projectile_speed)
	get_tree().current_scene.add_child(projectile)
	



func _on_ShootTimer_timeout() ->void:
	can_attack = true


func cancel_attack()->void:
	current_weapon.cancel_attack()


func switch_camera()->void:
	var main_scene_camera: Camera2D = get_tree().current_scene.get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false

func pick_up_weapon(weapon:Node2D)->void:
	SaveData.weapons.append(weapon.duplicate())
	SaveData.equipped_weapon_index = weapons.get_child_count()
	weapon.get_parent().call_deferred("remove_child",weapon)
	weapons.call_deferred("add_child",weapon)
	weapon.set_deferred("owner",weapons)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon
	
func _drop_weapon()->void:
	SaveData.weapons.remove(current_weapon.get_index() - 1)
	var weapon_to_drop:Node2D = current_weapon
	_switch_weapon(UP)
	weapons.call_deferred("remove_child",weapon_to_drop)
	get_parent().call_deferred("add_child",weapon_to_drop)
	weapon_to_drop.set_owner(get_parent())
	yield(weapon_to_drop.tween,"tree_entered")
	weapon_to_drop.show()
	
	var throw_dir:Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.interpolate_pos(position,position+throw_dir*50)


