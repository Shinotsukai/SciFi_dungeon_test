extends FiniteStateMachine

func _init()->void:
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")
	
	

func _ready() ->void:
	set_state(states.idle)

func _state_logic(_delta:float)->void:
	if state == states.idle:
		parent.find_player()
	
	if state == states.chase:
		parent.find_player()
		parent.move()

func _get_transition()->int:
	match state:
		states.hurt:
			if not animation_player.is_playing():
				return states.chase
	return -1

func _enter_state(_previous_state:int, new_state:int)->void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.chase:
			animation_player.play("move")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")

