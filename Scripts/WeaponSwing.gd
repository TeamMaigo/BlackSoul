extends Area2D

signal attack_finished

onready var animation_player = $AnimationPlayer

enum STATES {IDLE, ATTACK}
var current_state = IDLE

func _ready():
	set_physics_process(false)

func attack():
	# Called when the player users the attack func
	if current_state != ATTACK:
		_change_state(ATTACK)

func _change_state(new_state):
	current_state = new_state
	match current_state:
		IDLE:
			set_physics_process(false)
		ATTACK:
			set_physics_process(true)
			animation_player.play("WeaponSwing")

func _physics_process(delta):
	var overlapping_bodies = get_overlapping_bodies()
	if not overlapping_bodies:
		return
	for body in overlapping_bodies:
		if not body.is_in_group("Enemy"):
			return
		if is_owner(body):	#Can't hit yourself
			return
		body.get_node("Sprite").set("modulate",Color(0.3,0.3,0.3)) # Temp to visualize hit
		#body.reflectProjectile() #Handle reflecting projectiles
	set_physics_process(false)	#Limits to one enemy hit per swing. Probably need to redo

func is_owner(node):
	return node.get_path() == get_path()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if name == "WeaponSwing":
		_change_state(IDLE)
		emit_signal("attack_finished")
