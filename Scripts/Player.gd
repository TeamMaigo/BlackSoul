extends KinematicBody2D

export var NORMAL_SPEED = 500
var MOTION_SPEED = NORMAL_SPEED
var maxDashSpeed = 2000
onready var SpriteNode = get_node("Sprite")
onready var AnimNode = get_node("AnimationPlayer")
onready var WeaponNode = get_node("RotationNode/WeaponSwing")
onready var RotationNode = get_node("RotationNode")
var movedir = Vector2(0,0)
#var RayNode
var CollisionNode
onready var dashTimer = $dashTimer
onready var swapTimer = $swapTimer
var dashAvailable = true
var dashUnlocked = false
var swapAvailable = true
var swapUnlocked = false
var barrierAvailable = true
var barrierUnlocked = false
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
var swapInvulnTime = 5.0/60.0 # invuln for 5 frames
var swapNoticeTime = 0.5 # enemies don't notice you for this time (seconds)
onready var swapInvulnTimer = $swapInvulnTimer
onready var swapNoticeTimer = $swapNoticeTimer
var swapInvuln = false
var swappedRecently = false
var dashInvuln = false
var minDashInvulnSpeed = 1300
var maxDashInvulnSpeed = 1800
var piecesOfHeart = 0
var trauma = 0

onready var healthBar = $CanvasLayer/PlayerUI/HealthBar
onready var healthUpProgress = $CanvasLayer/PlayerUI/HealthUpProgress

func _ready():
	set_physics_process(true)
	#RayNode = get_node("RayCast2D")	#For directions
	CollisionNode = get_node("Collision")
	lastTransferPoint = position
	$RotationNode.hide()
	updateHealthBar()
	#healthUpProgress.setMaxValue(3)

func _physics_process(delta):
	mousePos = get_global_mouse_position()
	if playerControlEnabled:
		controls_loop()
		movement_loop()
	speed_decay()
	CollisionNode.disabled = false # Reenable collision (Has to do with swap code)
	updateCamera()

func updateCamera():
	var targetPosition = (mousePos*0.3+global_position*0.7)
	$Camera2D.global_position = (targetPosition*0.8+$Camera2D.global_position*0.2)
	var multiplier = randi()%2
	if multiplier == 0:
		multiplier = -1
	var offsetValue = (trauma*trauma) * 0.001 * multiplier
	$Camera2D.offset = Vector2(offsetValue, offsetValue)
	$Camera2D.rotation = trauma * 0.0001 * multiplier
	if trauma != 0:
		trauma -= 2.5
		if trauma < 0:
			trauma = 0

func instantCameraUpdate():
	$Camera2D.position = (get_global_mouse_position()*0.3+global_position*0.7)

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

	if DASH && dashAvailable && dashUnlocked:
		MOTION_SPEED = maxDashSpeed
		dashAvailable = false
		dashDelay(DASH_DELAY)	# Start dash cooldown timer
		trauma = 40
		$PlayerAudio.stream = load("res://Audio/Warp.wav")
		$PlayerAudio.volume_db = Global.masterSound
		$PlayerAudio.play()

	if SWAP && swapAvailable && swapUnlocked:
		playerPos = SpriteNode.position
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, mousePos, [self], 5) # 5 refers to layer mask
		if result:
			if result.collider.is_in_group("Enemy"):
				swappedRecently = true
				swapPlaces(self, result.collider)
				trauma = 110
				$PlayerAudio.stream = load("res://Audio/Warp.wav")
				$PlayerAudio.volume_db = Global.masterSound
				$PlayerAudio.play()
				swapAvailable = false
				SpriteNode.set("modulate",Color(1,0.3,0.3,1))
				swapInvuln = true
				swapDelay(SWAP_DELAY)
				swapInvuln(swapInvulnTime)
				swapNotice(swapNoticeTime)
	
	mousePos = get_global_mouse_position()
	var attackDirection = Vector2(1, 0).rotated(get_angle_to(mousePos))
	RotationNode.rotation_degrees = rad2deg(get_angle_to(mousePos))
	
	if BARRIER and barrierAvailable && barrierUnlocked:
		barrierAvailable = false
		$RotationNode.show()
		$Sprite.modulate.g = 0
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
		if MOTION_SPEED > minDashInvulnSpeed and MOTION_SPEED < maxDashInvulnSpeed:
			dashInvuln = true
			SpriteNode.set("modulate",Color(0,0,233.0/255,1)) # Used to test dash
		else:
			dashInvuln = false
			SpriteNode.set("modulate",Color(1,1,1,1))
	elif MOTION_SPEED == NORMAL_SPEED:
		pass
	else:
		#SpriteNode.set("modulate",Color(233.0/255,255,255,1))
		MOTION_SPEED = NORMAL_SPEED

func dashDelay(sec):
	dashTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	dashTimer.start() # Start the Timer counting down
	yield(dashTimer, "timeout") # Wait for the timer to wind down
	dashAvailable = true

func swapDelay(sec):
	swapTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	swapTimer.start() # Start the Timer counting down
	yield(swapTimer, "timeout") # Wait for the timer to wind down
	swapAvailable = true
	SpriteNode.set("modulate",Color(1,1,1))

func swapInvuln(sec):
	swapInvulnTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	swapInvulnTimer.start() # Start the Timer counting down
	yield(swapInvulnTimer, "timeout") # Wait for the timer to wind down
	swapInvuln = false

func swapNotice(sec):
	swapNoticeTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	swapNoticeTimer.start() # Start the Timer counting down
	yield(swapNoticeTimer, "timeout") # Wait for the timer to wind down
	swappedRecently = false

func swapPlaces(player, enemy): # Takes in player node and enemy collider
	CollisionNode.disabled = true	# Disable collision to avoid displacement bug after teleport
	var tempEnemyPos = enemy.position
	enemy.position = position
	position = tempEnemyPos

func takeDamage(damage):
	if vulnerable and not swapInvuln and not dashInvuln:
		vulnerable = false
		trauma = 60
		$PlayerAudio.stream = load("res://Audio/HitSound.wav")
		$PlayerAudio.volume_db = Global.masterSound
		$PlayerAudio.play()
		health -= damage
		updateHealthBar()
		$InvulPlayer.play("Invuln")
		if health <= 0:
			respawn()

func updateHealthBar():
	healthBar.setMaxValue(maxHealth)
	healthBar.setValue(health)

func updateHealthUpProgress():
	if piecesOfHeart == 3:
		piecesOfHeart = 0
		maxHealth += 1
		setHealth(maxHealth)
	get_node("PlayerAudio").stream = load("res://Audio/RecievedChat.ogg")
	get_node("PlayerAudio").playing = true
	get_node("PlayerAudio").volume_db = Global.masterSound
	healthUpProgress.setValue(piecesOfHeart)

func setHealth(value):
	health = value
	updateHealthBar()

func respawn():
	playerControlEnabled = false
	get_node("../").reloadLastScene()
	health = maxHealth
	updateHealthBar()

func _on_InvulPlayer_animation_finished(anim_name):
	if anim_name == "Invuln":
		vulnerable = true


func _on_WeaponSwing_attack_finished():
	barrierAvailable = true
	$Sprite.modulate.g = 1

func save():
	var saveDict = {
		"filename": filename,
		"parent": get_parent().get_path(),
		"health": maxHealth,
		"maxHealth": maxHealth,
		"position": position,
		"dashUnlocked": dashUnlocked,
		"swapUnlocked": swapUnlocked,
		"barrierUnlocked": barrierUnlocked
	}
	return saveDict
