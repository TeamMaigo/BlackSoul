extends KinematicBody2D

export (Vector2) var railStart = Vector2(0.0,0.0)
export (Vector2) var railEnd = Vector2(50.0,0.0)
export var railSpeed = 2

var componentCount = 2		# (e.g. sprite, collisionShape2D)

var velocity = Vector2()
var dVector = Vector2()
var traversingForwards = true # true = going from start to end, false = back from end to start

# Use if more than two waypoints
var lastPointReached = 0 # 0 is start, 1 is the next point from start, and so on and so forth

func _ready():
	set_physics_process(true)
	
	#Initialize global positions of rail locations
	railStart += global_position
	railEnd += global_position
	
	if len(get_children()) > componentCount:
		var obj = get_children()[componentCount] #The item after the last component should be a container
		obj.global_position = global_position #Place the container at the Rotator
	pass

func _process(delta):
	# Test print statements
	#print("New frame")
	#print(railStart)
	#print(railEnd)
	#print(global_position)
	
	#Remove unexpected children
	while len(get_children()) > componentCount + 1: #Allow for components and one container
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos
	
	# Check if destination has been reached yet; change direction if so
	if(traversingForwards and (railEnd == global_position)):
		print("Reached the end!")
		traversingForwards = false
	elif(!traversingForwards and (railStart == global_position)):
		print("Reached the start!")
		traversingForwards = true
		
	# Get direction vector (not yet normalized)
	if(traversingForwards):
		dVector = railEnd - global_position
	else:
		dVector = railStart - global_position
	# If destination won't be reached next frame, normalize the vector and move by railSpeed
	if(dVector.length() > railSpeed):
		dVector = dVector.normalized() * railSpeed
	
	# Set velocity
	velocity = dVector
	global_position += velocity

#func _physics_process(delta):
#	move_and_slide(velocity)

func moveCargo():
	pass

func changePoint():
	pass