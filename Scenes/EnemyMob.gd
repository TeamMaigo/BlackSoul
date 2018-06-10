extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var frame
var direction
var movedir = Vector2(0,0)
var MOTION_SPEED = 200

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	frame = 0
	direction = randi() % 4

func _process(delta):
	frame += 1
	if frame > 45:
		frame = 0
		direction = randi() % 4
	if direction == 0:
		movedir.x = -1
		movedir.y = 0
	elif direction == 1:
		movedir.x = 1
		movedir.y = 0
	elif direction == 2:
		movedir.x = 0
		movedir.y = -1
	elif direction == 3:
		movedir.x = 0
		movedir.y = 1
	else:
		pass
	
	movement_loop()
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	passrandi() % 4

func movement_loop():
	var motion = movedir.normalized() * MOTION_SPEED
	move_and_slide(motion, Vector2(0,0))