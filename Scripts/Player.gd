extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var MOTION_SPEED = 500
var movedir = Vector2(0,0)
var RayNode

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	
	RayNode = get_node("RayCast2D")	#For directions

func _physics_process(delta):
	controls_loop()
	movement_loop()

func controls_loop():
	var LEFT	= Input.is_action_pressed("ui_left")
	var RIGHT	= Input.is_action_pressed("ui_right")
	var UP	= Input.is_action_pressed("ui_up")
	var DOWN	= Input.is_action_pressed("ui_down")
	
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)
	
func movement_loop():
	var motion = movedir.normalized() * MOTION_SPEED
	move_and_slide(motion, Vector2(0,0))