extends Area2D

signal attack_finished

onready var animation_player = $AnimationPlayer

enum STATES {IDLE, ATTACK}
var current_state = IDLE
var activation_vector = null
var rotationVariance = 10

func _ready():
	set_physics_process(false)

func attack(directionVector):
	# Called when the player users the attack func
	if current_state != ATTACK:
		activation_vector = directionVector
		_change_state(ATTACK)

func attackIsActive():
	return current_state == ATTACK

func _change_state(new_state):
	current_state = new_state
	match current_state:
		IDLE:
			activation_vector = null
			set_physics_process(false)
		ATTACK:
			set_physics_process(true)
			animation_player.play("WeaponSwing")

func _physics_process(delta):
	var overlapping_bodies = get_overlapping_bodies()
	if not overlapping_bodies:
		return
	for body in overlapping_bodies:
		if body.is_in_group("Enemy"):
			body.get_node("Sprite").set("modulate",Color(0.5,0.3,0.8)) # Temp to visualize hit
			return
		if is_owner(body):	#Can't hit yourself
			return
		if body.is_in_group("Projectile"):	# Hit a projectile
			$BarrierAudio.playing = true
			var newDirection = get_global_mouse_position()-body.position
			newDirection = newDirection.rotated(deg2rad(randi()%rotationVariance-rotationVariance))
			body.setDirection(newDirection) # Bullet changes direction to mouse location
			body.get_node("Sprite").set("modulate",Color(0.3,0.3,0.3)) # Temp to visualize hit
			body.setTarget(null)
	#set_physics_process(false)	#Limits to one enemy hit per swing. Probably need to redo

func is_owner(node):
	return node.get_path() == get_path()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if name == "WeaponSwing":
		_change_state(IDLE)
		emit_signal("attack_finished")