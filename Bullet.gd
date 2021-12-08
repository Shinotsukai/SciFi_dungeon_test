extends Hitbox

var player_exited: bool = false

var direction: Vector2 = Vector2.ZERO
var bullet_speed: int = 0

func fire(init_pos:Vector2,dir:Vector2,speed:int)->void:
	position = init_pos
	direction = dir
	knockback_direction = dir
	bullet_speed = speed
	
	rotation += dir.angle()+PI/4
	
	
func _physics_process(delta:float)->void:
	position += direction * bullet_speed * delta


func _on_Bullet_body_exited(body:KinematicBody2D)->void:
	if not player_exited:
		player_exited = true
		set_collision_mask_bit(0,true)
		set_collision_mask_bit(2,true)
		
func _collide(body:KinematicBody2D)->void:
	if player_exited:
		if body != null:
			body.take_damage(damage,knockback_direction,knockback_force)
			queue_free()
