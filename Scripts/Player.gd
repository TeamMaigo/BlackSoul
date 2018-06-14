extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var MOTION_SPEED = 500
var movedir = Vector2(0,0)
var RayNode
var timer
var dashAvailable

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	timer = 0
	RayNode = get_node("RayCast2D")	#For directions
	dashAvailable = 1

func _physics_process(delta):
	controls_loop()
	movement_loop()
	speed_decay()
	dash_delay(3, delta)

func speed_decay():
	if MOTION_SPEED > 500:
		MOTION_SPEED *= 0.95
	else:
		MOTION_SPEED = 500

func dash_delay(sec, delta):
	timer += delta
	if timer > sec:
		dashAvailable = 1
		timer = 0

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP	= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	var dash = Input.is_action_pressed("ui_dash")
	
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	if dash && dashAvailable:
		MOTION_SPEED = 1000
		dashAvailable = 0
	dash = 0
	
func movement_loop():
	var motion = movedir.normalized() * MOTION_SPEED
	move_and_slide(motion, Vector2(0,0))