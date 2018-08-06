extends KinematicBody2D

export var NORMAL_SPEED = 500
var MOTION_SPEED = NORMAL_SPEED
onready var SpriteNode = get_node("Sprite")
onready var AnimNode = get_node("AnimationPlayer")
onready var WeaponNode = get_node("RotationNode/WeaponSwing")
onready var RotationNode = get_node("RotationNode")
var movedir = Vector2(0,0)
#var RayNode
var CollisionNode
var dashTimer = 0
var dashAvailable = true
var swapTimer = 0
var swapAvailable = true
var barrierAvailable = true
var playerPos
var mousePos
var DASH_DELAY = 1	# in seconds
var SWAP_DELAY = 2
var maxHealth = 3
var health = maxHealth
var lastTransferPoint
var anim = "Idle"
var animNew = ""
var vulnerable = true
var playerControlEnabled = true
var swapInvulnTimer = 5 #Frames
var swapInvuln = false

func _ready():
	set_physics_process(true)
	#RayNode = get_node("RayCast2D")	#For directions
	CollisionNode = get_node("Collision")
	lastTransferPoint = position
	$RotationNode.hide()

func _physics_process(delta):
	if playerControlEnabled:
		controls_loop()
		movement_loop()
	speed_decay()
	dash_delay(DASH_DELAY, delta)	# Check if dash can be renabled
	swap_delay(SWAP_DELAY, delta)
	CollisionNode.disabled = false # Reenable collision (Has to do with swap code)

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP		= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	var DASH	= Input.is_action_pressed("ui_dash")
	var SWAP	= Input.is_action_pressed("ui_swap")
	var BARRIER	= Input.is_action_pressed("ui_barrier")

	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	
	if movedir.y > 0:
		anim = "PlayerWalkingDown"
	elif movedir.y < 0:
		anim = "PlayerWalkingUp"
	if movedir.x > 0:
		anim = "PlayerWalkingRight"
	elif movedir.x < 0:
		anim = "PlayerWalkingLeft"

	#if not $WeaponSwing.attackIsActive():
	#	look_at(mousePos) #If we want player to rotate to face mouse

	if DASH && dashAvailable:
		MOTION_SPEED = 2000
		dashAvailable = false

	if SWAP && swapAvailable:
		playerPos = SpriteNode.position
		mousePos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, mousePos, [self], 5) # 5 refers to layer mask
		if result:
			if result.collider.is_in_group("Enemy"):
				swapPlaces(self, result.collider)
		swapAvailable = false
		SpriteNode.set("modulate",Color(1,0.3,0.3,1))
		swapInvuln = true
		
	mousePos = get_global_mouse_position()
	var attackDirection = Vector2(1, 0).rotated(get_angle_to(mousePos))
	RotationNode.rotation_degrees = rad2deg(get_angle_to(mousePos))
	if BARRIER and barrierAvailable:
		barrierAvailable = false
		$RotationNode.show()
		WeaponNode.attack(attackDirection)


func movement_loop():
	var motion = movedir.normalized() * MOTION_SPEED
	move_and_slide(motion)
	if movedir == Vector2():
		anim = "Idle"
	if anim != animNew:
		animNew = anim
		AnimNode.play(anim)
	for i in range(get_slide_count()):
		var collisions = get_slide_collision(i)
		if collisions:	# Note: Causes a double hit bug where if you touch a projectile in the same frame it touches you,
		# you get hit twice. This can be solved through invulnerability frames after being hit.
			if collisions.collider.is_in_group("Projectile"):
				var projectile = collisions.collider #The extra .get_node("./") doesn't seem to do anything, not sure why?
				projectile.collide(self)
			if collisions.collider.is_in_group("Pickup"):
				var collider = collisions.collider.get_node("./")
				collider.applyEffect(self)
		pass

func speed_decay():
	if MOTION_SPEED > NORMAL_SPEED:
		#SpriteNode.set("modulate",Color(233.0/255,0,0,1)) # Used to test dash
		MOTION_SPEED *= 0.90
	elif MOTION_SPEED == NORMAL_SPEED:
		pass
	else:
		#SpriteNode.set("modulate",Color(233.0/255,255,255,1))
		MOTION_SPEED = NORMAL_SPEED

func dash_delay(sec, delta):
	dashTimer += delta
	if dashTimer > sec:
		dashAvailable = true
		dashTimer = 0

func swap_delay(sec, delta):
	swapTimer += delta
	if swapTimer >= swapInvulnTimer:
		swapInvuln = false
	if swapTimer > sec:
		swapAvailable = true
		SpriteNode.set("modulate",Color(1,1,1))
		swapTimer = 0

func swapPlaces(player, enemy): # Takes in player node and enemy collider
	CollisionNode.disabled = true	# Disable collision to avoid displacement bug after teleport
	var tempEnemyPos = enemy.position
	enemy.position = position
	position = tempEnemyPos

func takeDamage(damage):
	if vulnerable and not swapInvuln:
		vulnerable = false
		$PlayerAudio.stream = load("res://Audio/Wilhelm-Scream.wav")
		$PlayerAudio.volume_db = Global.masterSound
		$PlayerAudio.play()
		health -= damage
		updateHealthBar()
		$InvulPlayer.play("Invuln")
		if health <= 0:
			respawn()

func updateHealthBar():
		$CanvasLayer/PlayerUI/ProgressBar.value = (float(health)/float(maxHealth)) * 100

func respawn():
	get_node("../").reloadLastScene()
	health = maxHealth
	updateHealthBar()

func _on_InvulPlayer_animation_finished(anim_name):
	if anim_name == "Invuln":
		vulnerable = true


func _on_WeaponSwing_attack_finished():
	barrierAvailable = true
