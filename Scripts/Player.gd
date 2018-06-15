extends KinematicBody2D
# class member variables go here, for example:

export var NORMAL_SPEED = 500
var MOTION_SPEED = NORMAL_SPEED
onready var SpriteNode = get_node("Sprite")
var movedir = Vector2(0,0)
var RayNode
var CollisionNode
var dashTimer
var dashAvailable
var swapTimer
var swapAvailable
var playerPos
var mousePos
var DASH_DELAY = 1	# in seconds
var SWAP_DELAY = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	dashTimer = 0
	swapTimer = 0
	#RayNode = get_node("RayCast2D")	#For directions
	CollisionNode = get_node("Collision")
	dashAvailable = 1
	swapAvailable = 1

func _physics_process(delta):
	controls_loop()
	movement_loop()
	speed_decay()
	dash_delay(DASH_DELAY, delta)	# Check if dash can be renabled
	swap_delay(SWAP_DELAY, delta)
	CollisionNode.disabled = false # Reenable collision (Has to do with swap code)

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP	= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	var DASH = Input.is_action_pressed("ui_dash")
	var SWAP = Input.is_action_pressed("ui_swap")

	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)

	#mousePos = get_global_mouse_position() #If we want player to rotate to face mouse
	#look_at(mousePos)

	if DASH && dashAvailable:
		MOTION_SPEED = 2000
		dashAvailable = 0

	if SWAP && swapAvailable:
		playerPos = SpriteNode.position
		mousePos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, mousePos, [self], collision_mask)
		if result:
			if result.collider.is_in_group("EnemyGroup"):
				swapPlaces(self, result.collider)

		swapAvailable = 0
		SpriteNode.set("modulate",Color(50.0/120,150,0,1))

func movement_loop():
	var motion = movedir.normalized() * MOTION_SPEED
	move_and_slide(motion)#, Vector2(0,0))

func speed_decay():
	if MOTION_SPEED > NORMAL_SPEED:
		SpriteNode.set("modulate",Color(233.0/255,0,0,1)) # Used to test dash
		MOTION_SPEED *= 0.90
	elif MOTION_SPEED == NORMAL_SPEED:
		pass
	else:
		SpriteNode.set("modulate",Color(233.0/255,255,255,1))
		MOTION_SPEED = NORMAL_SPEED

func dash_delay(sec, delta):
	dashTimer += delta
	if dashTimer > sec:
		dashAvailable = 1
		dashTimer = 0

func swap_delay(sec, delta):
	swapTimer += delta
	if swapTimer > sec:
		swapAvailable = 1
		SpriteNode.set("modulate",Color(233.0/255,255,255,1))
		swapTimer = 0

func swapPlaces(player, enemy): # Takes in player node and enemy collider
	CollisionNode.disabled = true	# Disable collision to avoid displacement bug after teleport
	var tempEnemyPos = enemy.position
	enemy.position = position
	position = tempEnemyPos